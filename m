Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4FE6B04DD
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 06:23:42 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e64so3541347wmi.0
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 03:23:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u53si61117wrc.538.2017.09.05.03.23.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Sep 2017 03:23:40 -0700 (PDT)
Date: Tue, 5 Sep 2017 12:23:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: possible circular locking dependency
 mmap_sem/cpu_hotplug_lock.rw_sem
Message-ID: <20170905102336.bqxb7tltnt3lphkq@dhcp22.suse.cz>
References: <20170807140947.nhfz2gel6wytl6ia@shodan.usersys.redhat.com>
 <alpine.DEB.2.20.1708161605050.1987@nanos>
 <20170830141543.qhipikpog6mkqe5b@dhcp22.suse.cz>
 <20170830154315.sa57wasw64rvnuhe@dhcp22.suse.cz>
 <20170904140353.k5mo3f4wela5nxqe@dhcp22.suse.cz>
 <alpine.DEB.2.20.1709051013380.1900@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1709051013380.1900@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Artem Savkov <asavkov@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 05-09-17 10:19:13, Thomas Gleixner wrote:
> On Mon, 4 Sep 2017, Michal Hocko wrote:
> 
> > Thomas, Johannes,
> > could you double check my thinking here? I will repost the patch to
> > Andrew if you are OK with this.
> > > +	/*
> > > +	 * The only protection from memory hotplug vs. drain_stock races is
> > > +	 * that we always operate on local CPU stock here with IRQ disabled
> > > +	 */
> > >  	local_irq_save(flags);
> > >  
> > >  	stock = this_cpu_ptr(&memcg_stock);
> > > @@ -1807,26 +1811,27 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
> > >  	if (!mutex_trylock(&percpu_charge_mutex))
> > >  		return;
> > >  	/* Notify other cpus that system-wide "drain" is running */
> > > -	get_online_cpus();
> > >  	curcpu = get_cpu();
> 
> The problem here is that this does only protect you against a CPU being
> unplugged, but not against a CPU coming online concurrently.

Yes but same as the drain_all_pages we do not have any cpu up specific
intialization so there is no specific action to race against AFAICS.

> I have no idea
> whether that might be a problem, but at least you should put a comment in
> which explains why it is not.

What about this?
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5c70f47abb3d..ff9b0979ccc3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1810,7 +1810,12 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
 	/* If someone's already draining, avoid adding running more workers. */
 	if (!mutex_trylock(&percpu_charge_mutex))
 		return;
-	/* Notify other cpus that system-wide "drain" is running */
+	/*
+	 * Notify other cpus that system-wide "drain" is running
+	 * We do not care about races with the cpu hotplug because cpu down
+	 * as well as workers from this path always operate on the local
+	 * per-cpu data. CPU up doesn't touch memcg_stock at all.
+	 */
 	curcpu = get_cpu();
 	for_each_online_cpu(cpu) {
 		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
