Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 786676B02C2
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 23:23:49 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b6so2511811pgu.16
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 20:23:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w8-v6si470203plk.597.2018.02.06.20.23.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Feb 2018 20:23:48 -0800 (PST)
Date: Tue, 6 Feb 2018 20:23:34 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Message-ID: <20180207042334.GA16175@bombadil.infradead.org>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
 <20180207021703.GC3617@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207021703.GC3617@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Tue, Feb 06, 2018 at 06:17:03PM -0800, Paul E. McKenney wrote:
> So it is OK to kvmalloc() something and pass it to either kfree() or
> kvfree(), and it had better be OK to kvmalloc() something and pass it
> to kvfree().
> 
> Is it OK to kmalloc() something and pass it to kvfree()?

Yes, it absolutely is.

void kvfree(const void *addr)
{
        if (is_vmalloc_addr(addr))
                vfree(addr);
        else
                kfree(addr);
}

> If so, is it really useful to have two different names here, that is,
> both kfree_rcu() and kvfree_rcu()?

I think it's handy to have all three of kvfree_rcu(), kfree_rcu() and
vfree_rcu() available in the API for the symmetry of calling kmalloc()
/ kfree_rcu().

Personally, I would like us to rename kvfree() to just free(), and have
malloc(x) be an alias to kvmalloc(x, GFP_KERNEL), but I haven't won that
fight yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
