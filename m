Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB7C6B0313
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 08:57:05 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e1so443582pfi.10
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 05:57:05 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v10si978455pgf.214.2018.02.07.05.57.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 05:57:03 -0800 (PST)
Date: Wed, 7 Feb 2018 08:57:00 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Message-ID: <20180207085700.393f90d0@gandalf.local.home>
In-Reply-To: <20180207083104.GK3617@linux.vnet.ibm.com>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
	<20180207021703.GC3617@linux.vnet.ibm.com>
	<20180207042334.GA16175@bombadil.infradead.org>
	<20180207050200.GH3617@linux.vnet.ibm.com>
	<db9bda80-7506-ae25-2c0a-45eaa08963d9@virtuozzo.com>
	<20180207083104.GK3617@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Matthew Wilcox <willy@infradead.org>, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Wed, 7 Feb 2018 00:31:04 -0800
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> I see problems.  We would then have two different names for exactly the
> same thing.
> 
> Seems like it would be a lot easier to simply document the existing
> kfree_rcu() behavior, especially given that it apparently already works.
> The really doesn't seem to me to be worth a name change.

Honestly, I don't believe this is an RCU sub-system decision. This is a
memory management decision.

If we have kmalloc(), vmalloc(), kfree(), vfree() and kvfree(), and we
want kmalloc() to be freed with kfree(), and vmalloc() to be freed with
vfree(), and for strange reasons, we don't know how the data was
allocated we have kvfree(). That's an mm decision not an rcu one. We
should have kfree_rcu(), vfree_rcu() and kvfree_rcu(), and honestly,
they should not depend on kvfree() doing the same thing for everything.
Each should call the corresponding member that they represent. Which
would change this patch set.

Why? Too much coupling between RCU and MM. What if in the future
something changes and kvfree() goes away or changes drastically. We
would then have to go through all the users of RCU to change them too.

To me kvfree() is a special case and should not be used by RCU as a
generic function. That would make RCU and MM much more coupled than
necessary.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
