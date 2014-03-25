Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 999E46B0062
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 11:56:06 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so639557pbb.33
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 08:56:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id p2si11686354pbn.46.2014.03.25.08.56.05
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 08:56:05 -0700 (PDT)
Date: Tue, 25 Mar 2014 08:56:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [v3.17-rc8] LTP oom testsuite produces OOPS
Message-Id: <20140325085609.9132a2e1.akpm@linux-foundation.org>
In-Reply-To: <CA+icZUUr2Wua1kNoB1oCje2rU0KQx5c+V6A76UP0c99gg6UxTg@mail.gmail.com>
References: <CA+icZUUr2Wua1kNoB1oCje2rU0KQx5c+V6A76UP0c99gg6UxTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 25 Mar 2014 08:45:34 +0100 Sedat Dilek <sedat.dilek@gmail.com> wrote:

> Hi,
> 
> as reported in [1] in my post-scriptum I see several OOPs when running
> LTP and OOM tests (here: oom3).
> Linus requested to send you mm-folks my bug-report.
> 
> # cd /opt/ltp/
> 
> # cat Version
> 20140115
> 
> # ./testcases/bin/oom03
> 
> I have tested with latest LTP (15-Jan-2014).
> 
> If you need additional information, please let me know.

I don't actually see any oopses there.  There are some stack traces
associated with the oom-killing events:


[  104.383349] Memory cgroup out of memory: Kill process 2518 (oom03) score 777 or sacrifice child
[  104.383352] Killed process 2518 (oom03) total-vm:3152196kB, anon-rss:1048444kB, file-rss:192kB
[  107.946908] oom03 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
[  107.946912] oom03 cpuset=/ mems_allowed=0
[  107.946915] CPU: 0 PID: 2521 Comm: oom03 Not tainted 3.14.0-rc8-1-iniza-small #1
[  107.946917] Hardware name: SAMSUNG ELECTRONICS CO., LTD. 530U3BI/530U4BI/530U4BH/530U3BI/530U4BI/530U4BH, BIOS 13XK 03/28/2013
[  107.946919]  ffff880108e58400 ffff880064125be8 ffffffff8170fb45 0000000000000007
[  107.946923]  ffff880108e7a190 ffff880064125c68 ffffffff8170c6e5 ffff880064125cd8
[  107.946925]  ffff88010b686858 ffff88011fdf9d80 ffff88010b6863d0 0000000000000000
[  107.946928] Call Trace:
[  107.946934]  [<ffffffff8170fb45>] dump_stack+0x46/0x58
[  107.946937]  [<ffffffff8170c6e5>] dump_header+0x7e/0x1c3
[  107.946942]  [<ffffffff813881e0>] ? ___ratelimit+0xa0/0x120
[  107.946946]  [<ffffffff811580e4>] oom_kill_process+0x214/0x370
[  107.946949]  [<ffffffff81075ce5>] ? has_ns_capability_noaudit+0x15/0x20
...

But these aren't oopses - mm/oom_kill.c:dump_header() deliberately
performs a dump_stack() while reporting on the event.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
