Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57C22280553
	for <linux-mm@kvack.org>; Tue,  9 May 2017 08:43:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l64so56584183pfb.14
        for <linux-mm@kvack.org>; Tue, 09 May 2017 05:43:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id t141si13063391pgb.103.2017.05.09.05.43.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 05:43:31 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 3D1FA201BC
	for <linux-mm@kvack.org>; Tue,  9 May 2017 12:43:29 +0000 (UTC)
Received: from mail-ua0-f171.google.com (mail-ua0-f171.google.com [209.85.217.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2F23E20219
	for <linux-mm@kvack.org>; Tue,  9 May 2017 12:43:28 +0000 (UTC)
Received: by mail-ua0-f171.google.com with SMTP id j17so48579807uag.3
        for <linux-mm@kvack.org>; Tue, 09 May 2017 05:43:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <469C2BEE-5B6C-4351-8BC9-17796A072964@gmail.com>
References: <cover.1494160201.git.luto@kernel.org> <469C2BEE-5B6C-4351-8BC9-17796A072964@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 9 May 2017 05:43:06 -0700
Message-ID: <CALCETrVY5wGzVP-19iT6+qQZ7pxh2UEj5n1qfgwT=2k9rpAs0A@mail.gmail.com>
Subject: Re: [RFC 00/10] x86 TLB flush cleanups, moving toward PCID support
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, May 8, 2017 at 9:36 AM, Nadav Amit <nadav.amit@gmail.com> wrote:
>
>> On May 7, 2017, at 5:38 AM, Andy Lutomirski <luto@kernel.org> wrote:
>>
>> As I've been working on polishing my PCID code, a major problem I've
>> encountered is that there are too many x86 TLB flushing code paths and
>> that they have too many inconsequential differences.  The result was
>> that earlier versions of the PCID code were a colossal mess and very
>> difficult to understand.
>>
>> This series goes a long way toward cleaning up the mess.  With all the
>> patches applied, there is a single function that contains the meat of
>> the code to flush the TLB on a given CPU, and all the tlb flushing
>> APIs call it for both local and remote CPUs.
>>
>> This series should only adversely affect the kernel in a couple of
>> minor ways:
>>
>> - It makes smp_mb() unconditional when flushing TLBs.  We used to
>>   use the TLB flush itself to mostly avoid smp_mb() on the initiating
>>   CPU.
>>
>> - On UP kernels, we lose the dubious optimization of inlining nerfed
>>   variants of all the TLB flush APIs.  This bloats the kernel a tiny
>>   bit, although it should increase performance, since the SMP
>>   versions were better.
>>
>> Patch 10 in here is a little bit off topic.  It's a cleanup that's
>> also needed before PCID can go in, but it's not directly about
>> TLB flushing.
>>
>> Thoughts?
>
> In general I like the changes. I needed to hack Linux TLB shootdowns for
> a research project just because I could not handle the code otherwise.
> I ended up doing some of changes that you have done.
>
> I just have two general comments:
>
> - You may want to consider merging the kernel mappings invalidation
>   with the userspace mappings invalidations as well, since there are
>   still code redundancies.
>

Hmm.  The code for kernel mappings is quite short, and I'm not sure
how well it would fit in if I tried to merge it.

> - Don=E2=80=99t expect too much from concurrent TLB invalidations. In man=
y
>   cases the IPI latency dominates the overhead from my experience.
>

Fair enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
