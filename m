Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4CE986B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 12:15:01 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so430223wfa.11
        for <linux-mm@kvack.org>; Tue, 28 Apr 2009 09:15:14 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 28 Apr 2009 09:15:14 -0700
Message-ID: <606676310904280915i3161fc90h367218482b19bbd6@mail.gmail.com>
Subject: Memory/CPU affinity and Nehalem/QPI
From: Andrew Dickinson <andrew@whydna.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Howdy linux-mm,

<background>
I'm working on a kernel module which does some packet mangling based
on the results of a memory lookup;  a packet comes in, I do a table
lookup and if there's a match, I mangle the packet.  This process is
2-way; I encode in one direction and decode in the other.  I've found
that I get better performance of I pin the interrupts of the 2 NICs in
my system to different cores; I match the rx IRQs on one NIC and the
tx IRQs on the other NIC to one set of cores and the other rx/tx pairs
to another set of cores.  The reason for the IRQ pinning is that I
spend less time passing table locks across cpu packages (at least,
that's my theory).  My "current" system is a dual Xeon 5160
(woodcrest).  It has a relatively low-speed FSB and passing memory
from core-to-core seems to suck at high packet rates.
</background>

I'm now testing a dual-package Nehalem system.  If I understand this
architecture correctly, each package's memory controller is driving
its own bank of RAM.  In my ideal world, I'd be able to provide a hint
to kmalloc (or friends) such that my encode-table is stored close to
one package and my decode-table is stored close to the other package.
Is this something that I can control?  If so, how?  Does this matter
with Intel's QPI or am I wasting my time?

-Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
