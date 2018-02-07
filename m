Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82A5E6B0356
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 13:11:09 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id r1so612065pgp.2
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 10:11:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v19-v6si1430899ply.494.2018.02.07.10.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Feb 2018 10:11:08 -0800 (PST)
Date: Wed, 7 Feb 2018 10:10:55 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Message-ID: <20180207181055.GB12446@bombadil.infradead.org>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
 <20180207021703.GC3617@linux.vnet.ibm.com>
 <20180207042334.GA16175@bombadil.infradead.org>
 <20180207050200.GH3617@linux.vnet.ibm.com>
 <db9bda80-7506-ae25-2c0a-45eaa08963d9@virtuozzo.com>
 <20180207083104.GK3617@linux.vnet.ibm.com>
 <20180207085700.393f90d0@gandalf.local.home>
 <20180207174513.5cc9b503@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207174513.5cc9b503@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rao.shoaib@oracle.com

On Wed, Feb 07, 2018 at 05:45:13PM +0100, Jesper Dangaard Brouer wrote:
> On Wed, 7 Feb 2018 08:57:00 -0500
> Steven Rostedt <rostedt@goodmis.org> wrote:
> > To me kvfree() is a special case and should not be used by RCU as a
> > generic function. That would make RCU and MM much more coupled than
> > necessary.
> 
> For the record, I fully agree with Steve here. 
> 
> And being a performance "fanatic" I don't like to have the extra branch
> (and compares) in the free code path... but it's a MM-decision (and
> sometimes you should not listen to "fanatics" ;-))

While free_rcu() is not withut its performance requirements, I think it's
currently dominated by cache misses and not by branches.  By the time RCU
gets to run callbacks, memory is certainly L1/L2 cache-cold and probably
L3 cache-cold.  Also calling the callback functions is utterly impossible
for the branch predictor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
