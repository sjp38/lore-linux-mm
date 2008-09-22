From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <32459434.1222099038142.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 23 Sep 2008 00:57:18 +0900 (JST)
Subject: Re: Re: Re: [PATCH 9/13] memcg: lookup page cgroup (and remove pointer from struct page)
In-Reply-To: <1222098450.8533.41.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <1222098450.8533.41.camel@nimitz>
 <1222095177.8533.14.camel@nimitz>
	 <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com>
	 <31600854.1222096483210.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>> >
>> I admit this calcuration is too easy. Hmm, based on totalram_pages is 
>> better. ok.
>
>No, I was setting a trap. ;)
>
Bomb!

>If you use totalram_pages, I'll just complain that it doesn't work if a
>memory hotplug machine drastically changes its size.  You'll end up with
>pretty darn big hash buckets.
>
As I wrote, this is just _generic_ one.
I'll add FLATMEM and SPARSEMEM support later.

I never want to write SPARSEMEM_EXTREME by myself and want to depend
on SPARSEMEM's internal implementation, which I know well.


>You basically can't get away with the fact that you (potentially) have
>really sparse addresses to play with here.  Using a hash table is
>exactly the same as using an array such as sparsemem except you randomly
>index into it instead of using straight arithmetic.
>
see the next patch. per-cpu look-aside cache works well.

>My gut says that you'll need to do exactly the same things sparsemem did
>here, which is at *least* have a two-level lookup before you get to the
>linear search.  The two-level lookup also makes the hotplug problem
>easier.
>
>As I look at this, I always have to bounce between these tradeoffs:
>
>1. deal with sparse address spaces (keeps you from using max_pfn)
>2. scale as that sparse address space has memory hotplugged into it
>   (keeps you from using boot-time present_pages)
>3. deal with performance impacts from new data structures created to
>   deal with the other two :)
>
>> >Can you lay out how much memory this will use on a machine like Dave
>> >Miller's which has 1GB of memory at 0x0 and 1GB of memory at 1TB up in
>> >the address space?
>> 
>> >Also, how large do the hash buckets get in the average case?
>> >
>> on my 48GB box, hashtable was 16384bytes. (in dmesg log.)
>> (section size was 128MB.)
>
>I'm wondering how long the linear searches of those hlists get.
>
In above case, just one step.  16384/8 * 128MB.
In ppc, it has 16MB sections, hash table will be bigger. But "walk" is
not very long.
Anyway, How "walk" is long is not very big problem because look-aside
buffer helps.

I'll add FLATMEM/SPARSEMEM support later. Could you wait for a while ?
Because we have lookup_page_cgroup() after this, we can do anything.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
