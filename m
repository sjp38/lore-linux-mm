Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 73DFB6B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 04:40:23 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so254208362pac.0
        for <linux-mm@kvack.org>; Mon, 09 May 2016 01:40:23 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id u2si37601026pan.192.2016.05.09.01.40.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 May 2016 01:40:22 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id 145so15497239pfz.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 01:40:22 -0700 (PDT)
Date: Mon, 9 May 2016 17:41:55 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: fix zs_can_compact() integer overflow
Message-ID: <20160509084155.GA507@swordfish>
References: <1462779333-7092-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20160509080707.GB5434@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160509080707.GB5434@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "[4.3+]" <stable@vger.kernel.org>

Hello,

On (05/09/16 17:07), Minchan Kim wrote:
[..]
> > Depending on the circumstances, OBJ_ALLOCATED can become less
> > than OBJ_USED, which can result in either very high or negative
> > `total_scan' value calculated in do_shrink_slab().
> 
> So, do you see pr_err("shrink_slab: %pF negative objects xxxx)
> in vmscan.c and skip shrinking?

yes

 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-64
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-64
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-64
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-64
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62
 : vmscan: shrink_slab: zs_shrinker_scan+0x0/0x28 [zsmalloc] negative objects to delete nr=-62


> It would be better to explain what's the result without this patch
> and end-user effect for going -stable.

it seems that not every overflowed value returned from zs_can_compact()
is getting detected in do_shrink_slab():

	freeable = shrinker->count_objects(shrinker, shrinkctl);
	if (freeable == 0)
		return 0;

	/*
	 * copy the current shrinker scan count into a local variable
	 * and zero it so that other concurrent shrinker invocations
	 * don't also do this scanning work.
	 */
	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);

	total_scan = nr;
	delta = (4 * nr_scanned) / shrinker->seeks;
	delta *= freeable;
	do_div(delta, nr_eligible + 1);
	total_scan += delta;
	if (total_scan < 0) {
		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
		       shrinker->scan_objects, total_scan);
		total_scan = freeable;
	}

this calculation can hide the shrinker->count_objects() error. I added
some debugging code (on x86_64), and the output was:

[   59.041959] vmscan: >> OVERFLOW: shrinker->count_objects() == -1 [18446744073709551615]
[   59.041963] vmscan: >> but total_scan > 0: 92679974445502
[   59.041964] vmscan: >> resulting total_scan: 92679974445502

[   59.192734] vmscan: >> OVERFLOW: shrinker->count_objects() == -1 [18446744073709551615]
[   59.192737] vmscan: >> but total_scan > 0: 5830197242006811
[   59.192738] vmscan: >> resulting total_scan: 5830197242006811

[   59.259805] vmscan: >> OVERFLOW: shrinker->count_objects() == -1 [18446744073709551615]
[   59.259809] vmscan: >> but total_scan > 0: 23649671889371219
[   59.259810] vmscan: >> resulting total_scan: 23649671889371219

[   76.279767] vmscan: >> OVERFLOW: shrinker->count_objects() == -1 [18446744073709551615]
[   76.279770] vmscan: >> but total_scan > 0: 895907920044174
[   76.279771] vmscan: >> resulting total_scan: 895907920044174

[   84.807837] vmscan: >> OVERFLOW: shrinker->count_objects() == -1 [18446744073709551615]
[   84.807841] vmscan: >> but total_scan > 0: 22634041808232578
[   84.807842] vmscan: >> resulting total_scan: 22634041808232578

so we can end up with insanely huge total_scan values.

[..]
> > @@ -2262,10 +2262,13 @@ static void SetZsPageMovable(struct zs_pool *pool, struct zspage *zspage)
> 
> It seems this patch is based on my old page migration work?
> It's not go to the mainline yet but your patch which fixes the bug should
> be supposed to go to the -stable. So, I hope this patch first.

oops... my fat fingers! good catch, thanks! I have two versions: for -next and
-mmots (with your LRU rework applied, indeed). somehow I managed to cd to the
wrong dir. sorry, will resend.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
