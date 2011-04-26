Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B33B7900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 02:34:24 -0400 (EDT)
Date: Tue, 26 Apr 2011 14:34:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: readahead and oom
Message-ID: <20110426063421.GC19717@localhost>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
 <20110426055521.GA18473@localhost>
 <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
 <BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
 <20110426062535.GB19717@localhost>
 <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>

On Tue, Apr 26, 2011 at 02:29:15PM +0800, Dave Young wrote:
> On Tue, Apr 26, 2011 at 2:25 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > On Tue, Apr 26, 2011 at 02:07:17PM +0800, Dave Young wrote:
> >> On Tue, Apr 26, 2011 at 2:05 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
> >> > On Tue, Apr 26, 2011 at 1:55 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> >> >> On Tue, Apr 26, 2011 at 01:49:25PM +0800, Dave Young wrote:
> >> >>> Hi,
> >> >>>
> >> >>> When memory pressure is high, readahead could cause oom killing.
> >> >>> IMHO we should stop readaheading under such circumstancesa??If it's true
> >> >>> how to fix it?
> >> >>
> >> >> Good question. Before OOM there will be readahead thrashings, which
> >> >> can be addressed by this patch:
> >> >>
> >> >> http://lkml.org/lkml/2010/2/2/229
> >> >
> >> > Hi, I'm not clear about the patch, could be regard as below cases?
> >> > 1) readahead alloc fail due to low memory such as other large allocation
> >>
> >> For example vm balloon allocate lots of memory, then readahead could
> >> fail immediately and then oom
> >
> > If true, that would be the problem of vm balloon. It's not good to
> > consume lots of memory all of a sudden, which will likely impact lots
> > of kernel subsystems.
> >
> > btw readahead page allocations are completely optional. They are OK to
> > fail and in theory shall not trigger OOM on themselves. We may
> > consider passing __GFP_NORETRY for readahead page allocations.
> 
> Good idea, care to submit a patch?

Here it is :)

Thanks,
Fengguang
---
readahead: readahead page allocations is OK to fail

Pass __GFP_NORETRY for readahead page allocations.

readahead page allocations are completely optional. They are OK to
fail and in particular shall not trigger OOM on themselves.

Reported-by: Dave Young <hidave.darkstar@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/pagemap.h |    5 +++++
 mm/readahead.c          |    2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

--- linux-next.orig/include/linux/pagemap.h	2011-04-26 14:27:46.000000000 +0800
+++ linux-next/include/linux/pagemap.h	2011-04-26 14:29:31.000000000 +0800
@@ -219,6 +219,11 @@ static inline struct page *page_cache_al
 	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
 }
 
+static inline struct page *page_cache_alloc_cold_noretry(struct address_space *x)
+{
+	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD|__GFP_NORETRY);
+}
+
 typedef int filler_t(void *, struct page *);
 
 extern struct page * find_get_page(struct address_space *mapping,
--- linux-next.orig/mm/readahead.c	2011-04-26 14:27:02.000000000 +0800
+++ linux-next/mm/readahead.c	2011-04-26 14:27:24.000000000 +0800
@@ -180,7 +180,7 @@ __do_page_cache_readahead(struct address
 		if (page)
 			continue;
 
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold_noretry(mapping);
 		if (!page)
 			break;
 		page->index = page_offset;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
