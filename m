Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 897CB6B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 18:27:59 -0400 (EDT)
Date: Tue, 18 Oct 2011 15:27:56 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: problems with memory hotplug/remove on 3.0.1
Message-ID: <20111018222756.GA3841@labbmf-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kparsha@codeaurora.org, vgandhi@codeaurora.org

We have encountered two problems with memory hotplug/hotremove
in 3.0.1 -- this is a port of memory hotplug to ARM with a few
small changes noted below.

Neither of these occurred on a similar 2.6.38-based port
we did to the same hardware.

The memory is essentially 2 512M memory banks, the lower
is always on, the upper is the one we are powering on
and off. ARCH_POPULATES_NODE_MAP was ported to ARM
and a small change was made to ensure that
the movable zone could be placed exactly where desired
(as movablecore= does not and must be specified on
the command line -- we don't know where the movable
zone must be until the kernel starts coming up).
Also the upper 512M is forced to be highmem as
the movable zone must come from the highest physical
memory zone (of course highmem may be larger than
512M, just not smaller).

1. If highmem is set to start at exactly 512M, then
all of highmem is used up when forming the movable
zone. This seems to confuse the memory management
subsystem (page reclaim?) because although the memory
hotremove of the upper 512M succeeds, running a command
that takes a pagefault after hotremove causes
the system to hang:

try_to_free_pages
__alloc_pages_nodemask
do_wp_page
handle_pte_fault
handle_mm_fault
do_page_fault

try_to_free_pages() is called repeatedly (forever), making no
apparent progress. After some experimentation, I
discovered that making the highmem zone at least 5M
larger than the 512M movable zone appears to make the
problem disappear.

I can (if I don't run anything that provokes the
above bug) hotplug the 512M back in, and then this
problem does not occur.

I've seen some discussion about very small zones causing
problems. Is what we are seeing a known problem?
Is there a known fix (or at least a patch we could try)?

2. Assuming the workaround we have for #1 is present,
we see memory hotremove occasionally fail. This seems
to (after a few seconds) cause init's state to become
corrupted, provoking a panic -- sometimes (but not always)
init's PC is 0. Sometimes additional (not always the
same) processes also unexpectedly exit after the
memory hotremove attempt.

Thanks in advance for any insight you might have.

Larry Bassel

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
