Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8C2176B0047
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 09:54:09 -0400 (EDT)
Date: Mon, 27 Sep 2010 08:53:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad forfile/email/web
 servers
In-Reply-To: <20100927110049.6B31.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009270828510.7000@router.home>
References: <52C8765522A740A4A5C027E8FDFFDFE3@jem> <20100921090407.GA11439@csn.ul.ie> <20100927110049.6B31.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Sep 2010, KOSAKI Motohiro wrote:

> > No doubt this is true. The only real difference is that there are more NUMA
> > machines running mail/web/file servers now than there might have been in the
> > past. The default made sense once upon a time. Personally I wouldn't mind
> > the default changing but my preference would be that distribution packages
> > installing on NUMA machines would prompt if the default should be changed if it
> > is likely to be of benefit for that package (e.g. the mail, file and web ones).
>
> At first impression, I thought this is cute idea. But, after while thinking, I've found some
> weak point. The problem is, too many package need to disable zone_reclaim_mode.
> zone_reclaim doesn't works fine if an application need large working set rather than
> local node size. It mean major desktop applications (e.g. OpenOffice.org, Firefox, GIMP)
> need to disable zone_reclaim. It mean even though basic package installation require
> zone_reclaim disabling. Then, this mechanism doesn't works practically. Even though
> the user hope to use the machine for hpc, disable zone_reclaim will be turn on anyway.
>
> Probably, opposite switch (default is zone_reclaim=0, and installation MPI library change
> to zone_reclaim=1) might works. but I can guess why you don't propose this one.

The fundamental problem that needs to be addressed is the balancing of a
memory load in a system with memory ranges that have different performance
characteristics when running conventional software that does not
properly balance allocations and that has not been written with these
new memory balancing issues in mind.

You can switch off zone reclaim of course which means that the
applications will not be getting memory thats optimal for them to access.
Given the current minimal NUMA differences in most single server systems
this is likely not going to matter. In fact the kernel has such a
mechanism to switch off zone reclaim for such systems (see the definition
of RECLAIM_DISTANCE). Which seems to have somehow been defeated by the
ACPI information of those machines which indicate a high latency
difference between the memory areas. The arch code could be adjusted to
set a higher RECLAIM_DISTANCE so that this motherboard also will default
to zone reclaim mode off.

However, the larger the NUMA effects become the more the performance loss
due to these effect. Its expected that the number of processors and
therefore also the NUMA effects in coming generations of machines will
increase. Various API exist to do finer grained memory access control so
that the performance loss can be isolated to processes or memory ranges.

F.e. running the application with numactl (using interleave) or a cpuset
with round robin on could address this issue without changing zone
reclaim and would allow other processes to allocate faster local memory.

The problem with zone reclaim mainly is created for large apps whose
working set is larger than the local node. The special settings are only
needing for those applications.

What can be done here is:

1. Fix the ACPI information to indicate lower memory access differences
   (was that info actually acurate?) so that zone reclaim defaults to off.

2. Change the RECLAIM_DISTANCE setting for the arch so that the ACPI
   information does not trigger zone reclaim to be enabled.

3. Run the application with numactl settings for interleaving of memory
   accesses (or corresponding cpuset settings).

4. Fix the application to be conscious of the effect of memory allocations
   on a NUMA systems. Use the numa memory allocations API to allocate
   anonymous memory locally for optimal access and set interleave for the
   file backed pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
