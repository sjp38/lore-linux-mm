Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6300D6B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 00:22:42 -0400 (EDT)
Received: by wyb36 with SMTP id 36so1291971wyb.14
        for <linux-mm@kvack.org>; Wed, 15 Sep 2010 21:22:37 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 16 Sep 2010 00:22:37 -0400
Message-ID: <AANLkTikrasA6fD1b+0aMBO2RUH3vzg9w5rdt369h9Uqh@mail.gmail.com>
Subject: Investigating memory loss in kernel space..
From: Mohan G <mohan9271@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I am running a 2.6.27 based embedded linux for MIPS.  I can reproduce
a memory loss in kernel space by running a simple script

while true; do w >/dev/null; done

I am a VM newbie but it doesn't look like it's a leak.  I notice
through /proc/zoneinfo that nr_free goes down while nr_active goes up
for DMA zone forever until the OOM killer starts killing tasks.

Here is a snapshot of /proc/zoneinfo at t0.

Node 0, zone      DMA
 pages free     708328
       min      1919
       low      2398
       high     2878
       scanned  0 (a: 0 i: 0)
       spanned  1048064
       present  935944
   nr_free_pages 708328
   nr_inactive  118115
   nr_active    99415
   nr_anon_pages 3891
   nr_mapped    1747
   nr_file_pages 125801
   nr_dirty     0
   nr_writeback 0
   nr_slab_reclaimable 11158
   nr_slab_unreclaimable 6594
   nr_page_table_pages 362
   nr_unstable  0
   nr_bounce    0
   nr_vmscan_write 0
   nr_writeback_temp 0
       protection: (0, 56, 56)

Here is another snapshot at t0 + 5 mins running while true; do
w>/dev/null; done.

Node 0, zone      DMA
 pages free     644875
       min      1919
       low      2398
       high     2878
       scanned  0 (a: 0 i: 0)
       spanned  1048064
       present  935944
   nr_free_pages 644875
   nr_inactive  118114
   nr_active    163202
   nr_anon_pages 4378
   nr_mapped    1744
   nr_file_pages 125805
   nr_dirty     0
   nr_writeback 0
   nr_slab_reclaimable 11158
   nr_slab_unreclaimable 6822
   nr_page_table_pages 470
   nr_unstable  0
   nr_bounce    0
   nr_vmscan_write 0
   nr_writeback_temp 0
       protection: (0, 56, 56)

It just feels like active pages are not being balanced correctly. Any
pointers troubleshooting this are highly appreciated.

Many thanks.

-Mohan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
