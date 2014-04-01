Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id C51866B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 11:13:32 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id im17so10203527vcb.9
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 08:13:32 -0700 (PDT)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id cb3si3691332vdc.5.2014.04.01.08.13.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 08:13:32 -0700 (PDT)
Received: by mail-vc0-f182.google.com with SMTP id ks9so9784164vcb.41
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 08:13:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140331113442.0d628362@annuminas.surriel.com>
References: <20140331113442.0d628362@annuminas.surriel.com>
Date: Tue, 1 Apr 2014 08:13:31 -0700
Message-ID: <CA+55aFzG=B3t_YaoCY_H1jmEgs+cYd--ZHz7XhGeforMRvNfEQ@mail.gmail.com>
Subject: Re: [PATCH] x86,mm: delay TLB flush after clearing accessed bit
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shli@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>

On Mon, Mar 31, 2014 at 8:34 AM, Rik van Riel <riel@redhat.com> wrote:
>
> However, clearing the accessed bit does not lead to any
> consistency issues, there is no reason to flush the TLB
> immediately. The TLB flush can be deferred until some
> later point in time.

Ugh. I absolutely detest this patch.

If we're going to leave the TLB dirty, then dammit, leave it dirty.
Don't play some half-way games.

Here's the patch you should just try:

 int ptep_clear_flush_young(struct vm_area_struct *vma,
        unsigned long address, pte_t *ptep)
 {
     return ptep_test_and_clear_young(vma, address, ptep);
 }

instead of complicating things.

Rationale: if the working set is so big that we start paging things
out, we sure as hell don't need to worry about TLB flushing. It will
flush itself.

And conversely - if it doesn't flush itself, and something stays
marked as "accessed" in the TLB for a long time even though we've
cleared it in the page tables, we don't care, because clearly there
isn't enough memory pressure for the accessed bit to matter.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
