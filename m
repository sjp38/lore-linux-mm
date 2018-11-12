Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 857B66B0003
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 00:10:39 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id f3-v6so8109036wme.9
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 21:10:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s15-v6sor9607401wrn.35.2018.11.11.21.10.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Nov 2018 21:10:37 -0800 (PST)
Date: Mon, 12 Nov 2018 06:10:33 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH 00/12] locking/lockdep: Add a new class of terminal
 locks
Message-ID: <20181112051033.GA123204@gmail.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <20181109080412.GC86700@gmail.com>
 <20181110141045.GD3339@worktop.programming.kicks-ass.net>
 <dfa0a2fa-0094-3ae0-4f27-2930233132a3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dfa0a2fa-0094-3ae0-4f27-2930233132a3@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>


* Waiman Long <longman@redhat.com> wrote:

> On 11/10/2018 09:10 AM, Peter Zijlstra wrote:
> > On Fri, Nov 09, 2018 at 09:04:12AM +0100, Ingo Molnar wrote:
> >> BTW., if you are interested in more radical approaches to optimize 
> >> lockdep, we could also add a static checker via objtool driven call graph 
> >> analysis, and mark those locks terminal that we can prove are terminal.
> >>
> >> This would require the unified call graph of the kernel image and of all 
> >> modules to be examined in a final pass, but that's within the principal 
> >> scope of objtool. (This 'final pass' could also be done during bootup, at 
> >> least in initial versions.)
> >
> > Something like this is needed for objtool LTO support as well. I just
> > dread the build time 'regressions' this will introduce :/
> >
> > The final link pass is already by far the most expensive part (as
> > measured in wall-time) of building a kernel, adding more work there
> > would really suck :/
> 
> I think the idea is to make objtool have the capability to do that. It
> doesn't mean we need to turn it on by default in every build.

Yeah.

Also note that much of the objtool legwork would be on a per file basis 
which is reasonably parallelized already. On x86 it's also already done 
for every ORC build i.e. every distro build and the incremental overhead 
from also extracting locking dependencies should be reasonably small.

The final search of the global graph would be serialized but still 
reasonably fast as these are all 'class' level dependencies which are 
much less numerous than runtime dependencies.

I.e. I think we are talking about tens of thousands of dependencies, not 
tens of millions.

At least in theory. ;-)

Thanks,

	Ingo
