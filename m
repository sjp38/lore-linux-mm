Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AB3368D003A
	for <linux-mm@kvack.org>; Sun, 13 Mar 2011 13:14:23 -0400 (EDT)
Date: Sun, 13 Mar 2011 18:14:19 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [REVIEW] NVM Express driver
Message-ID: <20110313171419.GL2499@one.firstfloor.org>
References: <20110303204749.GY3663@linux.intel.com> <m24o79cmv4.fsf@firstfloor.org> <20110312055146.GA4183@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110312055146.GA4183@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Mar 12, 2011 at 12:51:46AM -0500, Matthew Wilcox wrote:
> Is there a good API to iterate through each socket, then each core in a
> socket, then each HT sibling?  eg, if I have 20 queues and 2x6x2 CPUs,

Not for this particular order. And also you have to handle
hotplug in any case anyways.

And whatever you do, don't add NR_CPUS arrays.

> I want to assign at least one queue to each core; some threads will get
> their own queues and others will have to share with their HT sibling.

Please write a generic library function for this if you do this.

> 
> > > +	nprps = DIV_ROUND_UP(length, PAGE_SIZE);
> > > +	npages = DIV_ROUND_UP(8 * nprps, PAGE_SIZE);
> > > +	prps = kmalloc(sizeof(*prps) + sizeof(__le64 *) * npages, GFP_ATOMIC);
> > > +	prp_page = 0;
> > > +	if (nprps <= (256 / 8)) {
> > > +		pool = dev->prp_small_pool;
> > > +		prps->npages = 0;
> > 
> > 
> > Unchecked GFP_ATOMIC allocation? That will oops soon.
> > Besides GFP_ATOMIC a very risky thing to do on a low memory situation,
> > which can trigger writeouts.
> 
> Ah yes, thank you.  There are a few other places like this.  Bizarrely,
> they've not oopsed during the xfstests runs.

You need suitable background load. If you run it in LTP the harness has
support for background load. For GFP_ATOMIC exhaustion you typically
need something interrupt intensive, like a lot of networking.

> 
> My plan for this is, instead of using a mempool, to submit partial I/Os
> in the rare cases where a write cannot allocate memory.  I have the
> design in my head, just not committed to code yet.  The design also
> avoids allocating any memory in the driver for I/Os that do not cross
> a page boundary.

I forgot the latest status, but there were a lot of improvements
with dirty pages handling since that "no memory allocation on writeout"
rule was introduced. It may not be as big a problem as it used to 
be with GFP_NOFS. 

Copying linux-mm in case there are deep thoughts on this there.

Just GFP_ATOMIC is definitely still a bad idea there. 

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
