Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8286B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 12:58:32 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id fz5so57079222obc.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 09:58:32 -0800 (PST)
Received: from mail-ob0-x232.google.com (mail-ob0-x232.google.com. [2607:f8b0:4003:c01::232])
        by mx.google.com with ESMTPS id r82si3506361oif.40.2016.03.04.09.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 09:58:31 -0800 (PST)
Received: by mail-ob0-x232.google.com with SMTP id ts10so57009904obc.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 09:58:31 -0800 (PST)
Date: Fri, 4 Mar 2016 09:58:23 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Problems with swapping in v4.5-rc on POWER
In-Reply-To: <1456984266.28236.1.camel@ellerman.id.au>
Message-ID: <alpine.LSU.2.11.1603040948250.5477@eggly.anvils>
References: <alpine.LSU.2.11.1602241716220.15121@eggly.anvils> <877fhttmr1.fsf@linux.vnet.ibm.com> <alpine.LSU.2.11.1602242136270.6876@eggly.anvils> <alpine.LSU.2.11.1602251322130.8063@eggly.anvils> <alpine.LSU.2.11.1602260157430.10399@eggly.anvils>
 <alpine.LSU.2.11.1603021226300.31251@eggly.anvils> <1456984266.28236.1.camel@ellerman.id.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Hugh Dickins <hughd@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Mackerras <paulus@ozlabs.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, 3 Mar 2016, Michael Ellerman wrote:
> On Wed, 2016-03-02 at 12:49 -0800, Hugh Dickins wrote:
> > On Fri, 26 Feb 2016, Hugh Dickins wrote:
> > > On Thu, 25 Feb 2016, Hugh Dickins wrote:
> > > > On Wed, 24 Feb 2016, Hugh Dickins wrote:
> > > > > On Thu, 25 Feb 2016, Aneesh Kumar K.V wrote:
> > > > > > 
> > > > > > Can you test the impact of the merge listed below ?(ie, revert the merge and see if
> > > > > > we can reproduce and also verify with merge applied). This will give us a
> > > > > > set of commits to look closer. We had quiet a lot of page table
> > > > > > related changes going in this merge window. 
> > > > > > 
> > > > > > f689b742f217b2ffe7 ("Pull powerpc updates from Michael Ellerman:")
> > > > > > 
> > > > > > That is the merge commit that added _PAGE_PTE. 
> > > > > 
> > > > > Another experiment running on it at the moment, I'd like to give that
> > > > > a few more hours, and then will try the revert you suggest.  But does
> > > > > that merge revert cleanly, did you try?  I'm afraid of interactions,
> > > > > whether obvious or subtle, with the THP refcounting rework.  Oh, since
> > > > > I don't have THP configured on, maybe I can ignore any issues from that.
> > > > 
> > > > That revert worked painlessly, only a very few and simple conflicts,
> > > > I ran that under load for 12 hours, no problem seen.
> > > > 
> > > > I've now checked out an f689b742 tree and started on that, just to
> > > > confirm that it fails fairly quickly I hope; and will then proceed
> > > > to git bisect, giving that as bad and 37cea93b as good.
> > > > 
> > > > Given the uncertainty of whether 12 hours is really long enough to be
> > > > sure, and perhaps difficulties along the way, I don't rate my chances
> > > > of a reliable bisection higher than 60%, but we'll see.
> > > 
> > > I'm sure you won't want a breathless report from me on each bisection
> > > step, but I ought to report that: contrary to our expectations, the
> > > f689b742 survived without error for 12 hours, so appears to be good.
> > > I'll bisect between there and v4.5-rc1.
> > 
> > The bisection completed this morning (log appended below):
> > not a satisfactory conclusion, it's pointing to a davem/net merge.
> > 
> > I was uncomfortable when I marked that point bad in the first place:
> > it ran for 9 hours before hitting a compiler error, which was nearly
> > twice as long as the longest I'd seen before (5 hours), and
> > uncomfortably close to the 12 hours I've been taking as good.
> > 
> > My current thinking is that the powerpc merge that you indicated,
> > that I found to be "good", is the one that contains the bad commit;
> > but that the bug is very rare to manifest in that kernel, and my test
> > of the davem/net merge happened to be unusually unlucky to hit it.
> > 
> > Then some other later change makes it significantly easier to hit;
> > and identifying that change may make it much easier to pin down
> > what the original bug is.
> > 
> > So I've replayed the bisection up to that point, marked the davem/net
> > merge as good this time, and set off again in the hope that it will
> > lead somewhere more enlightening.  But prepared for disappointment.
> 
> Thanks Hugh. That logic sounds reasonable, I doubt we can blame davem :)
> 
> I've setup another box here to try and reproduce it. It's running with 4k
> pages, no THP, and it's going well into swap. Hopefully I can hit the same bug,
> but we'll see in 12 hours I guess.

The alternative bisection was as unsatisfactory as the first:
again it fingered an irrelevant merge (rather than any commit
pulled in by that merge) as the bad commit.

It seems this issue is too intermittent for bisection to be useful,
on my load anyway.

The best I can do now is try v4.4 for a couple of days, to verify that
still comes out good (rather than the machine going bad coincident with
v4.5-rc), then try v4.5-rc7 to verify that that still comes out bad.

I'll report back on those; but beyond that, I'll have to leave it to you.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
