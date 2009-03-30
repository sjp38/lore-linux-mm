Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E672B6B003D
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 12:33:43 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2UGYAin116376
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 16:34:10 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2UGY86k4337720
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 18:34:10 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2UGY8Pc012677
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 18:34:08 +0200
Date: Mon, 30 Mar 2009 18:34:05 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [patch 0/6] Guest page hinting version 7.
Message-ID: <20090330183405.750440da@skybase>
In-Reply-To: <1238428495.8286.638.camel@nimitz>
References: <20090327150905.819861420@de.ibm.com>
	<1238195024.8286.562.camel@nimitz>
	<20090329161253.3faffdeb@skybase>
	<1238428495.8286.638.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, 30 Mar 2009 08:54:55 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Sun, 2009-03-29 at 16:12 +0200, Martin Schwidefsky wrote:
> > > Can we persuade the hypervisor to tell us which pages it decided to page
> > > out and just skip those when we're scanning the LRU?
> > 
> > One principle of the whole approach is that the hypervisor does not
> > call into an otherwise idle guest. The cost of schedulung the virtual
> > cpu is just too high. So we would a means to store the information where
> > the guest can pick it up when it happens to do LRU. I don't think that
> > this will work out.
> 
> I didn't mean for it to actively notify the guest.  Perhaps, as Rik
> said, have a bitmap where the host can set or clear bit for the guest to
> see.

Yes, agreed.

> As the guest is scanning the LRU, it checks the structure (or makes an
> hcall or whatever) and sees that the hypervisor has already taken care
> of the page.  It skips these pages in the first round of scanning.

As long as we make this optional I'm fine with it. On s390 with the
current implementation that translates to an ESSA call. Which is not
exactly inexpensive, we are talking about > 100 cycles. The better
solution for us is to age the page with the standard active/inactive
processing.

> I do see what you're saying about this saving the page-*out* operation
> on the hypervisor side.  It can simply toss out pages instead of paging
> them itself.  That's a pretty advanced optimization, though.  What would
> this code look like if we didn't optimize to that level?

Why? It is just a simple test in the hosts LRU scan. If the page is at
the end of the inactive list AND has the volatile state then don't
bother with writeback, just throw it away. This is the only place where
the host has to check for the page state. 

> It also occurs to me that the hypervisor could be doing a lot of this
> internally.  This whole scheme is about telling the hypervisor about
> pages that we (the kernel) know we can regenerate.  The hypervisor
> should know a lot of that information, too.  We ask it to populate a
> page with stuff from virtual I/O devices or write a page out to those
> devices.  The page remains volatile until something from the guest
> writes to it.  The hypervisor could keep a record of how to recreate the
> page as long as it remains volatile and clean.

Unfortunately it is not that simple. There are quite a few reasons why
a page has to be made stable. You'd have to pass that information back
and forth between the guest and the host otherwise the host will throw
away e.g. an mlocked page because it is still marked as volatile in the
virtual block device.

> That wouldn't cover things like page cache from network filesystems,
> though.  

Yes, there are pages with a backing the host knows nothing about.

> This patch does look like the full monty but I have to wonder what other
> partial approaches are out there.  

I am open for suggestions. The simples partial approach is already
implemented for s390: unused/stable transitions in the buddy allocator.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
