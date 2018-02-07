Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C47496B0335
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 11:34:20 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b4so511152pgs.5
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 08:34:20 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q11si1135605pgc.165.2018.02.07.08.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 08:34:19 -0800 (PST)
Date: Wed, 7 Feb 2018 11:34:16 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Message-ID: <20180207113416.33b6247b@gandalf.local.home>
In-Reply-To: <20180207161846.GA902@bombadil.infradead.org>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
	<20180207021703.GC3617@linux.vnet.ibm.com>
	<20180207042334.GA16175@bombadil.infradead.org>
	<20180207050200.GH3617@linux.vnet.ibm.com>
	<db9bda80-7506-ae25-2c0a-45eaa08963d9@virtuozzo.com>
	<20180207083104.GK3617@linux.vnet.ibm.com>
	<20180207085700.393f90d0@gandalf.local.home>
	<20180207161846.GA902@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Wed, 7 Feb 2018 08:18:46 -0800
Matthew Wilcox <willy@infradead.org> wrote:

> Do we need to be able to free any of those objects in order to rename
> kfree_rcu() to just free_rcu()?

I'm just nervous about tightly coupling free_rcu() with all the *free()
from the memory management system. I've been burnt in the past by doing
such things.

What's the down side of having a way of matching *free_rcu() with all
the *free()s? I think it's easier to understand, and rcu doesn't need
to worry about changes of *free() code.

To me:

	kfree_rcu(x);

is just a quick way of doing 'kfree(x)' after a synchronize_rcu() call.

But a "free_rcu(x)", is something I have to think about, because I
don't know from the name exactly what it is doing.

I know this may sound a bit bike shedding, but the less I need to think
about how other sub systems work, the easier it is to concentrate on my
own sub system.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
