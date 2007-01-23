Date: Tue, 23 Jan 2007 10:52:43 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070123185242.2640.8367.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 0/5] Cpuset aware writeback V2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Currently cpusets are not able to do proper writeback since dirty ratio
calculations and writeback are all done for the system as a whole. This
may result in a large percentage of the nodes in a cpuset to become dirty
without background writeout being triggered and without synchrononous
writes occurring. Instead writeout occurs during reclaim when memory
is tight which may lead to dicey VM situations.

In order to fix the problem we first of all introduce a method to establish
a map of dirty nodes for each struct address_space.

Secondly, we modify the dirty limit calculation to be based on the current
state of memory on the nodes of the cpuset that the current tasks belongs to.

If the current tasks is part of a cpuset that is not allowed to allocate
from all nodes in the system then we select only inodes for writeback
that have pages on the nodes that we are allowed to allocate from.

Changelog: V1->V2
-----------------
- Remove stray diff chunk and general patch beautification

- Put do { } while (0) around cpuset_update_dirty_nodes macro since it
  contains and if()

- Update comments to clarify locking scheme for dirty node maps.

- Retest and verify compile on UP.

Changelog: RFC->V1
------------------

- Rework dirty_map logic to allocate it dynamically on larger
  NUMA systems. Move to struct address_space and address various minor issues.

- Dynamically allocate dirty maps only if an inode is dirtied.

- Clear the dirty map only when an inode is cleared (simplifies
  locking and we need to keep the dirty state even after the dirty state of
  all pages has be cleared for NFS writeout to occur correctly).

- Drop nr_node_ids patches

- Drop the NR_UNRECLAIMABLE patch. There may be other ideas around on how
  to accomplish the same in a more elegant way.

- Drop mentioning the NFS issues since Peter is working on those.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
