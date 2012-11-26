Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id A69456B004D
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 10:07:32 -0500 (EST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 26 Nov 2012 08:07:31 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 2162E3E40063
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 08:07:14 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAQF73BD312358
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 08:07:03 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAQF6xVP010046
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 08:06:59 -0700
Message-ID: <50B3858D.2060404@linux.vnet.ibm.com>
Date: Mon, 26 Nov 2012 07:06:53 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: compaction: Fix return value of capture_free_page
References: <20121121192151.3FFE0A9A@kernel.stglabs.ibm.com> <20121126112350.GI8218@suse.de>
In-Reply-To: <20121126112350.GI8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-mm@kvack.org

On 11/26/2012 03:23 AM, Mel Gorman wrote:
> On Wed, Nov 21, 2012 at 02:21:51PM -0500, Dave Hansen wrote:
>>
>> This needs to make it in before 3.7 is released.
>>
> 
> This is also required. Dave, can you double check? The surprise is that
> this does not blow up very obviously.
...
> @@ -1422,7 +1422,7 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
>  		}
>  	}
> 
> -	return 1UL << order;
> +	return 1UL << alloc_order;
>  }

compact_capture_page() only looks at the boolean return value out of
capture_free_page(), so it wouldn't notice.  split_free_page() does.
But, when it calls capture_free_page(), order==alloc_order, so it
wouldn't make a difference.  So, there's probably no actual bug here,
but it's certainly a wrong return value.

We should probably also fix the set_pageblock_migratetype() loop in
there while we're at it.  I think it's potentially trampling on the
migration type of pages currently in the allocator.  I _think_ that
completes the list of things that need to get audited in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
