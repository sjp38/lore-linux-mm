Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 707D86B003B
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 05:23:07 -0400 (EDT)
Date: Mon, 8 Jul 2013 10:23:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 13/15] sched: Set preferred NUMA node based on number of
 private faults
Message-ID: <20130708092303.GZ1875@suse.de>
References: <1373065742-9753-1-git-send-email-mgorman@suse.de>
 <1373065742-9753-14-git-send-email-mgorman@suse.de>
 <20130706104107.GR18898@dyad.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130706104107.GR18898@dyad.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Jul 06, 2013 at 12:41:07PM +0200, Peter Zijlstra wrote:
> On Sat, Jul 06, 2013 at 12:09:00AM +0100, Mel Gorman wrote:
> > +++ b/include/linux/mm.h
> > @@ -582,11 +582,11 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
> >   * sets it, so none of the operations on it need to be atomic.
> >   */
> >  
> > -/* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_NID] | ... | FLAGS | */
> > +/* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_NIDPID] | ... | FLAGS | */
> >  #define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
> >  #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
> >  #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
> > -#define LAST_NID_PGOFF		(ZONES_PGOFF - LAST_NID_WIDTH)
> > +#define LAST_NIDPID_PGOFF	(ZONES_PGOFF - LAST_NIDPID_WIDTH)
> 
> I saw the same with Ingo's patch doing the similar thing. But why do we fuse
> these two into a single field? Would it not make more sense to have them be
> separate fields?
> 
> Yes I get we update and read them together, and we could still do that with
> appropriate helper function, but they are two independent values stored in the
> page flags.
> 

There were two reasons. First, it is because we update and read them
together. Second, it's all or nothing if this field is included in the
page->flags or not. I know this could also be done with helpers and
other tricks but I did not think it would be any easier to understand.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
