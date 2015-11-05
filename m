Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id EBB0882F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 17:30:17 -0500 (EST)
Received: by ykba4 with SMTP id a4so158296622ykb.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 14:30:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u184si6545151vke.58.2015.11.05.14.30.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 14:30:16 -0800 (PST)
Message-Id: <20151105223014.701269769@redhat.com>
Date: Thu, 05 Nov 2015 17:30:14 -0500
From: aris@redhat.com
Subject: [PATCH 0/5] dump_stack: allow specifying printk log level
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kerne@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

This patchset lays the foundation work to allow using dump_stack() with a
specified printk log level. Currently each architecture uses a different
log level in show_stack() and it's not possible to control it without
calling directly architecture specific functions.

The motivation behind this work is to limit the amount of kernel messages
printed in the console when a process is killed by the OOM killer. In some
scenarios (lots of containers running different customers' workloads) OOMs
are way more common and don't require the console to be flooded by stack
traces when the OOM killer probably did the right choice. During a recent
discussion it was determined that a knob to control when dump_stack() is
called is a bad idea and instead we should tune the log level in dump_stack()
which prompted this work.

This patchset introduces two new functions:
	dump_stack_lvl(char *log_lvl)
	show_stack_lvl(struct task_struct *task, unsigned long *sp, char *log_lvl)

and both can be reimplemented by each architecture but only the second is
expected. The idea is to initially implement show_stack_lvl() in all
architectures then simply have show_stack() to require log_lvl as parameter.
While that happens, dump_stack() uses can be changed to dump_stack_lvl() and
once everything is in place, dump_stack() will require the log_level as well.

I have a draft patch for every architecture but for this patchset I'm only
including x86 to get some feedback while I try to get a cross compiler working
for each one of them (which is being harder than I thought).

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Aristeu Rozanski <aris@redhat.com>

-- 
Aristeu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
