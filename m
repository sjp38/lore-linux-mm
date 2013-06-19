Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 8851D6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 19:24:12 -0400 (EDT)
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <1371683514.1783.3.camel@buesod1.americas.hpqcorp.net>
References: <1371165333.27102.568.camel@schen9-DESK>
	 <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
	 <51BD8A77.2080201@intel.com>
	 <1371486122.1778.14.camel@buesod1.americas.hpqcorp.net>
	 <51BF99B0.4040509@intel.com>
	 <1371512120.1778.40.camel@buesod1.americas.hpqcorp.net>
	 <1371514081.27102.651.camel@schen9-DESK>
	 <1371683514.1783.3.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 19 Jun 2013 16:24:15 -0700
Message-ID: <1371684255.27102.667.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Alex Shi <alex.shi@intel.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 2013-06-19 at 16:11 -0700, Davidlohr Bueso wrote:
> On Mon, 2013-06-17 at 17:08 -0700, Tim Chen wrote:
> > On Mon, 2013-06-17 at 16:35 -0700, Davidlohr Bueso wrote:
> > > On Tue, 2013-06-18 at 07:20 +0800, Alex Shi wrote:
> > > > On 06/18/2013 12:22 AM, Davidlohr Bueso wrote:
> > > > > After a lot of benchmarking, I finally got the ideal results for aim7,
> > > > > so far: this patch + optimistic spinning with preemption disabled. Just
> > > > > like optimistic spinning, this patch by itself makes little to no
> > > > > difference, yet combined is where we actually outperform 3.10-rc5. In
> > > > > addition, I noticed extra throughput when disabling preemption in
> > > > > try_optimistic_spin().
> > > > > 
> > > > > With i_mmap as a rwsem and these changes I could see performance
> > > > > benefits for alltests (+14.5%), custom (+17%), disk (+11%), high_systime
> > > > > (+5%), shared (+15%) and short (+4%), most of them after around 500
> > > > > users, for fewer users, it made little to no difference.
> > > > 
> > > > A pretty good number. what's the cpu number in your machine? :)
> > > 
> > > 8-socket, 80 cores (ht off)
> > > 
> > > 
> > 
> > David,
> > 
> > I wonder if you are interested to try the experimental patch below.  
> > It tries to avoid unnecessary writes to the sem->count when we are 
> > going to fail the down_write by executing rwsem_down_write_failed_s
> > instead of rwsem_down_write_failed.  It should further reduce the
> > cache line bouncing.  It didn't make a difference for my 
> > workload.  Wonder if it may help yours more in addition to the 
> > other two patches.  Right now the patch is an ugly hack.  I'll merge
> > rwsem_down_write_failed_s and rwsem_down_write_failed into one
> > function if this approach actually helps things.
> > 
> 
> I tried this on top of the patches we've already been dealing with. It
> actually did more harm than good. Only got a slight increase in the
> five_sec workload, for the rest either no effect, or negative. So far
> the best results are still with spin on owner + preempt disable + Alex's
> patches.
> 

Thanks for trying it out. A little disappointed as I was expecting no
change in performance for the worst case.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
