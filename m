Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 175E128027A
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 13:20:25 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id y8so1150057lfj.1
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 10:20:25 -0800 (PST)
Received: from twin.jikos.cz (twin.jikos.cz. [91.219.245.39])
        by mx.google.com with ESMTPS id j137si2043649lfg.419.2018.01.05.10.20.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 10:20:23 -0800 (PST)
Date: Fri, 5 Jan 2018 19:19:51 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
In-Reply-To: <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
Message-ID: <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com> <20171123003447.1DB395E3@viggo.jf.intel.com> <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com> <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com> <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
 <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>Hugh Dickins <hughd@google.com>


[ adding Hugh ]

On Thu, 4 Jan 2018, Dave Hansen wrote:

> > BTW, we have just reported a bug caused by kaiser[1], which looks like
> > caused by SMEP. Could you please help to have a look?
> > 
> > [1] https://lkml.org/lkml/2018/1/5/3
> 
> Please report that to your kernel vendor.  Your EFI page tables have the
> NX bit set on the low addresses.  There have been a bunch of iterations
> of this, but you need to make sure that the EFI kernel mappings don't
> get _PAGE_NX set on them.  Look at what __pti_set_user_pgd() does in
> mainline.

Unfortunately this is more complicated.

The thing is -- efi=old_memmap is broken even upstream. We will probably 
not receive too many reports about this against upstream PTI, as most of 
the machines are using classic high-mapping of EFI regions; but older 
kernels force on certain machines stil old_memmap (or it can be specified 
manually on kernel cmdline), where EFI has all its mapping in the 
userspace range.

And that explodes, as those get marked NX in the kernel pagetables.

I've spent most of today tracking this down (the legacy EFI mmap is 
horrid); the patch below is confirmed to fix it both on current upstream 
kernel, as well as on original-KAISER based kernels (Hugh's backport) in 
cases old_memmap is used by EFI.

I am not super happy about this, but I din't really want to extend the 
_set_pgd() code to always figure out whether it's dealing wih low EFI 
mapping or not, as that would be way too much overhead just for this 
one-off call during boot.



From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] PTI: unbreak EFI old_memmap

old_memmap's efi_call_phys_prolog() calls set_pgd() with swapper PGD that 
has PAGE_USER set, which makes PTI set NX on it, and therefore EFI can't 
execute it's code.

Fix that by forcefully clearing _PAGE_NX from the PGD (this can't be done
by the pgprot API).

_PAGE_NX will be automatically reintroduced in efi_call_phys_epilog(), as 
_set_pgd() will again notice that this is _PAGE_USER, and set _PAGE_NX on 
it.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 arch/x86/platform/efi/efi_64.c |    6 ++++++
 1 file changed, 6 insertions(+)

--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -95,6 +95,12 @@ pgd_t * __init efi_call_phys_prolog(void
 		save_pgd[pgd] = *pgd_offset_k(pgd * PGDIR_SIZE);
 		vaddress = (unsigned long)__va(pgd * PGDIR_SIZE);
 		set_pgd(pgd_offset_k(pgd * PGDIR_SIZE), *pgd_offset_k(vaddress));
+		/*
+		 * pgprot API doesn't clear it for PGD
+		 *
+		 * Will be brought back automatically in _epilog()
+		 */
+		pgd_offset_k(pgd * PGDIR_SIZE)->pgd &= ~_PAGE_NX;
 	}
 	__flush_tlb_all();
 

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
