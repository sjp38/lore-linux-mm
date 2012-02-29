Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id CADA96B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 20:12:28 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 04FA73EE0BB
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:12:27 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DA36745DEAD
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:12:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B85B545DEA6
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:12:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AB8DD1DB803B
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:12:26 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 563CD1DB8038
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:12:26 +0900 (JST)
Date: Wed, 29 Feb 2012 10:10:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/9] memcg: add kernel calls for memcg dirty page stats
Message-Id: <20120229101054.98e121fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120228144747.044421224@intel.com>
References: <20120228140022.614718843@intel.com>
	<20120228144747.044421224@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 28 Feb 2012 22:00:25 +0800
Fengguang Wu <fengguang.wu@intel.com> wrote:

> From: Greg Thelen <gthelen@google.com>
> 
> Add calls into memcg dirty page accounting.  Notify memcg when pages
> transition between clean, file dirty, writeback, and unstable nfs.  This
> allows the memory controller to maintain an accurate view of the amount
> of its memory that is dirty.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: Andrea Righi <andrea@betterlinux.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  fs/nfs/write.c      |    4 ++++
>  mm/filemap.c        |    1 +
>  mm/page-writeback.c |    4 ++++
>  mm/truncate.c       |    1 +
>  4 files changed, 10 insertions(+)
> 
> --- linux.orig/fs/nfs/write.c	2012-02-19 10:53:14.000000000 +0800
> +++ linux/fs/nfs/write.c	2012-02-19 10:53:21.000000000 +0800
> @@ -449,6 +449,7 @@ nfs_mark_request_commit(struct nfs_page 
>  	nfsi->ncommit++;
>  	spin_unlock(&inode->i_lock);
>  	pnfs_mark_request_commit(req, lseg);
> +	mem_cgroup_inc_page_stat(req->wb_page, MEMCG_NR_FILE_UNSTABLE_NFS);

Hmm...Is the status UNSTABLE_NFS cannot be obtaiend by 'struct page' ?

One idea to avoid adding a new flag to pc->flags is..

Can't we do this by following if 'req' exists per page ?

	memcg = mem_cgroup_from_page(page);  # update memcg's refcnt+1
	req->memcg = memcg;		     # record memcg to req.
	mem_cgroup_inc_nfs_unstable(memcg)   # a new call



>  	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>  	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
>  	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> @@ -460,6 +461,7 @@ nfs_clear_request_commit(struct nfs_page
>  	struct page *page = req->wb_page;
>  
>  	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
> +		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_UNSTABLE_NFS);
>  		dec_zone_page_state(page, NR_UNSTABLE_NFS);
>  		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
>  		return 1;
> @@ -1408,6 +1410,8 @@ void nfs_retry_commit(struct list_head *
>  		req = nfs_list_entry(page_list->next);
>  		nfs_list_remove_request(req);
>  		nfs_mark_request_commit(req, lseg);
> +		mem_cgroup_dec_page_stat(req->wb_page,
> +					 MEMCG_NR_FILE_UNSTABLE_NFS);
>  		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>  		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
>  			     BDI_RECLAIMABLE);
> --- linux.orig/mm/filemap.c	2012-02-19 10:53:14.000000000 +0800
> +++ linux/mm/filemap.c	2012-02-19 10:53:21.000000000 +0800
> @@ -142,6 +142,7 @@ void __delete_from_page_cache(struct pag
>  	 * having removed the page entirely.
>  	 */
>  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> +		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_DIRTY);


I think we can make use of PageDirty() as explained.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
