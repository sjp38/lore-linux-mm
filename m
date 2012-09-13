Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 286F76B0185
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 18:19:24 -0400 (EDT)
Date: Thu, 13 Sep 2012 15:19:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: cma: Discard clean pages during contiguous
 allocation instead of migration
Message-Id: <20120913151922.b8893088.akpm@linux-foundation.org>
In-Reply-To: <CAMuHMdXWZ=Jeggd7cT_LXK0MTnmFAf+cWEhC75B1gCcSd3eWeg@mail.gmail.com>
References: <1347324112-14134-1-git-send-email-minchan@kernel.org>
	<CAMuHMdXWZ=Jeggd7cT_LXK0MTnmFAf+cWEhC75B1gCcSd3eWeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kmpark@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Linux-Next <linux-next@vger.kernel.org>

On Thu, 13 Sep 2012 21:17:19 +0200
Geert Uytterhoeven <geert@linux-m68k.org> wrote:

> On Tue, Sep 11, 2012 at 2:41 AM, Minchan Kim <minchan@kernel.org> wrote:
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -674,8 +674,10 @@ static enum page_references page_check_references(struct page *page,
> >  static unsigned long shrink_page_list(struct list_head *page_list,
> >                                       struct zone *zone,
> >                                       struct scan_control *sc,
> > +                                     enum ttu_flags ttu_flags,
> 
> "enum ttu_flags" is defined on CONFIG_MMU=y only, causing on nommu:
> 
> mm/vmscan.c:677:26: error: parameter 4 ('ttu_flags') has incomplete type
> mm/vmscan.c:987:5: error: 'TTU_UNMAP' undeclared (first use in this function)
> mm/vmscan.c:987:15: error: 'TTU_IGNORE_ACCESS' undeclared (first use
> in this function)
> mm/vmscan.c:1312:56: error: 'TTU_UNMAP' undeclared (first use in this function)
> 
> E.g.
> http://kisskb.ellerman.id.au/kisskb/buildresult/7191694/ (h8300-defconfig)
> http://kisskb.ellerman.id.au/kisskb/buildresult/7191858/ (sh-allnoconfig)

hm, OK, the means by which current mainline avoids build errors is
either clever or lucky.

			switch (try_to_unmap(page, TTU_UNMAP)) {

gets preprocessed into

			switch (2) {

so the cmopiler never gets to see the TTU_ symbol at all.  Because it
happens to be inside the try_to_unmap() call.


I guess we can just make ttu_flags visible to NOMMU:


--- a/include/linux/rmap.h~mm-cma-discard-clean-pages-during-contiguous-allocation-instead-of-migration-fix-fix
+++ a/include/linux/rmap.h
@@ -71,6 +71,17 @@ struct anon_vma_chain {
 #endif
 };
 
+enum ttu_flags {
+	TTU_UNMAP = 0,			/* unmap mode */
+	TTU_MIGRATION = 1,		/* migration mode */
+	TTU_MUNLOCK = 2,		/* munlock mode */
+	TTU_ACTION_MASK = 0xff,
+
+	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
+	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
+	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
+};
+
 #ifdef CONFIG_MMU
 static inline void get_anon_vma(struct anon_vma *anon_vma)
 {
@@ -164,16 +175,6 @@ int page_referenced(struct page *, int i
 int page_referenced_one(struct page *, struct vm_area_struct *,
 	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
 
-enum ttu_flags {
-	TTU_UNMAP = 0,			/* unmap mode */
-	TTU_MIGRATION = 1,		/* migration mode */
-	TTU_MUNLOCK = 2,		/* munlock mode */
-	TTU_ACTION_MASK = 0xff,
-
-	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
-	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
-	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
-};
 #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
 
 int try_to_unmap(struct page *, enum ttu_flags flags);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
