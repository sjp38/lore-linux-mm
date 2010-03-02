Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E2DA26B0078
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 08:47:49 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp01.au.ibm.com (8.14.3/8.13.1) with ESMTP id o22Djguj029923
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 00:45:42 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o22Dg8ta1573044
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 00:42:08 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o22Dli26012759
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 00:47:45 +1100
Date: Tue, 2 Mar 2010 19:17:36 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-ID: <20100302134736.GG3212@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
 <1267478620-5276-4-git-send-email-arighi@develer.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1267478620-5276-4-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrea Righi <arighi@develer.com> [2010-03-01 22:23:40]:

> Apply the cgroup dirty pages accounting and limiting infrastructure to
> the opportune kernel functions.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> ---
>  fs/fuse/file.c      |    5 +++
>  fs/nfs/write.c      |    4 ++
>  fs/nilfs2/segment.c |   10 +++++-
>  mm/filemap.c        |    1 +
>  mm/page-writeback.c |   84 ++++++++++++++++++++++++++++++++------------------
>  mm/rmap.c           |    4 +-
>  mm/truncate.c       |    2 +
>  7 files changed, 76 insertions(+), 34 deletions(-)
> 
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index a9f5e13..dbbdd53 100644
> --- a/fs/fuse/file.c
> +++ b/fs/fuse/file.c
> @@ -11,6 +11,7 @@
>  #include <linux/pagemap.h>
>  #include <linux/slab.h>
>  #include <linux/kernel.h>
> +#include <linux/memcontrol.h>
>  #include <linux/sched.h>
>  #include <linux/module.h>
> 
> @@ -1129,6 +1130,8 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
> 
>  	list_del(&req->writepages_entry);
>  	dec_bdi_stat(bdi, BDI_WRITEBACK);
> +	mem_cgroup_update_stat(req->pages[0],
> +			MEM_CGROUP_STAT_WRITEBACK_TEMP, -1);
>  	dec_zone_page_state(req->pages[0], NR_WRITEBACK_TEMP);
>  	bdi_writeout_inc(bdi);
>  	wake_up(&fi->page_waitq);
> @@ -1240,6 +1243,8 @@ static int fuse_writepage_locked(struct page *page)
>  	req->inode = inode;
> 
>  	inc_bdi_stat(mapping->backing_dev_info, BDI_WRITEBACK);
> +	mem_cgroup_update_stat(tmp_page,
> +			MEM_CGROUP_STAT_WRITEBACK_TEMP, 1);
>  	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
>  	end_page_writeback(page);
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index b753242..7316f7a 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c

Don't need memcontrol.h to be included here?

Looks OK to me overall, but there might be objection using the
mem_cgroup_* naming convention, but I don't mind it very much :)

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
