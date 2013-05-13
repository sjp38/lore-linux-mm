Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id BC2356B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 07:21:34 -0400 (EDT)
Date: Mon, 13 May 2013 07:21:32 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [page fault tracepoint 1/2] Add page fault trace event
	definitions
Message-ID: <20130513112132.GA15168@Krystal>
References: <1368079520-11015-1-git-send-email-fdeslaur@gmail.com> <518B464E.6010208@huawei.com> <518BA91E.3080406@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <518BA91E.3080406@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: "zhangwei(Jovi)" <jovi.zhangwei@huawei.com>, Francis Deslauriers <fdeslaur@gmail.com>, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, rostedt@goodmis.org, fweisbec@gmail.com, raphael.beamonte@gmail.com, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

* H. Peter Anvin (hpa@zytor.com) wrote:
> On 05/08/2013 11:46 PM, zhangwei(Jovi) wrote:
> > On 2013/5/9 14:05, Francis Deslauriers wrote:
> >> Add page_fault_entry and page_fault_exit event definitions. It will
> >> allow each architecture to instrument their page faults.
> > 
> > I'm wondering if this tracepoint could handle other page faults,
> > like faults in kernel memory(vmalloc, kmmio, etc...)
> > 
> > And if we decide to support those faults, add a type annotate in TP_printk
> > would be much helpful for user, to let user know what type of page faults happened.
> > 
> 
> The plan for x86 was to switch the IDT so that any exception could get a
> trace event without any overhead in normal operation.  This has been in
> the process for quite some time but looks like it was getting very close.

Hi Peter,

Who is leading this IDT instrumentation effort ?

Since we have tracepoints in interrupt handlers nowadays, I wonder what
makes traps so much more special than interrupts to require the
arch-specific complexity of the IDT switcharoo trick ? If I had to
guess, the reason for this would be the page fault handler, which is
called way too frequently for its own good. The number of page faults
triggered by COW on process fork has been impressively high for the past
couple of years.

IMHO, this should be one extra reason for quickly allowing people to
trace those page faults, so they can get an idea of their tremendous
performance impact. This could speed up the efforts on transparent huge
pages, which seems to be a viable long-term solution to this page-size
scalability issue.

By default, my 3.5 Linux kernel (Debian) has:

$ cat /sys/kernel/mm/transparent_hugepage/enabled
always [madvise] never

I think transparent huge pages will become generally useful when enabled
by default, and when they will handle the page cache in addition to
anonymous pages.[1]

Thanks,

Mathieu

[1] Documentation/vm/transhuge.txt

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
