Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id AF67B6B003D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:09:05 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so3986481pbc.37
        for <linux-mm@kvack.org>; Mon, 26 Aug 2013 15:09:05 -0700 (PDT)
Date: Mon, 26 Aug 2013 15:08:45 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: unused swap offset / bad page map.
In-Reply-To: <CA+55aFwQbJbR3xij1+iGbvj3EQggF9NLGAfDbmA54FkKz9xfew@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1308261448490.4982@eggly.anvils>
References: <20130807153030.GA25515@redhat.com> <CAJd=RBCyZU8PR7mbFUdKsWq3OH+5HccEWKMEH5u7GNHNy3esWg@mail.gmail.com> <20130819231836.GD14369@redhat.com> <CAJd=RBA-UZmSTxNX63Vni+UPZBHwP4tvzE_qp1ZaHBqcNG7Fcw@mail.gmail.com> <20130821204901.GA19802@redhat.com>
 <CAJd=RBBNCf5_V-nHjK0gOqS4OLMszgB7Rg_WMf4DvL-De+ZdHA@mail.gmail.com> <20130823032127.GA5098@redhat.com> <CAJd=RBArkh3sKVoOJUZBLngXtJubjx4-a3G6s7Tn0N=Pr1gU4g@mail.gmail.com> <20130823035344.GB5098@redhat.com> <CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
 <20130826190757.GB27768@redhat.com> <CA+55aFw_bhMOP73owFHRFHZDAYEdWgF9j-502Aq9tZe3tEfmwg@mail.gmail.com> <CA+55aFwQbJbR3xij1+iGbvj3EQggF9NLGAfDbmA54FkKz9xfew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon, 26 Aug 2013, Linus Torvalds wrote:
> On Mon, Aug 26, 2013 at 1:15 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > So I'm almost likely to think that we are more likely to have
> > something wrong in the messy magical special cases.
> 
> Of course, the good news would be if it actually ends up being the
> soft-dirty stuff, and bisection hits something recent.

I suspect so.

> 
> So maybe I'm overly pessimistic. That messy swap_map[] code really
> _is_ messy, but at the same time it should also be pretty well-tested.
> I don't think it's been touched in years.

Blame me for the byte-instead-of-short continuation stuff.
But it's never yet shown any problem (okay, perhaps that's
because it's so rare to need any continuation anyway).

> 
> That said, google does find "swap_free: Unused swap offset entry"
> reports from over the years. Most of them seem to be single-bit
> errors, though (ie when the entry is 00000100 or similar I'm more
> inclined to blame a bit error

Yes, historically they have usually represented either single-bit
errors, or corruption of page tables by other kernel data.  The
swap subsystem discovers it, but it's rarely an error of swap.

So I don't care for Dave's suggestion much earlier in this thread,
that swapoff should fail with -EINVAL if there has been a bad page
taint: that doesn't necessarily interfere with swapoff at all.

And besides, swapoff is killable: yes, if counts go wrong, it
can cycle around endlessly, but it checks for signal_pending()
each time around the loop.

> - in contrast your values look like "real" swap entries).

Indeed they do.

I just did a quick diff of 3.11-rc7/mm against 3.10, and here's
a line in mremap which worries me.  That set_pte_at() is operating
on anything that isn't pte_none(), so the pte_mksoft_dirty() looks
prone to corrupt a swap entry.

I've not tried matching up bits with Dave's reports, and just going
into a meeting now, but this patch looks worth a try: probably Cyrill
can improve it meanwhile to what he actually wants there (I'm
surprised anything special is needed for just moving a pte).

Hugh

--- 3.11-rc7/mm/mremap.c	2013-07-14 17:10:16.640003652 -0700
+++ linux/mm/mremap.c	2013-08-26 14:46:14.460027627 -0700
@@ -126,7 +126,7 @@ static void move_ptes(struct vm_area_str
 			continue;
 		pte = ptep_get_and_clear(mm, old_addr, old_pte);
 		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
-		set_pte_at(mm, new_addr, new_pte, pte_mksoft_dirty(pte));
+		set_pte_at(mm, new_addr, new_pte, pte);
 	}
 
 	arch_leave_lazy_mmu_mode();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
