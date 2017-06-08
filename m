Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 517B86B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 01:44:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h21so11476722pfk.13
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 22:44:34 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id b15si3546945pfh.381.2017.06.07.22.44.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Jun 2017 22:44:33 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: 4.12-rc ppc64 4k-page needs costly allocations
In-Reply-To: <alpine.LSU.2.11.1706012045240.4854@eggly.anvils>
References: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils> <87h9014j7t.fsf@concordia.ellerman.id.au> <alpine.DEB.2.20.1705310906570.14920@east.gentwo.org> <alpine.LSU.2.11.1705311112290.1839@eggly.anvils> <alpine.DEB.2.20.1706011027310.8835@east.gentwo.org> <alpine.LSU.2.11.1706011002130.3014@eggly.anvils> <alpine.DEB.2.20.1706011306560.11993@east.gentwo.org> <alpine.LSU.2.11.1706011128490.3622@eggly.anvils> <878tlb2igt.fsf@concordia.ellerman.id.au> <alpine.LSU.2.11.1706012045240.4854@eggly.anvils>
Date: Thu, 08 Jun 2017 15:44:29 +1000
Message-ID: <87efuvdoea.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Christoph Lameter <cl@linux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Hugh Dickins <hughd@google.com> writes:
> On Fri, 2 Jun 2017, Michael Ellerman wrote:
>> Hugh Dickins <hughd@google.com> writes:
>> > On Thu, 1 Jun 2017, Christoph Lameter wrote:
>> >> 
>> >> Ok so debugging was off but the slab cache has a ctor callback which
>> >> mandates that the free pointer cannot use the free object space when
>> >> the object is not in use. Thus the size of the object must be increased to
>> >> accomodate the freepointer.
>> >
>> > Thanks a lot for working that out.  Makes sense, fully understood now,
>> > nothing to worry about (though makes one wonder whether it's efficient
>> > to use ctors on high-alignment caches; or whether an internal "zero-me"
>> > ctor would be useful).
>> 
>> Or should we just be using kmem_cache_zalloc() when we allocate from
>> those slabs?
>> 
>> Given all the ctor's do is memset to 0.
>
> I'm not sure.  From a memory-utilization point of view, with SLUB,
> using kmem_cache_zalloc() there would certainly be better.
>
> But you may be forgetting that the constructor is applied only when a
> new slab of objects is allocated, not each time an object is allocated
> from that slab (and the user of those objects agrees to free objects
> back to the cache in a reusable state: zeroed in this case).

Ah yes, I was "forgetting" that :) - ie. didn't know it.

> So from a cpu-utilization point of view, it's better to use the ctor:
> it's saving you lots of redundant memsets.

OK. Presumably we guarantee (somewhere) that the page tables are zeroed
before we free them, which is a natural result of tearing down all
mappings?

But then I see other arches (x86, arm64 at least), which don't use a
constructor, and use __GPF_ZERO (via PGALLOC_GFP) at allocation time.

eg. arm64:

	pgd_cache = kmem_cache_create("pgd_cache", PGD_SIZE, PGD_SIZE,
				      SLAB_PANIC, NULL);
        ...
	return kmem_cache_alloc(pgd_cache, PGALLOC_GFP);


So that's a bit puzzling.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
