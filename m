Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 98F336B0003
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:55:17 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id d26so5337235qtm.14
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 15:55:17 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d26si1191171qtf.17.2018.02.22.15.55.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 15:55:16 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1MNrbHv086223
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:55:15 -0500
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ga31wajnc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:55:14 -0500
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 22 Feb 2018 18:55:13 -0500
Date: Thu, 22 Feb 2018 15:55:32 -0800
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
 <20180207174513.5cc9b503@redhat.com>
 <20180207181055.GB12446@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207181055.GB12446@bombadil.infradead.org>
Message-Id: <20180222235532.GA11181@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, josh@joshtriplett.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rao.shoaib@oracle.com

On Wed, Feb 07, 2018 at 10:10:55AM -0800, Matthew Wilcox wrote:
> On Wed, Feb 07, 2018 at 05:45:13PM +0100, Jesper Dangaard Brouer wrote:
> > On Wed, 7 Feb 2018 08:57:00 -0500
> > Steven Rostedt <rostedt@goodmis.org> wrote:
> > > To me kvfree() is a special case and should not be used by RCU as a
> > > generic function. That would make RCU and MM much more coupled than
> > > necessary.
> > 
> > For the record, I fully agree with Steve here. 
> > 
> > And being a performance "fanatic" I don't like to have the extra branch
> > (and compares) in the free code path... but it's a MM-decision (and
> > sometimes you should not listen to "fanatics" ;-))
> 
> While free_rcu() is not withut its performance requirements, I think it's
> currently dominated by cache misses and not by branches.  By the time RCU
> gets to run callbacks, memory is certainly L1/L2 cache-cold and probably
> L3 cache-cold.  Also calling the callback functions is utterly impossible
> for the branch predictor.

This seems to have fallen by the wayside.

To get things going again, I suggest starting out by simply replacing
the kfree() in __rcu_reclaim() with kvfree().  If desired, a kvfree_rcu()
can also be defined as a synonym for kfree_rcu().

This gets us a very simple and small patch which provides the ability
to dispose of kvmalloc() memory after a grace period.

								Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
