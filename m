Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7A806B0273
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 12:04:06 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j16so28358202pga.6
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:04:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6si7944589pln.426.2017.09.27.09.03.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 09:03:58 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 12/15] mm: Add variant of pagevec_lookup_range_tag() taking number of pages
Date: Wed, 27 Sep 2017 18:03:31 +0200
Message-Id: <20170927160334.29513-13-jack@suse.cz>
In-Reply-To: <20170927160334.29513-1-jack@suse.cz>
References: <20170927160334.29513-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>

Currently pagevec_lookup_range_tag() takes number of pages to look up
but most users don't need this. Create a new function
pagevec_lookup_range_nr_tag() that takes maximum number of pages to
lookup for Ceph which wants this functionality so that we can drop
nr_pages argument from pagevec_lookup_range_tag().

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/pagevec.h | 3 +++
 mm/swap.c               | 9 +++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 371edacc10d5..0281b1d3a91b 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -40,6 +40,9 @@ static inline unsigned pagevec_lookup(struct pagevec *pvec,
 unsigned pagevec_lookup_range_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, pgoff_t end,
 		int tag, unsigned nr_pages);
+unsigned pagevec_lookup_range_nr_tag(struct pagevec *pvec,
+		struct address_space *mapping, pgoff_t *index, pgoff_t end,
+		int tag, unsigned max_pages);
 static inline unsigned pagevec_lookup_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, int tag,
 		unsigned nr_pages)
diff --git a/mm/swap.c b/mm/swap.c
index a00065f2a8f2..97186da8e5bd 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -996,6 +996,15 @@ unsigned pagevec_lookup_range_tag(struct pagevec *pvec,
 }
 EXPORT_SYMBOL(pagevec_lookup_range_tag);
 
+unsigned pagevec_lookup_range_nr_tag(struct pagevec *pvec,
+		struct address_space *mapping, pgoff_t *index, pgoff_t end,
+		int tag, unsigned max_pages)
+{
+	pvec->nr = find_get_pages_range_tag(mapping, index, end, tag,
+		min_t(unsigned int, max_pages, PAGEVEC_SIZE), pvec->pages);
+	return pagevec_count(pvec);
+}
+EXPORT_SYMBOL(pagevec_lookup_range_tag);
 /*
  * Perform any setup for the swap system
  */
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
