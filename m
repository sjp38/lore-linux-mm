Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7976B004A
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 03:05:11 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad forfile/email/web servers
References: <52C8765522A740A4A5C027E8FDFFDFE3@jem>
	<20100921090407.GA11439@csn.ul.ie>
	<20100927110049.6B31.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1009270828510.7000@router.home>
Date: Thu, 30 Sep 2010 09:05:05 +0200
In-Reply-To: <alpine.DEB.2.00.1009270828510.7000@router.home> (Christoph
	Lameter's message of "Mon, 27 Sep 2010 08:53:58 -0500 (CDT)")
Message-ID: <87aamzww2m.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter <cl@linux.com> writes:
>
> 1. Fix the ACPI information to indicate lower memory access differences
>    (was that info actually acurate?) so that zone reclaim defaults to off.

The reason the ACPI information is set this way is that the people who
tune the BIOS have some workload they care about which prefers zone
reclaim off and they know they can force this "faster setting" by faking
the distances.

Basically they're working around a Linux performance quirk.

Really I think some variant of Motohiro-san's patch is the right
solution: most problems with zone reclaim are related to IO 
intensive workloads and it never made sense to have the unmapped
disk cache local on a system with reasonably small NUMA factor.

The only problem is on extremly big NUMA systems where remote nodes
are so slow that it's too slow even for read() and write().
I have been playing with the idea of adding a new "nearby interleave"
NUMA mode for this, but didn't have time to implement it so far.

For application I don't think we can ever solve it completely, this
probably always needs some kind of tuning. Currently the NUMA policy
APIs are not too good for this because they are too static, e.g. in some
cases "nearby" without fixed node affinity would also help here.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
