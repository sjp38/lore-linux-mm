Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id BEEC96B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 19:58:23 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id rl12so21002426iec.0
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 16:58:23 -0800 (PST)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id g4si776266igh.45.2015.01.21.16.58.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 16:58:22 -0800 (PST)
Received: by mail-ie0-f177.google.com with SMTP id vy18so566710iec.8
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 16:58:22 -0800 (PST)
Date: Wed, 21 Jan 2015 16:58:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: compaction: fix the page state calculation in
 too_many_isolated
In-Reply-To: <54BF78E3.7030303@suse.cz>
Message-ID: <alpine.DEB.2.10.1501211656160.28120@chino.kir.corp.google.com>
References: <1421832864-30643-1-git-send-email-vinmenon@codeaurora.org> <54BF78E3.7030303@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, minchan@kernel.org, iamjoonsoo.kim@lge.com

On Wed, 21 Jan 2015, Vlastimil Babka wrote:

> On 01/21/2015 10:34 AM, Vinayak Menon wrote:
> > Commit "3611badc1baa" (mm: vmscan: fix the page state calculation in
> 
> That appears to be a -next commit ID, which won't be the same in Linus' tree, so
> it shouldn't be in commit message, AFAIK.
> 
> > too_many_isolated) fixed an issue where a number of tasks were
> > blocked in reclaim path for seconds, because of vmstat_diff not being
> > synced in time. A similar problem can happen in isolate_migratepages_block,
> > similar calculation is performed. This patch fixes that.
> 
> I guess it's not possible to fix the stats instantly and once in the safe
> versions, so that future readings will be correct without safe, right?
> So until it gets fixed, each reading will have to be safe and thus expensive?
> 

Yeah, this patch will actually hurt performance for the migration scanner 
but not as much as stalling unnecessarily when the snapshot is the same.

> I think in case of async compaction, we could skip the safe stuff and just
> terminate it - it's already done when too_many_isolated returns true, and
> there's no congestion waiting in that case.
> 
> So you could extend the too_many_isolated() with "safe" parameter (as you did
> for vmscan) and pass it "cc->mode != MIGRATE_ASYNC" value from
> isolate_migrate_block().
> 

Or just pass it struct compact_control *cc and use both cc->zone and 
cc->mode inside this compaction-only function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
