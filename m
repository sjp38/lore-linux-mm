Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 36AF59003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 13:13:36 -0400 (EDT)
Received: by qgii95 with SMTP id i95so89577273qgi.2
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 10:13:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p198si6618064qha.68.2015.07.23.10.13.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 10:13:35 -0700 (PDT)
Date: Thu, 23 Jul 2015 19:13:32 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
Message-ID: <20150723171332.GD23799@redhat.com>
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com>
 <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com>
 <CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com>
 <55B021B1.5020409@intel.com>
 <20150723104938.GA27052@e104818-lin.cambridge.arm.com>
 <20150723141303.GB23799@redhat.com>
 <55B0FD14.8050501@intel.com>
 <20150723161644.GG27052@e104818-lin.cambridge.arm.com>
 <55B11C85.5070900@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55B11C85.5070900@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jul 23, 2015 at 09:55:33AM -0700, Dave Hansen wrote:
> On 07/23/2015 09:16 AM, Catalin Marinas wrote:
> > Anyway, if you want to keep the option of a full TLB flush for x86 on
> > huge pages, I'm happy to repost a v2 with a separate
> > flush_tlb_pmd_huge_page that arch code can define as it sees fit.
> 
> I think your patch is fine on x86.  We need to keep an eye out for any
> regressions, but I think it's OK.

That's my view as well.

I've read more of the other thread and I quote Ingo:

" It barely makes sense for a 2 pages and gets exponentially
worse. It's probably done in microcode and its performance is
horrible. "

So in our case it's just 1 page (not 2, not 33), and considering it
prevents to invalidate all other TLB entries, it's most certainly a
win: it requires zero additional infrastructure and best of all it can
also avoid to flush the entire TLB for remote CPUs too again without
infrastructure or pfn arrays or multiple invlpg.

As further confirmation that for 1 entry invlpg is worth it, even
flush_tlb_page->flush_tlb_func invokes __flush_tlb_single in the IPI
handler instead of local_flush_tlb().

So the discussion there was about the additional infrastructure and a
flood of invlpg, perhaps more than 33, I agree a local_flush_tlb()
sounds better for that.

The question left for x86 is if invlpg is even slower for 2MB pages
than it is for 4k pages, but I'd be surprised if it is, especially on
newer CPUs where the TLB can use different page size for each TLB
entry. Why we didn't do flush_tlb_page before wasn't related to such a
concern at least.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
