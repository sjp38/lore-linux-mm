Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 30AA06B003D
	for <linux-mm@kvack.org>; Mon,  9 Feb 2009 12:06:42 -0500 (EST)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1232919337-21434-1-git-send-email-righi.andrea@gmail.com>
References: <1232919337-21434-1-git-send-email-righi.andrea@gmail.com>
Subject: Re: [PATCH -mmotm] mm: unify some pmd_*() functions
Date: Mon, 09 Feb 2009 17:06:35 +0000
Message-ID: <16182.1234199195@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <righi.andrea@gmail.com>
Cc: dhowells@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrea Righi <righi.andrea@gmail.com> wrote:

> Unify all the identical implementations of pmd_free(), __pmd_free_tlb(),
> pmd_alloc_one(), pmd_addr_end() in include/asm-generic/pgtable-nopmd.h

NAK for FRV on two fronts:

 (1) The definition of pud_t in pgtable-nopud.h:

	typedef struct { pgd_t pgd; } pud_t;

     is not consistent with the one in FRV's page.h:

	typedef struct { unsigned long	ste[64];} pmd_t;
	typedef struct { pmd_t		pue[1]; } pud_t;
	typedef struct { pud_t		pge[1];	} pgd_t;

     The upper intermediate page table is contained within the page directory
     entry, not the other way around.  Having a pgd_t inside a pud_t is
     upside-down, illogical and makes things harder to follow IMNSHO.

 (2) It produces the following errors:

mm/memory.c: In function 'free_pmd_range':
mm/memory.c:176: error: implicit declaration of function '__pmd_free_tlb'
  CC      fs/seq_file.o
mm/memory.c: In function '__pmd_alloc':
mm/memory.c:2896: error: implicit declaration of function 'pmd_alloc_one_bug'
mm/memory.c:2896: warning: initialization makes pointer from integer without a cast
mm/memory.c:2905: error: implicit declaration of function 'pmd_free'

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
