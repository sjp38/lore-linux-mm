Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id CE1386B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 09:26:23 -0500 (EST)
Received: by ykdr82 with SMTP id r82so195307600ykd.3
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 06:26:23 -0800 (PST)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com. [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id 203si15708029ywy.356.2015.12.07.06.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 06:26:23 -0800 (PST)
Received: by ykba77 with SMTP id a77so195432845ykb.2
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 06:26:22 -0800 (PST)
Date: Mon, 7 Dec 2015 09:26:21 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: undefined shift in wb_update_dirty_ratelimit()
Message-ID: <20151207142621.GA7012@mtj.duckdns.org>
References: <566594E2.3050306@odin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <566594E2.3050306@odin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@odin.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Sasha Levin <sasha.levin@oracle.com>

Hello, Andrey.

On Mon, Dec 07, 2015 at 05:17:06PM +0300, Andrey Ryabinin wrote:
> I've hit undefined shift in wb_update_dirty_ratelimit() which does some
> mysterious 'step' calculations:
> 
> 	/*
> 	 * Don't pursue 100% rate matching. It's impossible since the balanced
> 	 * rate itself is constantly fluctuating. So decrease the track speed
> 	 * when it gets close to the target. Helps eliminate pointless tremors.
> 	 */
> 	step >>= dirty_ratelimit / (2 * step + 1);
> 
> 
> dirty_ratelimit = INIT_BW and step = 0 results in this:
> 
> [ 5006.957366] ================================================================================
> [ 5006.957798] UBSAN: Undefined behaviour in ../mm/page-writeback.c:1286:7
> [ 5006.958091] shift exponent 25600 is too large for 64-bit type 'long unsigned int'

We prolly should do sth like

	shift = dirty_ratelimit / (2 * step = 1);
	if (shift < BITS_PER_LONG) {
		step = (step >> shift) + 7 / 8;
	} else {
		step = 0;
	}

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
