Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 459936B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 14:47:53 -0500 (EST)
Received: by iecrd18 with SMTP id rd18so50933288iec.5
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 11:47:53 -0800 (PST)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id s6si9449899igh.45.2015.03.02.11.47.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 11:47:52 -0800 (PST)
Received: by igkb16 with SMTP id b16so20409375igk.1
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 11:47:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150302010413.GP4251@dastard>
References: <20150302010413.GP4251@dastard>
Date: Mon, 2 Mar 2015 11:47:52 -0800
Message-ID: <CA+55aFzGFvVGD_8Y=jTkYwgmYgZnW0p0Fjf7OHFPRcL6Mz4HOw@mail.gmail.com>
Subject: Re: [regression v4.0-rc1] mm: IPIs from TLB flushes causing
 significant performance degradation.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Matt B <jackdachef@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs@oss.sgi.com

On Sun, Mar 1, 2015 at 5:04 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> Across the board the 4.0-rc1 numbers are much slower, and the
> degradation is far worse when using the large memory footprint
> configs. Perf points straight at the cause - this is from 4.0-rc1
> on the "-o bhash=101073" config:
>
> -   56.07%    56.07%  [kernel]            [k] default_send_IPI_mask_sequence_phys
>       - 99.99% physflat_send_IPI_mask
>          - 99.37% native_send_call_func_ipi
..
>
> And the same profile output from 3.19 shows:
>
> -    9.61%     9.61%  [kernel]            [k] default_send_IPI_mask_sequence_phys
>      - 99.98% physflat_send_IPI_mask
>          - 96.26% native_send_call_func_ipi
...
>
> So either there's been a massive increase in the number of IPIs
> being sent, or the cost per IPI have greatly increased. Either way,
> the result is a pretty significant performance degradatation.

And on Mon, Mar 2, 2015 at 11:17 AM, Matt <jackdachef@gmail.com> wrote:
>
> Linus already posted a fix to the problem, however I can't seem to
> find the matching commit in his tree (searching for "TLC regression"
> or "TLB cache").

That was commit f045bbb9fa1b, which was then refined by commit
721c21c17ab9, because it turned out that ARM64 had a very subtle
relationship with tlb->end and fullmm.

But both of those hit 3.19, so none of this should affect 4.0-rc1.
There's something else going on.

I assume it's the mm queue from Andrew, so adding him to the cc. There
are changes to the page migration etc, which could explain it.

There are also a fair amount of APIC changes in 4.0-rc1, so I guess it
really could be just that the IPI sending itself has gotten much
slower. Adding Ingo for that, although I don't think
default_send_IPI_mask_sequence_phys() itself hasn't actually changed,
only other things around the apic. So I'd be inclined to blame the mm
changes.

Obviously bisection would find it..

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
