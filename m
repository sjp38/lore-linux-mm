Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F414E6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 08:41:39 -0500 (EST)
Received: by bwz28 with SMTP id 28so2592230bwz.14
        for <linux-mm@kvack.org>; Tue, 10 Feb 2009 05:41:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <16182.1234199195@redhat.com>
References: <1232919337-21434-1-git-send-email-righi.andrea@gmail.com>
	 <16182.1234199195@redhat.com>
Date: Tue, 10 Feb 2009 14:41:37 +0100
Message-ID: <a2776ec50902100541p1503adaay52d221411d92c842@mail.gmail.com>
Subject: Re: [PATCH -mmotm] mm: unify some pmd_*() functions
From: Andrea Righi <righi.andrea@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 9, 2009 at 6:06 PM, David Howells <dhowells@redhat.com> wrote:
> Andrea Righi <righi.andrea@gmail.com> wrote:
>
>> Unify all the identical implementations of pmd_free(), __pmd_free_tlb(),
>> pmd_alloc_one(), pmd_addr_end() in include/asm-generic/pgtable-nopmd.h
>
> NAK for FRV on two fronts:

This patch generates too many followup fixes and it's better to simply drop it
for now.

I think we need to use a different approach and, more important, we need to
clean a lot of .h files before to avoid the include hell problems.

-Andrea

>
>  (1) The definition of pud_t in pgtable-nopud.h:
>
>        typedef struct { pgd_t pgd; } pud_t;
>
>     is not consistent with the one in FRV's page.h:
>
>        typedef struct { unsigned long  ste[64];} pmd_t;
>        typedef struct { pmd_t          pue[1]; } pud_t;
>        typedef struct { pud_t          pge[1]; } pgd_t;
>
>     The upper intermediate page table is contained within the page directory
>     entry, not the other way around.  Having a pgd_t inside a pud_t is
>     upside-down, illogical and makes things harder to follow IMNSHO.
>
>  (2) It produces the following errors:
>
> mm/memory.c: In function 'free_pmd_range':
> mm/memory.c:176: error: implicit declaration of function '__pmd_free_tlb'
>  CC      fs/seq_file.o
> mm/memory.c: In function '__pmd_alloc':
> mm/memory.c:2896: error: implicit declaration of function 'pmd_alloc_one_bug'
> mm/memory.c:2896: warning: initialization makes pointer from integer without a cast
> mm/memory.c:2905: error: implicit declaration of function 'pmd_free'
>
> David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
