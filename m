Date: Fri, 27 Oct 2006 08:19:08 +1000
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 3/3] hugetlb: fix absurd HugePages_Rsvd
Message-ID: <20061026221908.GA9518@localhost.localdomain>
References: <Pine.LNX.4.64.0610261200520.2802@schroedinger.engr.sgi.com> <000001c6f933$b75bc190$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001c6f933$b75bc190$ff0da8c0@amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Christoph Lameter' <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 26, 2006 at 12:19:53PM -0700, Chen, Kenneth W wrote:
> Christoph Lameter wrote on Thursday, October 26, 2006 12:09 PM
> > On Wed, 25 Oct 2006, Chen, Kenneth W wrote:
> > > I used to argue dearly on how important it is to allow parallel hugetlb
> > > faults for scalability, but somehow lost my ground in the midst of flurry
> > > development.  Glad to see it is coming back.
> > 
> > I wish someone would have cced me before allowing performance atrocities
> > such as this.
> > 
> > Performance before the "fixes" (March, 2.6.16):
> > 
> > hsz=256M thr=100 pgs=10 min= 1370ms max=1746ms avg= 1554ms wall=1995ms cpu=155473ms
> > hsz=256M thr=100 pgs=10 min= 1936ms max=3706ms avg= 2610ms wall=4085ms cpu=261076ms
> > hsz=256M thr=100 pgs=10 min= 1375ms max=1988ms avg= 1600ms wall=2241ms cpu=160084ms
> > 
> > Performance now:
> > 
> > hsz=256M thr=10 pgs=3 min= 2965ms max=4091ms avg= 3471ms wall=4232ms cpu=34715ms
> > hsz=256M thr=100 pgs=3 min=16268ms max=43856ms avg=35927ms wall=44561ms cpu=3592702ms
> > hsz=256M thr=250 pgs=3 min=38348ms max=91242ms avg=74077ms wall=97071ms cpu=18519284ms
> > 
> > Note the performance now is only using 3 instead of 10 pages. Still factor 
> > 10 down! Meaning we are now much worse than that.
> > 
> > With David's latest parallelization attempt:
> > 
> > hsz=256M thr=100 pgs=10 min= 1373ms max=9604ms avg= 6311ms wall=10787ms cpu=631164ms
> > hsz=256M thr=100 pgs=10 min= 1442ms max=9115ms avg= 6386ms wall=10078ms cpu=638645ms
> > hsz=256M thr=100 pgs=10 min= 1451ms max=10788ms avg= 7430ms wall=11357ms cpu=743070ms
> > hsz=256M thr=100 pgs=10 min= 1439ms max=11876ms avg= 8396ms wall=13091ms cpu=839642ms
> > 
> > Still down by a factor of 3 to 4.
> 
> 
> One performance fix I have in mind is to only use the mutex when
> system is down to 1 free hugetlb page. That is the real reason why
> mutex got introduced. I'm implementing it right now and hope it will
> restore most if not all of the performance we lost.

Not sufficient for a system with >2 CPUs.  And with preempt and
pathalogical conditions I'm not sure even use lock if # freepages < #
cpus is adequate.

> Christoph, the shared page table for hugetlb also need your advice
> here in the path of allocating page table page. It takes a per inode
> spin lock in order to find shareable page table page.  Do you think
> it will cause problem?  I hope not.
> 
> - Ken
> 

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
