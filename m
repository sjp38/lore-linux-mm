Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 21242280267
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 20:25:57 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so14188665pdj.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 17:25:56 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id gp1si4305244pbd.238.2015.07.14.17.25.54
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 17:25:56 -0700 (PDT)
Date: Wed, 15 Jul 2015 10:25:40 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/7] mm: introduce kvmalloc and kvmalloc_node
Message-ID: <20150715002540.GR3902@dastard>
References: <alpine.LRH.2.02.1507071109490.23387@file01.intranet.prod.int.rdu2.redhat.com>
 <20150707144117.5b38ac38efda238af8a1f536@linux-foundation.org>
 <alpine.LRH.2.02.1507081855340.32526@file01.intranet.prod.int.rdu2.redhat.com>
 <20150708161815.bdff609d77868dbdc2e1ce64@linux-foundation.org>
 <alpine.LRH.2.02.1507091039440.30842@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.10.1507141401170.16182@chino.kir.corp.google.com>
 <20150714211918.GC7915@redhat.com>
 <alpine.DEB.2.10.1507141420350.16182@chino.kir.corp.google.com>
 <20150714215413.GP3902@dastard>
 <alpine.DEB.2.10.1507141536590.16182@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507141536590.16182@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Edward Thornber <thornber@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, Vivek Goyal <vgoyal@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Alasdair G. Kergon" <agk@redhat.com>

On Tue, Jul 14, 2015 at 03:45:40PM -0700, David Rientjes wrote:
> On Wed, 15 Jul 2015, Dave Chinner wrote:
> 
> > > Sure, but it's not accomplishing the same thing: things like 
> > > ext4_kvmalloc() only want to fallback to vmalloc() when high-order 
> > > allocations fail: the function is used for different sizes.  This cannot 
> > > be converted to kvmalloc_node() since it fallsback immediately when 
> > > reclaim fails.  Same issue with single_file_open() for the seq_file code.  
> > > We could go through every kmalloc() -> vmalloc() fallback for more 
> > > examples in the code, but those two instances were the first I looked at 
> > > and couldn't be converted to kvmalloc_node() without work.
> > > 
> > > > It is always easier to shoehorn utility functions locally within a
> > > > subsystem (be it ext4, dm, etc) but once enough do something in a
> > > > similar but different way it really should get elevated.
> > > > 
> > > 
> > > I would argue that
> > > 
> > > void *ext4_kvmalloc(size_t size, gfp_t flags)
> > > {
> > > 	void *ret;
> > > 
> > > 	ret = kmalloc(size, flags | __GFP_NOWARN);
> > > 	if (!ret)
> > > 		ret = __vmalloc(size, flags, PAGE_KERNEL);
> > > 	return ret;
> > > }
> > > 
> > > is simple enough that we don't need to convert it to anything.
> > 
> > Except that it will have problems with GFP_NOFS context when the pte
> > code inside vmalloc does a GFP_KERNEL allocation. Hence we have
> > stuff in other subsystems (such as XFS) where we've noticed lockdep
> > whining about this:
> > 
> 
> Does anyone have an example of ext4_kvmalloc() having a lockdep violation?  
> Presumably the GFP_NOFS calls to ext4_kvmalloc() will never have 
> size > (1 << (PAGE_SHIFT + PAGE_ALLOC_COSTLY_ORDER)) so that kmalloc() 
> above actually never returns NULL and __vmalloc() only gets used for the 
> ext4_kvmalloc(..., GFP_KERNEL) call.

Code inspection is all that is necessary. For example,
fs/ext4/resize.c::add_new_gdb() does:

 818         n_group_desc = ext4_kvmalloc((gdb_num + 1) *
 819                                      sizeof(struct buffer_head *),
 820                                      GFP_NOFS);

I have to assume this was done because resize was failing kmalloc()
calls on large filesystems in GFP_NOFS context as the commit message
is less than helpful:

commit f18a5f21c25707b4fe64b326e2b4d150565e7300
Author: Theodore Ts'o <tytso@mit.edu>
Date:   Mon Aug 1 08:45:38 2011 -0400

    ext4: use ext4_kvzalloc()/ext4_kvmalloc() for s_group_desc and s_group_info

    Signed-off-by: "Theodore Ts'o" <tytso@mit.edu>


> It should be fixed, though, probably in the same way as 
> kmem_zalloc_large() today, but it seems the real fix would be to attack 
> the whole vmalloc() GFP_KERNEL issue that has been talked about several 
> times in the past.  Then the existing ext4_kvmalloc() implementation 
> should be fine.

Agreed, we really need to ensure that the generic kernel allocation
functions follow the context guidelines they are provided by
callers. I'm not going to hold my breathe waiting for this to
happen, though....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
