Date: Mon, 15 Jan 2007 21:47:43 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 0/8] Cpuset aware writeback
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Currently cpusets are not able to do proper writeback since
dirty ratio calculations and writeback are all done for the system
as a whole. This may result in a large percentage of a cpuset
to become dirty without writeout being triggered. Under NFS
this can lead to OOM conditions.

Writeback will occur during the LRU scans. But such writeout
is not effective since we write page by page and not in inode page
order (regular writeback).

In order to fix the problem we first of all introduce a method to
establish a map of nodes that contain dirty pages for each
inode mapping.

Secondly we modify the dirty limit calculation to be based
on the acctive cpuset.

If we are in a cpuset then we select only inodes for writeback
that have pages on the nodes of the cpuset.

After we have the cpuset throttling in place we can then make
further fixups:

A. We can do inode based writeout from direct reclaim
   avoiding single page writes to the filesystem.

B. We add a new counter NR_UNRECLAIMABLE that is subtracted
   from the available pages in a node. This allows us to
   accurately calculate the dirty ratio even if large portions
   of the node have been allocated for huge pages or for
   slab pages.

There are a couple of points where some better ideas could be used:

1. The nodemask expands the inode structure significantly if the
architecture allows a high number of nodes. This is only an issue
for IA64. For that platform we expand the inode structure by 128 byte
(to support 1024 nodes). The last patch attempts to address the issue
by using the knowledge about the maximum possible number of nodes
determined on bootup to shrink the nodemask.

2. The calculation of the per cpuset limits can require looping
over a number of nodes which may bring the performance of get_dirty_limits
near pre 2.6.18 performance (before the introduction of the ZVC counters)
(only for cpuset based limit calculation). There is no way of keeping these
counters per cpuset since cpusets may overlap.

Paul probably needs to go through this and may want additional fixes to
keep things in harmony with cpusets.

Tested on:
IA64 NUMA 128p, 12p

Compiles on:
i386 SMP
x86_64 UP


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
