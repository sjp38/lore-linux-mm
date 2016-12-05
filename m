Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5B83F6B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 16:11:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y71so394238352pgd.0
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 13:11:30 -0800 (PST)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id z190si15909785pgd.290.2016.12.05.13.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 13:11:29 -0800 (PST)
Received: by mail-pg0-x230.google.com with SMTP id f188so140082685pgc.3
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 13:11:29 -0800 (PST)
Date: Mon, 5 Dec 2016 13:11:26 -0800
From: Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH v2] zswap: only use CPU notifier when HOTPLUG_CPU=y
Message-ID: <20161205211126.GB14876@google.com>
References: <1480540516-6458-1-git-send-email-yuzhao@google.com>
 <20161202134604.GA6837@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161202134604.GA6837@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 02, 2016 at 02:46:06PM +0100, Michal Hocko wrote:
> On Wed 30-11-16 13:15:16, Yu Zhao wrote:
> > __unregister_cpu_notifier() only removes registered notifier from its
> > linked list when CPU hotplug is configured. If we free registered CPU
> > notifier when HOTPLUG_CPU=n, we corrupt the linked list.
> > 
> > To fix the problem, we can either use a static CPU notifier that walks
> > through each pool or just simply disable CPU notifier when CPU hotplug
> > is not configured (which is perfectly safe because the code in question
> > is called after all possible CPUs are online and will remain online
> > until power off).
> > 
> > v2: #ifdef for cpu_notifier_register_done during cleanup.
> 
> this ifedfery is just ugly as hell. I am also wondering whether it is
> really needed. __register_cpu_notifier and __unregister_cpu_notifier are
> noops for CONFIG_HOTPLUG_CPU=n. So what's exactly that is broken here?

Well, I'm not a fan of ifdef and I don't like the unnecessary memory
usage (notifier_block) and lock (cpu_notifier_register_begin/done)
either.

Just pointing this out, having no problem living with your hotplug
fixes.

> 
> > Signe-off-by: Yu Zhao <yuzhao@google.com>
> > ---
> >  mm/zswap.c | 14 ++++++++++++++
> >  1 file changed, 14 insertions(+)
> > 
> > diff --git a/mm/zswap.c b/mm/zswap.c
> > index 275b22c..2915f44 100644
> > --- a/mm/zswap.c
> > +++ b/mm/zswap.c
> > @@ -118,7 +118,9 @@ struct zswap_pool {
> >  	struct kref kref;
> >  	struct list_head list;
> >  	struct work_struct work;
> > +#ifdef CONFIG_HOTPLUG_CPU
> >  	struct notifier_block notifier;
> > +#endif
> >  	char tfm_name[CRYPTO_MAX_ALG_NAME];
> >  };
> >  
> > @@ -448,6 +450,7 @@ static int __zswap_cpu_comp_notifier(struct zswap_pool *pool,
> >  	return NOTIFY_OK;
> >  }
> >  
> > +#ifdef CONFIG_HOTPLUG_CPU
> >  static int zswap_cpu_comp_notifier(struct notifier_block *nb,
> >  				   unsigned long action, void *pcpu)
> >  {
> > @@ -456,27 +459,34 @@ static int zswap_cpu_comp_notifier(struct notifier_block *nb,
> >  
> >  	return __zswap_cpu_comp_notifier(pool, action, cpu);
> >  }
> > +#endif
> >  
> >  static int zswap_cpu_comp_init(struct zswap_pool *pool)
> >  {
> >  	unsigned long cpu;
> >  
> > +#ifdef CONFIG_HOTPLUG_CPU
> >  	memset(&pool->notifier, 0, sizeof(pool->notifier));
> >  	pool->notifier.notifier_call = zswap_cpu_comp_notifier;
> >  
> >  	cpu_notifier_register_begin();
> > +#endif
> >  	for_each_online_cpu(cpu)
> >  		if (__zswap_cpu_comp_notifier(pool, CPU_UP_PREPARE, cpu) ==
> >  		    NOTIFY_BAD)
> >  			goto cleanup;
> > +#ifdef CONFIG_HOTPLUG_CPU
> >  	__register_cpu_notifier(&pool->notifier);
> >  	cpu_notifier_register_done();
> > +#endif
> >  	return 0;
> >  
> >  cleanup:
> >  	for_each_online_cpu(cpu)
> >  		__zswap_cpu_comp_notifier(pool, CPU_UP_CANCELED, cpu);
> > +#ifdef CONFIG_HOTPLUG_CPU
> >  	cpu_notifier_register_done();
> > +#endif
> >  	return -ENOMEM;
> >  }
> >  
> > @@ -484,11 +494,15 @@ static void zswap_cpu_comp_destroy(struct zswap_pool *pool)
> >  {
> >  	unsigned long cpu;
> >  
> > +#ifdef CONFIG_HOTPLUG_CPU
> >  	cpu_notifier_register_begin();
> > +#endif
> >  	for_each_online_cpu(cpu)
> >  		__zswap_cpu_comp_notifier(pool, CPU_UP_CANCELED, cpu);
> > +#ifdef CONFIG_HOTPLUG_CPU
> >  	__unregister_cpu_notifier(&pool->notifier);
> >  	cpu_notifier_register_done();
> > +#endif
> >  }
> >  
> >  /*********************************
> > -- 
> > 2.8.0.rc3.226.g39d4020
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
