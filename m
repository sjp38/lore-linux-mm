Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5874B6B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 03:37:12 -0400 (EDT)
Date: Wed, 11 Mar 2009 15:36:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090311073619.GA26691@localhost>
References: <20090310024135.GA6832@localhost> <20090310081917.GA28968@localhost> <20090310105523.3dfd4873@mjolnir.ossman.eu> <20090310122210.GA8415@localhost> <20090310131155.GA9654@localhost> <20090310212118.7bf17af6@mjolnir.ossman.eu> <20090311013739.GA7078@localhost> <20090311075703.35de2488@mjolnir.ossman.eu> <20090311071445.GA13584@localhost> <20090311082658.06ff605a@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090311082658.06ff605a@mjolnir.ossman.eu>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

(add cc)

On Wed, Mar 11, 2009 at 09:26:58AM +0200, Pierre Ossman wrote:
> On Wed, 11 Mar 2009 15:14:45 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > On Wed, Mar 11, 2009 at 08:57:03AM +0200, Pierre Ossman wrote:
> > > On Wed, 11 Mar 2009 09:37:40 +0800
> > > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > 
> > > > 
> > > > This 80MB noflags pages together with the below 80MB lru pages are
> > > > very close to the missing page numbers :-) Could you run the following
> > > > commands on fresh booted 2.6.27 and post the output files? Thank you!
> > > > 
> > > >         dd if=/dev/zero of=/tmp/s bs=1M count=1 seek=1024
> > > >         cp /tmp/s /dev/null
> > > > 
> > > >         ./page-flags > flags
> > > >         ./page-areas =0x20000 > areas-noflags
> > > >         ./page-areas =0x00020 > areas-lru
> > > > 
> > > 
> > > Attached.
> > 
> > Thank you very much!
> > 
> > > I have to say, the patterns look very much like some kind of leak.
> > 
> > Wow it looks really interesting.  The lru pages and noflags pages make
> > perfect 1-page interleaved pattern...
> > 
> 
> Another breakthrough. I turned off everything in kernel/trace, and now
> the missing memory is back. Here's the relevant diff against the
> original .config:
> 
> @@ -3677,18 +3639,15 @@
>  # CONFIG_BACKTRACE_SELF_TEST is not set
>  # CONFIG_LKDTM is not set
>  # CONFIG_FAULT_INJECTION is not set
> -CONFIG_LATENCYTOP=y
> +# CONFIG_LATENCYTOP is not set
>  # CONFIG_SYSCTL_SYSCALL_CHECK is not set
>  CONFIG_HAVE_FTRACE=y
>  CONFIG_HAVE_DYNAMIC_FTRACE=y
> -CONFIG_TRACER_MAX_TRACE=y
> -CONFIG_TRACING=y
>  # CONFIG_FTRACE is not set
> -CONFIG_IRQSOFF_TRACER=y
> -CONFIG_SYSPROF_TRACER=y
> -CONFIG_SCHED_TRACER=y
> -CONFIG_CONTEXT_SWITCH_TRACER=y
> -# CONFIG_FTRACE_STARTUP_TEST is not set
> +# CONFIG_IRQSOFF_TRACER is not set
> +# CONFIG_SYSPROF_TRACER is not set
> +# CONFIG_SCHED_TRACER is not set
> +# CONFIG_CONTEXT_SWITCH_TRACER is not set
> 
> I'll enable them one at a time and see when the bug reappears, but if
> you have some ideas on which it could be, that would be helpful. The
> machine takes some time to recompile a kernel. :)

A quick question: are there any possibility of ftrace memory reservation?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
