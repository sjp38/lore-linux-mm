Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id ED22D82F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 19:23:06 -0400 (EDT)
Received: by obbwb3 with SMTP id wb3so54736670obb.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:23:06 -0700 (PDT)
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com. [209.85.214.177])
        by mx.google.com with ESMTPS id g7si6881873obh.48.2015.10.21.16.23.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 16:23:06 -0700 (PDT)
Received: by obcqt19 with SMTP id qt19so54341963obc.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:23:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5627E348.4010702@sr71.net>
References: <20150916174913.AF5FEA6D@viggo.jf.intel.com> <20150920085554.GA21906@gmail.com>
 <55FF88BA.6080006@sr71.net> <20150924094956.GA30349@gmail.com>
 <56044A88.7030203@sr71.net> <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <CALCETrWaar55uTv5q3Ym1KEdQjfgjDfwMM=PPnjb9eV+ASS_ig@mail.gmail.com>
 <20151002062340.GB30051@gmail.com> <560EC3EC.2080803@sr71.net>
 <20151003072755.GA23524@gmail.com> <562113F0.6060307@sr71.net>
 <CALCETrWVyyAtKCNuNTVDKyTB6S3hRRe=Nma756ssvFxSVbNNig@mail.gmail.com> <5627E348.4010702@sr71.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 21 Oct 2015 16:22:46 -0700
Message-ID: <CALCETrXpADZOyKDKGgkC8x-Q25mOpFeWw-CzUYc8MhU5900=tQ@mail.gmail.com>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@google.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On Wed, Oct 21, 2015 at 12:11 PM, Dave Hansen <dave@sr71.net> wrote:
> On 10/21/2015 11:55 AM, Andy Lutomirski wrote:
>> On Fri, Oct 16, 2015 at 8:12 AM, Dave Hansen <dave@sr71.net> wrote:
>>> On 10/03/2015 12:27 AM, Ingo Molnar wrote:
>>>>  - Along similar considerations, also add a sys_pkey_query() system call to query
>>>>    the mapping of a specific pkey. (returns -EBADF or so if the key is not mapped
>>>>    at the moment.) This too could be vDSO accelerated in the future.
>>>>
>>>> I.e. something like:
>>>>
>>>>      unsigned long sys_pkey_alloc (unsigned long flags, unsigned long init_val)
>>>>      unsigned long sys_pkey_set   (int pkey, unsigned long new_val)
>>>>      unsigned long sys_pkey_get   (int pkey)
>>>>      unsigned long sys_pkey_free  (int pkey)
>>>
>>> The pkey_set() operation is going to get a wee bit interesting with signals.
>>>
>>> pkey_set() will modify the _current_ context's PKRU which includes the
>>> register itself and the kernel XSAVE buffer (if active).  But, since the
>>> PKRU state is saved/restored with the XSAVE state, we will blow away any
>>> state set during the signal.
>>>
>>> I _think_ the right move here is to either keep a 'shadow' version of
>>> PKRU inside the kernel (for each thread) and always update the task's
>>> XSAVE PKRU state when returning from a signal handler.  Or, _copy_ the
>>> signal's PKRU state in to the main process's PKRU state when returning
>>> from a signal.
>>
>> Ick.  Or we could just declare that signals don't affect the PKRU
>> state by default and mask it off in sigreturn.
>
> Yeah, I've been messing with it in a few forms and it's pretty ugly.
>
> I think it will be easier if we say the PKRU rights are not inherited by
> signals and changes during a signal are tossed out.  Signal handlers are
> special anyway and folks have to be careful writing them.

This is somewhat related to something I've been pondering in a
different context: fsbase and gsbase.

If a program changes fsbase using wrfsbase, should a signal handler
override it?  And should a change made in a signal handler carry over
after sigreturn?  Arguably, for fsbase and gsbase, the answer is no --
anyone use uses them for userspace threading (which is presumably why
they happened in the first place, even though userspace threading has
possibly dubious value) probably wants their context switches to stick
across signal invocations.

So I think that propagating PKRU into the signal handler and keeping
the in-register value on sigreturn by default is probably a reasonable
choice.

(OTOH, there's an argument for allowing programs to reset PKRU on
signal delivery: you could sort of arrange for signal handler to be
more privileged than the code that invokes them.  But that's doable
with some asm regardless.)

>
>> In fact, maybe we should add a general xfeature (or whatever it's
>> called these days) to the xstate in the signal context that controls
>> which pieces are restored.  Then user code can tweak it if needed in
>> signal handlers.
>
> Yeah, that's probably a good idea long-term.  We're only getting more
> and more things managed by XSAVE and it's going to be increasingly
> interesting to glue real semantics back on top.
>

Should we maybe extend copy_user_to_fpregs_zeroing to have a pair of
masks, where one mask indicates which features are copied and another
indicates which are preserved?  It looks like we already allow some
control over which bits are restored from sigcontext versus being
restored to their init state.

We might need to add some kind of extended ucontext area for this.  I
don't know if we're starting to run out of space.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
