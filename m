Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 26EBD6B0006
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 17:38:55 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u68so547566pfk.8
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 14:38:55 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w31-v6si15431570pla.315.2018.03.08.14.38.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 14:38:54 -0800 (PST)
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A52E4217A4
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 22:38:53 +0000 (UTC)
Received: by mail-io0-f170.google.com with SMTP id f1so1491937iob.0
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 14:38:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1520548101.2693.106.camel@hpe.com>
References: <87a7vi1f3h.fsf@kerf.amer.corp.natinst.com> <1520548101.2693.106.camel@hpe.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 8 Mar 2018 22:38:32 +0000
Message-ID: <CALCETrUB0brd92Tuv_cgakTgBo8yXxaAC1eLUMePMNsoWPK+mw@mail.gmail.com>
Subject: Re: Kernel page fault in vmalloc_fault() after a preempted ioremap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshi" <toshi.kani@hpe.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "gratian.crisan@ni.com" <gratian.crisan@ni.com>, "mingo@kernel.org" <mingo@kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "julia.cartwright@ni.com" <julia.cartwright@ni.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "bp@suse.de" <bp@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "brgerst@gmail.com" <brgerst@gmail.com>, "luto@kernel.org" <luto@kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "dvlasenk@redhat.com" <dvlasenk@redhat.com>, "gratian@gmail.com" <gratian@gmail.com>

On Thu, Mar 8, 2018 at 9:43 PM, Kani, Toshi <toshi.kani@hpe.com> wrote:
> On Thu, 2018-03-08 at 14:34 -0600, Gratian Crisan wrote:
>> Hi all,
>>
>> We are seeing kernel page faults happening on module loads with certain
>> drivers like the i915 video driver[1]. This was initially discovered on
>> a 4.9 PREEMPT_RT kernel. It takes 5 days on average to reproduce using a
>> simple reboot loop test. Looking at the code paths involved I believe
>> the issue is still present in the latest vanilla kernel.
>>
>> Some relevant points are:
>>
>>   * x86_64 CPU: Intel Atom E3940
>>
>>   * CONFIG_HUGETLBFS is not set (which also gates CONFIG_HUGETLB_PAGE)
>>
>> Based on function traces I was able to gather the sequence of events is:
>>
>>   1. Driver starts a ioremap operation for a region that is PMD_SIZE in
>>   size (or PUD_SIZE).
>>
>>   2. The ioremap() operation is preempted while it's in the middle of
>>   setting up the page mappings:
>>   ioremap_page_range->...->ioremap_pmd_range->pmd_set_huge <<preempted>>
>>
>>   3. Unrelated tasks run. Traces also include some cross core scheduling
>>   IPI calls.
>>
>>   4. Driver resumes execution finishes the ioremap operation and tries to
>>   access the newly mapped IO region. This triggers a vmalloc fault.
>>
>>   5. The vmalloc_fault() function hits a kernel page fault when trying to
>>   dereference a non-existent *pte_ref.
>>
>> The reason this happens is the code paths called from ioremap_page_range()
>> make different assumptions about when a large page (pud/pmd) mapping can be
>> used versus the code paths in vmalloc_fault().
>>
>> Using the PMD sized ioremap case as an example (the PUD case is similar):
>> ioremap_pmd_range() calls ioremap_pmd_enabled() which is gated by
>> CONFIG_HAVE_ARCH_HUGE_VMAP. On x86_64 this will return true unless the
>> "nohugeiomap" kernel boot parameter is passed in.
>>
>> On the other hand, in the rare case when a page fault happens in the
>> ioremap'ed region, vmalloc_fault() calls the pmd_huge() function to check
>> if a PMD page is marked huge or if it should go on and get a reference to
>> the PTE. However pmd_huge() is conditionally compiled based on the user
>> configured CONFIG_HUGETLB_PAGE selected by CONFIG_HUGETLBFS. If the
>> CONFIG_HUGETLBFS option is not enabled pmd_huge() is always defined to be
>> 0.
>>
>> The end result is an OOPS in vmalloc_fault() when the non-existent pte_ref
>> is dereferenced because the test for pmd_huge() failed.
>>
>> Commit f4eafd8bcd52 ("x86/mm: Fix vmalloc_fault() to handle large pages
>> properly") attempted to fix the mismatch between ioremap() and
>> vmalloc_fault() with regards to huge page handling but it missed this use
>> case.
>>
>> I am working on a simpler reproducing case however so far I've been
>> unsuccessful in re-creating the conditions that trigger the vmalloc fault
>> in the first place. Adding explicit scheduling points in
>> ioremap_pmd_range/pmd_set_huge doesn't seem to be sufficient. Ideas
>> appreciated.
>>
>> Any thoughts on what a correct fix would look like? Should the ioremap
>> code paths respect the HUGETLBFS config or would it be better for the
>> vmalloc fault code paths to match the tests used in ioremap and not rely
>> on the HUGETLBFS option being enabled?
>
> Thanks for the report and analysis!  I believe pud_large() and
> pmd_large() should have been used here.  I will try to reproduce the
> issue and verify the fix.

Indeed.  I find myself wondering why pud_huge() exists at all.

While you're at it, I think there may be more bugs in there.
Specifically, the code walks the reference and current tables at the
same time without any synchronization and without READ_ONCE()
protection.  I think that all of the BUG() calls below the comment:

        /*
         * Below here mismatches are bugs because these lower tables
         * are shared:
         */

are bogus and could be hit due to races.  I also think they're
pointless -- we've already asserted that the reference and loaded
tables are literally the same pointers.  I think the right fix is to
remove pud_ref, pmd_ref and pte_ref entirely and to get rid of those
BUG() calls.

What do you think?
