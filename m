Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id BB7A46B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 23:50:56 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so91240411pab.5
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 20:50:56 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id pj10si1064251pac.82.2015.02.02.20.50.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 20:50:55 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so91197613pab.6
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 20:50:55 -0800 (PST)
Date: Tue, 3 Feb 2015 13:50:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] zram: check bd_openers instead bd_holders
Message-ID: <20150203045046.GA13771@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On Tue, Feb 03, 2015 at 12:56:28PM +0900, Sergey Senozhatsky wrote:
> On (02/03/15 12:02), Minchan Kim wrote:
> > On Tue, Feb 03, 2015 at 10:54:33AM +0900, Sergey Senozhatsky wrote:
> > > On (02/02/15 16:06), Sergey Senozhatsky wrote:
> > > > So, guys, how about doing it differently, in less lines of code,
> > > > hopefully. Don't move reset_store()'s work to zram_reset_device().
> > > > Instead, move
> > > > 
> > > > 	set_capacity(zram->disk, 0);
> > > > 	revalidate_disk(zram->disk);
> > > > 
> > > > out from zram_reset_device() to reset_store(). this two function are
> > > > executed only when called from reset_store() anyway. this also will let
> > > > us drop `bool reset capacity' param from zram_reset_device().
> > > > 
> > > > 
> > > > so we will do in reset_store()
> > > > 
> > > > 	mutex_lock(bdev->bd_mutex);
> > > > 
> > > > 	fsync_bdev(bdev);
> > > > 	zram_reset_device(zram);
> > > > 	set_capacity(zram->disk, 0);
> > > > 
> > > > 	mutex_unlock(&bdev->bd_mutex);
> > > > 
> > > > 	revalidate_disk(zram->disk);
> > > > 	bdput(bdev);
> > > > 
> > > > 
> > > > 
> > > > and change zram_reset_device(zram, false) call to simply zram_reset_device(zram)
> > > > in __exit zram_exit(void).
> > > > 
> > > 
> > > Hello,
> > > 
> > > Minchan, Ganesh, I sent a patch last night, with the above solution.
> > > looks ok to you?
> > 
> > Just I sent a feedback.
> > 
> 
> thanks.
> yeah, !FMODE_EXCL mode.
> 
> how do you want to handle it -- you want to send a separate patch or
> you want me to send incremental one-liner and ask Andrew to squash them?

Send a new patch based on yours.
Thanks.
