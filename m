Received: from noc.nyx.net (mail@noc.nyx.net [206.124.29.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA30294
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 07:54:57 -0500
Date: Mon, 11 Jan 1999 05:54:24 -0700 (MST)
From: Colin Plumb <colin@nyx.net>
Message-Id: <199901111254.FAA06857@nyx10.nyx.net>
Subject: Re: testing/pre-7 and do_poll()
Sender: owner-linux-mm@kvack.org
To: chip@perlsupport.com
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chip Salzenberg wrote:
> Well, I forgot the (unsigned long) cast, as someone else noted:

>	timeout = ROUND_UP((unsigned long) timeout, 1000/HZ);

>
> Otherwise, the code is Just Right.

Um, this works perfectly when HZ == 100, but consider what happens when
HZ == 1024.  1000/HZ == 0, and then computing (x+0-1)/0 doesn't work so well.

If you want accuracy with no danger of overflow, try the following trick:

	ticks = (msec/1000)*HZ + (msec%1000)*HZ/1000.

To make this more efficient, use that only on large values of msec,
and the simpler (msec*HZ)/1000.  In thhe HZ > 1000 case, you also lose
the guarantee that every legal msec value corresponds to a 

(C experts will note that none of the parens are necessary, but I though
it was clearer to include them.)

So, for perfection, you want:

unsigned long msec_to_ticks(unsigned long msec)
{
	if (msec <= ULONG_MAX/HZ)
		return msec*HZ/1000;
#if HZ > 1000
	/* Wups, can overflow - saturate return value */
	if (msec > (ULONG_MAX/HZ)*1000 + (ULONG_MAX % HZ)*1000/HZ)
		return ULONG_MAX
#endif
	return (msec/1000)*HZ + (msec%1000)*HZ/1000;
}

Um... this is the rounding-down case, and also saturates at ULONG_MAX
instead of MAX_SCHEDULE_TIMEOUT (LONG_MAX).  Let me adjust the boundary
cases a bit...

#if MAX_SCHEDULE_TIMEOUT != LONG_MAX
#error Adjust this code - it assumes identical input and output ranges
#endif
unsigned long msec_to_ticks(unsigned long msec)
{
	if (msec < ULONG_MAX/HZ - 999)
		return (msec+999)*HZ/1000;
	msec--;	/* Following code rounds up and adds one */
#if HZ > 1000
	/* Wups, can overflow - saturate return value */
	if (msec >= (ULONG_MAX/HZ)*1000 + (ULONG_MAX % HZ)*1000/HZ)
		return MAX_SCHEDULE_TIMEOUT;
#endif
	return (msec/1000)*HZ + (msec%1000)*HZ/1000 + 1;
}
-- 
	-Colin
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
