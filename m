Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 2B1448D0006
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 13:03:40 -0500 (EST)
Date: Thu, 6 Dec 2012 17:55:15 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Message-ID: <20121206175451.GC17258@suse.de>
References: <20121206091744.GA1397@polaris.bitmath.org>
 <20121206144821.GC18547@quack.suse.cz>
 <20121206161934.GA17258@suse.de>
 <CA+55aFw9WQN-MYFKzoGXF9Z70h1XsMu5X4hLy0GPJopBVuE=Yg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFw9WQN-MYFKzoGXF9Z70h1XsMu5X4hLy0GPJopBVuE=Yg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Henrik Rydberg <rydberg@euromail.se>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Dec 06, 2012 at 08:50:54AM -0800, Linus Torvalds wrote:
> On Thu, Dec 6, 2012 at 8:19 AM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > Still travelling and am not in a position to test this properly :(.
> > However, this bug feels very similar to a bug in the migration scanner where
> > a pfn_valid check is missed because the start is not aligned.
> 
> Ugh. This patch makes my eyes bleed.
> 

Yeah. I was listening to a talk while I was writing it, a bit cranky and
didn't see why I should suffer alone.

> Is there no way to do this nicely in the caller? IOW, fix the
> 'end_pfn' logic way upstream where it is computed, and just cap it at
> the MAX_ORDER_NR_PAGES boundary?
> 

Easily done in the caller, but not on the MAX_ORDER_NR_PAGES boundary.
The caller is striding by pageblock so a MAX_ORDER_NR_PAGES alignment will
not work out.

> For example, isolate_freepages_range() seems to have this *other*
> end-point alignment thing going on, and does it in a loop. Wouldn't it
> be much better to have a separate loop that looped up to the next
> MAX_ORDER_NR_PAGES boundary instead of having this kind of very random
> test in the middle of a loop.
> 
> Even the name ("isolate_freepages_block") implies that we have a
> "block" of pages. Having to have a random "oops, this block can have
> other blocks inside of it that aren't mapped" test in the middle of
> that function really makes me go "Uhh, no".
> 

The block in the name is related to pageblocks.

> Plus, is it even guaranteed that the *first* pfn (that we get called
> with) is pfnvalid to begin with?
> 

Yes, the caller has already checked pfn_valid() and it used to be the
case that this pfn was pageblock-aligned but not since commit c89511ab
(mm: compaction: Restart compaction from near where it left off).

> So I guess this patch fixes things, but it does make me go "That's
> really *really* ugly".
> 

Quasimoto strikes again

---8<---
mm: compaction: check pfn_valid when entering a new MAX_ORDER_NR_PAGES block during isolation for free

Commit 0bf380bc (mm: compaction: check pfn_valid when entering a new
MAX_ORDER_NR_PAGES block during isolation for migration) added a check
for pfn_valid() when isolating pages for migration as the scanner does not
necessarily start pageblock-aligned. Since commit c89511ab (mm: compaction:
Restart compaction from near where it left off), the free scanner has
the same problem. This patch makes sure that the pfn range passed to
isolate_freepages_block() is within the same block so that pfn_valid()
checks are unnecessary.

Reported-by: Henrik Rydberg <rydberg@euromail.se>
Signed-off-by: Mel Gorman <mgorman@suse.de>

diff --git a/mm/compaction.c b/mm/compaction.c
index 9eef558..c23fa55 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -713,7 +713,15 @@ static void isolate_freepages(struct zone *zone,
 
 		/* Found a block suitable for isolating free pages from */
 		isolated = 0;
-		end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
+
+		/*
+		 * As pfn may not start aligned, pfn+pageblock_nr_page
+		 * may cross a MAX_ORDER_NR_PAGES boundary and miss
+		 * a pfn_valid check. Ensure isolate_freepages_block()
+		 * only scans within a pageblock.
+		 */
+		end_pfn = ALIGN(pfn + pageblock_nr_pages, pageblock_nr_pages);
+		end_pfn = min(end_pfn, end_pfn);
 		isolated = isolate_freepages_block(cc, pfn, end_pfn,
 						   freelist, false);
 		nr_freepages += isolated;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
