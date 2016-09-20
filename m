Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE566B0253
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 04:28:33 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id s64so8711633lfs.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 01:28:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l17si30692139wjr.46.2016.09.20.01.28.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 01:28:32 -0700 (PDT)
Date: Tue, 20 Sep 2016 10:28:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3] mm,ksm: fix endless looping in allocating memory when
 ksm enable
Message-ID: <20160920082831.GG5477@dhcp22.suse.cz>
References: <1474358125-29716-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474358125-29716-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: hughd@google.com, penguin-kernel@I-love.SAKURA.ne.jp, rientjes@google.com, vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue 20-09-16 15:55:25, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> I hit the following hung task when runing a OOM LTP test case with
> 4.1 kernel.
> 
> Call trace:
> [<ffffffc000086a88>] __switch_to+0x74/0x8c
> [<ffffffc000a1bae0>] __schedule+0x23c/0x7bc
> [<ffffffc000a1c09c>] schedule+0x3c/0x94
> [<ffffffc000a1eb84>] rwsem_down_write_failed+0x214/0x350
> [<ffffffc000a1e32c>] down_write+0x64/0x80
> [<ffffffc00021f794>] __ksm_exit+0x90/0x19c
> [<ffffffc0000be650>] mmput+0x118/0x11c
> [<ffffffc0000c3ec4>] do_exit+0x2dc/0xa74
> [<ffffffc0000c46f8>] do_group_exit+0x4c/0xe4
> [<ffffffc0000d0f34>] get_signal+0x444/0x5e0
> [<ffffffc000089fcc>] do_signal+0x1d8/0x450
> [<ffffffc00008a35c>] do_notify_resume+0x70/0x78
> 
> The oom victim cannot terminate because it needs to take mmap_sem for
> write while the lock is held by ksmd for read which loops in the page
> allocator
> 
> ksm_do_scan
> 	scan_get_next_rmap_item
> 		down_read
> 		get_next_rmap_item
> 			alloc_rmap_item   #ksmd will loop permanently.
> 
> There is not way forward because the oom victim cannot release any
> memory in 4.1 based kernel. Since 4.6 we have the oom reaper which would
> solve this problem because it would release the memory asynchronously.
> Nevertheless we can relax alloc_rmap_item requirements and use
> __GFP_NORETRY because the allocation failure is acceptable as
> ksm_do_scan would just retry later after the lock got dropped.
> 
> Such a patch would be also easy to backport to older stable kernels
> which do not have oom_reaper.
> 
> While we are at it add GFP_NOWARN as the admin doesn't have to be
> alarmed by the allocation failure.
> 
> CC: <stable@vger.kernel.org>
> Suggested-by: Hugh Dickins <hughd@google.com>
> Suggested-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/ksm.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 73d43ba..5048083 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -283,7 +283,8 @@ static inline struct rmap_item *alloc_rmap_item(void)
>  {
>  	struct rmap_item *rmap_item;
>  
> -	rmap_item = kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
> +	rmap_item = kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL |
> +						__GFP_NORETRY | __GFP_NOWARN);
>  	if (rmap_item)
>  		ksm_rmap_items++;
>  	return rmap_item;
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
