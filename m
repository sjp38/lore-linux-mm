Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id B3D4F6B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 14:42:19 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id l13so4059252iga.3
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 11:42:19 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id qo6si2547495igb.23.2014.09.16.11.42.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 11:42:18 -0700 (PDT)
Received: by mail-ig0-f173.google.com with SMTP id l13so6118260iga.6
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 11:42:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <54188179.7010705@redhat.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
	<54184078.4070505@redhat.com>
	<CAJu=L5_w+u6komiZB6RE1+9H5MiL+8RJBy_GYO6CmjqkhaG5Zg@mail.gmail.com>
	<54188179.7010705@redhat.com>
Date: Tue, 16 Sep 2014 11:42:17 -0700
Message-ID: <CAJu=L58z-=_KkZXpEiPjDUup8GpH7079HH39csmvgUxGkvXy0A@mail.gmail.com>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 16, 2014 at 11:29 AM, Paolo Bonzini <pbonzini@redhat.com> wrote:
> Il 16/09/2014 18:52, Andres Lagar-Cavilla ha scritto:
>> Was this:
>>
>>         down_read(&mm->mmap_sem);
>>         npages = get_user_pages(NULL, mm, addr, 1, 1, 0, NULL, NULL);
>>         up_read(&mm->mmap_sem);
>>
>> the intention rather than get_user_pages_fast?
>
> I meant the intention of the original author, not yours.

Yes, in all likelihood. I hope!

>
>> By that point in the call chain I felt comfortable dropping the _fast.
>> All paths that get there have already tried _fast (and some have tried
>> _NOWAIT).
>
> Yes, understood.
>
>>     I think a first patch should introduce kvm_get_user_page_retry ("Retry a
>>     fault after a gup with FOLL_NOWAIT.") and the second would add
>>     FOLL_TRIED ("This properly relinquishes mmap semaphore if the
>>     filemap/swap has to wait on page lock (and retries the gup to completion
>>     after that").
>>
>> That's not what FOLL_TRIED does. The relinquishing of mmap semaphore is
>> done by this patch minus the FOLL_TRIED bits. FOLL_TRIED will let the
>> fault handler (e.g. filemap) know that we've been there and waited on
>> the IO already, so in the common case we won't need to redo the IO.
>
> Yes, that's not what FOLL_TRIED does.  But it's the difference between
> get_user_pages and kvm_get_user_page_retry, right?

Unfortunately get_user_pages does not expose the param (int
*nonblocking) that __gup will use to set FAULT_FLAG_ALLOW_RETRY. So
that's one difference. The second difference is that kvm_gup_retry
will call two times if necessary (the second without _RETRY but with
_TRIED).

Thanks
Andres
>
> Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
