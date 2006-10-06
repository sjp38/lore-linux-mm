Date: Fri, 6 Oct 2006 15:45:35 +0100
Subject: [PATCH] zoneid fix up calculations for ZONEID_PGSHIFT
Message-ID: <20061006144535.GA18583@shadowen.org>
References: <Pine.LNX.4.64.0610021008510.12554@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Ok, it seems the sensible thing is to actually calculate
ZONEID_PGSHIFT and ZONEID_SHIFT off of the actual fields we want
it to contain.  The id is either the NODE,ZONE or the SECTION,ZONE
depending on whats available.  For each field we have the location
of its right hand edge.  The right hand edge of the combined field
is the lower of the two.  It is possible for there to be no bits
in our identifier in the non-numa single zone case, so we also need
to take the overall width being zero (to avoid a shift error).

I think the following should do the trick.  I've tested this outside
the kernel in all the combinations I could think of and it seems to
do the right thing.  I've build tested on a few machines, but there
seems to be so many unrelated problems about with 2.6.19-mm3 that
I've not tested it as extensivly as I might prefer.

How does this look, against 2.6.19-mm3.

-apw


=== 8< ===
zoneid: fix up calculations for ZONEID_PGSHIFT

Currently if we have a non-zero ZONES_SHIFT we assume we are able
to rely on that as the bottom edge of the ZONEID, if not then we
use the NODES_PGOFF as the right end of either NODES _or_ SECTION.
This latter is more luck than judgement and would be incorrect if
we reordered the SECTION,NODE,ZONE options in the fields space.

Really what we want is the lower of the right hand end of the two
fields we are using (either NODE,ZONE or SECTION,ZONE).  Codify that
explicitly.  As always allow for there being no bits in either of
the fields, such as might be valid in a non-numa machine with only
a zone NORMAL.

I have checked that the compiler is still able to constant fold
all of this away correctly.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d9d0b46..98ed057 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -418,15 +418,15 @@ #define ZONES_PGSHIFT		(ZONES_PGOFF * (Z
 /* NODE:ZONE or SECTION:ZONE is used to ID a zone for the buddy allcator */
 #ifdef NODE_NOT_IN_PAGEFLAGS
 #define ZONEID_SHIFT		(SECTIONS_SHIFT + ZONES_SHIFT)
+#define ZONEID_PGOFF		((SECTIONS_PGOFF < ZONES_PGOFF)? \
+						SECTIONS_PGOFF : ZONES_PGOFF)
 #else
 #define ZONEID_SHIFT		(NODES_SHIFT + ZONES_SHIFT)
+#define ZONEID_PGOFF		((NODES_PGOFF < ZONES_PGOFF)? \
+						NODES_PGOFF : ZONES_PGOFF)
 #endif
 
-#if ZONES_WIDTH > 0
-#define ZONEID_PGSHIFT		ZONES_PGSHIFT
-#else
-#define ZONEID_PGSHIFT		NODES_PGOFF
-#endif
+#define ZONEID_PGSHIFT		(ZONEID_PGOFF * (ZONEID_SHIFT != 0))
 
 #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
 #error SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
@@ -452,7 +452,6 @@ static inline enum zone_type page_zonenu
  */
 static inline int page_zone_id(struct page *page)
 {
-	BUILD_BUG_ON(ZONEID_PGSHIFT == 0 && ZONEID_MASK);
 	return (page->flags >> ZONEID_PGSHIFT) & ZONEID_MASK;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
