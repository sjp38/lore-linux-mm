Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2D8AC6B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 12:46:56 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A748D82C372
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 12:58:46 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BOEhq5ejiaTP for <linux-mm@kvack.org>;
	Tue, 28 Apr 2009 12:58:46 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F099282C374
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 12:57:58 -0400 (EDT)
Date: Tue, 28 Apr 2009 12:37:22 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Properly account for freed pages in free_pages_bulk()
 and when allocating high-order pages in buffered_rmqueue()
In-Reply-To: <20090428103159.GB23540@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0904281236350.21913@qirst.com>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240819119.2567.884.camel@ymzhang> <20090427143845.GC912@csn.ul.ie> <1240883957.2567.886.camel@ymzhang> <20090428103159.GB23540@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Apr 2009, Mel Gorman wrote:

> @@ -1151,6 +1151,7 @@ again:
>  	} else {
>  		spin_lock_irqsave(&zone->lock, flags);
>  		page = __rmqueue(zone, order, migratetype);
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
>  		spin_unlock(&zone->lock);
>  		if (!page)
>  			goto failed;

__mod_zone_page_state takes an signed integer argument. Not sure what is
won by the UL suffix here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
