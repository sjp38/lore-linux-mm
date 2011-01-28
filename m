Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ABBE28D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:11:16 -0500 (EST)
Message-ID: <4D42F899.3080004@redhat.com>
Date: Fri, 28 Jan 2011 12:10:49 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: too big min_free_kbytes
References: <20110126154203.GS926@random.random> <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110127160301.GA29291@csn.ul.ie> <20110127185215.GE16981@random.random> <20110127213106.GA25933@csn.ul.ie> <4D41FD2F.3050006@redhat.com> <20110128103539.GA14669@csn.ul.ie> <20110128162831.GH16981@random.random>
In-Reply-To: <20110128162831.GH16981@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>
List-ID: <linux-mm.kvack.org>

On 01/28/2011 11:28 AM, Andrea Arcangeli wrote:

> In short I think the zone balancing problem tackled in kswapd is wrong
> and kswapd should stick to the high wmark only, and if you care about
> zone balancing it should be done in the allocator only, then kswapd
> will cope with whatever the allocator decides just fine.

The allocator does not have information on which memory
zones have more heavily used data vs which zones have
less frequently used data.

When the system starts up, we do our initial allocations
in the top zone.  This includes both heavily used files
(like libc) and never-used-again files, as well as daemons
that are active and daemons that go to sleep and never do
anything again.

After initial startup, we may eventually end up falling
back to lower memory zones.

In short, we may have an imbalance between the zones in
how actively memory is used, from the moment the system
has started up.

The distance between the low and high watermarks
corresponds only to the relative size of each zone.

Having kswapd move only between these two watermarks
means that memory in each zone is allocated and freed
only according to zone size, not according to how
actively used the memory in each zone is.

Giving kswapd a little bit of extra room where it
is allowed to extra free pages in a zone with lots of
infrequently used and easily reclaimable pages, when
another zone in the same node suffers from harder to
deal with memory pressure, will steer more allocations
towards the memory zone that has less pressure.

This should even out the pressure between zones over
time.

We have had the kernel work like this since 2.6.0, and
I believe that removing this "pressure valve" from the
VM will result in the kind of balancing problems we had
in some 2.4 kernels.

Reducing the size of the gap is fine with me, since
the pressure should even out over time.  Removing the
gap is just asking for trouble.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
