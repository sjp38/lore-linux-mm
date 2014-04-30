Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id EF86E6B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 09:44:30 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id hm4so991140wib.10
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 06:44:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id lz16si414702wic.1.2014.04.30.06.44.28
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 06:44:29 -0700 (PDT)
Date: Wed, 30 Apr 2014 09:30:35 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH v2] mm,writeback: fix divide by zero in pos_ratio_polynom
Message-ID: <20140430093035.7e7226f2@annuminas.surriel.com>
In-Reply-To: <5360C9E7.6010701@jp.fujitsu.com>
References: <20140429151910.53f740ef@annuminas.surriel.com>
	<5360C9E7.6010701@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, akpm@linux-foundation.org, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, mhocko@suse.cz, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

On Wed, 30 Apr 2014 19:01:11 +0900
Masayoshi Mizuma <m.mizuma@jp.fujitsu.com> wrote:

> Hi Rik,
> 
> I applied your patch to linux-next kernel, then divide error happened
> when I ran ltp stress test.
> The divide error occurred on the following div_u64(), so the following
> should be also fixed...
> 
> static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,

Good catch.  This patch fixes both places, and also has Andrew's
improvements in both places.

Andrew, this can drop in -mm instead of my previous patch and
your two cleanups to it.

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
index ef41349..f98a297 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -597,11 +597,16 @@ static inline long long pos_ratio_polynom(unsigned long setpoint,
 					  unsigned long dirty,
 					  unsigned long limit)
 {
+	unsigned long divisor;
 	long long pos_ratio;
 	long x;
 
+	divisor = limit - setpoint;
+	if (!divisor)
+		divisor = 1;	/* Avoid div-by-zero */
+
 	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
-		    limit - setpoint + 1);
+		    divisor);
 	pos_ratio = x;
 	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
 	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
@@ -842,8 +847,12 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
 	x_intercept = bdi_setpoint + span;
 
 	if (bdi_dirty < x_intercept - span / 4) {
+		unsigned long divisor = x_intercept - bdi_setpoint;
+		if (!divisor)
+			divisor = 1;	/* Avoid div-by-zero */
+
 		pos_ratio = div_u64(pos_ratio * (x_intercept - bdi_dirty),
-				    x_intercept - bdi_setpoint + 1);
+				    divisor);
 	} else
 		pos_ratio /= 4;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
