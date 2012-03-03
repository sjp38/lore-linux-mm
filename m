Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id BD8106B004A
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 19:09:13 -0500 (EST)
Received: by bkwq16 with SMTP id q16so2705588bkw.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2012 16:09:12 -0800 (PST)
Date: Sat, 3 Mar 2012 04:09:09 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 1/3] vmevent: Fix build for SWAP=n case
Message-ID: <20120303000909.GA30207@oksana.dev.rtsoft.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org

Caught this build failure:

  CC      mm/vmevent.o
mm/vmevent.c:17:6: error: expected identifier or '(' before numeric constant
mm/vmevent.c:18:1: warning: no semicolon at end of struct or union [enabled by default]
mm/vmevent.c: In function 'vmevent_sample':
mm/vmevent.c:84:36: error: expected identifier before numeric constant
make[1]: *** [mm/vmevent.o] Error 1
make: *** [mm/] Error 2

This is because linux/swap.h defines nr_swap_pages to 0L, and so things
break.

Fix this by undefinding it back, as we don't use it anyway.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---

The patch is for git://github.com/penberg/linux.git vmevent/core.

 mm/vmevent.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/vmevent.c b/mm/vmevent.c
index 37d2c5f..2342752 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -6,6 +6,7 @@
 #include <linux/poll.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
+#undef nr_swap_pages /* This is defined to a constant for SWAP=n case */
 
 #define VMEVENT_MAX_FREE_THRESHOD	100
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
