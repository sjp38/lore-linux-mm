From: Paul Mackerras <paulus@samba.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15757.18495.802801.215286@argo.ozlabs.ibm.com>
Date: Sun, 22 Sep 2002 14:34:07 +1000 (EST)
Subject: Bug in sys_mprotect
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hch@infradead.org, torvalds@transmeta.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

There is a bug in sys_mprotect in the current 2.5 kernel where it can
dereference `prev' when it is NULL.  After the main loop we have the
statement (line 284):

	if (next && prev->vm_end == next->vm_start &&
			can_vma_merge(next, prev->vm_flags) &&
			!prev->vm_file && !(prev->vm_flags & VM_SHARED)) {

If you mprotect a region which is in the first VMA, the find_vma_prev
call (line 236) will set prev = NULL, and it is possible to get
through the main loop without changing prev.  When this happens, we
get a NULL dereference and the process then hangs at the down_read in
do_page_fault since sys_mprotect has downed the mm->mmap_sem for
writing.

This bites badly on PPC since ld.so maps the shared libraries below
the main executable, and uses mprotect on the regions it has mapped.
Consequently, init hangs with no visible indication of what is wrong.

Anyway, looking at the old mprotect code, it is clear that all of
mprotect_fixup_{start,middle,end,all} set *pprev to something non-NULL
(unless an error occurs).  The new mprotect_fixup doesn't do this.
It's not clear to me what the old code set *pprev to.  I thought it
was the VMA which now comes immediately before the VMA which came
after the original VMA before we split it, but mprotect_fixup_start
and mprotect_fixup_end don't seem to set it this way.  Some comments
in the code would have been helpful.

For now I have changed the if statement at line 284 to test prev !=
NULL as well as the existing conditions, and that works, but I don't
think it fixes the real problem.  Perhaps someone who knows exactly
what prev is supposed to be can post a proper fix.

Paul.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
