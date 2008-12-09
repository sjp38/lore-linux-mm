Subject: Question:  mmotm-081207 - Should i_mmap_writable go negative?
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Tue, 09 Dec 2008 15:47:46 -0500
Message-Id: <1228855666.6379.84.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I've been trying to figure out how to determine when the last shared
mapping [vma with VM_SHARED] is removed from a mmap()ed file.  Looking
at the sources, it appears that vma->vm_file->f_mapping->i_mmap_writable
counts the number of vmas with VM_SHARED mapping the file.  However, in
2.6.28-rc7-mmotm-081207, it appears that i_mmap_writable doesn't get
incremented when a task fork()s, and can go negative when the parent and
child both unmap the file.

I instrumented a couple of functions in mmap.c that increment and
decrement i_mmap_writable and then mapped a file sharable, fork(), and
unmapped the file in the parent and child, using my memtoy ad hoc test
program.  Here's what I see [again, on 2.6.28-rc7-mmotm-081207]--right
after boot, so my test file should have zero mappers:

--------

root@dropout(root):memtoy
memtoy pid:  3301
memtoy>file /tmp/zf1
memtoy>map zf1 shared

console:__vma_link_file:  vma: ffff8803fdc090b8 - mapping->i_mmap_writable: 0 -> 1

memtoy>child c1
memtoy:  child c1 - pid 3302

me: I would have expected to see i_mmap_writable incremented again here, but
me: saw no console output from my instrumentation.

memtoy>unmap zf1	# unmap in parent

console:__remove_shared_vm_struct:  vma: ffff8803fdc090b8 - mapping->i_mmap_writable: 1 -> 0
console:__remove_shared_vm_struct:  vma: ffff8803fdc090b8 - removed last shared mapping

memtoy>/c1 show
  _____address______ ____length____ ____offset____ prot  share  name
f 0x00007f000ae68000 0x000001000000 0x000000000000  rw- shared  /tmp/zf1

me:  child still has zf1 mapped

memtoy>/c1 unmap zf1	# unmap in child

console:__remove_shared_vm_struct:  vma: ffff8803fe5d3170 - mapping->i_mmap_writable: 0 -> -1

--------

So, the file's i_mmap_writable goes negative.  Is this expected?

If I remap the file, whether or not I restart memtoy, I see that it's
i_mmap_writable has remained negative:

-------
memtoy>map zf1		# map private [!shared] - no change in i_mmap_writable

console:__vma_link_file:  vma: ffff8805fd0590b8 - mapping->i_mmap_writable: -1 -> -1

memtoy>unmap zf1	# unmap:  no change in i_mmap_writable

console:__remove_shared_vm_struct:  vma: ffff8805fd0590b8 - mapping->i_mmap_writable: -1 -> -1

memtoy>map zf1 shared	# mmap shared, again

console:__vma_link_file:  vma: ffff8805fd0590b8 - mapping->i_mmap_writable: -1 -> 0

--------

I recall that this used to work [as I expected] at one time.

Lee




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
