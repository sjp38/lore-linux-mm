Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 00B066B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 21:34:27 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so62241609pdb.1
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 18:34:26 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id fe3si29841988pad.183.2015.06.26.18.34.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 18:34:25 -0700 (PDT)
Date: Fri, 26 Jun 2015 18:34:16 -0700
From: Mark Hairgrove <mhairgrove@nvidia.com>
Subject: Re: [PATCH 06/36] HMM: add HMM page table v2.
In-Reply-To: <20150626163030.GA3748@gmail.com>
Message-ID: <alpine.DEB.2.00.1506261827090.20890@mdh-linux64-2.nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-7-git-send-email-j.glisse@gmail.com> <alpine.DEB.2.00.1506251540170.28614@mdh-linux64-2.nvidia.com> <20150626163030.GA3748@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="8323329-1411506140-1435368864=:20890"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

--8323329-1411506140-1435368864=:20890
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT



On Fri, 26 Jun 2015, Jerome Glisse wrote:

> On Thu, Jun 25, 2015 at 03:57:29PM -0700, Mark Hairgrove wrote:
> > On Thu, 21 May 2015, j.glisse@gmail.com wrote:
> > > From: Jerome Glisse <jglisse@redhat.com>
> > > [...]
> > > +
> > > +void hmm_pt_iter_init(struct hmm_pt_iter *iter);
> > > +void hmm_pt_iter_fini(struct hmm_pt_iter *iter, struct hmm_pt *pt);
> > > +unsigned long hmm_pt_iter_next(struct hmm_pt_iter *iter,
> > > +			       struct hmm_pt *pt,
> > > +			       unsigned long addr,
> > > +			       unsigned long end);
> > > +dma_addr_t *hmm_pt_iter_update(struct hmm_pt_iter *iter,
> > > +			       struct hmm_pt *pt,
> > > +			       unsigned long addr);
> > > +dma_addr_t *hmm_pt_iter_fault(struct hmm_pt_iter *iter,
> > > +			      struct hmm_pt *pt,
> > > +			      unsigned long addr);
> > 
> > I've got a few more thoughts on hmm_pt_iter after looking at some of the 
> > later patches. I think I've convinced myself that this patch functionally 
> > works as-is, but I've got some suggestions and questions about the design.
> > 
> > Right now there are these three major functions:
> > 
> > 1) hmm_pt_iter_update(addr)
> >    - Returns the hmm_pte * for addr, or NULL if none exists.
> > 
> > 2) hmm_pt_iter_fault(addr)
> >    - Returns the hmm_pte * for addr, allocating a new one if none exists.
> > 
> > 3) hmm_pt_iter_next(addr, end)
> >    - Returns the next possibly-valid address. The caller must use
> >      hmm_pt_iter_update to check if there really is an hmm_pte there.
> > 
> > In my view, there are two sources of confusion here:
> > - Naming. "update" shares a name with the HMM mirror callback, and it also
> >   implies that the page tables are "updated" as a result of the call. 
> >   "fault" likewise implies that the function handles a fault in some way.
> >   Neither of these implications are true.
> 
> Maybe hmm_pt_iter_walk & hmm_pt_iter_populate are better name ?

hmm_pt_iter_populate sounds good. See below for _walk.


> 
> 
> > - hmm_pt_iter_next and hmm_pt_iter_update have some overlapping
> >   functionality when compared to traditional iterators, requiring the 
> >   callers to all do this sort of thing:
> > 
> >         hmm_pte = hmm_pt_iter_update(&iter, &mirror->pt, addr);
> >         if (!hmm_pte) {
> >             addr = hmm_pt_iter_next(&iter, &mirror->pt,
> >                         addr, event->end);
> >             continue;
> >         }
> > 
> > Wouldn't it be more efficient and simpler to have _next do all the 
> > iteration internally so it always returns the next valid entry? Then you 
> > could combine _update and _next into a single function, something along 
> > these lines (which also addresses the naming concern):
> > 
> > void hmm_pt_iter_init(iter, pt, start, end);
> > unsigned long hmm_pt_iter_next(iter, hmm_pte *);
> > unsigned long hmm_pt_iter_next_alloc(iter, hmm_pte *);
> > 
> > hmm_pt_iter_next would return the address and ptep of the next valid 
> > entry, taking the place of the existing _update and _next functions. 
> > hmm_pt_iter_next_alloc takes the place of _fault.
> > 
> > Also, since the _next functions don't take in an address, the iterator 
> > doesn't have to handle the input addr being different from iter->cur.
> 
> It would still need to do the same kind of test, this test is really to
> know when you switch from one directory to the next and to drop and take
> reference accordingly.

But all of the directory references are already hidden entirely in the 
iterator _update function. The caller only has to worry about taking 
references on the bottom level, so I don't understand why the iterator 
needs to return to the caller when it hits the end of a directory. Or for 
that matter, why it returns every possible index within a directory to the 
caller whether that index is valid or not.

If _next only returned to the caller when it hit a valid hmm_pte (or end), 
then only one function would be needed (_next) instead of two 
(_update/_walk and _next).


> 
> 
> > The logical extent of this is a callback approach like mm_walk. That would 
> > be nice because the caller wouldn't have to worry about making the _init 
> > and _fini calls. I assume you didn't go with this approach because 
> > sometimes you need to iterate over hmm_pt while doing an mm_walk itself, 
> > and you didn't want the overhead of nesting those?
> 
> Correct i do not want to do a hmm_pt_walk inside a mm_walk, that sounded and
> looked bad in my mind. That being said i could add a hmm_pt_walk like mm_walk
> for device driver and simply have it using the hmm_pt_iter internally.

I agree that nesting walks feels bad. If we can get the hmm_pt_iter API 
simple enough, I don't think an hmm_pt_walk callback approach is 
necessary.


> 
> 
> > Finally, another minor thing I just noticed: shouldn't hmm_pt.h include 
> > <linux/bitops.h> since it uses all of the clear/set/test bit APIs?
> 
> Good catch, i forgot that.
> 
> Cheers,
> Jerome
> 
--8323329-1411506140-1435368864=:20890--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
