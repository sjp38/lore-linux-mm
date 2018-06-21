Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8BE96B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 23:03:30 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id q19-v6so925698plr.22
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 20:03:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 33-v6sor1385391plt.9.2018.06.20.20.03.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 20:03:28 -0700 (PDT)
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Subject: [BUG] mm: backing-dev: a possible sleep-in-atomic-context bug in
 cgwb_create()
Message-ID: <626acba3-c565-7e05-6c8b-0d100ff645c5@gmail.com>
Date: Thu, 21 Jun 2018 11:02:58 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, akpm@linux-foundation.or, jack@suse.cz, zhangweiping@didichuxing.com, sergey.senozhatsky@gmail.com, andriy.shevchenko@linux.intel.com, christophe.jaillet@wanadoo.fr, aryabinin@virtuozzo.com
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

The kernel may sleep with holding a spinlock.
The function call path (from bottom to top) in Linux-4.16.7 is:

[FUNC] schedule
lib/percpu-refcount.c, 222:
         schedule in __percpu_ref_switch_mode
lib/percpu-refcount.c, 339:
         __percpu_ref_switch_mode in percpu_ref_kill_and_confirm
./include/linux/percpu-refcount.h, 127:
         percpu_ref_kill_and_confirm in percpu_ref_kill
mm/backing-dev.c, 545:
         percpu_ref_kill in cgwb_kill
mm/backing-dev.c, 576:
         cgwb_kill in cgwb_create
mm/backing-dev.c, 573:
         _raw_spin_lock_irqsave in cgwb_create

This bug is found by my static analysis tool (DSAC-2) and checked by my
code review.

I do not know how to correctly fix this bug, so I just report them.
Maybe cgwb_kill() should not be called with holding a spinlock.


Best wishes,
Jia-Ju Bai
