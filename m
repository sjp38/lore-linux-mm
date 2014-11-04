Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 197AE6B009A
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 02:27:21 -0500 (EST)
Received: by mail-la0-f53.google.com with SMTP id mc6so346793lab.40
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 23:27:20 -0800 (PST)
Received: from tux-cave.hellug.gr (tux-cave.hellug.gr. [195.134.99.74])
        by mx.google.com with ESMTPS id lm8si36209142lac.7.2014.11.03.23.27.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 23:27:19 -0800 (PST)
From: "P. Christeas" <xrg@linux.gr>
Subject: Early test: hangs in mm/compact.c w. Linus's 12d7aacab56e9ef185c
Date: Tue, 04 Nov 2014 09:26:57 +0200
Message-ID: <12996532.NCRhVKzS9J@xorhgos3.pefnos>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

TL;DR: I'm testing Linus's 3.18-rcX in my desktop (x86_64, full load), 
experiencing mm races about every day. Current -rc starves the canary of 
stablity

Will keep testing (should I try some -mm tree, please? ) , provide you 
feedback about the issue.

Not an active kernel-developer.

Long:

Since 26 Oct. upgraded my everything-on-it laptop to new distro (systemd -
based, all new glibc etc.) and switched from 3.17 to 3.18-pre . First time in 
years, kernel got unstable.

This machine is occasionaly under heavy load, doing I/O and serving random 
desktop applications. (machine is Intel x86_64, dual core, mechanical SATA 
disk).
Now, I have a race about once a day, have narrowed them down (guess) to:
 
        [<ffffffff813b1025>] preempt_schedule_irq+0x3c/0x59
        [<ffffffff813b4810>] retint_kernel+0x20/0x30
        [<ffffffff810d7481>] ? __zone_watermark_ok+0x77/0x85
        [<ffffffff810d8256>] zone_watermark_ok+0x1a/0x1c
        [<ffffffff810eee56>] compact_zone+0x215/0x4b2
        [<ffffffff810ef13f>] compact_zone_order+0x4c/0x5f
        [<ffffffff810ef2fe>] try_to_compact_pages+0xc4/0x1e8
        [<ffffffff813ad7f8>] __alloc_pages_direct_compact+0x61/0x1bf
        [<ffffffff810da299>] __alloc_pages_nodemask+0x409/0x799
        [<ffffffff8110d3fd>] new_slab+0x5f/0x21c
       ...

Sometimes is a less critical process, that I can safely kill, otherwise I have 
to drop everything and reboot.

Unless you are already aware of this case, please accept this feedback.
I'm pulling from Linus, should I also try some of your trees for an early 
solution?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
