Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 318E06B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 18:18:40 -0400 (EDT)
Date: Tue, 15 May 2012 15:18:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/buddy: dump PG_compound_lock page flag
Message-Id: <20120515151838.6e750498.akpm@linux-foundation.org>
In-Reply-To: <20120514205134.GD1406@cmpxchg.org>
References: <1336991213-9149-1-git-send-email-shangw@linux.vnet.ibm.com>
	<20120514205134.GD1406@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org

On Mon, 14 May 2012 22:51:34 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Mon, May 14, 2012 at 06:26:53PM +0800, Gavin Shan wrote:
> > The array pageflag_names[] is doing the conversion from page flag
> > into the corresponding names so that the meaingful string again
> > the corresponding page flag can be printed. The mechniasm is used
> > while dumping the specified page frame. However, the array missed
> > PG_compound_lock. So PG_compound_lock page flag would be printed
> > as ditigal number instead of meaningful string.
> > 
> > The patch fixes that and print "compound_lock" for PG_compound_lock
> > page flag.
> > 
> > Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> This on top?

Can I play too?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/page_alloc.c: cleanups

- make pageflag_names[] const

- remove null termination of pageflag_names[]

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff -puN mm/page_alloc.c~mm-page_allocc-cleanups mm/page_alloc.c
--- a/mm/page_alloc.c~mm-page_allocc-cleanups
+++ a/mm/page_alloc.c
@@ -5934,7 +5934,7 @@ bool is_free_buddy_page(struct page *pag
 }
 #endif
 
-static struct trace_print_flags pageflag_names[] = {
+static const struct trace_print_flags pageflag_names[] = {
 	{1UL << PG_locked,		"locked"	},
 	{1UL << PG_error,		"error"		},
 	{1UL << PG_referenced,		"referenced"	},
@@ -5972,7 +5972,6 @@ static struct trace_print_flags pageflag
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	{1UL << PG_compound_lock,	"compound_lock"	},
 #endif
-	{-1UL,				NULL		},
 };
 
 static void dump_page_flags(unsigned long flags)
@@ -5981,14 +5980,14 @@ static void dump_page_flags(unsigned lon
 	unsigned long mask;
 	int i;
 
-	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) - 1 != __NR_PAGEFLAGS);
+	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS);
 
 	printk(KERN_ALERT "page flags: %#lx(", flags);
 
 	/* remove zone id */
 	flags &= (1UL << NR_PAGEFLAGS) - 1;
 
-	for (i = 0; pageflag_names[i].name && flags; i++) {
+	for (i = 0; i < ARRAY_SIZE(pageflag_names) && flags; i++) {
 
 		mask = pageflag_names[i].mask;
 		if ((flags & mask) != mask)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
