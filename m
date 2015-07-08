Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0B76B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 16:43:44 -0400 (EDT)
Received: by widjy10 with SMTP id jy10so227580277wid.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 13:43:43 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id bu10si5994736wjc.55.2015.07.08.13.43.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 13:43:42 -0700 (PDT)
Received: from [209.6.119.210] (helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1ZCwBq-0005mj-Fm
	for linux-mm@kvack.org; Wed, 08 Jul 2015 21:43:34 +0100
Date: Wed, 8 Jul 2015 16:43:34 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: 4.2rc1 odd looking page allocator failure stats
Message-ID: <20150708204334.GA15602@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I've got a box with 4GB of RAM that I've driven into oom (so much so that e1000 can't
alloc a single page, so I can't even ping it). But over serial console I noticed this..

[158831.710001] DMA32 free:1624kB min:6880kB low:8600kB high:10320kB active_anon:407004kB inactive_anon:799300kB active_file:516kB inactive_file:6644kB unevictable:0kB
 isolated(anon):0kB isolated(file):0kB present:3127220kB managed:3043108kB mlocked:0kB dirty:6680kB writeback:64kB mapped:31544kB shmem:1146792kB
 slab_reclaimable:46812kB slab_unreclaimable:388364kB kernel_stack:2288kB pagetables:2076kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
 free_cma:0kB writeback_tmp:0kB pages_scanned:70152496980 all_unreclaimable? yes

How come that 'pages_scanned' number is greater than the number of pages in the system ?
Does kswapd iterate over the same pages a number of times each time the page allocator fails ?


I've managed to hit this a couple times this week, where the oom killer kicks in, kills some
processes, but then the machine goes into a death spiral of looping in the page allocator.
Once that begins, it never tries to oom kill again, just hours of page allocation failure messages.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
