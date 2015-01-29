Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id AA3CF6B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 10:11:57 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so40146005pac.2
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 07:11:57 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id ww10si10143191pab.186.2015.01.29.07.11.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 07:11:56 -0800 (PST)
Received: by mail-pa0-f50.google.com with SMTP id rd3so40069413pab.9
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 07:11:55 -0800 (PST)
Date: Fri, 30 Jan 2015 00:12:27 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150129151227.GA936@swordfish>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
 <1422432945-6764-2-git-send-email-minchan@kernel.org>
 <CADAEsF9tejvCL3gqGuYKsnv_wsfpsESsAg=Hm3r_ZfbpftE4-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADAEsF9tejvCL3gqGuYKsnv_wsfpsESsAg=Hm3r_ZfbpftE4-w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com

On (01/29/15 21:48), Ganesh Mahendran wrote:
> > Admin could reset zram during I/O operation going on so we have
> > used zram->init_lock as read-side lock in I/O path to prevent
> > sudden zram meta freeing.
> 
> When I/O operation is running, that means the /dev/zram0 is
> mounted or swaped on. Then the device could not be reset by
> below code:
> 
>     /* Do not reset an active device! */
>     if (bdev->bd_holders) {
>         ret = -EBUSY;
>         goto out;
>     }
> 
> So the zram->init_lock in I/O path is to check whether the device
> has been initialized(echo xxx > /sys/block/zram/disk_size).
> 

for mounted device (w/fs), we see initial (well, it goes up and down
many times while we create device, but this is not interesting here)
->bd_holders increment in:
  vfs_kern_mount -> mount_bdev -> blkdev_get_by_path -> blkdev_get

and it goes to zero in:
  cleanup_mnt -> deactivate_super -> kill_block_super -> blkdev_put


after umount we still have init device. so, *theoretically*, we
can see something like

	CPU0				CPU1
umount
reset_store			
bdev->bd_holders == 0			mount
...					zram_make_request()
zram_reset_device()

w/o zram->init_lock in both zram_reset_device() and zram_make_request()
one of CPUs will be a bit sad.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
