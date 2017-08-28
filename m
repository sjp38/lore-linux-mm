Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D33346B02B4
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 16:38:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r133so2373077pgr.6
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 13:38:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r138sor814119pgr.165.2017.08.28.13.38.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Aug 2017 13:38:00 -0700 (PDT)
Date: Mon, 28 Aug 2017 13:37:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, madvise: Ensure poisoned pages are removed from
 per-cpu lists
In-Reply-To: <20170828133414.7qro57jbepdcyz5x@techsingularity.net>
Message-ID: <alpine.DEB.2.10.1708281337480.9719@chino.kir.corp.google.com>
References: <20170828133414.7qro57jbepdcyz5x@techsingularity.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 28 Aug 2017, Mel Gorman wrote:

> Wendy Wang reported off-list that a RAS HWPOISON-SOFT test case failed and
> bisected it to the commit 479f854a207c ("mm, page_alloc: defer debugging
> checks of pages allocated from the PCP"). The problem is that a page that
> was poisoned with madvise() is reused. The commit removed a check that
> would trigger if DEBUG_VM was enabled but re-enabling the check only
> fixes the problem as a side-effect by printing a bad_page warning and
> recovering.
> 
> The root of the problem is that a madvise() can leave a poisoned on
> the per-cpu list.  This patch drains all per-cpu lists after pages are
> poisoned so that they will not be reused. Wendy reports that the test case
> in question passes with this patch applied.  While this could be done in
> a targeted fashion, it is over-complicated for such a rare operation.
> 
> Fixes: 479f854a207c ("mm, page_alloc: defer debugging checks of pages allocated from the PCP")
> Reported-and-tested-by: Wang, Wendy <wendy.wang@intel.com>
> Cc: stable@kernel.org
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
