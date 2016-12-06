Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DE2126B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 04:30:42 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so23152696wma.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 01:30:42 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id v10si2843758wmv.51.2016.12.06.01.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Dec 2016 01:30:41 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id a20so20313791wme.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 01:30:41 -0800 (PST)
Date: Tue, 6 Dec 2016 10:30:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] hotplug: make register and unregister notifier API
 symmetric
Message-ID: <20161206093038.GA21270@dhcp22.suse.cz>
References: <1480540516-6458-1-git-send-email-yuzhao@google.com>
 <20161202134604.GA6837@dhcp22.suse.cz>
 <CALZtONBhvHNpGW4u1a8pVQeHx_8dX17vnFS52rrYbWA5dOtQ8w@mail.gmail.com>
 <20161202143848.GP6830@dhcp22.suse.cz>
 <20161202144440.GQ6830@dhcp22.suse.cz>
 <CALZtONAM27oQWrWn5iinD++NL=Xyex6Au1X_aZRXi3BwW0xWvA@mail.gmail.com>
 <20161202151935.GR6830@dhcp22.suse.cz>
 <20161205205902.GA14876@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161205205902.GA14876@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>

On Mon 05-12-16 12:59:02, Yu Zhao wrote:
> On Fri, Dec 02, 2016 at 04:19:36PM +0100, Michal Hocko wrote:
> > [Let's CC more people - the thread started
> > http://lkml.kernel.org/r/1480540516-6458-1-git-send-email-yuzhao@google.com]
> > 
> > On Fri 02-12-16 09:56:26, Dan Streetman wrote:
> > > On Fri, Dec 2, 2016 at 9:44 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > > On Fri 02-12-16 15:38:48, Michal Hocko wrote:
> > > >> On Fri 02-12-16 09:24:35, Dan Streetman wrote:
> > > >> > On Fri, Dec 2, 2016 at 8:46 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > >> > > On Wed 30-11-16 13:15:16, Yu Zhao wrote:
> > > >> > >> __unregister_cpu_notifier() only removes registered notifier from its
> > > >> > >> linked list when CPU hotplug is configured. If we free registered CPU
> > > >> > >> notifier when HOTPLUG_CPU=n, we corrupt the linked list.
> > > >> > >>
> > > >> > >> To fix the problem, we can either use a static CPU notifier that walks
> > > >> > >> through each pool or just simply disable CPU notifier when CPU hotplug
> > > >> > >> is not configured (which is perfectly safe because the code in question
> > > >> > >> is called after all possible CPUs are online and will remain online
> > > >> > >> until power off).
> > > >> > >>
> > > >> > >> v2: #ifdef for cpu_notifier_register_done during cleanup.
> > > >> > >
> > > >> > > this ifedfery is just ugly as hell. I am also wondering whether it is
> > > >> > > really needed. __register_cpu_notifier and __unregister_cpu_notifier are
> > > >> > > noops for CONFIG_HOTPLUG_CPU=n. So what's exactly that is broken here?
> > > >> >
> > > >> > hmm, that's interesting, __unregister_cpu_notifier is always a noop if
> > > >> > HOTPLUG_CPU=n, but __register_cpu_notifier is only a noop if
> > > >> > HOTPLUG_CPU=n *and* MODULE.  If !MODULE, __register_cpu_notifier does
> > > >>
> > > >> OK, I've missed the MODULE part
> > > >>
> > > >> > actually register!  This was added by commit
> > > >> > 47e627bc8c9a70392d2049e6af5bd55fae61fe53 ('hotplug: Allow modules to
> > > >> > use the cpu hotplug notifiers even if !CONFIG_HOTPLUG_CPU') and looks
> > > >> > like it's to allow built-ins to register so they can notice during
> > > >> > boot when cpus are initialized.
> > > >>
> > > >> I cannot say I wound understand the motivation but that is not really
> > > >> all that important.
> > > >>
> > > >> > IMHO, that is the real problem - sure, without HOTPLUG_CPU, nobody
> > > >> > should ever get a notification that a cpu is dying, but that doesn't
> > > >> > mean builtins that register notifiers will never unregister their
> > > >> > notifiers and then free them.
> > > >>
> > > >> Yes that is true. That suggests that __unregister_cpu_notifier should
> > > >> the the symmetric thing to the __register_cpu_notifier for
> > > >> CONFIG_MODULE, right?
> > > >
> > > > I meant the following. Completely untested
> > > 
> > > agreed, but also needs the non-__ version, and kernel/cpu.c needs
> > > tweaking to move those functions out of the #ifdef CONFIG_HOTPLUG_CPU
> > > section.
> > 
> > OK, this is still only compile tested. Yu Zhao, assuming you were able
> > to trigger the original problem could you test with the below patch
> > please?
> 
> This patch (plus the latest fix in this thread) solves the problem.
> 
> Just for the record, the problem is when CONFIG_HOTPLUG_CPU=n, changing
> /sys/module/zswap/parameters/compressor multiple times will cause:
> 
> [  144.964346] BUG: unable to handle kernel paging request at ffff880658a2be78
> [  144.971337] IP: [<ffffffffa290b00b>] raw_notifier_chain_register+0x1b/0x40
> <snipped>
> [  145.122628] Call Trace:
> [  145.125086]  [<ffffffffa28e5cf8>] __register_cpu_notifier+0x18/0x20
> [  145.131350]  [<ffffffffa2a5dd73>] zswap_pool_create+0x273/0x400
> [  145.137268]  [<ffffffffa2a5e0fc>] __zswap_param_set+0x1fc/0x300
> [  145.143188]  [<ffffffffa2944c1d>] ? trace_hardirqs_on+0xd/0x10
> [  145.149018]  [<ffffffffa2908798>] ? kernel_param_lock+0x28/0x30
> [  145.154940]  [<ffffffffa2a3e8cf>] ? __might_fault+0x4f/0xa0
> [  145.160511]  [<ffffffffa2a5e237>] zswap_compressor_param_set+0x17/0x20
> [  145.167035]  [<ffffffffa2908d3c>] param_attr_store+0x5c/0xb0
> [  145.172694]  [<ffffffffa290848d>] module_attr_store+0x1d/0x30
> [  145.178443]  [<ffffffffa2b2b41f>] sysfs_kf_write+0x4f/0x70
> [  145.183925]  [<ffffffffa2b2a5b9>] kernfs_fop_write+0x149/0x180
> [  145.189761]  [<ffffffffa2a99248>] __vfs_write+0x18/0x40
> [  145.194982]  [<ffffffffa2a9a412>] vfs_write+0xb2/0x1a0
> [  145.200122]  [<ffffffffa2a9a732>] SyS_write+0x52/0xa0
> [  145.205177]  [<ffffffffa2ff4d97>] entry_SYSCALL_64_fastpath+0x12/0x17

Thanks for this additional information which I have added to the
changelog. I have also added your Tested-by unless you have any
objections and will repost soon.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
