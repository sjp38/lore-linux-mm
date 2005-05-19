From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17036.56626.994129.265926@gargle.gargle.HOWL>
Date: Thu, 19 May 2005 14:38:42 -0400
Subject: RE: [PATCH] Avoiding mmap fragmentation - clean rev
In-Reply-To: <200505181757.j4IHv0g14491@unix-os.sc.intel.com>
References: <17035.30820.347382.9137@gargle.gargle.HOWL>
	<200505181757.j4IHv0g14491@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Wolfgang Wander' <wwc@rentec.com>, =?iso-8859-1?Q?Herv=E9_Piedvache?= <herve@elma.fr>, 'Andrew Morton' <akpm@osdl.org>, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W writes:
 > Wolfgang Wander wrote on Wednesday, May 18, 2005 10:16 AM
 > > My goal was to place small requests close to the base while leaving
 > > larger holes open as long as possible and far from the base. 2.4
 > > kernels did this inadvertently by always starting to search from the
 > > base, my patch starts searching from the base (upward or downward)
 > > if the new request is known to fit between base and current cache
 > > pointer, thus it maintains the 2.4 quality of mixing small and large
 > > requests and maintains the huge speedups Ingo introduced with the
 > > cache pointer.
 > 
 > This algorithm tends to penalize small size request and it would do a
 > linear search from the beginning. It would also penalize large size
 > request since cache pointer will be reset to a lower address and making
 > a subsequent large request to search forward.  In your case, since all
 > mappings are anonymous mmap with same page protection, you won't notice
 > performance problem because of coalescing in the mapped area.  But other
 > app like apache web server, which mmap thousands of different files will
 > degrade. The probability of linear search is lot higher with this proposal.
 > The nice thing about the current *broken* cache pointer is that it is
 > almost an O(1) order to fulfill a request since it moves in one direction.
 > The new proposal would reduce that O(1) probability.

I do certainly see that the algorithm isn't perfect in every case
however for the test case Ingo sent me (Ingo, did you verify the
timing?)  my patch performed as well as Ingo's original solution.  I
assume that Ingo's test was requesting same map sizes for every thread
so the results would be a bit biased in my favour... ;-)

That leaves us with two scenarious for a new mmap request:

  * the new request is greater or equal than the cached_hole_size ->
    no change in behaviour
  * otherwise we start the search at a position where we know the
    new request will fit in, this could eventually even be faster
    than the required wrap.

So I don't necessarily see that the probability is reduced in all
circumstances.  Clearly mixed size requests do tend to keep the
free_area_cache pointer low and thus will likely extend the search length.

Are there test cases/benchmarks which would simulate the behaviour of an 
Apache like application under the various schemes?

Clearly one has to weight the performance issues against the memory
efficiency but since we demonstratibly throw away 25% (or 1GB) of the
available address space in the various accumulated holes a long
running application can generate I hope that for the time being we can
stick with my first solution, preferably extended by your munmap fix? 

Please? ;-)

            Wolfgang
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
