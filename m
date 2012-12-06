Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id D78046B00A5
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:27:56 -0500 (EST)
Date: Thu, 6 Dec 2012 16:19:34 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Message-ID: <20121206161934.GA17258@suse.de>
References: <20121206091744.GA1397@polaris.bitmath.org>
 <20121206144821.GC18547@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121206144821.GC18547@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Henrik Rydberg <rydberg@euromail.se>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Dec 06, 2012 at 03:48:21PM +0100, Jan Kara wrote:
> On Thu 06-12-12 10:17:44, Henrik Rydberg wrote:
> > Hi Linus,
> > 
> > This is the third time I encounter this oops in 3.7, but the first
> > time I managed to get a decent screenshot:
> > 
> > http://bitmath.org/test/oops-3.7-rc8.jpg
> > 
> > It seems to have to do with page migration. I run with transparent
> > hugepages configured, just for the fun of it.
> > 
> > I am happy to test any suggestions.
>   Adding linux-mm and Mel as an author of compaction in particular to CC...
> It seems that while traversing struct page structures, we entered into a new
> huge page (note that RBX is 0xffffea0001c00000 - just the beginning of
> a huge page) and oopsed on PageBuddy test (_mapcount is at offset 0x18 in
> struct page). It might be useful if you provide disassembly of
> isolate_freepages_block() function in your kernel so that we can guess more
> from other register contents...
> 

Still travelling and am not in a position to test this properly :(.
However, this bug feels very similar to a bug in the migration scanner where
a pfn_valid check is missed because the start is not aligned.  Henrik, when
did this start happening? I would be a little surprised if it started between
3.6 and 3.7-rcX but maybe it's just easier to hit now for some reason. How
reproducible is this? Is there anything in particular you do to trigger the
oops? Does the following patch help any? It's only compile tested I'm afraid.

---8<---
mm: compaction: check pfn_valid when entering a new MAX_ORDER_NR_PAGES block during isolation for free

Commit 0bf380bc (mm: compaction: check pfn_valid when entering a new
MAX_ORDER_NR_PAGES block during isolation for migration) added a check
for pfn_valid() when isolating pages for migration as the scanner does
not necessarily start pageblock-aligned. However, the free scanner has
the same problem. If it encounters a hole, it can also trigger an oops
when is calls PageBuddy(page) on a page that is within an hole.

Reported-by: Henrik Rydberg <rydberg@euromail.se>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: stable@vger.kernel.org
---
 mm/compaction.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9eef558..7d85ad485 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -298,6 +298,16 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 			continue;
 		if (!valid_page)
 			valid_page = page;
+
+		/*
+		 * As blockpfn may not start aligned, blockpfn->end_pfn
+		 * may cross a MAX_ORDER_NR_PAGES boundary and a pfn_valid
+		 * check is necessary. If the pfn is not valid, stop
+		 * isolation.
+		 */
+		if ((blockpfn & (MAX_ORDER_NR_PAGES - 1)) == 0 &&
+		    !pfn_valid(blockpfn))
+			break;
 		if (!PageBuddy(page))
 			continue;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
