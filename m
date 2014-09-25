Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id E42EA6B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 21:25:30 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so5509205pdb.14
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 18:25:30 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id f1si813386pat.227.2014.09.24.18.25.28
        for <linux-mm@kvack.org>;
        Wed, 24 Sep 2014 18:25:29 -0700 (PDT)
Date: Thu, 25 Sep 2014 10:26:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm: show deferred_compaction state in page alloc fail
Message-ID: <20140925012611.GD17364@bbox>
References: <1409038219-21483-1-git-send-email-minchan@kernel.org>
 <5422E1B8.9000100@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5422E1B8.9000100@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>

On Wed, Sep 24, 2014 at 05:22:32PM +0200, Vlastimil Babka wrote:
> On 08/26/2014 09:30 AM, Minchan Kim wrote:
> >Recently, I saw several reports that high order allocation failed
> >although there were many freeable pages but it's hard to reproduce
> >so asking them to reproduce the problem several time is really painful.
> >
> >A culprit I doubt is compaction deferring logic which prevent
> >compaction for a while so high order allocation could be fail.
> 
> Could be that, but also the non-determinism of watermark checking,
> where compaction thinks allocation should succeed, but in the end it
> won't.
> 
> >It would be more clear if we can see the stat which can show
> >current zone's compaction deferred state when allocatil fail.
> >
> >It's a RFC and never test it. I just get an idea with
> >handling another strange high order allocation fail.
> >Any comments are welcome.
> 
> It's quite large patch. Maybe it could be much simpler if you did
> not print just true/false but:
> 
> 1) true/false based on zone->compact_considered < defer_limit, ignoring
>    zone->compact_order_failed
> 
> 2) zone->compact_order_failed value itself
> 
> Then you wouldn't need to pass the allocation order around like you do.
> The "allocation failed" message tells you the order which was
> attempted, and then it's easy for the user to compare with the
> reported
> zone->compact_order_failed and decide if the defer status actually
> applies or not.

Actually, I thought about it. The reason I avoid that approach
is I don't want to expose deferring logic internal but now that
I think about it, it was wrong conclusion because show_free_area
already have been exported lots of internal. IOW, without it,
there is not much to investigate the reason.

I will send it.
 
Thanks for the review, Vlastimil.
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
