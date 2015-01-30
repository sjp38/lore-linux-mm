Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0B1506B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 03:08:12 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so49476314pab.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 00:08:11 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id o6si13072489pdm.4.2015.01.30.00.08.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 00:08:11 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so49476213pab.5
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 00:08:11 -0800 (PST)
Date: Fri, 30 Jan 2015 17:08:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150130080808.GA782@swordfish>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
 <1422432945-6764-2-git-send-email-minchan@kernel.org>
 <CADAEsF9tejvCL3gqGuYKsnv_wsfpsESsAg=Hm3r_ZfbpftE4-w@mail.gmail.com>
 <20150129151227.GA936@swordfish>
 <CADAEsF-1Y7_JM_1cq6+O3XASz8FAZoazjOF=x+oXFXuXUxK5Ng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADAEsF-1Y7_JM_1cq6+O3XASz8FAZoazjOF=x+oXFXuXUxK5Ng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, sergey.senozhatsky.work@gmail.com

On (01/30/15 15:52), Ganesh Mahendran wrote:
> >> When I/O operation is running, that means the /dev/zram0 is
> >> mounted or swaped on. Then the device could not be reset by
> >> below code:
> >>
> >>     /* Do not reset an active device! */
> >>     if (bdev->bd_holders) {
> >>         ret = -EBUSY;
> >>         goto out;
> >>     }
> >>
> >> So the zram->init_lock in I/O path is to check whether the device
> >> has been initialized(echo xxx > /sys/block/zram/disk_size).
> >>
> 
> Thanks for your explanation.
> 
> >
> > for mounted device (w/fs), we see initial (well, it goes up and down
> 
> What does "w/" mean?

'with fs'

> > many times while we create device, but this is not interesting here)
> > ->bd_holders increment in:
> >   vfs_kern_mount -> mount_bdev -> blkdev_get_by_path -> blkdev_get
> >
> > and it goes to zero in:
> >   cleanup_mnt -> deactivate_super -> kill_block_super -> blkdev_put
> >
> >
> > after umount we still have init device. so, *theoretically*, we
> > can see something like
> >
> >         CPU0                            CPU1
> > umount
> > reset_store
> > bdev->bd_holders == 0                   mount
> > ...                                     zram_make_request()
> > zram_reset_device()
> 
> In this example, the data stored in zram will be corrupted.
> Since CPU0 will free meta while CPU1 is using.
> right?
> 

with out ->init_lock protection in this case we have 'free' vs. 'use' race.

> 
> >
> > w/o zram->init_lock in both zram_reset_device() and zram_make_request()
> > one of CPUs will be a bit sad.
> what does "w/o" mean?

'with out'


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
