Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E726E6B0012
	for <linux-mm@kvack.org>; Tue, 17 May 2011 17:52:32 -0400 (EDT)
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
From: Joe Perches <joe@perches.com>
In-Reply-To: <4DD2EBAB.5080004@gmail.com>
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org>
	 <1305665263-20933-3-git-send-email-john.stultz@linaro.org>
	 <4DD2EBAB.5080004@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 May 2011 14:52:30 -0700
Message-ID: <1305669150.1722.83.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 2011-05-17 at 23:42 +0200, Jiri Slaby wrote:
> On 05/17/2011 10:47 PM, John Stultz wrote:
> > Accessing task->comm requires proper locking. However in the past
> > access to current->comm could be done without locking. This
> > is no longer the case, so all comm access needs to be done
> > while holding the comm_lock.
> > +static noinline_for_stack
> I still fail to see why this should be slowed down by noinlining it.
> Care to explain?

Any vsprintf is slow.

> With my setup, the code below inlined will use 32 bytes of stack. The
> same as %pK case. Uninlined it obviously eats "only" 8 bytes for IP.

The idea is to avoid excess stack consumption for things like:

	struct va_format vaf;

	const char *fmt = "some format with %ptc";

	vaf.fmt = fmt;
	vaf.va = &va_list;

	printk("some format with %pV\n", &vaf);

> > +char *task_comm_string(char *buf, char *end, void *addr,
> > +			 struct printf_spec spec, const char *fmt)
> > +{
> > +	struct task_struct *tsk = addr;
> > +	char *ret;
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&tsk->comm_lock, flags);
> > +	ret = string(buf, end, tsk->comm, spec);
> > +	spin_unlock_irqrestore(&tsk->comm_lock, flags);
> > +
> > +	return ret;
> > +}

I think it was more of a problem when "4k stacks" was the default
than today, but I think it is still "good form". 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
