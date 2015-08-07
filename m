Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B4C906B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 10:17:07 -0400 (EDT)
Received: by pawu10 with SMTP id u10so89846005paw.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 07:17:07 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id f11si17758647pdm.171.2015.08.07.07.17.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 07:17:06 -0700 (PDT)
Date: Fri, 7 Aug 2015 17:16:57 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [linux-next:master 6277/6751] mm/page_idle.c:67:4: error:
 implicit declaration of function 'pmdp_test_and_clear_young'
Message-ID: <20150807141657.GA30763@esperanza>
References: <201508072112.qcf4SmbI%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <201508072112.qcf4SmbI%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Aug 07, 2015 at 09:57:14PM +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   e6455bc5b91f41f842f30465c9193320f0568707
> commit: cbba4e22584984bffccd07e0801fd2b8ec1ecf5f [6277/6751] Move /proc/kpageidle to /sys/kernel/mm/page_idle/bitmap
> config: sh-allmodconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout cbba4e22584984bffccd07e0801fd2b8ec1ecf5f
>   # save the attached .config to linux build tree
>   make.cross ARCH=sh 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    mm/page_idle.c: In function 'page_idle_clear_pte_refs_one':
> >> mm/page_idle.c:67:4: error: implicit declaration of function 'pmdp_test_and_clear_young' [-Werror=implicit-function-declaration]
> >> mm/page_idle.c:71:3: error: implicit declaration of function 'page_check_address' [-Werror=implicit-function-declaration]
> >> mm/page_idle.c:71:7: warning: assignment makes pointer from integer without a cast [enabled by default]
> >> mm/page_idle.c:73:4: error: implicit declaration of function 'ptep_test_and_clear_young' [-Werror=implicit-function-declaration]
>    mm/page_idle.c: In function 'page_idle_clear_pte_refs':
> >> mm/page_idle.c:95:22: error: variable 'rwc' has initializer but incomplete type
> >> mm/page_idle.c:96:3: error: unknown field 'rmap_one' specified in initializer
> >> mm/page_idle.c:96:3: warning: excess elements in struct initializer [enabled by default]
> >> mm/page_idle.c:96:3: warning: (near initialization for 'rwc') [enabled by default]
> >> mm/page_idle.c:97:3: error: unknown field 'anon_lock' specified in initializer
> >> mm/page_idle.c:97:16: error: 'page_lock_anon_vma_read' undeclared (first use in this function)
>    mm/page_idle.c:97:16: note: each undeclared identifier is reported only once for each function it appears in
>    mm/page_idle.c:97:3: warning: excess elements in struct initializer [enabled by default]
>    mm/page_idle.c:97:3: warning: (near initialization for 'rwc') [enabled by default]
> >> mm/page_idle.c:95:40: error: storage size of 'rwc' isn't known
> >> mm/page_idle.c:109:2: error: implicit declaration of function 'rmap_walk' [-Werror=implicit-function-declaration]
> >> mm/page_idle.c:95:40: warning: unused variable 'rwc' [-Wunused-variable]
>    cc1: some warnings being treated as errors

IDLE_PAGE_TRACKING must depend on MMU. I accidentally lost this
dependency while moving /proc/kpageidle to sysfs, sorry about that.

The fix is below.
---
diff --git a/mm/Kconfig b/mm/Kconfig
index fe133a98a9ef..5f817f35ecc6 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -651,7 +651,7 @@ config DEFERRED_STRUCT_PAGE_INIT
 
 config IDLE_PAGE_TRACKING
 	bool "Enable idle page tracking"
-	depends on SYSFS
+	depends on MMU && SYSFS
 	select PAGE_EXTENSION if !64BIT
 	help
 	  This feature allows to estimate the amount of user pages that have

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
