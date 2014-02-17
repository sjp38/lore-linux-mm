Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 380F46B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 02:50:54 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id f8so2075400wiw.9
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 23:50:53 -0800 (PST)
Received: from mail-wg0-x243.google.com (mail-wg0-x243.google.com [2a00:1450:400c:c00::243])
        by mx.google.com with ESMTPS id hu4si9691723wjb.92.2014.02.16.23.50.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 16 Feb 2014 23:50:52 -0800 (PST)
Received: by mail-wg0-f67.google.com with SMTP id n12so1054511wgh.2
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 23:50:52 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 17 Feb 2014 15:50:52 +0800
Message-ID: <CAGbhdVxwWOyfEzF-fcYpyBCpi2g9Jtz-8Hfzf6=3rGk6Z+dFRg@mail.gmail.com>
Subject: page->mapping invalid issue
From: Lisa Du <chunlingdu1@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi, All
   Recently I met a kernel panic issue which shows that one
page->mapping already invalid.
   This issue is hard to reproduce but we met over 4 times, for
example in below case, the page->mapping already change to other
usage. In other cases, we also met the page->mapping was changed to
free_area. We are using kernel v3.4. Compaction and ZRAM swap was
configured.
   I know when anon_vma and anon_vma_chain first used/enabled in
kenrel2.6.34 also met such issue, but last fixed by below patch and
further optimization patches.
   I send out this mail and wondering if anyone else ever met such
issue?  Any suspicion point? Any suggestion or comment is appreciated.
Thanks a lot!

commit ea90002b0fa7bdee86ec22eba1d951f30bf043a6
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Mon Apr 12 12:44:29 2010 -0700

    anonvma: when setting up page->mapping, we need to pick the _oldest_ anonvma

commit 288468c334e98aacbb7e2fb8bde6bc1adcd55e05
Author: Andrea Arcangeli <aarcange@redhat.com>
Date:   Mon Aug 9 17:19:09 2010 -0700

    rmap: always use anon_vma root pointer


 crash> struct page.mapping 0xc2364de0
  mapping = 0xd21a1601
   This address 0xd21a1600 is in Binder_2's stack range! It should be
from anon_vma slab.
crash> kmem 0xd21a1601
    PID: 32202
COMMAND: "Binder_2"
   TASK: e426b000  [THREAD_INFO: d21a0000]
    CPU: 1
  STATE: TASK_INTERRUPTIBLE

  PAGE    PHYSICAL   MAPPING    INDEX CNT FLAGS
c2343420  121a1000         0         0  0 0

[14789.905700] c0 68 (kcompcached) Internal error: : 1 [#1] PREEMPT SMP ARM
[14789.905792] c0 68 (kcompcached) Modules linked in: sd8xxx mlan
usimeventk cidatattydev gs_diag diag ccinetdev cci_datastub citty
msocketk seh cploaddev geu galcore
[14789.907165] c0 68 (kcompcached) CPU: 0    Tainted: G    B   W
(3.4.5-2289913 #2)
[14789.907348] c0 68 (kcompcached) PC is at mutex_trylock+0x10/0x6c
[14789.907531] c0 68 (kcompcached) LR is at page_lock_anon_vma+0x3c/0x154
[14789.907623] c0 68 (kcompcached) pc : [<c05e99c4>]    lr :
[<c01c4b00>]    psr: 60000013
[14789.907623] c0 68 (kcompcached) sp : eb299d30  ip : 00000000  fp : 00000000
[14789.907958] c0 68 (kcompcached) r10: eb299e58  r9 : eb299dc4  r8 : eb298000
[14789.908050] c0 68 (kcompcached) r7 : c2364de0  r6 : ff05060b  r5 :
d21a1600  r4 : d21a1601
[14789.908233] c0 68 (kcompcached) r3 : ff05060b  r2 : 00000000  r1 :
00000001  r0 : ff05060b
[14789.908386] c0 68 (kcompcached) Flags: nZCv  IRQs on  FIQs on  Mode
SVC_32  ISA ARM  Segment kernel
[14789.908508] c0 68 (kcompcached) Control: 10c53c7d  Table: 2afe404a
DAC: 00000015


[14790.002593] c0 68 (kcompcached) [<c05e99c4>]
(mutex_trylock+0x10/0x6c) from [<c01c4b00>]
(page_lock_anon_vma+0x3c/0x154)
[14790.002777] c0 68 (kcompcached) [<c01c4b00>]
(page_lock_anon_vma+0x3c/0x154) from [<c01c4dbc>]
(page_referenced+0x6c/0x200)
[14790.002990] c0 68 (kcompcached) [<c01c4dbc>]
(page_referenced+0x6c/0x200) from [<c01ad188>]
(shrink_page_list+0x160/0x868)
[14790.003173] c0 68 (kcompcached) [<c01ad188>]
(shrink_page_list+0x160/0x868) from [<c01addb0>]
(shrink_inactive_list+0x210/0x4b4)
[14790.003356] c0 68 (kcompcached) [<c01addb0>]
(shrink_inactive_list+0x210/0x4b4) from [<c01ae3ac>]
(shrink_mem_cgroup_zone+0x358/0x4e0)
[14790.003540] c0 68 (kcompcached) [<c01ae3ac>]
(shrink_mem_cgroup_zone+0x358/0x4e0) from [<c01af13c>]
(shrink_zones+0x148/0x194)
[14790.003753] c0 68 (kcompcached) [<c01af13c>]
(shrink_zones+0x148/0x194) from [<c01af24c>]
(rtcc_reclaim_pages+0xc4/0x204)
[14790.003936] c0 68 (kcompcached) [<c01af24c>]
(rtcc_reclaim_pages+0xc4/0x204) from [<c0458438>]
(do_compcache+0x6c/0xb0)
[14790.004119] c0 68 (kcompcached) [<c0458438>]
(do_compcache+0x6c/0xb0) from [<c0153acc>] (kthread+0x80/0x8c)
[14790.004333] c0 68 (kcompcached) [<c0153acc>] (kthread+0x80/0x8c)
from [<c010ebf8>] (kernel_thread_exit+0x0/0x8)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
