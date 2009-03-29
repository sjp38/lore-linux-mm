Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7FA336B003D
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 10:13:37 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.14.3/8.13.8) with ESMTP id n2TECwrA461016
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 14:12:58 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2TECwsF4288714
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 16:12:58 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2TECvbT016381
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 16:12:57 +0200
Date: Sun, 29 Mar 2009 16:12:53 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [patch 0/6] Guest page hinting version 7.
Message-ID: <20090329161253.3faffdeb@skybase>
In-Reply-To: <1238195024.8286.562.camel@nimitz>
References: <20090327150905.819861420@de.ibm.com>
	<1238195024.8286.562.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 27 Mar 2009 16:03:43 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Fri, 2009-03-27 at 16:09 +0100, Martin Schwidefsky wrote:
> > If the host picks one of the
> > pages the guest can recreate, the host can throw it away instead of writing
> > it to the paging device. Simple and elegant.
> 
> Heh, simple and elegant for the hypervisor.  But I'm not sure I'm going
> to call *anything* that requires a new CPU instruction elegant. ;)

Hey its cool if you can request an instruction to solve your problem :-)

> I don't see any description of it in there any more, but I thought this
> entire patch set was to get rid of the idiotic triple I/Os in the
> following scenario:
> 
> 1. Hypervisor picks a page and evicts it out to disk, pays the I/O cost
>    to get it written out. (I/O #1)
> 2. Linux comes along (being a bit late to the party) and picks the same
>    page, also decides it needs to be out to disk
> 3. Linux tries to write the page to disk, but touches it in the 
>    process, pulling the page back in from the store where the hypervisor
>    wrote it. (I/O #2)
> 4. Linux writes the page to its swap device (I/O #3)
> 
> I don't see that mentioned at all in the current description.
> Simplifying the hypervisor is hard to get behind, but cutting system I/O
> by 2/3 is a much nicer benefit for 1200 lines of invasive code. ;)

You are right, for a newcomer to the party the advantages of this
approach are not really obvious. Should have copied some more text from
the boilerplate from the previous versions.

Yes, the guest page hinting code aims to reduce the hosts swap I/O.
There are two scenarios, one is the above, the other is a simple
read-only file cache page.
Without hinting:
1. Hypervisor picks a page and evicts it, that is one write I/O
2. Linux access the page and causes a host page fault. The host reads
the page from its swap disk, one read I/O.
In total 2 I/O operations.
With hinting:
1. Hypervisor picks a page, finds it volatile and throws it away.
2. Linux access the page and gets a discard fault from the host. Linux
reads the file page from its block device.
This is just one I/O operation.

> Can we persuade the hypervisor to tell us which pages it decided to page
> out and just skip those when we're scanning the LRU?

One principle of the whole approach is that the hypervisor does not
call into an otherwise idle guest. The cost of schedulung the virtual
cpu is just too high. So we would a means to store the information where
the guest can pick it up when it happens to do LRU. I don't think that
this will work out.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
