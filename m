Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8MFpclR017639
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 11:51:38 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8MFlXrZ270912
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 11:47:33 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8MFlW7K005488
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 11:47:33 -0400
Subject: Re: Re: [PATCH 9/13] memcg: lookup page cgroup (and remove pointer
	from struct page)
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <31600854.1222096483210.kamezawa.hiroyu@jp.fujitsu.com>
References: <1222095177.8533.14.camel@nimitz>
	 <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com>
	 <31600854.1222096483210.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 22 Sep 2008 08:47:30 -0700
Message-Id: <1222098450.8533.41.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-09-23 at 00:14 +0900, kamezawa.hiroyu@jp.fujitsu.com wrote:
> >Basing it on max_pfn makes me nervous because of what it will do on
> >machines with very sparse memory.  Is this like sparsemem where the
> >structure can be small enough to actually span all of physical memory,
> >or will it be a large memory user?
> >
> I admit this calcuration is too easy. Hmm, based on totalram_pages is 
> better. ok.

No, I was setting a trap. ;)

If you use totalram_pages, I'll just complain that it doesn't work if a
memory hotplug machine drastically changes its size.  You'll end up with
pretty darn big hash buckets.

You basically can't get away with the fact that you (potentially) have
really sparse addresses to play with here.  Using a hash table is
exactly the same as using an array such as sparsemem except you randomly
index into it instead of using straight arithmetic.

My gut says that you'll need to do exactly the same things sparsemem did
here, which is at *least* have a two-level lookup before you get to the
linear search.  The two-level lookup also makes the hotplug problem
easier.

As I look at this, I always have to bounce between these tradeoffs:

1. deal with sparse address spaces (keeps you from using max_pfn)
2. scale as that sparse address space has memory hotplugged into it
   (keeps you from using boot-time present_pages)
3. deal with performance impacts from new data structures created to
   deal with the other two :)

> >Can you lay out how much memory this will use on a machine like Dave
> >Miller's which has 1GB of memory at 0x0 and 1GB of memory at 1TB up in
> >the address space?
> 
> >Also, how large do the hash buckets get in the average case?
> >
> on my 48GB box, hashtable was 16384bytes. (in dmesg log.)
> (section size was 128MB.)

I'm wondering how long the linear searches of those hlists get.

> I'll rewrite this based on totalram_pages.
> 
> BTW, do you know difference between num_physpages and totalram_pages ?

num_physpages appears to be linked to the size of the address space and
totalram_pages looks like the amount of ram present.  Kinda
spanned_pages and present_pages.  But, who knows how consistent they are
these days. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
