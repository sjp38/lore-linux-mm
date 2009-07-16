Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDA26B0062
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 00:02:59 -0400 (EDT)
Date: Wed, 15 Jul 2009 21:02:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] throttle direct reclaim when too many pages are
 isolated already (v3)
Message-Id: <20090715210253.bc137b2d.akpm@linux-foundation.org>
In-Reply-To: <20090715235318.6d2f5247@bree.surriel.com>
References: <20090715223854.7548740a@bree.surriel.com>
	<20090715194820.237a4d77.akpm@linux-foundation.org>
	<4A5E9A33.3030704@redhat.com>
	<20090715202114.789d36f7.akpm@linux-foundation.org>
	<4A5E9E4E.5000308@redhat.com>
	<20090715203854.336de2d5.akpm@linux-foundation.org>
	<20090715235318.6d2f5247@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009 23:53:18 -0400 Rik van Riel <riel@redhat.com> wrote:

> @@ -1049,6 +1074,14 @@ static unsigned long shrink_inactive_lis
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>  	int lumpy_reclaim = 0;
>  
> +	while (unlikely(too_many_isolated(zone, file, sc))) {
> +		congestion_wait(WRITE, HZ/10);
> +
> +		/* We are about to die and free our memory. Return now. */
> +		if (fatal_signal_pending(current))
> +			return SWAP_CLUSTER_MAX;
> +	}

mutter.

While I agree that handling fatal signals on the direct reclaim path
is probably a good thing, this seems like a fairly random place at
which to start the enhancement.

If we were to step back and approach this in a broader fashion, perhaps
we would find some commonality with the existing TIF_MEMDIE handling,
dunno.


And I question the testedness of v3 :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
