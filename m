Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 669B66B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 00:47:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r63so21505076pfb.7
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 21:47:31 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id n189si7859445pgn.110.2017.07.24.21.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 21:47:29 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id g69so3080614pfe.1
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 21:47:29 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v5 2/2] x86/mm: Improve TLB flush documentation
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <695299daa67239284e8db5a60d4d7eb88c914e0a.1500957502.git.luto@kernel.org>
Date: Mon, 24 Jul 2017 21:47:25 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <231630A0-21DB-4347-B126-F49AFD32B851@gmail.com>
References: <cover.1500957502.git.luto@kernel.org>
 <cover.1500957502.git.luto@kernel.org>
 <695299daa67239284e8db5a60d4d7eb88c914e0a.1500957502.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

Andy Lutomirski <luto@kernel.org> wrote:

> Improve comments as requested by PeterZ and also add some
> documentation at the top of the file.
>=20
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
> arch/x86/mm/tlb.c | 43 +++++++++++++++++++++++++++++++++----------
> 1 file changed, 33 insertions(+), 10 deletions(-)
>=20
> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index ce104b962a17..d4ee781ca656 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -15,17 +15,24 @@
> #include <linux/debugfs.h>
>=20
> /*
> - *	TLB flushing, formerly SMP-only
> - *		c/o Linus Torvalds.
> + * The code in this file handles mm switches and TLB flushes.
>  *
> - *	These mean you can really definitely utterly forget about
> - *	writing to user space from interrupts. (Its not allowed anyway).
> + * An mm's TLB state is logically represented by a totally ordered =
sequence
> + * of TLB flushes.  Each flush increments the mm's tlb_gen.
>  *
> - *	Optimizations Manfred Spraul <manfred@colorfullife.com>
> + * Each CPU that might have an mm in its TLB (and that might ever use
> + * those TLB entries) will have an entry for it in its =
cpu_tlbstate.ctxs
> + * array.  The kernel maintains the following invariant: for each CPU =
and
> + * for each mm in its cpu_tlbstate.ctxs array, the CPU has performed =
all
> + * flushes in that mms history up to the tlb_gen in cpu_tlbstate.ctxs
> + * or the CPU has performed an equivalent set of flushes.
>  *
> - *	More scalable flush, from Andi Kleen
> - *
> - *	Implement flush IPI by CALL_FUNCTION_VECTOR, Alex Shi
> + * For this purpose, an equivalent set is a set that is at least as =
strong.
> + * So, for example, if the flush history is a full flush at time 1,
> + * a full flush after time 1 is sufficient, but a full flush before =
time 1
> + * is not.  Similarly, any number of flushes can be replaced by a =
single
> + * full flush so long as that replacement flush is after all the =
flushes
> + * that it's replacing.
>  */
>=20
> atomic64_t last_mm_ctx_id =3D ATOMIC64_INIT(1);
> @@ -138,7 +145,16 @@ void switch_mm_irqs_off(struct mm_struct *prev, =
struct mm_struct *next,
> 			return;
> 		}
>=20
> -		/* Resume remote flushes and then read tlb_gen. */
> +		/*
> +		 * Resume remote flushes and then read tlb_gen.  The
> +		 * implied barrier in atomic64_read() synchronizes
> +		 * with inc_mm_tlb_gen() like this:

You mean the implied memory barrier in cpumask_set_cpu(), no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
