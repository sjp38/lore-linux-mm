Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 57EFD6B0005
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 07:25:06 -0500 (EST)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 8 Feb 2013 22:19:23 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 17E442BB0050
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 23:24:48 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r18CCWR559441296
	for <linux-mm@kvack.org>; Fri, 8 Feb 2013 23:12:33 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r18COkKY021011
	for <linux-mm@kvack.org>; Fri, 8 Feb 2013 23:24:46 +1100
Message-ID: <5114EE1C.1040802@linux.vnet.ibm.com>
Date: Fri, 08 Feb 2013 17:52:52 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC][ATTEND] Linux VM Infrastructure to support Memory
 Power Management
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


Today, we are increasingly seeing computer systems sporting larger and larger
amounts of RAM, in order to meet workload demands. However, memory consumes a
significant amount of power, potentially upto more than a third of total system
power on server systems. So naturally, memory becomes the next big target for
power management - on embedded systems and smartphones, and all the way upto
large server systems.

Modern memory hardware such as DDR3 support a number of power management
capabilities. And new firmware standards such as ACPI 5.0 have added support
for exposing the power-management capabilities of the underlying memory hardware
to the Operating System. So it is upto the kernel's MM subsystem to make the
best use of these capabilities and manage memory power-efficiently.
It had been demonstrated on a Samsung Exynos board (with 2 GB RAM) that upto
6% of total system power can be saved by making the Linux kernel MM subsystem
power-aware[1]. (More savings can be expected on systems with larger amounts
of memory, and perhaps improved further using better MM designs).

Often this simply translates to having the Linux MM understand the granularity
at which RAM modules can be power-managed, and consolidating the memory
allocations and references to a minimum no. of these power-manageable
"memory regions". It is of particular interest to note that most of these
memory hardware have the intelligence to automatically save power, such as
putting memory banks into (content-preserving) low-power states when not
referenced for a threshold amount of time. All that the kernel has to do, is
avoid wrecking the power-savings logic by scattering its allocations and
references all over the system memory. IOW, the kernel/MM doesn't really need
to keep track of memory DIMMs and perform their power-state transitions - most
often it is automatically handled by the hardware/memory-controller. The MM
has to just co-operate by keeping the references consolidated to a minimum
no. of memory regions.

To that end, I had recently posted patchsets implementing 2 very different MM
designs, namely the "Hierarchy" design[2] (originally developed by Ankita Garg)
and the new "Sorted-buddy" design[3]. The challenge with the latter design is
that it can potentially lead to increased run-time memory allocation overheads.
At the summit, I would like to brainstorm on ideas and designs for reducing the
run-time cost of implementing memory power management, and seek suggestions and
feedback from MM developers on the issues involved.

About myself:
------------
I have been contributing to CPU- and System-wide power management subsystems in
the kernel such as CPU idle and Suspend-to-RAM, in terms of enhancements to their
reliability/scalability. In particular, I have contributed to some of the
core kernel infrastructure that Suspend-to-RAM depends on, such as Freezer and
CPU hotplug, and have been working towards redesigning CPU hotplug to get rid of
some of its pain points.

Recently I have been looking at conserving memory power, and came up with the
"Sorted-buddy" design [3] of the Linux MM, which alters the buddy allocator to
keep memory allocations consolidated to a minimum no. of memory regions. I would
like to discuss this topic with other MM developers at the summit and get
feedback on the best way to take this technology forward.


References:
----------

1. Estimate of potential power savings on Samsung exynos board
   http://article.gmane.org/gmane.linux.kernel.mm/65935

2. "Hierarchy" design for Memory Power Management:
    http://lwn.net/Articles/445045/ (Original posting by Ankita Garg)
    http://lwn.net/Articles/523311/ (Forward-port to 3.7-rc3)

3. "Sorted-buddy" design for Memory Power Management:
    http://article.gmane.org/gmane.linux.power-management.general/28498/


Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
