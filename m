Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id BC24F6B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 20:43:29 -0400 (EDT)
Message-ID: <1371861805.13136.23.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 0/2] rwsem: performance enhancements for systems with
 many cores
From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Fri, 21 Jun 2013 17:43:25 -0700
In-Reply-To: <CANN689G1hyV_+2DxOiLqHDLGGuCjAqn9GhV-g4A0Jfd6YRQupQ@mail.gmail.com>
References: <1371858691.22432.3.camel@schen9-DESK>
	 <1371859222.13136.11.camel@buesod1.americas.hpqcorp.net>
	 <CANN689G1hyV_+2DxOiLqHDLGGuCjAqn9GhV-g4A0Jfd6YRQupQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Fri, 2013-06-21 at 17:25 -0700, Michel Lespinasse wrote:
> On Fri, Jun 21, 2013 at 5:00 PM, Davidlohr Bueso <davidlohr.bueso@hp.com> wrote:
> > On Fri, 2013-06-21 at 16:51 -0700, Tim Chen wrote:
> >> In this patchset, we introduce two optimizations to read write semaphore.
> >> The first one reduces cache bouncing of the sem->count field
> >> by doing a pre-read of the sem->count and avoid cmpxchg if possible.
> >> The second patch introduces similar optimistic spining logic in
> >> the mutex code for the writer lock acquisition of rw-sem.
> >>
> >> Combining the two patches, in testing by Davidlohr Bueso on aim7 workloads
> >> on 8 socket 80 cores system, he saw improvements of
> >> alltests (+14.5%), custom (+17%), disk (+11%), high_systime
> >> (+5%), shared (+15%) and short (+4%), most of them after around 500
> >> users when i_mmap was implemented as rwsem.
> >>
> >> Feedbacks on the effectiveness of these tweaks on other workloads
> >> will be appreciated.
> >
> > Tim, I was really hoping to send all this in one big bundle. I was doing
> > some further testing (enabling hyperthreading and some Oracle runs),
> > fortunately everything looks ok and we are getting actual improvements
> > on large boxes.
> >
> > That said, how about I send you my i_mmap rwsem patchset for a v2 of
> > this patchset?
> 
> I'm a bit confused about the state of these patchsets - it looks like
> I'm only copied into half of the conversations. Should I wait for a v2
> here, or should I hunt down for Alex's version of things, or... ?

Except for some internal patch logistics, you haven't been left out on
any conversations :)

My original plan was to send out, in one patchset: 

- rwsem optimizations from Alex (patch 1/2 here, which should be
actually 4 patches) +
- rwsem optimistic spinning (patch 2/2 here) +
- i_mmap_mutex to rwsem conversion (5 more patches)

Now, I realize that the i_mmap stuff might not be welcomed in a
rwsem-specific optimizations patchset like this one, but I think it's
relevant to include everything in a single bundle as it really shows the
performance boosts and it's what I have been using and measuring the
original negative rwsem performance when compared to a mutex. 

If folks don't agree, I can always send it as a separate patchset.

Thanks,
Davidlohr


the rwsem spin on owner functionality (2/2) + 4 from Alex )which is
really patch 1/2 here + I haven't sent out any

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
