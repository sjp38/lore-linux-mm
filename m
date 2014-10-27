Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 601E56B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 09:53:52 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id tp5so4320619ieb.22
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 06:53:52 -0700 (PDT)
Received: from resqmta-po-10v.sys.comcast.net (resqmta-po-10v.sys.comcast.net. [2001:558:fe16:19:96:114:154:169])
        by mx.google.com with ESMTPS id ku4si12339055igb.60.2014.10.27.06.53.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 06:53:50 -0700 (PDT)
Date: Mon, 27 Oct 2014 08:53:48 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/4] [RFC] slub: Fastpath optimization (especially for
 RT)
In-Reply-To: <20141027075830.GF23379@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1410270850160.14245@gentwo.org>
References: <20141022155517.560385718@linux.com> <20141023080942.GA7598@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1410230916090.19494@gentwo.org> <20141024045630.GD15243@js1304-P5Q-DELUXE> <alpine.DEB.2.11.1410240938460.29214@gentwo.org>
 <20141027075830.GF23379@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Mon, 27 Oct 2014, Joonsoo Kim wrote:

> > One other aspect of this patchset is that it reduces the cache footprint
> > of the alloc and free functions. This typically results in a performance
> > increase for the allocator. If we can avoid the page_address() and
> > virt_to_head_page() stuff that is required because we drop the ->page
> > field in a sufficient number of places then this may be a benefit that
> > goes beyond the RT and CONFIG_PREEMPT case.
>
> Yeah... if we can avoid those function calls, it would be good.

One trick that may be possible is to have an address mask for the
page_address. If a pointer satisfies the mask requuirements then its on
the right page and we do not need to do virt_to_head_page.

> But, current struct kmem_cache_cpu occupies just 32 bytes on 64 bits
> machine, and, that means just 1 cacheline. Reducing size of struct may have
> no remarkable performance benefit in this case.

Hmmm... If we also drop the partial field then a 64 byte cacheline would
fit kmem_cache_cpu structs from 4 caches. If we place them correctly then
the frequently used caches could avoid fetching up to 3 cachelines.

You are right just dropping ->page wont do anything since the
kmem_cache_cpu struct is aligned to a double word boundary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
