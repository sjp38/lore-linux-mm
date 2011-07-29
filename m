Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 30B266B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 18:12:34 -0400 (EDT)
Date: Fri, 29 Jul 2011 15:12:31 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: questions about memory hotplug
Message-ID: <20110729221230.GA3466@labbmf-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

We want to handle the following 2 use cases we have on
some of our (ARM) platforms:

1. A platform where part of the memory may be powered
off. The location and size of this memory is not known
until the kernel parses the memory tags (there aren't
any non-standard tags used, but the memory layout and
a memory bank size which is obtained from HW are used
to figure out where and how large this memory is). All
of this memory must either be on or off. For a given
configuration the location of this memory can't be moved.

2. A (different) platform where part of the memory
is occasionally needed as a large physically contiguous 
block, but usually is not (and then should be usable
by the kernel as normal memory). When the memory is
needed for the contiguous block, the pages in this
range currently being used by the kernel will
need to be migrated out.

The size of this is known at compile time and can be
placed at any reasonable place in memory (but should
be SPARSEMEM section aligned -- its size may however
not be a power of 2 and thus this memory could
span more than one section). This memory will not be
powered off, but must either be completely used for
one purpose or the other.

The size of memory in question for #1 is generally
much larger than that of #2.

Memory hotplug/hotremove (logical and physical for #1,
only logical for #2) approximately solves these problems,
but there is some functionality we need that AFAIK is
not present:

* The memory in #1 and #2 above must be in a movable
zone so that the chance of migration is maximized.
I'm familiar with the kernelcore= and movablecore=
commandline options, but they don't do what is necessary
here, because we need control on where the movable zone
is formed as well as the size. Also the location and size
of these special memory areas is not known until the
kernel comes up (in #1 it is conceivable that the bootloader
could locate the memory that can be powered on and off and
pass it in via some commandline option, but AFAICT this won't
work at all for #2).

One could hack up find_zone_movable_pfns_for_nodes() presumably,
but I wonder if there is an already existing way of doing
this (or at least a clean extension to the current
functionality that someone might suggest).

Would CONFIG_ARCH_POPULATES_NODE_MAP help here? Does anyone
use this? It doesn't seem to be in any defconfig or Kconfig
on 3.0 (or earlier versions I've looked at).

Perhaps CMA (which is not merged yet and AFAIK still has some
issues on ARM) might handle #2 better than memory
hotplug/hotremove. Or is there a better way to handle #2
than either CMA or memory hotplug?

Thanks.

Larry

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
