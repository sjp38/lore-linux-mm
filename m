Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 69E596B005A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 07:40:17 -0400 (EDT)
Date: Mon, 23 Jul 2012 12:40:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
Message-ID: <20120723114007.GU9222@suse.de>
References: <20120720134937.GG9222@suse.de>
 <20120720141108.GH9222@suse.de>
 <20120720143635.GE12434@tiehlicka.suse.cz>
 <20120720145121.GJ9222@suse.de>
 <alpine.LSU.2.00.1207222033030.6810@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207222033030.6810@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Sun, Jul 22, 2012 at 09:04:33PM -0700, Hugh Dickins wrote:
> On Fri, 20 Jul 2012, Mel Gorman wrote:
> > On Fri, Jul 20, 2012 at 04:36:35PM +0200, Michal Hocko wrote:
> > > And here is my attempt for the fix (Hugh mentioned something similar
> > > earlier but he suggested using special flags in ptes or VMAs). I still
> > > owe doc. update and it hasn't been tested with too many configs and I
> > > could missed some definition updates.
> > > I also think that changelog could be much better, I will add (steal) the
> > > full bug description if people think that this way is worth going rather
> > > than the one suggested by Mel.
> > > To be honest I am not quite happy how I had to pollute generic mm code with
> > > something that is specific to a single architecture.
> > > Mel hammered it with the test case and it survived.
> > 
> > Tested-by: Mel Gorman <mgorman@suse.de>
> > 
> > This approach looks more or less like what I was expecting. I like that
> > the trick was applied to the page table page instead of using PTE tricks
> > or by bodging it with a VMA flag like I was thinking so kudos for that. I
> > also prefer this approach to trying to free the page tables on or near
> > huge_pmd_unshare()
> > 
> > In general I think this patch would execute better than mine because it is
> > far less heavy-handed but I share your concern that it changes the core MM
> > quite a bit for a corner case that only one architecture cares about. I am
> > completely biased of course, but I still prefer my patch because other than
> > an API change it keeps the bulk of the madness in arch/x86/mm/hugetlbpage.c
> > . I am also not concerned with the scalability of how quickly we can setup
> > page table sharing.
> > 
> > Hugh, I'm afraid you get to choose :)
> 
> Thank you bestowing that honour upon me :) 

Just so you know, there was a ceremonial gong when it happened.

> Seriously, though, you
> were quite right to Cc me on this, it is one of those areas I ought
> to know something about (unlike hugetlb reservations, for example).
> 
> Please don't be upset if I say that I don't like either of your patches.

I can live with that :) It would not be the first time we found the right
patch out of dislike for the first proposed and getting the fix is what's
important.

> Mainly for obvious reasons - I don't like Mel's because anything with
> trylock retries and nested spinlocks worries me before I can even start
> to think about it;

That's a reasonable objection. The trylock could be avoided by always
falling through at the cost of reducing the amount of sharing
opportunities but the nested locking is unavoidable. I agree with you
that nested locking like this should always be a cause for concern.

> and I don't like Michal's for the same reason as Mel,
> that it spreads more change around in common paths than we would like.
> 
> But I didn't spend much time thinking through either of them, they just
> seemed more complicated than should be needed.  I cannot confirm or deny
> whether they're correct - though I still do not understand how mmap_sem
> can help you, Mel.  I can see that it will help in your shmdt()ing test,
> but if you leave the area mapped on exit, then mmap_sem is not taken in
> the exit_mmap() path, so how does it help?
> 

It certainly helps in the shmdt case which is what the test case focused
on because that is what the application that triggered this bug was
doing. However, you're right in that the exit_mmap() path is still vunerable
because it does not take mmap_sem. I'll think about that a bit more.

> I spent hours trying to dream up a better patch, trying various
> approaches.  I think I have a nice one now, what do you think?  And
> more importantly, does it work?  I have not tried to test it at all,
> that I'm hoping to leave to you, I'm sure you'll attack it with gusto!
> 
> If you like it, please take it over and add your comments and signoff
> and send it in. 
> 

I like it in that it's simple and I can confirm it works for the test case
of interest.

However, is your patch not vunerable to truncate issues?
madvise()/truncate() issues was the main reason why I was wary of VMA tricks
as a solution. As it turns out, madvise(DONTNEED) is not a problem as it is
ignored for hugetlbfs but I think truncate is still problematic. Lets say
we mmap(MAP_SHARED) a hugetlbfs file and then truncate for whatever reason.

invalidate_inode_pages2
  invalidate_inode_pages2_range
    unmap_mapping_range_vma
      zap_page_range_single
        unmap_single_vma
	  __unmap_hugepage_range (removes VM_MAYSHARE)

The VMA still exists so the consequences for this would be varied but
minimally fault is going to be "interesting".

I think that potentially we could work around this but it may end up stomping
on the core MM and not necessarily be any better than Michal's patch.

> The second part won't come up in your testing, and could
> be made a separate patch if you prefer: it's a related point that struck
> me while I was playing with a different approach.

I'm fine with the second part.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
