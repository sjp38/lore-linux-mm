Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4C79B5F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 07:41:27 -0400 (EDT)
Date: Wed, 15 Apr 2009 13:41:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
Message-ID: <20090415114154.GI9809@random.random>
References: <20090414143252.GE28265@random.random> <200904150042.15653.nickpiggin@yahoo.com.au> <20090415165431.AC4C.A69D9226@jp.fujitsu.com> <20090415104615.GG9809@random.random> <2f11576a0904150439k6e828307ja97b6729650bcb94@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2f11576a0904150439k6e828307ja97b6729650bcb94@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 15, 2009 at 08:39:04PM +0900, KOSAKI Motohiro wrote:
> >> +     if (!migration) {
> >> +             /* re-check */
> >> +             if (PageSwapCache(page) &&
> >> +                 page_count(page) != page_mapcount(page) + 2) {
> >> +                     /* We lose race against get_user_pages_fast() */
> >> +                     set_pte_at(mm, address, pte, pteval);
> >> +                     ret = SWAP_FAIL;
> >> +                     goto out_unmap;
> >> +             }
> >> +     }
> >> +     mmu_notifier_invalidate_page(vma->vm_mm, address);
> >
> > With regard to mmu notifier, this is the opposite of the right
> > ordering. One mmu_notifier_invalidate_page must run _before_ the first
> > check. The ptep_clear_flush_notify will then stay and there's no need
> > of a further mmu_notifier_invalidate_page after the second check.
> 
> OK. but I have one question.
> 
> Can we assume mmu_notifier is only used by kvm now?
> if not, we need to make new notifier.

KVM is no fundamentally different from other users in this respect, so
I don't see why need a new notifier. If it works for others it'll work
for KVM and the other way around is true too.

mmu notifier users can or cannot take a page pin. KVM does. GRU
doesn't. XPMEM does. All of them releases any pin after
mmu_notifier_invalidate_page. All that is important is to run
mmu_notifier_invalidate_page _after_ the ptep_clear_young_notify, so
that we don't nuke secondary mappings on the pages unless we really go
to nuke the pte.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
