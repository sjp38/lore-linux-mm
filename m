Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB6246B02E4
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 03:20:25 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id c135so13332qkb.10
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 00:20:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f47si992074qtc.420.2018.02.07.00.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 00:20:25 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w178JsjS011520
	for <linux-mm@kvack.org>; Wed, 7 Feb 2018 03:20:24 -0500
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fypywesvp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Feb 2018 03:20:24 -0500
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 7 Feb 2018 03:20:23 -0500
Date: Wed, 7 Feb 2018 00:20:29 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Reply-To: paulmck@linux.vnet.ibm.com
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
 <20180207021703.GC3617@linux.vnet.ibm.com>
 <20180207042334.GA16175@bombadil.infradead.org>
 <20180207050200.GH3617@linux.vnet.ibm.com>
 <20180207075409.GA5726@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207075409.GA5726@localhost>
Message-Id: <20180207082029.GJ3617@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Matthew Wilcox <willy@infradead.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Tue, Feb 06, 2018 at 11:54:09PM -0800, Josh Triplett wrote:
> On Tue, Feb 06, 2018 at 09:02:00PM -0800, Paul E. McKenney wrote:
> > On Tue, Feb 06, 2018 at 08:23:34PM -0800, Matthew Wilcox wrote:
> > > On Tue, Feb 06, 2018 at 06:17:03PM -0800, Paul E. McKenney wrote:
> > > > So it is OK to kvmalloc() something and pass it to either kfree() or
> > > > kvfree(), and it had better be OK to kvmalloc() something and pass it
> > > > to kvfree().
> > > > 
> > > > Is it OK to kmalloc() something and pass it to kvfree()?
> > > 
> > > Yes, it absolutely is.
> > > 
> > > void kvfree(const void *addr)
> > > {
> > >         if (is_vmalloc_addr(addr))
> > >                 vfree(addr);
> > >         else
> > >                 kfree(addr);
> > > }
> > > 
> > > > If so, is it really useful to have two different names here, that is,
> > > > both kfree_rcu() and kvfree_rcu()?
> > > 
> > > I think it's handy to have all three of kvfree_rcu(), kfree_rcu() and
> > > vfree_rcu() available in the API for the symmetry of calling kmalloc()
> > > / kfree_rcu().
> > > 
> > > Personally, I would like us to rename kvfree() to just free(), and have
> > > malloc(x) be an alias to kvmalloc(x, GFP_KERNEL), but I haven't won that
> > > fight yet.
> > 
> > But why not just have the existing kfree_rcu() API cover both kmalloc()
> > and kvmalloc()?  Perhaps I am not in the right forums, but I am not hearing
> > anyone arguing that the RCU API has too few members.  ;-)
> 
> I don't have any problem with having just `kvfree_rcu`, but having just
> `kfree_rcu` seems confusingly asymmetric.

I don't understand why kmalloc()/kvfree_rcu() would seem any less
asymmetric than kvmalloc()/kfree_rcu().

> (Also, count me in favor of having just one "free" function, too.)

We agree on that much, anyway.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
