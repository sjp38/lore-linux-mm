Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 087D66B0023
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 18:18:20 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p9PMIJZl002863
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 15:18:19 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by wpaz24.hot.corp.google.com with ESMTP id p9PMCLmX013559
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 15:18:17 -0700
Received: by pzk36 with SMTP id 36so3548923pzk.7
        for <linux-mm@kvack.org>; Tue, 25 Oct 2011 15:18:17 -0700 (PDT)
Date: Tue, 25 Oct 2011 15:18:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
In-Reply-To: <20111025090956.GA10797@suse.de>
Message-ID: <alpine.DEB.2.00.1110251513520.26017@chino.kir.corp.google.com>
References: <1319524789-22818-1-git-send-email-ccross@android.com> <20111025090956.GA10797@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Colin Cross <ccross@android.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue, 25 Oct 2011, Mel Gorman wrote:

> That said, it will be difficult to remember why checking __GFP_NOFAIL in
> this case is necessary and someone might "optimitise" it away later. It
> would be preferable if it was self-documenting. Maybe something like
> this? (This is totally untested)
> 

__GFP_NOFAIL _should_ be optimized away in this case because all he's 
passing is __GFP_WAIT | __GFP_NOFAIL.  That doesn't make any sense unless 
all you want to do is livelock.

__GFP_NOFAIL doesn't mean the page allocator would infinitely loop in all 
conditions.  That's why GFP_ATOMIC | __GFP_NOFAIL actually fails, and I 
would argue that __GFP_WAIT | __GFP_NOFAIL should fail as well since it's 
the exact same condition except doesn't have access to the extra memory 
reserves.

Suspend needs to either set __GFP_NORETRY to avoid the livelock if it's 
going to disable all means of memory reclaiming or freeing in the page 
allocator.  Or, better yet, just make it GFP_NOWAIT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
