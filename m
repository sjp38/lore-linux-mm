Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 369036B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 03:29:48 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id w62so1415134wes.11
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 00:29:47 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kz5si40245683wjc.167.2015.01.13.00.29.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 00:29:47 -0800 (PST)
Message-ID: <54B4D778.7050501@suse.cz>
Date: Tue, 13 Jan 2015 09:29:44 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/5] mm/compaction: more trace to understand when/why
 compaction start/finish
References: <1421050875-26332-1-git-send-email-iamjoonsoo.kim@lge.com> <1421050875-26332-4-git-send-email-iamjoonsoo.kim@lge.com> <54B3EE11.3040303@suse.cz> <20150113071605.GA29898@js1304-P5Q-DELUXE>
In-Reply-To: <20150113071605.GA29898@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/13/2015 08:16 AM, Joonsoo Kim wrote:
> On Mon, Jan 12, 2015 at 04:53:53PM +0100, Vlastimil Babka wrote:
>> On 01/12/2015 09:21 AM, Joonsoo Kim wrote:
>> > It is not well analyzed that when/why compaction start/finish or not. With
>> > these new tracepoints, we can know much more about start/finish reason of
>> > compaction. I can find following bug with these tracepoint.
>> > 
>> > http://www.spinics.net/lists/linux-mm/msg81582.html
>> > 
>> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> > ---
>> >  include/linux/compaction.h        |    3 ++
>> >  include/trace/events/compaction.h |   94 +++++++++++++++++++++++++++++++++++++
>> >  mm/compaction.c                   |   41 ++++++++++++++--
>> >  3 files changed, 134 insertions(+), 4 deletions(-)
>> > 
>> > diff --git a/include/linux/compaction.h b/include/linux/compaction.h
>> > index a9547b6..d82181a 100644
>> > --- a/include/linux/compaction.h
>> > +++ b/include/linux/compaction.h
>> > @@ -12,6 +12,9 @@
>> >  #define COMPACT_PARTIAL		3
>> >  /* The full zone was compacted */
>> >  #define COMPACT_COMPLETE	4
>> > +/* For more detailed tracepoint output */
>> > +#define COMPACT_NO_SUITABLE_PAGE	5
>> > +#define COMPACT_NOT_SUITABLE_ZONE	6
>> >  /* When adding new state, please change compaction_status_string, too */
>> >  
>> >  /* Used to signal whether compaction detected need_sched() or lock contention */
>> > diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
>> > index 139020b..839dd4f 100644
>> > --- a/include/trace/events/compaction.h
>> > +++ b/include/trace/events/compaction.h
>> > @@ -164,6 +164,100 @@ TRACE_EVENT(mm_compaction_end,
>> >  		compaction_status_string[__entry->status])
>> >  );
>> >  
>> > +TRACE_EVENT(mm_compaction_try_to_compact_pages,
>> > +
>> > +	TP_PROTO(
>> > +		int order,
>> > +		gfp_t gfp_mask,
>> > +		enum migrate_mode mode,
>> > +		int alloc_flags,
>> > +		int classzone_idx),
>> 
>> I wonder if alloc_flags and classzone_idx is particularly useful. It affects the
>> watermark checks, but those are a bit of blackbox anyway.
> 
> Yes, I think so. How about printing gfp_flag rather than these? It would
> tell us migratetype and other information so would be useful.

Yeah gfp_mask should be enough.

> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
