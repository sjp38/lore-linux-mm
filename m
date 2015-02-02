Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1C02E6B006E
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 01:18:26 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so78201919pab.6
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 22:18:25 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id e10si22380891pdp.183.2015.02.01.22.18.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 22:18:25 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so78304099pad.8
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 22:18:25 -0800 (PST)
Date: Mon, 2 Feb 2015 15:18:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150202061812.GJ6402@blaptop>
References: <20150202034100.GF6402@blaptop>
 <20150202055923.GA332@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150202055923.GA332@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On Mon, Feb 02, 2015 at 02:59:23PM +0900, Sergey Senozhatsky wrote:
> On (02/02/15 12:41), Minchan Kim wrote:
> > > If we use zram as block device itself(not a fs or swap) and open the
> > > block device as !FMODE_EXCL, bd_holders will be void.
> > > 
> > > Another topic: As I didn't see enough fs/block_dev.c bd_holders in zram
> > > would be mess. I guess we need to study hotplug of device and implement
> > > it for zram reset rather than strange own konb. It should go TODO. :(
> > 
> > Actually, I thought bd_mutex use from custom driver was terrible idea
> > so we should walk around with device hotplug but as I look through
> > another drivers, they have used the lock for a long time.
> > Maybe it's okay to use it in zram?
> > If so, Ganesh's patch is no problem to me although I didn't' review it in detail.
> > One thing I want to point out is that it would be better to change bd_holders
> > with bd_openers to filter out because dd test opens block device as !EXCL
> > so bd_holders will be void.
> > 
> > What do you think about it?
> > 
> 
> a quick idea:
> can we additionally move all bd flush and put work after zram_reset_device(zram, true)
> and, perhaps, replace ->bd_holders with something else?
> 
> zram_reset_device() will not return until we have active IOs, pending IOs will be
> invalidated by ->disksize != 0.

Sorry, I don't get it. Could you describe what you are concerning about active I/O?
My concern is just race bd_holder/bd_openers and bd_holders of zram check.
I don't think any simple solution without bd_mutex.
If we can close the race, anything could be a solution.
If we close the race, we should return -EBUSY if anyone is opening the zram device
so bd_openers check would be better than bd_holders.

> 
> 	-ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
