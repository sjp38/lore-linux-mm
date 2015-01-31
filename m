Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 31B846B0032
	for <linux-mm@kvack.org>; Sat, 31 Jan 2015 03:51:01 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id va8so16905550obc.10
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 00:51:00 -0800 (PST)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id lj10si6382547oeb.23.2015.01.31.00.51.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 31 Jan 2015 00:51:00 -0800 (PST)
Received: by mail-ob0-f181.google.com with SMTP id vb8so6612181obc.12
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 00:51:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150130080808.GA782@swordfish>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
	<1422432945-6764-2-git-send-email-minchan@kernel.org>
	<CADAEsF9tejvCL3gqGuYKsnv_wsfpsESsAg=Hm3r_ZfbpftE4-w@mail.gmail.com>
	<20150129151227.GA936@swordfish>
	<CADAEsF-1Y7_JM_1cq6+O3XASz8FAZoazjOF=x+oXFXuXUxK5Ng@mail.gmail.com>
	<20150130080808.GA782@swordfish>
Date: Sat, 31 Jan 2015 16:50:59 +0800
Message-ID: <CADAEsF-BztDePzMFAQ7zncXBTtS+iey79xf3sGzYeAjak0k-QQ@mail.gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>

2015-01-30 16:08 GMT+08:00 Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com>:
> On (01/30/15 15:52), Ganesh Mahendran wrote:
>> >> When I/O operation is running, that means the /dev/zram0 is
>> >> mounted or swaped on. Then the device could not be reset by
>> >> below code:
>> >>
>> >>     /* Do not reset an active device! */
>> >>     if (bdev->bd_holders) {
>> >>         ret = -EBUSY;
>> >>         goto out;
>> >>     }
>> >>
>> >> So the zram->init_lock in I/O path is to check whether the device
>> >> has been initialized(echo xxx > /sys/block/zram/disk_size).
>> >>
>>
>> Thanks for your explanation.
>>
>> >
>> > for mounted device (w/fs), we see initial (well, it goes up and down
>>
>> What does "w/" mean?
>
> 'with fs'
>
>> > many times while we create device, but this is not interesting here)
>> > ->bd_holders increment in:
>> >   vfs_kern_mount -> mount_bdev -> blkdev_get_by_path -> blkdev_get
>> >
>> > and it goes to zero in:
>> >   cleanup_mnt -> deactivate_super -> kill_block_super -> blkdev_put
>> >
>> >
>> > after umount we still have init device. so, *theoretically*, we
>> > can see something like
>> >
>> >         CPU0                            CPU1
>> > umount
>> > reset_store
>> > bdev->bd_holders == 0                   mount
>> > ...                                     zram_make_request()
>> > zram_reset_device()
>>
>> In this example, the data stored in zram will be corrupted.
>> Since CPU0 will free meta while CPU1 is using.
>> right?
>>
>
> with out ->init_lock protection in this case we have 'free' vs. 'use' race.

Maybe I did not explain clearly. I send a patch about this issue:

https://patchwork.kernel.org/patch/5754041/

Thanks

>
>>
>> >
>> > w/o zram->init_lock in both zram_reset_device() and zram_make_request()
>> > one of CPUs will be a bit sad.
>> what does "w/o" mean?
>
> 'with out'
>
>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
