Received: from localhost (riel@localhost)
	by duckman.distro.conectiva (8.9.3/8.8.7) with ESMTP id CAA30868
	for <linux-mm@kvack.org>; Sun, 20 Aug 2000 02:18:44 -0300
Date: Sun, 20 Aug 2000 02:18:44 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: differential throttling & local page replacement
Message-ID: <Pine.LNX.4.21.0008200119410.30483-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I think I have worked out two (related) things to make the
system (more) resistant against thrashing memory hogs,
more interactive during heavy IO load and resistant against
heavy disk writes.

The basic idea revolves around one statistic, which is kept
locally per process and globally, lets call it fault_rate.

On every page fault (in handle_mm_fault()) and on write()
calls, we do a current->fault_rate++, global_fault_rate++;
The value will be decayed on a regular basis.
(that this may count write faults twice is probably a
beneficial effect)

This will mean that for every process we will know the
percentage of page faults in the system are for this
process  (current->fault_rate * 100 / global_fault_rate)
and we can use this ratio for 2 different, but related,
things.


First there's write throttling. The current write
throttling code has the disadvantage that one heavily
writing thread can stall the others too. The formula
(in balance_dirty_state()) is as follows:

if (nr_dirty * 100 > total * max_dirty_percentage/2)
	wake_up_bdflush(NOWAIT);

if (nr_dirty * 100 > total * max_dirty_percentage)
	wake_up_bdflush(WAIT);

Since waiting on a disk write is rather expensive, it
may well be worth it to change the second formula a
bit to take into account the percentage of VM activity
of the current process and put VM or disk bandwidth
hogs to sleep a bit earlier so they won't impact the
performance of lower activity tasks.

local_max_percentage = (max_dirty_percentage - \
	((current->fault_rate * max_dirty_percentage/3) /  \
	global_fault_rate);

if (nr_dirty * 100 > total * local_max_percentage)
	wake_up_bdflush(WAIT);

This will still allow disk bandwidth eaters to run at
full disk speed, but without having any of the less IO
intensive processes stalled on IO.


The second place where we can use these statistics is
in making sure VM hogs (where a hog is defined as a
process that has lots of page faults and causes the VM
subsystem to be busy) don't impact the rest of the system
too much.

The idea here is to make the VM hog do local page replacement
some percentage of the time, the percentage of course being
its own (current->fault_rate * 100 / global_fault_rate). To
prevent a task from doing only local page replacement while
there are idle pages sitting around, this should only happen
when the amount of free+freeable memory is _lower_ than the
amount of memory kswapd tries to keep free, so the local page
replacement only kicks in at the moment where our task truly
starts to burden the rest of the system.

So if:

if (nr_free_pages() + nr_inactive_clean_pages() < kswapd_goal / 2) {
	do_local_fault_rate_percentage_of_the_time()
		swap_out_mm(current->mm);
}

Or, alternatively:

if (nr_free_pages() + nr_inactive_clean_pages() <
				 kswapd_goal * local_fault_ratio)
	swap_out_mm(current->mm);

This way the memory hog (say, mmap002, tar, ...) will do some
page replacement on itself to protect the rest of the system.
Of course we need to do something like that for the page cache
too, but that should be trivial.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
