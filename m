Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C02F6B02E6
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 03:31:02 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id z13so35810qth.22
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 00:31:02 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y127si965358qkd.306.2018.02.07.00.31.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 00:31:01 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w178UYVe089935
	for <linux-mm@kvack.org>; Wed, 7 Feb 2018 03:31:00 -0500
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fyws9rsgx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Feb 2018 03:31:00 -0500
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 7 Feb 2018 03:30:58 -0500
Date: Wed, 7 Feb 2018 00:31:04 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Reply-To: paulmck@linux.vnet.ibm.com
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
 <20180207021703.GC3617@linux.vnet.ibm.com>
 <20180207042334.GA16175@bombadil.infradead.org>
 <20180207050200.GH3617@linux.vnet.ibm.com>
 <db9bda80-7506-ae25-2c0a-45eaa08963d9@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <db9bda80-7506-ae25-2c0a-45eaa08963d9@virtuozzo.com>
Message-Id: <20180207083104.GK3617@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Matthew Wilcox <willy@infradead.org>, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Wed, Feb 07, 2018 at 10:57:28AM +0300, Kirill Tkhai wrote:
> On 07.02.2018 08:02, Paul E. McKenney wrote:
> > On Tue, Feb 06, 2018 at 08:23:34PM -0800, Matthew Wilcox wrote:
> >> On Tue, Feb 06, 2018 at 06:17:03PM -0800, Paul E. McKenney wrote:
> >>> So it is OK to kvmalloc() something and pass it to either kfree() or
> >>> kvfree(), and it had better be OK to kvmalloc() something and pass it
> >>> to kvfree().
> >>>
> >>> Is it OK to kmalloc() something and pass it to kvfree()?
> >>
> >> Yes, it absolutely is.
> >>
> >> void kvfree(const void *addr)
> >> {
> >>         if (is_vmalloc_addr(addr))
> >>                 vfree(addr);
> >>         else
> >>                 kfree(addr);
> >> }
> >>
> >>> If so, is it really useful to have two different names here, that is,
> >>> both kfree_rcu() and kvfree_rcu()?
> >>
> >> I think it's handy to have all three of kvfree_rcu(), kfree_rcu() and
> >> vfree_rcu() available in the API for the symmetry of calling kmalloc()
> >> / kfree_rcu().
> >>
> >> Personally, I would like us to rename kvfree() to just free(), and have
> >> malloc(x) be an alias to kvmalloc(x, GFP_KERNEL), but I haven't won that
> >> fight yet.
> > 
> > But why not just have the existing kfree_rcu() API cover both kmalloc()
> > and kvmalloc()?  Perhaps I am not in the right forums, but I am not hearing
> > anyone arguing that the RCU API has too few members.  ;-)
> 
> People, far from RCU internals, consider kfree_rcu() like an extension
> of kfree(). And it's not clear it's need to dive into kfree_rcu() comments,
> when someone is looking a primitive to free vmalloc'ed memory.

Seems like a relatively simple lesson to teach.

> Also, construction like
> 
> obj = kvmalloc();
> kfree_rcu(obj);
> 
> makes me think it's legitimately to use plain kfree() as pair bracket to kvmalloc().

So it all works as is, then.

> So the significant change of kfree_rcu() behavior will complicate stable backporters
> life, because they will need to keep in mind such differences between different
> kernel versions.

If I understood your construction above, that significant change in
kfree_rcu() behavior has already happened.

> It seems if we are going to use the single primitive for both kmalloc()
> and kvmalloc() memory, it has to have another name. But I don't see problems
> with having both kfree_rcu() and kvfree_rcu().

I see problems.  We would then have two different names for exactly the
same thing.

Seems like it would be a lot easier to simply document the existing
kfree_rcu() behavior, especially given that it apparently already works.
The really doesn't seem to me to be worth a name change.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
