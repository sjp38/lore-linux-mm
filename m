Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA26926
	for <Linux-MM@kvack.org>; Mon, 17 May 1999 00:48:22 -0400
Date: Sun, 16 May 1999 21:48:03 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] kanoj-mm2.0-2.2.9 unneccesary page force in by munlock
In-Reply-To: <199905170402.VAA25069@google.engr.sgi.com>
Message-ID: <Pine.LNX.3.95.990516214528.4550B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Linux-MM@kvack.org, number6@the-village.bc.nu
List-ID: <linux-mm.kvack.org>


On Sun, 16 May 1999, Kanoj Sarcar wrote:
>
> While looking at the code for munlock() in mm/mlock.c, I found
> that munlock() unneccesarily executes a code path that forces
> page fault in over the entire range. The following patch fixes 
> this problem:

Well, it shouldn't force a page-fault, as the code is only executed if the
lockedness changes - and if it is a unlock then it will have been locked
before, so all the pages will have been present, and as such we wouldn't
actually need to fault them in.

I agree that it is certainly unnecessary, though, and pollutes TLB's etc
for no good reason.

How about this diff instead, avoiding the if-then-else setup?

		Linus

-----
--- v2.3.2/linux/mm/mlock.c	Fri Nov 20 11:43:19 1998
+++ linux/mm/mlock.c	Sun May 16 21:45:23 1999
@@ -115,10 +115,11 @@
 	if (!retval) {
 		/* keep track of amount of locked VM */
 		pages = (end - start) >> PAGE_SHIFT;
-		if (!(newflags & VM_LOCKED))
+		if (newflags & VM_LOCKED) {
 			pages = -pages;
-		vma->vm_mm->locked_vm += pages;
-		make_pages_present(start, end);
+			make_pages_present(start, end);
+		}
+		vma->vm_mm->locked_vm -= pages;
 	}
 	return retval;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
