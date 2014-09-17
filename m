Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 364086B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 12:58:33 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id j7so2199264qaq.15
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 09:58:32 -0700 (PDT)
Received: from mail-qa0-x22d.google.com (mail-qa0-x22d.google.com [2607:f8b0:400d:c00::22d])
        by mx.google.com with ESMTPS id ik2si14731180qab.86.2014.09.17.09.58.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 09:58:32 -0700 (PDT)
Received: by mail-qa0-f45.google.com with SMTP id s7so2226978qap.4
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 09:58:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <54193BB2.8010500@redhat.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
	<54184078.4070505@redhat.com>
	<CAJu=L5_w+u6komiZB6RE1+9H5MiL+8RJBy_GYO6CmjqkhaG5Zg@mail.gmail.com>
	<54188179.7010705@redhat.com>
	<CAJu=L58z-=_KkZXpEiPjDUup8GpH7079HH39csmvgUxGkvXy0A@mail.gmail.com>
	<54193BB2.8010500@redhat.com>
Date: Wed, 17 Sep 2014 09:58:32 -0700
Message-ID: <CAJu=L5-_1ZDyhnMTFePRCyECr1rVLeMqR6dCDK1m6baR7J7gpw@mail.gmail.com>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 17, 2014 at 12:43 AM, Paolo Bonzini <pbonzini@redhat.com> wrote:
> Il 16/09/2014 20:42, Andres Lagar-Cavilla ha scritto:
>> On Tue, Sep 16, 2014 at 11:29 AM, Paolo Bonzini <pbonzini@redhat.com> wrote:
>>>>     I think a first patch should introduce kvm_get_user_page_retry ("Retry a
>>>>     fault after a gup with FOLL_NOWAIT.") and the second would add
>>>>     FOLL_TRIED ("This properly relinquishes mmap semaphore if the
>>>>     filemap/swap has to wait on page lock (and retries the gup to completion
>>>>     after that").
>>>>
>>>> That's not what FOLL_TRIED does. The relinquishing of mmap semaphore is
>>>> done by this patch minus the FOLL_TRIED bits. FOLL_TRIED will let the
>>>> fault handler (e.g. filemap) know that we've been there and waited on
>>>> the IO already, so in the common case we won't need to redo the IO.
>>>
>>> Yes, that's not what FOLL_TRIED does.  But it's the difference between
>>> get_user_pages and kvm_get_user_page_retry, right?
>>
>> Unfortunately get_user_pages does not expose the param (int
>> *nonblocking) that __gup will use to set FAULT_FLAG_ALLOW_RETRY. So
>> that's one difference. The second difference is that kvm_gup_retry
>> will call two times if necessary (the second without _RETRY but with
>> _TRIED).
>
> Yeah, that's how it is in your patch.  I can see that.
>
> What I'm saying is that your patch is two changes in one:
>
> 1) do not use gup_fast in hva_to_pfn_slow, instead use gup as in
> async_pf_execute.  This change can already introduce a function called
> kvm_get_user_page_retry, and can already use it in async_pf_execute and
> hva_to_pfn_slow
>
> 2) introduce the two-phase RETRY + TRIED mechanism in
> kvm_get_user_page_retry, so that the mmap semaphore is relinquished
> properly if the filemap or swap has to wait on the page lock.
>
> I would prefer to split it in two patches.  Is it clearer now?

Understood. So in patch 1, would kvm_gup_retry be ... just a wrapper
around gup? That looks thin to me, and the naming of the function will
not be accurate. Plus, considering Radim's suggestion that the naming
is not optimal.

I can have patch 1 just s/gup_fast/gup (one liner), and then patch 2
do the rest of the work.

Andres
>
> Paolo



-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
