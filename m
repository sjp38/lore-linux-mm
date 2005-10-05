Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95Fq0eO016061
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 11:52:00 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95FqpfK524106
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 09:52:51 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j95FqoWu004001
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 09:52:50 -0600
Subject: Re: sparsemem & sparsemem extreme question
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051005063909.GA9699@osiris.boeblingen.de.ibm.com>
References: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com>
	 <1128442502.20208.6.camel@localhost>
	 <20051005063909.GA9699@osiris.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 08:52:34 -0700
Message-Id: <1128527554.26009.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 08:39 +0200, Heiko Carstens wrote:
> > > I'm just wondering why there is all this indirection stuff here and why not
> > > have one contiguous aray of struct pages (residing in the vmalloc area) that
> > > deals with whatever size of memory an architecture wants to support.
> > This is exactly what ia64 does today.  Programatically, it does remove a
> > layer of indirection.  However, there are some data structures that have
> > to be traversed during a lookup: the page tables.  Granted, the TLB will
> > provide some caching, but a lookup on ia64 can potentially be much more
> > expensive than the two cacheline misses that sparsemem extreme might
> > have.
> 
> Sure, just that on s390 we have a 1:1 mapping anyway. So these lookups would
> be more or less for free for us (compared to what we have now).

Is the 1:1 mapping done with pagetables?  If so, it is not free.

> > In the end no one has ever produced any compelling performance reason to
> > use a vmem_map (as ia64 calls it).  In addition, sparsemem doesn't cause
> > any known performance regressions, either.
> 
> As far as I understand the memory hotplug patches they won't work without
> SPARSEMEM support. So the ia64 approach with a vmem_map will not work here,
> right?

If we had vmem_map implemented for every arch that supported memory
hotplug, and it didn't have performance implications, then we could have
vmem_map everywhere, and use it for hotplug.

> Actually my concern is that whenever the address space that is covered with
> SPARSEMEM_EXTREME is not sufficient just another layer of indirection needs
> to be added.

Do you have any performance numbers to back up your concerns, or is it
more about the code complexity?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
