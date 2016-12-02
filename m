Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0926B0253
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 09:44:43 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id o2so38338622wje.5
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 06:44:43 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id i125si3321859wmg.121.2016.12.02.06.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 06:44:42 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id xy5so30520746wjc.1
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 06:44:42 -0800 (PST)
Date: Fri, 2 Dec 2016 15:44:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] zswap: only use CPU notifier when HOTPLUG_CPU=y
Message-ID: <20161202144440.GQ6830@dhcp22.suse.cz>
References: <1480540516-6458-1-git-send-email-yuzhao@google.com>
 <20161202134604.GA6837@dhcp22.suse.cz>
 <CALZtONBhvHNpGW4u1a8pVQeHx_8dX17vnFS52rrYbWA5dOtQ8w@mail.gmail.com>
 <20161202143848.GP6830@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161202143848.GP6830@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Yu Zhao <yuzhao@google.com>, Seth Jennings <sjenning@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri 02-12-16 15:38:48, Michal Hocko wrote:
> On Fri 02-12-16 09:24:35, Dan Streetman wrote:
> > On Fri, Dec 2, 2016 at 8:46 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > On Wed 30-11-16 13:15:16, Yu Zhao wrote:
> > >> __unregister_cpu_notifier() only removes registered notifier from its
> > >> linked list when CPU hotplug is configured. If we free registered CPU
> > >> notifier when HOTPLUG_CPU=n, we corrupt the linked list.
> > >>
> > >> To fix the problem, we can either use a static CPU notifier that walks
> > >> through each pool or just simply disable CPU notifier when CPU hotplug
> > >> is not configured (which is perfectly safe because the code in question
> > >> is called after all possible CPUs are online and will remain online
> > >> until power off).
> > >>
> > >> v2: #ifdef for cpu_notifier_register_done during cleanup.
> > >
> > > this ifedfery is just ugly as hell. I am also wondering whether it is
> > > really needed. __register_cpu_notifier and __unregister_cpu_notifier are
> > > noops for CONFIG_HOTPLUG_CPU=n. So what's exactly that is broken here?
> > 
> > hmm, that's interesting, __unregister_cpu_notifier is always a noop if
> > HOTPLUG_CPU=n, but __register_cpu_notifier is only a noop if
> > HOTPLUG_CPU=n *and* MODULE.  If !MODULE, __register_cpu_notifier does
> 
> OK, I've missed the MODULE part
> 
> > actually register!  This was added by commit
> > 47e627bc8c9a70392d2049e6af5bd55fae61fe53 ('hotplug: Allow modules to
> > use the cpu hotplug notifiers even if !CONFIG_HOTPLUG_CPU') and looks
> > like it's to allow built-ins to register so they can notice during
> > boot when cpus are initialized.
>  
> I cannot say I wound understand the motivation but that is not really
> all that important.
> 
> > IMHO, that is the real problem - sure, without HOTPLUG_CPU, nobody
> > should ever get a notification that a cpu is dying, but that doesn't
> > mean builtins that register notifiers will never unregister their
> > notifiers and then free them.
> 
> Yes that is true. That suggests that __unregister_cpu_notifier should
> the the symmetric thing to the __register_cpu_notifier for
> CONFIG_MODULE, right?

I meant the following. Completely untested
---
diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index 797d9c8e9a1b..8d7b473426af 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -120,6 +120,7 @@ extern void __unregister_cpu_notifier(struct notifier_block *nb);
 #ifndef MODULE
 extern int register_cpu_notifier(struct notifier_block *nb);
 extern int __register_cpu_notifier(struct notifier_block *nb);
+extern void __unregister_cpu_notifier(struct notifier_block *nb);
 #else
 static inline int register_cpu_notifier(struct notifier_block *nb)
 {
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
