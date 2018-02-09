Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id ADABA6B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 03:50:04 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id b6so1755543plx.3
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 00:50:04 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id o18si1390352pfa.407.2018.02.09.00.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 00:50:03 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3] mm, swap, frontswap: Fix THP swap if frontswap enabled
Date: Fri,  9 Feb 2018 16:49:47 +0800
Message-Id: <20180209084947.22749-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, "Huang, Ying" <ying.huang@intel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>

From: Huang Ying <huang.ying.caritas@gmail.com>

It was reported by Sergey Senozhatsky that if THP (Transparent Huge
Page) and frontswap (via zswap) are both enabled, when memory goes low
so that swap is triggered, segfault and memory corruption will occur
in random user space applications as follow,

kernel: urxvt[338]: segfault at 20 ip 00007fc08889ae0d sp 00007ffc73a7fc40 error 6 in libc-2.26.so[7fc08881a000+1ae000]
 #0  0x00007fc08889ae0d _int_malloc (libc.so.6)
 #1  0x00007fc08889c2f3 malloc (libc.so.6)
 #2  0x0000560e6004bff7 _Z14rxvt_wcstoutf8PKwi (urxvt)
 #3  0x0000560e6005e75c n/a (urxvt)
 #4  0x0000560e6007d9f1 _ZN16rxvt_perl_interp6invokeEP9rxvt_term9hook_typez (urxvt)
 #5  0x0000560e6003d988 _ZN9rxvt_term9cmd_parseEv (urxvt)
 #6  0x0000560e60042804 _ZN9rxvt_term6pty_cbERN2ev2ioEi (urxvt)
 #7  0x0000560e6005c10f _Z17ev_invoke_pendingv (urxvt)
 #8  0x0000560e6005cb55 ev_run (urxvt)
 #9  0x0000560e6003b9b9 main (urxvt)
 #10 0x00007fc08883af4a __libc_start_main (libc.so.6)
 #11 0x0000560e6003f9da _start (urxvt)

After bisection, it was found the first bad commit is
bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped
out").

The root cause is as follow.

When the pages are written to swap device during swapping out in
swap_writepage(), zswap (fontswap) is tried to compress the pages
instead to improve the performance.  But zswap (frontswap) will treat
THP as normal page, so only the head page is saved.  After swapping
in, tail pages will not be restored to its original contents, so cause
the memory corruption in the applications.

This is fixed via rejecting to save page in frontswap store functions
if the page is a THP.  So that the THP will be swapped out to swap
device.

Another choice is to split THP if frontswap is enabled.  But it is
found that the frontswap enabling isn't flexible.  For example, if
CONFIG_ZSWAP=y (cannot be module), frontswap will be enabled even if
zswap itself isn't enabled.

Frontswap has multiple backends, to make it easy for one backend to
enable THP support, the THP checking is put in backend frontswap store
functions instead of the general interfaces.

Fixes: bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped out")
Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Suggested-by: Minchan Kim <minchan@kernel.org> # put THP checking in backend
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjenning@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Shaohua Li <shli@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: stable@vger.kernel.org # 4.14

Changelog:

v3:

- Fix via checking THP in frontswap backend as suggested by Minchan.

v2:

- Move frontswap check into swapfile.c to avoid to make vmscan.c
  depends on frontswap as suggested by Minchan.
---
 drivers/xen/tmem.c | 4 ++++
 mm/zswap.c         | 6 ++++++
 2 files changed, 10 insertions(+)

diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index bf13d1ec51f3..04e7b3b29bac 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -284,6 +284,10 @@ static int tmem_frontswap_store(unsigned type, pgoff_t offset,
 	int pool = tmem_frontswap_poolid;
 	int ret;
 
+	/* THP isn't supported */
+	if (PageTransHuge(page))
+		return -1;
+
 	if (pool < 0)
 		return -1;
 	if (ind64 != ind)
diff --git a/mm/zswap.c b/mm/zswap.c
index c004aa4fd3f4..61a5c41972db 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -1007,6 +1007,12 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	u8 *src, *dst;
 	struct zswap_header zhdr = { .swpentry = swp_entry(type, offset) };
 
+	/* THP isn't supported */
+	if (PageTransHuge(page)) {
+		ret = -EINVAL;
+		goto reject;
+	}
+
 	if (!zswap_enabled || !tree) {
 		ret = -ENODEV;
 		goto reject;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
