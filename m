Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id D6A8F6B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 16:04:58 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id e53so1729021eek.36
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:04:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id q5si31971239eem.111.2014.04.30.13.04.52
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 13:04:53 -0700 (PDT)
Date: Wed, 30 Apr 2014 16:02:18 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH v4] mm,writeback: fix divide by zero in pos_ratio_polynom
Message-ID: <20140430160218.442863e0@cuia.bos.redhat.com>
In-Reply-To: <20140430123526.bc6a229c1ea4addad1fb483d@linux-foundation.org>
References: <20140429151910.53f740ef@annuminas.surriel.com>
	<5360C9E7.6010701@jp.fujitsu.com>
	<20140430093035.7e7226f2@annuminas.surriel.com>
	<20140430134826.GH4357@dhcp22.suse.cz>
	<20140430104114.4bdc588e@cuia.bos.redhat.com>
	<20140430120001.b4b95061ac7252a976b8a179@linux-foundation.org>
	<53614F3C.8020009@redhat.com>
	<20140430123526.bc6a229c1ea4addad1fb483d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

On Wed, 30 Apr 2014 12:35:26 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> > The easy way would be by calling div64_s64 and div64_u64,
> > which are 64 bit all the way through.
> > 
> > Any objections?
> 
> Sounds good to me.
> 
> > The inlined bits seem to be stubs calling the _rem variants
> > of the functions, and discarding the remainder.
> 
> I was referring to pos_ratio_polynom().  The compiler will probably be
> uninlining it anyway, but still...

I believe this should do the trick.

---8<---

Subject: mm,writeback: fix divide by zero in pos_ratio_polynom

It is possible for "limit - setpoint + 1" to equal zero, leading to a
divide by zero error. Blindly adding 1 to "limit - setpoint" is not
working, so we need to actually test the divisor before calling div64.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 mm/page-writeback.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index ef41349..37f56bb 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -593,15 +593,20 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
  * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
  *     => fast response on large errors; small oscillation near setpoint
  */
-static inline long long pos_ratio_polynom(unsigned long setpoint,
+static long long pos_ratio_polynom(unsigned long setpoint,
 					  unsigned long dirty,
 					  unsigned long limit)
 {
+	unsigned long divisor;
 	long long pos_ratio;
 	long x;
 
-	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
-		    limit - setpoint + 1);
+	divisor = limit - setpoint;
+	if (!divisor)
+		divisor = 1;	/* Avoid div-by-zero */
+
+	x = div64_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
+		    divisor);
 	pos_ratio = x;
 	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
 	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
@@ -842,8 +847,12 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
 	x_intercept = bdi_setpoint + span;
 
 	if (bdi_dirty < x_intercept - span / 4) {
-		pos_ratio = div_u64(pos_ratio * (x_intercept - bdi_dirty),
-				    x_intercept - bdi_setpoint + 1);
+		unsigned long divisor = x_intercept - bdi_setpoint;
+		if (!divisor)
+			divisor = 1;	/* Avoid div-by-zero */
+
+		pos_ratio = div64_u64(pos_ratio * (x_intercept - bdi_dirty),
+				    divisor);
 	} else
 		pos_ratio /= 4;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
