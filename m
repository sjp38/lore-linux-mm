Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id ECAB86B0038
	for <linux-mm@kvack.org>; Sat,  7 Mar 2015 13:33:44 -0500 (EST)
Received: by igal13 with SMTP id l13so11564642iga.5
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 10:33:44 -0800 (PST)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id bg7si8342921icc.72.2015.03.07.10.33.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Mar 2015 10:33:44 -0800 (PST)
Received: by iecrl12 with SMTP id rl12so10874765iec.5
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 10:33:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1425741651-29152-4-git-send-email-mgorman@suse.de>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
	<1425741651-29152-4-git-send-email-mgorman@suse.de>
Date: Sat, 7 Mar 2015 10:33:43 -0800
Message-ID: <CA+55aFwSQgrYqfXPr6RPvQ+8OJfexXJRY_GVEKg5QtB2t38cWA@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm: numa: Mark huge PTEs young when clearing NUMA
 hinting faults
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Sat, Mar 7, 2015 at 7:20 AM, Mel Gorman <mgorman@suse.de> wrote:
>         pmd = pmd_modify(pmd, vma->vm_page_prot);
> +       pmd = pmd_mkyoung(pmd);

Hmm. I *thought* this should be unnecessary. vm_page_prot alreadty has
the accessed bit set, and we kind of depend on the initial page table
setup and mk_pte() and friends (ie all new pages are installed
"young").

But it looks like I am wrong - the way we use _[H]PAGE_CHG_MASK means
that we always take the accessed and dirty bits from the old entry,
ignoring the bit in vm_page_prot.

I wonder if we should just make pte/pmd_modify() work the way I
*thought* they worked (remove the masking of vm_page_prot bits).

So the patch isn't wrong. It's just that we *migth* instead just do
something like this:

    arch/x86/include/asm/pgtable.h | 4 ++--
    1 file changed, 2 insertions(+), 2 deletions(-)

   diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
   index a0c35bf6cb92..79b898bb9e18 100644
   --- a/arch/x86/include/asm/pgtable.h
   +++ b/arch/x86/include/asm/pgtable.h
   @@ -355,7 +355,7 @@ static inline pte_t pte_modify(pte_t pte,
pgprot_t newprot)
            * the newprot (if present):
            */
           val &= _PAGE_CHG_MASK;
   -       val |= massage_pgprot(newprot) & ~_PAGE_CHG_MASK;
   +       val |= massage_pgprot(newprot);

           return __pte(val);
    }
   @@ -365,7 +365,7 @@ static inline pmd_t pmd_modify(pmd_t pmd,
pgprot_t newprot)
           pmdval_t val = pmd_val(pmd);

           val &= _HPAGE_CHG_MASK;
   -       val |= massage_pgprot(newprot) & ~_HPAGE_CHG_MASK;
   +       val |= massage_pgprot(newprot);

           return __pmd(val);
    }

instead, and remove the mkyoung. Completely untested, but that "just
or in the new protection bits" is what pnf_pte() does just a few lines
above this.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
