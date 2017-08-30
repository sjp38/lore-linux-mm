Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 503AA6B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:52:07 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id j99so6157250ioo.6
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 06:52:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j2si118121iof.48.2017.08.30.06.52.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Aug 2017 06:52:04 -0700 (PDT)
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170828230256.GF491396@devbig577.frc2.facebook.com>
	<20170828230924.GG491396@devbig577.frc2.facebook.com>
	<201708292014.JHH35412.FMVFHOQOJtSLOF@I-love.SAKURA.ne.jp>
	<20170829143817.GK491396@devbig577.frc2.facebook.com>
	<20170829214104.GW491396@devbig577.frc2.facebook.com>
In-Reply-To: <20170829214104.GW491396@devbig577.frc2.facebook.com>
Message-Id: <201708302251.GDI75812.OFOQSVJOFMHFLt@I-love.SAKURA.ne.jp>
Date: Wed, 30 Aug 2017 22:51:57 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Tejun Heo wrote:
> I can't repro the problem.  The test program gets cleanly oom killed.
> Hmm... the workqueue dumps you posted are really weird because there
> are multiple work items stalling for really long times but only one
> pool is reporting hang and nobody has rescuers active.  I don't get
> how the system can be in such state.
> 
> Just in case, you're testing mainline, right?  I've updated your debug
> patch slightly so that it doesn't skip seemingly idle pools.  Can you
> please repro the problem with the patch applied?  Thanks.

Here are logs from the patch applied on top of linux-next-20170828.
Can you find some clue?

http://I-love.SAKURA.ne.jp/tmp/serial-20170830.txt.xz :

[  150.580362] Showing busy workqueues and worker pools:
[  150.580425] workqueue events_power_efficient: flags=0x80
[  150.580452]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  150.580456]     in-flight: 57:fb_flashcursor{53}
[  150.580486] workqueue mm_percpu_wq: flags=0x18
[  150.580513]   pwq 3: cpus=1 node=0 flags=0x0 nice=-20 active=1/256
[  150.580516]     pending: drain_local_pages_wq{14139} BAR(1706){14139}
[  150.580558] workqueue writeback: flags=0x4e
[  150.580559]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  150.580562]     in-flight: 400:wb_workfn{0} wb_workfn{0}
[  150.581413] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 178 3
[  150.581417] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 4 98
[  150.581420] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=15s workers=4 idle: 81 2104 17 285
[  150.581424] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=14s workers=2 idle: 18 92
[  150.581426] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 84 102 23
[  150.581429] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 94 24
[  150.581432] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 163 85 29
[  150.581435] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 30 95
[  150.581437] pool 8: cpus=4 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 132 86 2106 35
[  150.581440] pool 9: cpus=4 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 97 36
[  150.581442] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 87 306 41
[  150.581445] pool 11: cpus=5 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 42 93
[  150.581448] pool 12: cpus=6 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 88 258 506 47
[  150.581451] pool 13: cpus=6 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 48 96
[  150.581453] pool 14: cpus=7 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 89 470 53
[  150.581456] pool 15: cpus=7 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 54 99
[  150.581458] pool 16: cpus=8 node=0 flags=0x4 nice=0 hung=150s workers=0
[  150.581460] pool 17: cpus=8 node=0 flags=0x4 nice=-20 hung=150s workers=0

[  355.958940] Showing busy workqueues and worker pools:
[  355.960900] workqueue events: flags=0x0
[  355.962508]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=2/256
[  355.964646]     in-flight: 163:rht_deferred_worker{17020} rht_deferred_worker{17020}
[  355.967284]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  355.969522]     in-flight: 57:vmw_fb_dirty_flush{10381} vmw_fb_dirty_flush{10381}
[  355.972442] workqueue events_freezable_power_: flags=0x84
[  355.974636]   pwq 12: cpus=6 node=0 flags=0x0 nice=0 active=1/256
[  355.976956]     in-flight: 258:disk_events_workfn{355}
[  355.979027] workqueue writeback: flags=0x4e
[  355.980775]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  355.982892]     in-flight: 400:wb_workfn{0} wb_workfn{0}
[  355.985847] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 178 2114 3
[  355.988698] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 98 4
[  355.991253] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=1s workers=4 idle: 81 2104 17 285
[  355.993997] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=1s workers=2 idle: 18 92
[  355.996596] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 84 102 23
[  355.999415] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 24 94
[  356.002380] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 2117 29 85
[  356.005322] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 95 30
[  356.008095] pool 8: cpus=4 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 132 86 2106 35
[  356.010991] pool 9: cpus=4 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 97 36
[  356.013592] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 87 306 41
[  356.016336] pool 11: cpus=5 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 93 42
[  356.019163] pool 12: cpus=6 node=0 flags=0x0 nice=0 hung=0s workers=6 idle: 88 506 47 2116 2115
[  356.022239] pool 13: cpus=6 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 96 48
[  356.025010] pool 14: cpus=7 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 89 470 53
[  356.027690] pool 15: cpus=7 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 99 54
[  356.030419] pool 16: cpus=8 node=0 flags=0x4 nice=0 hung=276s workers=0
[  356.033156] pool 17: cpus=8 node=0 flags=0x4 nice=-20 hung=276s workers=0

[  488.888894] Showing busy workqueues and worker pools:
[  488.888908] workqueue events: flags=0x0
[  488.888934]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[  488.888937]     in-flight: 2120:rht_deferred_worker{0}
[  488.888991] workqueue events_power_efficient: flags=0x80
[  488.889011]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  488.889013]     in-flight: 178:fb_flashcursor{57}
[  488.889030] workqueue events_freezable_power_: flags=0x84
[  488.889048]   pwq 12: cpus=6 node=0 flags=0x0 nice=0 active=1/256
[  488.889050]     in-flight: 258:disk_events_workfn{1113}
[  488.889106] workqueue writeback: flags=0x4e
[  488.889114]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  488.889118]     in-flight: 400:wb_workfn{0}
[  488.889122]     pending: wb_workfn{0}
[  488.889934] workqueue xfs-eofblocks/sda1: flags=0xc
[  488.889953]   pwq 8: cpus=4 node=0 flags=0x0 nice=0 active=1/256
[  488.889956]     in-flight: 132:xfs_eofblocks_worker [xfs]{132266}
[  488.889991] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 57 2114 3
[  488.889997] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 98 4
[  488.890001] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=65s workers=5 idle: 17 2104 81 2118 285
[  488.890006] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=65s workers=2 idle: 92 18
[  488.890010] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 84 2119 102
[  488.890014] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 24 94
[  488.890018] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 163 2117 29 85
[  488.890023] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 30 95
[  488.890027] pool 8: cpus=4 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 86 2106
[  488.890030] pool 9: cpus=4 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 97 36
[  488.890034] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 306 87
[  488.890037] pool 11: cpus=5 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 93 42
[  488.890041] pool 12: cpus=6 node=0 flags=0x0 nice=0 hung=0s workers=6 idle: 88 506 47 2116 2115
[  488.890046] pool 13: cpus=6 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 48 96
[  488.890050] pool 14: cpus=7 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 89 2121 470
[  488.890054] pool 15: cpus=7 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 99 54
[  488.890057] pool 16: cpus=8 node=0 flags=0x4 nice=0 hung=488s workers=0
[  488.890060] pool 17: cpus=8 node=0 flags=0x4 nice=-20 hung=488s workers=0

[  782.785399] Showing busy workqueues and worker pools:
[  782.787507] workqueue mm_percpu_wq: flags=0x18
[  782.789366]   pwq 3: cpus=1 node=0 flags=0x0 nice=-20 active=2/256
[  782.791577]     pending: vmstat_update{69030}, drain_local_pages_wq{61669} BAR(63){61669}
[  782.794420] workqueue writeback: flags=0x4e
[  782.796202]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  782.798524]     in-flight: 400:wb_workfn{4446} wb_workfn{4446}
[  782.801737] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 178 57 2114
[  782.804596] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=6s workers=2 idle: 4 98
[  782.807263] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=69s workers=3 idle: 2104 17 81
[  782.810031] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=69s workers=2 idle: 18 92
[  782.812672] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=4s workers=5 idle: 2154 2119 84 2158 102
[  782.815738] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=4s workers=2 idle: 24 94
[  782.818558] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=9s workers=5 idle: 2117 2135 163 2143 29
[  782.821472] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=7s workers=2 idle: 95 30
[  782.824111] pool 8: cpus=4 node=0 flags=0x0 nice=0 hung=4s workers=6 idle: 86 2122 132 2163 2164 2106
[  782.827268] pool 9: cpus=4 node=0 flags=0x0 nice=-20 hung=4s workers=2 idle: 36 97
[  782.830008] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=8s workers=9 idle: 2153 2146 306 2120 2144 2145 2140 2155 87
[  782.833435] pool 11: cpus=5 node=0 flags=0x0 nice=-20 hung=4s workers=2 idle: 93 42
[  782.836114] pool 12: cpus=6 node=0 flags=0x0 nice=0 hung=0s workers=5 idle: 258 2123 506 2160 88
[  782.839049] pool 13: cpus=6 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 96 48
[  782.841727] pool 14: cpus=7 node=0 flags=0x0 nice=0 hung=9s workers=6 idle: 470 2161 2121 2137 89 2150
[  782.844850] pool 15: cpus=7 node=0 flags=0x0 nice=-20 hung=4s workers=2 idle: 99 54
[  782.847604] pool 16: cpus=8 node=0 flags=0x4 nice=0 hung=782s workers=0
[  782.850438] pool 17: cpus=8 node=0 flags=0x4 nice=-20 hung=782s workers=0

[ 1007.742112] Showing busy workqueues and worker pools:
[ 1007.744110] workqueue events: flags=0x0
[ 1007.745835]   pwq 14: cpus=7 node=0 flags=0x0 nice=0 active=2/256
[ 1007.748067]     in-flight: 470:rht_deferred_worker{102996} rht_deferred_worker{102996}
[ 1007.750867] workqueue events_freezable_power_: flags=0x84
[ 1007.752933]   pwq 12: cpus=6 node=0 flags=0x0 nice=0 active=1/256
[ 1007.755118]     in-flight: 2123:disk_events_workfn{27947}
[ 1007.757094] workqueue mm_percpu_wq: flags=0x18
[ 1007.758878]   pwq 3: cpus=1 node=0 flags=0x0 nice=-20 active=1/256
[ 1007.761177]     pending: drain_local_pages_wq{115542} BAR(2325){115542}
[ 1007.763543] workqueue writeback: flags=0x4e
[ 1007.765229]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[ 1007.767355]     in-flight: 400:wb_workfn{23} wb_workfn{23}
[ 1007.770144] workqueue xfs-eofblocks/sda1: flags=0xc
[ 1007.772130]   pwq 8: cpus=4 node=0 flags=0x0 nice=0 active=1/256
[ 1007.774388]     in-flight: 2122:xfs_eofblocks_worker [xfs]{150718}
[ 1007.776700] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 178 57 3323 2114
[ 1007.779630] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 4 98
[ 1007.782237] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=115s workers=4 idle: 2104 17 3322 81
[ 1007.785224] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=115s workers=2 idle: 92 18
[ 1007.788045] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=2 idle: 2154 2119
[ 1007.790817] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 24 94
[ 1007.793534] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=2 idle: 2117 2135
[ 1007.796327] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 30 95
[ 1007.799053] pool 8: cpus=4 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 86 132
[ 1007.801779] pool 9: cpus=4 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 36 97
[ 1007.804560] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 2146 2153 306
[ 1007.807460] pool 11: cpus=5 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 42 93
[ 1007.810222] pool 12: cpus=6 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 258 506
[ 1007.812973] pool 13: cpus=6 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 48 96
[ 1007.815723] pool 14: cpus=7 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 2161 2121
[ 1007.819226] pool 15: cpus=7 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 99 54
[ 1007.822063] pool 16: cpus=8 node=0 flags=0x4 nice=0 hung=1007s workers=0
[ 1007.824581] pool 17: cpus=8 node=0 flags=0x4 nice=-20 hung=1007s workers=0

[ 1106.385165] Showing busy workqueues and worker pools:
[ 1106.385182] workqueue events: flags=0x0
[ 1106.385218]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1106.385221]     pending: vmw_fb_dirty_flush{63}
[ 1106.385247] workqueue events_long: flags=0x0
[ 1106.385264]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1106.385266]     pending: gc_worker [nf_conntrack]{27}
[ 1106.385297] workqueue events_power_efficient: flags=0x80
[ 1106.385313]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[ 1106.385315]     pending: fb_flashcursor{47}
[ 1106.385375] workqueue writeback: flags=0x4e
[ 1106.385376]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[ 1106.385379]     in-flight: 400:wb_workfn{7} wb_workfn{7}
[ 1106.386250] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 178 57 3323 2114
[ 1106.386256] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 98 4
[ 1106.386259] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 2104 17 3322
[ 1106.386262] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 18 92
[ 1106.386265] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3327 2119 2154
[ 1106.386268] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 94 24
[ 1106.386270] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 2117 3324 2135
[ 1106.386273] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 30 95
[ 1106.386275] pool 8: cpus=4 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 2122 86 132
[ 1106.386278] pool 9: cpus=4 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 97 36
[ 1106.386280] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 2146 3332 2153
[ 1106.386283] pool 11: cpus=5 node=0 flags=0x0 nice=-20 hung=0s workers=3 idle: 42 3333 93
[ 1106.386286] pool 12: cpus=6 node=0 flags=0x0 nice=0 hung=0s workers=8 idle: 506 3330 3329 258 3328 3325 3326 2123
[ 1106.386290] pool 13: cpus=6 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 96 48
[ 1106.386293] pool 14: cpus=7 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 2161 470 3331 2121
[ 1106.386296] pool 15: cpus=7 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 54 99
[ 1106.386298] pool 16: cpus=8 node=0 flags=0x4 nice=0 hung=1106s workers=0
[ 1106.386300] pool 17: cpus=8 node=0 flags=0x4 nice=-20 hung=1106s workers=0

http://I-love.SAKURA.ne.jp/tmp/serial-20170830-2.txt.xz :

[  277.367469] Showing busy workqueues and worker pools:
[  277.367545] workqueue events_freezable_power_: flags=0x84
[  277.367573]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[  277.367577]     in-flight: 88:disk_events_workfn{15431}
[  277.367595] workqueue mm_percpu_wq: flags=0x18
[  277.367622]   pwq 3: cpus=1 node=0 flags=0x0 nice=-20 active=1/256
[  277.367625]     pending: drain_local_pages_wq{17528} BAR(2405){17527}
[  277.367668] workqueue writeback: flags=0x4e
[  277.367669]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  277.367672]     in-flight: 400:wb_workfn{0}
[  277.367676]     pending: wb_workfn{0}
[  277.368519] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=12 idle: 2103 57 2105 2110 259 2104 3 2099 2106 2108 2107 2109
[  277.368531] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 96 4
[  277.368535] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=17s workers=3 idle: 84 102 17
[  277.368539] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=17s workers=2 idle: 94 18
[  277.368542] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 444 85 23
[  277.368546] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 93 24
[  277.368551] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 86 156 2100 29
[  277.368556] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 30 92
[  277.368560] pool 8: cpus=4 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 87 240 35
[  277.368563] pool 9: cpus=4 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 36 95
[  277.368566] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 2111 308 41
[  277.368571] pool 11: cpus=5 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 97 42
[  277.368574] pool 12: cpus=6 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 47 311 89
[  277.368578] pool 13: cpus=6 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 99 48
[  277.368581] pool 14: cpus=7 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 83 146 53
[  277.368585] pool 15: cpus=7 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 54 98
[  277.368589] pool 16: cpus=8 node=0 flags=0x4 nice=0 hung=277s workers=0
[  277.368591] pool 17: cpus=8 node=0 flags=0x4 nice=-20 hung=277s workers=0

[  488.757378] Showing busy workqueues and worker pools:
[  488.759373] workqueue events_freezable_power_: flags=0x84
[  488.761431]   pwq 10: cpus=5 node=0 flags=0x0 nice=0 active=1/256
[  488.763659]     in-flight: 3158:disk_events_workfn{37021}
[  488.765712] workqueue mm_percpu_wq: flags=0x18
[  488.767541]   pwq 5: cpus=2 node=0 flags=0x0 nice=-20 active=1/256
[  488.769772]     pending: vmstat_update{101027}
[  488.771566]   pwq 3: cpus=1 node=0 flags=0x0 nice=-20 active=1/256
[  488.773812]     pending: drain_local_pages_wq{108219} BAR(3074){108190}
[  488.776363] workqueue writeback: flags=0x4e
[  488.778077]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  488.780471]     in-flight: 400:wb_workfn{36001} wb_workfn{36001}
[  488.784158] workqueue xfs-eofblocks/sda1: flags=0xc
[  488.786568]   pwq 12: cpus=6 node=0 flags=0x0 nice=0 active=1/256
[  488.788857]     in-flight: 47:xfs_eofblocks_worker [xfs]{156022}
[  488.791150] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3159 2103 57
[  488.794047] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=6s workers=2 idle: 96 4
[  488.796746] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=108s workers=3 idle: 84 102 17
[  488.799533] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=108s workers=2 idle: 94 18
[  488.802291] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=101s workers=3 idle: 444 3152 85
[  488.805121] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=101s workers=2 idle: 24 93
[  488.807894] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=2 idle: 86 156
[  488.810602] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=34s workers=2 idle: 30 92
[  488.813337] pool 8: cpus=4 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 87 3154 240
[  488.816206] pool 9: cpus=4 node=0 flags=0x0 nice=-20 hung=34s workers=2 idle: 36 95
[  488.818942] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 2111 308 88
[  488.821804] pool 11: cpus=5 node=0 flags=0x0 nice=-20 hung=34s workers=2 idle: 97 42
[  488.824652] pool 12: cpus=6 node=0 flags=0x0 nice=0 hung=0s workers=6 idle: 3150 3153 3155 3156 311
[  488.827793] pool 13: cpus=6 node=0 flags=0x0 nice=-20 hung=10s workers=2 idle: 99 48
[  488.830590] pool 14: cpus=7 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 3151 3157 146 83
[  488.833591] pool 15: cpus=7 node=0 flags=0x0 nice=-20 hung=34s workers=2 idle: 98 54
[  488.836396] pool 16: cpus=8 node=0 flags=0x4 nice=0 hung=488s workers=0
[  488.838876] pool 17: cpus=8 node=0 flags=0x4 nice=-20 hung=488s workers=0

[  542.541098] Showing busy workqueues and worker pools:
[  542.541110] workqueue events: flags=0x0
[  542.541136]   pwq 14: cpus=7 node=0 flags=0x0 nice=0 active=2/256
[  542.541139]     in-flight: 3151:vmw_fb_dirty_flush{16400} vmw_fb_dirty_flush{16400}
[  542.541146]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=2/256
[  542.541148]     in-flight: 84:console_callback{647}
[  542.541152]     pending: vmpressure_work_fn{539}
[  542.541265] workqueue writeback: flags=0x4e
[  542.541275]   pwq 256: cpus=0-127 flags=0x4 nice=0 active=2/256
[  542.541278]     in-flight: 400:wb_workfn{0}
[  542.541282]     pending: wb_workfn{0}
[  542.542017] workqueue xfs-buf/sda1: flags=0xc
[  542.542036]   pwq 2: cpus=1 node=0 flags=0x0 nice=0 active=1/1
[  542.542039]     pending: xfs_buf_ioend_work [xfs]{300}
[  542.542133] workqueue xfs-eofblocks/sda1: flags=0xc
[  542.542151]   pwq 12: cpus=6 node=0 flags=0x0 nice=0 active=1/256
[  542.542153]     in-flight: 47:xfs_eofblocks_worker [xfs]{209776}
[  542.542184] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3159 2103 57
[  542.542189] pool 1: cpus=0 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 96 4
[  542.542193] pool 2: cpus=1 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 102 17
[  542.542196] pool 3: cpus=1 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 18 94
[  542.542200] pool 4: cpus=2 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 444 3152 85
[  542.542204] pool 5: cpus=2 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 93 24
[  542.542221] pool 6: cpus=3 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 3160 156 86
[  542.542225] pool 7: cpus=3 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 30 92
[  542.542229] pool 8: cpus=4 node=0 flags=0x0 nice=0 hung=0s workers=3 idle: 87 3154 240
[  542.542233] pool 9: cpus=4 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 95 36
[  542.542236] pool 10: cpus=5 node=0 flags=0x0 nice=0 hung=0s workers=4 idle: 3158 2111 308 88
[  542.542241] pool 11: cpus=5 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 97 42
[  542.542244] pool 12: cpus=6 node=0 flags=0x0 nice=0 hung=0s workers=6 idle: 3150 3155 3153 3156 311
[  542.542249] pool 13: cpus=6 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 99 48
[  542.542253] pool 14: cpus=7 node=0 flags=0x0 nice=0 hung=0s workers=5 idle: 3161 83 3157 146
[  542.542257] pool 15: cpus=7 node=0 flags=0x0 nice=-20 hung=0s workers=2 idle: 98 54
[  542.542260] pool 16: cpus=8 node=0 flags=0x4 nice=0 hung=542s workers=0
[  542.542262] pool 17: cpus=8 node=0 flags=0x4 nice=-20 hung=542s workers=0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
