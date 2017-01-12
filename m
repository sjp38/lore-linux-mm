Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 68F506B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 16:58:49 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d140so9178068wmd.4
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 13:58:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j53si8672467wra.334.2017.01.12.13.58.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 13:58:47 -0800 (PST)
Subject: Re: [LSF/MM ATTEND] 2017 userfaultfd-WP, node reclaim vs zone
 compaction, THP
References: <20170112192611.GO4947@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <73b60b0a-33c2-739c-3d1e-d74b73f204e9@suse.cz>
Date: Thu, 12 Jan 2017 22:58:46 +0100
MIME-Version: 1.0
In-Reply-To: <20170112192611.GO4947@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

On 01/12/2017 08:26 PM, Andrea Arcangeli wrote:
> 2) the s/zone/node/ conversion of the page LRU feels still incomplete,
>    as compaction still works zone based and can't compact memory
>    crossing the zone boundaries. While it's is simpler to do
>    compaction that way, it's not ideal because reclaim works node
>    based.

I don't think it's that big issue. Node based reclaim is better than zone based 
because it avoids imbalanced aging between zones. Zone-based compaction doesn't 
have such problem.

>    To avoid dropping some patches that implement "compaction aware
>    zone_reclaim_mode" (i.e. now node_reclaim_mode) I'm still running
>    with zone LRU, although I don't disagree with the node LRU per se,
>    my only issue is that compaction still work zone based and that
>    collides with those changes.
>
>    With reclaim working node based and compaction working zone
>    based, I would need to call a blind for_each_zone(node)
>    compaction() loop which is far from ideal compared to compaction
>    crossing the zone boundary.

Compaction does a lot of watermark checking, which is also per-zone based, so we 
would likely have to do these for_each_zone() dances for the watermark checks, 
I'm afraid. At the same time it should make sure that it doesn't exhaust free 
pages of each single zone below the watermark. The result would look ugly, 
unless we switch to per-node watermarks.

>    Most pages that can be migrated by
>    compaction can go in any zone, not all but we could record the page
>    classzone.

Finding space for that in struct page also wouldn't be easy.

What benefits do you expect from this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
