Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 144B46B0055
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 14:36:24 -0400 (EDT)
Date: Tue, 24 Mar 2009 19:51:28 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 9/9] LTTng instrumentation - swap
Message-ID: <20090324185128.GJ31117@elte.hu>
References: <20090324155625.420966314@polymtl.ca> <20090324160149.188175023@polymtl.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090324160149.188175023@polymtl.ca>
Sender: owner-linux-mm@kvack.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, ltt-dev@lists.casi.polymtl.ca, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Masami Hiramatsu <mhiramat@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Frank Ch. Eigler" <fche@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>


* Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:

> +DECLARE_TRACE(swap_in,
> +	TPPROTO(struct page *page, swp_entry_t entry),
> +		TPARGS(page, entry));
> +DECLARE_TRACE(swap_out,
> +	TPPROTO(struct page *page),
> +		TPARGS(page));
> +DECLARE_TRACE(swap_file_open,
> +	TPPROTO(struct file *file, char *filename),
> +		TPARGS(file, filename));
> +DECLARE_TRACE(swap_file_close,
> +	TPPROTO(struct file *file),
> +		TPARGS(file));

These are more complete than the pagecache tracepoints, but still 
incomplete to make a comprehensive picture about swap activities.

Firstly, the swap_file_open/close events seem quite pointless. Most 
systems enable swap during bootup and never close it. These 
tracepoints just wont be excercised in practice.

Also, to _really_ help with debugging VM pressure problems, the 
whole LRU state-machine should be instrumented, and linked up with 
pagecache instrumentation via page frame numbers and (inode,offset) 
[file] and (pgd,addr) [anon] pairs.

Not just the fact that something got swapped out is interesting, but 
also the whole decision chain that leads up to it. The lifetime of a 
page how it jumps between the various stages of eviction and LRU 
scores.

a minor nit:

> +DECLARE_TRACE(swap_file_open,
> +	TPPROTO(struct file *file, char *filename),
> +		TPARGS(file, filename));

there's no need to pass in the filename - it can be deducted in the 
probe from struct file.

a small inconsistency:

> +DECLARE_TRACE(swap_in,
> +	TPPROTO(struct page *page, swp_entry_t entry),
> +		TPARGS(page, entry));
> +DECLARE_TRACE(swap_out,
> +	TPPROTO(struct page *page),
> +		TPARGS(page));

you pass in swp_entry to trace_swap_in(), which encodes the offset - 
but that parameter is not needed, the page already represents the 
offset at that stage in do_swap_page(). (the actual data is not read 
in yet from swap, but the page is already linked up in the 
swap-cache and has the offset available - which a probe can 
recover.)

So this suffices:

 DECLARE_TRACE(swap_in,
	TPPROTO(struct page *page),
		TPARGS(page));

 DECLARE_TRACE(swap_out,
	TPPROTO(struct page *page),
		TPARGS(page));

And here again i'd like to see actual meaningful probe contents via 
a TRACE_EVENT() construct. That shows and proves that it's all part 
of a comprehensive framework, and the data that is recovered is 
understood and put into a coherent whole - upstream. That makes it 
immediately useful to the built-in tracers, and will also cause 
fewer surprises downstream.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
