Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 04B256B0089
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 07:58:08 -0400 (EDT)
Date: Tue, 4 Jun 2013 06:58:07 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: Handling NUMA page migration
Message-ID: <20130604115807.GF3672@sgi.com>
References: <201306040922.10235.frank.mehnert@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201306040922.10235.frank.mehnert@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Mehnert <frank.mehnert@oracle.com>, linux-mm@kvack.org
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

This is probably more appropriate to be directed at the linux-mm
mailing list.

On Tue, Jun 04, 2013 at 09:22:10AM +0200, Frank Mehnert wrote:
> Hi,
> 
> our memory management on Linux hosts conflicts with NUMA page migration.
> I assume this problem existed for a longer time but Linux 3.8 introduced
> automatic NUMA page balancing which makes the problem visible on
> multi-node hosts leading to kernel oopses.
> 
> NUMA page migration means that the physical address of a page changes.
> This is fatal if the application assumes that this never happens for
> that page as it was supposed to be pinned.
> 
> We have two kind of pinned memory:
> 
> A) 1. allocate memory in userland with mmap()
>    2. madvise(MADV_DONTFORK)
>    3. pin with get_user_pages().
>    4. flush dcache_page()
>    5. vm_flags |= (VM_DONTCOPY | VM_LOCKED)
>       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND |
>        VM_DONTCOPY | VM_LOCKED | 0xff)

I don't think this type of allocation should be affected.  The
get_user_pages() call should elevate the pages reference count which
should prevent migration from completing.  I would, however, wait for
a more definitive answer.

> B) 1. allocate memory with alloc_pages()
>    2. SetPageReserved()
>    3. vm_mmap() to allocate a userspace mapping
>    4. vm_insert_page()
>    5. vm_flags |= (VM_DONTEXPAND | VM_DONTDUMP)
>       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND | 0xff)
> 
> At least the memory allocated like B) is affected by automatic NUMA page
> migration. I'm not sure about A).
> 
> 1. How can I prevent automatic NUMA page migration on this memory?
> 2. Can NUMA page migration also be handled on such kind of memory without
>    preventing migration?
> 
> Thanks,
> 
> Frank
> -- 
> Dr.-Ing. Frank Mehnert | Software Development Director, VirtualBox
> ORACLE Deutschland B.V. & Co. KG | Werkstr. 24 | 71384 Weinstadt, Germany
> 
> Hauptverwaltung: Riesstr. 25, D-80992 Munchen
> Registergericht: Amtsgericht Munchen, HRA 95603
> Geschaftsfuhrer: Jurgen Kunz
> 
> Komplementarin: ORACLE Deutschland Verwaltung B.V.
> Hertogswetering 163/167, 3543 AS Utrecht, Niederlande
> Handelsregister der Handelskammer Midden-Niederlande, Nr. 30143697
> Geschaftsfuhrer: Alexander van der Ven, Astrid Kepper, Val Maher
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
