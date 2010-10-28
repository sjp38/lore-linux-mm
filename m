Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 78EC96B00CF
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 17:31:18 -0400 (EDT)
Message-ID: <4CC9EB84.9050406@redhat.com>
Date: Thu, 28 Oct 2010 17:30:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for protecting
 the working set
References: <20101028191523.GA14972@google.com>
In-Reply-To: <20101028191523.GA14972@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: 20101025094235.9154.A69D9226@jp.fujitsu.com
Cc: Mandeep Singh Baines <msb@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On 10/28/2010 03:15 PM, Mandeep Singh Baines wrote:

> +/*
> + * Check low watermark used to prevent fscache thrashing during low memory.
> + */
> +static int file_is_low(struct zone *zone, struct scan_control *sc)
> +{
> +	unsigned long pages_min, active, inactive;
> +
> +	if (!scanning_global_lru(sc))
> +		return false;
> +
> +	pages_min = min_filelist_kbytes>>  (PAGE_SHIFT - 10);
> +	active = zone_page_state(zone, NR_ACTIVE_FILE);
> +	inactive = zone_page_state(zone, NR_INACTIVE_FILE);
> +
> +	return ((active + inactive)<  pages_min);
> +}

This is problematic.

It is quite possible for a NUMA system to have one zone
legitimately low on page cache (because all the binaries
and libraries got paged in on another NUMA node), without
the system being anywhere near out of memory.

This patch looks like it could cause a false OOM kill
in that scenario.

At the very minimum, you'd have to check that the system
is low on page cache globally, not just locally.

You do point out a real problem though, and it would be
nice to find a generic solution to it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
