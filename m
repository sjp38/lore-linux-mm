Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA09166
	for <Linux-MM@kvack.org>; Thu, 22 Apr 1999 11:30:36 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14111.16505.189611.184633@dukat.scot.redhat.com>
Date: Thu, 22 Apr 1999 16:30:01 +0100 (BST)
Subject: Patch: Re: boundary condition bug fix for vmalloc()
In-Reply-To: <199904220012.RAA57724@google.engr.sgi.com>
References: <199904220012.RAA57724@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <number6@the-village.bc.nu>
Cc: Linux-MM@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 21 Apr 1999 17:12:37 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> Under heavy load conditions, get_vm_area() might end up allocating an
> address range beyond VMALLOC_END. The problem is after the for loop in
> get_vm_area() terminates, no consistency check (addr > VMALLOC_END -
> size) is performed on the "addr".

Agreed, and the patch looks OK.  Moving the test outside the for loop
entirely has the same effect while shaving a few cycles off the
function.  The existing clearly broken in not checking the size of the
final area if we ran off the end of the vm_area chain.

--Stephen

----------------------------------------------------------------
--- mm/vmalloc.c~	Mon Jan 18 18:19:28 1999
+++ mm/vmalloc.c	Thu Apr 22 16:12:58 1999
@@ -161,11 +161,11 @@
 	for (p = &vmlist; (tmp = *p) ; p = &tmp->next) {
 		if (size + addr < (unsigned long) tmp->addr)
 			break;
-		if (addr > VMALLOC_END-size) {
-			kfree(area);
-			return NULL;
-		}
 		addr = tmp->size + (unsigned long) tmp->addr;
+	}
+	if (addr > VMALLOC_END-size) {
+		kfree(area);
+		return NULL;
 	}
 	area->addr = (void *)addr;
 	area->size = size + PAGE_SIZE;
----------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
