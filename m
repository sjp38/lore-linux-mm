Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id DA4746B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 20:47:09 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id w8so7234752qac.36
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 17:47:09 -0800 (PST)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id t3si9101270qas.14.2014.01.31.17.47.08
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 17:47:09 -0800 (PST)
Date: Fri, 31 Jan 2014 19:47:06 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: [LSF/MM ATTEND] Defragmentation approaches
Message-ID: <alpine.DEB.2.10.1401311938100.9879@nuc>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: lsf-pc@lists.linuxfoundation.org

It seems that fragmentation is in the way of many kernel subsystems and we
are adding numerous allocators to deal with the problem of getting access
to contiguous memory (CMA, ION, huge page allocators, memory pools and
boot memory management etc etc).

Some subsystems performance already depends on contiguous physical memory
(like the slub allocator that can use larger physical pages but falls back
to lesser sizes if those are not available). The limited availability of
higher order pages limits the performance reachable with various linux
subsystemm since we are getting into issues with too many page structs
to handle to manage memory (See my talk "Bazillions of pages" at the OLS
in 2008).

I would like to discuss approaches to dealing with this problem.

- Can we reduce the number of times we create new allocators to manage the
problem? Maybe have a couple that cover all the use cases and that have
APIs that are expandable?

- Can we generalize the existing approaches with reserving pages of a
certain size (hugepages, giant pages) to an arbitrary order? F.e. would it
be possible to create 64k page pools to be able to handle devices that
require 64k physical blocks for full performance.

- Are there any novell approaches to defragmentation?

F.e.

In the past I have pushed one approach that emerges from what page
migration accomplishes: If all memory becomes movable then defragmentation
becomes possible. I have in the past added features to make slab memory
movable (via callbacks). This could be generalized an used in other
allocators to ensure that memory is movable. If we can get so far as to
ensure that all of memory is movable then the fragmentation problem goes
away.,

- Maybe also an open discussion on more ways to address these issues?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
