Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9674B8D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:10:45 -0400 (EDT)
Received: by pzk32 with SMTP id 32so1008189pzk.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 08:10:43 -0700 (PDT)
Date: Tue, 15 Mar 2011 00:10:23 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v6 4/9] memcg: add kernel calls for memcg dirty page
 stats
Message-ID: <20110314151023.GF11699@barrios-desktop>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-5-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299869011-26152-5-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>, KONISHI Ryusuke <konishi.ryusuke@lab.ntt.co.jp>

On Fri, Mar 11, 2011 at 10:43:26AM -0800, Greg Thelen wrote:
> Add calls into memcg dirty page accounting.  Notify memcg when pages
> transition between clean, file dirty, writeback, and unstable nfs.
> This allows the memory controller to maintain an accurate view of
> the amount of its memory that is dirty.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
> Changelog since v5:
> - moved accounting site in test_clear_page_writeback() and
>   test_set_page_writeback().
> 
>  fs/nfs/write.c      |    4 ++++
>  mm/filemap.c        |    1 +
>  mm/page-writeback.c |   10 ++++++++--
>  mm/truncate.c       |    1 +
>  4 files changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 42b92d7..7863777 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -451,6 +451,7 @@ nfs_mark_request_commit(struct nfs_page *req)
>  			NFS_PAGE_TAG_COMMIT);
>  	nfsi->ncommit++;
>  	spin_unlock(&inode->i_lock);
> +	mem_cgroup_inc_page_stat(req->wb_page, MEMCG_NR_FILE_UNSTABLE_NFS);
>  	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>  	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
>  	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> @@ -462,6 +463,7 @@ nfs_clear_request_commit(struct nfs_page *req)
>  	struct page *page = req->wb_page;
>  
>  	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
> +		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_UNSTABLE_NFS);
>  		dec_zone_page_state(page, NR_UNSTABLE_NFS);
>  		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
>  		return 1;
> @@ -1319,6 +1321,8 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
>  		req = nfs_list_entry(head->next);
>  		nfs_list_remove_request(req);
>  		nfs_mark_request_commit(req);
> +		mem_cgroup_dec_page_stat(req->wb_page,
> +					 MEMCG_NR_FILE_UNSTABLE_NFS);
>  		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
>  		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
>  				BDI_RECLAIMABLE);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index a6cfecf..7e751fe 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -143,6 +143,7 @@ void __delete_from_page_cache(struct page *page)
>  	 * having removed the page entirely.
>  	 */
>  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> +		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_DIRTY);
>  		dec_zone_page_state(page, NR_FILE_DIRTY);
>  		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
>  	}
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 632b464..d8005b0 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1118,6 +1118,7 @@ int __set_page_dirty_no_writeback(struct page *page)
>  void account_page_dirtied(struct page *page, struct address_space *mapping)
>  {
>  	if (mapping_cap_account_dirty(mapping)) {
> +		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_DIRTY);
>  		__inc_zone_page_state(page, NR_FILE_DIRTY);
>  		__inc_zone_page_state(page, NR_DIRTIED);
>  		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
> @@ -1317,6 +1318,7 @@ int clear_page_dirty_for_io(struct page *page)
>  		 * for more comments.
>  		 */
>  		if (TestClearPageDirty(page)) {
> +			mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_DIRTY);
>  			dec_zone_page_state(page, NR_FILE_DIRTY);
>  			dec_bdi_stat(mapping->backing_dev_info,
>  					BDI_RECLAIMABLE);
> @@ -1352,8 +1354,10 @@ int test_clear_page_writeback(struct page *page)
>  	} else {
>  		ret = TestClearPageWriteback(page);
>  	}
> -	if (ret)
> +	if (ret) {
> +		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_WRITEBACK);
>  		dec_zone_page_state(page, NR_WRITEBACK);
> +	}
>  	return ret;
>  }
>  
> @@ -1386,8 +1390,10 @@ int test_set_page_writeback(struct page *page)
>  	} else {
>  		ret = TestSetPageWriteback(page);
>  	}
> -	if (!ret)
> +	if (!ret) {
> +		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_WRITEBACK);
>  		account_page_writeback(page);
> +	}
>  	return ret;
>  
>  }

At least in mainline, NR_WRITEBACK handling codes are following as. 

1) increase

 * account_page_writeback

2) decrease

 * test_clear_page_writeback
 * __nilfs_end_page_io

I think account_page_writeback name is good to add your account function into that.
The problem is decreasement. Normall we can handle decreasement in test_clear_page_writeback.
But I am not sure it's okay in __nilfs_end_page_io.
I think if __nilfs_end_page_io is right, __nilfs_end_page_io should call 
mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_WRITEBACK). 

What do you think about it?



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
