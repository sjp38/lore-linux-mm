Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 170946B0047
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:11:46 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3MH8p4u024741
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 11:08:51 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3MHBvWT068324
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 11:11:57 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3MHBtE5007429
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 11:11:56 -0600
Subject: Re: [PATCH 18/22] Use allocation flags as an index to the zone
	watermark
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1240408407-21848-19-git-send-email-mel@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	 <1240408407-21848-19-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 22 Apr 2009 10:11:53 -0700
Message-Id: <1240420313.10627.85.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-04-22 at 14:53 +0100, Mel Gorman wrote:
>  struct zone {
>         /* Fields commonly accessed by the page allocator */
> -       unsigned long           pages_min, pages_low, pages_high;
> +       union {
> +               struct {
> +                       unsigned long   pages_min, pages_low, pages_high;
> +               };
> +               unsigned long pages_mark[3];
> +       };

Why the union?  It's a bit obfuscated for me.  Why not just have a
couple of these:

static inline unsigned long zone_pages_min(struct zone *zone)
{
	return zone->pages_mark[ALLOC_WMARK_MIN];
}

and s/zone->pages_min/zone_pages_min(zone)/

?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
