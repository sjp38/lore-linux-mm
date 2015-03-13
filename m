Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 385DB829BE
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 15:32:26 -0400 (EDT)
Received: by iecsl2 with SMTP id sl2so121633307iec.1
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 12:32:26 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0174.hostedemail.com. [216.40.44.174])
        by mx.google.com with ESMTP id j10si3150981igj.49.2015.03.13.12.32.12
        for <linux-mm@kvack.org>;
        Fri, 13 Mar 2015 12:32:12 -0700 (PDT)
Date: Fri, 13 Mar 2015 15:32:10 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] tracing: add trace event for memory-failure
Message-ID: <20150313153210.14f1bd88@gandalf.local.home>
In-Reply-To: <CA+8MBbKen9JfQ29AWVZuxO9CkPCmjG670q0Fg7G-qCPDrtDHig@mail.gmail.com>
References: <1426241451-25729-1-git-send-email-xiexiuqi@huawei.com>
	<CA+8MBbKen9JfQ29AWVZuxO9CkPCmjG670q0Fg7G-qCPDrtDHig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Xie XiuQi <xiexiuqi@huawei.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Chen Gong <gong.chen@linux.intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Borislav Petkov <bp@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jingle.chen@huawei.com

On Fri, 13 Mar 2015 09:37:34 -0700
Tony Luck <tony.luck@gmail.com> wrote:


> >  int sysctl_memory_failure_early_kill __read_mostly = 0;
> >
> > @@ -837,6 +838,8 @@ static struct page_state {
> >   */
> >  static void action_result(unsigned long pfn, char *msg, int result)
> >  {
> > +       trace_memory_failure_event(pfn, msg, action_name[result]);
> > +
> >         pr_err("MCE %#lx: %s page recovery: %s\n",
> >                 pfn, msg, action_name[result]);
> >  }
> > --
> > 1.7.1
> >
> > --
> 
> Concept looks good to me. Adding Steven Rostedt as we've historically had
> challenges adding new trace points in the cleanest way.

Hehe, thank you :-) I actually do have a recommendation. How about just
passing in "result" and doing:


	TP_printk("pfn %#lx: %s page recovery: %s",
		__entry->pfn,
		__get_str(action),
		__print_symbolic(result, 0, "Ignored",
				1, "Failed",
				2, "Delayed",
				3, "Recovered"))


Now it is hard coded here because trace-cmd and perf do not have a way
to process enums (yet, I need to fix that).

I also need a way to just submit print strings on module load and boot
up such that you only need to pass in the address of the action field
instead of the string. That is also a todo of mine that I may soon
change.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
