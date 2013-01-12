Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id F1A786B0068
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 22:24:22 -0500 (EST)
Date: Sat, 12 Jan 2013 14:24:07 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301120324.r0C3O7DY015947@como.maths.usyd.edu.au>
Subject: Re: [RFC] Reproducible OOM with partial workaround
In-Reply-To: <20130111123149.c3232a96.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: 695182@bugs.debian.org, dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Andrew,

>>> Check /proc/slabinfo, see if all your lowmem got eaten up by buffer_heads.
>> Please see below ...
> ... Was this dump taken when the system was at or near oom?

No, that was a "quiescent" machine. Please see a just-before-OOM dump in
my next message (in a little while).

> Please send a copy of the oom-killer kernel message dump, if you still
> have one.

Please see one in next message, or in
http://bugs.debian.org/695182

>> I tried setting dirty_ratio to "funny" values, that did not seem to
>> help.
> Did you try setting it as low as possible?

Probably. Maybe. Sorry, cannot say with certainty.

>> Did you notice my patch about bdi_position_ratio(), how it was
>> plain wrong half the time (for negative x)? 
> Nope, please resend.

Quoting from
http://bugs.debian.org/cgi-bin/bugreport.cgi?msg=101;att=1;bug=695182
:
...
 - In bdi_position_ratio() get difference (setpoint-dirty) right even
   when it is negative, which happens often. Normally these numbers are
   "small" and even with left-shift I never observed a 32-bit overflow.
   I believe it should be possible to re-write the whole function in
   32-bit ints; maybe it is not worth the effort to make it "efficient";
   seeing how this function was always wrong and we survived, it should
   simply be removed.
...
--- mm/page-writeback.c.old	2012-10-17 13:50:15.000000000 +1100
+++ mm/page-writeback.c	2013-01-06 21:54:59.000000000 +1100
[ Line numbers out because other patches not shown ]
...
@@ -559,7 +578,7 @@ static unsigned long bdi_position_ratio(
 	 *     => fast response on large errors; small oscillation near setpoint
 	 */
 	setpoint = (freerun + limit) / 2;
-	x = div_s64((setpoint - dirty) << RATELIMIT_CALC_SHIFT,
+	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
 		    limit - setpoint + 1);
 	pos_ratio = x;
 	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
...

Cheers, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
