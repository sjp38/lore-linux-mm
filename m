Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3AE6B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 21:07:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 21so234839636pfy.3
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 18:07:22 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id u14si25817785pal.70.2016.09.18.18.07.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Sep 2016 18:07:20 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: More OOM problems
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
	<214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz>
Date: Sun, 18 Sep 2016 18:07:19 -0700
In-Reply-To: <214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz> (Vlastimil Babka's
	message of "Sun, 18 Sep 2016 23:00:29 +0200")
Message-ID: <87twdc4rzs.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>, cl@linux-foundation.org

Vlastimil Babka <vbabka@suse.cz> writes:
>> 
>> The trigger is a kcalloc() in the i915 driver:
>> 
>>     Xorg invoked oom-killer:
>> gfp_mask=0x240c0d0(GFP_TEMPORARY|__GFP_COMP|__GFP_ZERO), order=3,
>> oom_score_adj=0
>> 
>>       __kmalloc+0x1cd/0x1f0
>>       alloc_gen8_temp_bitmaps+0x47/0x80 [i915]
>> 
>> which looks like it is one of these:
>> 
>>   slabinfo - version: 2.1
>>   # name            <active_objs> <num_objs> <objsize> <objperslab>
>> <pagesperslab>
>>   kmalloc-8192         268    268   8192    4    8
>>   kmalloc-4096         732    786   4096    8    8
>>   kmalloc-2048        1402   1456   2048   16    8
>>   kmalloc-1024        2505   2976   1024   32    8
>> 
>> so even just a 1kB allocation can cause an order-3 page allocation.
>
> Sounds like SLUB. SLAB would use order-0 as long as things fit. I would
> hope for SLUB to fallback to order-0 (or order-1 for 8kB) instead of
> OOM, though. Guess not...

It's already trying to do that, perhaps just some flags need to be
changed?

Adding Christoph.

	flags |= s->allocflags;

	/*
	 * Let the initial higher-order allocation fail under memory pressure
	 * so we fall-back to the minimum order allocation.
	 */
	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;

	page = alloc_slab_page(alloc_gfp, node, oo);
	if (unlikely(!page)) {
		oo = s->min;
		/*
		 * Allocation may have failed due to fragmentation.
		 * Try a lower order alloc if possible
		 */
		page = alloc_slab_page(flags, node, oo);

		if (page)
			stat(s, ORDER_FALLBACK);
	}


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
