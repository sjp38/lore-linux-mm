Received: from pneumatic-tube.sgi.com (pneumatic-tube.sgi.com [204.94.214.22])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA02566
	for <Linux-MM@kvack.org>; Wed, 21 Apr 1999 21:20:00 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199904220012.RAA57724@google.engr.sgi.com>
Subject: boundary condition bug fix for vmalloc()
Date: Wed, 21 Apr 1999 17:12:37 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linux-MM@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

Under heavy load conditions, get_vm_area() might end up allocating an
address range beyond VMALLOC_END. The problem is after the for loop
in get_vm_area() terminates, no consistency check (addr > VMALLOC_END
- size) is performed on the "addr". 

I believe the following patch will fix the problem:

--- vmalloc.old		Wed Apr 21 16:52:05 1999
+++ mm/vmalloc.c	Wed Apr 21 16:53:08 1999
@@ -161,11 +161,11 @@
        for (p = &vmlist; (tmp = *p) ; p = &tmp->next) {
                if (size + addr < (unsigned long) tmp->addr)
                        break;
+               addr = tmp->size + (unsigned long) tmp->addr;
                if (addr > VMALLOC_END-size) {
                        kfree(area);
                        return NULL;
                }
-               addr = tmp->size + (unsigned long) tmp->addr;
        }
        area->addr = (void *)addr;
        area->size = size + PAGE_SIZE;
 
Please let me know if this patch is pulled into the source tree, 
so I can update my tree.

Thanks.

Kanoj
kanoj@engr.sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
