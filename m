Received: from dolphin.chromatix.org.uk ([192.168.239.105])
	by helium.chromatix.org.uk with esmtp (Exim 3.15 #5)
	id 1583tO-00029S-00
	for linux-mm@kvack.org; Thu, 07 Jun 2001 18:48:22 +0100
Message-Id: <l03130318b74568171b40@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 7 Jun 2001 18:48:18 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: VM tuning patch, take 2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've been coding my butt off for the past ... well, couple of evenings, and
I've got a modified 2.4.5 kernel which addresses some of the problems with
stock 2.4.5 VM.  To summarise:

- ageing is now done evenly, and independently of the number of mappings on
a given page.  This is done by introducing a 4th LRU list (aside from
active, inactive_clean and inactive_dirty) which holds pages attached to a
process but not in the swapcache.  This is then scanned immediately before
calling swap_out(), and does ageing up and down.  Maintenance of the new
list is done automatically as part of the existing add_page_to_*_list()
macros, and new pages are discovered by try_to_swap_out().  Also maintains
a count of pages on the list, which I'd like to report in /proc/meminfo.

- try_to_swap_out() will now refuse to move a page into the swapcache which
still has positive age.  This helps preserve the working set information,
and may help to reduce swap bloat.  It may re-introduce the cause of cache
collapse, but I haven't seen any evidence of this being disastrous, as yet.

- new pages are still given an age of PAGE_AGE_START, which is 2.
PAGE_AGE_ADV has been increased to 4, and PAGE_AGE_MAX to 128.  Pages which
are demand-paged in from swap are given an initial age of PAGE_AGE_MAX/2,
or 64 - this should help to keep these (expensive) pages around for as long
as possible.  Ageing down is now done using a decrement instead of a
division by 2, preserving the age information for longer.

- includes the original patch to reclaim dead swapcache pages quickly.  I
need to update this to the version which includes SMP locking and is
factored out into a function.  Would be nice to include the bdflush
swapcache-reclaim patch too.

- also includes my own patches to fix vm_enough_memory() and
out_of_memory() to be consistent with each other and reality.  This is a
big bug which has gone unfixed for too long, and which people ARE noticing.

The result is a kernel which exhibits considerably better performance under
high VM load (of the limited types I have available), uses less swap, and
is far less likely to go OOM unexpectedly, than the stock 2.4.x kernels.

Compiling MySQL with 256Mb RAM and make -j 15 now takes 6m15s on my Athlon
(make -j 10 takes around 5m and completes within physical RAM), during
which the mpg123 playing on a separate terminal stutters slightly a few
times but is not badly affected (the disk containing the MP3s is physically
separate from the swap device).  Swap usage goes to around 70Mb under these
conditions.

I'm just about to test single-threaded compilation with 48Mb and 32Mb
physical RAM, for comparison.  Previous best times are 6m30s and 2h15m
respectively...

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)

The key to knowledge is not to rely on people to teach you it.

GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
