Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3756B0372
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 00:44:18 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id 63so20388981otc.5
        for <linux-mm@kvack.org>; Sun, 18 Jun 2017 21:44:18 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q125si1713488oic.174.2017.06.18.21.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Jun 2017 21:44:17 -0700 (PDT)
Received: from mail-ua0-f178.google.com (mail-ua0-f178.google.com [209.85.217.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 43379239D4
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 04:44:16 +0000 (UTC)
Received: by mail-ua0-f178.google.com with SMTP id 68so52044428uas.0
        for <linux-mm@kvack.org>; Sun, 18 Jun 2017 21:44:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170618212948.mt33zbajt5n6saed@sasha-lappy>
References: <cover.1497415951.git.luto@kernel.org> <20170618212948.mt33zbajt5n6saed@sasha-lappy>
From: Andy Lutomirski <luto@kernel.org>
Date: Sun, 18 Jun 2017 21:43:54 -0700
Message-ID: <CALCETrVp9h5=PB6mu5_KZPKkj1YqpuYva=ncPxT0tfAgtA9Hdw@mail.gmail.com>
Subject: Re: [PATCH v2 00/10] PCID and improved laziness
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Cc: Andy Lutomirski <luto@kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Sun, Jun 18, 2017 at 2:29 PM, Levin, Alexander (Sasha Levin)
<alexander.levin@verizon.com> wrote:
> On Tue, Jun 13, 2017 at 09:56:18PM -0700, Andy Lutomirski wrote:
>>There are three performance benefits here:
>>
>>1. TLB flushing is slow.  (I.e. the flush itself takes a while.)
>>   This avoids many of them when switching tasks by using PCID.  In
>>   a stupid little benchmark I did, it saves about 100ns on my laptop
>>   per context switch.  I'll try to improve that benchmark.
>>
>>2. Mms that have been used recently on a given CPU might get to keep
>>   their TLB entries alive across process switches with this patch
>>   set.  TLB fills are pretty fast on modern CPUs, but they're even
>>   faster when they don't happen.
>>
>>3. Lazy TLB is way better.  We used to do two stupid things when we
>>   ran kernel threads: we'd send IPIs to flush user contexts on their
>>   CPUs and then we'd write to CR3 for no particular reason as an excuse
>>   to stop further IPIs.  With this patch, we do neither.
>>
>>This will, in general, perform suboptimally if paravirt TLB flushing
>>is in use (currently just Xen, I think, but Hyper-V is in the works).
>>The code is structured so we could fix it in one of two ways: we
>>could take a spinlock when touching the percpu state so we can update
>>it remotely after a paravirt flush, or we could be more careful about
>>our exactly how we access the state and use cmpxchg16b to do atomic
>>remote updates.  (On SMP systems without cmpxchg16b, we'd just skip
>>the optimization entirely.)
>
> Hey Andy,
>
> I've started seeing the following in -next:
>
> ------------[ cut here ]------------
> kernel BUG at arch/x86/mm/tlb.c:47!

...

> Call Trace:
>  flush_tlb_func_local arch/x86/mm/tlb.c:239 [inline]
>  flush_tlb_mm_range+0x26d/0x370 arch/x86/mm/tlb.c:317
>  flush_tlb_page arch/x86/include/asm/tlbflush.h:253 [inline]

I think I see what's going on, and it should be fixed in the PCID
series.  I'll split out the fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
