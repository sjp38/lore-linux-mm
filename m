Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 291196B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 14:10:34 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 4so19657161pge.8
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 11:10:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor4721281pgo.244.2017.11.14.11.10.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 11:10:32 -0800 (PST)
Date: Tue, 14 Nov 2017 11:10:23 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 18/30] x86, kaiser: map virtually-addressed performance
 monitoring buffers
In-Reply-To: <30655167-963f-09e3-f88f-600bb95407e8@linux.intel.com>
Message-ID: <alpine.LSU.2.11.1711141057510.2433@eggly.anvils>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193139.B039E97B@viggo.jf.intel.com> <20171114182009.jbhobwxlkfjb2t6i@hirez.programming.kicks-ass.net> <30655167-963f-09e3-f88f-600bb95407e8@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, x86@kernel.org

On Tue, 14 Nov 2017, Dave Hansen wrote:
> On 11/14/2017 10:20 AM, Peter Zijlstra wrote:
> > On Fri, Nov 10, 2017 at 11:31:39AM -0800, Dave Hansen wrote:
> >>  static int alloc_ds_buffer(int cpu)
> >>  {
> >> +	struct debug_store *ds = per_cpu_ptr(&cpu_debug_store, cpu);
> >>  
> >> +	memset(ds, 0, sizeof(*ds));
> > Still wondering about that memset...

Sorry, my attention is far away at the moment.

> 
> My guess is that it was done to mirror the zeroing done by the original
> kzalloc().

You guess right.

> But, I think you're right that it's zero'd already by virtue
> of being static:
> 
> static
> DEFINE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(struct debug_store,
> cpu_debug_store);
> 
> I'll queue a cleanup, or update it if I re-post the set.

I was about to agree, but now I'm not so sure.  I don't know much
about these PMC things, but at a glance it looks like what is reserved
by x86_reserve_hardware() may later be released by x86_release_hardware(),
and then later reserved again by x86_reserve_hardware().  And although
the static per-cpu area would be zeroed the first time, the second time
it will contain data left over from before, so really needs the memset?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
