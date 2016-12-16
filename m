Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8C16B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:15:20 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id m67so61815747qkf.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 03:15:20 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l37si2922750qtl.48.2016.12.16.03.15.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 03:15:19 -0800 (PST)
Subject: Re: [PATCH 1/4] mm: add new mmgrab() helper
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216095624.GR3107@twins.programming.kicks-ass.net>
From: Vegard Nossum <vegard.nossum@oracle.com>
Message-ID: <9b9b09ac-f47a-3644-7d20-cc9d059a0b0d@oracle.com>
Date: Fri, 16 Dec 2016 12:14:40 +0100
MIME-Version: 1.0
In-Reply-To: <20161216095624.GR3107@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 12/16/2016 10:56 AM, Peter Zijlstra wrote:
> On Fri, Dec 16, 2016 at 09:21:59AM +0100, Vegard Nossum wrote:
>> Apart from adding the helper function itself, the rest of the kernel is
>> converted mechanically using:
>>
>>   git grep -l 'atomic_inc.*mm_count' | xargs sed -i 's/atomic_inc(&\(.*\)->mm_count);/mmgrab\(\1\);/'
>>   git grep -l 'atomic_inc.*mm_count' | xargs sed -i 's/atomic_inc(&\(.*\)\.mm_count);/mmgrab\(\&\1\);/'
>>
>> This is needed for a later patch that hooks into the helper, but might be
>> a worthwhile cleanup on its own.
>
> Given the desire to replace all refcounting with a specific refcount
> type, this seems to make sense.
>
> FYI: http://www.openwall.com/lists/kernel-hardening/2016/12/07/8

If we're going that way eventually (replacing all reference counting
things with a generic interface), I wonder if we shouldn't consider a
generic mechanism for reference counting debugging too.

We could wrap all the 'type *' + 'type_ref' occurrences in a struct, so
that with debugging it boils down to just a pointer (like we have now):

struct ref {
     void *ptr;
#ifdef CONFIG_REF_DEBUG
     /* list_entry, pid, stacktrace, etc. */
#endif
};

Instead of calling refcount_inc() in most of the kernel code, that would
be considered a low-level detail and you'd have the main interface be
something like:

void ref_acquire(refcount_t *count, struct ref *old, struct ref *new)
{
     refcount_inc(&count);
     new->ptr = old->ptr;
#ifdef CONFIG_REF_DEBUG
     /* extra code for debugging case */
#endif
}

So if you had old code that did (for example):

struct task_struct {
     struct mm_struct *mm;
     ...
};

int proc_pid_cmdline_read(struct task_struct *task)
{
     struct mm_struct *mm;

     task_lock(task);
     mm = task->mm;
     atomic_inc(&mm->mm_users);
     task_unlock(task);

     ...

     mmput(mm);
}

you'd instead have:

struct task_struct {
     struct ref mm;
};

int proc_pid_cmdline_read(struct task_struct *task)
{
     REF(mm);

     task_lock(task);
     ref_acquire(&mm->mm_users, &task->mm, &mm)
     task_unlock(task);

     ...

     ref_release(&mm->mm_users, &mm);
}

Of course you'd define a 'struct ref' per type using a macro or
something to keep it type safe (maybe even wrap the counter itself in
there, e.g. mm_users in the example above, so you wouldn't have to pass
it explicitly).

Functions that don't touch reference counts (because the caller holds
one) can just take a plain pointer as usual.

In the example above, you could also have ref_release() set mm->ptr =
NULL; as the pointer should not be considered usable after it has been
released anyway for added safety/debugability.

Best of both worlds?


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
