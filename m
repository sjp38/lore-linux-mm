Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id B9AE38D0006
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 14:26:40 -0500 (EST)
Received: from ipb5.telenor.se (ipb5.telenor.se [195.54.127.168])
	by smtprelay-b22.telenor.se (Postfix) with ESMTP id D35E7EBBF3
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 20:26:38 +0100 (CET)
From: "Henrik Rydberg" <rydberg@euromail.se>
Date: Thu, 6 Dec 2012 20:28:45 +0100
Subject: Re: Oops in 3.7-rc8 isolate_free_pages_block()
Message-ID: <20121206192845.GA599@polaris.bitmath.org>
References: <20121206091744.GA1397@polaris.bitmath.org>
 <20121206144821.GC18547@quack.suse.cz>
 <20121206161934.GA17258@suse.de>
 <CA+55aFw9WQN-MYFKzoGXF9Z70h1XsMu5X4hLy0GPJopBVuE=Yg@mail.gmail.com>
 <20121206175451.GC17258@suse.de>
 <CA+55aFwDZHXf2FkWugCy4DF+mPTjxvjZH87ydhE5cuFFcJ-dJg@mail.gmail.com>
 <20121206183259.GA591@polaris.bitmath.org>
 <CA+55aFzievpA_b5p-bXwW11a89eC-ucpzKUuSqb2PNQOLrqaPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzievpA_b5p-bXwW11a89eC-ucpzKUuSqb2PNQOLrqaPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

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

Ah, and now the two callers treat the pointers the same way.

> Hmm? Mel, please confirm. And Henrik, it might be good to test that
> doubly-fixed patch. Because reading the patch and trying to fix bugs
> in it that way is *not* the same as actually verifying it ;)

Confirmed, working. I also checked 3.6, but could not trigger the
original problem there. The code also looks different, so it makes
sense. To be explicit, this is what I tested on top of v3.7-rc8:

---
 mm/compaction.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9eef558..ff1c483 100644
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
+		end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+		end_pfn = min(end_pfn, zone_end_pfn);
 		isolated = isolate_freepages_block(cc, pfn, end_pfn,
 						   freelist, false);
 		nr_freepages += isolated;
-- 
1.8.0.1

Hopefully, that's a wrap. :-)

Henrik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
