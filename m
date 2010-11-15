Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C8CA08D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 10:23:39 -0500 (EST)
Date: Mon, 15 Nov 2010 16:23:10 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm,vmscan: Reclaim order-0 and compact instead of
 lumpy reclaim when under light pressure
Message-ID: <20101115152310.GG6809@random.random>
References: <1289502424-12661-4-git-send-email-mel@csn.ul.ie>
 <20101112093742.GA3537@csn.ul.ie>
 <20101114150039.E028.A69D9226@jp.fujitsu.com>
 <20101115092256.GE27362@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101115092256.GE27362@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 15, 2010 at 09:22:56AM +0000, Mel Gorman wrote:
> GFP_LUMPY is something else and is only partially related. Transparent Huge
> Pages (THP) does not want to hit lumpy reclaim no matter what the circumstances
> are - It is always better for THP to not use lumpy reclaim. It's debatable

Agreed.

> whether it should even reclaim order-0 pages for compaction so even with
> this series, THP might still introduce GFP_LUMPY.

reclaim of some order 0 page shouldn't do any significant harm as long
as the young bits are not ignored and it's just going "normal" and not
aggressive like lumpy.

Also we it's ok to do some reclaim as we can free some slab that can't
be compacted in case there's excessive amount of slab caches to be
shrunk to have a chance to convert unmovable pageblocks to movable
ones. And we need at least 2M fully available as migration
destination (but I guess that is always available :).

In general interleaving compaction with regular-reclaim (no lumpy)
before failing allocation sounds ok to me.

I guess these days compaction would tend to succeed before lumpy ever
gets invoked so the trouble with lumpy would then only trigger when
compaction starts failing and we enter reclaim to create more movable
pageblocks, but I don't want to risk bad behavior when the amount of
anoymous memory goes very high and not all anonymous memory can be
backed fully by hugepages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
