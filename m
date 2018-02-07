Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 09D716B032F
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 11:19:01 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id m65so620073pfm.14
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 08:19:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u13si1108589pgr.530.2018.02.07.08.18.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Feb 2018 08:18:59 -0800 (PST)
Date: Wed, 7 Feb 2018 08:18:46 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Message-ID: <20180207161846.GA902@bombadil.infradead.org>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
 <20180207021703.GC3617@linux.vnet.ibm.com>
 <20180207042334.GA16175@bombadil.infradead.org>
 <20180207050200.GH3617@linux.vnet.ibm.com>
 <db9bda80-7506-ae25-2c0a-45eaa08963d9@virtuozzo.com>
 <20180207083104.GK3617@linux.vnet.ibm.com>
 <20180207085700.393f90d0@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207085700.393f90d0@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Wed, Feb 07, 2018 at 08:57:00AM -0500, Steven Rostedt wrote:
> On Wed, 7 Feb 2018 00:31:04 -0800
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > I see problems.  We would then have two different names for exactly the
> > same thing.
> > 
> > Seems like it would be a lot easier to simply document the existing
> > kfree_rcu() behavior, especially given that it apparently already works.
> > The really doesn't seem to me to be worth a name change.
> 
> Honestly, I don't believe this is an RCU sub-system decision. This is a
> memory management decision.
> 
> If we have kmalloc(), vmalloc(), kfree(), vfree() and kvfree(), and we

You missed kvmalloc() ...

> want kmalloc() to be freed with kfree(), and vmalloc() to be freed with
> vfree(), and for strange reasons, we don't know how the data was
> allocated we have kvfree(). That's an mm decision not an rcu one. We
> should have kfree_rcu(), vfree_rcu() and kvfree_rcu(), and honestly,
> they should not depend on kvfree() doing the same thing for everything.
> Each should call the corresponding member that they represent. Which
> would change this patch set.
> 
> Why? Too much coupling between RCU and MM. What if in the future
> something changes and kvfree() goes away or changes drastically. We
> would then have to go through all the users of RCU to change them too.
> 
> To me kvfree() is a special case and should not be used by RCU as a
> generic function. That would make RCU and MM much more coupled than
> necessary.

I'd still like it to be called free_rcu() ... so let's turn it around.

What memory can you allocate and then *not* free by calling kvfree()?
kvfree() can free memory allocated by kmalloc(), vmalloc(), any slab
allocation (is that guaranteed, or just something that happens to work?)
I think it can't free per-cpu allocations, bootmem, DMA allocations, or
alloc_page/get_free_page.

Do we need to be able to free any of those objects in order to rename
kfree_rcu() to just free_rcu()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
