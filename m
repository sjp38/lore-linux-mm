Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id MAA07543
	for <linux-mm@kvack.org>; Tue, 12 Nov 2002 12:27:27 -0800 (PST)
Message-ID: <3DD1642A.4A7C663C@digeo.com>
Date: Tue, 12 Nov 2002 12:27:22 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: get_user_pages rewrite rediffed against 2.5.47-mm1
References: <20021112205848.B5263@nightmaster.csn.tu-chemnitz.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Oeser wrote:
> 
> Hi Andrew,
> 
> the get_user_pages rewrite has been rediffed against 2.5.47-mm1

The single diff helps, thanks.

I'm still having indigestion over this:

+/*** Page walking API ***/
+
+/* &custom_page_walker - A custom page walk handler for walk_user_pages().
+ * vma:         The vma we walk pages of.
+ * page:        The page we found or an %ERR_PTR() value
+ * virt_addr:   The virtual address we are at while walking.
+ * customdata:  Anything you would like to pass additionally.
+ *
+ * Returns:
+ *      Negative values -> ERRNO values.
+ *      0               -> continue page walking.
+ *      1               -> abort page walking.
+ *
+ * If this functions gets a page, for which %IS_ERR(@page) is true, than it
+ * should do it's cleanup of customdata and return -PTR_ERR(@page).
+ *
+ * If IS_ERR(@page) is NOT TRUE, this function is called with
+ * @vma->vm_mm->page_table_lock held. 
+ *
+ * The value of @vma is undefined if IS_ERR(@page) is TRUE.
+ * (So never use or check it if IS_ERR(@page) is TRUE)
+ *
+ * If it returns a negative value but got a valid page, then the
+ * page_table_lock must be dropped by this function. (This condition should be
+ * rather rare.)
+ */
+typedef int (*custom_page_walker_t)(struct vm_area_struct *vma, 
+		struct page *page, unsigned long virt_addr, void *customdata);
+

I think I see what you're doing now.  You've overloaded the callback,
with an IS_ERR value of "page" to mean "something went wrong".

Would that be a correct interpretation?

If so, it would be better (ie: more Linus-friendly) to make that a
separate callback.  One which is called outside the lock, and which
has distinctly different semantics from the normal page walker.

Some (all?) callers of walk_user_pages() may not even be interested
in the error-time callout.  In fact it may be possible to just leave
the state at time-of-error in the state structure (see below) and just
return an error code to the caller of walk_user_pages()?

I suggest that it's time to fold all these arguments into a structure
which is on the caller's stack, and pass the address of that around.
This will simplify things, but one needs to be careful to think through
the ownership rules of the various parts of that structure.

Please review your ERR_PTR handling.  You have lots of these:

+               return ERR_PTR(EFAULT);

which are all wrong.  It needs to be `ERR_PTR(-EFAULT)'.  (editing
the diff is the easy fix ;))

When you do the above, this becomes wrong too:

	return -PTR_ERR(page);

So please check all those too.

Also, please rip everything which is appropriate out of mm/memory.c
and create a new file in mm/ for it.


I cannot guarantee that we can get this merged up, frankly.  We need
a *reason* for doing that.  The current code is "good enough" for
current callers.  So the best I can do is to get it under test, give
Linus a heads-up that it's floating about while you get in there and
start creating reasons for merging it - namely the clients down in
device drivers.

If we don't make it then we can definitely push it for 2.7.

How does that suit?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
