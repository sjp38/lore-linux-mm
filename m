Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5626B0007
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 15:17:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y8-v6so5058486pfl.17
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 12:17:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g4-v6si9979870plm.181.2018.06.15.12.17.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 12:17:18 -0700 (PDT)
Date: Fri, 15 Jun 2018 12:17:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memblock: add missing include <linux/bootmem.h>
Message-Id: <20180615121716.37fb93385825b0b2f59240cc@linux-foundation.org>
In-Reply-To: <CA+8MBbKj4A5kh=hE0vcadzD+=cEAFY7OCWFCzvubu6cWULCJ0A@mail.gmail.com>
References: <20180606194144.16990-1-malat@debian.org>
	<CA+8MBbKj4A5kh=hE0vcadzD+=cEAFY7OCWFCzvubu6cWULCJ0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Mathieu Malaterre <malat@debian.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 15 Jun 2018 11:59:10 -0700 Tony Luck <tony.luck@gmail.com> wrote:

> On Wed, Jun 6, 2018 at 12:41 PM, Mathieu Malaterre <malat@debian.org> wrote:
> > Commit 26f09e9b3a06 ("mm/memblock: add memblock memory allocation apis")
> > introduced two new function definitions:
> >   a??memblock_virt_alloc_try_nid_nopanica??
> > and
> >   a??memblock_virt_alloc_try_nida??.
> > Commit ea1f5f3712af ("mm: define memblock_virt_alloc_try_nid_raw")
> > introduced the following function definition:
> >   a??memblock_virt_alloc_try_nid_rawa??
> >
> > This commit adds an includeof header file <linux/bootmem.h> to provide the
> > missing function prototypes. Silence the following gcc warning (W=1):
> >
> >   mm/memblock.c:1334:15: warning: no previous prototype for a??memblock_virt_alloc_try_nid_rawa?? [-Wmissing-prototypes]
> >   mm/memblock.c:1371:15: warning: no previous prototype for a??memblock_virt_alloc_try_nid_nopanica?? [-Wmissing-prototypes]
> >   mm/memblock.c:1407:15: warning: no previous prototype for a??memblock_virt_alloc_try_nida?? [-Wmissing-prototypes]
> >
> > Signed-off-by: Mathieu Malaterre <malat@debian.org>
> 
> Sadly that breaks ia64 build:
> 
>   CC      mm/memblock.o
> mm/memblock.c:1340: error: redefinition of a??memblock_virt_alloc_try_nid_rawa??
> ./include/linux/bootmem.h:335: error: previous definition of
> a??memblock_virt_alloc_try_nid_rawa?? was here
> mm/memblock.c:1377: error: redefinition of a??memblock_virt_alloc_try_nid_nopanica??
> ./include/linux/bootmem.h:343: error: previous definition of
> a??memblock_virt_alloc_try_nid_nopanica?? was here
> mm/memblock.c:1413: error: redefinition of a??memblock_virt_alloc_try_nida??
> ./include/linux/bootmem.h:327: error: previous definition of
> a??memblock_virt_alloc_try_nida?? was here
> make[1]: *** [mm/memblock.o] Error 1
> make: *** [mm/memblock.o] Error 2

Huh.  How did that ever work.  I guess it's either this:

--- a/mm/Makefile~a
+++ a/mm/Makefile
@@ -45,6 +45,7 @@ obj-y += init-mm.o
 
 ifdef CONFIG_NO_BOOTMEM
 	obj-y		+= nobootmem.o
+	obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
 else
 	obj-y		+= bootmem.o
 endif
@@ -53,7 +54,6 @@ obj-$(CONFIG_ADVISE_SYSCALLS)	+= fadvise
 ifdef CONFIG_MMU
 	obj-$(CONFIG_ADVISE_SYSCALLS)	+= madvise.o
 endif
-obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
 
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o swap_slots.o
 obj-$(CONFIG_FRONTSWAP)	+= frontswap.o


or this:

--- a/include/linux/bootmem.h~a
+++ a/include/linux/bootmem.h
@@ -154,7 +154,7 @@ extern void *__alloc_bootmem_low_node(pg
 	__alloc_bootmem_low_node(pgdat, x, PAGE_SIZE, 0)
 
 
-#if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)
+#if defined(CONFIG_HAVE_MEMBLOCK)
 
 /* FIXME: use MEMBLOCK_ALLOC_* variants here */
 #define BOOTMEM_ALLOC_ACCESSIBLE	0


and I'm not sure which.  I think I'll just revert $subject for now.
