Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5C0F06B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 11:43:25 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 0/2 v3] Flexible proportions
Date: Tue, 15 May 2012 17:43:01 +0200
Message-Id: <1337096583-6049-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>


  Hello,

  here is the next iteration of my flexible proportions code. Changes since
v2 are:
  * use timer instead of workqueue for triggering period switch
  * arm timer only if aging didn't zero out all fractions, re-arm timer when
    new event arrives again
  * set period length to 3s

  Some introduction for first time readers:

  The idea of this patch set is to provide code for computing event proportions
where aging period is not dependent on the number of events happening (so
that aging works well both with fast storage and slow USB sticks in the same
system).

  The basic idea is that we compute proportions as:
p_j = (\Sum_{i>=0} x_{i,j}/2^{i+1}) / (\Sum_{i>=0} x_i/2^{i+1})

  Where x_{i,j} is j's number of events in i-th last time period and x_i is
total number of events in i-th last time period.

  Note that when x_i's are all the same (as is the case with current
proportion code), this expression simplifies to the expression defining
current proportions which is:
p_j =  \Sum_{i>=0} x_{i,j}/2^{i+1} / t

  where t is the lenght of the aging period.

  In fact, if we are in the middle of the period, the proportion computed by
the current code is:
p_j = (x_0 + \Sum_{i>=1} x_{i,j}/2^{i+1}) / (t' + t)

  where t' is total number of events in the running period and t is the lenght
of the aging period. So there is event more similarity.

  Similarly as with current proportion code, it is simple to compute update
proportion after several periods have elapsed. For each proportion we store
the numerator of our fraction and the number of period when the proportion
was last updated. In global proportion structure we compute the denominator
of the fraction which is the same for all event types. So catch up with missed
periods boils down to shifting the numerator by the number of missed periods
and that's it. For more details, please see the code.

  I've also run a few tests (I've created a userspace wrapper to allow me to
run proportion code in userpace and arbitrarily generate events for it) to
compare the behavior of old and new code. You can see them at
http://beta.suse.com/private/jack/flex_proportions/ In all the tests new code
showed faster convergence to current event proportions (I tried to
realistically set period_shift for fixed proportions).  Also in the last test
we see that if period_shift is decreased, then current proportions become more
sensitive to short term fluctuations in event rate so just decreasing
period_shift isn't a good solution to slower convergence. If anyone has other
idea what to try, I can do that - it should be simple enough to implement in
my testing tool.

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
