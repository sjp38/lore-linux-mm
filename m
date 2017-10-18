Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9620F6B0261
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 17:40:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 196so2663038wma.6
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 14:40:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d90si2387173edd.437.2017.10.18.14.40.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 14:40:22 -0700 (PDT)
Date: Wed, 18 Oct 2017 14:40:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [linux-next:master 6243/6567] WARNING:
 vmlinux.o(.text.unlikely+0x5fb7): Section mismatch in reference from the
 function __def_free() to the function .init.text:__free_pages_boot_core()
Message-Id: <20171018144019.c20bc90461c71fc80ac49ff4@linux-foundation.org>
In-Reply-To: <201710181834.h61cZcRt%fengguang.wu@intel.com>
References: <201710181834.h61cZcRt%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, kbuild-all@01.org, Mark Brown <broonie@kernel.org>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Bob Picco <bob.picco@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 18 Oct 2017 18:41:44 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   a7dd40274d75326ca868479c62090b1198a357ad
> commit: 430676b385fb341d5a33950bae284d0df2e70117 [6243/6567] mm: deferred_init_memmap improvements
> config: x86_64-randconfig-it0-10181522 (attached as .config)
> compiler: gcc-4.9 (Debian 4.9.4-2) 4.9.4
> reproduce:
>         git checkout 430676b385fb341d5a33950bae284d0df2e70117
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
> >> WARNING: vmlinux.o(.text.unlikely+0x5fb7): Section mismatch in reference from the function __def_free() to the function .init.text:__free_pages_boot_core()
>    The function __def_free() references
>    the function __init __free_pages_boot_core().
>    This is often because __def_free lacks a __init
>    annotation or the annotation of __free_pages_boot_core is wrong.

This?

--- a/mm/page_alloc.c~mm-deferred_init_memmap-improvements-fix
+++ a/mm/page_alloc.c
@@ -1448,7 +1448,7 @@ static inline void __init pgdat_init_rep
  * Helper for deferred_init_range, free the given range, reset the counters, and
  * return number of pages freed.
  */
-static inline unsigned long __def_free(unsigned long *nr_free,
+static unsigned long __init __def_free(unsigned long *nr_free,
 				       unsigned long *free_base_pfn,
 				       struct page **page)
 {
@@ -1462,8 +1462,8 @@ static inline unsigned long __def_free(u
 	return nr;
 }
 
-static unsigned long deferred_init_range(int nid, int zid, unsigned long pfn,
-					 unsigned long end_pfn)
+static unsigned long __init deferred_init_range(int nid, int zid,
+				unsigned long pfn, unsigned long end_pfn)
 {
 	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long nr_pgmask = pageblock_nr_pages - 1;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
