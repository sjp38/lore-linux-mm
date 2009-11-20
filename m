Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 906176B00A3
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 04:02:28 -0500 (EST)
Date: Fri, 20 Nov 2009 10:01:34 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
Message-ID: <20091120090134.GD19778@elte.hu>
References: <4B064AF5.9060208@cn.fujitsu.com>
 <20091120081440.GA19778@elte.hu>
 <84144f020911200019p4978c8e8tc593334d974ee5ff@mail.gmail.com>
 <20091120083053.GB19778@elte.hu>
 <4B0657A4.2040606@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B0657A4.2040606@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> Ingo Molnar kirjoitti:
> >Regarding patch 2 - can we set some definitive benchmark threshold
> >for that? I.e. a list of must-have features in 'perf kmem' before
> >we can do it? 100% information and analysis equivalency with
> >kmemtrace-user tool?
> 
> I'd be interested to hear Eduard's comment on that.
> 
> That said, I'll try to find some time to test "perf kmem" and
> provide feedback on that. I can ACK the patch when I'm happy with
> the output. :-)
> 
> I'm mostly interested in two scenarios: (1) getting a nice report on
> worst fragmented call-sites (perf kmem needs symbol lookup) and (2)
> doing "perf kmem record" on machine A (think embedded here) and then
> "perf kmem report" on machine B. I haven't tried kmemtrace-user for
> a while but it did support both of them quite nicely at some point.

The perf.data can be copied over and to get off-side kernel symbol 
resolution you can specify the kernel vmlinux via -k/--vmlinux to perf 
report, then perf will look up the symbols from that vmlinux.

Cross word-size data files should work fine - cross-endian probably 
needs a few fixes.

Plus off-site user-space symbols need more work, right now we dont 
embedd them in the perf.data. It would need a symbol lookup + embedd-it 
pass in perf record (perhaps available as a separate 'perf archive' 
command as well), and some smarts on the reporting side to make use of 
them. (Probably a copy of all relevant DSOs is what works best - that 
enables off-site annotate as well.)

But ... even without that, perf is really fast and is supposed to build 
fine even in minimal (embedded) environments, so you can run it on the 
embedded board too. That's useful to get live inspection features like 
'perf top', 'perf stat' and 'perf probe' anyway.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
