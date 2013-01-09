Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 9C3546B004D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 06:44:18 -0500 (EST)
Date: Wed, 9 Jan 2013 11:44:13 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: oops in copy_page_rep()
Message-ID: <20130109114413.GA13475@suse.de>
References: <20130105152208.GA3386@redhat.com>
 <CAJd=RBCb0oheRnVCM4okVKFvKGzuLp9GpZJCkVY3RR-J=XEoBA@mail.gmail.com>
 <alpine.LNX.2.00.1301061037140.28950@eggly.anvils>
 <CAJd=RBAps4Qk9WLYbQhLkJd8d12NLV0CbjPYC6uqH_-L+Vu0VQ@mail.gmail.com>
 <CA+55aFyYAf6ztDLsxWFD+6jb++y0YNjso-9j+83Mm+3uQ=8PdA@mail.gmail.com>
 <CAJd=RBDTvCcYV8qAd-++_DOyDSypQD4Dvt216pG9nTQnWA2uCA@mail.gmail.com>
 <CA+55aFzfUABPycR82aNQhHNasQkL1kmxLN1rD0DJcByFtead3g@mail.gmail.com>
 <20130108163141.GA27555@shutemov.name>
 <CA+55aFzaTvF7nYxWBT-G_b=xGz+_akRAeJ=U9iHy+Y=ZPo=pbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFzaTvF7nYxWBT-G_b=xGz+_akRAeJ=U9iHy+Y=ZPo=pbA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

On Tue, Jan 08, 2013 at 08:52:14AM -0800, Linus Torvalds wrote:
> On Tue, Jan 8, 2013 at 8:31 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> >>
> >> Heh. I was more thinking about why do_huge_pmd_wp_page() needs it, but
> >> do_huge_pmd_numa_page() does not.
> >
> > It does. The check should be moved up.
> >
> >> Also, do we actually need it for huge_pmd_set_accessed()? The
> >> *placement* of that thing confuses me. And because it confuses me, I'd
> >> like to understand it.
> >
> > We need it for huge_pmd_set_accessed() too.
> >
> > Looks like a mis-merge. The original patch for huge_pmd_set_accessed() was
> > correct: http://lkml.org/lkml/2012/10/25/402
> 
> Not a merge error: the pmd_trans_splitting() check was removed by
> commit d10e63f29488 ("mm: numa: Create basic numa page hinting
> infrastructure").
> 
> Now, *why* it was removed, I can't tell. And it's not clear why the
> original code just had it in a conditional, while the suggested patch
> has that "goto repeat" thing.

It was a mistake by me to remove it and as I screwed up in October I no
longer remember how I managed it.

The retry versus "goto repeat" is a detail. By retrying the full fault
there is a possibility the split will still be in progress on fault
retry or that a new THP is collapsed underneath and a new split started
while the mmap_sem is released but both are unlikely. On the other side,
taking the anon_vma rwsem for write in wait_split_huge_page() could cause
delays elsewhere that would be almost impossible to detect so it is not
necessarily better. Retrying the fault as your patch does is reasonable.

> I suspect re-trying the fault (which I
> assume the original code did) is actually better, because that way you
> go through all the "should I reschedule as I return through the
> exception" stuff. I dunno.
> 
> Mel, that original patch came from you , although it was based on
> previous work by Peter/Ingo/Andrea. Can you walk us through the
> history and thinking about the loss of pmd_trans_splitting(). Was it
> purely a mistake? It looks intentional.
> 

Mistake. Andrea, Peter and Ingo did not make similar mistakes.

Looking at your patch, I also think that the check needs to be made before
the call to do_huge_pmd_numa_page() so it can reply on a pmd_same() check
to make sure a split did not start before the page table lock was taken.

In response you said to Andrea

	Also, and more fundamentally, since do_pmd_numa_page() doesn't
	take the orig_pmd thing as an argument (and re-check it under the
	page-table lock), testing pmd_trans_splitting() on it is pointless,
	since it can change later.

do_pmd_numa_page() is called for a normal PMD that is marked pmd_numa(), not
a THP PMD. As the mmap_sem is held it cannot collapse to a THP underneath us
after the pmd_trans_huge() check so it should be unnecessary to check
pmd_trans_splitting() there.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
