Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7FAE6B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 10:04:04 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 30so5982238wrk.7
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 07:04:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l19si743058wrg.540.2017.08.16.07.04.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Aug 2017 07:04:03 -0700 (PDT)
Date: Wed, 16 Aug 2017 16:04:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/mempolicy: fix use after free when calling
 get_mempolicy
Message-ID: <20170816140400.GD32161@dhcp22.suse.cz>
References: <1502849621-12420-1-git-send-email-zhongjiang@huawei.com>
 <59944642.6050005@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59944642.6050005@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, oleg@redhat.com, vbabka@suse.cz, mgorman@techsingularity.net, rientjes@google.com, linux-mm@kvack.org, stable@vger.kernel.org

Hmm, I haven't received the original patch.
On Wed 16-08-17 21:18:58, zhong jiang wrote:
> + stable@vger.kernel.org

Anyway the proper way to route this to the stable tree is to put Cc:
stable to the sign-off-by area. It is also preferable if you could add
Fixes: sha1

which has caused the issue so that people know to which kernel versions
this should be backported.

> On 2017/8/16 10:13, zhong jiang wrote:
> > I hit an use after free issue by executing trinity. and repoduce it
> > with KASAN enabled. The related call trace is as follows.
> >
> > BUG: KASan: use after free in SyS_get_mempolicy+0x3c8/0x960 at addr ffff8801f582d766
> > Read of size 2 by task syz-executor1/798
> >
> > INFO: Allocated in mpol_new.part.2+0x74/0x160 age=3 cpu=1 pid=799
> > __slab_alloc+0x768/0x970
> > kmem_cache_alloc+0x2e7/0x450
> > mpol_new.part.2+0x74/0x160
> > mpol_new+0x66/0x80
> > SyS_mbind+0x267/0x9f0
> > system_call_fastpath+0x16/0x1b
> > INFO: Freed in __mpol_put+0x2b/0x40 age=4 cpu=1 pid=799
> > __slab_free+0x495/0x8e0
> > kmem_cache_free+0x2f3/0x4c0
> > __mpol_put+0x2b/0x40
> > SyS_mbind+0x383/0x9f0
> > system_call_fastpath+0x16/0x1b
> > INFO: Slab 0xffffea0009cb8dc0 objects=23 used=8 fp=0xffff8801f582de40 flags=0x200000000004080
> > INFO: Object 0xffff8801f582d760 @offset=5984 fp=0xffff8801f582d600
> >
> > Bytes b4 ffff8801f582d750: ae 01 ff ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
> > Object ffff8801f582d760: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > Object ffff8801f582d770: 6b 6b 6b 6b 6b 6b 6b a5                          kkkkkkk.
> > Redzone ffff8801f582d778: bb bb bb bb bb bb bb bb                          ........
> > Padding ffff8801f582d8b8: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
> > Memory state around the buggy address:
> > ffff8801f582d600: fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc fc
> > ffff8801f582d680: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> >> ffff8801f582d700: fc fc fc fc fc fc fc fc fc fc fc fc fb fb fb fc
> >
> > when calling get_mempolicy from userspace, it only hold the mmap_sem
> > and increase the shared pol count, the unshared pol is not be increased.
> > it premature release the mmap_sem, it will result in the related mempolicy
> > maybe had freed by mbind. then, the issue will trigger.

This is really hard to read. I assume you meant to say that !shared
memory policy is not protected against parallel removal by other thread
which is normally protected by the mmap_sem. do_get_mempolicy, however,
drops the lock midway while we can still access it later. Early
premature up_read is a historical artifact from times when put_user was
called in this path see https://lwn.net/Articles/124754/ but that is
gone since 8bccd85ffbaf ("[PATCH] Implement sys_* do_* layering in the
memory policy layer."). I didn't check since when we have the current
mempolicy ref count model though but it is really old...

> > The patch fix the issue by removing the premature release. it will safe
> > access the mempolicy. The issue will leave.
> >
> > Signed-off-by: zhong jiang <zhongjiang@huawei.com>

The fix looks good to me, feel free to use above information for a
better changelog
Acked-by: Michal Hocko <mhocko@suse.com>

> > ---
> >  mm/mempolicy.c | 5 -----
> >  1 file changed, 5 deletions(-)
> >
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index d911fa5..618ab12 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -861,11 +861,6 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
> >  		*policy |= (pol->flags & MPOL_MODE_FLAGS);
> >  	}
> >  
> > -	if (vma) {
> > -		up_read(&current->mm->mmap_sem);
> > -		vma = NULL;
> > -	}
> > -
> >  	err = 0;
> >  	if (nmask) {
> >  		if (mpol_store_user_nodemask(pol)) {
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
