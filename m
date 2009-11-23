Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A541D6B0044
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 01:51:22 -0500 (EST)
Date: Mon, 23 Nov 2009 07:51:10 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
Message-ID: <20091123065110.GC31758@elte.hu>
References: <4B064AF5.9060208@cn.fujitsu.com>
 <20091120081440.GA19778@elte.hu>
 <84144f020911200019p4978c8e8tc593334d974ee5ff@mail.gmail.com>
 <20091120083053.GB19778@elte.hu>
 <4B0657A4.2040606@cs.helsinki.fi>
 <4B06590C.7010109@cn.fujitsu.com>
 <20091120090353.GE19778@elte.hu>
 <20091120144215.GH18283@ghostprotocols.net>
 <20091120164110.GA24183@elte.hu>
 <20091120175228.GD27926@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091120175228.GD27926@ghostprotocols.net>
Sender: owner-linux-mm@kvack.org
To: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Arnaldo Carvalho de Melo <acme@infradead.org> wrote:

> Em Fri, Nov 20, 2009 at 05:41:10PM +0100, Ingo Molnar escreveu:
> > > So we have a mechanism that is already present in several distros
> > > (build-id), that is in the kernel build process since ~2.6.23, and that
> > > avoids using mismatching DSOs when resolving symbols.
> > 
> > But what do we do if we have another box that runs say on a MIPS CPU, 
> > uses some minimal distro - and copy that perf.data over to an x86 box.
> 
> There would be no problem, it would be just a matter of installing the
> right -debuginfo packages, for MIPS.

I havent tried this - is this really possible to do on an x86 box, with 
a typical distro? Can i install say Fedora PowerPC debuginfo packages on 
an x86 box, while also having the x86 debuginfo packages there?

> Or the original, unstripped FS image sent to the machine with the MIPS 
> cpu, if there aren't -debuginfo packages.
> 
> Either one, the right DSOs would be found by the buildids.
> 
> There are other scenarios, like a binary that gets updated while a long
> running perf record session runs, the way to differentiate between the
> two DSOs wouldn't be the name, but the buildid.
> 
> > The idea is there to be some new mode of perf.data where all the 
> > relevant DSO contents (symtabs but also sections with instructions for 
> > perf annotate to work) are copied into perf.data, during or after data 
> > capture - on the box that does the recording.
> > 
> > Once we have everything embedded in the perf.data, analysis passes only 
> > have to work based on that particular perf.data - no external data.
> 
> Well, we can that, additionally, but think about stripped binaries, we 
> would lose potentially a lot because the symtabs on that small machine 
> would have poorer symtabs than the ones in an unstriped binary (or in 
> a -debuginfo package).

We should definitely use the widest and best quality information we can 
- if it's available.

So even if we 'inline' any information from the box, if there's better 
info available at the time of analysis, we should use that too.

Basically what matters is the principle of 'what is possible'.

If a user records on a box and analyses on a different box, and we end 
up not doing something (and printing an error or displaying an empty 
profile) that could reasonably have been done, then the user will be 
unhappy and we might lose that user.

The user wont be unhappy about us using a big set of data sources that 
we can recover information from transparently. The user will be unhappy 
if we insist on (and force) a certain form of information source - such 
as debuginfo.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
