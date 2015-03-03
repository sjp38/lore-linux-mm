Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 772306B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 21:37:48 -0500 (EST)
Received: by iecrp18 with SMTP id rp18so53564062iec.1
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 18:37:48 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id h130si226007ioh.98.2015.03.02.18.37.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 18:37:48 -0800 (PST)
Received: by igal13 with SMTP id l13so22982423iga.5
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 18:37:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFw+7V9DfxBA2_DhMNrEQOkvdwjFFga5Y67-a6yVeAz+NQ@mail.gmail.com>
References: <20150302010413.GP4251@dastard>
	<CA+55aFzGFvVGD_8Y=jTkYwgmYgZnW0p0Fjf7OHFPRcL6Mz4HOw@mail.gmail.com>
	<20150303014733.GL18360@dastard>
	<CA+55aFw+7V9DfxBA2_DhMNrEQOkvdwjFFga5Y67-a6yVeAz+NQ@mail.gmail.com>
Date: Mon, 2 Mar 2015 18:37:47 -0800
Message-ID: <CA+55aFw+fb=Fh4M2wA4dVskgqN7PhZRGZS6JTMx4Rb1Qn++oaA@mail.gmail.com>
Subject: Re: [regression v4.0-rc1] mm: IPIs from TLB flushes causing
 significant performance degradation.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Matt B <jackdachef@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs@oss.sgi.com

On Mon, Mar 2, 2015 at 6:22 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> There might be some other case where the new "just change the
> protection" doesn't do the "oh, but it the protection didn't change,
> don't bother flushing". I don't see it.

Hmm. I wonder.. In change_pte_range(), we just unconditionally change
the protection bits.

But the old numa code used to do

    if (!pte_numa(oldpte)) {
        ptep_set_numa(mm, addr, pte);

so it would actually avoid the pte update if a numa-prot page was
marked numa-prot again.

But are those migrate-page calls really common enough to make these
things happen often enough on the same pages for this all to matter?

Odd.

So it would be good if your profiles just show "there's suddenly a
*lot* more calls to flush_tlb_page() from XYZ" and the culprit is
obvious that way..

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
