Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CD0916B0047
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 19:17:02 -0400 (EDT)
Message-Id: <1285629420.10278.1397188599@webmail.messagingengine.com>
From: "Robert Mueller" <robm@fastmail.fm>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="us-ascii"
References: <52C8765522A740A4A5C027E8FDFFDFE3@jem>
 <20100921090407.GA11439@csn.ul.ie>
 <20100927110049.6B31.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1009270828510.7000@router.home>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad
 forfile/email/web servers
In-Reply-To: <alpine.DEB.2.00.1009270828510.7000@router.home>
Reply-To: robm@fastmail.fm
Date: Tue, 28 Sep 2010 09:17:00 +1000
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, Bron
 Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> You can switch off zone reclaim of course which means that the
> applications will not be getting memory thats optimal for them to access.

That's true, but also remember that going to disk is going to be way
more expensive than memory on another node. What we found was that data
that should have been cached because it was being accessed a lot, wasn't
being cached, so it had to keep going back to disk to get it. That's
even worse.

> 1. Fix the ACPI information to indicate lower memory access
>    differences (was that info actually acurate?) so that zone reclaim
>    defaults to off.
> 
> 2. Change the RECLAIM_DISTANCE setting for the arch so that the ACPI
>    information does not trigger zone reclaim to be enabled.

How would the ACPI information actually be changed?

I ran numactl -H to get the hardware information, and that seems to
include distances. As mentioned previously, this is a very standard
Intel server motherboard.

http://www.intel.com/Products/Server/Motherboards/S5520UR/S5520UR-specifications.htm

Intel 5520 chipset with Intel I/O Controller Hub ICH10R

$ numactl -H
available: 2 nodes (0-1)
node 0 cpus: 0 2 4 6 8 10 12 14
node 0 size: 24517 MB
node 0 free: 1523 MB
node 1 cpus: 1 3 5 7 9 11 13 15
node 1 size: 24576 MB
node 1 free: 39 MB
node distances:
node   0   1
  0:  10  21
  1:  21  10

Since I'm not sure what the "distance" values mean, I have no idea if
those values large or not?

> 3. Run the application with numactl settings for interleaving of
>    memory accesses (or corresponding cpuset settings).
>
> 4. Fix the application to be conscious of the effect of memory
>    allocations on a NUMA systems. Use the numa memory allocations API
>    to allocate anonymous memory locally for optimal access and set
>    interleave for the file backed pages.

The problem we saw was purely with file caching. The application wasn't
actually allocating much memory itself, but it was reading lots of files
from disk (via mmap'ed memory mostly), and as most people would, we
expected that data would be cached in memory to reduce future reads from
disk. That was not happening.

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
