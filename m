Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DBA8C6B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:31:11 -0500 (EST)
Date: Tue, 18 Jan 2011 10:31:05 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: [LSF/MM TOPIC] Per cpu atomic operations and some ideas for faster
 synchronization
Message-ID: <alpine.DEB.2.00.1101181013340.15278@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: lsf-pc@lists.linuxfoundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Synchronization is typically based on mechanisms to obtain exclusive
ownership of cachelines that are used for global serialization of events
between many processors. The overhead of the resulting cacheline bounces
and the corresponding long wait times to acquire a lock to perform any
synchronization increases as the number of processors on a system
increases.

The locking overhead is now often been reduced using several existing
techniques such as RCU and seqlocks.

There is an additional technique that was recently introduced which allows
using per cpu data to parallelize processing between multiple processors.
All processor own their data exclusively and operations refers to local
data.

In order to make these accesses more effective we recently introduces the
this_cpu_xxx operations. These macros allow relocation of accesses
relative to the current per processor area with negligible cost since the
implementation uses a segment prefix to perform the relocation.

Performing transactions on per cpu data has its own challenges since
preemption and interrupts can cause processor changes or additional per
cpu operations that can cause difficulties if a series of operations must
occur in an atomic fashion. Disabling preemption and interrupts is
expensive and therefore the this_cpu_ ops introduce per atomic operation
analoguous to full atomic operations that operate on per cpu data an
guarantee that operations are atomic vs. interrupts and preemption (as
well as sometimes vs. NMI). These operations are significantly less
expensive than fully atomic operations that must use a LOCK prefix and
globally serialize access.

There is also a new (full and per cpu) atomic operation: cmpxchg_double()
which allows to extend the cmpxchg to two words. Two words allow to keep
more state in lockless algorithms (f.e. one can version a pointer, or
store the size of a list in addition to a pointer to a linked list).

I would like to discuss these ideas and the various usage scenarios to get
some more ideas on how to further refine these mechanisms and make them
more useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
