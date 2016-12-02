Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F10406B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 09:38:51 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id bk3so45385177wjc.4
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 06:38:51 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 189si3372314wmz.7.2016.12.02.06.38.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 06:38:50 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u144so3047119wmu.0
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 06:38:50 -0800 (PST)
Date: Fri, 2 Dec 2016 15:38:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] zswap: only use CPU notifier when HOTPLUG_CPU=y
Message-ID: <20161202143848.GP6830@dhcp22.suse.cz>
References: <1480540516-6458-1-git-send-email-yuzhao@google.com>
 <20161202134604.GA6837@dhcp22.suse.cz>
 <CALZtONBhvHNpGW4u1a8pVQeHx_8dX17vnFS52rrYbWA5dOtQ8w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONBhvHNpGW4u1a8pVQeHx_8dX17vnFS52rrYbWA5dOtQ8w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Yu Zhao <yuzhao@google.com>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri 02-12-16 09:24:35, Dan Streetman wrote:
> On Fri, Dec 2, 2016 at 8:46 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Wed 30-11-16 13:15:16, Yu Zhao wrote:
> >> __unregister_cpu_notifier() only removes registered notifier from its
> >> linked list when CPU hotplug is configured. If we free registered CPU
> >> notifier when HOTPLUG_CPU=n, we corrupt the linked list.
> >>
> >> To fix the problem, we can either use a static CPU notifier that walks
> >> through each pool or just simply disable CPU notifier when CPU hotplug
> >> is not configured (which is perfectly safe because the code in question
> >> is called after all possible CPUs are online and will remain online
> >> until power off).
> >>
> >> v2: #ifdef for cpu_notifier_register_done during cleanup.
> >
> > this ifedfery is just ugly as hell. I am also wondering whether it is
> > really needed. __register_cpu_notifier and __unregister_cpu_notifier are
> > noops for CONFIG_HOTPLUG_CPU=n. So what's exactly that is broken here?
> 
> hmm, that's interesting, __unregister_cpu_notifier is always a noop if
> HOTPLUG_CPU=n, but __register_cpu_notifier is only a noop if
> HOTPLUG_CPU=n *and* MODULE.  If !MODULE, __register_cpu_notifier does

OK, I've missed the MODULE part

> actually register!  This was added by commit
> 47e627bc8c9a70392d2049e6af5bd55fae61fe53 ('hotplug: Allow modules to
> use the cpu hotplug notifiers even if !CONFIG_HOTPLUG_CPU') and looks
> like it's to allow built-ins to register so they can notice during
> boot when cpus are initialized.
 
I cannot say I wound understand the motivation but that is not really
all that important.

> IMHO, that is the real problem - sure, without HOTPLUG_CPU, nobody
> should ever get a notification that a cpu is dying, but that doesn't
> mean builtins that register notifiers will never unregister their
> notifiers and then free them.

Yes that is true. That suggests that __unregister_cpu_notifier should
the the symmetric thing to the __register_cpu_notifier for
CONFIG_MODULE, right?

> Changing zswap is only working around the symptom; instead, hotplug
> should be changed to provide unregister_cpu_notifier in all cases
> where register_cpu_notifier is provided.

Agreed.

> >> Signe-off-by: Yu Zhao <yuzhao@google.com>
> >> ---
> >>  mm/zswap.c | 14 ++++++++++++++
> >>  1 file changed, 14 insertions(+)
> >>
> >> diff --git a/mm/zswap.c b/mm/zswap.c
> >> index 275b22c..2915f44 100644
> >> --- a/mm/zswap.c
> >> +++ b/mm/zswap.c
> >> @@ -118,7 +118,9 @@ struct zswap_pool {
> >>       struct kref kref;
> >>       struct list_head list;
> >>       struct work_struct work;
> >> +#ifdef CONFIG_HOTPLUG_CPU
> >>       struct notifier_block notifier;
> >> +#endif
> >>       char tfm_name[CRYPTO_MAX_ALG_NAME];
> >>  };
> >>
> >> @@ -448,6 +450,7 @@ static int __zswap_cpu_comp_notifier(struct zswap_pool *pool,
> >>       return NOTIFY_OK;
> >>  }
> >>
> >> +#ifdef CONFIG_HOTPLUG_CPU
> >>  static int zswap_cpu_comp_notifier(struct notifier_block *nb,
> >>                                  unsigned long action, void *pcpu)
> >>  {
> >> @@ -456,27 +459,34 @@ static int zswap_cpu_comp_notifier(struct notifier_block *nb,
> >>
> >>       return __zswap_cpu_comp_notifier(pool, action, cpu);
> >>  }
> >> +#endif
> >>
> >>  static int zswap_cpu_comp_init(struct zswap_pool *pool)
> >>  {
> >>       unsigned long cpu;
> >>
> >> +#ifdef CONFIG_HOTPLUG_CPU
> >>       memset(&pool->notifier, 0, sizeof(pool->notifier));
> >>       pool->notifier.notifier_call = zswap_cpu_comp_notifier;
> >>
> >>       cpu_notifier_register_begin();
> >> +#endif
> >>       for_each_online_cpu(cpu)
> >>               if (__zswap_cpu_comp_notifier(pool, CPU_UP_PREPARE, cpu) ==
> >>                   NOTIFY_BAD)
> >>                       goto cleanup;
> >> +#ifdef CONFIG_HOTPLUG_CPU
> >>       __register_cpu_notifier(&pool->notifier);
> >>       cpu_notifier_register_done();
> >> +#endif
> >>       return 0;
> >>
> >>  cleanup:
> >>       for_each_online_cpu(cpu)
> >>               __zswap_cpu_comp_notifier(pool, CPU_UP_CANCELED, cpu);
> >> +#ifdef CONFIG_HOTPLUG_CPU
> >>       cpu_notifier_register_done();
> >> +#endif
> >>       return -ENOMEM;
> >>  }
> >>
> >> @@ -484,11 +494,15 @@ static void zswap_cpu_comp_destroy(struct zswap_pool *pool)
> >>  {
> >>       unsigned long cpu;
> >>
> >> +#ifdef CONFIG_HOTPLUG_CPU
> >>       cpu_notifier_register_begin();
> >> +#endif
> >>       for_each_online_cpu(cpu)
> >>               __zswap_cpu_comp_notifier(pool, CPU_UP_CANCELED, cpu);
> >> +#ifdef CONFIG_HOTPLUG_CPU
> >>       __unregister_cpu_notifier(&pool->notifier);
> >>       cpu_notifier_register_done();
> >> +#endif
> >>  }
> >>
> >>  /*********************************
> >> --
> >> 2.8.0.rc3.226.g39d4020
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> > --
> > Michal Hocko
> > SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
