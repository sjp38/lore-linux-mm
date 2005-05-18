From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17035.15766.660660.326331@gargle.gargle.HOWL>
Date: Wed, 18 May 2005 09:05:26 -0400
Subject: Re: [PATCH] Avoiding mmap fragmentation - clean rev
In-Reply-To: <200505172228.j4HMSkg28528@unix-os.sc.intel.com>
References: <E4BA51C8E4E9634993418831223F0A49291F06E1@scsmsx401.amr.corp.intel.com>
	<200505172228.j4HMSkg28528@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Wolfgang Wander' <wwc@rentec.com>, 'Andrew Morton' <akpm@osdl.org>, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W writes:
 > This patch tries to solve address space fragmentation issue brought
 > up by Wolfgang where fragmentation is so severe that application
 > would fail on 2.6 kernel.  Looking a bit deep into the issue, we
 > found that a lot of fragmentation were caused by suboptimal algorithm
 > in the munmap code path.  For example, as people pointed out that
 > when a series of munmap occurs, the free_area_cache would point to
 > last vma that was freed, ignoring its surrounding and not performing
 > any coalescing at all, thus artificially create more holes in the
 > virtual address space than necessary.  However, all the information
 > needed to perform coalescing are actually already there.  This patch
 > put that data in use so we will prevent artificial fragmentation.
 > 
 > This patch covers both bottom-up and top-down topology.  For bottom-up
 > topology, free_area_cache points to prev->vm_end. And for top-down,
 > free_area_cache points to next->vm_start.  The results are very promising,
 > it passes the test case that Wolfgang posted and I have tested it on a
 > variety of x86, x86_64, ia64 machines.
 > 
 > Please note, this patch completely obsoletes previous patch that
 > Wolfgang posted and should completely retain the performance benefit
 > of free_area_cache and at the same time preserving fragmentation to
 > minimum.
 > 
 > Andrew, please consider for -mm testing.  Thanks.
 > 

I do like it for its simplicity.  My test case is perfectly happy
with it and I'm all for including this one rather than my patch
as a fix.

Please note though that this patch only seems to address the issue of
fragmentation due to unmapping.

The other issue, namely that the old code (2.4) and my patch tend to
fill holes in near the base with small requests thus leaving larger
holes far from the base uncluttered is not addressed.   Here as in the
orginal 2.6 code we will distribute small request equally in all
available holes which will close larger holes unnessecarily.

I'll rerun my large scale applications that caused us to detect the
fragmentation issues in the first place. If they fail (which I don't
believe) we could maybe combine the two approaches to get a better
cache pointer for the unmap case and a way to unclutter the address
space via the cached_hole_size.

         Wolfgang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
