Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2556A6B02DD
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 02:54:20 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id z83so370721wmc.5
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 23:54:20 -0800 (PST)
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [2001:4b98:c:538::195])
        by mx.google.com with ESMTPS id j136si855965wmd.184.2018.02.06.23.54.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 23:54:18 -0800 (PST)
Date: Tue, 6 Feb 2018 23:54:09 -0800
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Message-ID: <20180207075409.GA5726@localhost>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
 <20180207021703.GC3617@linux.vnet.ibm.com>
 <20180207042334.GA16175@bombadil.infradead.org>
 <20180207050200.GH3617@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207050200.GH3617@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Tue, Feb 06, 2018 at 09:02:00PM -0800, Paul E. McKenney wrote:
> On Tue, Feb 06, 2018 at 08:23:34PM -0800, Matthew Wilcox wrote:
> > On Tue, Feb 06, 2018 at 06:17:03PM -0800, Paul E. McKenney wrote:
> > > So it is OK to kvmalloc() something and pass it to either kfree() or
> > > kvfree(), and it had better be OK to kvmalloc() something and pass it
> > > to kvfree().
> > > 
> > > Is it OK to kmalloc() something and pass it to kvfree()?
> > 
> > Yes, it absolutely is.
> > 
> > void kvfree(const void *addr)
> > {
> >         if (is_vmalloc_addr(addr))
> >                 vfree(addr);
> >         else
> >                 kfree(addr);
> > }
> > 
> > > If so, is it really useful to have two different names here, that is,
> > > both kfree_rcu() and kvfree_rcu()?
> > 
> > I think it's handy to have all three of kvfree_rcu(), kfree_rcu() and
> > vfree_rcu() available in the API for the symmetry of calling kmalloc()
> > / kfree_rcu().
> > 
> > Personally, I would like us to rename kvfree() to just free(), and have
> > malloc(x) be an alias to kvmalloc(x, GFP_KERNEL), but I haven't won that
> > fight yet.
> 
> But why not just have the existing kfree_rcu() API cover both kmalloc()
> and kvmalloc()?  Perhaps I am not in the right forums, but I am not hearing
> anyone arguing that the RCU API has too few members.  ;-)

I don't have any problem with having just `kvfree_rcu`, but having just
`kfree_rcu` seems confusingly asymmetric.

(Also, count me in favor of having just one "free" function, too.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
