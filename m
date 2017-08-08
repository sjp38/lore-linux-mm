Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1B456B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 21:01:59 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id 7so30932034ywe.0
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 18:01:59 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id b3si28334ybm.434.2017.08.07.18.01.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 18:01:58 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id p68so1337278ywg.5
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 18:01:58 -0700 (PDT)
From: Bradley Bolen <bradleybolen@gmail.com>
Subject: Re: kernel panic on null pointer on page->mem_cgroup
Date: Mon,  7 Aug 2017 21:01:50 -0400
Message-Id: <20170808010150.4155-1-bradleybolen@gmail.com>
In-Reply-To: <20170805155241.GA94821@jaegeuk-macbookpro.roam.corp.google.com>
References: <20170805155241.GA94821@jaegeuk-macbookpro.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: jaegeuk@kernel.org, Bradley Bolen <bradleybolen@gmail.com>

I am getting a very similar error on v4.11 with an arm64 board.

I, too, also see page->mem_cgroup checked to make sure that it is not
NULL and then several instructions later it is NULL.  It does appear
that someone is changing that member without taking the lock.  In my
setup, I see

crash> bt
PID: 72     TASK: e1f48640  CPU: 0   COMMAND: "mmcqd/1"
 #0 [<c00ad35c>] (__crash_kexec) from [<c0101080>]
 #1 [<c0101080>] (panic) from [<c028cd6c>]
 #2 [<c028cd6c>] (svcerr_panic) from [<c028cdc4>]
 #3 [<c028cdc4>] (_SvcErr_) from [<c001474c>]
 #4 [<c001474c>] (die) from [<c00241f8>]
 #5 [<c00241f8>] (__do_kernel_fault) from [<c0560600>]
 #6 [<c0560600>] (do_page_fault) from [<c00092e8>]
 #7 [<c00092e8>] (do_DataAbort) from [<c055f9f0>]
    pc : [<c0112540>]    lr : [<c0112518>]    psr: a0000193
    sp : c1a19cc8  ip : 00000000  fp : c1a19d04
    r10: 0006ae29  r9 : 00000000  r8 : dfbf1800
    r7 : dfbf1800  r6 : 00000001  r5 : f3c1107c  r4 : e2fb6424
    r3 : 00000000  r2 : 00040228  r1 : 221e3000  r0 : a0000113
    Flags: NzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM
 #8 [<c055f9f0>] (__dabt_svc) from [<c0112518>]
 #9 [<c0112540>] (test_clear_page_writeback) from [<c01046d4>]
#10 [<c01046d4>] (end_page_writeback) from [<c0149bcc>]
#11 [<c0149bcc>] (end_swap_bio_write) from [<c0261460>]
#12 [<c0261460>] (bio_endio) from [<c042c800>]
#13 [<c042c800>] (dec_pending) from [<c042e648>]
#14 [<c042e648>] (clone_endio) from [<c0261460>]
#15 [<c0261460>] (bio_endio) from [<bf60aa00>]
#16 [<bf60aa00>] (crypt_dec_pending [dm_crypt]) from [<bf60c1e8>]
#17 [<bf60c1e8>] (crypt_endio [dm_crypt]) from [<c0261460>]
#18 [<c0261460>] (bio_endio) from [<c0269e34>]
#19 [<c0269e34>] (blk_update_request) from [<c026a058>]
#20 [<c026a058>] (blk_update_bidi_request) from [<c026a444>]
#21 [<c026a444>] (blk_end_bidi_request) from [<c026a494>]
#22 [<c026a494>] (blk_end_request) from [<c0458dbc>]
#23 [<c0458dbc>] (mmc_blk_issue_rw_rq) from [<c0459e24>]
#24 [<c0459e24>] (mmc_blk_issue_rq) from [<c045a018>]
#25 [<c045a018>] (mmc_queue_thread) from [<c0048890>]
#26 [<c0048890>] (kthread) from [<c0010388>]
crash> sym c0112540
c0112540 (T) test_clear_page_writeback+512
 /kernel-source/include/linux/memcontrol.h: 518

crash> bt 35
PID: 35     TASK: e1d45dc0  CPU: 1   COMMAND: "kswapd0"
 #0 [<c0559ab8>] (__schedule) from [<c0559edc>]
 #1 [<c0559edc>] (schedule) from [<c055e54c>]
 #2 [<c055e54c>] (schedule_timeout) from [<c055a3a4>]
 #3 [<c055a3a4>] (io_schedule_timeout) from [<c0106cb0>]
 #4 [<c0106cb0>] (mempool_alloc) from [<c0261668>]
 #5 [<c0261668>] (bio_alloc_bioset) from [<c0149d68>]
 #6 [<c0149d68>] (get_swap_bio) from [<c014a280>]
 #7 [<c014a280>] (__swap_writepage) from [<c014a3bc>]
 #8 [<c014a3bc>] (swap_writepage) from [<c011e5c8>]
 #9 [<c011e5c8>] (shmem_writepage) from [<c011a9b8>]
#10 [<c011a9b8>] (shrink_page_list) from [<c011b528>]
#11 [<c011b528>] (shrink_inactive_list) from [<c011c160>]
#12 [<c011c160>] (shrink_node_memcg) from [<c011c400>]
#13 [<c011c400>] (shrink_node) from [<c011d7dc>]
#14 [<c011d7dc>] (kswapd) from [<c0048890>]
#15 [<c0048890>] (kthread) from [<c0010388>]

It appears that uncharge_list() in mm/memcontrol.c is not taking the
page lock when it sets mem_cgroup to NULL.  I am not familiar with the
mm code so I do not know if this is on purpose or not.  There is a
comment in uncharge_list that makes me believe that the crashing code
should not have been running:
/*
 * Nobody should be changing or seriously looking at
 * page->mem_cgroup at this point, we have fully
 * exclusive access to the page.
 */
However, I am new to looking at this area of the kernel so I am not
sure.

I was able to create a reproducible scenario by using a udelay to
increase the time between the if (page->mem_cgroup) check and the later
dereference of it to increase the race window.  I then mounted an empty
ext4 partition and ran the following no more than twice before it
crashed.
dd if=/dev/zero of=/tmp/ext4disk/test bs=1M count=100

I added page_lock/page_unlock to uncharge_list() and it fixes my
problem, but I do not know what other effects this would have.

Hopefully, some of this information can help someone more knowledgable
than me.

Thanks.

Brad Bolen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
