Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id C5C7B6B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 12:11:44 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id q5so5495306wiv.4
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 09:11:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 43si28809267eer.207.2014.04.01.09.11.10
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 09:11:41 -0700 (PDT)
Message-ID: <533AE518.1090705@redhat.com>
Date: Tue, 01 Apr 2014 12:11:04 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86,mm: delay TLB flush after clearing accessed bit
References: <20140331113442.0d628362@annuminas.surriel.com> <CA+55aFzG=B3t_YaoCY_H1jmEgs+cYd--ZHz7XhGeforMRvNfEQ@mail.gmail.com>
In-Reply-To: <CA+55aFzG=B3t_YaoCY_H1jmEgs+cYd--ZHz7XhGeforMRvNfEQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shli@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>

On 04/01/2014 11:13 AM, Linus Torvalds wrote:
> On Mon, Mar 31, 2014 at 8:34 AM, Rik van Riel <riel@redhat.com> wrote:
>>
>> However, clearing the accessed bit does not lead to any
>> consistency issues, there is no reason to flush the TLB
>> immediately. The TLB flush can be deferred until some
>> later point in time.
> 
> Ugh. I absolutely detest this patch.
> 
> If we're going to leave the TLB dirty, then dammit, leave it dirty.
> Don't play some half-way games.
> 
> Here's the patch you should just try:
> 
>  int ptep_clear_flush_young(struct vm_area_struct *vma,
>         unsigned long address, pte_t *ptep)
>  {
>      return ptep_test_and_clear_young(vma, address, ptep);
>  }
> 
> instead of complicating things.
> 
> Rationale: if the working set is so big that we start paging things
> out, we sure as hell don't need to worry about TLB flushing. It will
> flush itself.
> 
> And conversely - if it doesn't flush itself, and something stays
> marked as "accessed" in the TLB for a long time even though we've
> cleared it in the page tables, we don't care, because clearly there
> isn't enough memory pressure for the accessed bit to matter.

That was my initial feeling too, when this kind of patch first
came up, a few years ago.

However, the more I think about it, the less I am convinced it
is actually true.

Memory pressure is not necessarily caused by the same process
whose accessed bit we just cleared. Memory pressure may not
even be caused by any process's virtual memory at all, but it
could be caused by the page cache.

With 2MB pages, a reasonably sized process could fit in the
TLB quite easily. Having its accessed bits not make it to the
page table while its pages are on the inactive list could
cause it to get paged out, due to memory pressure from another,
larger process.

I have no particular preference for this implementation, and am
willing to implement any other idea for batching the TLB shootdowns
that are due to pageout scanning.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
