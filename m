Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id C0DD56B00E9
	for <linux-mm@kvack.org>; Thu,  3 May 2012 04:50:24 -0400 (EDT)
Date: Thu, 3 May 2012 10:50:19 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] MM: check limit while deallocating bootmem node
Message-ID: <20120503085019.GB31780@cmpxchg.org>
References: <1336008674-10858-1-git-send-email-shangw@linux.vnet.ibm.com>
 <20120503074708.GA31780@cmpxchg.org>
 <20120503083506.GA19924@shangw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120503083506.GA19924@shangw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org

On Thu, May 03, 2012 at 04:35:06PM +0800, Gavin Shan wrote:
> >From: Gavin Shan <shangw@linux.vnet.ibm.com>
> >Subject: [patch 1/2] mm: bootmem: fix checking the bitmap when finally
> > freeing bootmem
> >
> >When bootmem releases an unaligned chunk of memory at the beginning of
> >a node to the page allocator, it iterates from that unaligned PFN but
> >checks an aligned word of the page bitmap.  The checked bits do not
> >correspond to the PFNs and, as a result, reserved pages can be freed.
> >
> >Properly shift the bitmap word so that the lowest bit corresponds to
> >the starting PFN before entering the freeing loop.
> >
> 
> Thanks for changing it correctly, Johannes ;-)
> 
> >Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> >Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> >---
> > mm/bootmem.c |    1 +
> > 1 file changed, 1 insertion(+)
> >
> >diff --git a/mm/bootmem.c b/mm/bootmem.c
> >index 0131170..67872fc 100644
> >--- a/mm/bootmem.c
> >+++ b/mm/bootmem.c
> >@@ -203,6 +203,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
> > 		} else {
> > 			unsigned long off = 0;
> >
> >+			vec >>= start & (BITS_PER_LONG - 1);
> > 			while (vec && off < BITS_PER_LONG) {
> 
> I think it can be changed to "while (vec) {" since it's duplicate
> check. "vec" has no chance to have more bits than BITS_PER_LONG here.

Yes, I think it should be removed too, but as a separate patch.  It's
an unrelated cleanup, better to keep it out of the bugfix change.

> Others look good. Need I change it accordingly and send it out
> again?

It doesn't really matter who sends the patches, your original
authorship is preserved (see the From: in the patch header).  If you
don't have any objections, I'll send both patches to Andrew later.

Here is 2/2, btw:

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/2] mm: bootmem: remove redundant offset check when finally
 freeing bootmem

When bootmem releases an unaligned BITS_PER_LONG pages chunk of memory
to the page allocator, it checks the bitmap if there are still
unreserved pages in the chunk (set bits), but also if the offset in
the chunk indicates BITS_PER_LONG loop iterations already.

But since the consulted bitmap is only a one-word-excerpt of the full
per-node bitmap, there can not be more than BITS_PER_LONG bits set in
it.  The additional offset check is unnecessary.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/bootmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 67872fc..053ac3f 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -204,7 +204,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 			unsigned long off = 0;
 
 			vec >>= start & (BITS_PER_LONG - 1);
-			while (vec && off < BITS_PER_LONG) {
+			while (vec) {
 				if (vec & 1) {
 					page = pfn_to_page(start + off);
 					__free_pages_bootmem(page, 0);
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
