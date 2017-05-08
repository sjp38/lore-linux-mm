Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 00E016B03CF
	for <linux-mm@kvack.org>; Mon,  8 May 2017 12:36:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f5so66909091pff.13
        for <linux-mm@kvack.org>; Mon, 08 May 2017 09:36:51 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id b35si13395995plh.80.2017.05.08.09.36.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 May 2017 09:36:51 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id s62so11390117pgc.0
        for <linux-mm@kvack.org>; Mon, 08 May 2017 09:36:50 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC 00/10] x86 TLB flush cleanups, moving toward PCID support
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <cover.1494160201.git.luto@kernel.org>
Date: Mon, 8 May 2017 09:36:47 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <469C2BEE-5B6C-4351-8BC9-17796A072964@gmail.com>
References: <cover.1494160201.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>


> On May 7, 2017, at 5:38 AM, Andy Lutomirski <luto@kernel.org> wrote:
>=20
> As I've been working on polishing my PCID code, a major problem I've
> encountered is that there are too many x86 TLB flushing code paths and
> that they have too many inconsequential differences.  The result was
> that earlier versions of the PCID code were a colossal mess and very
> difficult to understand.
>=20
> This series goes a long way toward cleaning up the mess.  With all the
> patches applied, there is a single function that contains the meat of
> the code to flush the TLB on a given CPU, and all the tlb flushing
> APIs call it for both local and remote CPUs.
>=20
> This series should only adversely affect the kernel in a couple of
> minor ways:
>=20
> - It makes smp_mb() unconditional when flushing TLBs.  We used to
>   use the TLB flush itself to mostly avoid smp_mb() on the initiating
>   CPU.
>=20
> - On UP kernels, we lose the dubious optimization of inlining nerfed
>   variants of all the TLB flush APIs.  This bloats the kernel a tiny
>   bit, although it should increase performance, since the SMP
>   versions were better.
>=20
> Patch 10 in here is a little bit off topic.  It's a cleanup that's
> also needed before PCID can go in, but it's not directly about
> TLB flushing.
>=20
> Thoughts?

In general I like the changes. I needed to hack Linux TLB shootdowns for
a research project just because I could not handle the code otherwise.
I ended up doing some of changes that you have done.

I just have two general comments:

- You may want to consider merging the kernel mappings invalidation
  with the userspace mappings invalidations as well, since there are
  still code redundancies.

- Don=E2=80=99t expect too much from concurrent TLB invalidations. In =
many
  cases the IPI latency dominates the overhead from my experience.

Regards,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
