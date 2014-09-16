Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id ADADE6B0035
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 17:01:17 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id r10so107804igi.16
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 14:01:17 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id qo6si2886375igb.23.2014.09.16.14.01.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 14:01:16 -0700 (PDT)
Received: by mail-ie0-f176.google.com with SMTP id ar1so465459iec.21
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 14:01:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140916205110.GA1273@potion.brq.redhat.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
	<54184078.4070505@redhat.com>
	<20140916205110.GA1273@potion.brq.redhat.com>
Date: Tue, 16 Sep 2014 14:01:15 -0700
Message-ID: <CAJu=L59f6ODMDOiKEGGSGg+0RhYw3FDy5D7AJcCOrHD5xL_iwQ@mail.gmail.com>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 16, 2014 at 1:51 PM, Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redha=
t.com> wrote:
> 2014-09-15 13:11-0700, Andres Lagar-Cavilla:
>> +int kvm_get_user_page_retry(struct task_struct *tsk, struct mm_struct *=
mm,
>
> The suffix '_retry' is not best suited for this.
> On first reading, I imagined we will be retrying something from before,
> possibly calling it in a loop, but we are actually doing the first and
> last try in one call.

We are doing ... the second and third in most scenarios. async_pf did
the first with _NOWAIT. We call this from the async pf retrier, or if
async pf couldn't be notified to the guest.

>
> Hard to find something that conveys our lock-dropping mechanic,
> '_polite' is my best candidate at the moment.

I'm at a loss towards finding a better name than '_retry'.

>
>> +     int flags =3D FOLL_TOUCH | FOLL_HWPOISON |
>
> (FOLL_HWPOISON wasn't used before, but it's harmless.)

Ok. Wasn't 100% sure TBH.

>
> 2014-09-16 15:51+0200, Paolo Bonzini:
>> Il 15/09/2014 22:11, Andres Lagar-Cavilla ha scritto:
>> > @@ -1177,9 +1210,15 @@ static int hva_to_pfn_slow(unsigned long addr, =
bool *async, bool write_fault,
>> >             npages =3D get_user_page_nowait(current, current->mm,
>> >                                           addr, write_fault, page);
>> >             up_read(&current->mm->mmap_sem);
>> > -   } else
>> > -           npages =3D get_user_pages_fast(addr, 1, write_fault,
>> > -                                        page);
>> > +   } else {
>> > +           /*
>> > +            * By now we have tried gup_fast, and possible async_pf, a=
nd we
>                                         ^
> (If we really tried get_user_pages_fast, we wouldn't be here, so I'd
>  prepend two underscores here as well.)

Yes, async pf tries and fails to do fast, and then we fallback to
slow, and so on.

>
>> > +            * are certainly not atomic. Time to retry the gup, allowi=
ng
>> > +            * mmap semaphore to be relinquished in the case of IO.
>> > +            */
>> > +           npages =3D kvm_get_user_page_retry(current, current->mm, a=
ddr,
>> > +                                            write_fault, page);
>>
>> This is a separate logical change.  Was this:
>>
>>       down_read(&mm->mmap_sem);
>>       npages =3D get_user_pages(NULL, mm, addr, 1, 1, 0, NULL, NULL);
>>       up_read(&mm->mmap_sem);
>>
>> the intention rather than get_user_pages_fast?
>
> I believe so as well.
>
> (Looking at get_user_pages_fast and __get_user_pages_fast made my
>  abstraction detector very sad.)

It's clunky, but a separate battle.

>
>> I think a first patch should introduce kvm_get_user_page_retry ("Retry a
>> fault after a gup with FOLL_NOWAIT.") and the second would add
>> FOLL_TRIED ("This properly relinquishes mmap semaphore if the
>> filemap/swap has to wait on page lock (and retries the gup to completion
>> after that").
>
> Not sure if that would help to understand the goal ...
>
>> Apart from this, the patch looks good.  The mm/ parts are minimal, so I
>> think it's best to merge it through the KVM tree with someone's Acked-by=
.
>
> I would prefer to have the last hunk in a separate patch, but still,
>
> Acked-by: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
Awesome, thanks much.

I'll recut with the VM_BUG_ON from Paolo and your Ack. LMK if anything
else from this email should go into the recut.

Andres


--=20
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
