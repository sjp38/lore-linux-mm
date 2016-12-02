Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 238A56B0253
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 10:19:40 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y16so3641446wmd.6
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 07:19:40 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id ce10si5733494wjd.29.2016.12.02.07.19.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 07:19:37 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id xy5so30642390wjc.1
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 07:19:37 -0800 (PST)
Date: Fri, 2 Dec 2016 16:19:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] hotplug: make register and unregister notifier API symmetric
Message-ID: <20161202151935.GR6830@dhcp22.suse.cz>
References: <1480540516-6458-1-git-send-email-yuzhao@google.com>
 <20161202134604.GA6837@dhcp22.suse.cz>
 <CALZtONBhvHNpGW4u1a8pVQeHx_8dX17vnFS52rrYbWA5dOtQ8w@mail.gmail.com>
 <20161202143848.GP6830@dhcp22.suse.cz>
 <20161202144440.GQ6830@dhcp22.suse.cz>
 <CALZtONAM27oQWrWn5iinD++NL=Xyex6Au1X_aZRXi3BwW0xWvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONAM27oQWrWn5iinD++NL=Xyex6Au1X_aZRXi3BwW0xWvA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Yu Zhao <yuzhao@google.com>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>

[Let's CC more people - the thread started
http://lkml.kernel.org/r/1480540516-6458-1-git-send-email-yuzhao@google.com]

On Fri 02-12-16 09:56:26, Dan Streetman wrote:
> On Fri, Dec 2, 2016 at 9:44 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Fri 02-12-16 15:38:48, Michal Hocko wrote:
> >> On Fri 02-12-16 09:24:35, Dan Streetman wrote:
> >> > On Fri, Dec 2, 2016 at 8:46 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >> > > On Wed 30-11-16 13:15:16, Yu Zhao wrote:
> >> > >> __unregister_cpu_notifier() only removes registered notifier from its
> >> > >> linked list when CPU hotplug is configured. If we free registered CPU
> >> > >> notifier when HOTPLUG_CPU=n, we corrupt the linked list.
> >> > >>
> >> > >> To fix the problem, we can either use a static CPU notifier that walks
> >> > >> through each pool or just simply disable CPU notifier when CPU hotplug
> >> > >> is not configured (which is perfectly safe because the code in question
> >> > >> is called after all possible CPUs are online and will remain online
> >> > >> until power off).
> >> > >>
> >> > >> v2: #ifdef for cpu_notifier_register_done during cleanup.
> >> > >
> >> > > this ifedfery is just ugly as hell. I am also wondering whether it is
> >> > > really needed. __register_cpu_notifier and __unregister_cpu_notifier are
> >> > > noops for CONFIG_HOTPLUG_CPU=n. So what's exactly that is broken here?
> >> >
> >> > hmm, that's interesting, __unregister_cpu_notifier is always a noop if
> >> > HOTPLUG_CPU=n, but __register_cpu_notifier is only a noop if
> >> > HOTPLUG_CPU=n *and* MODULE.  If !MODULE, __register_cpu_notifier does
> >>
> >> OK, I've missed the MODULE part
> >>
> >> > actually register!  This was added by commit
> >> > 47e627bc8c9a70392d2049e6af5bd55fae61fe53 ('hotplug: Allow modules to
> >> > use the cpu hotplug notifiers even if !CONFIG_HOTPLUG_CPU') and looks
> >> > like it's to allow built-ins to register so they can notice during
> >> > boot when cpus are initialized.
> >>
> >> I cannot say I wound understand the motivation but that is not really
> >> all that important.
> >>
> >> > IMHO, that is the real problem - sure, without HOTPLUG_CPU, nobody
> >> > should ever get a notification that a cpu is dying, but that doesn't
> >> > mean builtins that register notifiers will never unregister their
> >> > notifiers and then free them.
> >>
> >> Yes that is true. That suggests that __unregister_cpu_notifier should
> >> the the symmetric thing to the __register_cpu_notifier for
> >> CONFIG_MODULE, right?
> >
> > I meant the following. Completely untested
> 
> agreed, but also needs the non-__ version, and kernel/cpu.c needs
> tweaking to move those functions out of the #ifdef CONFIG_HOTPLUG_CPU
> section.

OK, this is still only compile tested. Yu Zhao, assuming you were able
to trigger the original problem could you test with the below patch
please?
---
