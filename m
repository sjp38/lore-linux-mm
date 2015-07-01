Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1A66B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 22:51:24 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so16784611pdb.2
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 19:51:24 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id kx14si756686pab.155.2015.06.30.19.51.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jun 2015 19:51:23 -0700 (PDT)
Date: Tue, 30 Jun 2015 19:51:12 -0700
From: Mark Hairgrove <mhairgrove@nvidia.com>
Subject: Re: [PATCH 06/36] HMM: add HMM page table v2.
In-Reply-To: <20150629144305.GA2173@gmail.com>
Message-ID: <alpine.DEB.2.00.1506301946190.31456@mdh-linux64-2.nvidia.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-7-git-send-email-j.glisse@gmail.com> <alpine.DEB.2.00.1506251540170.28614@mdh-linux64-2.nvidia.com> <20150626163030.GA3748@gmail.com> <alpine.DEB.2.00.1506261827090.20890@mdh-linux64-2.nvidia.com>
 <20150629144305.GA2173@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8323329-43040936-1435719081=:31456"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, "joro@8bytes.org" <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

--8323329-43040936-1435719081=:31456
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT



On Mon, 29 Jun 2015, Jerome Glisse wrote:

> [...]
> 
> Iterator is what protect against concurrent freeing of the directory so it
> has to return to caller on directory boundary (for 64bits arch with 64bits
> pte it has return every 512 entries). Otherwise pt_iter_fini() would have
> to walk over the whole directory range again just to drop reference and this
> doesn't sound like a good idea.

I don't understand why it would have to return to the caller to unprotect 
the directory. The iterator would simply drop the reference to the 
previous directory, take a reference on the next one, and keep searching 
for a valid entry.

Why would pt_iter_fini have to walk over the entire range? The iterator 
would keep at most one directory per level referenced. _fini would walk 
the per-level ptd array and unprotect each level, the same way it does 
now.


> 
> So really with what you are asking it whould be:
> 
> hmm_pt_iter_init(&iter, start, end);
> for(next=pt_iter_next(&iter,&ptep); next<end; next=pt_iter_next(&iter,&ptep))
> {
>    // Here ptep is valid until next address. Above you have to call
>    // pt_iter_next() to switch to next directory.
>    addr = max(start, next - (~HMM_PMD_MASK + 1));
>    for (; addr < next; addr += PAGE_SIZE, ptep++) {
>       // access ptep
>    }
> }
> 
> My point is that internally pt_iter_next() will do the exact same test it is
> doing now btw cur and addr. Just that the addr is no longer explicit but iter
> infer it.

But this way, the iteration across directories is more efficient because 
the iterator can simply walk the directory array. Take a directory that 
has one valid entry at the very end. The existing iteration will do this:

hmm_pt_iter_next(dir_addr[0], end)
    Walk up the ptd array
    Compute level start and end and compare them to dir_addr[0]
    Compute dir_addr[1] using addr and pt->mask
    Return dir_addr[1]
hmm_pt_iter_update(dir_addr[1])
    Walk up the ptd array, compute level start and end
    Compute level index of dir_addr[1]
    Read entry for dir_addr[1]
    Return NULL
hmm_pt_iter_next(dir_addr[1], end)
    ...
And so on 511 times until the last entry is read.

This is really more suited to a for loop iteration, which it could be if 
this were fully contained within the _next call.

> 
> > If _next only returned to the caller when it hit a valid hmm_pte (or end), 
> > then only one function would be needed (_next) instead of two 
> > (_update/_walk and _next).
> 
> On the valid entry side, this is because when you are walking the page table
> you have no garanty that the entry will not be clear below you (in case of
> concurrent invalidation). The only garanty you have is that if you are able
> to read a valid entry from the update() callback then this entry is valid
> until you get a new update() callback telling you otherwise.
> 
> Cheers,
> Jerome
> 
--8323329-43040936-1435719081=:31456--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
