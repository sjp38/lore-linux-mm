Received: from hoon.perlsupport.com (root@dt0e3na9.tampabay.rr.com [24.92.175.169])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA24965
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 18:28:53 -0500
Received: by hoon.perlsupport.com
	via sendmail from stdin
	id <m0zzUMn-0001bsC@hoon.perlsupport.com> (Debian Smail3.2.0.102)
	for linux-mm@kvack.org; Sun, 10 Jan 1999 18:33:57 -0500 (EST)
Date: Sun, 10 Jan 1999 18:33:56 -0500
From: Chip Salzenberg <chip@perlsupport.com>
Subject: testing/pre-7 and do_poll()
Message-ID: <19990110183356.C262@perlsupport.com>
References: <36990DB5.DA6AE432@netplus.net> <Pine.LNX.3.95.990110130307.7668N-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.95.990110130307.7668N-100000@penguin.transmeta.com>; from Linus Torvalds on Sun, Jan 10, 1999 at 01:41:38PM -0800
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

According to Linus Torvalds:
> There's a "pre-7.gz" on ftp.kernel.org in testing, anybody interested?

Got it, like it -- *except* the fix for overflow in do_poll() is a
little bit off.  Quoting testing/pre-7:

	if (timeout) {
		/* Carefula about overflow in the intermediate values */
		if ((unsigned long) timeout < MAX_SCHEDULE_TIMEOUT / HZ)
			timeout = (timeout*HZ+999)/1000+1;
		else /* Negative or overflow */
			timeout = MAX_SCHEDULE_TIMEOUT;
	}

However, the maximum legal millisecond timeout isn't (as shown)
MAX_SCHEDULE_TIMEOUT/HZ, but rather MAX_SCHEDULE_TIMEOUT/(1000/HZ).
So this code will turn some large timeouts into MAX_SCHEDULE_TIMEOUT
unnecessarily.

Therefore, I suggest this patch:

Index: fs/select.c
*************** asmlinkage int sys_poll(struct pollfd * 
*** 336,346 ****
  		goto out;
  
! 	if (timeout) {
! 		/* Carefula about overflow in the intermediate values */
! 		if ((unsigned long) timeout < MAX_SCHEDULE_TIMEOUT / HZ)
! 			timeout = (timeout*HZ+999)/1000+1;
! 		else /* Negative or overflow */
! 			timeout = MAX_SCHEDULE_TIMEOUT;
! 	}
  
  	err = -ENOMEM;
--- 336,343 ----
  		goto out;
  
! 	if (timeout < 0)
! 		timeout = MAX_SCHEDULE_TIMEOUT;
! 	else if (timeout)
! 		timeout = ROUND_UP(timeout, 1000/HZ);
  
  	err = -ENOMEM;


-- 
Chip Salzenberg      - a.k.a. -      <chip@perlsupport.com>
      "When do you work?"   "Whenever I'm not busy."
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
