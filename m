Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 704EB6B0337
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 11:45:24 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id w74so1395926qka.21
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 08:45:24 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 23si1953563qtr.35.2018.02.07.08.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 08:45:23 -0800 (PST)
Date: Wed, 7 Feb 2018 17:45:13 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Message-ID: <20180207174513.5cc9b503@redhat.com>
In-Reply-To: <20180207085700.393f90d0@gandalf.local.home>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
	<20180207021703.GC3617@linux.vnet.ibm.com>
	<20180207042334.GA16175@bombadil.infradead.org>
	<20180207050200.GH3617@linux.vnet.ibm.com>
	<db9bda80-7506-ae25-2c0a-45eaa08963d9@virtuozzo.com>
	<20180207083104.GK3617@linux.vnet.ibm.com>
	<20180207085700.393f90d0@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, Matthew Wilcox <willy@infradead.org>, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rao.shoaib@oracle.com, brouer@redhat.com

On Wed, 7 Feb 2018 08:57:00 -0500
Steven Rostedt <rostedt@goodmis.org> wrote:

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

For the record, I fully agree with Steve here. 

And being a performance "fanatic" I don't like to have the extra branch
(and compares) in the free code path... but it's a MM-decision (and
sometimes you should not listen to "fanatics" ;-))

void kvfree(const void *addr)
{
	if (is_vmalloc_addr(addr))
		vfree(addr);
	else
		kfree(addr);
}
EXPORT_SYMBOL(kvfree);

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer


static inline bool is_vmalloc_addr(const void *x)
{
#ifdef CONFIG_MMU
	unsigned long addr = (unsigned long)x;

	return addr >= VMALLOC_START && addr < VMALLOC_END;
#else
	return false;
#endif
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
