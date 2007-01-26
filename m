Date: Thu, 25 Jan 2007 21:41:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070126054153.10564.43218.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 0/8] Use ZVCs for accurate writeback ratio determination
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Nikita Danilov <nikita@clusterfs.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

The determination of the dirty ratio to determine writeback behavior
is currently based on the number of total pages on the system.

However, not all pages in the system may be dirtied. Thus the ratio
is always too low and can never reach 100%. The ratio may be
particularly skewed if large hugepage allocations, slab allocations
or device driver buffers make large sections of memory not available
anymore. In that case we may get into a situation in which f.e. the
background writeback ratio of 40% cannot be reached anymore which
leads to undesired writeback behavior.

This patchset fixes that issue by determining the ratio based
on the actual pages that may potentially be dirty. These are
the pages on the active and the inactive list plus free pages.

The problem with those counts has so far been that it is expensive
to calculate these because counts from multiple nodes and multiple
zones will have to be summed up. This patchset makes these counters
ZVC counters. This means that a current sum per zone, per node and
for the whole system is always available via global variables
and not expensive anymore to calculate.

The patchset results in some other good side effects:

- Removal of the various functions that sum up free, active
  and inactive page counts

- Cleanup of the functions that display information via the
  proc filesystem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
