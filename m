From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <31600854.1222096483210.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 23 Sep 2008 00:14:43 +0900 (JST)
Subject: Re: Re: [PATCH 9/13] memcg: lookup page cgroup (and remove pointer from struct page)
In-Reply-To: <1222095177.8533.14.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <1222095177.8533.14.camel@nimitz>
 <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>On Mon, 2008-09-22 at 20:12 +0900, KAMEZAWA Hiroyuki wrote:
>> +       /* we don't need too large hash */
>> +       default_pcg_hash_size = (max_pfn/ENTS_PER_CHUNK);
>> +       default_pcg_hash_size *= 2;
>> +       /* if too big, use automatic calclation */
>> +       if (default_pcg_hash_size > 1024 * 1024)
>> +               default_pcg_hash_size = 0;
>> +
>> +       pcg_hashtable = alloc_large_system_hash("PageCgroup Hash",
>> +                               sizeof(struct pcg_hash_head),
>> +                               default_pcg_hash_size,
>> +                               13,
>> +                               0,
>> +                               &pcg_hashshift,
>> +                               &pcg_hashmask,
>> +                               0);
>
>The one thing I don't see here is much explanation about how large this
>structure will get.
>
max 8MB. (1024 *1024 * 8)...I'll reduce this.

>Basing it on max_pfn makes me nervous because of what it will do on
>machines with very sparse memory.  Is this like sparsemem where the
>structure can be small enough to actually span all of physical memory,
>or will it be a large memory user?
>
I admit this calcuration is too easy. Hmm, based on totalram_pages is 
better. ok.


>Can you lay out how much memory this will use on a machine like Dave
>Miller's which has 1GB of memory at 0x0 and 1GB of memory at 1TB up in
>the address space?
>

>Also, how large do the hash buckets get in the average case?
>
on my 48GB box, hashtable was 16384bytes. (in dmesg log.)
(section size was 128MB.)

I'll rewrite this based on totalram_pages.

BTW, do you know difference between num_physpages and totalram_pages ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
