Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id A19C16B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 02:52:23 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id wp4so22564709obc.6
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 23:52:23 -0800 (PST)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id i186si4971279oib.70.2015.01.29.23.52.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 23:52:23 -0800 (PST)
Received: by mail-oi0-f44.google.com with SMTP id a3so33482744oib.3
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 23:52:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150129151227.GA936@swordfish>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
	<1422432945-6764-2-git-send-email-minchan@kernel.org>
	<CADAEsF9tejvCL3gqGuYKsnv_wsfpsESsAg=Hm3r_ZfbpftE4-w@mail.gmail.com>
	<20150129151227.GA936@swordfish>
Date: Fri, 30 Jan 2015 15:52:22 +0800
Message-ID: <CADAEsF-1Y7_JM_1cq6+O3XASz8FAZoazjOF=x+oXFXuXUxK5Ng@mail.gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, sergey.senozhatsky.work@gmail.com

Hello Sergey

2015-01-29 23:12 GMT+08:00 Sergey Senozhatsky <sergey.senozhatsky@gmail.com>:
> On (01/29/15 21:48), Ganesh Mahendran wrote:
>> > Admin could reset zram during I/O operation going on so we have
>> > used zram->init_lock as read-side lock in I/O path to prevent
>> > sudden zram meta freeing.
>>
>> When I/O operation is running, that means the /dev/zram0 is
>> mounted or swaped on. Then the device could not be reset by
>> below code:
>>
>>     /* Do not reset an active device! */
>>     if (bdev->bd_holders) {
>>         ret = -EBUSY;
>>         goto out;
>>     }
>>
>> So the zram->init_lock in I/O path is to check whether the device
>> has been initialized(echo xxx > /sys/block/zram/disk_size).
>>

Thanks for your explanation.

>
> for mounted device (w/fs), we see initial (well, it goes up and down

What does "w/" mean?

> many times while we create device, but this is not interesting here)
> ->bd_holders increment in:
>   vfs_kern_mount -> mount_bdev -> blkdev_get_by_path -> blkdev_get
>
> and it goes to zero in:
>   cleanup_mnt -> deactivate_super -> kill_block_super -> blkdev_put
>
>
> after umount we still have init device. so, *theoretically*, we
> can see something like
>
>         CPU0                            CPU1
> umount
> reset_store
> bdev->bd_holders == 0                   mount
> ...                                     zram_make_request()
> zram_reset_device()

In this example, the data stored in zram will be corrupted.
Since CPU0 will free meta while CPU1 is using.
right?


>
> w/o zram->init_lock in both zram_reset_device() and zram_make_request()
> one of CPUs will be a bit sad.
what does "w/o" mean?

Thanks

>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
