Date: Wed, 18 May 2005 09:28:38 +0200
From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: [PATCH] Avoiding mmap fragmentation - clean rev
Message-ID: <20050518072838.GB15326@devserv.devel.redhat.com>
References: <E4BA51C8E4E9634993418831223F0A49291F06E1@scsmsx401.amr.corp.intel.com> <200505172228.j4HMSkg28528@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200505172228.j4HMSkg28528@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Wolfgang Wander' <wwc@rentec.com>, 'Andrew Morton' <akpm@osdl.org>, mingo@elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 17, 2005 at 03:28:46PM -0700, Chen, Kenneth W wrote:
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

this has one downside (other than that I like it due to it's simplicity):
we've seen situations where there was a 4Kb gap at the start of the mmaps,
and then all future mmaps are bigger (say, stack sized). That 4Kb gap would
entirely void the advantage of the cache if the cache stuck to that 4kb gap.
(Personally I favor correctness above all but it does hurt performance
really bad)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
