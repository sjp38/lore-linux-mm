Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDDB9000BD
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 16:08:12 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <863f8de5-a8e5-427d-a329-e69a5402f88a@default>
Date: Thu, 15 Sep 2011 13:07:38 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org>
 <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org>
 <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org>
 <4E72284B.2040907@linux.vnet.ibm.com>
 <075c4e4c-a22d-47d1-ae98-31839df6e722@default
 4E725109.3010609@linux.vnet.ibm.com>
In-Reply-To: <4E725109.3010609@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, dave@linux.vnet.ibm.com, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

> On 09/15/2011 12:29 PM, Dan Magenheimer wrote:
> >> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> >> Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
> >>
> >> Right now xvmalloc is broken for zcache's application because
> >> of its huge fragmentation for half the valid allocation sizes
> >> (> PAGE_SIZE/2).
> >
> > Um, I have to disagree here. It is broken for zcache for
> > SOME set of workloads/data, where the AVERAGE compression
> > is poor (> PAGE_SIZE/2).
>=20
> True.
>=20
> But are we not in agreement that xvmalloc needs to be replaced
> with an allocator that doesn't have this issue? I thought we all
> agreed on that...

First, let me make it clear that I very much do appreciate
your innovation and effort here.  I'm not trying to block
your work from getting upstream or create hoops for you to
jump through.  Heaven knows, I can personally attest to
how frustrating that can be!

I am in agreement that xvmalloc has a significant problem with
some workloads and that it would be good to fix that.  What
I'm not clear on is if we are replacing an algorithm with
Problem X with another algorithm that has Problem Y... or
at least, if we are, that we agree that Problem Y is not
worse across a broad set of real world workloads than Problem X.
=20
> >> My xcfmalloc patches are _a_ solution that is ready now.  Sure,
> >> it doesn't so compaction yet, and it has some metadata overhead.
> >> So it's not "ideal" (if there is such I thing). But it does fix
> >> the brokenness of xvmalloc for zcache's application.
> >
> > But at what cost?  As Dave Hansen pointed out, we still do
> > not have a comprehensive worst-case performance analysis for
> > xcfmalloc.  Without that (and without an analysis over a very
> > large set of workloads), it is difficult to characterize
> > one as "better" than the other.
>=20
> I'm not sure what you mean by "comprehensive worst-case performance
> analysis".  If you're talking about theoretical worst-case runtimes
> (i.e. O(whatever)) then apparently we are going to have to
> talk to an authority on algorithm analysis because we can't agree
> how to determine that.  However, it isn't difficult to look at the
> code and (within your own understanding) see what it is.
>=20
> I'd be interested so see what Nitin thinks is the worst-case runtime
> bound.
>=20
> How would you suggest that I measure xcfmalloc performance on a "very
> large set of workloads".  I guess another form of that question is: How
> did xvmalloc do this?

I'm far from an expert in the allocation algorithms you and
Nitin are discussing, so let me use an analogy: ordered link
lists.  If you insert, a sequence of N numbers from largest to
smallest and then search/retrieve them in order from smallest
to largest, the data structure appears very very fast.  If you
insert them in the opposite order and then search/retrieve
them in the opposite order, the data structure appears
very very slow.

For your algorithm, are there sequences of allocations/deallocations
which will perform very poorly?  If so, how poorly?  If
"perform very poorly" for allocation/deallocation is
a fraction of the time to compress/decompress, I don't
care, let's switch to xcfmalloc.  However, if one could
manufacture a sequence of allocations/searches where the
overhead is much larger than the compress/decompress
time (and especially if grows worse as N grows), that's
an issue we need to understand better.

I think Dave Hansen was saying the same thing in an earlier thread:

> From: Dave Hansen [mailto:dave@linux.vnet.ibm.com]
> It took the largest (most valuable) block, and split a 500 block when it
> didn't have to.  The reason it doesn't do this is that it doesn't
> _search_.  It just indexes and guesses.  That's *fast*, but it errs on
> the side of speed rather than being optimal.  That's OK, we do it all
> the time, but it *is* a compromise.  We should at least be thinking of
> the cases when this doesn't perform well.

In other words, what happens if on some workload, strictly
by chance, xcfmalloc always guesses wrong?  Will search time
grow linearly, or exponentially?  (This is especially an
issue if interrupts are disabled during the search, which
they currently are, correct?)

> >> So I see two ways going forward:
> >>
> >> 1) We review and integrate xcfmalloc now.  Then, when you are
> >> done with your allocator, we can run them side by side and see
> >> which is better by numbers.  If yours is better, you'll get no
> >> argument from me and we can replace xcfmalloc with yours.
> >>
> >> 2) We can agree on a date (sooner rather than later) by which your
> >> allocator will be completed.  At that time we can compare them and
> >> integrate the best one by the numbers.
> >>
> >> Which would you like to do?
> >
> > Seth, I am still not clear why it is not possible to support
> > either allocation algorithm, selectable at runtime.  Or even
> > dynamically... use xvmalloc to store well-compressible pages
> > and xcfmalloc for poorly-compressible pages.  I understand
> > it might require some additional coding, perhaps even an
> > ugly hack or two, but it seems possible.
>=20
> But why do an ugly hack if we can just use a single allocator
> that has the best overall performance for the allocation range
> the zcache requires.  Why make it more complicated that it
> needs to be?

I agree, if we are certain that your statement of "best overall
performance" is true.

If you and Nitin can agree that xcfmalloc is better than xvmalloc,
even if future-slab-based-allocator is predicted to be better
than xcfmalloc, I am OK with (1) above.  I just want to feel
confident we aren't exchanging problem X for problem Y (in
which case some runtime or dynamic selection hack might be better).

With all that said, I guess my bottom line is: If Nitin provides
an Acked-by on your patchset, I will too.

Thanks again for your work on this!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
