Subject: Re: Oops in __free_pages_ok (pre7-1) (Long)
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 02 May 2000 03:08:02 +0200
In-Reply-To: "Juan J. Quintela"'s message of "02 May 2000 01:29:26 +0200"
Message-ID: <yttg0s13gjx.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Hi
        several people have reported Oops in __free_pages_ok, after a
BUG() in page_alloc.h.  This happens in 2.3.99-pre[67].  The BUGs are:

	if (page->mapping)
		BUG();
and
	if (PageSwapCache(page))
		BUG();
somebody reported to me that he obtained the BUG:
	if (PageLocked(page))
		BUG();

I have found that this patch solves the Oops for me. (I know that this
is not the proper solution, could people test this patch and mail me
if the Oops disappear/or go worst?  I am trying to isolate the
problem.  Now I get one kill of the process from the VM, I am
interested to know if this is the case for the rest of the people with
this problem.

I have read the comments from Andrea in this list about that
PG_swap_entry bit should be only a optimization, never produce
instability.  I have checked that with the following patch (i.e. the
only place when we set that bit) I don't get more Oops.

This bit is only used in three places in the kernel:

mm/memory.c:1056:do_swap_page()::SetPageSwapEntry(page);
        The only place where it is set

mm/swapfile.c:210:acquire_swap_entry():	if (!PageSwapEntry(page))
        Here we check if it is set, and if true, we check that the
        values are valid.

mm/swap_state.c:134:	ClearPageSwapEntry(page);
        We clear the bit in free_page_and_swap_cache(), but I am not
        sure that it is the only place when it must be deleted.
        Comments really appreciated.

It appears that we forgot to remove some bits/values when we free a
page. It has been several patches in this list regarding the
swap_entry bit, but not agreement in which is the correct one.

I hope this help to somebody understand where is the problem, or at
least give me some hint where can be the problem.

Thanks in advance, Juan.

diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* pre7-1plus/mm/memory.c lin
ux/mm/memory.c
--- pre7-1plus/mm/memory.c      Tue Apr 25 00:46:18 2000
+++ linux/mm/memory.c   Tue May  2 00:36:13 2000
@@ -1053,7 +1053,7 @@
 
        pte = mk_pte(page, vma->vm_page_prot);
 
-       SetPageSwapEntry(page);
+       /*      SetPageSwapEntry(page);  */
 
        /*
         * Freeze the "shared"ness of the page, ie page_count + swap_count.


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
