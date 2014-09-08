Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 27B156B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 03:16:10 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id kx10so2450121pab.31
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 00:16:09 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id oo1si16024150pdb.228.2014.09.08.00.16.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 00:16:09 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so1844888pab.12
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 00:16:08 -0700 (PDT)
Date: Mon, 8 Sep 2014 00:13:16 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 2/6] mm/hugetlb: take page table lock in
 follow_huge_(addr|pmd|pud)()
In-Reply-To: <20140905052751.GA6883@nhori.redhat.com>
Message-ID: <alpine.LSU.2.11.1409072307430.1298@eggly.anvils>
References: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1409276340-7054-3-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.LSU.2.11.1409031243420.9023@eggly.anvils> <20140905052751.GA6883@nhori.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 5 Sep 2014, Naoya Horiguchi wrote:
> On Wed, Sep 03, 2014 at 02:17:41PM -0700, Hugh Dickins wrote:
> > On Thu, 28 Aug 2014, Naoya Horiguchi wrote:
> > > 
> > > Reported-by: Hugh Dickins <hughd@google.com>
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Cc: <stable@vger.kernel.org>  # [3.12+]
> > 
> > No ack to this one yet, I'm afraid.
> 
> OK, I defer Reported-by until all the problems in this patch are solved.
> I added this Reported-by because Andrew asked how In found this problem,
> and advised me to show the reporter.
> And I didn't intend by this Reported-by that you acked the patch.
> In this case, should I have used some unofficial tag like
> "Not-yet-Reported-by:" to avoid being rude?

Sorry, misunderstanding, I chose that position to write "No ack to this
one yet" because that is where I would insert my "Acked-by" to the patch
when ready.  I just meant that I cannot yet give you my "Acked-by".

You were not being rude to me at all, quite the reverse.

I have no objection to your writing "Reported-by: Hugh...": you are
being polite to acknowledge me, and I was not objecting to that.

Although usually, we save "Reported-by"s for users who have
reported a problem they saw in practice, rather than for fellow
developers who have looked at the code and seen a potential bug -
so I won't mind at all if you end up taking it out.

> 
> > One subtlety to take care over: it's a long time since I've had to
> > worry about pmd folding and pud folding (what happens when you only
> > have 2 or 3 levels of page table instead of the full 4): macros get
> > defined to each other, and levels get optimized out (perhaps
> > differently on different architectures).
> > 
> > So although at first sight the lock to take in follow_huge_pud()
> > would seem to be mm->page_table_lock, I am not at this point certain
> > that that's necessarily so - sometimes pud_huge might be pmd_huge,
> > and the size PMD_SIZE, and pmd_lockptr appropriate at what appears
> > to be the pud level.  Maybe: needs checking through the architectures
> > and their configs, not obvious to me.
> 
> I think that every architecture uses mm->page_table_lock for pud-level
> locking at least for now, but that could be changed in the future,
> for example when 1GB hugepages or pud-based hugepages become common and
> someone are interested in splitting lock for pud level.

I'm not convinced by your answer, that you understand the (perhaps
imaginary!) issue I'm referring to.  Try grep for __PAGETABLE_P.D_FOLDED.

Our infrastructure allows for 4 levels of pagetable, pgd pud pmd pte,
but many architectures/configurations support only 2 or 3 levels.
What pud functions and pmd functions work out to be in those
configs is confusing, and varies from architecture to architecture.

In particular, pud and pmd may be different expressions of the same
thing (with 1 pmd per pud, instead of say 512).  In that case PUD_SIZE
will equal PMD_SIZE: and then at the pud level huge_pte_lockptr()
will be using split locking instead of mm->page_table_lock.

Many of the hugetlb architectures have a pud_huge() which just returns
0, and we need not worry about those, nor the follow_huge_addr() powerpc.
But arm64, mips, tile, x86 look more interesting.

Frankly, I find myself too dumb to be sure of the right answer for all:
and think that when we put the proper locking into follow_huge_pud(),
we shall have to include a PUD_SIZE == PMD_SIZE test, to let the
compiler decide for us which is the appropriate locking to match
huge_pte_lockptr().

Unless Kirill can illuminate: I may be afraid of complications
where actually there are none.

> So it would be helpful to introduce pud_lockptr() which just returns
> mm->page_table_lock now, so that developers never forget to update it
> when considering splitting pud lock.
> 
> > 
> > I realize that I am asking for you (or I) to do more work, when using
> > huge_pte_lock(hstate_vma(vma),,) would work it out "automatically";
> > but I do feel quite strongly that that's the right approach here
> > (and I'm not just trying to avoid a few edits of "mm" to "vma").
> 
> Yes, I agree.
> 
> > Cc'ing Kirill, who may have a strong view to the contrary,
> > or a good insight on where the problems if any might be.
> > 
> > Also Cc'ing Kirill because I'm not convinced that huge_pte_lockptr()
> > necessarily does the right thing on follow_huge_addr() architectures,
> > ia64 and powerpc.  Do they, for example, allocate the memory for their
> > hugetlb entries in such a way that we can indeed use pmd_lockptr() to
> > point to a useable spinlock, in the case when huge_page_size(h) just
> > happens to equal PMD_SIZE?
> > 
> > I don't know if this was thought through thoroughly
> > (now that's a satisfying phrase hugh thinks hugh never wrote before!)
> > when huge_pte_lockptr() was invented or not.  I think it would be safer
> > if huge_pte_lockptr() just gave mm->page_table_lock on follow_huge_addr()
> > architectures.
> 
> Yes, this seems a real problem and is worth discussing with maintainers
> of these architectures. Maybe we can do this as a separate work.

Perhaps, but I'm hoping Kirill can say, whether it's something he
considered and felt safe with, or something he overlooked at the
time and would prefer to change now.

I suspect that either the follow_huge_addr() architectures should be
constrained to use mm->page_table_lock; or, when we do introduce the
proper locking into find_huge_addr() (you appear to be backing away
from making any change there for now: yes, it's not needed urgently),
that one will have to take vma instead of mm, so that it can be sure
to match huge_pte_lockptr().

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
