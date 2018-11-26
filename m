Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 688C66B401C
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 08:34:24 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b3so1576174edi.0
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 05:34:24 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id u9si345907edf.359.2018.11.26.05.34.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 05:34:22 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id E88E31C24EC
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 13:34:21 +0000 (GMT)
Date: Mon, 26 Nov 2018 13:34:20 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Hackbench pipes regression bisected to PSI
Message-ID: <20181126133420.GN23260@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

Hi Johannes,

PSI is a great idea but it does have overhead and if enabled by Kconfig
then it incurs a hit whether the user is aware of the feature or not. I
think enabling by default is unnecessary as it should only be enabled if
the information is being consumed. While the Kconfig exists, it's all or
nothing if distributions want to have the feature available.

I've included a bisection report below showing a 6-10% regression on a
single socket skylake machine. Would you mind doing one or all of the
following to fix it please?

a) disable it by default
b) put psi_disable behind a static branch to move the overhead to zero
   if it's disabled
c) optionally enable/disable at runtime (least important as at a glance,
   this may be problematic)

Thanks

Bisect parameters
=================
CONFIG_AUTO=openSUSE-LEAP-15.0
BUILD_TYPE=make
MACHINE=delboy
BISECT_REVERSE=no
BISECT_MMTESTS_TEST=hackbench-process-pipes
BISECT_CONFIG=global-dhp__scheduler-unbound
BISECT_GOOD=v4.19
BISECT_BAD=92b419289cee
BISECT_LOGDIR=/srv/marvin/impera/bisections-sigma-delboy-global-dhp__scheduler-unbound-openSUSE-LEAP-15.0-openSUSE-LEAP-15.0-v4.19..92b419289cee
BISECT_COMPARE=Amean
BISECT_PREFER=Lower
BISECT_CLIENT="5"
BISECT_REBOOT_CLEAN=no
BISECT_MONITOR_CONFIG=
BISECT_NO_MITIGATIONS=no
BISECT_COMMAND="bisection-run --machine delboy --distro openSUSE-LEAP-15.0 --kernel-config openSUSE-LEAP-15.0 --tree make --config global-dhp__scheduler-unbound --mmtests-test hackbench-process-pipes --monitor no-monitor --method sigma --good v4.19 --bad 92b419289cee --walk-mainline --notify mgorman@techsingularity.net --bisect-client 5 --mmtests-limit --iterations 1 --logdir /srv/marvin/impera/bisections-sigma-delboy-global-dhp__scheduler-unbound-openSUSE-LEAP-15.0-openSUSE-LEAP-15.0-v4.19..92b419289cee --reset-trees"
BISECT_LOGDIR=/srv/marvin/impera/bisections-sigma-delboy-global-dhp__scheduler-unbound-openSUSE-LEAP-15.0-openSUSE-LEAP-15.0-v4.19..92b419289cee

Last good/First bad commit
==========================
Last good commit: eb414681d5a07d28d2ff90dc05f69ec6b232ebd2
First bad commit: 2ce7135adc9ad081aa3c49744144376ac74fea60
>From 2ce7135adc9ad081aa3c49744144376ac74fea60 Mon Sep 17 00:00:00 2001
From: Johannes Weiner <hannes@cmpxchg.org>
Date: Fri, 26 Oct 2018 15:06:31 -0700
Subject: [PATCH] psi: cgroup support
On a system that executes multiple cgrouped jobs and independent
workloads, we don't just care about the health of the overall system, but
also that of individual jobs, so that we can ensure individual job health,
fairness between jobs, or prioritize some jobs over others.
This patch implements pressure stall tracking for cgroups.  In kernels
with CONFIG_PSI=y, cgroup2 groups will have cpu.pressure, memory.pressure,
and io.pressure files that track aggregate pressure stall times for only
the tasks inside the cgroup.
Link: http://lkml.kernel.org/r/20180828172258.3185-10-hannes@cmpxchg.org
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Tested-by: Daniel Drake <drake@endlessm.com>
Tested-by: Suren Baghdasaryan <surenb@google.com>
Cc: Christopher Lameter <cl@linux.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Johannes Weiner <jweiner@fb.com>
Cc: Mike Galbraith <efault@gmx.de>
Cc: Peter Enderborg <peter.enderborg@sony.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
 Documentation/accounting/psi.txt        |   9 +++
 Documentation/admin-guide/cgroup-v2.rst |  18 +++++
 include/linux/cgroup-defs.h             |   4 ++
 include/linux/cgroup.h                  |  15 ++++
 include/linux/psi.h                     |  25 +++++++
 init/Kconfig                            |   4 ++
 kernel/cgroup/cgroup.c                  |  45 +++++++++++-
 kernel/sched/psi.c                      | 118 +++++++++++++++++++++++++++++---
 8 files changed, 228 insertions(+), 10 deletions(-)

Comparison
==========
                            initial                initial                   last                  penup                  first
                         good-v4.19       bad-92b419289cee          good-eb414681          good-95f9ab2d           bad-2ce7135a
Min       1       1.2980 (   0.00%)      1.2950 (   0.23%)      1.2870 (   0.85%)      1.3100 (  -0.92%)      1.3190 (  -1.62%)
Min       3       3.8480 (   0.00%)      4.0640 (  -5.61%)      3.8070 (   1.07%)      3.8530 (  -0.13%)      4.1750 (  -8.50%)
Min       5       6.7420 (   0.00%)      8.1480 ( -20.85%)      6.8010 (  -0.88%)      6.7740 (  -0.47%)      7.3370 (  -8.83%)
Min       7       9.7230 (   0.00%)     10.2490 (  -5.41%)      9.7840 (  -0.63%)      9.8940 (  -1.76%)     10.6890 (  -9.94%)
Min       12     16.2810 (   0.00%)     17.6470 (  -8.39%)     16.1740 (   0.66%)     16.2390 (   0.26%)     17.1260 (  -5.19%)
Min       18     25.2050 (   0.00%)     25.6510 (  -1.77%)     25.4950 (  -1.15%)     25.4130 (  -0.83%)     25.5330 (  -1.30%)
Min       24     31.7720 (   0.00%)     29.4380 (   7.35%)     33.3800 (  -5.06%)     31.2400 (   1.67%)     31.4640 (   0.97%)
Min       30     37.0100 (   0.00%)     37.6760 (  -1.80%)     33.7630 (   8.77%)     37.5890 (  -1.56%)     33.2980 (  10.03%)
Min       32     40.0150 (   0.00%)     39.9460 (   0.17%)     37.5790 (   6.09%)     37.7580 (   5.64%)     38.8230 (   2.98%)
Amean     1       1.3153 (   0.00%)      1.3530 (  -2.86%)      1.3133 (   0.15%)      1.3217 (  -0.48%)      1.3243 (  -0.68%)
Amean     3       3.8670 (   0.00%)      4.1097 *  -6.28%*      3.8597 (   0.19%)      3.8943 (  -0.71%)      4.2130 *  -8.95%*
Amean     5       6.8563 (   0.00%)      8.3113 * -21.22%*      6.9197 (  -0.92%)      6.8630 (  -0.10%)      7.5630 * -10.31%*
Amean     7       9.8650 (   0.00%)     10.5607 *  -7.05%*      9.9627 (  -0.99%)      9.9177 (  -0.53%)     10.7880 *  -9.36%*
Amean     12     16.5540 (   0.00%)     18.2850 * -10.46%*     16.7513 (  -1.19%)     16.3700 (   1.11%)     18.1283 *  -9.51%*
Amean     18     26.0390 (   0.00%)     27.4333 (  -5.35%)     27.0223 (  -3.78%)     25.8067 (   0.89%)     27.2333 (  -4.59%)
Amean     24     32.8650 (   0.00%)     33.0093 (  -0.44%)     34.6167 (  -5.33%)     32.7020 (   0.50%)     34.9150 (  -6.24%)
Amean     30     39.5653 (   0.00%)     41.0643 (  -3.79%)     36.6733 (   7.31%)     39.4050 (   0.41%)     38.1273 (   3.63%)
Amean     32     40.8177 (   0.00%)     42.1383 (  -3.24%)     39.1487 (   4.09%)     41.7743 (  -2.34%)     39.4193 *   3.43%*
Stddev    1       0.0158 (   0.00%)      0.0730 (-361.51%)      0.0247 ( -56.14%)      0.0102 (  35.44%)      0.0061 (  61.38%)
Stddev    3       0.0271 (   0.00%)      0.0397 ( -46.65%)      0.0627 (-131.53%)      0.0575 (-112.38%)      0.0330 ( -22.06%)
Stddev    5       0.1491 (   0.00%)      0.1744 ( -16.95%)      0.1134 (  23.94%)      0.0771 (  48.30%)      0.2126 ( -42.57%)
Stddev    7       0.1650 (   0.00%)      0.2780 ( -68.48%)      0.1663 (  -0.80%)      0.0257 (  84.43%)      0.0889 (  46.12%)
Stddev    12      0.2395 (   0.00%)      0.5652 (-135.95%)      0.5726 (-139.03%)      0.1626 (  32.11%)      0.8698 (-263.10%)
Stddev    18      0.8499 (   0.00%)      1.5949 ( -87.65%)      1.3650 ( -60.60%)      0.3799 (  55.31%)      1.5393 ( -81.11%)
Stddev    24      1.2105 (   0.00%)      3.3274 (-174.88%)      1.5403 ( -27.25%)      1.2683 (  -4.78%)      3.1545 (-160.60%)
Stddev    30      2.4625 (   0.00%)      2.9472 ( -19.69%)      2.5228 (  -2.45%)      1.5773 (  35.95%)      5.3969 (-119.17%)
Stddev    32      0.9572 (   0.00%)      2.4088 (-151.66%)      1.5982 ( -66.97%)      4.3986 (-359.54%)      0.5216 (  45.50%)
CoeffVar  1       1.2029 (   0.00%)      5.3969 (-348.67%)      1.8811 ( -56.38%)      0.7728 (  35.75%)      0.4614 (  61.64%)
CoeffVar  3       0.7001 (   0.00%)      0.9661 ( -37.99%)      1.6241 (-131.97%)      1.4765 (-110.89%)      0.7844 ( -12.03%)
CoeffVar  5       2.1749 (   0.00%)      2.0982 (   3.53%)      1.6392 (  24.63%)      1.1233 (  48.35%)      2.8110 ( -29.25%)
CoeffVar  7       1.6725 (   0.00%)      2.6322 ( -57.38%)      1.6694 (   0.18%)      0.2591 (  84.51%)      0.8241 (  50.73%)
CoeffVar  12      1.4470 (   0.00%)      3.0910 (-113.61%)      3.4180 (-136.21%)      0.9934 (  31.35%)      4.7978 (-231.56%)
CoeffVar  18      3.2640 (   0.00%)      5.8138 ( -78.12%)      5.0512 ( -54.75%)      1.4719 (  54.91%)      5.6523 ( -73.17%)
CoeffVar  24      3.6832 (   0.00%)     10.0801 (-173.68%)      4.4495 ( -20.81%)      3.8785 (  -5.30%)      9.0349 (-145.30%)
CoeffVar  30      6.2238 (   0.00%)      7.1770 ( -15.32%)      6.8792 ( -10.53%)      4.0027 (  35.69%)     14.1550 (-127.43%)
CoeffVar  32      2.3450 (   0.00%)      5.7165 (-143.78%)      4.0825 ( -74.09%)     10.5295 (-349.02%)      1.3233 (  43.57%)
Max       1       1.3290 (   0.00%)      1.4350 (  -7.98%)      1.3360 (  -0.53%)      1.3290 (   0.00%)      1.3310 (  -0.15%)
Max       3       3.8980 (   0.00%)      4.1360 (  -6.11%)      3.9290 (  -0.80%)      3.9600 (  -1.59%)      4.2350 (  -8.65%)
Max       5       7.0250 (   0.00%)      8.4950 ( -20.93%)      7.0270 (  -0.03%)      6.9090 (   1.65%)      7.7590 ( -10.45%)
Max       7      10.0460 (   0.00%)     10.7830 (  -7.34%)     10.1130 (  -0.67%)      9.9450 (   1.01%)     10.8610 (  -8.11%)
Max       12     16.7290 (   0.00%)     18.7230 ( -11.92%)     17.3190 (  -3.53%)     16.5520 (   1.06%)     18.6840 ( -11.69%)
Max       18     26.9040 (   0.00%)     28.7260 (  -6.77%)     28.1230 (  -4.53%)     26.1710 (   2.72%)     28.5320 (  -6.05%)
Max       24     34.1660 (   0.00%)     36.0220 (  -5.43%)     36.3420 (  -6.37%)     33.5080 (   1.93%)     37.6500 ( -10.20%)
Max       30     41.9230 (   0.00%)     43.0330 (  -2.65%)     38.2390 (   8.79%)     40.4330 (   3.55%)     43.9530 (  -4.84%)
Max       32     41.8770 (   0.00%)     44.7170 (  -6.78%)     40.7740 (   2.63%)     46.4750 ( -10.98%)     39.7910 (   4.98%)
BAmean-50 1       1.3085 (   0.00%)      1.3120 (  -0.27%)      1.3020 (   0.50%)      1.3180 (  -0.73%)      1.3210 (  -0.96%)
BAmean-50 3       3.8515 (   0.00%)      4.0965 (  -6.36%)      3.8250 (   0.69%)      3.8615 (  -0.26%)      4.2020 (  -9.10%)
BAmean-50 5       6.7720 (   0.00%)      8.2195 ( -21.37%)      6.8660 (  -1.39%)      6.8400 (  -1.00%)      7.4650 ( -10.23%)
BAmean-50 7       9.7745 (   0.00%)     10.4495 (  -6.91%)      9.8875 (  -1.16%)      9.9040 (  -1.32%)     10.7515 ( -10.00%)
BAmean-50 12     16.4665 (   0.00%)     18.0660 (  -9.71%)     16.4675 (  -0.01%)     16.2790 (   1.14%)     17.8505 (  -8.40%)
BAmean-50 18     25.6065 (   0.00%)     26.7870 (  -4.61%)     26.4720 (  -3.38%)     25.6245 (  -0.07%)     26.5840 (  -3.82%)
BAmean-50 24     32.2145 (   0.00%)     31.5030 (   2.21%)     33.7540 (  -4.78%)     32.2990 (  -0.26%)     33.5475 (  -4.14%)
BAmean-50 30     38.3865 (   0.00%)     40.0800 (  -4.41%)     35.8905 (   6.50%)     38.8910 (  -1.31%)     35.2145 (   8.26%)
BAmean-50 32     40.2880 (   0.00%)     40.8490 (  -1.39%)     38.3360 (   4.85%)     39.4240 (   2.14%)     39.2335 (   2.62%)
BAmean-95 1       1.3153 (   0.00%)      1.3530 (  -2.86%)      1.3133 (   0.15%)      1.3217 (  -0.48%)      1.3243 (  -0.68%)
BAmean-95 3       3.8670 (   0.00%)      4.1097 (  -6.28%)      3.8597 (   0.19%)      3.8943 (  -0.71%)      4.2130 (  -8.95%)
BAmean-95 5       6.8563 (   0.00%)      8.3113 ( -21.22%)      6.9197 (  -0.92%)      6.8630 (  -0.10%)      7.5630 ( -10.31%)
BAmean-95 7       9.8650 (   0.00%)     10.5607 (  -7.05%)      9.9627 (  -0.99%)      9.9177 (  -0.53%)     10.7880 (  -9.36%)
BAmean-95 12     16.5540 (   0.00%)     18.2850 ( -10.46%)     16.7513 (  -1.19%)     16.3700 (   1.11%)     18.1283 (  -9.51%)
BAmean-95 18     26.0390 (   0.00%)     27.4333 (  -5.35%)     27.0223 (  -3.78%)     25.8067 (   0.89%)     27.2333 (  -4.59%)
BAmean-95 24     32.8650 (   0.00%)     33.0093 (  -0.44%)     34.6167 (  -5.33%)     32.7020 (   0.50%)     34.9150 (  -6.24%)
BAmean-95 30     39.5653 (   0.00%)     41.0643 (  -3.79%)     36.6733 (   7.31%)     39.4050 (   0.41%)     38.1273 (   3.63%)
BAmean-95 32     40.8177 (   0.00%)     42.1383 (  -3.24%)     39.1487 (   4.09%)     41.7743 (  -2.34%)     39.4193 (   3.43%)
BAmean-99 1       1.3153 (   0.00%)      1.3530 (  -2.86%)      1.3133 (   0.15%)      1.3217 (  -0.48%)      1.3243 (  -0.68%)
BAmean-99 3       3.8670 (   0.00%)      4.1097 (  -6.28%)      3.8597 (   0.19%)      3.8943 (  -0.71%)      4.2130 (  -8.95%)
BAmean-99 5       6.8563 (   0.00%)      8.3113 ( -21.22%)      6.9197 (  -0.92%)      6.8630 (  -0.10%)      7.5630 ( -10.31%)
BAmean-99 7       9.8650 (   0.00%)     10.5607 (  -7.05%)      9.9627 (  -0.99%)      9.9177 (  -0.53%)     10.7880 (  -9.36%)
BAmean-99 12     16.5540 (   0.00%)     18.2850 ( -10.46%)     16.7513 (  -1.19%)     16.3700 (   1.11%)     18.1283 (  -9.51%)
BAmean-99 18     26.0390 (   0.00%)     27.4333 (  -5.35%)     27.0223 (  -3.78%)     25.8067 (   0.89%)     27.2333 (  -4.59%)
BAmean-99 24     32.8650 (   0.00%)     33.0093 (  -0.44%)     34.6167 (  -5.33%)     32.7020 (   0.50%)     34.9150 (  -6.24%)
BAmean-99 30     39.5653 (   0.00%)     41.0643 (  -3.79%)     36.6733 (   7.31%)     39.4050 (   0.41%)     38.1273 (   3.63%)
BAmean-99 32     40.8177 (   0.00%)     42.1383 (  -3.24%)     39.1487 (   4.09%)     41.7743 (  -2.34%)     39.4193 (   3.43%)

Git log
=======
git bisect start
# good: [84df9525b0c27f3ebc2ebb1864fa62a97fdedb7d] Linux 4.19
git bisect good 84df9525b0c27f3ebc2ebb1864fa62a97fdedb7d
# bad: [92b419289ceecdd1eae03114928913f298b84327] Merge tag 'riscv-for-linus-4.20-rc4' of git://git.kernel.org/pub/scm/linux/kernel/git/palmer/riscv-linux
git bisect bad 92b419289ceecdd1eae03114928913f298b84327
# good: [84df9525b0c27f3ebc2ebb1864fa62a97fdedb7d] Linux 4.19
git bisect good 84df9525b0c27f3ebc2ebb1864fa62a97fdedb7d
# good: [26873acacbdbb4e4b444f5dd28dcc4853f0e8ba2] Merge tag 'driver-core-4.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core
git bisect good 26873acacbdbb4e4b444f5dd28dcc4853f0e8ba2
# bad: [738b04fba18d35cd352b7b15afefb8a7b798648e] Merge tag 'staging-4.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging
git bisect bad 738b04fba18d35cd352b7b15afefb8a7b798648e
# good: [f2bfc71aee75feff33ca659322b72ffeed5a243d] Merge tag 'drm-intel-next-fixes-2018-10-18' of git://anongit.freedesktop.org/drm/drm-intel into drm-next
git bisect good f2bfc71aee75feff33ca659322b72ffeed5a243d
# bad: [345671ea0f9258f410eb057b9ced9cefbbe5dc78] Merge branch 'akpm' (patches from Andrew)
git bisect bad 345671ea0f9258f410eb057b9ced9cefbbe5dc78
# good: [033078a9afe504ac9e615d10c4b35d634450b637] Merge tag '4.20-smb3-fixes' of git://git.samba.org/sfrench/cifs-2.6
git bisect good 033078a9afe504ac9e615d10c4b35d634450b637
# good: [685f7e4f161425b137056abe35ba8ef7b669d83d] Merge tag 'powerpc-4.20-1' of git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux
git bisect good 685f7e4f161425b137056abe35ba8ef7b669d83d
# bad: [d3035be4ce2345d98633a45f93a74e526e94b802] mm: calculate deferred pages after skipping mirrored memory
git bisect bad d3035be4ce2345d98633a45f93a74e526e94b802
# good: [95f9ab2d596e8cbb388315e78c82b9a131bf2928] mm: workingset: don't drop refault information prematurely
git bisect good 95f9ab2d596e8cbb388315e78c82b9a131bf2928
# bad: [f682a97a00591def7cefbb5003dc04045028e405] mm: provide kernel parameter to allow disabling page init poisoning
git bisect bad f682a97a00591def7cefbb5003dc04045028e405
# bad: [c3df29d13044d885695067fa0b1386824942557a] mm/swap.c: remove duplicated include
git bisect bad c3df29d13044d885695067fa0b1386824942557a
# good: [eb414681d5a07d28d2ff90dc05f69ec6b232ebd2] psi: pressure stall information for CPU, memory, and IO
git bisect good eb414681d5a07d28d2ff90dc05f69ec6b232ebd2
# bad: [68d48e6a2df575b935edd420396c3cb8b6aa6ad3] mm: workingset: add vmstat counter for shadow nodes
git bisect bad 68d48e6a2df575b935edd420396c3cb8b6aa6ad3
# bad: [505802a53510e54ad5fbbd655a68893df83bfb91] mm: workingset: use cheaper __inc_lruvec_state in irqsafe node reclaim
git bisect bad 505802a53510e54ad5fbbd655a68893df83bfb91
# bad: [2ce7135adc9ad081aa3c49744144376ac74fea60] psi: cgroup support
git bisect bad 2ce7135adc9ad081aa3c49744144376ac74fea60
# first bad commit: [2ce7135adc9ad081aa3c49744144376ac74fea60] psi: cgroup support

-- 
Mel Gorman
SUSE Labs
