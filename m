Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0496A6B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 02:35:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so157173177pfg.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 23:35:15 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f84si30584159pfj.40.2016.08.15.23.35.14
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 23:35:15 -0700 (PDT)
Date: Tue, 16 Aug 2016 15:41:04 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 08/11] mm, compaction: create compact_gap wrapper
Message-ID: <20160816064104.GG17448@js1304-P5Q-DELUXE>
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-9-vbabka@suse.cz>
 <20160816061518.GE17448@js1304-P5Q-DELUXE>
 <656fea7f-753d-df56-744a-50b90f9a3842@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <656fea7f-753d-df56-744a-50b90f9a3842@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 16, 2016 at 08:15:36AM +0200, Vlastimil Babka wrote:
> On 08/16/2016 08:15 AM, Joonsoo Kim wrote:
> >On Wed, Aug 10, 2016 at 11:12:23AM +0200, Vlastimil Babka wrote:
> >>--- a/include/linux/compaction.h
> >>+++ b/include/linux/compaction.h
> >>@@ -58,6 +58,22 @@ enum compact_result {
> >>
> >> struct alloc_context; /* in mm/internal.h */
> >>
> >>+/*
> >>+ * Number of free order-0 pages that should be available above given watermark
> >>+ * to make sure compaction has reasonable chance of not running out of free
> >>+ * pages that it needs to isolate as migration target during its work.
> >>+ */
> >>+static inline unsigned long compact_gap(unsigned int order)
> >>+{
> >>+	/*
> >>+	 * Although all the isolations for migration are temporary, compaction
> >>+	 * may have up to 1 << order pages on its list and then try to split
> >>+	 * an (order - 1) free page. At that point, a gap of 1 << order might
> >>+	 * not be enough, so it's safer to require twice that amount.
> >>+	 */
> >>+	return 2UL << order;
> >>+}
> >
> >I agree with this wrapper function but there is a question.
> >
> >Could you elaborate more on this code comment? Freescanner could keep
> >COMPACT_CLUSTER_MAX freepages on the list. It's not associated with
> >requested order at least for now. Why compact_gap is 2UL << order in
> >this case?
> 
> It's true that for high enough order, COMPACT_CLUSTER_MAX might be
> more limiting than 1 << order. But then it also helps to have more

AFAIK, regardless of order, migration scanner isolates
COMPACT_CLUSTER_MAX pages. And, freepage scanner isolates
more than nr_migratepages freepages.

> free pages for probability of compaction success, so I don't think
> it's worth complicating the compact_gap() formula.

I agree that it's not worth complicating the compact_gap() formula but
it would be better to fix the comment?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
