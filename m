Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id A573A6B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 10:43:17 -0400 (EDT)
Received: by qgii30 with SMTP id i30so7635788qgi.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 07:43:17 -0700 (PDT)
Received: from mail-qc0-x235.google.com (mail-qc0-x235.google.com. [2607:f8b0:400d:c01::235])
        by mx.google.com with ESMTPS id 123si41874145qhv.14.2015.06.29.07.43.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 07:43:16 -0700 (PDT)
Received: by qcji3 with SMTP id i3so43474105qcj.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 07:43:16 -0700 (PDT)
Date: Mon, 29 Jun 2015 10:43:06 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 06/36] HMM: add HMM page table v2.
Message-ID: <20150629144305.GA2173@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432236705-4209-7-git-send-email-j.glisse@gmail.com>
 <alpine.DEB.2.00.1506251540170.28614@mdh-linux64-2.nvidia.com>
 <20150626163030.GA3748@gmail.com>
 <alpine.DEB.2.00.1506261827090.20890@mdh-linux64-2.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.00.1506261827090.20890@mdh-linux64-2.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

On Fri, Jun 26, 2015 at 06:34:16PM -0700, Mark Hairgrove wrote:
> 
> 
> On Fri, 26 Jun 2015, Jerome Glisse wrote:
> 
> > On Thu, Jun 25, 2015 at 03:57:29PM -0700, Mark Hairgrove wrote:
> > > On Thu, 21 May 2015, j.glisse@gmail.com wrote:
> > > > From: Jerome Glisse <jglisse@redhat.com>
> > > > [...]
> > > > +
> > > > +void hmm_pt_iter_init(struct hmm_pt_iter *iter);
> > > > +void hmm_pt_iter_fini(struct hmm_pt_iter *iter, struct hmm_pt *pt);
> > > > +unsigned long hmm_pt_iter_next(struct hmm_pt_iter *iter,
> > > > +			       struct hmm_pt *pt,
> > > > +			       unsigned long addr,
> > > > +			       unsigned long end);
> > > > +dma_addr_t *hmm_pt_iter_update(struct hmm_pt_iter *iter,
> > > > +			       struct hmm_pt *pt,
> > > > +			       unsigned long addr);
> > > > +dma_addr_t *hmm_pt_iter_fault(struct hmm_pt_iter *iter,
> > > > +			      struct hmm_pt *pt,
> > > > +			      unsigned long addr);
> > > 
> > > I've got a few more thoughts on hmm_pt_iter after looking at some of the 
> > > later patches. I think I've convinced myself that this patch functionally 
> > > works as-is, but I've got some suggestions and questions about the design.
> > > 
> > > Right now there are these three major functions:
> > > 
> > > 1) hmm_pt_iter_update(addr)
> > >    - Returns the hmm_pte * for addr, or NULL if none exists.
> > > 
> > > 2) hmm_pt_iter_fault(addr)
> > >    - Returns the hmm_pte * for addr, allocating a new one if none exists.
> > > 
> > > 3) hmm_pt_iter_next(addr, end)
> > >    - Returns the next possibly-valid address. The caller must use
> > >      hmm_pt_iter_update to check if there really is an hmm_pte there.
> > > 
> > > In my view, there are two sources of confusion here:
> > > - Naming. "update" shares a name with the HMM mirror callback, and it also
> > >   implies that the page tables are "updated" as a result of the call. 
> > >   "fault" likewise implies that the function handles a fault in some way.
> > >   Neither of these implications are true.
> > 
> > Maybe hmm_pt_iter_walk & hmm_pt_iter_populate are better name ?
> 
> hmm_pt_iter_populate sounds good. See below for _walk.
> 
> 
> > 
> > 
> > > - hmm_pt_iter_next and hmm_pt_iter_update have some overlapping
> > >   functionality when compared to traditional iterators, requiring the 
> > >   callers to all do this sort of thing:
> > > 
> > >         hmm_pte = hmm_pt_iter_update(&iter, &mirror->pt, addr);
> > >         if (!hmm_pte) {
> > >             addr = hmm_pt_iter_next(&iter, &mirror->pt,
> > >                         addr, event->end);
> > >             continue;
> > >         }
> > > 
> > > Wouldn't it be more efficient and simpler to have _next do all the 
> > > iteration internally so it always returns the next valid entry? Then you 
> > > could combine _update and _next into a single function, something along 
> > > these lines (which also addresses the naming concern):
> > > 
> > > void hmm_pt_iter_init(iter, pt, start, end);
> > > unsigned long hmm_pt_iter_next(iter, hmm_pte *);
> > > unsigned long hmm_pt_iter_next_alloc(iter, hmm_pte *);
> > > 
> > > hmm_pt_iter_next would return the address and ptep of the next valid 
> > > entry, taking the place of the existing _update and _next functions. 
> > > hmm_pt_iter_next_alloc takes the place of _fault.
> > > 
> > > Also, since the _next functions don't take in an address, the iterator 
> > > doesn't have to handle the input addr being different from iter->cur.
> > 
> > It would still need to do the same kind of test, this test is really to
> > know when you switch from one directory to the next and to drop and take
> > reference accordingly.
> 
> But all of the directory references are already hidden entirely in the 
> iterator _update function. The caller only has to worry about taking 
> references on the bottom level, so I don't understand why the iterator 
> needs to return to the caller when it hits the end of a directory. Or for 
> that matter, why it returns every possible index within a directory to the 
> caller whether that index is valid or not.

Iterator is what protect against concurrent freeing of the directory so it
has to return to caller on directory boundary (for 64bits arch with 64bits
pte it has return every 512 entries). Otherwise pt_iter_fini() would have
to walk over the whole directory range again just to drop reference and this
doesn't sound like a good idea.

So really with what you are asking it whould be:

hmm_pt_iter_init(&iter, start, end);
for(next=pt_iter_next(&iter,&ptep); next<end; next=pt_iter_next(&iter,&ptep))
{
   // Here ptep is valid until next address. Above you have to call
   // pt_iter_next() to switch to next directory.
   addr = max(start, next - (~HMM_PMD_MASK + 1));
   for (; addr < next; addr += PAGE_SIZE, ptep++) {
      // access ptep
   }
}

My point is that internally pt_iter_next() will do the exact same test it is
doing now btw cur and addr. Just that the addr is no longer explicit but iter
infer it.

> If _next only returned to the caller when it hit a valid hmm_pte (or end), 
> then only one function would be needed (_next) instead of two 
> (_update/_walk and _next).

On the valid entry side, this is because when you are walking the page table
you have no garanty that the entry will not be clear below you (in case of
concurrent invalidation). The only garanty you have is that if you are able
to read a valid entry from the update() callback then this entry is valid
until you get a new update() callback telling you otherwise.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
