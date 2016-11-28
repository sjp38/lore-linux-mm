Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1105B6B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 12:15:38 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id v84so265379334oie.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:15:38 -0800 (PST)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id c23si26873909otc.195.2016.11.28.09.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 09:15:37 -0800 (PST)
Received: by mail-oi0-x241.google.com with SMTP id m75so14587634oig.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:15:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161128084012.GC21738@aaronlu.sh.intel.com>
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
 <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
 <c160bc18-7c1b-2d54-8af1-7c5bfcbcefe8@intel.com> <20161128083715.GA21738@aaronlu.sh.intel.com>
 <20161128084012.GC21738@aaronlu.sh.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 28 Nov 2016 09:15:36 -0800
Message-ID: <CA+55aFwm8MgLi3pDMOQr2gvmjRKXeSjsmV2kLYSYZHFiUa_0fQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mremap: use mmu gather logic for tlb flush in mremap
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Nov 28, 2016 at 12:40 AM, Aaron Lu <aaron.lu@intel.com> wrote:
> As suggested by Linus, the same mmu gather logic could be used for tlb
> flush in mremap and this patch just did that.

Ok, looking at this patch, I still think it looks like the right thing
to do, but I'm admittedly rather less certain of it.

The main advantage of the mmu_gather thing is that it automatically
takes care of the TLB flush ranges for us, and that's a big deal
during munmap() (where the actual unmapped page range can be _very_
different from the total range), but now that I notice that this
doesn't actually remove any other code (in fact, it adds a line), I'm
wondering if it's worth it. mremap() is already "dense" in the vma
space, unlike munmap (ie you can't move multiple vma's with a single
mremap), so the fancy range optimizations that make a difference on
some architectures aren't much of an issue.

So I guess the MM people should take a look at this and say whether
they think the current state is fine or whether we should do the
mmu_gather thing. People?

However, I also independently think I found an actual bug while
looking at the code as part of looking at the patch.

This part looks racy:

                /*
                 * We are remapping a dirty PTE, make sure to
                 * flush TLB before we drop the PTL for the
                 * old PTE or we may race with page_mkclean().
                 */
                if (pte_present(*old_pte) && pte_dirty(*old_pte))
                        force_flush = true;
                pte = ptep_get_and_clear(mm, old_addr, old_pte);

where the issue is that another thread might make the pte be dirty (in
the hardware walker, so no locking of ours make any difference)
*after* we checked whether it was dirty, but *before* we removed it
from the page tables.

So I think the "check for force-flush" needs to come *after*, and we should do

                pte = ptep_get_and_clear(mm, old_addr, old_pte);
                if (pte_present(pte) && pte_dirty(pte))
                        force_flush = true;

instead.

This happens for the pmd case too.

So now I'm not sure the mmu_gather thing is worth it, but I'm pretty
sure that there remains a (very very) small race that wasn't fixed by
the original fix in commit 5d1904204c99 ("mremap: fix race between
mremap() and page cleanning").

Aaron, sorry for waffling about this, and asking you to look at a
completely different issue instead.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
