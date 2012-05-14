Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 3B8AD6B0081
	for <linux-mm@kvack.org>; Mon, 14 May 2012 16:51:38 -0400 (EDT)
Date: Mon, 14 May 2012 22:51:34 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/buddy: dump PG_compound_lock page flag
Message-ID: <20120514205134.GD1406@cmpxchg.org>
References: <1336991213-9149-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1336991213-9149-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Mon, May 14, 2012 at 06:26:53PM +0800, Gavin Shan wrote:
> The array pageflag_names[] is doing the conversion from page flag
> into the corresponding names so that the meaingful string again
> the corresponding page flag can be printed. The mechniasm is used
> while dumping the specified page frame. However, the array missed
> PG_compound_lock. So PG_compound_lock page flag would be printed
> as ditigal number instead of meaningful string.
> 
> The patch fixes that and print "compound_lock" for PG_compound_lock
> page flag.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

This on top?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: page_alloc: catch out-of-date list of page flag names

String tables with names of enum items are always prone to go out of
sync with the enums themselves.  Ensure during compile time that the
name table of page flags has the same size as the page flags enum.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9325913..65ae58d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5986,6 +5986,8 @@ static void dump_page_flags(unsigned long flags)
 	unsigned long mask;
 	int i;
 
+	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) - 1 != __NR_PAGEFLAGS);
+
 	printk(KERN_ALERT "page flags: %#lx(", flags);
 
 	/* remove zone id */
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
