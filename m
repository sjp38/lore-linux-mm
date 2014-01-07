Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1706B0031
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 04:50:19 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so159766pde.13
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 01:50:19 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id im7si57805997pbd.221.2014.01.07.01.50.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 01:50:18 -0800 (PST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 7 Jan 2014 19:49:54 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id CF3C33578054
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 20:49:52 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s079nYCV11207146
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 20:49:40 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s079nk32005610
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 20:49:46 +1100
Date: Tue, 7 Jan 2014 17:49:44 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <52cbcdda.0719450a.58ec.265dSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20140107132100.5b5ad198@kryten>
 <20140107074136.GA4011@lge.com>
 <52cbbf7b.2792420a.571c.ffffd476SMTPIN_ADDED_BROKEN@mx.google.com>
 <20140107091016.GA21965@lge.com>
 <52cbc738.c727440a.5ead.27a3SMTPIN_ADDED_BROKEN@mx.google.com>
 <20140107093156.GA10157@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140107093156.GA10157@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Anton Blanchard <anton@samba.org>, benh@kernel.crashing.org, paulus@samba.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jan 07, 2014 at 06:31:56PM +0900, Joonsoo Kim wrote:
>On Tue, Jan 07, 2014 at 05:21:45PM +0800, Wanpeng Li wrote:
>> On Tue, Jan 07, 2014 at 06:10:16PM +0900, Joonsoo Kim wrote:
>> >On Tue, Jan 07, 2014 at 04:48:40PM +0800, Wanpeng Li wrote:
>> >> Hi Joonsoo,
>> >> On Tue, Jan 07, 2014 at 04:41:36PM +0900, Joonsoo Kim wrote:
>> >> >On Tue, Jan 07, 2014 at 01:21:00PM +1100, Anton Blanchard wrote:
>> >> >> 
>> >> [...]
>> >> >Hello,
>> >> >
>> >> >I think that we need more efforts to solve unbalanced node problem.
>> >> >
>> >> >With this patch, even if node of current cpu slab is not favorable to
>> >> >unbalanced node, allocation would proceed and we would get the unintended memory.
>> >> >
>> >> 
>> >> We have a machine:
>> >> 
>> >> [    0.000000] Node 0 Memory:
>> >> [    0.000000] Node 4 Memory: 0x0-0x10000000 0x20000000-0x60000000 0x80000000-0xc0000000
>> >> [    0.000000] Node 6 Memory: 0x10000000-0x20000000 0x60000000-0x80000000
>> >> [    0.000000] Node 10 Memory: 0xc0000000-0x180000000
>> >> 
>> >> [    0.041486] Node 0 CPUs: 0-19
>> >> [    0.041490] Node 4 CPUs:
>> >> [    0.041492] Node 6 CPUs:
>> >> [    0.041495] Node 10 CPUs:
>> >> 
>> >> The pages of current cpu slab should be allocated from fallback zones/nodes 
>> >> of the memoryless node in buddy system, how can not favorable happen? 
>> >
>> >Hi, Wanpeng.
>> >
>> >IIRC, if we call kmem_cache_alloc_node() with certain node #, we try to
>> >allocate the page in fallback zones/node of that node #. So fallback list isn't
>> >related to fallback one of memoryless node #. Am I wrong?
>> >
>> 
>> Anton add node_spanned_pages(node) check, so current cpu slab mentioned
>> above is against memoryless node. If I miss something?
>
>I thought following scenario.
>
>memoryless node # : 1
>1's fallback node # : 0
>
>On node 1's cpu,
>
>1. kmem_cache_alloc_node (node 2)
>2. allocate the page on node 2 for the slab, now cpu slab is that one.
>3. kmem_cache_alloc_node (local node, that is, node 1)
>4. It check node_spanned_pages() and find it is memoryless node.
>So return node 2's memory.
>
>Is it impossible scenario?
>

Indeed, it can happen. 

Regards,
Wanpeng Li 

>Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
