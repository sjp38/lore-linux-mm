From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH 3/3] hugetlb: fix absurd HugePages_Rsvd
Date: Wed, 25 Oct 2006 20:59:18 -0700
Message-ID: <000001c6f8b3$1d4bd020$a389030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20061025100929.GA11040@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>, Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Gibson wrote on Wednesday, October 25, 2006 3:09 AM
> > And almost(?) all the backtracking could be taken out if i_mutex
> > were held; hugetlbfs_file_mmap is already taking i_mutex within
> > mmap_sem (contrary to usual mm lock ordering, but probably okay
> > since hugetlbfs has no read/write, though lockdep may need teaching).
> > Though serializing these faults at all is regrettable.
> 
> Um, yes.  Especially when I was in the middle of attempting to
> de-serialize it.  Christoph Lameter has userspace stuff to do hugepage
> initialization (clearing mostly), in parallal, which obviously won't
> work with the serialization.  I have a tentative patch to address it,

I used to argue dearly on how important it is to allow parallel hugetlb
faults for scalability, but somehow lost my ground in the midst of flurry
development.  Glad to see it is coming back.


> which replaces the hugetlb_instantiation_mutex with a table of
> mutexes, hashed on address_space and offset (or struct mm and address
> for MAP_PRIVATE).  Originally I tried to simply remove the mutex, and
> just retry faults when we got an OOM but a race was detected.  After
> several variants each on 2 or 3 basic approaches, each of which turned
> out to be less race-free than I originally thought, I gave up and went
> with the hashed mutexes.  Either way though, there will still be
> i_size issues to sort out.

We are trying to do too much in the fault path. One wild idea would be
to zero out page in the free_huge_page().  E.g. all "free" pages sitting
in the pool are ready to be handed out.  In the free_huge_page() path, we
have a lot more freedom and can scale better because there are no owner yet,
nor tricky race to worry about.  It will make the fault path faster.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
