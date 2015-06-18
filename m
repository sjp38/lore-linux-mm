Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6866B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 08:13:58 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so65462154pdj.3
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 05:13:57 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id di10si11141396pdb.34.2015.06.18.05.13.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 05:13:57 -0700 (PDT)
Received: by pdjm12 with SMTP id m12so65461904pdj.3
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 05:13:56 -0700 (PDT)
Date: Thu, 18 Jun 2015 21:13:14 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCHv3 2/7] zsmalloc: partial page ordering within a
 fullness_list
Message-ID: <20150618121314.GA518@swordfish>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1434628004-11144-3-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434628004-11144-3-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

Minchan, I didn't publish this patch separately yet, mostly to keep
the discussion in on thread. If we decide that this patch is good
enough, I'll resubmit it separately.

I did some synthetic testing. And (not surprising at all) its not so
clear. Any

I used a modified zsmalloc debug stats (to also account and report ZS_FULL
zspages). Automatic compaction was disabled.

the results are:

              almost_full         full almost_empty obj_allocated   obj_used pages_used
Base
 Total                 3          163           25          2265       1691        302
 Total                 2          161           26          2297       1688        298
 Total                 2          145           27          2396       1701        311
 Total                 3          152           26          2364       1696        312
 Total                 3          162           25          2243       1701        302

Patched
 Total                 3          155           22          2259       1691        293
 Total                 4          153           20          2177       1697        292
 Total                 2          157           23          2229       1696        298
 Total                 2          164           24          2242       1694        301
 Total                 2          159           24          2286       1696        301


Sooo... I don't know. The numbers are weird. On my x86_64 I saw somewhat
lowered 'almost_empty', 'obj_allocated', 'obj_used', 'pages_used'. But
it's a bit suspicious.

The patch was not expected to dramatically improve things anyway. It's
rather a theoretical improvement -- we sometimes keep busiest zspages first
and, at the same time, we can re-use recently used zspages.


I think it makes sense to also consider 'fullness_group fullness' in
insert_zspage(). Unconditionally put ZS_ALMOST_FULL pages to list
head, or (if zspage is !ZS_ALMOST_FULL) compage ->inuse.

IOW, something like this

---

 mm/zsmalloc.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 692b7dc..d576397 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -645,10 +645,11 @@ static void insert_zspage(struct page *page, struct size_class *class,
 		 * We want to see more ZS_FULL pages and less almost
 		 * empty/full. Put pages with higher ->inuse first.
 		 */
-		if (page->inuse < (*head)->inuse)
-			list_add_tail(&page->lru, &(*head)->lru);
-		else
+		if (fullness == ZS_ALMOST_FULL ||
+				(page->inuse >= (*head)->inuse))
 			list_add(&page->lru, &(*head)->lru);
+		else
+			list_add_tail(&page->lru, &(*head)->lru);
 	}
 
 	*head = page;

---

test script

modprobe zram
echo 4 > /sys/block/zram0/max_comp_streams
echo lzo > /sys/block/zram0/comp_algorithm
echo 3g > /sys/block/zram0/disksize
mkfs.ext4 /dev/zram0
mount -o relatime,defaults /dev/zram0 /zram

cd /zram/
sync

for i in {1..8192}; do
        dd if=/media/dump/down/zero_file of=/zram/$i iflag=direct bs=4K count=20 > /dev/null 2>&1
done

sync

head -n 1 /sys/kernel/debug/zsmalloc/zram0/classes
tail -n 1 /sys/kernel/debug/zsmalloc/zram0/classes

cd /
umount /zram
rmmod zram


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
