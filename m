Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A52526B0006
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 23:09:05 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id d15so2795139qtg.2
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 20:09:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 28si1906883qtq.280.2018.02.07.20.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 20:09:04 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w18440Du103537
	for <linux-mm@kvack.org>; Wed, 7 Feb 2018 23:09:04 -0500
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2g0ab69uw5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Feb 2018 23:09:04 -0500
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 7 Feb 2018 23:09:03 -0500
Date: Wed, 7 Feb 2018 20:09:10 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Reply-To: paulmck@linux.vnet.ibm.com
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
Message-Id: <20180208040910.GP3617@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Matthew Wilcox <willy@infradead.org>, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

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

I couldn't agree more!

To that end, what are your thoughts on this patch?

https://lkml.kernel.org/r/1513895570-28640-1-git-send-email-rao.shoaib@oracle.com

Advantages include the ability to optimize based on sl[aou]b state,
getting rid of the 4K offset hack in __is_kfree_rcu_offset(), better
cache localite, and, as you say, putting the naming responsibility
in the memory-management domain.

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

And that is one reason I am viewing the name-change patch with great
suspicion, especially given that there seems to be some controversy
among the memory-management folks as to exactly what the names should be.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
