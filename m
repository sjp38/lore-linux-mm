Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 79C496B0038
	for <linux-mm@kvack.org>; Sat,  7 Mar 2015 15:31:04 -0500 (EST)
Received: by igqa13 with SMTP id a13so11980989igq.0
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 12:31:04 -0800 (PST)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id e22si5448867ioi.40.2015.03.07.12.31.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Mar 2015 12:31:04 -0800 (PST)
Received: by iebtr6 with SMTP id tr6so20783549ieb.2
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 12:31:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1425741651-29152-2-git-send-email-mgorman@suse.de>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
	<1425741651-29152-2-git-send-email-mgorman@suse.de>
Date: Sat, 7 Mar 2015 12:31:03 -0800
Message-ID: <CA+55aFyCgzNGU-VAaKvwTYFhtJc_ugLK6hRzZBCxMYdAt5TVuA@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: thp: Return the correct value for change_huge_pmd
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Sat, Mar 7, 2015 at 7:20 AM, Mel Gorman <mgorman@suse.de> wrote:
>
>                 if (!prot_numa || !pmd_protnone(*pmd)) {
> -                       ret = 1;
>                         entry = pmdp_get_and_clear_notify(mm, addr, pmd);
>                         entry = pmd_modify(entry, newprot);
>                         ret = HPAGE_PMD_NR;

Hmm. I know I acked this already, but the return value - which correct
- is still potentially something we could improve upon.

In particular, we don't need to flush the TLB's if the old entry was
not present. Sadly, we don't have a helper function for that.

But the code *could* do something like

    entry = pmdp_get_and_clear_notify(mm, addr, pmd);
    ret = pmd_tlb_cacheable(entry) ? HPAGE_PMD_NR : 1;
    entry = pmd_modify(entry, newprot);

where pmd_tlb_cacheable() on x86 would test if _PAGE_PRESENT (bit #0) is set.

In particular, that would mean that as we change *from* a protnone
(whether NUMA or really protnone) we wouldn't need to flush the TLB.

In fact, we could make it even more aggressive: it's not just an old
non-present TLB entry that doesn't need flushing - we can avoid the
flushing whenever we strictly increase the access rigths. So we could
have something that takes the old entry _and_ the new protections into
account, and avoids the TLB flush if the new entry is strictly more
permissive.

This doesn't explain the extra TLB flushes Dave sees, though, because
the old code didn't make those kinds of optimizations either. But
maybe something like this is worth doing.

                            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
