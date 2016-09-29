Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9579B6B026B
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 21:38:07 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u134so16457186itb.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 18:38:07 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a19si13293769ioj.57.2016.09.28.18.37.39
        for <linux-mm@kvack.org>;
        Wed, 28 Sep 2016 18:37:40 -0700 (PDT)
Date: Thu, 29 Sep 2016 10:46:09 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Oops in slab.c in CentOS kernel, looking for ideas --
 correction, it's in slub.c
Message-ID: <20160929014608.GB29250@js1304-P5Q-DELUXE>
References: <57EA9A78.8080509@windriver.com>
 <57EABB64.7070607@windriver.com>
 <20160928051445.GA22706@js1304-P5Q-DELUXE>
 <57EC3FC7.8010000@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57EC3FC7.8010000@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Friesen <chris.friesen@windriver.com>
Cc: linux-mm@kvack.org

On Wed, Sep 28, 2016 at 04:10:15PM -0600, Chris Friesen wrote:
> On 09/27/2016 11:14 PM, Joonsoo Kim wrote:
> >On Tue, Sep 27, 2016 at 12:33:08PM -0600, Chris Friesen wrote:
> >>On 09/27/2016 10:12 AM, Chris Friesen wrote:
> 
> >>>Basically it appears that __mpol_dup() is failing because the value of
> >>>c->freelist in slab_alloc_node() is corrupt, causing the call to
> >>>get_freepointer_safe(s, object) to Oops because it tries to dereference
> >>>"object + s->offset".  (Where s->offset is zero.)
> >>>
> >>>In the trace, "kmem_cache_alloc+0x87" maps to the following assembly:
> >>>    0xffffffff8118be17 <+135>:   mov    (%r12,%rax,1),%rbx
> >>>
> >>>This corresponds to this line in get_freepointer():
> >>>	return *(void **)(object + s->offset);
> >>>
> >>>In the assembly code, R12 is "object", and RAX is s->offset.
> >>>
> >>>So the question becomes, why is "object" (which corresponds to c->freelist)
> >>>corrupt?
> >>>
> >>>Looking at the value of R12 (0x1ada8000), it's nonzero but also not a
> >>>valid pointer. Does the value mean anything to you?  (I'm not really
> >>>a memory subsystem guy, so I'm hoping you might have some ideas.)
> >>>
> >>>Do you have any suggestions on how to track down what's going on here?
> >
> >Please run with kernel parameter "slub_debug=F" or something.
> >See Documentation/vm/slub.txt.
> 
> I enabled /sys/kernel/slab/numa_policy/sanity_checks, but that's
> only going to maybe help if I can cause another CPU to get into the
> bad state.

It would help because it checks all the operations of the slub. If
wrong pointer is freed, it can detect at that moment. It also check
next free object pointer so problem would be found earlier.

If it would not detect your problem, I guess that someone overwrite
content of freed object. Could you check with slub_debug=FZPU.

And, KASAN would help you, too.

> 
> I created a kernel module to walk the list of objects starting at
> __this_cpu_ptr(policy_cache->cpu_slab)->freelist.
> 
> All other cpus had a freelist value of NULL, or else they pointed at
> a linked list which eventually ended with a NULL pointer.
> ("s->offset" is 0, so get_freepointer() just dereferences "object")
> For example:
> 
> cpu: 45, object: ffff88046d483cd8->ffff88046d483de0->ffff88046d483ee8->NULL
> cpu: 46, object: NULL
> 
> In the case of CPU 48, the value of
> __this_cpu_ptr(policy_cache->cpu_slab)->freelist was good, but
> dereferencing it gave an invalid address:
> 
> cpu: 48, object: ffff8804102f0528->000000001ada8000
> 
> 
> In the code path that causes problems we call mpol_new(), which
> calls kmem_cache_alloc(policy_cache, GFP_KERNEL) and consumes the
> object at 0xffff8804102f0528.  This results in
> __this_cpu_ptr(policy_cache->cpu_slab)->freelist being set to
> 0x000000001ada8000.   Then we fork, which calls __mpol_dup() which
> calls kmem_cache_alloc(policy_cache, GFP_KERNEL) with 'object' set
> to 0x000000001ada8000, which segfaults when we try to dereference it
> in get_freepointer().
> 
> So how do items get added to the freelist?  Do they always get added
> at the head, or is there a path where they could get added at the
> tail?

They always get added at the head.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
