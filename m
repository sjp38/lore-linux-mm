Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8DC82BDC
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 17:50:31 -0400 (EDT)
Received: by mail-yh0-f52.google.com with SMTP id a41so3956447yho.25
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 14:50:30 -0700 (PDT)
Received: from mail-yh0-x230.google.com (mail-yh0-x230.google.com [2607:f8b0:4002:c01::230])
        by mx.google.com with ESMTPS id a6si3000594yha.175.2014.09.25.14.50.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 14:50:30 -0700 (PDT)
Received: by mail-yh0-f48.google.com with SMTP id t59so4435019yho.7
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 14:50:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140925211604.GA4590@redhat.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
	<1410976308-7683-1-git-send-email-andreslc@google.com>
	<20140925211604.GA4590@redhat.com>
Date: Thu, 25 Sep 2014 14:50:29 -0700
Message-ID: <CAJu=L581dk4d5AEPQU=zCU=wC6pu629k+p5KkmvgiS_7+cPUMA@mail.gmail.com>
Subject: Re: [PATCH v2] kvm: Faults which trigger IO release the mmap_sem
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

On Thu, Sep 25, 2014 at 2:16 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hi Andres,
>
> On Wed, Sep 17, 2014 at 10:51:48AM -0700, Andres Lagar-Cavilla wrote:
>> +     if (!locked) {
>> +             VM_BUG_ON(npages != -EBUSY);
>> +
>
> Shouldn't this be VM_BUG_ON(npages)?

Oh shoot you're right. I was confused by the introduction of -EBUSY in
the forward port.

        if (ret & VM_FAULT_RETRY) {
                if (nonblocking)
                        *nonblocking = 0;
                return -EBUSY;
        }

(gaaah!!!)

>
> Alternatively we could patch gup to do:
>
>                         case -EHWPOISON:
> +                       case -EBUSY:
>                                 return i ? i : ret;
> -                       case -EBUSY:
> -                               return i;
>

No preference. Not a lot of semantics available given that we pass 1
as the count to gup. Want to cut the patch or I can just shoot one
right away?

> I need to fix gup_fast slow path to start with FAULT_FLAG_ALLOW_RETRY
> similarly to what you did to the KVM slow path.
>
> gup_fast is called without the mmap_sem (incidentally its whole point
> is to only disable irqs and not take the locks) so the enabling of
> FAULT_FLAG_ALLOW_RETRY initial pass inside gup_fast should be all self
> contained. It shouldn't concern KVM which should be already fine with
> your patch, but it will allow the userfaultfd to intercept all
> O_DIRECT gup_fast in addition to KVM with your patch.
>
> Eventually get_user_pages should be obsoleted in favor of
> get_user_pages_locked (or whoever we decide to call it) so the
> userfaultfd can intercept all kind of gups. gup_locked is same as gup
> except for one more "locked" parameter at the end, I called the
> parameter locked instead of nonblocking because it'd be more proper to
> call "nonblocking" gup the FOLL_NOWAIT kind which is quite the
> opposite (in fact as the mmap_sem cannot be dropped in the non
> blocking version).
>

It's nearly impossible to name it right because 1) it indicates we can
relinquish 2) it returns whether we still hold the mmap semaphore.

I'd prefer it'd be called mmap_sem_hold, which conveys immediately
what this is about ("nonblocking" or "locked" could be about a whole
lot of things)

> ptrace ironically is better off sticking with a NULL locked parameter
> and to get a sigbus instead of risking hanging on the userfaultfd
> (which would be safe as it can be killed, but it'd be annoying if
> erroneously poking into a hole during a gdb session). It's still
> possible to pass NULL as parameter to get_user_pages_locked to achieve
> that. So the fact some callers won't block in handle_userfault because
> FAULT_FLAG_ALLOW_RETRY is not set and the userfault cannot block, may
> come handy.
>
> What I'm trying to solve in this context is that the userfault cannot
> safely block without FAULT_FLAG_ALLOW_RETRY because we can't allow
> userland to take the mmap_sem for an unlimited amount of time without
> requiring special privileges, so if handle_userfault wants to blocks
> within a gup invocation, it must first release the mmap_sem hence
> FAULT_FLAG_ALLOW_RETRY is always required at the first attempt for any
> virtual address.

I can see that. My background for coming into this is very similar: in
a previous life we had a file system shim that would kick up into
userspace for servicing VM memory. KVM just wouldn't let the file
system give up the mmap semaphore. We had /proc readers hanging up all
over the place while userspace was servicing. Not happy.

With KVM (now) and the standard x86 fault giving you ALLOW_RETRY, what
stands in your way? Methinks that gup_fast has no slowpath fallback
that turns on ALLOW_RETRY. What would oppose that being the global
behavior?

>
> With regard to the last sentence, there's actually a race with
> MADV_DONTNEED too, I'd need to change the code to always pass
> FAULT_FLAG_ALLOW_RETRY (your code also would need to loop and
> insisting with the __get_user_pages(locked) version to solve it). The
> KVM ioctl worst case would get an -EFAULT if the race materializes for
> example. It's non concerning though because that can be solved in
> userland somehow by separating ballooning and live migration
> activities.

Well, IIUC every code path that has ALLOW_RETRY dives in the second
time with FAULT_TRIED or similar. In the common case, you happily
blaze through the second time, but if someone raced in while all locks
were given up, one pays the price of the second time being a full
fault hogging the mmap sem. At some point you need to not keep being
polite otherwise the task starves. Presumably the risk of an extra
retry drops steeply every new gup retry. Maybe just try three times is
good enough. It makes for ugly logic though.

Thanks
Andres

>
> Thanks,
> Andrea



-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
