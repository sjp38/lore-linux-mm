Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6C88D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 20:39:06 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [RFC PATCH 0/5] IO-less balance dirty pages
Date: Fri,  4 Feb 2011 02:38:49 +0100
Message-Id: <1296783534-11585-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org


  Hi,

  I've decided to take my stab at trying to make balance_dirty_pages() not
submit IO :). I hoped to have something simpler than Fengguang and we'll see
whether it is good enough.

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

I gave the patches some basic testing (multiple parallel dd's to a single
drive) and they seem to work OK. The dd's get equal share of the disk
throughput (about 10.5 MB/s, which is nice result given the disk can do
about 87 MB/s when writing single-threaded), and dirty limit does not get
exceeded. Of course much more testing needs to be done but I hope it's fine
for the first posting :).

Comments welcome.

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
