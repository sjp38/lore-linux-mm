Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 640F66B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 12:32:36 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x23so375995878pgx.6
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 09:32:36 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c25si51878976pfh.28.2016.11.28.09.32.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 09:32:35 -0800 (PST)
Subject: Re: [PATCH 2/2] mremap: use mmu gather logic for tlb flush in mremap
References: <026b73f6-ca1d-e7bb-766c-4aaeb7071ce6@intel.com>
 <CA+55aFzHfpZckv8ck19fZSFK+3TmR5eF=BsDzhwVGKrbyEBjEw@mail.gmail.com>
 <c160bc18-7c1b-2d54-8af1-7c5bfcbcefe8@intel.com>
 <20161128083715.GA21738@aaronlu.sh.intel.com>
 <20161128084012.GC21738@aaronlu.sh.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <31b1393c-22d2-8a49-842c-9678a1921441@intel.com>
Date: Mon, 28 Nov 2016 09:32:35 -0800
MIME-Version: 1.0
In-Reply-To: <20161128084012.GC21738@aaronlu.sh.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org

On 11/28/2016 12:40 AM, Aaron Lu wrote:
> As suggested by Linus, the same mmu gather logic could be used for tlb
> flush in mremap and this patch just did that.
> 
> Note that since there is no page added to "struct mmu_gather" for free
> during mremap, when tlb needs to be flushed, we can use tlb_flush_mmu or
> tlb_flush_mmu_tlbonly. Using tlb_flush_mmu could also avoid exporting
> tlb_flush_mmu_tlbonly. But tlb_flush_mmu_tlbonly *looks* more clear and
> straightforward so I end up using it.

OK, so the code before this patch was passing around a pointer to
'need_flush', and we basically just pass around an mmu_gather instead.
It doesn't really simplify the code _too_ much, although it does make it
less confusing than when we saw 'need_flush' mixed with 'force_flush' in
the code.

tlb_flush_mmu_tlbonly() has exactly one other use: zap_pte_range() for
flushing the TLB before pte_unmap_unlock():

        if (force_flush)
                tlb_flush_mmu_tlbonly(tlb);
        pte_unmap_unlock(start_pte, ptl);

But, both call-sites are still keeping 'force_flush' to store the
information about whether we ever saw a dirty pte.  If we moved _that_
logic into the x86 mmu_gather code, we could get rid of all the
'force_flush' tracking in both call sites.  It also makes us a bit more
future-proof against these page_mkclean() races if we ever grow a third
site for clearing ptes.

Instead of exporting and calling tlb_flush_mmu_tlbonly(), we'd need
something like tlb_flush_mmu_before_ptl_release() (but with a better
name, of course :).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
