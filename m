Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m53IxPNI025669
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 14:59:25 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m53IxHZi117434
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 12:59:20 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m53IxGNG027801
	for <linux-mm@kvack.org>; Tue, 3 Jun 2008 12:59:17 -0600
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080603182413.GJ20824@one.firstfloor.org>
References: <20080603095956.781009952@amd.local0.net>
	 <20080603100939.967775671@amd.local0.net>
	 <1212515282.8505.19.camel@nimitz.home.sr71.net>
	 <20080603182413.GJ20824@one.firstfloor.org>
Content-Type: text/plain
Date: Tue, 03 Jun 2008 11:59:15 -0700
Message-Id: <1212519555.8505.33.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-06-03 at 20:24 +0200, Andi Kleen wrote:
> > Then, give the boot-time large page reservations either to hugepages= or
> > a new boot option.  But, instead of doing it in number of hpages, do it
> > in sizes like hugepages=10G.  Bootmem-alloc that area, and make it
> 
> That assumes you can allocate all 10GB continuously.  Might be not true.
> e.g. consider a 16GB x86 with its 1GB PCI memory hole at 4GB and user
> wants 14GB worth of hugepages. It would need to allocate over the hole
> which is not possible in your scheme.
> 
> The bootmem allocator always needs to know the size to be able to split
> up.

Yeah, that's very true.  But, it shouldn't be too hard to work around.
We could try to allocate a set of bootmem areas which are, at their
largest, the largest available hsize, then fall back to smaller areas as
needed.

The downside of something like this is that you have yet another data
structure to manage.  Andi, do you think something like this would be
workable?

int alloc_boot_hpages(unsigned long needed)
{
	while(needed > 0) {
		unsigned long alloc = 0;
		/* would need to be sorted descending hsize */	 
		for_each(hsize) {
			alloc = alloc_bootmem(hsize)
			if (alloc) {
				add_to_hpage_pool(alloc);
				break;
			}
		}
		if (!alloc) {
			WARN();
			break;
		}
		needed -= alloc;
	}
}

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
