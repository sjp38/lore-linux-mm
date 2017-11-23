Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7764F6B0253
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 13:23:46 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k100so12480224wrc.9
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 10:23:46 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b13si5938749wmi.32.2017.11.23.10.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 10:23:45 -0800 (PST)
Date: Thu, 23 Nov 2017 19:23:31 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 1/4] mm: fix device-dax pud write-faults triggered by
 get_user_pages()
In-Reply-To: <151043109938.2842.14834662818213616199.stgit@dwillia2-desk3.amr.corp.intel.com>
Message-ID: <alpine.DEB.2.20.1711231922500.2364@nanos>
References: <151043109403.2842.11607911965674122836.stgit@dwillia2-desk3.amr.corp.intel.com> <151043109938.2842.14834662818213616199.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-nvdimm@lists.01.org



On Sat, 11 Nov 2017, Dan Williams wrote:

> Currently only get_user_pages_fast() can safely handle the writable gup
> case due to its use of pud_access_permitted() to check whether the pud
> entry is writable. In the gup slow path pud_write() is used instead of
> pud_access_permitted() and to date it has been unimplemented, just calls
> BUG_ON().
> 
>     kernel BUG at ./include/linux/hugetlb.h:244!
>     [..]
>     RIP: 0010:follow_devmap_pud+0x482/0x490
>     [..]
>     Call Trace:
>      follow_page_mask+0x28c/0x6e0
>      __get_user_pages+0xe4/0x6c0
>      get_user_pages_unlocked+0x130/0x1b0
>      get_user_pages_fast+0x89/0xb0
>      iov_iter_get_pages_alloc+0x114/0x4a0
>      nfs_direct_read_schedule_iovec+0xd2/0x350
>      ? nfs_start_io_direct+0x63/0x70
>      nfs_file_direct_read+0x1e0/0x250
>      nfs_file_read+0x90/0xc0
> 
> For now this just implements a simple check for the _PAGE_RW bit similar
> to pmd_write. However, this implies that the gup-slow-path check is
> missing the extra checks that the gup-fast-path performs with
> pud_access_permitted. Later patches will align all checks to use the
> 'access_permitted' helper if the architecture provides it. Note that the
> generic 'access_permitted' helper fallback is the simple _PAGE_RW check
> on architectures that do not define the 'access_permitted' helper(s).
> 
> Fixes: a00cc7d9dd93 ("mm, x86: add support for PUD-sized transparent hugepages")
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: <stable@vger.kernel.org>
> Cc: <x86@kernel.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/arm64/include/asm/pgtable.h    |    1 +
>  arch/sparc/include/asm/pgtable_64.h |    1 +
>  arch/x86/include/asm/pgtable.h      |    6 ++++++

For the x86 part:

Acked-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
