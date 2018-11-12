Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7936B0003
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 17:56:12 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s123-v6so26789155qkf.12
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 14:56:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h22si3528773qtk.163.2018.11.12.14.56.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 14:56:11 -0800 (PST)
Subject: Re: [RFC PATCH 00/12] locking/lockdep: Add a new class of terminal
 locks
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <20181109080412.GC86700@gmail.com>
 <20181110141045.GD3339@worktop.programming.kicks-ass.net>
 <dfa0a2fa-0094-3ae0-4f27-2930233132a3@redhat.com>
 <20181112051033.GA123204@gmail.com> <20181112055324.f7div2ahx5emkbbe@treble>
 <20181112063050.GB61749@gmail.com> <20181112222250.h37hkrj6warqewkd@treble>
From: Waiman Long <longman@redhat.com>
Message-ID: <74a54ce2-e71c-d64a-af46-83eb840b96b8@redhat.com>
Date: Mon, 12 Nov 2018 14:56:09 -0800
MIME-Version: 1.0
In-Reply-To: <20181112222250.h37hkrj6warqewkd@treble>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 11/12/2018 02:22 PM, Josh Poimboeuf wrote:
> On Mon, Nov 12, 2018 at 07:30:50AM +0100, Ingo Molnar wrote:
>> * Josh Poimboeuf <jpoimboe@redhat.com> wrote:
>>
>>> On Mon, Nov 12, 2018 at 06:10:33AM +0100, Ingo Molnar wrote:
>>>> * Waiman Long <longman@redhat.com> wrote:
>>>>
>>>>> On 11/10/2018 09:10 AM, Peter Zijlstra wrote:
>>>>>> On Fri, Nov 09, 2018 at 09:04:12AM +0100, Ingo Molnar wrote:
>>>>>>> BTW., if you are interested in more radical approaches to optimize 
>>>>>>> lockdep, we could also add a static checker via objtool driven call graph 
>>>>>>> analysis, and mark those locks terminal that we can prove are terminal.
>>>>>>>
>>>>>>> This would require the unified call graph of the kernel image and of all 
>>>>>>> modules to be examined in a final pass, but that's within the principal 
>>>>>>> scope of objtool. (This 'final pass' could also be done during bootup, at 
>>>>>>> least in initial versions.)
>>>>>> Something like this is needed for objtool LTO support as well. I just
>>>>>> dread the build time 'regressions' this will introduce :/
>>>>>>
>>>>>> The final link pass is already by far the most expensive part (as
>>>>>> measured in wall-time) of building a kernel, adding more work there
>>>>>> would really suck :/
>>>>> I think the idea is to make objtool have the capability to do that. It
>>>>> doesn't mean we need to turn it on by default in every build.
>>>> Yeah.
>>>>
>>>> Also note that much of the objtool legwork would be on a per file basis 
>>>> which is reasonably parallelized already. On x86 it's also already done 
>>>> for every ORC build i.e. every distro build and the incremental overhead 
>>>> from also extracting locking dependencies should be reasonably small.
>>>>
>>>> The final search of the global graph would be serialized but still 
>>>> reasonably fast as these are all 'class' level dependencies which are 
>>>> much less numerous than runtime dependencies.
>>>>
>>>> I.e. I think we are talking about tens of thousands of dependencies, not 
>>>> tens of millions.
>>>>
>>>> At least in theory. ;-)
>>> Generating a unified call graph sounds very expensive (and very far
>>> beyond what objtool can do today).
>> Well, objtool already goes through the instruction stream and recognizes 
>> function calls - so it can in effect generate a stream of "function x 
>> called by function y" data, correct?
> Yeah, though it would be quite simple to get the same data with a simple
> awk script at link time.
>
>>>  Also, what about function pointers?
>> So maybe it's possible to enumerate all potential values for function 
>> pointers with a reasonably simple compiler plugin and work from there?
> I think this would be somewhere between very difficult and impossible to
> do properly.  I can't even imagine how this would be implemented in a
> compiler plugin.  But I'd love to be proven wrong on that.

I would say we have to assume for the worst when a function pointer is
being called while holding a lock unless we are able to find out all its
possible targets.

Cheers,
Longman
