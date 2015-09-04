Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 95F626B0038
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 16:39:17 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so34161819pac.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 13:39:17 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id hw3si984478pbb.159.2015.09.04.13.39.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 13:39:17 -0700 (PDT)
Received: by pacwi10 with SMTP id wi10so34112097pac.3
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 13:39:16 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] Network stack, first user of SLAB/kmem_cache bulk
 free API.
References: <20150824005727.2947.36065.stgit@localhost>
 <20150904165944.4312.32435.stgit@devil> <55E9DE51.7090109@gmail.com>
 <alpine.DEB.2.11.1509041354560.993@east.gentwo.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Message-ID: <55EA0172.2040505@gmail.com>
Date: Fri, 4 Sep 2015 13:39:14 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509041354560.993@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, aravinda@linux.vnet.ibm.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com

On 09/04/2015 11:55 AM, Christoph Lameter wrote:
> On Fri, 4 Sep 2015, Alexander Duyck wrote:
>
>> were to create a per-cpu pool for skbs that could be freed and allocated in
>> NAPI context.  So for example we already have napi_alloc_skb, why not just add
>> a napi_free_skb and then make the array of objects to be freed part of a pool
>> that could be used for either allocation or freeing?  If the pool runs empty
>> you just allocate something like 8 or 16 new skb heads, and if you fill it you
>> just free half of the list?
> The slab allocators provide something like a per cpu pool for you to
> optimize object alloc and free.

Right, but one of the reasons for Jesper to implement the bulk 
alloc/free is to avoid the cmpxchg that is being used to get stuff into 
or off of the per cpu lists.

In the case of network drivers they are running in softirq context 
almost exclusively.  As such it is useful to have a set of buffers that 
can be acquired or freed from this context without the need to use any 
synchronization primitives.  Then once the softirq context ends then we 
can free up some or all of the resources back to the slab allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
