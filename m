Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 256986B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 06:43:01 -0400 (EDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 24 Apr 2013 11:39:50 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 887CD17D8017
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 11:43:54 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3OAgk3U50266218
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 10:42:46 GMT
Received: from d06av05.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3OAgtnd026659
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 04:42:56 -0600
Date: Wed, 24 Apr 2013 12:42:55 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [v3.9-rc8]: kernel BUG at mm/memcontrol.c:3994! (was: Re:
 [BUG][s390x] mm: system crashed)
Message-ID: <20130424104255.GC4350@osiris>
References: <156480624.266924.1365995933797.JavaMail.root@redhat.com>
 <2068164110.268217.1365996520440.JavaMail.root@redhat.com>
 <20130415055627.GB4207@osiris>
 <516B9B57.6050308@redhat.com>
 <20130416075047.GA4184@osiris>
 <1638103518.2400447.1366266465689.JavaMail.root@redhat.com>
 <20130418071303.GB4203@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130418071303.GB4203@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, caiqian <caiqian@redhat.com>, Caspar Zhang <czhang@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Apr 18, 2013 at 09:13:03AM +0200, Heiko Carstens wrote:
> Ok, thanks for verifying! I'll look into it; hopefully I can reproduce it
> here as well.

That seems to be a common code bug. I can easily trigger the VM_BUG_ON()
below (when I force the system to swap):

[   48.347963] ------------[ cut here ]------------
[   48.347972] kernel BUG at mm/memcontrol.c:3994!
[   48.348012] illegal operation: 0001 [#1] SMP 
[   48.348015] Modules linked in:
[   48.348017] CPU: 1 Not tainted 3.9.0-rc8+ #38
[   48.348020] Process mmap2 (pid: 635, task: 0000000029476100, ksp: 000000002e91b938)
[   48.348022] Krnl PSW : 0704f00180000000 000000000026552c (__mem_cgroup_uncharge_common+0x2c4/0x33c)
[   48.348032]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:3 PM:0 EA:3
               Krnl GPRS: 0000000000000008 0000000000000009 000003d1002a9200 0000000000000000
[   48.348039]            0000000000000000 00000000006812d8 000003ffdf339000 00000000321a6f98
[   48.348043]            000003fffce11000 0000000000000000 0000000000000001 000003d1002a9200
[   48.348046]            0000000000000001 0000000000681b88 000000002e91bc18 000000002e91bbd0
[   48.348057] Krnl Code: 000000000026551e: c0e5fffaa2a1        brasl   %r14,1b9a60
                          0000000000265524: a7f4ff7d            brc     15,26541e
                         #0000000000265528: a7f40001            brc     15,26552a
                         >000000000026552c: e3c0b8200124        stg     %r12,6176(%r11)
                          0000000000265532: a7f4ff57            brc     15,2653e0
                          0000000000265536: e310b8280104        lg      %r1,6184(%r11)
                          000000000026553c: a71b0001            aghi    %r1,1
                          0000000000265540: e310b8280124        stg     %r1,6184(%r11)
[   48.348099] Call Trace:
[   48.348100] ([<000003d1002a91c0>] 0x3d1002a91c0)
[   48.348102]  [<00000000002404aa>] page_remove_rmap+0xf2/0x16c
[   48.348106]  [<0000000000232dc8>] unmap_single_vma+0x494/0x7d8
[   48.348107]  [<0000000000233ac0>] unmap_vmas+0x50/0x74
[   48.348109]  [<00000000002396ec>] unmap_region+0x9c/0x110
[   48.348110]  [<000000000023bd18>] do_munmap+0x284/0x470
[   48.348111]  [<000000000023bf56>] vm_munmap+0x52/0x70
[   48.348113]  [<000000000023cf32>] SyS_munmap+0x3a/0x4c
[   48.348114]  [<0000000000665e14>] sysc_noemu+0x22/0x28
[   48.348118]  [<000003fffcf187b2>] 0x3fffcf187b2
[   48.348119] Last Breaking-Event-Address:
[   48.348120]  [<0000000000265528>] __mem_cgroup_uncharge_common+0x2c0/0x33c

Looking at the code, the code flow is:

page_remove_rmap() -> mem_cgroup_uncharge_page() -> __mem_cgroup_uncharge_common()

Note that in mem_cgroup_uncharge_page() the page in question passed the check:

[...]
        if (PageSwapCache(page))
                return;
[...]

and just a couple of instructions later the VM_BUG_ON() within
__mem_cgroup_uncharge_common() triggers:

[...]
        if (mem_cgroup_disabled())
                return NULL;

        VM_BUG_ON(PageSwapCache(page));
[...]

Which means that another cpu changed the pageflags concurrently. In fact,
looking at the dump a different cpu is indeed busy with running kswapd.

So.. this seems to be somewhat broken. Anyone familiar with memcontrol?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
