Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9119A6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:13:16 -0500 (EST)
Received: by vcbfo13 with SMTP id fo13so1765080vcb.14
        for <linux-mm@kvack.org>; Mon, 07 Nov 2011 08:13:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111107153220.GD3249@redhat.com>
References: <201111071221.35403.nai.xia@gmail.com>
	<20111107153220.GD3249@redhat.com>
Date: Tue, 8 Nov 2011 00:13:14 +0800
Message-ID: <CAPQyPG5bWCQ5TDau-s1DLv5zT0VN92+nv7+VHiPqgeGEum-f9w@mail.gmail.com>
Subject: Re: [PATCH] mremap: skip page table lookup for non-faulted anonymous VMAs
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Mon, Nov 7, 2011 at 11:32 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Mon, Nov 07, 2011 at 12:21:35PM +0800, Nai Xia wrote:
>> If an anonymous vma has not yet been faulted, move_page_tables() in move_vma()
>> is not necessary for it.
>
> I actually thought of adding that (in fact fork has it and it's more
> likely to be beneficial for fork than for mremap I suspect), but this
> adds a branch to the fast path for a case that shouldn't normally
> materialize. So I don't think it's worth adding it as I expect it to
> add overhead in average.
>

Well, it seems like I forgot to embrace it with unlikely(), with instr
prefetching  this line seems a trivial even for the average cases.

But in case it really materializes, it may avoid tedious page table
locking and pmd allocation and furthermore, a semantically
confusing operation of move_page_tables() on a same VMA.

Anyway, it's not a big deal, indeed. You are the maintainers,
it's left for you to decide.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
