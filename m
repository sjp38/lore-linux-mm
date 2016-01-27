Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE286B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 04:09:12 -0500 (EST)
Received: by mail-lb0-f177.google.com with SMTP id cl12so1494458lbc.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 01:09:12 -0800 (PST)
Received: from mail-lb0-x243.google.com (mail-lb0-x243.google.com. [2a00:1450:4010:c04::243])
        by mx.google.com with ESMTPS id f6si2670635lbc.137.2016.01.27.01.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 01:09:11 -0800 (PST)
Received: by mail-lb0-x243.google.com with SMTP id dx9so109750lbc.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 01:09:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160126144926.21d854fe53b76bd03e34b0d1@linux-foundation.org>
References: <145358234948.18573.2681359119037889087.stgit@zurg>
	<20160126144926.21d854fe53b76bd03e34b0d1@linux-foundation.org>
Date: Wed, 27 Jan 2016 12:09:10 +0300
Message-ID: <CALYGNiM-XNnXT+L+b=WLRVxrxii_oxXxY3Wu1PC8mvm_6W8wNw@mail.gmail.com>
Subject: Re: [PATCH v3] mm: warn about VmData over RLIMIT_DATA
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Kees Cook <keescook@google.com>, Willy Tarreau <w@1wt.eu>, Pavel Emelyanov <xemul@virtuozzo.com>

On Wed, Jan 27, 2016 at 1:49 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sat, 23 Jan 2016 23:52:29 +0300 Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>
>> This patch fixes 84638335900f ("mm: rework virtual memory accounting")
>
> uh, I think I'll rewrite this to
>
> : This patch provides a way of working around a slight regression introduced
> : by 84638335900f ("mm: rework virtual memory accounting").

Sure.

As you see I keept this in "ignore and warn" state by default.
During testing in linux-next it was able to cauch only small limits
like 0 in case of valgrind decause bug in pages/bytes units.
I think it's a bad idea to enfornce limit in the middle of merge window.
So let's change default to "block" in the next release.

>
>> Before that commit RLIMIT_DATA have control only over size of the brk region.
>> But that change have caused problems with all existing versions of valgrind,
>> because it set RLIMIT_DATA to zero.
>>
>> This patch fixes rlimit check (limit actually in bytes, not pages)
>> and by default turns it into warning which prints at first VmData misuse:
>> "mmap: top (795): VmData 516096 exceed data ulimit 512000. Will be forbidden soon."
>>
>> Behavior is controlled by boot param ignore_rlimit_data=y/n and by sysfs
>> /sys/module/kernel/parameters/ignore_rlimit_data. For now it set to "y".
>>
>>
>> ...
>>
>> +static inline bool is_data_mapping(vm_flags_t flags)
>> +{
>> +     return (flags & ((VM_STACK_FLAGS & (VM_GROWSUP | VM_GROWSDOWN)) |
>> +                                     VM_WRITE | VM_SHARED)) == VM_WRITE;
>> +}
>
> This (copied from existing code) hurts my brain.  We're saying "if it
> isn't stack and it's unshared and writable, it's data", yes?

Yes. Data vma supposed to be private, writable and without GROWSDOWN/UP.
We could make it more redable if define macro for stack growing direction.

Or redefine that data shouldn't grow in any direction and any growable
vma is a "stack",
but RLIMIT_STACK is enforced only in one direction (or not? not sure).
Anyway only few arches actually have flag VM_GROWSUP.

VM_WRITE separates Data and Code - Data can be executable, Code
should't be writable.
VM_GROWS separates Data and Stack - Stack grows automaticallly, Data is not.

Probaly stack should be writable too, but some applications  might
remaps pieces of stack as read-only.

For now (except parisc and metag)

VM_GROWSDOWN | VM_EXEC is a code
VM_GROWSDOWN | VM_EXEC | VM_WRITE is a stack
VM_GROWSUP | VM_EXEC | VM_WRITE is a data (for ia64)

And yes, this hurts my brain too. But much less than previous version
of accounting.

>
> hm.  I guess that's because with a shared mapping we don't know who to
> blame for the memory consumption so we blame nobody.  But what about
> non-shared read-only mappings?

I have no Idea. There's a lot stange combinations. But since VmData is
supposed to be limited with RLIMIT_DATA it safer to leave them alone.
User will see them in total VmSize and able to limit with RLIMIT_AS.

To be honest RLMIT_DATA cannot limit memory consumption at all.
RLIMIT_AS cannot do anything too: applicataion can keep any
amount of data in unlinked tmpfs file and mmap them as needed.
Only memory controller can solve this.

>
> Can we please have a comment here fully explaining the thinking?
>

Ok. I'll tie this together in a form of patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
