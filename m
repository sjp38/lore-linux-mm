Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 89ED36B02F4
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 18:02:56 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id c189so74963981oia.13
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 15:02:56 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d204si2750319oif.169.2017.06.19.15.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 15:02:55 -0700 (PDT)
Received: from mail-vk0-f43.google.com (mail-vk0-f43.google.com [209.85.213.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1254B23A05
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 22:02:55 +0000 (UTC)
Received: by mail-vk0-f43.google.com with SMTP id y70so59918526vky.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 15:02:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <740B1D51-B801-48C9-A4C9-F31B34A09AEF@gmail.com>
References: <cover.1497415951.git.luto@kernel.org> <35264bd304c93f6d3cfff2329e3e01b084598ea1.1497415951.git.luto@kernel.org>
 <740B1D51-B801-48C9-A4C9-F31B34A09AEF@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 19 Jun 2017 15:02:33 -0700
Message-ID: <CALCETrV=v_4Ss4VSSW0CJFWCnr0Ks9c0K1W55wipOnL8sStOpg@mail.gmail.com>
Subject: Re: [PATCH v2 10/10] x86/mm: Try to preserve old TLB entries using PCID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Sat, Jun 17, 2017 at 11:26 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
>
>> On Jun 13, 2017, at 9:56 PM, Andy Lutomirski <luto@kernel.org> wrote:
>>
>> PCID is a "process context ID" -- it's what other architectures call
>> an address space ID.  Every non-global TLB entry is tagged with a
>> PCID, only TLB entries that match the currently selected PCID are
>> used, and we can switch PGDs without flushing the TLB.  x86's
>> PCID is 12 bits.
>>
>> This is an unorthodox approach to using PCID.  x86's PCID is far too
>> short to uniquely identify a process, and we can't even really
>> uniquely identify a running process because there are monster
>> systems with over 4096 CPUs.  To make matters worse, past attempts
>> to use all 12 PCID bits have resulted in slowdowns instead of
>> speedups.
>>
>> This patch uses PCID differently.  We use a PCID to identify a
>> recently-used mm on a per-cpu basis.  An mm has no fixed PCID
>> binding at all; instead, we give it a fresh PCID each time it's
>> loaded except in cases where we want to preserve the TLB, in which
>> case we reuse a recent value.
>>
>> In particular, we use PCIDs 1-3 for recently-used mms and we reserve
>> PCID 0 for swapper_pg_dir and for PCID-unaware CR3 users (e.g. EFI).
>> Nothing ever switches to PCID 0 without flushing PCID 0 non-global
>> pages, so PCID 0 conflicts won't cause problems.
>
> Is this commit message outdated?

Yes, it's old.  Will fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
