Received: from sgi.com (sgi.SGI.COM [192.48.153.1])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA19691
	for <Linux-MM@kvack.org>; Wed, 19 May 1999 00:21:51 -0400
Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by sgi.com (980327.SGI.8.8.8-aspam/980304.SGI-aspam:
       SGI does not authorize the use of its proprietary
       systems or networks for unsolicited or bulk email
       from the Internet.)
	via ESMTP id VAA04085
	for <@external-mail-relay.sgi.com:Linux-MM@kvack.org>; Tue, 18 May 1999 21:21:34 -0700 (PDT)
	mail_from (kanoj@google.engr.sgi.com)
Received: from google.engr.sgi.com (google.engr.sgi.com [192.48.174.30])
	by cthulhu.engr.sgi.com (980427.SGI.8.8.8/970903.SGI.AUTOCF)
	via ESMTP id VAA37848
	for <@cthulhu.engr.sgi.com:Linux-MM@kvack.org>;
	Tue, 18 May 1999 21:21:34 -0700 (PDT)
	mail_from (kanoj@google.engr.sgi.com)
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199905190421.VAA90249@google.engr.sgi.com>
Subject: [RFC] PATCH: kanoj-mm3.0-2.2.9 shave exit/exec cycles from clear_page_tables
Date: Tue, 18 May 1999 21:21:32 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Whenever the exit and exec paths invoke clear_page_tables, clear_page_tables
has to validate that the input mm does not have a null pgd, or that the pgd
is not the swapper_pg_dir. This small patch obviates the need to do that, 
thereby shaving some cpu cycles off these very common paths.

Note that I am not 100% sure whether I missed some issues, hence I am flagging
this patch with Request for Comment. In case some reviewer can demonstrate that
applying the patch will make Linux behave differently in certain circumstances,
we might need to see whether the difference is acceptable against reduced cpu
cycles.

Here's the rationale for the patch: we need to determine whether any code path
leading into clear_page_tables can have pgd==0 or pgd==swapper_pg_dir. Note that
init_mm can never have its count go to 0, with the kernel_threads around.

Lets analyze the callers of clear_page_tables. The easy case to eliminate is
free_pgtables out of do_munmap. The other caller of clear_page_tables is 
exit_mmap. exit_mmap is called from exec_mmap and from mmput. The exec_mmap 
case is trivially eliminated too. That leaves all the callers of mmput. Those 
would be:

1. out of the success path from exec_mmap in CLONE_VM case
        mm->pgd can not be 0, if it is swapper_pg_dir, the mmput() can not get
        its count down to 0, hence clear_page_tables will not be invoked.
2. out of the failure path from exec_mmap in CLONE_VM case
3. out of the failure path from copy_mm in non CLONE_VM case
        both of these paths have been changed in the patch so that a complete
        mmput is not needed, rather a release_segments/kmem_cache_free is done
        on the mm. In fact, these two procedures can be combined into a mmfree()
        procedure call.
4. __exit_mm
        callers are do_exit and exit_mm, this only invokes mmput ->
	free_page_tables if the input task has an mm != init_mm. I can't see 
	how in either case, tsk->mm->pgd can be 0 or swapper_pg_dir (not even 
	if an interrupt handler erroneously invokes do_exit, for which there 
	is an explicit check in do_exit).

Finally, here's the patch:

--- /usr/tmp/p_rdiff_a00BlY/exec.c      Tue May 18 20:47:31 1999
+++ kern/fs/exec.c      Tue May 18 20:27:54 1999
@@ -415,12 +415,11 @@
         * Failure ... restore the prior mm_struct.
         */
 fail_restore:
-       /* The pgd belongs to the parent ... don't free it! */
-       mm->pgd = NULL;
        current->mm = old_mm;
        /* restore the ldt for this task */
        copy_segments(nr, current, NULL);
-       mmput(mm);
+       release_segments(mm);
+       kmem_cache_free(mm_cachep, mm);

 fail_nomem:
        return retval;
--- /usr/tmp/p_rdiff_a00BkT/fork.c      Tue May 18 20:47:43 1999
+++ kern/kernel/fork.c  Tue May 18 20:26:50 1999
@@ -390,7 +390,10 @@
        return 0;

 free_mm:
-       mm->pgd = NULL;
+       tsk->mm = NULL;
+       release_segments(mm);
+       kmem_cache_free(mm_cachep, mm);
+       return retval;
 free_pt:
        tsk->mm = NULL;
        mmput(mm);
--- /usr/tmp/p_rdiff_a00BXt/memory.c    Tue May 18 20:47:56 1999
+++ kern/mm/memory.c    Tue May 18 20:09:57 1999
@@ -130,16 +130,14 @@
 {
        pgd_t * page_dir = mm->pgd;

-       if (page_dir && page_dir != swapper_pg_dir) {
-               page_dir += first;
-               do {
-                       free_one_pgd(page_dir);
-                       page_dir++;
-               } while (--nr);
+       page_dir += first;
+       do {
+               free_one_pgd(page_dir);
+               page_dir++;
+       } while (--nr);

-               /* keep the page table cache within bounds */
-               check_pgt_cache();
-       }
+       /* keep the page table cache within bounds */
+       check_pgt_cache();
 }

 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
