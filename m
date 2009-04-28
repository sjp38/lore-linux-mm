Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B417A6B0047
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 12:52:14 -0400 (EDT)
Subject: Re: Memory/CPU affinity and Nehalem/QPI
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <606676310904280915i3161fc90h367218482b19bbd6@mail.gmail.com>
References: <606676310904280915i3161fc90h367218482b19bbd6@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 28 Apr 2009 12:52:57 -0400
Message-Id: <1240937577.6998.78.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Dickinson <andrew@whydna.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-28 at 09:15 -0700, Andrew Dickinson wrote:
> Howdy linux-mm,
> 
> <background>
> I'm working on a kernel module which does some packet mangling based
> on the results of a memory lookup;  a packet comes in, I do a table
> lookup and if there's a match, I mangle the packet.  This process is
> 2-way; I encode in one direction and decode in the other.  I've found
> that I get better performance of I pin the interrupts of the 2 NICs in
> my system to different cores; I match the rx IRQs on one NIC and the
> tx IRQs on the other NIC to one set of cores and the other rx/tx pairs
> to another set of cores.  The reason for the IRQ pinning is that I
> spend less time passing table locks across cpu packages (at least,
> that's my theory).  My "current" system is a dual Xeon 5160
> (woodcrest).  It has a relatively low-speed FSB and passing memory
> from core-to-core seems to suck at high packet rates.
> </background>
> 
> I'm now testing a dual-package Nehalem system.  If I understand this
> architecture correctly, each package's memory controller is driving
> its own bank of RAM.  In my ideal world, I'd be able to provide a hint
> to kmalloc (or friends) such that my encode-table is stored close to
> one package and my decode-table is stored close to the other package.
> Is this something that I can control?  If so, how?  

You can use kmalloc_node() to allocate on a specific node--if you encode
table is, indeed, dynamically allocated.  

> Does this matter
> with Intel's QPI or am I wasting my time?

I recently ran a numademo [from the numactl source package] test on a
2-node [== 2 socket], 2.93GHz Nehalem and saw this:

nelly:~ # taskset -c 0 numademo 256m    # run on cpu/node 0, 256M test buffer
2 nodes available
memory on node 0 memset                   Avg 6744.42 MB/s Max 6751.22 MB/s Min 6734.46 MB/s
memory on node 1 memset                   Avg 3900.29 MB/s Max 3904.86 MB/s Min 3890.31 MB/s
# remote = ~0.58 of local bandwidth

nelly:~ # taskset -c 1 numademo 256m    # run on cpu/node 1, 256M test buffer
2 nodes available
memory on node 0 memset                   Avg 3909.94 MB/s Max 3912.54 MB/s Min 3906.96 MB/s
memory on node 1 memset                   Avg 6668.64 MB/s Max 6677.33 MB/s Min 6657.96 MB/s
# remote = ~0.59 of local bandwidth

So, it's probably worth trying and measuring your results.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
