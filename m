Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD4A6B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 12:51:15 -0400 (EDT)
Received: by mail-yk0-f177.google.com with SMTP id q200so1049079ykb.8
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 09:51:14 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id k25si3226164yhl.54.2014.04.08.09.51.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 09:51:12 -0700 (PDT)
Message-ID: <534428F2.2040205@citrix.com>
Date: Tue, 8 Apr 2014 17:50:58 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
References: <5342C517.2020305@citrix.com> <20140407154935.GD7292@suse.de> <20140407161910.GJ1444@moon> <20140407182854.GH7292@suse.de> <5342FC0E.9080701@zytor.com> <20140407193646.GC23983@moon> <5342FFB0.6010501@zytor.com> <20140407212535.GJ7292@suse.de> <CAKbGBLhsWKVYnBqR0ZJ2kfaF_h=XAYkjq=v3RLoRBDkF_w=6ag@mail.gmail.com> <e9801da2-3aa4-4c23-9a64-90c890b9ebbc@email.android.com> <20140408160250.GE31554@phenom.dumpdata.com> <534420F1.3030301@zytor.com>
In-Reply-To: <534420F1.3030301@zytor.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Steven Noonan <steven@uplinklabs.net>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On 08/04/14 17:16, H. Peter Anvin wrote:
> On 04/08/2014 09:02 AM, Konrad Rzeszutek Wilk wrote:
>>>>
>>>> Amazon EC2 does have large memory instance types with NUMA exposed to
>>>> the guest (e.g. c3.8xlarge, i2.8xlarge, etc), so it'd be preferable
>>>> (to me anyway) if we didn't require !XEN.
>>
>> What about the patch that David Vrabel posted:
>>
>> http://osdir.com/ml/general/2014-03/msg41979.html
>>
>> Has anybody taken it for a spin?
>>
> 
> Oh lovely, more pvops in low level paths.  I'm so thrilled.
> 
> Incidentally, I wasn't even Cc:'d on that patch and was only added to
> the thread by Linus, but never saw the early bits of the thread
> including the actual patch.

I did resend a version CC'd to all the x86 maintainers and included some
performance figures for native (~1 extra clock cycle).

I've included it again below.

My preference would be take this patch as it fixes it for both NUMA
rebalancing and any future uses that want to set/clear _PAGE_PRESENT.

David

8<--------------
x86: use pv-ops in {pte, pmd}_{set,clear}_flags()

Instead of using native functions to operate on the PTEs in
pte_set_flags(), pte_clear_flags(), pmd_set_flags(), pmd_clear_flags()
use the PV aware ones.

This fixes a regression in Xen PV guests introduced by 1667918b6483
(mm: numa: clear numa hinting information on mprotect).

This has negligible performance impact on native since the pte_val()
and __pte() (etc.) calls are patched at runtime when running on bare
metal.  Measurements on a 3 GHz AMD 4284 give approx. 0.3 ns (~1 clock
cycle) of additional time for each function.

Xen PV guest page tables require that their entries use machine
addresses if the preset bit (_PAGE_PRESENT) is set, and (for
successful migration) non-present PTEs must use pseudo-physical
addresses.  This is because on migration MFNs only present PTEs are
translated to PFNs (canonicalised) so they may be translated back to
the new MFN in the destination domain (uncanonicalised).

pte_mknonnuma(), pmd_mknonnuma(), pte_mknuma() and pmd_mknuma() set
and clear the _PAGE_PRESENT bit using pte_set_flags(),
pte_clear_flags(), etc.

In a Xen PV guest, these functions must translate MFNs to PFNs when
clearing _PAGE_PRESENT and translate PFNs to MFNs when setting
_PAGE_PRESENT.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Cc: Steven Noonan <steven@uplinklabs.net>
Cc: Elena Ufimtseva <ufimtseva@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: <stable@vger.kernel.org>        [3.12+]
---
 arch/x86/include/asm/pgtable.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index bbc8b12..323e5e2 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -174,16 +174,16 @@ static inline int has_transparent_hugepage(void)

 static inline pte_t pte_set_flags(pte_t pte, pteval_t set)
 {
-	pteval_t v = native_pte_val(pte);
+	pteval_t v = pte_val(pte);

-	return native_make_pte(v | set);
+	return __pte(v | set);
 }

 static inline pte_t pte_clear_flags(pte_t pte, pteval_t clear)
 {
-	pteval_t v = native_pte_val(pte);
+	pteval_t v = pte_val(pte);

-	return native_make_pte(v & ~clear);
+	return __pte(v & ~clear);
 }

 static inline pte_t pte_mkclean(pte_t pte)
@@ -248,14 +248,14 @@ static inline pte_t pte_mkspecial(pte_t pte)

 static inline pmd_t pmd_set_flags(pmd_t pmd, pmdval_t set)
 {
-	pmdval_t v = native_pmd_val(pmd);
+	pmdval_t v = pmd_val(pmd);

 	return __pmd(v | set);
 }

 static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
 {
-	pmdval_t v = native_pmd_val(pmd);
+	pmdval_t v = pmd_val(pmd);

 	return __pmd(v & ~clear);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
