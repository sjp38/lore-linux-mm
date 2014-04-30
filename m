Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9A04C6B003A
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 10:43:49 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so1480648eei.0
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 07:43:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id p8si31140896eew.36.2014.04.30.07.43.46
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 07:43:47 -0700 (PDT)
Date: Wed, 30 Apr 2014 10:41:14 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH v3] mm,writeback: fix divide by zero in pos_ratio_polynom
Message-ID: <20140430104114.4bdc588e@cuia.bos.redhat.com>
In-Reply-To: <20140430134826.GH4357@dhcp22.suse.cz>
References: <20140429151910.53f740ef@annuminas.surriel.com>
	<5360C9E7.6010701@jp.fujitsu.com>
	<20140430093035.7e7226f2@annuminas.surriel.com>
	<20140430134826.GH4357@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, akpm@linux-foundation.org, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

On Wed, 30 Apr 2014 15:48:26 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> This is still prone to u64 -> s32 issue, isn't it?
> What was the original problem anyway? Was it really setpoint > limit or
> rather the overflow?

This patch should avoid math overflows with both the initial
subtraction, and with use of the truncated divisor by div_s64
and div_u64.

I added redundant casts in the div_s64 and div_u64 calls to
make it clear what those functions do internally, which should
make it easy to understand why we do the same cast in the if
statements right above.

I believe this version of the patch addresses everybody's concerns.

---8<---

Subject: mm,writeback: fix divide by zero in pos_ratio_polynom

It is possible for "limit - setpoint + 1" to equal zero, leading to a
divide by zero error. Blindly adding 1 to "limit - setpoint" is not
working, so we need to actually test the divisor before calling div64.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/page-writeback.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index ef41349..6405687 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -598,10 +598,15 @@ static inline long long pos_ratio_polynom(unsigned long setpoint,
 					  unsigned long limit)
 {
 	long long pos_ratio;
+	long divisor;
 	long x;
 
+	divisor = limit - setpoint;
+	if (!(s32)divisor)
+		divisor = 1;	/* Avoid div-by-zero */
+
 	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
-		    limit - setpoint + 1);
+		    (s32)divisor);
 	pos_ratio = x;
 	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
 	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
@@ -842,8 +847,12 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
 	x_intercept = bdi_setpoint + span;
 
 	if (bdi_dirty < x_intercept - span / 4) {
+		unsigned long divisor = x_intercept - bdi_setpoint;
+		if (!(u32)divisor)
+			divisor = 1;	/* Avoid div-by-zero */
+
 		pos_ratio = div_u64(pos_ratio * (x_intercept - bdi_dirty),
-				    x_intercept - bdi_setpoint + 1);
+				    (u32)divisor);
 	} else
 		pos_ratio /= 4;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
