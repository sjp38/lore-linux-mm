Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 701466B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 02:40:48 -0400 (EDT)
Received: by dakh32 with SMTP id h32so2261004dak.9
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 23:40:47 -0700 (PDT)
Date: Wed, 11 Apr 2012 23:40:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: swapoff() runs forever
In-Reply-To: <4F860F17.2090400@nod.at>
Message-ID: <alpine.LSU.2.00.1204112241510.28009@eggly.anvils>
References: <4F81F564.3020904@nod.at> <4F82752A.6020206@openvz.org> <4F82B6ED.2010500@nod.at> <alpine.LSU.2.00.1204091123380.1430@eggly.anvils> <4F860F17.2090400@nod.at>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 12 Apr 2012, Richard Weinberger wrote:
> Am 09.04.2012 20:40, schrieb Hugh Dickins:
> > I've not seen any such issue in recent months (or years), but
> > I've not been using UML either.  The most likely cause that springs
> > to mind would be corruption of the vmalloc'ed swap map: that would
> > be very likely to cause such a hang.
> 
> It does not look like a swap map corruption.
> If I restart most user space processes swapoff() terminates fine.

Right, thanks, that's very useful info.

> Maybe it is a refcounting problem?

You may prove to be correct; but since killing and restarting
processes fixes it up without (I presume) issuing warnings,
it doesn't sound like a refcounting problem to me.

> 
> > You say "recent Linux kernels": I wonder what "recent" means.
> > Is this something you can reproduce quickly and reliably enough
> > to do a bisection upon?
> > 
> 
> I can reproduce the issue on any UML kernel.
> The oldest I've tested was 2.6.20.
> Therefore, bug was not introduced by me. B-)

More useful info, thank you.

I think I've spotted two problems in the UML swp_entry_t handling;
but checking if I'm right, and if they're relevant, and how to fix them,
I'll leave to you - it's years since I tried UML and I remember 0.

One, likely to be your problem.  Take a look at unuse_pte_range() in
mm/swapfile.c, where it searches the page table for the swp_pte it's
trying to "unuse".  And take a look at set_pte() in
arch/um/include/asm/pgtable.h, which appears to add a mysterious
_PAGE_NEWPAGE bit into the page table entry.  And UML doesn't provide
an alternative to generic pte_same() in include/asm-genric/pgtable.h.

My guess is that the _NEWPAGE bit prevents swapoff from matching pte
against swap entry in all or some cases (I didn't look to see if
_NEWPAGE is sometimes cleared later).

Probably a good fix to try would be providing a UML pte_same() which
takes that into account; but I don't know what conditionals it should
contain, and whether it would become too inefficient.  Or, if _NEWPAGE
is always set in a swap pte, then swp_entry_to_pte() needs to set it.

(A word of warning if you're unfamiliar with swap entries: there's the
kernel's internal representation swp_entry_t, which has offset in the
low-order and type in the high-order, for efficient use with radix_tree
- see include/linux/swapops.h; and then there's the arch-dependent
representation as a page table entry, which rearranges the bits so
as not to be confused with a good present page table entry, and
traditionally has type on the lower side of offset.)

The other thing I noticed first, probably not relevant to the bug you're
seeing since I think you'd have mentioned if you had two swapfiles; but
the two or more swapfile case looks very broken to me.  _PAGE_PROTNONE is
0x010 but __swp_type(x) is (((x).val >> 4) & 0x3f): unless I'm confused,
a swap entry of type 1 will look just like a PROT_NONE pte.

Or maybe that's resolved by the _PAGE_NEWPAGE and _PAGE_NEWPROT bits,
I didn't spend time working out what they're up to.

include/linux/swap.h does not allow MAX_SWAPFILES to exceed 32,
so you can easily change __swp_type(x) to use 5 and 0x1f instead
(with 5 instead of 4 in __swp_entry too of course).  Though it doesn't
cause error, I wonder where the 11 in __swp_offset and __swp_entry
comes from: I think you can support larger swap by making it 10.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
