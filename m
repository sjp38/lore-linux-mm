Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 764E46B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 09:03:58 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c85so16264980wmi.6
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 06:03:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 204si2243194wmk.136.2017.01.13.06.03.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 06:03:57 -0800 (PST)
Date: Fri, 13 Jan 2017 15:03:56 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20170113140356.GN14894@pathway.suse.cz>
References: <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222134250.GE413@tigerII.localdomain>
 <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
 <20161222140930.GF413@tigerII.localdomain>
 <201612261954.FJE69201.OFLVtFJSQFOHMO@I-love.SAKURA.ne.jp>
 <20161226114106.GB515@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161226114106.GB515@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org

On Mon 2016-12-26 20:41:06, Sergey Senozhatsky wrote:
> On (12/26/16 19:54), Tetsuo Handa wrote:
> > I tried these 9 patches. Generally OK.
> > 
> > Although there is still "schedule_timeout_killable() lockup with oom_lock held"
> > problem, async-printk patches help avoiding "printk() lockup with oom_lock held"
> > problem. Thank you.
> > 
> > Three comments from me.
> > 
> > (1) Messages from e.g. SysRq-b is not waited for sent to consoles.
> >     "SysRq : Resetting" line is needed as a note that I gave up waiting.
> > 
> > (2) Messages from e.g. SysRq-t should be sent to consoles synchronously?
> >     "echo t > /proc/sysrq-trigger" case can use asynchronous printing.
> >     But since ALT-SysRq-T sequence from keyboard may be used when scheduler
> >     is not responding, it might be better to use synchronous printing.
> >     (Or define a magic key sequence to toggle synchronous/asynchronous?)
> 
> it's really hard to tell if the message comes from sysrq or from
> somewhere else.

Yes, but we have the oposite problem now. We usually do not see any
sysrq message on the console with async printk.

> the current approach -- switch to *always* sync printk
> once we see the first LOGLEVEL_EMERG message. so you can add
> printk(LOGLEVEL_EMERG "sysrq-t\n"); for example, and printk will
> switch to sync mode. sync mode, is might be a bit dangerous though,
> since we printk from IRQ.

Sysrq forces all messages to the console by manipulating the
console_loglevel by purpose, see:

void __handle_sysrq(int key, bool check_mask)
{
	struct sysrq_key_op *op_p;
	int orig_log_level;
	int i;

	rcu_sysrq_start();
	rcu_read_lock();
	/*
	 * Raise the apparent loglevel to maximum so that the sysrq header
	 * is shown to provide the user with positive feedback.  We do not
	 * simply emit this at KERN_EMERG as that would change message
	 * routing in the consumers of /proc/kmsg.
	 */
	orig_log_level = console_loglevel;
	console_loglevel = CONSOLE_LOGLEVEL_DEFAULT;
	pr_info("SysRq : ");

Where the loglevel forcing seems to be already in the initial commit
to git.

The comment explaining why KERN_EMERG is not a good idea was added
by the commit fb144adc517d9ebe8fd ("sysrq: add commentary on why we
use the console loglevel over using KERN_EMERG").

Also it seems that all messages are flushed with disabled interrupts
by purpose. See the commit message for that rcu calls in the commit
722773afd83209d4088d ("sysrq,rcu: suppress RCU stall warnings while
sysrq runs").


Therefore, it would make sense to switch to the synchronous
mode in this section.

The question is if we want to come back to the asynchronous mode
when sysrq is finished. It is not easy to do it race-less. A solution
would be to force synchronous mode via the printk_context per-CPU
variable, similar way like we force printk_safe mode.

Alternatively we could try to flush console before resetting back
the console_loglevel:

	if (console_trylock())
		console_unlock();
	console_loglevel = orig_log_level;


Of course, the best solution would be to store the desired console
level with the message into logbuf. But this is not easy because
we would break ABI for external tools, like crashdump, crash, ...

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
