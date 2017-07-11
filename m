Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 23C7C6B0513
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 11:01:14 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q4so142416oif.2
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 08:01:14 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f137si127292oib.237.2017.07.11.08.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 08:01:12 -0700 (PDT)
Received: from mail-vk0-f45.google.com (mail-vk0-f45.google.com [209.85.213.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 680A822C97
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:01:11 +0000 (UTC)
Received: by mail-vk0-f45.google.com with SMTP id 191so1396590vko.2
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 08:01:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170711113233.GA19177@codeblueprint.co.uk>
References: <cover.1498751203.git.luto@kernel.org> <20170630124422.GA12077@codeblueprint.co.uk>
 <20170711113233.GA19177@codeblueprint.co.uk>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 11 Jul 2017 08:00:47 -0700
Message-ID: <CALCETrVf87m6CRG3-m=i3wP5DyD5gfcMVJA4KDXb8TarCps2iA@mail.gmail.com>
Subject: Re: [PATCH v4 00/10] PCID and improved laziness
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jul 11, 2017 at 4:32 AM, Matt Fleming <matt@codeblueprint.co.uk> wrote:
> On Fri, 30 Jun, at 01:44:22PM, Matt Fleming wrote:
>> On Thu, 29 Jun, at 08:53:12AM, Andy Lutomirski wrote:
>> > *** Ingo, even if this misses 4.13, please apply the first patch before
>> > *** the merge window.
>> >
>> > There are three performance benefits here:
>> >
>> > 1. TLB flushing is slow.  (I.e. the flush itself takes a while.)
>> >    This avoids many of them when switching tasks by using PCID.  In
>> >    a stupid little benchmark I did, it saves about 100ns on my laptop
>> >    per context switch.  I'll try to improve that benchmark.
>> >
>> > 2. Mms that have been used recently on a given CPU might get to keep
>> >    their TLB entries alive across process switches with this patch
>> >    set.  TLB fills are pretty fast on modern CPUs, but they're even
>> >    faster when they don't happen.
>> >
>> > 3. Lazy TLB is way better.  We used to do two stupid things when we
>> >    ran kernel threads: we'd send IPIs to flush user contexts on their
>> >    CPUs and then we'd write to CR3 for no particular reason as an excuse
>> >    to stop further IPIs.  With this patch, we do neither.
>>
>> Heads up, I'm gonna queue this for a run on SUSE's performance test
>> grid.
>
> FWIW, I didn't see any change in performance with this series on a
> PCID-capable machine. On the plus side, I didn't see any weird-looking
> bugs either.
>
> Are your benchmarks available anywhere?

https://git.kernel.org/pub/scm/linux/kernel/git/luto/misc-tests.git/

I did:

$ ./context_switch_latency_64 0 process same

and

$ ./madvise_bounce_64 10k [IIRC -- it might have been a different loop count]

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
