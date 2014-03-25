Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 80ADB6B003B
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 16:31:47 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id bs8so3845916wib.3
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 13:31:47 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id w10si4321807wiy.37.2014.03.25.13.31.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Mar 2014 13:31:46 -0700 (PDT)
Received: by mail-wi0-f177.google.com with SMTP id cc10so1056482wib.4
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 13:31:45 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20140325085609.9132a2e1.akpm@linux-foundation.org>
References: <CA+icZUUr2Wua1kNoB1oCje2rU0KQx5c+V6A76UP0c99gg6UxTg@mail.gmail.com>
	<20140325085609.9132a2e1.akpm@linux-foundation.org>
Date: Tue, 25 Mar 2014 21:31:45 +0100
Message-ID: <CA+icZUVH98q=-n9WKJkxqkUPkUtUU1FCMVdT7Vye0x5-vPU7cA@mail.gmail.com>
Subject: Re: [v3.17-rc8] LTP oom testsuite produces OOPS
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 25, 2014 at 4:56 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 25 Mar 2014 08:45:34 +0100 Sedat Dilek <sedat.dilek@gmail.com> wrote:
>
>> Hi,
>>
>> as reported in [1] in my post-scriptum I see several OOPs when running
>> LTP and OOM tests (here: oom3).
>> Linus requested to send you mm-folks my bug-report.
>>
>> # cd /opt/ltp/
>>
>> # cat Version
>> 20140115
>>
>> # ./testcases/bin/oom03
>>
>> I have tested with latest LTP (15-Jan-2014).
>>
>> If you need additional information, please let me know.
>
> I don't actually see any oopses there.  There are some stack traces
> associated with the oom-killing events:
>
>
> [  104.383349] Memory cgroup out of memory: Kill process 2518 (oom03) score 777 or sacrifice child
> [  104.383352] Killed process 2518 (oom03) total-vm:3152196kB, anon-rss:1048444kB, file-rss:192kB
> [  107.946908] oom03 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
> [  107.946912] oom03 cpuset=/ mems_allowed=0
> [  107.946915] CPU: 0 PID: 2521 Comm: oom03 Not tainted 3.14.0-rc8-1-iniza-small #1
> [  107.946917] Hardware name: SAMSUNG ELECTRONICS CO., LTD. 530U3BI/530U4BI/530U4BH/530U3BI/530U4BI/530U4BH, BIOS 13XK 03/28/2013
> [  107.946919]  ffff880108e58400 ffff880064125be8 ffffffff8170fb45 0000000000000007
> [  107.946923]  ffff880108e7a190 ffff880064125c68 ffffffff8170c6e5 ffff880064125cd8
> [  107.946925]  ffff88010b686858 ffff88011fdf9d80 ffff88010b6863d0 0000000000000000
> [  107.946928] Call Trace:
> [  107.946934]  [<ffffffff8170fb45>] dump_stack+0x46/0x58
> [  107.946937]  [<ffffffff8170c6e5>] dump_header+0x7e/0x1c3
> [  107.946942]  [<ffffffff813881e0>] ? ___ratelimit+0xa0/0x120
> [  107.946946]  [<ffffffff811580e4>] oom_kill_process+0x214/0x370
> [  107.946949]  [<ffffffff81075ce5>] ? has_ns_capability_noaudit+0x15/0x20
> ...
>
> But these aren't oopses - mm/oom_kill.c:dump_header() deliberately
> performs a dump_stack() while reporting on the event.
>

Indicated by the lines '...expected victim is...' and according to you
'expected'?

# cd /opt/ltp/

# ./testcases/bin/oom03
oom03       0  TINFO  :  set overcommit_memory to 1
oom03       0  TINFO  :  start normal OOM testing.
oom03       0  TINFO  :  expected victim is 2834.
oom03       0  TINFO  :  allocating 3221225472 bytes.
oom03       0  TINFO  :  start OOM testing for mlocked pages.
oom03       0  TINFO  :  expected victim is 2835.
oom03       0  TINFO  :  allocating 3221225472 bytes.
oom03       0  TINFO  :  start OOM testing for KSM pages.
oom03       0  TINFO  :  expected victim is 2836.
oom03       0  TINFO  :  allocating 3221225472 bytes.
oom03       1  TCONF  :  memcg swap accounting is disabled
oom03       0  TINFO  :  set overcommit_memory to 0

# dmesg | egrep '2834|2835|2836'
[ 1220.478440] CPU: 0 PID: 2834 Comm: oom03 Not tainted
3.14.0-rc8-1-iniza-small #1
[ 1220.478552] [ 2834]     0  2834   788049   248262     623    65524
           0 oom03
[ 1220.478554] Memory cgroup out of memory: Kill process 2834 (oom03)
score 930 or sacrifice child
[ 1220.478558] Killed process 2834 (oom03) total-vm:3152196kB,
anon-rss:992852kB, file-rss:196kB
[ 1221.544018] CPU: 0 PID: 2835 Comm: oom03 Not tainted
3.14.0-rc8-1-iniza-small #1
[ 1221.544151] [ 2835]     0  2835   788049   262161     522       13
           0 oom03
[ 1221.544152] Memory cgroup out of memory: Kill process 2835 (oom03)
score 777 or sacrifice child
[ 1221.544155] Killed process 2835 (oom03) total-vm:3152196kB,
anon-rss:1048452kB, file-rss:192kB
[ 1225.016810] CPU: 0 PID: 2836 Comm: oom03 Not tainted
3.14.0-rc8-1-iniza-small #1
[ 1225.016941] [ 2836]     0  2836   788049   250693     628    65535
           0 oom03
[ 1225.016943] Memory cgroup out of memory: Kill process 2836 (oom03)
score 937 or sacrifice child
[ 1225.016945] Killed process 2836 (oom03) total-vm:3152196kB,
anon-rss:1002564kB, file-rss:208kB

- Sedat -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
