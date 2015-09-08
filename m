Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 891936B0258
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 12:29:06 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so126970191wic.0
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 09:29:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hd3si6793846wib.114.2015.09.08.09.29.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Sep 2015 09:29:05 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm, compaction: disginguish contended status in
 tracepoint
References: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
 <1440689044-2922-3-git-send-email-vbabka@suse.cz>
 <20150907055306.GD21207@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55EF0CCD.7000009@suse.cz>
Date: Tue, 8 Sep 2015 18:29:01 +0200
MIME-Version: 1.0
In-Reply-To: <20150907055306.GD21207@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On 09/07/2015 07:53 AM, Joonsoo Kim wrote:
> On Thu, Aug 27, 2015 at 05:24:04PM +0200, Vlastimil Babka wrote:
>> Compaction returns prematurely with COMPACT_PARTIAL when contended or has fatal
>> signal pending. This is ok for the callers, but might be misleading in the
>> traces, as the usual reason to return COMPACT_PARTIAL is that we think the
>> allocation should succeed. This patch distinguishes the premature ending
>> condition. Further distinguishing the exact reason seems unnecessary for now.
> 
> isolate_migratepages() could return ISOLATE_ABORT and skip to call
> compact_finished(). trace_mm_compaction_end() will print
> COMPACT_PARTIAL in this case and we cannot distinguish premature
> ending condition. Is it okay?

Thanks, that could be indeed misleading. It will affect
trace_mm_compaction_end() which also prints COMPACT_PARTIAL for
COMPACT_CONTENDED case as it's already changed in compact_finished(). And
there's no compaction_finished trace event to clarify. Some cases for abort can
be inferred from trace_mm_compaction_isolate_migratepages, but not all.

Maybe I could move the post-filtering for COMPACT_CONTENDED, now done in
compact_finished() to the end of compact_zone()? That would both enhance also
trace_mm_compaction_end() and allow setting proper "ret" value for the
ISOLATE_ABORT case. The abort only happens for sched contention or
too_many_isolated(), which is basically another form of contention...

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
