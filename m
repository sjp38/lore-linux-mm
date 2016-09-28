Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E372828024F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 18:10:37 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l187so1917030oia.2
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 15:10:37 -0700 (PDT)
Received: from mail5.wrs.com (mail5.windriver.com. [192.103.53.11])
        by mx.google.com with ESMTPS id v134si7734347oia.269.2016.09.28.15.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 15:10:19 -0700 (PDT)
Message-ID: <57EC3FC7.8010000@windriver.com>
Date: Wed, 28 Sep 2016 16:10:15 -0600
From: Chris Friesen <chris.friesen@windriver.com>
MIME-Version: 1.0
Subject: Re: Oops in slab.c in CentOS kernel, looking for ideas -- correction,
 it's in slub.c
References: <57EA9A78.8080509@windriver.com> <57EABB64.7070607@windriver.com> <20160928051445.GA22706@js1304-P5Q-DELUXE>
In-Reply-To: <20160928051445.GA22706@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org

On 09/27/2016 11:14 PM, Joonsoo Kim wrote:
> On Tue, Sep 27, 2016 at 12:33:08PM -0600, Chris Friesen wrote:
>> On 09/27/2016 10:12 AM, Chris Friesen wrote:

>>> Basically it appears that __mpol_dup() is failing because the value of
>>> c->freelist in slab_alloc_node() is corrupt, causing the call to
>>> get_freepointer_safe(s, object) to Oops because it tries to dereference
>>> "object + s->offset".  (Where s->offset is zero.)
>>>
>>> In the trace, "kmem_cache_alloc+0x87" maps to the following assembly:
>>>     0xffffffff8118be17 <+135>:   mov    (%r12,%rax,1),%rbx
>>>
>>> This corresponds to this line in get_freepointer():
>>> 	return *(void **)(object + s->offset);
>>>
>>> In the assembly code, R12 is "object", and RAX is s->offset.
>>>
>>> So the question becomes, why is "object" (which corresponds to c->freelist)
>>> corrupt?
>>>
>>> Looking at the value of R12 (0x1ada8000), it's nonzero but also not a
>>> valid pointer. Does the value mean anything to you?  (I'm not really
>>> a memory subsystem guy, so I'm hoping you might have some ideas.)
>>>
>>> Do you have any suggestions on how to track down what's going on here?
>
> Please run with kernel parameter "slub_debug=F" or something.
> See Documentation/vm/slub.txt.

I enabled /sys/kernel/slab/numa_policy/sanity_checks, but that's only going to 
maybe help if I can cause another CPU to get into the bad state.

I created a kernel module to walk the list of objects starting at 
__this_cpu_ptr(policy_cache->cpu_slab)->freelist.

All other cpus had a freelist value of NULL, or else they pointed at a linked 
list which eventually ended with a NULL pointer.  ("s->offset" is 0, so 
get_freepointer() just dereferences "object")  For example:

cpu: 45, object: ffff88046d483cd8->ffff88046d483de0->ffff88046d483ee8->NULL
cpu: 46, object: NULL

In the case of CPU 48, the value of 
__this_cpu_ptr(policy_cache->cpu_slab)->freelist was good, but dereferencing it 
gave an invalid address:

cpu: 48, object: ffff8804102f0528->000000001ada8000


In the code path that causes problems we call mpol_new(), which calls 
kmem_cache_alloc(policy_cache, GFP_KERNEL) and consumes the object at 
0xffff8804102f0528.  This results in 
__this_cpu_ptr(policy_cache->cpu_slab)->freelist being set to 
0x000000001ada8000.   Then we fork, which calls __mpol_dup() which calls 
kmem_cache_alloc(policy_cache, GFP_KERNEL) with 'object' set to 
0x000000001ada8000, which segfaults when we try to dereference it in 
get_freepointer().

So how do items get added to the freelist?  Do they always get added at the 
head, or is there a path where they could get added at the tail?

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
