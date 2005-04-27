Date: Tue, 26 Apr 2005 23:41:39 -0700
From: Chris Wright <chrisw@osdl.org>
Subject: Re: rlimit_as-checking-fix.patch
Message-ID: <20050427064139.GO493@shell0.pdx.osdl.net>
References: <20050425195556.092d0579.akpm@osdl.org> <20050426230050.3bcffe8a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050426230050.3bcffe8a.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hugh@veritas.com, chrisw@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrew Morton (akpm@osdl.org) wrote:
> Andrew Morton <akpm@osdl.org> wrote:
> >
> > review, please?
> 
> crappy reviewers.  Tested version.

Sorry to be so slow on that one.  Here's an update for the mlock part.
It's only compile tested as of yet.




Always use page counts when doing RLIMIT_MEMLOCK checking to avoid
possible overflow.

Signed-off-by: Chris Wright <chrisw@osdl.org>
---

mm/mmap.c: 6ea204cc751e4d2f0fe4a7d213bab9ae90ad58c4
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -937,9 +937,10 @@ unsigned long do_mmap_pgoff(struct file 
 	/* mlock MCL_FUTURE? */
 	if (vm_flags & VM_LOCKED) {
 		unsigned long locked, lock_limit;
-		locked = mm->locked_vm << PAGE_SHIFT;
+		locked = len >> PAGE_SHIFT;
+		locked += mm->locked_vm;
 		lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
-		locked += len;
+		lock_limit >>= PAGE_SHIFT;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
 			return -EAGAIN;
 	}
@@ -1823,9 +1824,10 @@ unsigned long do_brk(unsigned long addr,
 	 */
 	if (mm->def_flags & VM_LOCKED) {
 		unsigned long locked, lock_limit;
-		locked = mm->locked_vm << PAGE_SHIFT;
+		locked = len >> PAGE_SHIFT;
+		locked += mm->locked_vm;
 		lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
-		locked += len;
+		lock_limit >>= PAGE_SHIFT;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
 			return -EAGAIN;
 	}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
