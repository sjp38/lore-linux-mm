Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m496cv8J237456
	for <linux-mm@kvack.org>; Fri, 9 May 2008 06:38:57 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m496cvYh2637942
	for <linux-mm@kvack.org>; Fri, 9 May 2008 07:38:57 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m496cv1C029905
	for <linux-mm@kvack.org>; Fri, 9 May 2008 07:38:57 +0100
Date: Fri, 9 May 2008 08:38:56 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] sparsemem vmemmap: initialize memmap.
Message-ID: <20080509063856.GC9840@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <clameter@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Trying to online a new memory section that was added via memory hotplug
results in lots of messages of pages in bad page state.
Reason is that the alloacted virtual memmap isn't initialized.
This is only an issue for memory sections that get added after boot
time since for all other memmaps the bootmem allocator was used which
returns only initialized memory.

I noticed this on s390 which has its private vmemmap_populate function
without using callbacks to the common code. But as far as I can see the
generic code has the same bug, so fix it just once.

Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 mm/sparse-vmemmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/sparse-vmemmap.c
===================================================================
--- linux-2.6.orig/mm/sparse-vmemmap.c
+++ linux-2.6/mm/sparse-vmemmap.c
@@ -154,6 +154,6 @@ struct page * __meminit sparse_mem_map_p
 	int error = vmemmap_populate(map, PAGES_PER_SECTION, nid);
 	if (error)
 		return NULL;
-
+	memset(map, 0, PAGES_PER_SECTION * sizeof(struct page));
 	return map;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
