Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 80C6A6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:48:32 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j65so7639168oib.1
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:48:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 18si549162otc.208.2017.06.14.15.48.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 15:48:31 -0700 (PDT)
Received: from mail-ua0-f171.google.com (mail-ua0-f171.google.com [209.85.217.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 09535239BE
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 22:48:31 +0000 (UTC)
Received: by mail-ua0-f171.google.com with SMTP id q15so9839037uaa.2
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:48:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <6da4aea9-ef52-694d-9a03-285c32018326@intel.com>
References: <cover.1497415951.git.luto@kernel.org> <6da4aea9-ef52-694d-9a03-285c32018326@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 14 Jun 2017 15:48:09 -0700
Message-ID: <CALCETrXT28SpE1SnYJNVOLadTaOKRYyQ2887BAU5S7X8YxS4ig@mail.gmail.com>
Subject: Re: [PATCH v2 00/10] PCID and improved laziness
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jun 14, 2017 at 3:18 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 06/13/2017 09:56 PM, Andy Lutomirski wrote:
>> 2. Mms that have been used recently on a given CPU might get to keep
>>    their TLB entries alive across process switches with this patch
>>    set.  TLB fills are pretty fast on modern CPUs, but they're even
>>    faster when they don't happen.
>
> Let's not forget that TLBs are also getting bigger.  The bigger TLBs
> help ensure that they *can* survive across another process's timeslice.
>
> Also, the cost to refill the paging structure caches is going up.  Just
> think of how many cachelines you have to pull in to populate a
> ~1500-entry TLB, even if the CPU hid the latency of those loads.

Then throw EPT into the mix for extra fun.  I wonder if we should try
to allocate page tables from nearby physical addresses if we think we
might be running as a guest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
