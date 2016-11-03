Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C8CE46B02C9
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 06:41:27 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l124so28484201wml.4
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 03:41:27 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id k5si8185662wjo.179.2016.11.03.03.41.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Nov 2016 03:41:26 -0700 (PDT)
Subject: Re: [PATCH] mm: cma: improve utilization of cma pages
References: <201611031703.8WVh4Fcm%fengguang.wu@intel.com>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <581B141C.4080707@hisilicon.com>
Date: Thu, 3 Nov 2016 18:40:28 +0800
MIME-Version: 1.0
In-Reply-To: <201611031703.8WVh4Fcm%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, hannes@cmpxchg.org, kirill.shutemov@linux.intel.com, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, oliver.fu@hisilicon.com, suzhuangluan@hisilicon.com, qijiwen@hisilicon.com, xuyiping@hisilicon.com, puck.chen@foxmail.com

Sorry for this. Only test on arm64.

Should be this:
+#if IS_ENABLED(CONFIG_CMA)
+	if (gfp_flags & __GFP_MOVABLE)
+		return MIGRATE_CMA;
+#endif

On 2016/11/3 17:54, kbuild test robot wrote:
> Hi Chen,
> 
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.9-rc3 next-20161028]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Chen-Feng/mm-cma-improve-utilization-of-cma-pages/20161103-173624
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: x86_64-randconfig-x011-201644 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from include/linux/slab.h:14:0,
>                     from include/linux/crypto.h:24,
>                     from arch/x86/kernel/asm-offsets.c:8:
>    include/linux/gfp.h: In function 'gfpflags_to_migratetype':
>>> include/linux/gfp.h:274:10: error: 'MIGRATE_CMA' undeclared (first use in this function)
>       return MIGRATE_CMA;
>              ^~~~~~~~~~~
>    include/linux/gfp.h:274:10: note: each undeclared identifier is reported only once for each function it appears in
>    make[2]: *** [arch/x86/kernel/asm-offsets.s] Error 1
>    make[2]: Target '__build' not remade because of errors.
>    make[1]: *** [prepare0] Error 2
>    make[1]: Target 'prepare' not remade because of errors.
>    make: *** [sub-make] Error 2
> 
> vim +/MIGRATE_CMA +274 include/linux/gfp.h
> 
>    268	{
>    269		VM_WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
>    270		BUILD_BUG_ON((1UL << GFP_MOVABLE_SHIFT) != ___GFP_MOVABLE);
>    271		BUILD_BUG_ON((___GFP_MOVABLE >> GFP_MOVABLE_SHIFT) != MIGRATE_MOVABLE);
>    272	
>    273		if (IS_ENABLED(CONFIG_CMA) && gfp_flags & __GFP_MOVABLE)
>  > 274			return MIGRATE_CMA;
>    275	
>    276		if (unlikely(page_group_by_mobility_disabled))
>    277			return MIGRATE_UNMOVABLE;
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
