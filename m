Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id ABD776B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 11:07:20 -0400 (EDT)
Received: by qgii30 with SMTP id i30so19930844qgi.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 08:07:20 -0700 (PDT)
Received: from mail-qk0-x22c.google.com (mail-qk0-x22c.google.com. [2607:f8b0:400d:c09::22c])
        by mx.google.com with ESMTPS id j9si2523713qhc.78.2015.07.01.08.07.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 08:07:18 -0700 (PDT)
Received: by qkhu186 with SMTP id u186so31444733qkh.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 08:07:18 -0700 (PDT)
Date: Wed, 1 Jul 2015 11:07:08 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 06/36] HMM: add HMM page table v2.
Message-ID: <20150701150707.GA9313@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432236705-4209-7-git-send-email-j.glisse@gmail.com>
 <alpine.DEB.2.00.1506251540170.28614@mdh-linux64-2.nvidia.com>
 <20150626163030.GA3748@gmail.com>
 <alpine.DEB.2.00.1506261827090.20890@mdh-linux64-2.nvidia.com>
 <20150629144305.GA2173@gmail.com>
 <alpine.DEB.2.00.1506301946190.31456@mdh-linux64-2.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.00.1506301946190.31456@mdh-linux64-2.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

On Tue, Jun 30, 2015 at 07:51:12PM -0700, Mark Hairgrove wrote:
> On Mon, 29 Jun 2015, Jerome Glisse wrote:
> > [...]
> > 
> > Iterator is what protect against concurrent freeing of the directory so it
> > has to return to caller on directory boundary (for 64bits arch with 64bits
> > pte it has return every 512 entries). Otherwise pt_iter_fini() would have
> > to walk over the whole directory range again just to drop reference and this
> > doesn't sound like a good idea.
> 
> I don't understand why it would have to return to the caller to unprotect 
> the directory. The iterator would simply drop the reference to the 
> previous directory, take a reference on the next one, and keep searching 
> for a valid entry.
> 
> Why would pt_iter_fini have to walk over the entire range? The iterator 
> would keep at most one directory per level referenced. _fini would walk 
> the per-level ptd array and unprotect each level, the same way it does 
> now.

I think here we are just misunderstanding each other. I am saying that
iterator have to return on directory boundary (ie when switching from one
directory to the next). The return part is not only for protection it is
also by design because iterator function should not test the page table
entry as different code path have different synchronization requirement.


> > So really with what you are asking it whould be:
> > 
> > hmm_pt_iter_init(&iter, start, end);
> > for(next=pt_iter_next(&iter,&ptep); next<end; next=pt_iter_next(&iter,&ptep))
> > {
> >    // Here ptep is valid until next address. Above you have to call
> >    // pt_iter_next() to switch to next directory.
> >    addr = max(start, next - (~HMM_PMD_MASK + 1));
> >    for (; addr < next; addr += PAGE_SIZE, ptep++) {
> >       // access ptep
> >    }
> > }
> > 
> > My point is that internally pt_iter_next() will do the exact same test it is
> > doing now btw cur and addr. Just that the addr is no longer explicit but iter
> > infer it.
> 
> But this way, the iteration across directories is more efficient because 
> the iterator can simply walk the directory array. Take a directory that 
> has one valid entry at the very end. The existing iteration will do this:
> 
> hmm_pt_iter_next(dir_addr[0], end)
>     Walk up the ptd array
>     Compute level start and end and compare them to dir_addr[0]
>     Compute dir_addr[1] using addr and pt->mask
>     Return dir_addr[1]
> hmm_pt_iter_update(dir_addr[1])
>     Walk up the ptd array, compute level start and end
>     Compute level index of dir_addr[1]
>     Read entry for dir_addr[1]
>     Return NULL
> hmm_pt_iter_next(dir_addr[1], end)
>     ...
> And so on 511 times until the last entry is read.
> 
> This is really more suited to a for loop iteration, which it could be if 
> this were fully contained within the _next call.

No, existing code does not necessarily do that. Current use pattern is :

for (addr = start; addr < end;) {
   ptep = hmm_pt_iter_update(iter, addr);
   if (!ptep) {
     addr = hmm_pt_iter_next(iter, addr, end);
     continue;
   }
   next = hmm_pt_level_next(pt, addr, end);
   for (; addr < next; addr += PAGE_SIZE, ptep++) {
     // Process addr using ptep.
   }
}

The inner loop is on directory boundary ie 512 entries on 64bits arch.
It is that way because on some case you do not want the iterator to
control the address, the outer loop might be accessing several different
mirror page table each might have different gap. So you really want to
have explicit address provided to the iterator function.

Also iterator can not really test for valid entry as locking requirement
and synchronization with other thread is different depending on which
code path is walking the page table. So testing inside the iterator
function is kind of pointless has the performed test might be no longer
revealent by the time it returns pointer and address to the caller.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
