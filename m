Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 2AB526B0068
	for <linux-mm@kvack.org>; Sun, 16 Dec 2012 12:53:06 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id gb23so6739608vcb.14
        for <linux-mm@kvack.org>; Sun, 16 Dec 2012 09:53:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121216090026.GB21690@gmail.com>
References: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
 <2e91ea19fbd30fa17718cb293473ae207ee8fd0f.1355536006.git.luto@amacapital.net> <20121216090026.GB21690@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 16 Dec 2012 09:52:44 -0800
Message-ID: <CALCETrX=3oQMKMNF2L3K7ur35KpeiqUN12RMq3XvtRChh9OJkg@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Downgrade mmap_sem before locking or populating on mmap
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, J??rn Engel <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, Dec 16, 2012 at 1:00 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Andy Lutomirski <luto@amacapital.net> wrote:
>
>> This is a serious cause of mmap_sem contention.  MAP_POPULATE
>> and MCL_FUTURE, in particular, are disastrous in multithreaded programs.
>>
>> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
>> ---
>>
>> Changes from v1:
>>
>> The non-unlocking versions of do_mmap_pgoff and mmap_region are still
>> available for aio_setup_ring's benefit.  In theory, aio_setup_ring
>> would do better with a lock-downgrading version, but that would be
>> somewhat ugly and doesn't help my workload.
>>
>>  arch/tile/mm/elf.c |  9 +++---
>>  fs/aio.c           |  4 +++
>>  include/linux/mm.h | 19 ++++++++++--
>>  ipc/shm.c          |  6 ++--
>>  mm/fremap.c        | 10 ++++--
>>  mm/mmap.c          | 89 ++++++++++++++++++++++++++++++++++++++++++++++++------
>>  mm/util.c          |  3 +-
>>  7 files changed, 117 insertions(+), 23 deletions(-)
>
>> +unsigned long mmap_region(struct file *file, unsigned long addr,
>> +                       unsigned long len, unsigned long flags,
>> +                       vm_flags_t vm_flags, unsigned long pgoff)
>> +{
>> +     return mmap_region_helper(file, addr, len, flags, vm_flags, pgoff, 0);
>> +}
>> +
>
> That 0 really wants to be NULL ...

Sigh.  I blame C++11 -- I wanted to type nullptr, but that's no good :)

>
> Also, with your patch applied there's no user of mmap_region()
> left anymore.
>
> More fundamentally, while I agree with the optimization,
> couldn't we de-uglify it a bit more?
>
> In particular, instead of this wrappery:
>
>> +unsigned long mmap_region_unlock(struct file *file, unsigned long addr,
>> +                              unsigned long len, unsigned long flags,
>> +                              vm_flags_t vm_flags, unsigned long pgoff)
>> +{
>> +     int downgraded = 0;
>> +     unsigned long ret = mmap_region_helper(file, addr, len,
>> +             flags, vm_flags, pgoff, &downgraded);
>> +
>> +     if (downgraded)
>> +             up_read(&current->mm->mmap_sem);
>> +     else
>> +             up_write(&current->mm->mmap_sem);
>> +
>> +     return ret;
>> +}
>
> 1)
>
> We could at minimum wrap up the conditional unlocking as:
>
>         up_read_write(&mm->mmap_sem, read_locked);
>
> With that I'd also suggest to rename 'downgraded' to
> 'read_locked', which more clearly expresses the locking state.
>
> 2)
>
> More aggressively, we could just make it the _rule_ that the mm
> lock gets downgraded to read in mmap_region_helper(), no matter
> what.
>
> From a quick look I *think* all the usage sites (including
> sys_aio_setup()) are fine with that unlocking - but I could be
> wrong.

They are.

>
> There's a couple of shorter codepaths that would now see an
> extra op of downgrading:
>
>         down_write(&mm->mmap_sem);
>         ...
>         downgrade_write(&mm->mmap_sem);
>         ...
>         up_read(&mm->mmap_sem);
>
> with not much work done with the lock read-locked - but I think
> they are all fine and mostly affect error paths. So there's no
> real value in keeping the conditional nature of the unlocking I
> think.

There's also the normal (i.e. neither lock nor populate) success path.
 Does this matter?  Presumably downgrade_write + up_read isn't much
slower than up_write.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
