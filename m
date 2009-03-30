Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A913C6B003D
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 20:00:31 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 0/4] ksm - dynamic page sharing driver for linux
Date: Tue, 31 Mar 2009 02:59:16 +0300
Message-Id: <1238457560-7613-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

KSM is a linux driver that allows dynamicly sharing identical memory
pages between one or more processes.

Unlike tradtional page sharing that is made at the allocation of the
memory, ksm do it dynamicly after the memory was created.
Memory is periodically scanned; identical pages are identified and
merged.
The sharing is unnoticeable by the process that use this memory.
(the shared pages are marked as readonly, and in case of write
do_wp_page() take care to create new copy of the page)

To find identical pages ksm use algorithm that is split into three
primery levels:

1) Ksm will start scan the memory and will calculate checksum for each
   page that is registred to be scanned.
   (In the first round of the scanning, ksm would only calculate
    this checksum for all the pages)

2) Ksm will go again on the whole memory and will recalculate the
   checmsum of the pages, pages that are found to have the same
   checksum value, would be considered "pages that are most likely
   wont changed"
   Ksm will insert this pages into sorted by page content RB-tree that
   is called "unstable tree", the reason that this tree is called
   unstable is due to the fact that the page contents might changed
   while they are still inside the tree, and therefore the tree would
   become corrupted.
   Due to this problem ksm take two more steps in addition to the
   checksum calculation:
   a) Ksm will throw and recreate the entire unstable tree each round
      of memory scanning - so if we have corruption, it will be fixed
      when we will rebuild the tree.
   b) Ksm is using RB-tree, that its balancing is made by the node color
      and not by the content, so even if the page get corrupted, it still
      would take the same amount of time to search on it.

3) In addition to the unstable tree, ksm hold another tree that is called
   "stable tree" - this tree is RB-tree that is sorted by the pages
   content and all its pages are write protected, and therefore it cant get
   corrupted.
   Each time ksm will find two identcial pages using the unstable tree,
   it will create new write-protected shared page, and this page will be
   inserted into the stable tree, and would be saved there, the
   stable tree, unlike the unstable tree, is never throwen away, so each
   page that we find would be saved inside it.

Taking into account the three levels that described above, the algorithm
work like that:

search primary tree (sorted by entire page contents, pages write protected)
- if match found, merge
- if no match found...
  - search secondary tree (sorted by entire page contents, pages not write
    protected)
    - if match found, merge
      - remove from secondary tree and insert merged page into primary tree
    - if no match found...
      - checksum
        - if checksum hasn't changed
	  - insert into secondary tree
	- if it has, store updated checksum (note: first time this page
	  is handled it won't have a checksum, so checksum will appear
	  as "changed", so it takes two passes w/ no other matches to
	  get into secondary tree)
	  - do not insert into any tree, will see it again on next pass

The basic idea of this algorithm, is that even if the unstable tree doesnt
promise to us to find two identical pages in the first round, we would
probably find them in the second or the third or the tenth round,
then after we have found this two identical pages only once, we will insert
them into the stable tree, and then they would be protected there forever.
So the all idea of the unstable tree, is just to build the stable tree and
then we will find the identical pages using it.

The current implemantion can be improved alot:
we dont have to calculate exspensive checksum, we can just use the host
dirty bit.

currently we dont support shared pages swapping (other pages that are not
shared can be swapped (all the pages that we didnt find to be identical
to other pages...).

Walking on the tree, we keep call to get_user_pages(), we can optimized it
by saving the pfn, and using mmu notifiers to know when the virtual address
mapping was changed.

We currently scan just programs that were registred to be used by ksm, we
would later want to add the abilaty to tell ksm to scan PIDS (so you can
scan closed binary applications as well).

Right now ksm scanning is made by just one thread, multiple scanners
support might would be needed.

This driver is very useful for KVM as in cases of runing multiple guests
operation system of the same type.
(For desktop work loads we have achived more than x2 memory overcommit
(more like x3))

This driver have found users other than KVM, for example CERN,
Fons Rademakers:
"on many-core machines we run one large detector simulation program per core.
These simulation programs are identical but run each in their own process and
need about 2 - 2.5 GB RAM.
We typically buy machines with 2GB RAM per core and so have a problem to run
one of these programs per core.
Of the 2 - 2.5 GB about 700MB is identical data in the form of magnetic field
maps, detector geometry, etc.
Currently people have been trying to start one program, initialize the geometry
and field maps and then fork it N times, to have the data shared.
With KSM this would be done automatically by the system so it sounded extremely
attractive when Andrea presented it."

I am sending another seires of patchs for kvm kernel and kvm-userspace
that would allow users of kvm to test ksm with it.
The kvm patchs would apply to Avi git tree.

Izik Eidus (4):
  MMU_NOTIFIERS: add set_pte_at_notify()
  add page_wrprotect(): write protecting page.
  add replace_page(): change the page pte is pointing to.
  add ksm kernel shared memory driver.

 include/linux/ksm.h          |   69 ++
 include/linux/miscdevice.h   |    1 +
 include/linux/mm.h           |    5 +
 include/linux/mmu_notifier.h |   34 +
 include/linux/rmap.h         |   11 +
 mm/Kconfig                   |    6 +
 mm/Makefile                  |    1 +
 mm/ksm.c                     | 1431 ++++++++++++++++++++++++++++++++++++++++++
 mm/memory.c                  |   90 +++-
 mm/mmu_notifier.c            |   20 +
 mm/rmap.c                    |  139 ++++
 11 files changed, 1805 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/ksm.h
 create mode 100644 mm/ksm.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
