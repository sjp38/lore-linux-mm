Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6AD9003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 12:52:50 -0400 (EDT)
Received: by oihq81 with SMTP id q81so169594926oih.2
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 09:52:50 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id m3si13449665pdh.67.2015.07.23.09.52.49
        for <linux-mm@kvack.org>;
        Thu, 23 Jul 2015 09:52:49 -0700 (PDT)
Message-ID: <55B11BE1.3070903@intel.com>
Date: Thu, 23 Jul 2015 09:52:49 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com> <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com> <CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com> <55B021B1.5020409@intel.com> <20150723104938.GA27052@e104818-lin.cambridge.arm.com> <20150723141303.GB23799@redhat.com> <55B0FD14.8050501@intel.com> <20150723155801.GC23799@redhat.com>
In-Reply-To: <20150723155801.GC23799@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 07/23/2015 08:58 AM, Andrea Arcangeli wrote:
> You wrote the patch that uses the tlb_single_page_flush_ceiling, so if
> the above discussion would be relevant with regard to flush_tlb_page,
> are you implying that the above optimization in the kernel, should
> also be removed?

When I put that in, my goal was to bring consistency to how we handled
things without regressing anything.  I was never able to measure any
nice macro-level benefits to a particular flush behavior.

We can also now just easily disable the ranged flushes if we want to, or
leave them in place for small flushes only.

> When these flush_tlb_range optimizations were introduced, it was
> measured with benchmark that they helped IIRC. If it's not true
> anymore with latest CPU I don't know but there should be at least a
> subset of those CPUs where this helps. So I doubt it should be removed
> for all CPUs out there.

I tried to reproduce the results and had a difficult time doing so.

> The tlb_single_page_flush_ceiling optimization has nothing to do with
> 2MB pages. But if that is still valid (or if it has ever been valid
> for older CPUs), why is flush_tlb_page not a valid optimization at
> least for those older CPUS? Why is it worth doing single invalidates
> on 4k pages and not on 2MB pages?

I haven't seen any solid evidence that we should do it for one and not
the other.

> It surely was helpful to do invlpg invalidated on 4k pages, up to 33
> in a row, with x86 CPUs as you wrote the code quoted above to do
> that, and it is still in the current kernel. So why are 2MB pages
> different?

They were originally different because the work that introduced 'invlpg'
didn't see a benefit from using 'invlpg' on 2M pages.  I didn't
reevaluate it when I hacked on the code and just left it as it was.

It would be great if someone would go and collect some recent data on
using 'invlpg' on 2M pages!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
