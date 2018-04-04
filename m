Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 59FF26B0009
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 13:05:37 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p18so5598676wmh.2
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 10:05:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r11si109376edb.99.2018.04.04.10.05.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Apr 2018 10:05:35 -0700 (PDT)
Date: Wed, 4 Apr 2018 13:07:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC] mm: memory.low heirarchical behavior
Message-ID: <20180404170700.GA2161@cmpxchg.org>
References: <20180320223353.5673-1-guro@fb.com>
 <20180321182308.GA28232@cmpxchg.org>
 <20180321190801.GA22452@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180321190801.GA22452@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Mar 21, 2018 at 07:08:06PM +0000, Roman Gushchin wrote:
> > On Tue, Mar 20, 2018 at 10:33:53PM +0000, Roman Gushchin wrote:
> > > This patch aims to address an issue in current memory.low semantics,
> > > which makes it hard to use it in a hierarchy, where some leaf memory
> > > cgroups are more valuable than others.
> > > 
> > > For example, there are memcgs A, A/B, A/C, A/D and A/E:
> > > 
> > >   A      A/memory.low = 2G, A/memory.current = 6G
> > >  //\\
> > > BC  DE   B/memory.low = 3G  B/memory.usage = 2G
> > >          C/memory.low = 1G  C/memory.usage = 2G
> > >          D/memory.low = 0   D/memory.usage = 2G
> > > 	 E/memory.low = 10G E/memory.usage = 0
> > > 
> > > If we apply memory pressure, B, C and D are reclaimed at
> > > the same pace while A's usage exceeds 2G.
> > > This is obviously wrong, as B's usage is fully below B's memory.low,
> > > and C has 1G of protection as well.
> > > Also, A is pushed to the size, which is less than A's 2G memory.low,
> > > which is also wrong.
> > > 
> > > A simple bash script (provided below) can be used to reproduce
> > > the problem. Current results are:
> > >   A:    1430097920
> > >   A/B:  711929856
> > >   A/C:  717426688
> > >   A/D:  741376
> > >   A/E:  0
> > 
> > Yes, this is a problem. And the behavior with your patch looks much
> > preferable over the status quo.
> > 
> > > To address the issue a concept of effective memory.low is introduced.
> > > Effective memory.low is always equal or less than original memory.low.
> > > In a case, when there is no memory.low overcommittment (and also for
> > > top-level cgroups), these two values are equal.
> > > Otherwise it's a part of parent's effective memory.low, calculated as
> > > a cgroup's memory.low usage divided by sum of sibling's memory.low
> > > usages (under memory.low usage I mean the size of actually protected
> > > memory: memory.current if memory.current < memory.low, 0 otherwise).
> > 
> > This hurts my brain.
> > 
> > Why is memory.current == memory.low (which should fully protect
> > memory.current) a low usage of 0?
> > 
> > Why is memory.current > memory.low not a low usage of memory.low?
> > 
> > I.e. shouldn't this be low_usage = min(memory.current, memory.low)?
> 
> This is really the non-trivial part.
> 
> Let's look at an example:
> memcg A   (memory.current = 4G, memory.low = 2G)
> memcg A/B (memory.current = 2G, memory.low = 2G)
> memcg A/C (memory.current = 2G, memory.low = 1G)
> 
> If we'll calculate effective memory.low using your definition
> before any reclaim, we end up with the following:
> A/B  2G * 2G / (2G + 1G) = 4/3G
> A/C  2G * 1G / (2G + 1G) = 2/3G
> 
> Looks good, but both cgroups are below their effective limits.
> When memory pressure is applied, both are reclaimed at the same pace.
> While both B and C are getting smaller and smaller, their weights
> and effective low limits are getting closer and closer, but
> still below their usages. This ends up when both cgroups will
> have size of 1G, which is obviously wrong.
> 
> Fundamentally the problem is that memory.low doesn't define
> the reclaim speed, just yes or no. So, if there are children cgroups,
> some of which are below their memory.low, and some above (as in the example),
> it's crucially important to reclaim unprotected memory first.
> 
> This is exactly what my code does: as soon as memory.current is larger
> than memory.low, we don't treat cgroup's memory as protected at all,
> so it doesn't affect effective limits of sibling cgroups.

Okay, that explanation makes sense to me. Once you're in excess, your
memory is generally unprotected wrt your siblings until you're reigned
in again.

It should still be usage <= low rather than usage < low, right? Since
you're protected up to and including what that number says.

> > > @@ -1726,6 +1756,7 @@ static void drain_stock(struct memcg_stock_pcp *stock)
> > >  		page_counter_uncharge(&old->memory, stock->nr_pages);
> > >  		if (do_memsw_account())
> > >  			page_counter_uncharge(&old->memsw, stock->nr_pages);
> > > +		memcg_update_low(old);
> > >  		css_put_many(&old->css, stock->nr_pages);
> > >  		stock->nr_pages = 0;
> > 
> > The function is called every time the page counter changes and walks
> > up the hierarchy exactly the same. That is a good sign that the low
> > usage tracking should really be part of the page counter code itself.
> 
> I thought about it, but the problem is that page counters are used for
> accounting swap, kmem, tcpmem (for v1), where low limit calculations are
> not applicable. I've no idea, how to add them nicely and without excessive
> overhead.
> Also, good news are that it's possible to avoid any tracking until
> a user actually overcommits memory.low guarantees. I plan to implement
> this optimization in a separate patch.

Hm, I'm not too worried about swap (not a sensitive path) or the other
users (per-cpu batched). It just adds a branch. How about the below?

diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
index c15ab80ad32d..95bdbca86751 100644
--- a/include/linux/page_counter.h
+++ b/include/linux/page_counter.h
@@ -9,8 +9,13 @@
 struct page_counter {
 	atomic_long_t count;
 	unsigned long limit;
+	unsigned long protected;
 	struct page_counter *parent;
 
+	/* Hierarchical, proportional protection */
+	atomic_long_t protected_count;
+	atomic_long_t children_protected_count;
+
 	/* legacy */
 	unsigned long watermark;
 	unsigned long failcnt;
@@ -42,6 +47,7 @@ bool page_counter_try_charge(struct page_counter *counter,
 			     struct page_counter **fail);
 void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
 int page_counter_limit(struct page_counter *counter, unsigned long limit);
+void page_counter_protect(struct page_counter *counter, unsigned long protected);
 int page_counter_memparse(const char *buf, const char *max,
 			  unsigned long *nr_pages);
 
diff --git a/mm/page_counter.c b/mm/page_counter.c
index 2a8df3ad60a4..e6f7665d13e3 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -13,6 +13,29 @@
 #include <linux/bug.h>
 #include <asm/page.h>
 
+static void propagate_protected(struct page_counter *c, unsigned long count)
+{
+	unsigned long protected_count;
+	unsigned long delta;
+	unsigned long old;
+
+	if (!c->parent)
+		return;
+
+	if (!c->protected && !atomic_long_read(&c->protected_count))
+		return;
+
+	if (count <= c->protected)
+		protected_count = count;
+	else
+		protected_count = 0;
+
+	old = atomic_long_xchg(&c->protected_count, protected_count);
+	delta = protected_count - old;
+	if (delta)
+		atomic_long_add(delta, &c->parent->children_protected_count);
+}
+
 /**
  * page_counter_cancel - take pages out of the local counter
  * @counter: counter
@@ -23,6 +46,7 @@ void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
 	long new;
 
 	new = atomic_long_sub_return(nr_pages, &counter->count);
+	propagate_protected(counter, new);
 	/* More uncharges than charges? */
 	WARN_ON_ONCE(new < 0);
 }
@@ -42,6 +66,7 @@ void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
 		long new;
 
 		new = atomic_long_add_return(nr_pages, &c->count);
+		propagate_protected(c, new);
 		/*
 		 * This is indeed racy, but we can live with some
 		 * inaccuracy in the watermark.
@@ -93,6 +118,7 @@ bool page_counter_try_charge(struct page_counter *counter,
 			*fail = c;
 			goto failed;
 		}
+		propagate_protected(c, new);
 		/*
 		 * Just like with failcnt, we can live with some
 		 * inaccuracy in the watermark.
@@ -164,6 +190,12 @@ int page_counter_limit(struct page_counter *counter, unsigned long limit)
 	}
 }
 
+void page_counter_protect(struct page_counter *counter, unsigned long protected)
+{
+	c->protected = protected;
+	propagate_protected(counter, atomic_long_read(&counter->count));
+}
+
 /**
  * page_counter_memparse - memparse() for page counter limits
  * @buf: string to parse
