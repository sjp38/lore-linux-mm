Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 323976B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 11:22:36 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id pn19so10749686lab.22
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 08:22:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si23315122lae.1.2014.09.24.08.22.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 08:22:33 -0700 (PDT)
Message-ID: <5422E1B8.9000100@suse.cz>
Date: Wed, 24 Sep 2014 17:22:32 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC] mm: show deferred_compaction state in page alloc fail
References: <1409038219-21483-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1409038219-21483-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>

On 08/26/2014 09:30 AM, Minchan Kim wrote:
> Recently, I saw several reports that high order allocation failed
> although there were many freeable pages but it's hard to reproduce
> so asking them to reproduce the problem several time is really painful.
>
> A culprit I doubt is compaction deferring logic which prevent
> compaction for a while so high order allocation could be fail.

Could be that, but also the non-determinism of watermark checking, where 
compaction thinks allocation should succeed, but in the end it won't.

> It would be more clear if we can see the stat which can show
> current zone's compaction deferred state when allocatil fail.
>
> It's a RFC and never test it. I just get an idea with
> handling another strange high order allocation fail.
> Any comments are welcome.

It's quite large patch. Maybe it could be much simpler if you did not 
print just true/false but:

1) true/false based on zone->compact_considered < defer_limit, ignoring
    zone->compact_order_failed

2) zone->compact_order_failed value itself

Then you wouldn't need to pass the allocation order around like you do.
The "allocation failed" message tells you the order which was attempted, 
and then it's easy for the user to compare with the reported
zone->compact_order_failed and decide if the defer status actually 
applies or not.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
