Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 72EF76B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 17:30:05 -0500 (EST)
Received: by iouu10 with SMTP id u10so26683180iou.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 14:30:05 -0800 (PST)
Received: from mail-ig0-x242.google.com (mail-ig0-x242.google.com. [2607:f8b0:4001:c05::242])
        by mx.google.com with ESMTPS id 21si787510ioq.82.2015.12.01.14.30.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 14:30:04 -0800 (PST)
Received: by igcgq6 with SMTP id gq6so2364449igc.3
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 14:30:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151104200006.GA46783@kernel.org>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
	<1446600367-7976-2-git-send-email-minchan@kernel.org>
	<20151104200006.GA46783@kernel.org>
Date: Tue, 1 Dec 2015 14:30:04 -0800
Message-ID: <CANcMJZB27S2DK_05WTfRAd40iacBr+hF0ivxAxh5Hs5eqaPyNA@mail.gmail.com>
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
From: John Stultz <john.stultz@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, bmaurer@fb.com

On Wed, Nov 4, 2015 at 12:00 PM, Shaohua Li <shli@kernel.org> wrote:
> Compared to MADV_DONTNEED, MADV_FREE's lazy memory free is a huge win to reduce
> page fault. But there is one issue remaining, the TLB flush. Both MADV_DONTNEED
> and MADV_FREE do TLB flush. TLB flush overhead is quite big in contemporary
> multi-thread applications. In our production workload, we observed 80% CPU
> spending on TLB flush triggered by jemalloc madvise(MADV_DONTNEED) sometimes.
> We haven't tested MADV_FREE yet, but the result should be similar. It's hard to
> avoid the TLB flush issue with MADV_FREE, because it helps avoid data
> corruption.
>
> The new proposal tries to fix the TLB issue. We introduce two madvise verbs:
>
> MARK_FREE. Userspace notifies kernel the memory range can be discarded. Kernel
> just records the range in current stage. Should memory pressure happen, page
> reclaim can free the memory directly regardless the pte state.
>
> MARK_NOFREE. Userspace notifies kernel the memory range will be reused soon.
> Kernel deletes the record and prevents page reclaim discards the memory. If the
> memory isn't reclaimed, userspace will access the old memory, otherwise do
> normal page fault handling.
>
> The point is to let userspace notify kernel if memory can be discarded, instead
> of depending on pte dirty bit used by MADV_FREE. With these, no TLB flush is
> required till page reclaim actually frees the memory (page reclaim need do the
> TLB flush for MADV_FREE too). It still preserves the lazy memory free merit of
> MADV_FREE.
>
> Compared to MADV_FREE, reusing memory with the new proposal isn't transparent,
> eg must call MARK_NOFREE. But it's easy to utilize the new API in jemalloc.
>
> We don't have code to backup this yet, sorry. We'd like to discuss it if it
> makes sense.

Sorry to be so slow to reply here!

As Minchan mentioned, this is very similar in concept to the volatile
ranges work Minchan and I tried to push for a few years.

Here's some of the coverage (in reverse chronological order)
https://lwn.net/Articles/602650/
https://lwn.net/Articles/592042/
https://lwn.net/Articles/590991/
http://permalink.gmane.org/gmane.linux.kernel.mm/98848
http://permalink.gmane.org/gmane.linux.kernel.mm/98676
https://lwn.net/Articles/522135/
https://lwn.net/Kernel/Index/#Volatile_ranges


If you are interested in reviving the patch set, I'd love to hear
about it. I think its a really compelling feature for kernel
right-sizing of userspace caches.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
