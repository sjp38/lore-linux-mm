Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 96C632806D8
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 06:37:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s137so17703438pfs.4
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 03:37:39 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g2si283598pfc.180.2017.09.07.03.37.37
        for <linux-mm@kvack.org>;
        Thu, 07 Sep 2017 03:37:38 -0700 (PDT)
Date: Thu, 7 Sep 2017 11:36:16 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: "BUG: Bad rss-counter state" in v4.13 / arm64
Message-ID: <20170907103616.GC1990@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller@googlegroups.com
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>

Hi,

I'm hitting splats like below when fuzzing v4.13 on arm64:

BUG: Bad rss-counter state mm:ffff80002fa35f00 idx:1 val:1
BUG: Bad rss-counter state mm:ffff80002fa35f00 idx:3 val:-1

It looks like we're mis-accounting shared memory pages as anonymous
pages somewhere, or vice-versa.

Syzkaller came up with the two reproducers, which trigger the issue
intermittently:

Reproducer 1
----
# {Threaded:false Collide:false Repeat:true Procs:2 Sandbox:setuid Fault:false FaultCall:-1 FaultNth:0 EnableTun:true UseTmpDir:true HandleSegv:true WaitRepeat:true Debug:false Repro:false}
mmap(&(0x7f0000000000/0x5b2000)=nil, 0x5b2000, 0x3, 0x32, 0xffffffffffffffff, 0x0)
perf_event_open(&(0x7f000000b000-0x78)={0x1, 0x78, 0x0, 0x0, 0x0, 0x0, 0x0, 0x1, 0x0, 0x0, 0x7ffffffe, 0x3, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x101, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0}, 0x0, 0xffffffffffffffff, 0xffffffffffffffff, 0x0)
clone(0x0, &(0x7f0000d18000-0x2)="", &(0x7f00006b5000-0x4)=0x0, &(0x7f00002c2000-0x4)=0x0, &(0x7f0000415000)="")
move_pages(0x0, 0x1, &(0x7f00002f8000-0x38)=[&(0x7f00000b9000/0x2000)=nil], 0x0, &(0x7f00002f6000-0x4)=[], 0x0)
shmat(0x0, &(0x7f000000a000/0x4000)=nil, 0x5ffe)
pivot_root(&(0x7f00003f7000-0x8)="2e2f66696c653000", &(0x7f00005b1000)="2e2f66696c653000")
ioctl$DRM_IOCTL_PRIME_HANDLE_TO_FD(0xffffffffffffffff, 0xc00c642d, &(0x7f00002eb000)={0x0, 0x80000, 0xffffffffffffff9c})
----

Reproducer 2
----
# {Threaded:true Collide:false Repeat:true Procs:2 Sandbox:none Fault:false FaultCall:-1 FaultNth:0 EnableTun:true UseTmpDir:true HandleSegv:true WaitRepeat:true Debug:false Repro:false}
mmap(&(0x7f0000000000/0x592000)=nil, 0x592000, 0x3, 0x32, 0xffffffffffffffff, 0x0)
ioctl$VT_DISALLOCATE(0xffffffffffffffff, 0x5608)
io_setup(0x80, &(0x7f00002ea000-0x8)=0x0)
shmat(0x0, &(0x7f0000193000/0x3000)=nil, 0x6000)
rt_sigtimedwait(&(0x7f00002fa000)={0xae}, 0x0, &(0x7f0000045000-0x10)={0x0, 0x989680}, 0x8)
clone(0x0, &(0x7f0000d18000-0x2)="", &(0x7f00006b5000-0x4)=0x0, &(0x7f00002c2000-0x4)=0x0, &(0x7f0000415000)="")
move_pages(0x0, 0x1, &(0x7f00002f8000-0x38)=[&(0x7f00000b9000/0x2000)=nil], 0x0, &(0x7f00002f6000-0x4)=[], 0x0)
openat$ptmx(0xffffffffffffff9c, &(0x7f000000d000)="2f6465762f70746d7800", 0x0, 0x0)
syz_extract_tcp_res$synack(&(0x7f0000591000-0x8)={0x0, 0x0}, 0x1, 0x0)
syz_open_dev$vcsn(&(0x7f0000591000)="2f6465762f7663732300", 0x2, 0x0)
----

I haven't yet had the time to investigate this or run a bisect.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
