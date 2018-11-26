Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51D286B42B8
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 11:54:50 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so9201528edt.23
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 08:54:50 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id s19-v6si570774ejm.289.2018.11.26.08.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 08:54:48 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 806381C30F4
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 16:54:48 +0000 (GMT)
Date: Mon, 26 Nov 2018 16:54:47 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Hackbench pipes regression bisected to PSI
Message-ID: <20181126165446.GQ23260@techsingularity.net>
References: <20181126133420.GN23260@techsingularity.net>
 <20181126160724.GA21268@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181126160724.GA21268@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Mon, Nov 26, 2018 at 11:07:24AM -0500, Johannes Weiner wrote:
> Hi Mel,
> 
> On Mon, Nov 26, 2018 at 01:34:20PM +0000, Mel Gorman wrote:
> > Hi Johannes,
> > 
> > PSI is a great idea but it does have overhead and if enabled by Kconfig
> > then it incurs a hit whether the user is aware of the feature or not. I
> > think enabling by default is unnecessary as it should only be enabled if
> > the information is being consumed. While the Kconfig exists, it's all or
> > nothing if distributions want to have the feature available.
> 
> Yes, let's make this easier to pick and choose. Obviously I'd rather
> you shipped it default-disabled than not at all.
> 

Indeed.

> > I've included a bisection report below showing a 6-10% regression on a
> > single socket skylake machine. Would you mind doing one or all of the
> > following to fix it please?
> > 
> > a) disable it by default
> > b) put psi_disable behind a static branch to move the overhead to zero
> >    if it's disabled
> > c) optionally enable/disable at runtime (least important as at a glance,
> >    this may be problematic)
> 
> For a) I'd suggest we do what we do in other places that face this
> vendor kernel trade-off (NUMA balancing comes to mind): one option to
> build the feature, one option to set whether the default is on or off.
> 

That would be fine and makes sense.

> And b) is pretty straight-forward, let's do that too.
> 

Thanks.

> c) is not possible, as we need the complete task counts to calculate
> pressure, and maintaining those counts are where the sched cost is.
> 

I figured that this would be the case.

> > Last good/First bad commit
> > ==========================
> > Last good commit: eb414681d5a07d28d2ff90dc05f69ec6b232ebd2
> > First bad commit: 2ce7135adc9ad081aa3c49744144376ac74fea60
> > From 2ce7135adc9ad081aa3c49744144376ac74fea60 Mon Sep 17 00:00:00 2001
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Date: Fri, 26 Oct 2018 15:06:31 -0700
> > Subject: [PATCH] psi: cgroup support
> > On a system that executes multiple cgrouped jobs and independent
> > workloads, we don't just care about the health of the overall system, but
> > also that of individual jobs, so that we can ensure individual job health,
> > fairness between jobs, or prioritize some jobs over others.
> > This patch implements pressure stall tracking for cgroups.  In kernels
> > with CONFIG_PSI=y, cgroup2 groups will have cpu.pressure, memory.pressure,
> > and io.pressure files that track aggregate pressure stall times for only
> > the tasks inside the cgroup.
> 
> It's curious that the cgroup support patch is the offender, not the
> psi patch itself (that adds some cost as per the hackbench results,
> but not as much). What kind of cgroup setup does this code run in?
> 

No cgroup is setup but given that it is an automatic bisection, it's not
very unusual for it to get "close" but not get it exactly right.

> Anyway, how about the following?
> 

I've queued it up setting CONFIG_PSI_DEFAULT_DISABLED in the Kconfig.

> <SNIP>
>
> diff --git a/init/Kconfig b/init/Kconfig
> index a4112e95724a..cf5b5a0dcbc2 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -509,6 +509,15 @@ config PSI
>  
>  	  Say N if unsure.
>  
> +config PSI_DEFAULT_DISABLED
> +	bool "Require boot parameter to enable pressure stall information tracking"
> +	default n
> +	depends on PSI
> +	help
> +	  If set, pressure stall information tracking will be disabled
> +	  per default but can be enabled through passing psi_enable=1
> +	  on the kernel commandline during boot.
> +
>  endmenu # "CPU/Task time and stats accounting"
>  

Should this default y on the basis that someone only wants the feature if
they are aware of it? This is not that important as CONFIG_PSI is disabled
by default and it's up to distribution maintainers to use their brain.

>  config CPU_ISOLATION
> diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
> index 3d7355d7c3e3..9da0af3cd898 100644
> --- a/kernel/sched/psi.c
> +++ b/kernel/sched/psi.c
> @@ -136,8 +136,18 @@
>  
>  static int psi_bug __read_mostly;
>  
> -bool psi_disabled __read_mostly;
> -core_param(psi_disabled, psi_disabled, bool, 0644);
> +DEFINE_STATIC_KEY_FALSE(psi_disabled);
> +
> +#ifdef CONFIG_PSI_DEFAULT_DISABLED
> +bool psi_enable;
> +#else
> +bool psi_enable = true;
> +#endif
> +static int __init parse_psi_enable(char *str)
> +{
> +	return kstrtobool(str, &psi_enable) == 0;
> +}
> +__setup("psi_enable=", parse_psi_enable);
>  

Bit late to notice but this switch should be in
Documentation/admin-guide/kernel-parameters.txt. If you really want to
match the automatic numa balancing switch then it also should be
psi=[enable|disable] instead of psi_enable=[1|0]

-- 
Mel Gorman
SUSE Labs
