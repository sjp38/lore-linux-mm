Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3646B0375
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 14:00:48 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id o203so1165025lff.4
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 11:00:48 -0800 (PST)
Received: from twin.jikos.cz (twin.jikos.cz. [91.219.245.39])
        by mx.google.com with ESMTPS id n204si2078052lfn.401.2018.01.05.11.00.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 11:00:47 -0800 (PST)
Date: Fri, 5 Jan 2018 20:00:25 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
In-Reply-To: <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm>
Message-ID: <alpine.LRH.2.00.1801051958130.27010@gjva.wvxbf.pm>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com> <20171123003447.1DB395E3@viggo.jf.intel.com> <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com> <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com> <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
 <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com> <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, Hugh Dickins <hughd@google.com>, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>Hugh Dickins <hughd@google.com>


The previous patch was for slightly older kernel, and the logic in 
_prologue() is a bit different in 4.15, but the (cofirmed) fix for 
mainline is basically the same:


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

diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index d87ac96e37ed..2dd15e967c3f 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -135,7 +135,9 @@ pgd_t * __init efi_call_phys_prolog(void)
 				pud[j] = *pud_offset(p4d_k, vaddr);
 			}
 		}
+		pgd_offset_k(pgd * PGDIR_SIZE)->pgd &= ~_PAGE_NX;
 	}
+
 out:
 	__flush_tlb_all();
 

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
