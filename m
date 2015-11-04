Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0EB82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 16:43:56 -0500 (EST)
Received: by oiww189 with SMTP id w189so12612711oiw.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 13:43:56 -0800 (PST)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id z126si1613563oiz.129.2015.11.04.13.43.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 13:43:55 -0800 (PST)
Received: by obdgf3 with SMTP id gf3so50738468obd.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 13:43:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151104200006.GA46783@kernel.org>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org> <20151104200006.GA46783@kernel.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 4 Nov 2015 13:43:35 -0800
Message-ID: <CALCETrVbdUc7owd=h-F0wjQvNBnDs1_Ux_O-Tum2GqkjQJ9MQw@mail.gmail.com>
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Ben Maurer <bmaurer@fb.com>

On Wed, Nov 4, 2015 at 12:00 PM, Shaohua Li <shli@kernel.org> wrote:
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

I can't speak to the usefulness of this or to other arches, but on x86
(unless you have nohz_full or similar enabled), a pair of syscalls
should be *much* faster than an IPI or a page fault.

I don't know how expensive it is to write to a clean page or to access
an unaccessed page on x86.  I'm sure it's not free (there's memory
bandwidth if nothing else), but it could be very cheap.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
