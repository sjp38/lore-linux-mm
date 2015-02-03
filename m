Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 55B866B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 22:56:30 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so90634293pab.3
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 19:56:30 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id fa10si941550pdb.87.2015.02.02.19.56.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 19:56:29 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so90698348pab.5
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 19:56:29 -0800 (PST)
Date: Tue, 3 Feb 2015 12:56:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150203035628.GB454@swordfish>
References: <20150202034100.GF6402@blaptop>
 <20150202055923.GA332@swordfish>
 <20150202061812.GJ6402@blaptop>
 <20150202070604.GA666@swordfish>
 <20150203015433.GA454@swordfish>
 <20150203030235.GB1541@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150203030235.GB1541@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On (02/03/15 12:02), Minchan Kim wrote:
> On Tue, Feb 03, 2015 at 10:54:33AM +0900, Sergey Senozhatsky wrote:
> > On (02/02/15 16:06), Sergey Senozhatsky wrote:
> > > So, guys, how about doing it differently, in less lines of code,
> > > hopefully. Don't move reset_store()'s work to zram_reset_device().
> > > Instead, move
> > > 
> > > 	set_capacity(zram->disk, 0);
> > > 	revalidate_disk(zram->disk);
> > > 
> > > out from zram_reset_device() to reset_store(). this two function are
> > > executed only when called from reset_store() anyway. this also will let
> > > us drop `bool reset capacity' param from zram_reset_device().
> > > 
> > > 
> > > so we will do in reset_store()
> > > 
> > > 	mutex_lock(bdev->bd_mutex);
> > > 
> > > 	fsync_bdev(bdev);
> > > 	zram_reset_device(zram);
> > > 	set_capacity(zram->disk, 0);
> > > 
> > > 	mutex_unlock(&bdev->bd_mutex);
> > > 
> > > 	revalidate_disk(zram->disk);
> > > 	bdput(bdev);
> > > 
> > > 
> > > 
> > > and change zram_reset_device(zram, false) call to simply zram_reset_device(zram)
> > > in __exit zram_exit(void).
> > > 
> > 
> > Hello,
> > 
> > Minchan, Ganesh, I sent a patch last night, with the above solution.
> > looks ok to you?
> 
> Just I sent a feedback.
> 

thanks.
yeah, !FMODE_EXCL mode.

how do you want to handle it -- you want to send a separate patch or
you want me to send incremental one-liner and ask Andrew to squash them?

	-ss

> > 
> > Minchan, I think I'll send my small struct zram clean-up patch after
> > your init_lock patch. what's your opinion?
> 
> Good for me.
> 
> Thanks.
> -- 
> Kind regards,
> Minchan Kim
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
