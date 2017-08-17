Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E2D686B02C3
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 07:31:29 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o8so12516551wrg.11
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 04:31:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n131si2432326wmf.60.2017.08.17.04.31.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Aug 2017 04:31:28 -0700 (PDT)
Date: Thu, 17 Aug 2017 13:31:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/mempolicy: fix use after free when calling
 get_mempolicy
Message-ID: <20170817113127.GE17781@dhcp22.suse.cz>
References: <1502950924-27521-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502950924-27521-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, rientjes@google.com, gregkh@linuxfoundation.org, linux-mm@kvack.org, stable@vger.kernel.org

On Thu 17-08-17 14:22:04, zhong jiang wrote:
> I hit an use after free issue by executing trinity. and repoduce it
> with KASAN enabled. The related call trace is as follows.
> 
> BUG: KASan: use after free in SyS_get_mempolicy+0x3c8/0x960 at addr ffff8801f582d766
> Read of size 2 by task syz-executor1/798
> 
> INFO: Allocated in mpol_new.part.2+0x74/0x160 age=3 cpu=1 pid=799
> __slab_alloc+0x768/0x970
> kmem_cache_alloc+0x2e7/0x450
> mpol_new.part.2+0x74/0x160
> mpol_new+0x66/0x80
> SyS_mbind+0x267/0x9f0
> system_call_fastpath+0x16/0x1b
> INFO: Freed in __mpol_put+0x2b/0x40 age=4 cpu=1 pid=799
> __slab_free+0x495/0x8e0
> kmem_cache_free+0x2f3/0x4c0
> __mpol_put+0x2b/0x40
> SyS_mbind+0x383/0x9f0
> system_call_fastpath+0x16/0x1b
> INFO: Slab 0xffffea0009cb8dc0 objects=23 used=8 fp=0xffff8801f582de40 flags=0x200000000004080
> INFO: Object 0xffff8801f582d760 @offset=5984 fp=0xffff8801f582d600
> 
> Bytes b4 ffff8801f582d750: ae 01 ff ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
> Object ffff8801f582d760: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> Object ffff8801f582d770: 6b 6b 6b 6b 6b 6b 6b a5                          kkkkkkk.
> Redzone ffff8801f582d778: bb bb bb bb bb bb bb bb                          ........
> Padding ffff8801f582d8b8: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
> Memory state around the buggy address:
> ffff8801f582d600: fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc fc
> ffff8801f582d680: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> >ffff8801f582d700: fc fc fc fc fc fc fc fc fc fc fc fc fb fb fb fc
> 
> !shared memory policy is not protected against parallel removal by other
> thread which is normally protected by the mmap_sem. do_get_mempolicy, 
> however, drops the lock midway while we can still access it later. Early
> premature up_read is a historical artifact from times when put_user was
> called in this path see https://lwn.net/Articles/124754/ but that is
> gone since 8bccd85ffbaf ("[PATCH] Implement sys_* do_* layering in the
> memory policy layer."). but when we have the the current mempolicy ref 
> count model. The issue was introduced accordingly.
> 
> The patch fix the issue by removing the premature release. it will safe
> access the mempolicy. The issue will leave.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: <stable@vger.kernel.org>		 [2.6+] 

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> v1->v2
>   - changelog is modified as Michal suggestion.
> 
>  mm/mempolicy.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index d911fa5..618ab12 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -861,11 +861,6 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>  		*policy |= (pol->flags & MPOL_MODE_FLAGS);
>  	}
>  
> -	if (vma) {
> -		up_read(&current->mm->mmap_sem);
> -		vma = NULL;
> -	}
> -
>  	err = 0;
>  	if (nmask) {
>  		if (mpol_store_user_nodemask(pol)) {
> -- 
> 1.7.12.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
