Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 189F56B0038
	for <linux-mm@kvack.org>; Sun,  1 Feb 2015 23:01:27 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so77024809pad.7
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 20:01:26 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id fz11si22004206pdb.238.2015.02.01.20.01.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 20:01:26 -0800 (PST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so77024703pad.7
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 20:01:26 -0800 (PST)
Date: Mon, 2 Feb 2015 13:01:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150202040124.GE6977@swordfish>
References: <20150129022241.GA2555@swordfish>
 <20150129052827.GB25462@blaptop>
 <20150129060604.GC2555@swordfish>
 <20150129063505.GA32331@blaptop>
 <20150129070835.GD2555@swordfish>
 <20150130144145.GA2840@blaptop>
 <20150201145036.GA1290@swordfish>
 <20150202013028.GB6402@blaptop>
 <20150202014800.GA6977@swordfish>
 <20150202024405.GD6402@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150202024405.GD6402@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On (02/02/15 11:44), Minchan Kim wrote:
> > sure, I did think about this. and I actually didn't find any reason not
> > to use ->refcount there. if user wants to reset the device, he first
> > should umount it to make bdev->bd_holders check happy. and that's where
> > IOs will be failed. so it makes sense to switch to ->refcount there, IMHO.
> 
> If we use zram as block device itself(not a fs or swap) and open the
> block device as !FMODE_EXCL, bd_holders will be void.
> 

hm.
I don't mind to use ->disksize there, but personally I'd maybe prefer
to use ->refcount, which just looks less hacky. zram's most common use
cases are coming from ram swap device or ram device with fs. so it looks
a bit like we care about some corner case here.

just my opinion, no objections against ->disksize != 0.

I need to check fs/block_dev. can we switch away from ->bd_holders?

> Another topic: As I didn't see enough fs/block_dev.c bd_holders in zram
> would be mess. I guess we need to study hotplug of device and implement
> it for zram reset rather than strange own konb. It should go TODO. :(

ok, need to investigate this later.
let's land current activities first.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
