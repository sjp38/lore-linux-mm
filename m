Message-Id: <l03130301b73f486b8acb@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sun, 3 Jun 2001 03:06:22 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Some VM tweaks (against 2.4.5)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've made a collection of small tweaks to the 2.4.5 VM which "work for me",
and hopefully are largely applicable to other workloads as well.

http://www.chromatix.uklinux.net/linux-patches/vm-update-1.patch

Summary (roughly in order as found in the patchfile):

- Increased PAGE_AGE_MAX and PAGE_AGE_START to help newly-created and
frequently-accessed pages remain in physical RAM.

- Includes my tweak to vm_enough_memory(), to limit memory reservation
under low-memory conditions (this isn't quite working as expected, but
seems to be harmless).

- Fixes out_of_memory() to use the same (and more correct) criteria as
vm_enough_memory().  Does NOT include my revised OOM-killer algorithm,
although it is probably sorely needed.

- Changed age_page_down() and family to use a decrement instead of divide
(gives frequently-accessed pages a longer lease of life).

- In try_to_swap_out(), take page->age into account and age it down rather
than swapping it out immediately.

- In swap_out_mm(), don't allow large processes to force out processes
which have smaller RSS than them.  kswapd can still cause any process to be
paged out.  This replaces my earlier "enforce minimum RSS" hack.

- Bump up the page->age to PAGE_AGE_START when moving a page to the active
list in page_launder().

- Includes Zlatko Calusic's patch from earlier today, since I can't see
anything immediately wrong about it.

Please go ahead and test, and (constructively) criticise.

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
big-mail: chromatix@penguinpowered.com
uni-mail: j.d.morton@lancaster.ac.uk

The key to knowledge is not to rely on people to teach you it.

Get VNC Server for Macintosh from http://www.chromatix.uklinux.net/vnc/

-----BEGIN GEEK CODE BLOCK-----
Version 3.12
GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
-----END GEEK CODE BLOCK-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
