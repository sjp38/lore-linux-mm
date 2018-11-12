Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57F396B026E
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 01:30:55 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id f1-v6so8716965wrs.19
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 22:30:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a3-v6sor9794084wrv.9.2018.11.11.22.30.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Nov 2018 22:30:54 -0800 (PST)
Date: Mon, 12 Nov 2018 07:30:50 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH 00/12] locking/lockdep: Add a new class of terminal
 locks
Message-ID: <20181112063050.GB61749@gmail.com>
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <20181109080412.GC86700@gmail.com>
 <20181110141045.GD3339@worktop.programming.kicks-ass.net>
 <dfa0a2fa-0094-3ae0-4f27-2930233132a3@redhat.com>
 <20181112051033.GA123204@gmail.com>
 <20181112055324.f7div2ahx5emkbbe@treble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181112055324.f7div2ahx5emkbbe@treble>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>


* Josh Poimboeuf <jpoimboe@redhat.com> wrote:

> On Mon, Nov 12, 2018 at 06:10:33AM +0100, Ingo Molnar wrote:
> > 
> > * Waiman Long <longman@redhat.com> wrote:
> > 
> > > On 11/10/2018 09:10 AM, Peter Zijlstra wrote:
> > > > On Fri, Nov 09, 2018 at 09:04:12AM +0100, Ingo Molnar wrote:
> > > >> BTW., if you are interested in more radical approaches to optimize 
> > > >> lockdep, we could also add a static checker via objtool driven call graph 
> > > >> analysis, and mark those locks terminal that we can prove are terminal.
> > > >>
> > > >> This would require the unified call graph of the kernel image and of all 
> > > >> modules to be examined in a final pass, but that's within the principal 
> > > >> scope of objtool. (This 'final pass' could also be done during bootup, at 
> > > >> least in initial versions.)
> > > >
> > > > Something like this is needed for objtool LTO support as well. I just
> > > > dread the build time 'regressions' this will introduce :/
> > > >
> > > > The final link pass is already by far the most expensive part (as
> > > > measured in wall-time) of building a kernel, adding more work there
> > > > would really suck :/
> > > 
> > > I think the idea is to make objtool have the capability to do that. It
> > > doesn't mean we need to turn it on by default in every build.
> > 
> > Yeah.
> > 
> > Also note that much of the objtool legwork would be on a per file basis 
> > which is reasonably parallelized already. On x86 it's also already done 
> > for every ORC build i.e. every distro build and the incremental overhead 
> > from also extracting locking dependencies should be reasonably small.
> > 
> > The final search of the global graph would be serialized but still 
> > reasonably fast as these are all 'class' level dependencies which are 
> > much less numerous than runtime dependencies.
> > 
> > I.e. I think we are talking about tens of thousands of dependencies, not 
> > tens of millions.
> > 
> > At least in theory. ;-)
> 
> Generating a unified call graph sounds very expensive (and very far
> beyond what objtool can do today).

Well, objtool already goes through the instruction stream and recognizes 
function calls - so it can in effect generate a stream of "function x 
called by function y" data, correct?

>  Also, what about function pointers?

So maybe it's possible to enumerate all potential values for function 
pointers with a reasonably simple compiler plugin and work from there?

One complication would be function pointers encoded as opaque data 
types...

> BTW there's another kernel static analysis tool which attempts to 
> create such a call graph already: smatch.

It's not included in the kernel tree though and I'd expect tight coupling 
(or at least lock-step improvements) between tooling and lockdep here.

Thanks,

	Ingo
