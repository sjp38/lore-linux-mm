Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8295890010B
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 14:39:02 -0400 (EDT)
Received: by pzk4 with SMTP id 4so2389572pzk.14
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 11:39:00 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 28 Apr 2011 20:39:00 +0200
Message-ID: <BANLkTinhK_K1oSJDEoqD6EQK8Qy5Wy3v+g@mail.gmail.com>
Subject: mmc blkqueue is empty even if there are pending reads in do_generic_file_read()
From: Per Forlin <per.forlin@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-mmc@vger.kernel.org, linaro-kernel@lists.linaro.org

Hi,

I am working on minimizing the latency between two block requests in
the mmc framework. The approach is simple. If there are more than one
request in the block queue the 2nd request will be prepared while the
1st request is being transfered. When the 1 st request is completed
the 2nd request will start with minimal latency cost.

For writes this work fine:
root@(none):/ dd of=/dev/mmcblk0p2 if=/dev/zero bs=4k count=2560
2560+0 records in
2560+0 records out
root@(none):/ dmesg
[mmc_queue_thread] req d97a2ac8 blocks 1024
[mmc_queue_thread] req d97a2ba0 blocks 1024
[mmc_queue_thread] req d97a2c78 blocks 1024
[mmc_queue_thread] req d97a2d50 blocks 1024
[mmc_queue_thread] req d97a2e28 blocks 1024
[mmc_queue_thread] req d97a2f00 blocks 1024
[mmc_queue_thread] req d954c9b0 blocks 1024
[mmc_queue_thread] req d954c800 blocks 1024
[mmc_queue_thread] req d954c728 blocks 1024
[mmc_queue_thread] req d954c650 blocks 1024
[mmc_queue_thread] req d954c578 blocks 1024
[mmc_queue_thread] req d954c4a0 blocks 1024
[mmc_queue_thread] req d954c8d8 blocks 1024
[mmc_queue_thread] req d954c3c8 blocks 1024
[mmc_queue_thread] req d954c2f0 blocks 1024
[mmc_queue_thread] req d954c218 blocks 1024
[mmc_queue_thread] req d954c140 blocks 1024
[mmc_queue_thread] req d954c068 blocks 1024
[mmc_queue_thread] req d954cde8 blocks 1024
[mmc_queue_thread] req d954cec0 blocks 1024
mmc block queue is never empty. All the mmc request preparations can
run in parallel with an ongoing transfer.

[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req   (null) blocks 0
"req (null)" indicates there are no requests pending in the mmc block
queue. This is expected since there are no more requests to process.

For reads on the other hand it look like this
root@(none):/ dd if=/dev/mmcblk0 of=/dev/null bs=4k count=256
256+0 records in
256+0 records out
root@(none):/ dmesg
[mmc_queue_thread] req d954cec0 blocks 32
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req d954cec0 blocks 64
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req d954cde8 blocks 128
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req d954cec0 blocks 256
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req d954cde8 blocks 256
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req d954cec0 blocks 256
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req d954cde8 blocks 256
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req d954cec0 blocks 256
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req d954cde8 blocks 256
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req d954cec0 blocks 256
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req d954cde8 blocks 256
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req d954cec0 blocks 256
[mmc_queue_thread] req   (null) blocks 0
[mmc_queue_thread] req   (null) blocks 0
There are never more than one read request in the mmc block queue. All
the mmc request preparations will be serialized and the cost for this
is roughly 10% lower bandwidth (verified on ARM platforms ux500 and
Pandaboard).

> page_not_up_to_date:
> /* Get exclusive access to the page ... */
> error = lock_page_killable(page);
I looked at the code in do_generic_file_read(). lock_page_killable
waits until the current read ahead is completed.
Is it possible to configure the read ahead to push multiple read
request to the block device queue?

Thanks,
Per

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
