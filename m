Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id C79C28D0006
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 14:09:39 -0500 (EST)
Date: Thu, 6 Dec 2012 19:01:14 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Message-ID: <20121206190114.GE17258@suse.de>
References: <20121206091744.GA1397@polaris.bitmath.org>
 <20121206144821.GC18547@quack.suse.cz>
 <20121206161934.GA17258@suse.de>
 <CA+55aFw9WQN-MYFKzoGXF9Z70h1XsMu5X4hLy0GPJopBVuE=Yg@mail.gmail.com>
 <20121206175451.GC17258@suse.de>
 <CA+55aFwDZHXf2FkWugCy4DF+mPTjxvjZH87ydhE5cuFFcJ-dJg@mail.gmail.com>
 <20121206183259.GA591@polaris.bitmath.org>
 <CA+55aFzievpA_b5p-bXwW11a89eC-ucpzKUuSqb2PNQOLrqaPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFzievpA_b5p-bXwW11a89eC-ucpzKUuSqb2PNQOLrqaPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Henrik Rydberg <rydberg@euromail.se>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Dec 06, 2012 at 10:41:14AM -0800, Linus Torvalds wrote:
> On Thu, Dec 6, 2012 at 10:32 AM, Henrik Rydberg <rydberg@euromail.se> wrote:
> >>
> >> Henrik, does that - corrected - patch (*instead* of the previous one,
> >> not in addition to) also fix your issue?
> >
> > Yes - I can no longer trigger the failpath, so it seems to work. Mel,
> > enjoy the rest of the talk. ;-)
> >
> > Generally, I am a bit surprised that noone hit this before, given that
> > it was quite easy to trigger. I will check 3.6 as well.
> 
> Actually, looking at it some more, I think that two-liner patch had
> *ANOTHER* bug.
> 
> Because the other line seems buggy as well.
> 
> Instead of
> 
>         end_pfn = ALIGN(pfn + pageblock_nr_pages, pageblock_nr_pages);
> 
> I think it should be
> 
>         end_pfn = ALIGN(pfn+1, pageblock_nr_pages);
> 
> instead. ALIGN() already aligns upwards (but the "+1" is needed in
> case pfn is already at a pageblock_nr_pages boundary, at which point
> ALIGN() would have just returned that same boundary.
> 
> Hmm? Mel, please confirm.

FFS. Yes, confirmed.

In answer to Henrik's wondering why others have reported this -- reproducing
this requires a large enough hole with the right aligment to have compaction
walk into a PFN range with no memmap. Size and alignment depends in the
memory model - 4M for FLATMEM and 128M for SPARSEMEM on x86. It needs a
"lucky" machine.

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
---
 mm/compaction.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9eef558..694eaab 100644
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
+		 * only scans within a pageblock
+		 */
+		end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+		end_pfn = min(end_pfn, zone_end_pfn);
 		isolated = isolate_freepages_block(cc, pfn, end_pfn,
 						   freelist, false);
 		nr_freepages += isolated;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
