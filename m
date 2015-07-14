Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id BCE826B027F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 18:45:43 -0400 (EDT)
Received: by ietj16 with SMTP id j16so21781846iet.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 15:45:43 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id m184si2018670ioe.10.2015.07.14.15.45.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 15:45:42 -0700 (PDT)
Received: by igbpg9 with SMTP id pg9so23450988igb.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 15:45:42 -0700 (PDT)
Date: Tue, 14 Jul 2015 15:45:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/7] mm: introduce kvmalloc and kvmalloc_node
In-Reply-To: <20150714215413.GP3902@dastard>
Message-ID: <alpine.DEB.2.10.1507141536590.16182@chino.kir.corp.google.com>
References: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1507071109490.23387@file01.intranet.prod.int.rdu2.redhat.com> <20150707144117.5b38ac38efda238af8a1f536@linux-foundation.org>
 <alpine.LRH.2.02.1507081855340.32526@file01.intranet.prod.int.rdu2.redhat.com> <20150708161815.bdff609d77868dbdc2e1ce64@linux-foundation.org> <alpine.LRH.2.02.1507091039440.30842@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1507141401170.16182@chino.kir.corp.google.com>
 <20150714211918.GC7915@redhat.com> <alpine.DEB.2.10.1507141420350.16182@chino.kir.corp.google.com> <20150714215413.GP3902@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Edward Thornber <thornber@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Alasdair G. Kergon" <agk@redhat.com>

On Wed, 15 Jul 2015, Dave Chinner wrote:

> > Sure, but it's not accomplishing the same thing: things like 
> > ext4_kvmalloc() only want to fallback to vmalloc() when high-order 
> > allocations fail: the function is used for different sizes.  This cannot 
> > be converted to kvmalloc_node() since it fallsback immediately when 
> > reclaim fails.  Same issue with single_file_open() for the seq_file code.  
> > We could go through every kmalloc() -> vmalloc() fallback for more 
> > examples in the code, but those two instances were the first I looked at 
> > and couldn't be converted to kvmalloc_node() without work.
> > 
> > > It is always easier to shoehorn utility functions locally within a
> > > subsystem (be it ext4, dm, etc) but once enough do something in a
> > > similar but different way it really should get elevated.
> > > 
> > 
> > I would argue that
> > 
> > void *ext4_kvmalloc(size_t size, gfp_t flags)
> > {
> > 	void *ret;
> > 
> > 	ret = kmalloc(size, flags | __GFP_NOWARN);
> > 	if (!ret)
> > 		ret = __vmalloc(size, flags, PAGE_KERNEL);
> > 	return ret;
> > }
> > 
> > is simple enough that we don't need to convert it to anything.
> 
> Except that it will have problems with GFP_NOFS context when the pte
> code inside vmalloc does a GFP_KERNEL allocation. Hence we have
> stuff in other subsystems (such as XFS) where we've noticed lockdep
> whining about this:
> 

Does anyone have an example of ext4_kvmalloc() having a lockdep violation?  
Presumably the GFP_NOFS calls to ext4_kvmalloc() will never have 
size > (1 << (PAGE_SHIFT + PAGE_ALLOC_COSTLY_ORDER)) so that kmalloc() 
above actually never returns NULL and __vmalloc() only gets used for the 
ext4_kvmalloc(..., GFP_KERNEL) call.

It should be fixed, though, probably in the same way as 
kmem_zalloc_large() today, but it seems the real fix would be to attack 
the whole vmalloc() GFP_KERNEL issue that has been talked about several 
times in the past.  Then the existing ext4_kvmalloc() implementation 
should be fine.

Once that's done, we can revisit the idea of a generalized kvmalloc() or 
kvmalloc_node(), but since the implementation such as above is different 
from the proposed kvmalloc_node() implementation with respect to 
high-order allocations, I doubt a generalized form will be helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
