Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 101B06B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 21:22:30 -0500 (EST)
Received: by iecrl12 with SMTP id rl12so53381719iec.4
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 18:22:29 -0800 (PST)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com. [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id qc2si262339igb.27.2015.03.02.18.22.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 18:22:29 -0800 (PST)
Received: by iecvy18 with SMTP id vy18so53276960iec.13
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 18:22:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150303014733.GL18360@dastard>
References: <20150302010413.GP4251@dastard>
	<CA+55aFzGFvVGD_8Y=jTkYwgmYgZnW0p0Fjf7OHFPRcL6Mz4HOw@mail.gmail.com>
	<20150303014733.GL18360@dastard>
Date: Mon, 2 Mar 2015 18:22:29 -0800
Message-ID: <CA+55aFw+7V9DfxBA2_DhMNrEQOkvdwjFFga5Y67-a6yVeAz+NQ@mail.gmail.com>
Subject: Re: [regression v4.0-rc1] mm: IPIs from TLB flushes causing
 significant performance degradation.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Matt B <jackdachef@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs@oss.sgi.com

On Mon, Mar 2, 2015 at 5:47 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> Anyway, the difference between good and bad is pretty clear, so
> I'm pretty confident the bisect is solid:
>
> 4d9424669946532be754a6e116618dcb58430cb4 is the first bad commit

Well, it's the mm queue from Andrew, so I'm not surprised. That said,
I don't see why that particular one should matter.

Hmm. In your profiles, can you tell which caller of "flush_tlb_page()"
 changed the most? The change from "mknnuma" to "prot_none" *should*
be 100% equivalent (both just change the page to be not-present, just
set different bits elsewhere in the pte), but clearly something
wasn't.

Oh. Except for that special "huge-zero-page" special case that got
dropped, but that got re-introduced in commit e944fd67b625.

There might be some other case where the new "just change the
protection" doesn't do the "oh, but it the protection didn't change,
don't bother flushing". I don't see it.

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
