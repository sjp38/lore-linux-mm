Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 512DC6B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 21:39:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a7so68641959pgn.7
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 18:39:27 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id z3si32657516pgo.59.2017.06.05.18.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 18:39:26 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id v14so7819118pgn.1
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 18:39:26 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC 05/11] x86/mm: Rework lazy TLB mode and TLB freshness
 tracking
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <9b939d6218b78352b9f13594ebf97c1c88a6c33d.1496701658.git.luto@kernel.org>
Date: Mon, 5 Jun 2017 18:39:22 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <C5EDE308-D2EA-490E-A76F-258E7B9A56E9@gmail.com>
References: <cover.1496701658.git.luto@kernel.org>
 <cover.1496701658.git.luto@kernel.org>
 <9b939d6218b78352b9f13594ebf97c1c88a6c33d.1496701658.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>


> On Jun 5, 2017, at 3:36 PM, Andy Lutomirski <luto@kernel.org> wrote:
>=20
> x86's lazy TLB mode used to be fairly weak -- it would switch to
> init_mm the first time it tried to flush a lazy TLB.  This meant an
> unnecessary CR3 write and, if the flush was remote, an unnecessary
> IPI.
>=20
> Rewrite it entirely.  When we enter lazy mode, we simply remove the
> cpu from mm_cpumask.  This means that we need a way to figure out
> whether we've missed a flush when we switch back out of lazy mode.
> I use the tlb_gen machinery to track whether a context is up to
> date.
>=20

[snip]

> @@ -67,133 +67,118 @@ void switch_mm_irqs_off(struct mm_struct *prev, =
struct mm_struct *next,
> {
>=20

[snip]

> +		/* Resume remote flushes and then read tlb_gen. */
> +		cpumask_set_cpu(cpu, mm_cpumask(next));
> +		next_tlb_gen =3D atomic64_read(&next->context.tlb_gen);

It seems correct, but it got me somewhat confused at first.

Perhaps it worth a comment that a memory barrier is not needed since
cpumask_set_cpu() uses a locked-instruction. Otherwise, somebody may
even copy-paste it to another architecture...

Thanks,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
