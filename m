Date: Wed, 20 Aug 2008 21:16:30 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC][PATCH 0/2] Quicklist is slighly problematic.
Message-ID: <20080821021630.GB23397@sgi.com>
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com> <48AC25E7.4090005@linux-foundation.org> <20080821021332.GA23397@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080821021332.GA23397@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, Aug 20, 2008 at 09:13:32PM -0500, Robin Holt wrote:
> On Wed, Aug 20, 2008 at 09:10:47AM -0500, Christoph Lameter wrote:
> > KOSAKI Motohiro wrote:
> > > Hi Cristoph,
> > > 
> > > Thank you for explain your quicklist plan at OLS.
> > > 
> > > So, I made summary to issue of quicklist.
> > > if you have a bit time, Could you please read this mail and patches?
> > > And, if possible, Could you please tell me your feeling?
> > 
> > I believe what I said at the OLS was that quicklists are fundamentally crappy
> > and should be replaced by something that works (Guess that is what you meant
> > by "plan"?). Quicklists were generalized from the IA64 arch code.
> > 
> > Good fixup but I would think that some more radical rework is needed.
> > 
> > Maybe some of this needs to vanish into the TLB handling logic?
> > 
> > Then I have thought for awhile that the main reason that quicklists exist are
> > the performance problems in the page allocator. If you can make the single
> > page alloc / free pass competitive in performance with quicklists then we
> > could get rid of all uses.
> 
> It is more than the free/alloc cycle, the quicklist saves us from
> having to zero the page.  In a sparsely filled page table, it saves time
> and cache footprint.  In a heavily used page table, you end up with a
> near wash.
> 
> One problem I see is somebody got rid of the node awareness.  We used
> to not put pages onto a quicklist when they were being released from a
> different node than the cpu is on.  Not sure where that went.  It was
> done because of the trap page problem described here.

Poorly worded.  Here is the code I am referring to:

#ifdef CONFIG_NUMA
        unsigned long nid = page_to_nid(virt_to_page(pgtable_entry));

        if (unlikely(nid != numa_node_id())) {
                free_page((unsigned long)pgtable_entry);
                return;
        }
#endif

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
