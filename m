Message-Id: <20070319155737.653325176@programming.kicks-ass.net>
Date: Mon, 19 Mar 2007 16:57:37 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 0/6] per device dirty throttling
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

This patch-set implements per device dirty page throttling. Which should solve
the problem we currently have with one device hogging the dirty limit.

Preliminary testing shows good results:

mem=128M

time (dd if=/dev/zero of=/mnt/<dev>/zero bs=4096 count=$((1024*1024/4)); sync)

1GB to disk

real    0m33.074s       0m34.596s       0m33.387s
user    0m0.147s        0m0.163s        0m0.142s
sys     0m7.872s        0m8.409s        0m8.395s

1GB to usb-flash

real    3m21.170s       3m15.512s       3m23.889s
user    0m0.135s        0m0.146s        0m0.127s
sys     0m7.327s        0m7.328s        0m7.342s


2.6.20 device vs device

1GB disk vs disk

real    1m30.736s       1m16.133s       1m42.068s
user    0m0.204s        0m0.167s        0m0.222s
sys     0m10.438s       0m7.958s        0m10.599s

1GB usb-flash vs background disk

N/A 30m+

1GB disk vs background usb-flash

real    4m0.687s        2m20.145s       4m12.923s
user    0m0.173s        0m0.185s        0m0.161s
sys     0m8.227s        0m8.581s        0m8.345s


2.6.20-writeback

1GB disk vs disk

real    0m36.696s	0m40.837s	0m38.679s
user    0m0.161s	0m0.148s	0m0.160s
sys     0m8.240s	0m8.068s	0m8.174s

1GB usb-flash vs background disk

real    3m37.464s	3m49.720s	4m5.805s
user    0m0.167s	0m0.166s	0m0.149s
sys     0m7.195s	0m7.281s	0m7.199s

1GB disk vs background usb-flash

real    0m41.585s	0m30.888s	0m34.493s
user    0m0.161s	0m0.167s	0m0.162s
sys     0m7.826s	0m7.807s	0m7.821s


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
