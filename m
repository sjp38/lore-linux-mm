Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 73A856B0292
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 01:03:27 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id y134so26704939itc.14
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 22:03:27 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id e70si10514873ioj.189.2017.06.05.22.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 22:03:26 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id d68so25712083ita.1
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 22:03:26 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC 04/11] x86/mm: Track the TLB's tlb_gen and update the
 flushing algorithm
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <fa028af2168f71ab55522eb19b320c167ba4678d.1496701658.git.luto@kernel.org>
Date: Mon, 5 Jun 2017 22:03:23 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <E1A42E76-A583-490F-9667-37A5CB4005E2@gmail.com>
References: <cover.1496701658.git.luto@kernel.org>
 <cover.1496701658.git.luto@kernel.org>
 <fa028af2168f71ab55522eb19b320c167ba4678d.1496701658.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

Maybe it=E2=80=99s me, but I find it rather hard to figure out whether
flush_tlb_func_common() is safe, since it can be re-entered - if a local =
TLB
flush is performed, and during this local flush a remote shootdown IPI =
is
received.

Did I miss irq being disabled during the local flush?

Otherwise, it raises the question whether flush_tlb_func_common() =
changes were
designed with re-entry in mind. Regarding it in the comments would =
really be
helpful.

Anyhow, I suspect that at least the following warning can be triggered:

	WARN_ON_ONCE(local_tlb_gen > mm_tlb_gen);


> static void flush_tlb_func_common(const struct flush_tlb_info *f,
> 				  bool local, enum tlb_flush_reason =
reason)
> {
> +	struct mm_struct *loaded_mm =3D =
this_cpu_read(cpu_tlbstate.loaded_mm);
> +
> +	/*
> +	 * Our memory ordering requirement is that any TLB fills that
> +	 * happen after we flush the TLB are ordered after we read
> +	 * active_mm's tlb_gen.  We don't need any explicit barrier
> +	 * because all x86 flush operations are serializing and the
> +	 * atomic64_read operation won't be reordered by the compiler.
> +	 */
> +	u64 mm_tlb_gen =3D atomic64_read(&loaded_mm->context.tlb_gen);

If for example a shootdown IPI can be delivered here...=20

> +	u64 local_tlb_gen =3D =
this_cpu_read(cpu_tlbstate.ctxs[0].tlb_gen);
> +


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
