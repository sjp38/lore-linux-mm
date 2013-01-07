Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 4AC8C6B006E
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 17:31:40 -0500 (EST)
Date: Mon, 7 Jan 2013 14:31:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND][PATCH v3] mm: Use aligned zone start for pfn_to_bitidx
 calculation
Message-Id: <20130107143128.face9220.akpm@linux-foundation.org>
In-Reply-To: <1357414111-20736-1-git-send-email-lauraa@codeaurora.org>
References: <1357414111-20736-1-git-send-email-lauraa@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org

On Sat,  5 Jan 2013 11:28:31 -0800
Laura Abbott <lauraa@codeaurora.org> wrote:

> The current calculation in pfn_to_bitidx assumes that
> (pfn - zone->zone_start_pfn) >> pageblock_order will return the
> same bit for all pfn in a pageblock. If zone_start_pfn is not
> aligned to pageblock_nr_pages, this may not always be correct.
> 
> Consider the following with pageblock order = 10, zone start 2MB:
> 
> pfn     | pfn - zone start | (pfn - zone start) >> page block order
> ----------------------------------------------------------------
> 0x26000 | 0x25e00	   |  0x97
> 0x26100 | 0x25f00	   |  0x97
> 0x26200 | 0x26000	   |  0x98
> 0x26300 | 0x26100	   |  0x98
> 
> This means that calling {get,set}_pageblock_migratetype on a single
> page will not set the migratetype for the full block. Fix this by
> rounding down zone_start_pfn when doing the bitidx calculation.

What are the user-visible effects of this bug?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
