Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 8FF6C6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 18:53:09 -0400 (EDT)
Message-ID: <51DDE5BA.9020800@intel.com>
Date: Wed, 10 Jul 2013 15:52:42 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/5] mm, page_alloc: support multiple pages allocation
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com> <1372840460-5571-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1372840460-5571-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On 07/03/2013 01:34 AM, Joonsoo Kim wrote:
> -		if (page)
> +		do {
> +			page = buffered_rmqueue(preferred_zone, zone, order,
> +							gfp_mask, migratetype);
> +			if (!page)
> +				break;
> +
> +			if (!nr_pages) {
> +				count++;
> +				break;
> +			}
> +
> +			pages[count++] = page;
> +			if (count >= *nr_pages)
> +				break;
> +
> +			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
> +			if (!zone_watermark_ok(zone, order, mark,
> +					classzone_idx, alloc_flags))
> +				break;
> +		} while (1);

I'm really surprised this works as well as it does.  Calling
buffered_rmqueue() a bunch of times enables/disables interrupts a bunch
of times, and mucks with the percpu pages lists a whole bunch.
buffered_rmqueue() is really meant for _single_ pages, not to be called
a bunch of times in a row.

Why not just do a single rmqueue_bulk() call?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
