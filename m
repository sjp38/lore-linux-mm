Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD889003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 11:58:05 -0400 (EDT)
Received: by qgy5 with SMTP id 5so119443221qgy.3
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 08:58:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i35si6333179qgd.126.2015.07.23.08.58.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 08:58:04 -0700 (PDT)
Date: Thu, 23 Jul 2015 17:58:01 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
Message-ID: <20150723155801.GC23799@redhat.com>
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com>
 <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com>
 <CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com>
 <55B021B1.5020409@intel.com>
 <20150723104938.GA27052@e104818-lin.cambridge.arm.com>
 <20150723141303.GB23799@redhat.com>
 <55B0FD14.8050501@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55B0FD14.8050501@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jul 23, 2015 at 07:41:24AM -0700, Dave Hansen wrote:
> We had a discussion about this a few weeks ago:
> 
> 	https://lkml.org/lkml/2015/6/25/666
> 
> The argument is that the CPU is so good at refilling the TLB that it
> rarely waits on it, so the "cost" can be very very low.

That was about a new optimization adding more infrastructure to extend
these kind of optimizations, but the infrastructure has a cost so I'm
not sure this is relevant for this discussion, as there is not
infrastructure or overhead here.

If we were to do close to 33 invlpg it would be a gray area, but it's
just one.

I also refer to code that is already in the kernel:

   if (base_pages_to_flush > tlb_single_page_flush_ceiling) {

You wrote the patch that uses the tlb_single_page_flush_ceiling, so if
the above discussion would be relevant with regard to flush_tlb_page,
are you implying that the above optimization in the kernel, should
also be removed?

When these flush_tlb_range optimizations were introduced, it was
measured with benchmark that they helped IIRC. If it's not true
anymore with latest CPU I don't know but there should be at least a
subset of those CPUs where this helps. So I doubt it should be removed
for all CPUs out there.

Also if flush_tlb_page is slower on x86 (I doubt), then x86 should be
implement it without invlpg but for the common code it would still
make sense to use flush_tlb_page.

> On older CPUs we had dedicated 2M TLB slots.  Now, we have an STLB that
> can hold 2M and 4k entries at the same time.  That will surely change
> the performance profile enough that whatever testing we did in the past
> is fairly stale now.
> 
> I didn't mean mixing 4k and 2M mappings for the same virtual address.

Thanks for the clarification, got what you meant now.

I still can't see why flush_tlb_page isn't an obviously valid
optimization though.

The tlb_single_page_flush_ceiling optimization has nothing to do with
2MB pages. But if that is still valid (or if it has ever been valid
for older CPUs), why is flush_tlb_page not a valid optimization at
least for those older CPUS? Why is it worth doing single invalidates
on 4k pages and not on 2MB pages?

It surely was helpful to do invlpg invalidated on 4k pages, up to 33
in a row, with x86 CPUs as you wrote the code quoted above to do
that, and it is still in the current kernel. So why are 2MB pages
different?

I don't see a relation with this and the fact 2MB and 4KB TLB entries
aren't separated anymore. If something the fact the TLB can use the
same TLB entry for 2MB and 4KB pages, means doing invlpg on 2MB is
even more helpful with newer CPUs as there can be more 2MB TLB entries
to preserve than before. So I'm slightly confused now.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
