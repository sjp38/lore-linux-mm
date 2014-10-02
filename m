Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2DC6B0070
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 12:00:44 -0400 (EDT)
Received: by mail-yk0-f172.google.com with SMTP id 19so1339928ykq.3
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 09:00:44 -0700 (PDT)
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
        by mx.google.com with ESMTPS id e48si6667524yho.212.2014.10.02.09.00.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Oct 2014 09:00:43 -0700 (PDT)
Received: by mail-yh0-f49.google.com with SMTP id a41so332846yho.22
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 09:00:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1409291443210.2800@eggly.anvils>
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org>
	<1411740233-28038-2-git-send-email-steve.capper@linaro.org>
	<alpine.LSU.2.11.1409291443210.2800@eggly.anvils>
Date: Thu, 2 Oct 2014 23:00:43 +0700
Message-ID: <CAPvkgC1RcgeraaUyHLs0qA=G-mMoNFEneypkvUiPWEjZWWExfA@mail.gmail.com>
Subject: Re: [PATCH V4 1/6] mm: Introduce a general RCU get_user_pages_fast.
From: Steve Capper <steve.capper@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Gary Robertson <gary.robertson@linaro.org>, Christoffer Dall <christoffer.dall@linaro.org>, Peter Zijlstra <peterz@infradead.org>, Anders Roxell <anders.roxell@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Mark Rutland <mark.rutland@arm.com>, Mel Gorman <mgorman@suse.de>

On 30 September 2014 04:51, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 26 Sep 2014, Steve Capper wrote:
>
>> get_user_pages_fast attempts to pin user pages by walking the page
>> tables directly and avoids taking locks. Thus the walker needs to be
>> protected from page table pages being freed from under it, and needs
>> to block any THP splits.
>>
>> One way to achieve this is to have the walker disable interrupts, and
>> rely on IPIs from the TLB flushing code blocking before the page table
>> pages are freed.
>>
>> On some platforms we have hardware broadcast of TLB invalidations, thus
>> the TLB flushing code doesn't necessarily need to broadcast IPIs; and
>> spuriously broadcasting IPIs can hurt system performance if done too
>> often.
>>
>> This problem has been solved on PowerPC and Sparc by batching up page
>> table pages belonging to more than one mm_user, then scheduling an
>> rcu_sched callback to free the pages. This RCU page table free logic
>> has been promoted to core code and is activated when one enables
>> HAVE_RCU_TABLE_FREE. Unfortunately, these architectures implement
>> their own get_user_pages_fast routines.
>>
>> The RCU page table free logic coupled with a an IPI broadcast on THP
>> split (which is a rare event), allows one to protect a page table
>> walker by merely disabling the interrupts during the walk.
>>
>> This patch provides a general RCU implementation of get_user_pages_fast
>> that can be used by architectures that perform hardware broadcast of
>> TLB invalidations.
>>
>> It is based heavily on the PowerPC implementation by Nick Piggin.
>>
>> Signed-off-by: Steve Capper <steve.capper@linaro.org>
>> Tested-by: Dann Frazier <dann.frazier@canonical.com>
>> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
>
> Acked-by: Hugh Dickins <hughd@google.com>
>

Thanks Hugh!

> Thanks for making all those clarifications, Steve: this looks very
> good to me now.  I'm not sure which tree you're hoping will take this
> and the arm+arm64 patches 2-6: although this one would normally go
> through akpm, I expect it's easier for you to synchronize if it goes
> in along with the arm+arm64 2-6 - would that be okay with you, Andrew?
> I see no clash with what's currently in mmotm.

I see it's gone into mmotm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
