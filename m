Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F01848D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 17:31:27 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple approach)
Date: Tue,  8 Mar 2011 23:31:10 +0100
Message-Id: <1299623475-5512-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>


  Hello,

  I'm posting second version of my IO-less balance_dirty_pages() patches. This
is alternative approach to Fengguang's patches - much simpler I believe (only
300 lines added) - but obviously I does not provide so sophisticated control.
Fengguang is currently running some tests on my patches so that we can compare
the approaches.

The basic idea (implemented in the third patch) is that processes throttled
in balance_dirty_pages() wait for enough IO to complete. The waiting is
implemented as follows: Whenever we decide to throttle a task in
balance_dirty_pages(), task adds itself to a list of tasks that are throttled
against that bdi and goes to sleep waiting to receive specified amount of page
IO completions. Once in a while (currently HZ/10, in patch 5 the interval is
autotuned based on observed IO rate), accumulated page IO completions are
distributed equally among waiting tasks.

This waiting scheme has been chosen so that waiting time in
balance_dirty_pages() is proportional to
  number_waited_pages * number_of_waiters.
In particular it does not depend on the total number of pages being waited for,
thus providing possibly a fairer results.

Since last version I've implemented cleanups as suggested by Peter Zilstra.
The patches undergone more throughout testing. So far I've tested different
filesystems (ext2, ext3, ext4, xfs, nfs), also a combination of a local
filesystem and nfs. The load was either various number of dd threads or
fio with several threads each dirtying pages at different speed.

Results and test scripts can be found at
  http://beta.suse.com/private/jack/balance_dirty_pages-v2/
See README file for some explanation of test framework, tests, and graphs.
Except for ext3 in data=ordered mode, where kjournald creates high
fluctuations in waiting time of throttled processes (and also high latencies),
the results look OK. Parallel dd threads are being throttled in the same way
(in a 2s window threads spend the same time waiting) and also latencies of
individual waits seem OK - except for ext3 they fit in 100 ms for local
filesystems. They are in 200-500 ms range for NFS, which isn't that nice but
to fix that we'd have to modify current ratelimiting scheme to take into
account on which bdi a page is dirtied. Then we could ratelimit slower BDIs
more often thus reducing latencies in individual waits...

The results for different bandwidths fio load is interesting. There are 8
threads dirtying pages at 1,2,4,..,128 MB/s rate. Due to different task
bdi dirty limits, what happens is that three most aggresive tasks get
throttled so they end up at bandwidths 24, 26, and 30 MB/s and the lighter
dirtiers run unthrottled.

I'm planning to run some tests with multiple SATA drives to verify whether
there aren't some unexpected fluctuations. But currently I have some trouble
with the HW...

As usual comments are welcome :).

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
