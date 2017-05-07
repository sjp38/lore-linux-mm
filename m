Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB956B03AF
	for <linux-mm@kvack.org>; Sun,  7 May 2017 09:00:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l9so7108542wre.12
        for <linux-mm@kvack.org>; Sun, 07 May 2017 06:00:35 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id v23si11497011wra.152.2017.05.07.06.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 06:00:33 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id v42so4976011wrc.3
        for <linux-mm@kvack.org>; Sun, 07 May 2017 06:00:33 -0700 (PDT)
Date: Sun, 7 May 2017 15:00:30 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC 00/10] x86 TLB flush cleanups, moving toward PCID support
Message-ID: <20170507130030.tmoke7zsiz2iomsk@gmail.com>
References: <cover.1494160201.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>


* Andy Lutomirski <luto@kernel.org> wrote:

> As I've been working on polishing my PCID code, a major problem I've
> encountered is that there are too many x86 TLB flushing code paths and
> that they have too many inconsequential differences.  The result was
> that earlier versions of the PCID code were a colossal mess and very
> difficult to understand.
> 
> This series goes a long way toward cleaning up the mess.  With all the
> patches applied, there is a single function that contains the meat of
> the code to flush the TLB on a given CPU, and all the tlb flushing
> APIs call it for both local and remote CPUs.
> 
> This series should only adversely affect the kernel in a couple of
> minor ways:
> 
>  - It makes smp_mb() unconditional when flushing TLBs.  We used to
>    use the TLB flush itself to mostly avoid smp_mb() on the initiating
>    CPU.
> 
>  - On UP kernels, we lose the dubious optimization of inlining nerfed
>    variants of all the TLB flush APIs.  This bloats the kernel a tiny
>    bit, although it should increase performance, since the SMP
>    versions were better.
> 
> Patch 10 in here is a little bit off topic.  It's a cleanup that's
> also needed before PCID can go in, but it's not directly about
> TLB flushing.
> 
> Thoughts?

Looks really nifty! The diffstat alone appears to be worth it:

 18 files changed, 334 insertions(+), 408 deletions(-)

Will have a closer look next week.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
