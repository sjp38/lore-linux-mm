Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA21725
	for <linux-mm@kvack.org>; Fri, 22 Jan 1999 04:42:41 -0500
Date: Fri, 22 Jan 1999 10:38:40 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] arca-vm-28 - new nr_freeable_pages
In-Reply-To: <Pine.LNX.3.96.990121210148.2760B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990122103703.516A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Cc: Nimrod Zimerman <zimerman@deskmail.com>, John Alvord <jalvo@cloud9.net>, "Stephen C. Tweedie" <sct@redhat.com>, Steve Bergman <steve@netplus.net>, dlux@dlux.sch.bme.hu, "Nicholas J. Leon" <nicholas@binary9.net>, Kalle Andersson <kalle@sslug.dk>, Heinz Mauelshagen <mauelsha@ez-darmstadt.telekom.de>, Ben McCann <bmccann@indusriver.com>"Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 1999, Andrea Arcangeli wrote:

> ftp://e-mind.com/pub/linux/kernel-patches/2.2.0-pre8testing-arca-VM-28.gz

Woops I forgot to diff pagemap.h in arca-vm-28, excuse me. At least
arca-tree-109 was fine ;). 

Index: linux/include/linux/pagemap.h
diff -u linux/include/linux/pagemap.h:1.1.1.1 linux/include/linux/pagemap.h:1.1.2.4
--- linux/include/linux/pagemap.h:1.1.1.1	Mon Jan 18 02:27:10 1999
+++ linux/include/linux/pagemap.h	Fri Jan 22 10:12:47 1999
@@ -11,17 +11,16 @@
 
 #include <linux/mm.h>
 #include <linux/fs.h>
+#include <linux/swap.h>
 
 static inline unsigned long page_address(struct page * page)
 {
-	return PAGE_OFFSET + PAGE_SIZE * page->map_nr;
+	return PAGE_OFFSET + (page->map_nr << PAGE_SHIFT);
 }
 
-#define PAGE_HASH_BITS 11
+#define PAGE_HASH_BITS 13
 #define PAGE_HASH_SIZE (1 << PAGE_HASH_BITS)
 
-#define PAGE_AGE_VALUE 16
-
 extern unsigned long page_cache_size; /* # of pages currently in the hash table */
 extern struct page * page_hash_table[PAGE_HASH_SIZE];
 
@@ -58,7 +57,7 @@
 			break;
 	}
 	/* Found the page. */
-	atomic_inc(&page->count);
+	page_get(page);
 	set_bit(PG_referenced, &page->flags);
 not_found:
 	return page;
@@ -78,6 +77,7 @@
 		page->pprev_hash = NULL;
 	}
 	page_cache_size--;
+	page_put(page);
 }
 
 static inline void __add_page_to_hash_queue(struct page * page, struct page **p)


Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
