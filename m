Received: from pneumatic-tube.sgi.com (pneumatic-tube.sgi.com [204.94.214.22])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA26455
	for <Linux-MM@kvack.org>; Mon, 17 May 1999 00:03:03 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199905170402.VAA25069@google.engr.sgi.com>
Subject: [PATCH] kanoj-mm2.0-2.2.9 unneccesary page force in by munlock
Date: Sun, 16 May 1999 21:02:04 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linux-MM@kvack.org
Cc: torvalds@transmeta.com, number6@the-village.bc.nu
List-ID: <linux-mm.kvack.org>

While looking at the code for munlock() in mm/mlock.c, I found
that munlock() unneccesarily executes a code path that forces
page fault in over the entire range. The following patch fixes 
this problem:

--- /usr/tmp/p_rdiff_a007Qs/mlock.c     Sun May 16 20:48:12 1999
+++ mm/mlock.c  Sun May 16 20:47:01 1999
@@ -117,8 +117,9 @@
                pages = (end - start) >> PAGE_SHIFT;
                if (!(newflags & VM_LOCKED))
                        pages = -pages;
+               else
+                       make_pages_present(start, end);
                vma->vm_mm->locked_vm += pages;
-               make_pages_present(start, end);
        }
        return retval;
 }

Please review and include in the source.

Thanks.

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
