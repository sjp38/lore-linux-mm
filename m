Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 04E2E6B0055
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:20:34 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D0EA3304865
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:27:15 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id b1ae1B9XgFMB for <linux-mm@kvack.org>;
	Mon, 16 Mar 2009 12:27:09 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 12C69304816
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:25:37 -0400 (EDT)
Date: Mon, 16 Mar 2009 12:17:15 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 23/35] Update NR_FREE_PAGES only as necessary
In-Reply-To: <1237196790-7268-24-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903161214080.32577@qirst.com>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-24-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009, Mel Gorman wrote:

> When pages are being freed to the buddy allocator, the zone
> NR_FREE_PAGES counter must be updated. In the case of bulk per-cpu page
> freeing, it's updated once per page. This retouches cache lines more
> than necessary. Update the counters one per per-cpu bulk free.

Not sure about the reasoning here since the individual updates are batched
and you are touching the same cacheline as the pcp you are operating on
and have to touch anyways.

But if its frequent that __rmqueue_smallest() and free_pages_bulk() are
called with multiple pages then its always a win.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

> +	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order) * i);

A multiplication? Okay with contemporary cpus I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
