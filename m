Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8MErOdM026846
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 10:53:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8MErOY9158388
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 10:53:24 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8MErMJh028279
	for <linux-mm@kvack.org>; Mon, 22 Sep 2008 10:53:23 -0400
Subject: Re: [PATCH 9/13] memcg: lookup page cgroup (and remove pointer
	from struct page)
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 22 Sep 2008 07:52:56 -0700
Message-Id: <1222095177.8533.14.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-09-22 at 20:12 +0900, KAMEZAWA Hiroyuki wrote:
> +       /* we don't need too large hash */
> +       default_pcg_hash_size = (max_pfn/ENTS_PER_CHUNK);
> +       default_pcg_hash_size *= 2;
> +       /* if too big, use automatic calclation */
> +       if (default_pcg_hash_size > 1024 * 1024)
> +               default_pcg_hash_size = 0;
> +
> +       pcg_hashtable = alloc_large_system_hash("PageCgroup Hash",
> +                               sizeof(struct pcg_hash_head),
> +                               default_pcg_hash_size,
> +                               13,
> +                               0,
> +                               &pcg_hashshift,
> +                               &pcg_hashmask,
> +                               0);

The one thing I don't see here is much explanation about how large this
structure will get.

Basing it on max_pfn makes me nervous because of what it will do on
machines with very sparse memory.  Is this like sparsemem where the
structure can be small enough to actually span all of physical memory,
or will it be a large memory user?

Can you lay out how much memory this will use on a machine like Dave
Miller's which has 1GB of memory at 0x0 and 1GB of memory at 1TB up in
the address space?

Also, how large do the hash buckets get in the average case?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
