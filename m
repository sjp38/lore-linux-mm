Date: Tue, 1 May 2007 07:54:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: fragmentation avoidance Re: 2.6.22 -mm merge plans
In-Reply-To: <20070501101651.GA29957@skynet.ie>
Message-ID: <Pine.LNX.4.64.0705010724010.22931@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <20070501101651.GA29957@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007, Mel Gorman wrote:

>    anti-fragmentation-switch-over-to-pfn_valid_within.patch
> 
> These patches are the grouping pages by mobility patches. They get tested
> every time someone boots the machine from the perspective that they affect
> the page allocator. It is working to keep fragmentation problems to a
> minimum and being exercised.  We have beaten it heavily here on tests
> with a variety of machines using the system that drives test.kernel.org
> for both functionality and performance testing. That covers x86, x86_64,
> ppc64 and occasionally IA64. Granted, there are corner-case machines out
> there or we'd never receive bug reports at all.
> 
> They are currently being reviewed by Christoph Lameter. His feedback in
> the linux-mm thread "Antifrag patchset comments" has given me a TODO list
> which I'm currently working through. So far, there has been no fundamental
> mistake in my opinion and the additional work is logical extensions.

I think we really urgently need a defragmentation solution in Linux in 
order to support higher page allocations for various purposes. SLUB f.e. 
would benefit from it and the large blocksize patches are not reasonable 
without such a method.

However, the current code is not up to the task. I did not see a clean 
categorization of allocations nor a consistent handling of those. The 
cleanup work that would have to be done throughout the kernel is not 
there. It is spotty. There seems to be a series of heuristic driving this 
thing (I have to agree with Nick there). The temporary allocations that 
were missed are just a few that I found. The review of the rest of the 
kernel was not done. Mel said that he fixed up locations that showed up to 
be a problem in testing. That is another issue: Too much focus on testing 
instead of conceptual cleanness and clean code in the kernel. It looks 
like this is geared for a specific series of tests on specific platforms 
and also to a particular allocation size (max order sized huge pages).

There are major technical problems with

1. Large Scale allocs. Multiple MAX_ORDER blocks as required by the 
   antifrag patches may not exist on all platforms. Thus the antifrag 
   patches will not be able to generate their MAX_ORDER sections. We
   could reduce MAX_ORDER on some platforms but that would have other
   implications like limiting the highest order allocation.

2. Small huge page size support. F.e. IA64 can support down to page size
   huge pages. The antifrag patches handle huge page in a special way. 
   They are categorized as movable. Small huge pages may 
   therefore contaminate the movable area.

3. Defining the size of ZONE_MOVABLE. This was done to guarantee
   availability of movable memory but the practical effect is to
   guarantee that we panic when too many unreclaimable allocations have
   been done.

I have already said during the review that IMHO the patches are not ready 
for merging. They are currently more like a prototype that explores ideas. 
The generalization steps are not done.

How we could make progress:

1. Develop a useful categorization of allocations in the kernel whose
   utility goes beyond the antifrag patches. I.e. length of 
   the objects existence and the method of reclaim could be useful in 
   various contexts.

2. Have statistics of these various allocations.

3. Page allocator should gather statistics on how memory was allocated in
   the various categories.

4. The available data can then be used to driver more intelligent reclaim 
   and develop methods of antifrag or defragmentation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
