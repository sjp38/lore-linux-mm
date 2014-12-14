Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5F83B6B0038
	for <linux-mm@kvack.org>; Sun, 14 Dec 2014 07:35:15 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id x12so12466403wgg.25
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 04:35:14 -0800 (PST)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com. [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id fn9si11928106wib.56.2014.12.14.04.35.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Dec 2014 04:35:14 -0800 (PST)
Received: by mail-wg0-f45.google.com with SMTP id b13so12496520wgh.32
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 04:35:14 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH] mempool.c: Replace io_schedule_timeout with io_schedule
Date: Sun, 14 Dec 2014 15:34:46 +0300
Message-Id: <1418560486-21685-1-git-send-email-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nefelim4ag@gmail.com, akpm@linux-foundation.org

io_schedule_timeout(5*HZ);
Introduced for avoidance dm bug:
http://linux.derkeiler.com/Mailing-Lists/Kernel/2006-08/msg04869.html
According to description must be replaced with io_schedule()

I replace it and recompile kernel, tested it by following script:
---
dev=""
block_dev=zram #loop
if [ "$block_dev" == "loop" ]; then
        f1=$RANDOM
        f2=${f1}_2
        truncate -s 256G ./$f1
        truncate -s 256G ./$f2
        dev="$(losetup -f --show ./$f1) $(losetup -f --show ./$f2)"
        rm ./$f1 ./$f2
else
        modprobe zram num_devices=8
        # needed ~1g free ram for test
        echo 128G > /sys/block/zram7/disksize
        echo 128G > /sys/block/zram6/disksize
        dev="/dev/zram7 /dev/zram6"
fi

md=/dev/md$[$RANDOM%8]
echo "y\n" | mdadm --create $md --chunk=4 --level=1 --raid-devices=2 $(echo $dev)
[ "$block_dev" == "loop" ] && losetup -d $(echo $dev) &

mkfs.xfs -f $md
mount $md /mnt

cat /dev/zero > /mnt/$RANDOM &
cat /dev/zero > /mnt/$RANDOM &
wait
umount -l /mnt
mdadm --stop $md

if [ "$block_dev" == "zram" ]; then
        echo 1 > /sys/block/zram7/reset
        echo 1 > /sys/block/zram6/reset
fi
---

i.e. i can't get this error for fast test with zram and slow test with loop devices

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
---
 mm/mempool.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/mempool.c b/mm/mempool.c
index e209c98..ae230c9 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -253,11 +253,7 @@ repeat_alloc:
 
 	spin_unlock_irqrestore(&pool->lock, flags);
 
-	/*
-	 * FIXME: this should be io_schedule().  The timeout is there as a
-	 * workaround for some DM problems in 2.6.18.
-	 */
-	io_schedule_timeout(5*HZ);
+	io_schedule();
 
 	finish_wait(&pool->wait, &wait);
 	goto repeat_alloc;
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
