Received: from f03n05e.au.ibm.com
	by ausmtp01.au.ibm.com (IBM AP 1.0) with ESMTP id BAA33680
	for <linux-mm@kvack.org>; Fri, 3 Nov 2000 01:20:52 +1100
From: bsuparna@in.ibm.com
Message-ID: <CA25698B.004FD156.00@d73mta05.au.ibm.com>
Date: Thu, 2 Nov 2000 19:57:53 +0530
Subject: Memory mgmt lock hierarchy related concerns
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: dprobes@oss.software.ibm.com
List-ID: <linux-mm.kvack.org>

We are trying to fix a race that exists in our current Dprobes code, in our
handling of probes on copy-on-write pages. In short, the objective is to be
able to detect all copy-on-write pages corresponding to a particular
<inode, offset>, so that we can insert our probes in those pages too. To do
this, we:
     Traverse the inode's address space mappings to locate the vmas mapped
to that inode and for each vma
     we use the vma offset field to figure out what address the required
offset (point) would map to, and look up
     the pte to get the actual page, and if check if that is a COW page.

I'm still in the process of finding out the best way to close all the races
in this, but I ran into an issue on the correct memory locking hierarchies
in Linux, which I wanted to put across.

I sincerly hope that I'm not repeating a question that has already been
answered here.
[I'm not subscribed to this mailing list yet, so do send me a reply at my
e-mail id, bsuparna@in.ibm.com]

Some of the relevant mem mgmt locks (for us) as I understand are (talking
of only 2.4 for now):
     address space mapping spin lock :   mapping->i_shared_lock:
          protects the i_mmap list for the inode's address space (we need
to acquire this
          to traverse the list of vma's mapped to the inode for the module)

     vma list lock:      vmlist_access/modify_lock
          protects the vma list in the mm, namely addition/removal of vma's
for the mm (we need to
          take either this lock or the mm->mmap_sem if we want to be sure
that the vma won't go away)
          [Note: Implementation-wise, this is the same as
mm->page_table_lock]

     page table lock:    mm->page_table_lock
          protects the page table entries for an mm (we might need to take
this when we are looking at or
          manipulating pte's)
Reference count that we may need to manipulate:
     page reference count:    page->count
          holding this ensures that a page doesn't go away underneath us -
it is updated and checked under
          the page_cache_lock (routine get_page).


Now, comes my concern in terms of locking hierarchies:

The vma list lock  can nest with i_shared_lock, as per the documentation.
But there is some confusion on
the correct hierarchy. Looking at mmap code, it appears that the vma list
lock or page_table_lock
is to be acquired first (e.g insert_vm_struct which acquires i_shared_lock
internally, is called under
the page_table/vma list lock). In the unmap code, care has been taken not
to have these locks acquired
simultaneously. Elsewhere in madvise too, I see a similar hierachy.

However, in the vmtruncate code, it looks like the hierarchy is reversed.
There, the i_shared_lock is
acquired, in order to traverse the i_mmap list (much like we need to do),
and inside the loop it calls
zap_page_range, which aquires the page_table_lock.

This is odd. Isn't there a possibility of a deadlock if mmap and truncation
for the same file happen
simultaneously (on an SMP) ?
Or have I missed something ?
(Could this be a side effect of the doubling up of the page_table_lock as a
vma list lock ? )

[I have checked upto  2.4-test10 ]

What is the correct hierarchy that we should be following ?

Regards
Suparna


  Suparna Bhattacharya
  Systems Software Group, IBM Global Services, India
  E-mail : bsuparna@in.ibm.com
  Phone : 91-80-5267117, Extn : 2525



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
