Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id EECDE6B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 11:57:23 -0400 (EDT)
Date: Thu, 12 Apr 2012 12:56:49 -0300
From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: Re: Re: [PATCH] perf/probe: Provide perf interface for uprobes
Message-ID: <20120412155649.GP16257@infradead.org>
References: <20120411135742.29198.45061.sendpatchset@srdronam.in.ibm.com>
 <20120411144918.GD16257@infradead.org>
 <20120411170343.GB29831@linux.vnet.ibm.com>
 <20120411181727.GK16257@infradead.org>
 <4F864BB3.3090405@hitachi.com>
 <20120412140751.GM16257@infradead.org>
 <20120412144148.GA21587@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120412144148.GA21587@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

Em Thu, Apr 12, 2012 at 08:11:48PM +0530, Srikar Dronamraju escreveu:
> * Arnaldo Carvalho de Melo <acme@infradead.org> [2012-04-12 11:07:51]:
> > Em Thu, Apr 12, 2012 at 12:27:47PM +0900, Masami Hiramatsu escreveu:
> > 	Likewise, if we do:
> > 
> >  $ perf probe libc-2.12.so malloc

> > 	It should just figure out it is the /lib64/libc-2.12.so

> > 	Heck, even:

> >  $ perf probe libc malloc

> > 	Makes it even easier to use.

> > 	Its just when one asks for something that has ambiguities that
> > the tool should ask the user to be a bit more precise to remove such
> > ambiguity.
> 
> I do understand/agree that the short form looks better. However each
> user in the system might have different library /executable paths (and
> different ordering of paths. The session in which perf is called may

Yeah, they might, but not really the common case, right?

People with multiple versions can use the precise, full path form.

> find just one unique library or executable. But the used binary maynot
> be the one that is being traced.
> 
> For example: I may have my perf in /home/srikar/bin/perf which may be
> picked up. But when I use "perf probe perf cmd_probe" as a root user,
> the root may only see /usr/bin/perf. It might look intuitive for us.

Which is what he expects. If root wants one specific perf file it can do
so as:

$ perf probe /home/srikar/bin/perf cmd_probe

> However it may not look so for ordinary users and system admins. 
> 
> The other choice would be to probe all executables/libraries by the give
> name. Here also getting a exhaustive list is debatable.

If a path is not provided, we have to resort to the LD library path and
$PATH, as when we run:

$ perf

the system will use what was configured ($PATH) and the LD library path
to resolve libraries, so should perf probe, that is what I'm suggesting
after all :-)

I.e. just because I have /home/acme/bin/perf and /root/bin/perf and
/usr/bin/perf, possibly all different (distro shipped, last stable,
current one being developed, whatever), we don't _require_ that the full
path be provided, we let the shell do its work in finding the right
binary.
 
> So I think its okay for people to type a bit more than allow perf to guess
> and make a wrong choice. After all we have bash history and tab
> completion, command alias to lessen the typing.

And those are good, but we can do even better by using well established
conventions for finding the right binary/DSO when a path is not
specified ($PATH, $LD_LIBRARY_PATH).
 
> > [acme@sandy linux]$ locate libc-2.12.so
> > /home/acme/.debug/lib64/libc-2.12.so
> > /home/acme/.debug/lib64/libc-2.12.so/293f8b6f5e6cea240d1bb0b47ec269ee91f31673
> > /home/acme/.debug/lib64/libc-2.12.so/5a7fad9dfcbb67af098a258bc2a20137cc954424
> > /lib64/libc-2.12.so
> > /usr/lib/debug/lib64/libc-2.12.so.debug
> > [acme@sandy linux]$
> > 
> > 	Only /lib64/libc-2.12.so is on the ld library path :-)
> > 
> > 	And after people really start depending on this tool for day to
> > day use, they may do like me:
> 
> But what if the /lib/libc.so.6 is around on the same machine to cater for 32
> bit apps and the user only wanted to trace 32 bit apps.
> 
> As you pointed out earlier, some user might have a text file by name
> libc in the current directory which he inadvertently could have given
> execute permissions. 

That case is covered by "if it is ambiguous, ask for more info".

But in the common case asking for "libc" should be really unambiguous.

Another example:

[root@sandy ~]# rpm -e glibc
error: "glibc" specifies multiple packages:
  glibc-2.12-1.47.el6_2.9.x86_64
  glibc-2.12-1.47.el6_2.9.i686
[root@sandy ~]# 

Oops, I better say which one, or use 'rpm --allmatches' to say that I
intend to remove all those glibc packages. 'perf probe' could act just
like that when ambiguities are found.

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
