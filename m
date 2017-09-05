Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA2EA280300
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 04:19:24 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 40so3808250wrv.4
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 01:19:24 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a18si137584wrd.327.2017.09.05.01.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 05 Sep 2017 01:19:23 -0700 (PDT)
Date: Tue, 5 Sep 2017 10:19:13 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: possible circular locking dependency
 mmap_sem/cpu_hotplug_lock.rw_sem
In-Reply-To: <20170904140353.k5mo3f4wela5nxqe@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1709051013380.1900@nanos>
References: <20170807140947.nhfz2gel6wytl6ia@shodan.usersys.redhat.com> <alpine.DEB.2.20.1708161605050.1987@nanos> <20170830141543.qhipikpog6mkqe5b@dhcp22.suse.cz> <20170830154315.sa57wasw64rvnuhe@dhcp22.suse.cz>
 <20170904140353.k5mo3f4wela5nxqe@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Artem Savkov <asavkov@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, 4 Sep 2017, Michal Hocko wrote:

> Thomas, Johannes,
> could you double check my thinking here? I will repost the patch to
> Andrew if you are OK with this.
> > +	/*
> > +	 * The only protection from memory hotplug vs. drain_stock races is
> > +	 * that we always operate on local CPU stock here with IRQ disabled
> > +	 */
> >  	local_irq_save(flags);
> >  
> >  	stock = this_cpu_ptr(&memcg_stock);
> > @@ -1807,26 +1811,27 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
> >  	if (!mutex_trylock(&percpu_charge_mutex))
> >  		return;
> >  	/* Notify other cpus that system-wide "drain" is running */
> > -	get_online_cpus();
> >  	curcpu = get_cpu();

The problem here is that this does only protect you against a CPU being
unplugged, but not against a CPU coming online concurrently. I have no idea
whether that might be a problem, but at least you should put a comment in
which explains why it is not.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
