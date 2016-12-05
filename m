Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0876B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 15:59:07 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id p66so396413740pga.4
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 12:59:07 -0800 (PST)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id m8si15975102pfi.25.2016.12.05.12.59.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 12:59:06 -0800 (PST)
Received: by mail-pg0-x22d.google.com with SMTP id 3so140477421pgd.0
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 12:59:06 -0800 (PST)
Date: Mon, 5 Dec 2016 12:59:02 -0800
From: Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH] hotplug: make register and unregister notifier API
 symmetric
Message-ID: <20161205205902.GA14876@google.com>
References: <1480540516-6458-1-git-send-email-yuzhao@google.com>
 <20161202134604.GA6837@dhcp22.suse.cz>
 <CALZtONBhvHNpGW4u1a8pVQeHx_8dX17vnFS52rrYbWA5dOtQ8w@mail.gmail.com>
 <20161202143848.GP6830@dhcp22.suse.cz>
 <20161202144440.GQ6830@dhcp22.suse.cz>
 <CALZtONAM27oQWrWn5iinD++NL=Xyex6Au1X_aZRXi3BwW0xWvA@mail.gmail.com>
 <20161202151935.GR6830@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161202151935.GR6830@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>

On Fri, Dec 02, 2016 at 04:19:36PM +0100, Michal Hocko wrote:
> [Let's CC more people - the thread started
> http://lkml.kernel.org/r/1480540516-6458-1-git-send-email-yuzhao@google.com]
> 
> On Fri 02-12-16 09:56:26, Dan Streetman wrote:
> > On Fri, Dec 2, 2016 at 9:44 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > On Fri 02-12-16 15:38:48, Michal Hocko wrote:
> > >> On Fri 02-12-16 09:24:35, Dan Streetman wrote:
> > >> > On Fri, Dec 2, 2016 at 8:46 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > >> > > On Wed 30-11-16 13:15:16, Yu Zhao wrote:
> > >> > >> __unregister_cpu_notifier() only removes registered notifier from its
> > >> > >> linked list when CPU hotplug is configured. If we free registered CPU
> > >> > >> notifier when HOTPLUG_CPU=n, we corrupt the linked list.
> > >> > >>
> > >> > >> To fix the problem, we can either use a static CPU notifier that walks
> > >> > >> through each pool or just simply disable CPU notifier when CPU hotplug
> > >> > >> is not configured (which is perfectly safe because the code in question
> > >> > >> is called after all possible CPUs are online and will remain online
> > >> > >> until power off).
> > >> > >>
> > >> > >> v2: #ifdef for cpu_notifier_register_done during cleanup.
> > >> > >
> > >> > > this ifedfery is just ugly as hell. I am also wondering whether it is
> > >> > > really needed. __register_cpu_notifier and __unregister_cpu_notifier are
> > >> > > noops for CONFIG_HOTPLUG_CPU=n. So what's exactly that is broken here?
> > >> >
> > >> > hmm, that's interesting, __unregister_cpu_notifier is always a noop if
> > >> > HOTPLUG_CPU=n, but __register_cpu_notifier is only a noop if
> > >> > HOTPLUG_CPU=n *and* MODULE.  If !MODULE, __register_cpu_notifier does
> > >>
> > >> OK, I've missed the MODULE part
> > >>
> > >> > actually register!  This was added by commit
> > >> > 47e627bc8c9a70392d2049e6af5bd55fae61fe53 ('hotplug: Allow modules to
> > >> > use the cpu hotplug notifiers even if !CONFIG_HOTPLUG_CPU') and looks
> > >> > like it's to allow built-ins to register so they can notice during
> > >> > boot when cpus are initialized.
> > >>
> > >> I cannot say I wound understand the motivation but that is not really
> > >> all that important.
> > >>
> > >> > IMHO, that is the real problem - sure, without HOTPLUG_CPU, nobody
> > >> > should ever get a notification that a cpu is dying, but that doesn't
> > >> > mean builtins that register notifiers will never unregister their
> > >> > notifiers and then free them.
> > >>
> > >> Yes that is true. That suggests that __unregister_cpu_notifier should
> > >> the the symmetric thing to the __register_cpu_notifier for
> > >> CONFIG_MODULE, right?
> > >
> > > I meant the following. Completely untested
> > 
> > agreed, but also needs the non-__ version, and kernel/cpu.c needs
> > tweaking to move those functions out of the #ifdef CONFIG_HOTPLUG_CPU
> > section.
> 
> OK, this is still only compile tested. Yu Zhao, assuming you were able
> to trigger the original problem could you test with the below patch
> please?

This patch (plus the latest fix in this thread) solves the problem.

Just for the record, the problem is when CONFIG_HOTPLUG_CPU=n, changing
/sys/module/zswap/parameters/compressor multiple times will cause:

[  144.964346] BUG: unable to handle kernel paging request at ffff880658a2be78
[  144.971337] IP: [<ffffffffa290b00b>] raw_notifier_chain_register+0x1b/0x40
<snipped>
[  145.122628] Call Trace:
[  145.125086]  [<ffffffffa28e5cf8>] __register_cpu_notifier+0x18/0x20
[  145.131350]  [<ffffffffa2a5dd73>] zswap_pool_create+0x273/0x400
[  145.137268]  [<ffffffffa2a5e0fc>] __zswap_param_set+0x1fc/0x300
[  145.143188]  [<ffffffffa2944c1d>] ? trace_hardirqs_on+0xd/0x10
[  145.149018]  [<ffffffffa2908798>] ? kernel_param_lock+0x28/0x30
[  145.154940]  [<ffffffffa2a3e8cf>] ? __might_fault+0x4f/0xa0
[  145.160511]  [<ffffffffa2a5e237>] zswap_compressor_param_set+0x17/0x20
[  145.167035]  [<ffffffffa2908d3c>] param_attr_store+0x5c/0xb0
[  145.172694]  [<ffffffffa290848d>] module_attr_store+0x1d/0x30
[  145.178443]  [<ffffffffa2b2b41f>] sysfs_kf_write+0x4f/0x70
[  145.183925]  [<ffffffffa2b2a5b9>] kernfs_fop_write+0x149/0x180
[  145.189761]  [<ffffffffa2a99248>] __vfs_write+0x18/0x40
[  145.194982]  [<ffffffffa2a9a412>] vfs_write+0xb2/0x1a0
[  145.200122]  [<ffffffffa2a9a732>] SyS_write+0x52/0xa0
[  145.205177]  [<ffffffffa2ff4d97>] entry_SYSCALL_64_fastpath+0x12/0x17

> ---
> From c812fe4e519914aa37f092d3a0321038fadcdde7 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 2 Dec 2016 16:06:56 +0100
> Subject: [PATCH] hotplug: make register and unregister notifier API symmetric
> 
> Yu Zhao has noticed that __unregister_cpu_notifier only unregisters its
> notifiers when HOTPLUG_CPU=y while the registration might succeed even
> when HOTPLUG_CPU=n if MODULE is enabled. This means that e.g. zswap
> might keep a stale notifier on the list on the manual clean up during
> the pool tear down and thus corrupt the list. Fix this issue by making
> unregister APIs symmetric to the register so there are no surprises.
> 
> Fixes: 47e627bc8c9a ("[PATCH] hotplug: Allow modules to use the cpu hotplug notifiers even if !CONFIG_HOTPLUG_CPU")
> Cc: stable # zswap needs it 4.3+
> Reported-by: Yu Zhao <yuzhao@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/cpu.h | 15 ++++-----------
>  1 file changed, 4 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/cpu.h b/include/linux/cpu.h
> index 797d9c8e9a1b..c8938eb21e34 100644
> --- a/include/linux/cpu.h
> +++ b/include/linux/cpu.h
> @@ -105,22 +105,16 @@ extern bool cpuhp_tasks_frozen;
>  		{ .notifier_call = fn, .priority = pri };	\
>  	__register_cpu_notifier(&fn##_nb);			\
>  }
> -#else /* #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE) */
> -#define cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
> -#define __cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
> -#endif /* #else #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE) */
>  
> -#ifdef CONFIG_HOTPLUG_CPU
>  extern int register_cpu_notifier(struct notifier_block *nb);
>  extern int __register_cpu_notifier(struct notifier_block *nb);
>  extern void unregister_cpu_notifier(struct notifier_block *nb);
>  extern void __unregister_cpu_notifier(struct notifier_block *nb);
> -#else
>  
> -#ifndef MODULE
> -extern int register_cpu_notifier(struct notifier_block *nb);
> -extern int __register_cpu_notifier(struct notifier_block *nb);
> -#else
> +#else /* #if defined(CONFIG_HOTPLUG_CPU) || !defined(MODULE) */
> +#define cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
> +#define __cpu_notifier(fn, pri)	do { (void)(fn); } while (0)
> +
>  static inline int register_cpu_notifier(struct notifier_block *nb)
>  {
>  	return 0;
> @@ -130,7 +124,6 @@ static inline int __register_cpu_notifier(struct notifier_block *nb)
>  {
>  	return 0;
>  }
> -#endif
>  
>  static inline void unregister_cpu_notifier(struct notifier_block *nb)
>  {
> -- 
> 2.10.2
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
