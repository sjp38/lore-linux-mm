Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8B31C6B02A4
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 17:56:44 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o6SLueMJ018747
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 14:56:40 -0700
Received: from yxm8 (yxm8.prod.google.com [10.190.4.8])
	by kpbe14.cbf.corp.google.com with ESMTP id o6SLucKL027918
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 14:56:39 -0700
Received: by yxm8 with SMTP id 8so1666478yxm.40
        for <linux-mm@kvack.org>; Wed, 28 Jul 2010 14:56:38 -0700 (PDT)
Date: Wed, 28 Jul 2010 14:56:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Bug 16415] New: Show_Memory/Shift-ScrollLock triggers "unable
 to handle kernel paging request at 00021c6e"
In-Reply-To: <20100728155026.GJ5300@csn.ul.ie>
Message-ID: <alpine.DEB.1.00.1007281423470.21425@tigran.mtv.corp.google.com>
References: <bug-16415-27@https.bugzilla.kernel.org/> <20100722153443.e266b2d6.akpm@linux-foundation.org> <20100727125428.GY5300@csn.ul.ie> <4C50233A.4090304@xs4all.nl> <20100728155026.GJ5300@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: The Nimble Byte <tnimble@xs4all.nl>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yinghai@kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 2010, Mel Gorman wrote:
> On Wed, Jul 28, 2010 at 02:31:54PM +0200, The Nimble Byte wrote:
> > [   17.182169] BUG: unable to handle kernel paging request at 4c4fe4ad
> > [   17.182169] IP: [<c01d8a07>] show_mem+0xbf/0x15c
> 
> In both boot logs, the bad request was very close to 0x4c4fe400. It
> doesn't look like any poison pattern but does it look like any sort of
> relevant sequence to anyone else? I'm wondering if there is some piece
> of hardware writing where it shouldn't similar to what this bug was
> about http://lkml.org/lkml/2010/6/6/172 .

This has intrigued me, but I can't spend more time on it.

I doubt whether it's worth trying to interpret the 0x4c4fe4ad etc, I
think just leftover junk from a troubled history.  What's much easier
to make sense of is the poison in the sister bug 16416: 0xcc splattered
over a portion of mem_map.  Cannot be SLUB_RED_INACTIVE because SLUB is
not configured in, so looks like POISON_FREE_INITMEM.

Yesterday I thought that too unlikely (I'd expect 16416 to be quicker
to reproduce if it really were that); but looking through this latest
on 16415 also points to initmem:

> > [    0.000000] Linux version 2.6.34.1 
> > (root@doeblin.development.xafax.nl) (gcc version 4.2.4) #26 SMP Wed Jul 
> > 28 13:24:34 CEST 2010
> > ...
> > [    0.000000] Subtract (46 early reservations)
> > [    0.000000]   #1 [0000001000 - 0000002000]   EX TRAMPOLINE
> > [    0.000000]   #2 [0000100000 - 000048df10]   TEXT DATA BSS
> > [    0.000000]   #3 [000048e000 - 00004920a6]             BRK
> > ...
> > [    0.000000] virtual kernel memory layout:
> > ...
> > [    0.000000]       .init : 0xc130c000 - 0xc135f000   ( 332 kB)
> > [    0.000000]       .data : 0xc031dd65 - 0xc040bc80   ( 951 kB)
> > [    0.000000]       .text : 0xc0100000 - 0xc031dd65   (2167 kB)
> > ...
> > [   17.182169] BUG: unable to handle kernel paging request at 4c4fe4ad
> > [   17.182169] IP: [<c01d8a07>] show_mem+0xbf/0x15c
> > [   17.182169] Oops: 0000 [#1] SMP
> > [   17.182169] Pid: 0, comm: swapper Not tainted 2.6.34.1 #26
> > [   17.182169] EIP is at show_mem+0xbf/0x15c
> > [   17.182169] EAX: 4c4fe4a9 EBX: 00018580 ECX: 00000001 EDX: c130c000
> > [   17.182169] ESI: 00018570 EDI: c0407900 EBP: c03dfdc8 ESP: c03dfda8

That EDX: c130c000 there is show_mem's struct page pointer into mem_map:
and it matches the start of the init area in the virtual kernel memory
layout above.  Looks as if we've had the misfortune to allocate mem_map
across an area which soon gets freed as initmem.

When I try to build that .config, my .init follows on immediately from
.data; and as I understand it, should all be included in the reservation
of TEXT DATA BSS.  But here there's a significant gap: I suppose that's
either confusing something, or else a symptom of confusion.

I wonder what toolchain the Nimble Byte is using, and a bugzilla
attachment of System.map might be helpful, to see where __init_begin
and __init_end are shown there in relation to other sections.

But over to you guys, I must extricate myself!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
