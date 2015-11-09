Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 254946B0255
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 11:21:28 -0500 (EST)
Received: by wmec201 with SMTP id c201so88526251wme.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 08:21:27 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id hx3si2695638wjb.116.2015.11.09.08.21.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 08:21:27 -0800 (PST)
Received: by wmww144 with SMTP id w144so83121760wmw.1
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 08:21:26 -0800 (PST)
Date: Mon, 9 Nov 2015 17:21:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/5] dump_stack: allow specifying printk log level
Message-ID: <20151109162125.GI8916@dhcp22.suse.cz>
References: <20151105223014.701269769@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105223014.701269769@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aris@redhat.com
Cc: linux-kerne@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

On Thu 05-11-15 17:30:14, aris@redhat.com wrote:
> This patchset lays the foundation work to allow using dump_stack() with a
> specified printk log level. Currently each architecture uses a different
> log level in show_stack() and it's not possible to control it without
> calling directly architecture specific functions.
> 
> The motivation behind this work is to limit the amount of kernel messages
> printed in the console when a process is killed by the OOM killer. In some
> scenarios (lots of containers running different customers' workloads) OOMs
> are way more common and don't require the console to be flooded by stack
> traces when the OOM killer probably did the right choice. During a recent
> discussion it was determined that a knob to control when dump_stack() is
> called is a bad idea and instead we should tune the log level in dump_stack()
> which prompted this work.
> 
> This patchset introduces two new functions:
> 	dump_stack_lvl(char *log_lvl)
> 	show_stack_lvl(struct task_struct *task, unsigned long *sp, char *log_lvl)
> 
> and both can be reimplemented by each architecture but only the second is
> expected. The idea is to initially implement show_stack_lvl() in all
> architectures then simply have show_stack() to require log_lvl as parameter.
> While that happens, dump_stack() uses can be changed to dump_stack_lvl() and
> once everything is in place, dump_stack() will require the log_level as well.

This looks good to me FWIW.
 
> I have a draft patch for every architecture but for this patchset I'm only
> including x86 to get some feedback while I try to get a cross compiler working
> for each one of them (which is being harder than I thought).
>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Greg Thelen <gthelen@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Aristeu Rozanski <aris@redhat.com>
> 
> -- 
> Aristeu

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
