Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B71EE6B02F4
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 18:01:14 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id v74so74873856oie.10
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 15:01:14 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u187si2740820oie.66.2017.06.19.15.01.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 15:01:13 -0700 (PDT)
Received: from mail-ua0-f182.google.com (mail-ua0-f182.google.com [209.85.217.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1DCAE239F2
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 22:01:13 +0000 (UTC)
Received: by mail-ua0-f182.google.com with SMTP id g40so67910102uaa.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 15:01:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1619e0d4-683d-c129-a132-383c7495d285@suse.com>
References: <cover.1497415951.git.luto@kernel.org> <039935bc914009103fdaa6f72f14980c19562de5.1497415951.git.luto@kernel.org>
 <1619e0d4-683d-c129-a132-383c7495d285@suse.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 19 Jun 2017 15:00:51 -0700
Message-ID: <CALCETrVV8103awgJhhHiJdVUFZHe2m0E8z-unkQzc739zUvPOQ@mail.gmail.com>
Subject: Re: [PATCH v2 05/10] x86/mm: Rework lazy TLB mode and TLB freshness tracking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Tue, Jun 13, 2017 at 11:09 PM, Juergen Gross <jgross@suse.com> wrote:
> On 14/06/17 06:56, Andy Lutomirski wrote:
>> x86's lazy TLB mode used to be fairly weak -- it would switch to
>> init_mm the first time it tried to flush a lazy TLB.  This meant an
>> unnecessary CR3 write and, if the flush was remote, an unnecessary
>> IPI.
>>
>> Rewrite it entirely.  When we enter lazy mode, we simply remove the
>> cpu from mm_cpumask.  This means that we need a way to figure out
>> whether we've missed a flush when we switch back out of lazy mode.
>> I use the tlb_gen machinery to track whether a context is up to
>> date.
>>
>> Note to reviewers: this patch, my itself, looks a bit odd.  I'm
>> using an array of length 1 containing (ctx_id, tlb_gen) rather than
>> just storing tlb_gen, and making it at array isn't necessary yet.
>> I'm doing this because the next few patches add PCID support, and,
>> with PCID, we need ctx_id, and the array will end up with a length
>> greater than 1.  Making it an array now means that there will be
>> less churn and therefore less stress on your eyeballs.
>>
>> NB: This is dubious but, AFAICT, still correct on Xen and UV.
>> xen_exit_mmap() uses mm_cpumask() for nefarious purposes and this
>> patch changes the way that mm_cpumask() works.  This should be okay,
>> since Xen *also* iterates all online CPUs to find all the CPUs it
>> needs to twiddle.
>
> There is a allocation failure path in xen_drop_mm_ref() which might
> be wrong with this patch. As this path should be taken only very
> unlikely I'd suggest to remove the test for mm_cpumask() bit zero in
> this path.
>

Right, fixed.

>
> Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
