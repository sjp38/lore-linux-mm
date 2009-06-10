Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F3BD66B005D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 21:50:49 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5A1qPsA018840
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 10 Jun 2009 10:52:25 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C921145DE87
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 10:52:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CF0F45DE7E
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 10:52:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB2851DB8046
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 10:52:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D4A6F1DB8042
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 10:52:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] Do not unconditionally treat zones that fail zone_reclaim() as full
In-Reply-To: <1244566904-31470-3-git-send-email-mel@csn.ul.ie>
References: <1244566904-31470-1-git-send-email-mel@csn.ul.ie> <1244566904-31470-3-git-send-email-mel@csn.ul.ie>
Message-Id: <20090610104935.DDA9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Jun 2009 10:52:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

>  			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
> -			if (!zone_watermark_ok(zone, order, mark,
> -				    classzone_idx, alloc_flags)) {
> -				if (!zone_reclaim_mode ||
> -				    !zone_reclaim(zone, gfp_mask, order))
> +			if (zone_watermark_ok(zone, order, mark,
> +				    classzone_idx, alloc_flags))
> +				goto try_this_zone;
> +
> +			if (zone_reclaim_mode == 0)
> +				goto this_zone_full;
> +
> +			ret = zone_reclaim(zone, gfp_mask, order);
> +			switch (ret) {
> +			case ZONE_RECLAIM_NOSCAN:
> +				/* did not scan */
> +				goto try_next_zone;
> +			case ZONE_RECLAIM_FULL:
> +				/* scanned but unreclaimable */
> +				goto this_zone_full;
> +			default:
> +				/* did we reclaim enough */
> +				if (!zone_watermark_ok(zone, order, mark,
> +						classzone_idx, alloc_flags))
>  					goto this_zone_full;

ok, this version's change are minimal than previous.
I'm not afraid this patch now. thanks.


	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
