Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id B8AD86B0044
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 14:24:06 -0400 (EDT)
Received: from labbmf01-linux.qualcomm.com (pdmz-ns-snip_218_1.qualcomm.com [192.168.218.1])
	by mostmsg01.qualcomm.com (Postfix) with ESMTPA id DA1B410004BE
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 11:24:05 -0700 (PDT)
Date: Thu, 2 Aug 2012 11:24:04 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: How to steer allocations to or away from subsets of physical
 memory?
Message-ID: <20120802182404.GA4018@labbmf01-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I am looking for a way to steer allocations (these may be
by either userspace or the kernel) to or away from particular
ranges of memory. The reason for this is that some parts of
memory are different from others (i.e. some memory may be
faster/slower, some may potentially be powered off when
not in use, etc.).

One approach I have considered is to use NUMA and have
each block of memory with differing attributes be its own
node. This doesn't quite fit because:

1. Unlike the standard NUMA model, there will not be
any difference in memory access speed from
different CPUs to memory, rather an absolute difference
in access speed (or other attribute) from any CPU.
Thus the notion of a "local node" of memory bound to
each processor doesn't seem to fit.

These allocations must be steered independently of which
processor happens to be running.

2. For our use case it is not reasonable to make changes
to userspace code so that they become node-aware (i.e. have each
process use cpusets/cgroups/memory policies directly).
Even if this were possible, the user processes will need to run 
on different platforms which will have different node
layouts (i.e. there could be a varying number of nodes
of different sizes and attributes on different HW configurations
which userspace AFAIK wouldn't be able to deal with itself).

So my questions are:

1. Is NUMA the best fit here, or is there something that fits
better that I should consider?

2. If NUMA is a reasonable approach, is there already a way
to deal with nodes in a "processor independent" way (see issue
#1 above) to make the model fit our use case better?

3. We have done a "proof-of-concept" port of NUMA to ARM (at this
point artificially associating processors to nodes) and have
noticed some degradation in memory allocation time from userspace
(malloc'ing and touching various amounts of memory). This
appears to get somewhat worse as the number of nodes increases
(up to 8 which is the most we've tried), but even the case
where we enable NUMA but only have a single node is worse.
Is this to be expected, or is it simply a problem with our
initial port that should be fixable?

Thanks.

Larry Bassel

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
