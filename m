Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE4706B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 10:49:05 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w84so15621902wmg.1
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 07:49:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si19024665wjt.20.2016.09.18.07.49.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Sep 2016 07:49:04 -0700 (PDT)
Date: Sun, 18 Sep 2016 16:49:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,ksm: fix endless looping in allocating memory when
 ksm enable
Message-ID: <20160918144858.GB28476@dhcp22.suse.cz>
References: <1474165570-44398-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474165570-44398-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: hughd@google.com, akpm@linux-foundation.org, qiuxishi@huawei.com, guohanjun@huawei.com, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On Sun 18-09-16 10:26:10, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> I hit the following issue when run a OOM case of the LTP and
> ksm enable.
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
> it will leads to a hung task because the exiting task cannot get the
> mmap sem for write. but the root cause is that the ksmd holds it for
> read while allocateing memory which just takes ages to complete.
> and ksmd  will loop in the following path.
> 
>  scan_get_next_rmap_item
>           down_read
>                 get_next_rmap_item
>                         alloc_rmap_item   #ksmd will loop permanently.
> 
> we fix it by changing the GFP to allow the allocation sometimes fail, and
> we're not at all interested in hearing abot that.

Two things. As Tetsuo (who is not on the CC list - added) pointed out
earlier it is important to mention which kernel version this was
triggered because the current version shouldn't be affected because of
the recent oom changes (mainly the oom reaper). The other thing is that
the changelog doesn't say _why_ failing early is OK. __GFP_NORETRY not
only allows allocations to fail it also doesn't trigger OOM killer. This
sounds OK but the changelog should be clear this is intentional and
reasonable (especially when it is marked for stable).

> CC: <stable@vger.kernel.org>
> Suggested-by: Hugh Dickins <hughd@google.com>
> Suggested-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
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
