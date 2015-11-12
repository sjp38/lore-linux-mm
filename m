Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id B31936B0253
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 23:50:18 -0500 (EST)
Received: by oiww189 with SMTP id w189so27159600oiw.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:50:18 -0800 (PST)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id wb3si6591309oeb.93.2015.11.11.20.50.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 20:50:18 -0800 (PST)
Received: by obdgf3 with SMTP id gf3so38589612obd.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:50:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1447302793-5376-2-git-send-email-minchan@kernel.org>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org> <1447302793-5376-2-git-send-email-minchan@kernel.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 11 Nov 2015 20:49:58 -0800
Message-ID: <CALCETrWA6aZC_3LPM3niN+2HFjGEm_65m9hiEdpBtEZMn0JhwQ@mail.gmail.com>
Subject: Re: [PATCH v3 01/17] mm: support madvise(MADV_FREE)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin wang <yalin.wang2010@gmail.com>

On Wed, Nov 11, 2015 at 8:32 PM, Minchan Kim <minchan@kernel.org> wrote:
>
> Linux doesn't have an ability to free pages lazy while other OS already
> have been supported that named by madvise(MADV_FREE).
>
> The gain is clear that kernel can discard freed pages rather than swapping
> out or OOM if memory pressure happens.


>
> When madvise syscall is called, VM clears dirty bit of ptes of the range.
> If memory pressure happens, VM checks dirty bit of page table and if it
> found still "clean", it means it's a "lazyfree pages" so VM could discard
> the page instead of swapping out.  Once there was store operation for the
> page before VM peek a page to reclaim, dirty bit is set so VM can swap out
> the page instead of discarding.
>

I realize that this lends itself to an efficient implementation, but
it's certainly the case that the kernel *could* use the accessed bit
instead of the dirty bit to give more sensible user semantics, and the
semantics that rely on the dirty bit make me uncomfortable from an ABI
perspective.

I also think that the kernel should commit to either zeroing the page
or leaving it unchanged in response to MADV_FREE (even if the decision
of which to do is made later on).  I think that your patch series does
this, but only after a few of the patches are applied (the swap entry
freeing), and I think that it should be a real guaranteed part of the
semantics and maybe have a test case.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
