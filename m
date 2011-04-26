Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3EF6C9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 05:20:33 -0400 (EDT)
Date: Tue, 26 Apr 2011 17:20:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: readahead and oom
Message-ID: <20110426092029.GA27053@localhost>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
 <20110426055521.GA18473@localhost>
 <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
 <BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
 <20110426062535.GB19717@localhost>
 <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>

Minchan,

> > +static inline struct page *page_cache_alloc_cold_noretry(struct address_space *x)
> > +{
> > + A  A  A  return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD|__GFP_NORETRY);
> 
> It makes sense to me but it could make a noise about page allocation
> failure. I think it's not desirable.
> How about adding __GFP_NOWARAN?

Yeah it makes sense. Here is the new version.

Thanks,
Fengguang
---
Subject: readahead: readahead page allocations is OK to fail
Date: Tue Apr 26 14:29:40 CST 2011

Pass __GFP_NORETRY|__GFP_NOWARN for readahead page allocations.

readahead page allocations are completely optional. They are OK to
fail and in particular shall not trigger OOM on themselves.

Reported-by: Dave Young <hidave.darkstar@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/pagemap.h |    6 ++++++
 mm/readahead.c          |    2 +-
 2 files changed, 7 insertions(+), 1 deletion(-)

--- linux-next.orig/include/linux/pagemap.h	2011-04-26 14:27:46.000000000 +0800
+++ linux-next/include/linux/pagemap.h	2011-04-26 17:17:13.000000000 +0800
@@ -219,6 +219,12 @@ static inline struct page *page_cache_al
 	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
 }
 
+static inline struct page *page_cache_alloc_readahead(struct address_space *x)
+{
+	return __page_cache_alloc(mapping_gfp_mask(x) |
+				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN);
+}
+
 typedef int filler_t(void *, struct page *);
 
 extern struct page * find_get_page(struct address_space *mapping,
--- linux-next.orig/mm/readahead.c	2011-04-26 14:27:02.000000000 +0800
+++ linux-next/mm/readahead.c	2011-04-26 17:17:25.000000000 +0800
@@ -180,7 +180,7 @@ __do_page_cache_readahead(struct address
 		if (page)
 			continue;
 
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_readahead(mapping);
 		if (!page)
 			break;
 		page->index = page_offset;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
