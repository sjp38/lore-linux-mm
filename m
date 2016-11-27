Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0189A6B0253
	for <linux-mm@kvack.org>; Sun, 27 Nov 2016 08:20:27 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x23so297064042pgx.6
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 05:20:26 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id p124si51590856pga.159.2016.11.27.05.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Nov 2016 05:20:26 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id i88so5031298pfk.2
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 05:20:26 -0800 (PST)
Date: Sun, 27 Nov 2016 22:19:10 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v3 1/3] mm: support anonymous stable page
Message-ID: <20161127131910.GB4919@tigerII>
References: <1480062914-25556-1-git-send-email-minchan@kernel.org>
 <1480062914-25556-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480062914-25556-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Takashi Iwai <tiwai@suse.de>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, Sangseok Lee <sangseok.lee@lge.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, "Darrick J . Wong" <darrick.wong@oracle.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hi,

On (11/25/16 17:35), Minchan Kim wrote:
[..]
> Unfortunately, zram has used per-cpu stream feature from v4.7.
> It aims for increasing cache hit ratio of scratch buffer for
> compressing. Downside of that approach is that zram should ask
> memory space for compressed page in per-cpu context which requires
> stricted gfp flag which could be failed. If so, it retries to
> allocate memory space out of per-cpu context so it could get memory
> this time and compress the data again, copies it to the memory space.
> 
> In this scenario, zram assumes the data should never be changed
> but it is not true unless stable page supports. So, If the data is
> changed under us, zram can make buffer overrun because second
> compression size could be bigger than one we got in previous trial
> and blindly, copy bigger size object to smaller buffer which is
> buffer overrun. The overrun breaks zsmalloc free object chaining
> so system goes crash like above.

very interesting find! didn't see this coming.

> Unfortunately, reuse_swap_page should be atomic so that we cannot wait on
> writeback in there so the approach in this patch is simply return false if
> we found it needs stable page.  Although it increases memory footprint
> temporarily, it happens rarely and it should be reclaimed easily althoug
> it happened.  Also, It would be better than waiting of IO completion,
> which is critial path for application latency.

wondering - how many pages can it hold? we are in low memory, that's why we
failed to zsmalloc in fast path, so how likely this to worsen memory pressure?
just asking. in async zram the window between zram_rw_page() and actual
write of a page even bigger, isn't it?

we *probably* and *may be* can try handle it in zram:

-- store the previous clen before re-compression
-- check if new clen > saved_clen and if it is - we can't use previously
   allocate handle and need to allocate a new one again. if it's less or
   equal than the saved one - store the object (wasting some space,
   yes. but we are in low mem).

-- we, may be, also can try harder in zsmalloc. once we detected that
   zsmllaoc has failed, then we can declare it as an emergency and
   store objects of size X in higher classes (assuming that there is a
   bigger size class available with allocated and unused object).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
