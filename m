Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA07944
	for <linux-mm@kvack.org>; Mon, 9 Sep 2002 11:58:17 -0700 (PDT)
Message-ID: <3D7CEF39.56E55E9C@digeo.com>
Date: Mon, 09 Sep 2002 11:58:01 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] modified segq for 2.5
References: <Pine.LNX.4.44L.0208151119190.23404-100000@imladris.surriel.com> <3D7C6C0A.1BBEBB2D@digeo.com> <200209090740.16942.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Rik van Riel <riel@conectiva.com.br>, William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> On September 9, 2002 05:38 am, Andrew Morton wrote:
> 
> > With nonblocking-vm and slabasap, the test took 150 seconds.
> > Removing slabasap took it down to 98 seconds.  The slab rework
> > seemed to leave an extra megabyte average in cache.  Which is not
> > to say that the algorithms in there are wrong, but perhaps we should
> > push it a bit harder if there's swapout pressure.
> 
> Andrew, One simple change that will make slabasap try harder is to
> use only inactive pages caculating the ratio.
> 
> unsigned int nr_used_zone_pages(void)
> {
>         unsigned int pages = 0;
>         struct zone *zone;
> 
>         for_each_zone(zone)
>                 pages += zone->nr_inactive;
> 
>         return pages;
> }
> 
> This will make it closer to slablru which used the inactive list.

hmm.  Well if we are to be honest to the "account for seeks" thing
then perhaps we should double-count for swap activity - a swapout
and a swapin is two units of seekiness.  So consider add_to_swap()
to be worth two page scans.  Maybe the same for swap_writepage().

That should increase pressure on slab when anon pages are being
victimised.  Ditto for dirty MAP_SHARED I guess.

> Second item.  Do you run gkrelmon when doing your tests?  If not please
> install it and watch it slowly start to eat resources.   This morning (uptime
> 12hr) it was using 31% of CPU.  Stopping and starting it did not change this.
> Think we have something we can improve here.  I have inclued an strace
> of one (and a bit) update cycle.

I was running gkrellm for a while.  Is that the same thing?  I didn't
see anything untoward in there.  It seems to update at 10Hz or more,
so it's fairly expensive.  But no obvious increase in load across time.

It seems that the CPU load accounting in 2.5 is a bit odd; perhaps
as a result of the HZ changes.  Certainly it is hard to make comparisons
with 2.4 based upon it.  Probably one needs to equalise the HZ settings
to make useful comparison.

Anyway.  Could you please run the kernel profiler, see where the time
is being spent?  Just add `profile=1' to the kernel boot line and
use this:

readprofile -r
sleep 30
readprofile -v -m /boot/System.map | sort -n +2 | tail -40

(If readprofile screws up, edit your System.map and remove all
the lines containing " w " and " W ")
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
