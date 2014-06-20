Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0BCCA6B0031
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 17:14:18 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so3544229pad.27
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:14:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id to10si11248856pbc.228.2014.06.20.14.14.17
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 14:14:18 -0700 (PDT)
Date: Fri, 20 Jun 2014 14:14:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 130/230] mm/swap.c:719:2: error: implicit
 declaration of function 'TestSetPageMlocked'
Message-Id: <20140620141416.1f6930c591190557ff62416d@linux-foundation.org>
In-Reply-To: <53a397d7.WKpm75H8yvJSkNsS%fengguang.wu@intel.com>
References: <53a397d7.WKpm75H8yvJSkNsS%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Fri, 20 Jun 2014 10:09:27 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   df25ba7db0775d87018e2cd92f26b9b087093840
> commit: 8d72d7b20fab14a779df2f7ea7632d4ee223dfcc [130/230] mm: memcontrol: rewrite charge API
> config: make ARCH=m32r m32104ut_defconfig
> 
> All error/warnings:
> 
>    mm/swap.c: In function 'lru_cache_add_active_or_unevictable':
> >> mm/swap.c:719:2: error: implicit declaration of function 'TestSetPageMlocked' [-Werror=implicit-function-declaration]
>    cc1: some warnings being treated as errors
> 
> vim +/TestSetPageMlocked +719 mm/swap.c
> 
>    713		if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED)) {
>    714			SetPageActive(page);
>    715			lru_cache_add(page);
>    716			return;
>    717		}
>    718	
>  > 719		if (!TestSetPageMlocked(page)) {
>    720			/*
>    721			 * We use the irq-unsafe __mod_zone_page_stat because this
>    722			 * counter is not modified from interrupt context, and the pte
> 

hm, I can't think of anything very smart here.

--- a/mm/swap.c~mm-memcontrol-rewrite-charge-api-fix-2
+++ a/mm/swap.c
@@ -716,6 +716,7 @@ void lru_cache_add_active_or_unevictable
 		return;
 	}
 
+#ifdef CONFIG_MMU
 	if (!TestSetPageMlocked(page)) {
 		/*
 		 * We use the irq-unsafe __mod_zone_page_stat because this
@@ -726,6 +727,7 @@ void lru_cache_add_active_or_unevictable
 				    hpage_nr_pages(page));
 		count_vm_event(UNEVICTABLE_PGMLOCKED);
 	}
+#else
 	add_page_to_unevictable_list(page);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
