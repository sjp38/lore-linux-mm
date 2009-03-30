Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 42B736B003D
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 11:54:10 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2UFjSua027502
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 11:45:28 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2UFsxNO188182
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 11:54:59 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2UFswPr014975
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 11:54:58 -0400
Subject: Re: [patch 0/6] Guest page hinting version 7.
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090329161253.3faffdeb@skybase>
References: <20090327150905.819861420@de.ibm.com>
	 <1238195024.8286.562.camel@nimitz>  <20090329161253.3faffdeb@skybase>
Content-Type: text/plain
Date: Mon, 30 Mar 2009 08:54:55 -0700
Message-Id: <1238428495.8286.638.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Sun, 2009-03-29 at 16:12 +0200, Martin Schwidefsky wrote:
> > Can we persuade the hypervisor to tell us which pages it decided to page
> > out and just skip those when we're scanning the LRU?
> 
> One principle of the whole approach is that the hypervisor does not
> call into an otherwise idle guest. The cost of schedulung the virtual
> cpu is just too high. So we would a means to store the information where
> the guest can pick it up when it happens to do LRU. I don't think that
> this will work out.

I didn't mean for it to actively notify the guest.  Perhaps, as Rik
said, have a bitmap where the host can set or clear bit for the guest to
see.

As the guest is scanning the LRU, it checks the structure (or makes an
hcall or whatever) and sees that the hypervisor has already taken care
of the page.  It skips these pages in the first round of scanning.

I do see what you're saying about this saving the page-*out* operation
on the hypervisor side.  It can simply toss out pages instead of paging
them itself.  That's a pretty advanced optimization, though.  What would
this code look like if we didn't optimize to that level?

It also occurs to me that the hypervisor could be doing a lot of this
internally.  This whole scheme is about telling the hypervisor about
pages that we (the kernel) know we can regenerate.  The hypervisor
should know a lot of that information, too.  We ask it to populate a
page with stuff from virtual I/O devices or write a page out to those
devices.  The page remains volatile until something from the guest
writes to it.  The hypervisor could keep a record of how to recreate the
page as long as it remains volatile and clean.

That wouldn't cover things like page cache from network filesystems,
though.  

This patch does look like the full monty but I have to wonder what other
partial approaches are out there.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
