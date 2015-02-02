Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CF37E6B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 02:06:29 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so78688451pab.6
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 23:06:29 -0800 (PST)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id g1si22428727pdn.224.2015.02.01.23.06.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 23:06:28 -0800 (PST)
Received: by mail-pa0-f68.google.com with SMTP id lj1so42399170pab.3
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 23:06:28 -0800 (PST)
Date: Mon, 2 Feb 2015 16:06:29 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150202070604.GA666@swordfish>
References: <20150202034100.GF6402@blaptop>
 <20150202055923.GA332@swordfish>
 <20150202061812.GJ6402@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150202061812.GJ6402@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On (02/02/15 15:18), Minchan Kim wrote:
> > a quick idea:
> > can we additionally move all bd flush and put work after zram_reset_device(zram, true)
> > and, perhaps, replace ->bd_holders with something else?
> > 
> > zram_reset_device() will not return until we have active IOs, pending IOs will be
> > invalidated by ->disksize != 0.
> 
> Sorry, I don't get it. Could you describe what you are concerning about active I/O?
> My concern is just race bd_holder/bd_openers and bd_holders of zram check.
> I don't think any simple solution without bd_mutex.
> If we can close the race, anything could be a solution.
> If we close the race, we should return -EBUSY if anyone is opening the zram device
> so bd_openers check would be better than bd_holders.
> 

yeah, sorry. nevermind.


So, guys, how about doing it differently, in less lines of code,
hopefully. Don't move reset_store()'s work to zram_reset_device().
Instead, move

	set_capacity(zram->disk, 0);
	revalidate_disk(zram->disk);

out from zram_reset_device() to reset_store(). this two function are
executed only when called from reset_store() anyway. this also will let
us drop `bool reset capacity' param from zram_reset_device().


so we will do in reset_store()

	mutex_lock(bdev->bd_mutex);

	fsync_bdev(bdev);
	zram_reset_device(zram);
	set_capacity(zram->disk, 0);

	mutex_unlock(&bdev->bd_mutex);

	revalidate_disk(zram->disk);
	bdput(bdev);



and change zram_reset_device(zram, false) call to simply zram_reset_device(zram)
in __exit zram_exit(void).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
