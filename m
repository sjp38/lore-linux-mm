Subject: [RFC][PATCH 2/3] throttle writers of shared mappings
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
References: <1146861313.3561.13.camel@lappy>
	 <445CA22B.8030807@cyberone.com.au> <1146922446.3561.20.camel@lappy>
	 <445CA907.9060002@cyberone.com.au> <1146929357.3561.28.camel@lappy>
	 <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
	 <1147116034.16600.2.camel@lappy>
	 <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 09 May 2006 22:44:20 +0200
Message-Id: <1147207460.27680.20.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Now that we can detect writers of shared mappings, throttle them.
Avoids OOM by surprise.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

---

 mm/memory.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2006-05-09 09:15:11.000000000 +0200
+++ linux-2.6/mm/memory.c	2006-05-09 09:17:12.000000000 +0200
@@ -50,6 +50,7 @@
 #include <linux/init.h>
 #include <linux/mm_page_replace.h>
 #include <linux/backing-dev.h>
+#include <linux/writeback.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -2183,8 +2184,11 @@ retry:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {
+		struct address_space *mapping = page_mapping(dirty_page);
 		set_page_dirty(dirty_page);
 		put_page(dirty_page);
+		if (mapping)
+			balance_dirty_pages_ratelimited_nr(mapping, 1);
 	}
 	return ret;
 oom:
@@ -2304,8 +2308,11 @@ static inline int handle_pte_fault(struc
 unlock:
 	pte_unmap_unlock(pte, ptl);
 	if (dirty_page) {
+		struct address_space *mapping = page_mapping(dirty_page);
 		set_page_dirty(dirty_page);
 		put_page(dirty_page);
+		if (mapping)
+			balance_dirty_pages_ratelimited_nr(mapping, 1);
 	}
 	return VM_FAULT_MINOR;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
