Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86DE36B02FD
	for <linux-mm@kvack.org>; Sun, 18 Jun 2017 04:06:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a82so77157840pfc.8
        for <linux-mm@kvack.org>; Sun, 18 Jun 2017 01:06:20 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id y2si6416638pli.466.2017.06.18.01.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Jun 2017 01:06:19 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id f127so11834585pgc.2
        for <linux-mm@kvack.org>; Sun, 18 Jun 2017 01:06:19 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v2 05/10] x86/mm: Rework lazy TLB mode and TLB freshness
 tracking
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <039935bc914009103fdaa6f72f14980c19562de5.1497415951.git.luto@kernel.org>
Date: Sun, 18 Jun 2017 01:06:15 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <515383DE-922D-4278-9FF6-AEF5445A0547@gmail.com>
References: <cover.1497415951.git.luto@kernel.org>
 <cover.1497415951.git.luto@kernel.org>
 <039935bc914009103fdaa6f72f14980c19562de5.1497415951.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>


> On Jun 13, 2017, at 9:56 PM, Andy Lutomirski <luto@kernel.org> wrote:
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
> Note to reviewers: this patch, my itself, looks a bit odd.  I'm
> using an array of length 1 containing (ctx_id, tlb_gen) rather than
> just storing tlb_gen, and making it at array isn't necessary yet.
> I'm doing this because the next few patches add PCID support, and,
> with PCID, we need ctx_id, and the array will end up with a length
> greater than 1.  Making it an array now means that there will be
> less churn and therefore less stress on your eyeballs.
>=20
> NB: This is dubious but, AFAICT, still correct on Xen and UV.
> xen_exit_mmap() uses mm_cpumask() for nefarious purposes and this
> patch changes the way that mm_cpumask() works.  This should be okay,
> since Xen *also* iterates all online CPUs to find all the CPUs it
> needs to twiddle.
>=20
> The UV tlbflush code is rather dated and should be changed.
>=20
> Cc: Andrew Banman <abanman@sgi.com>
> Cc: Mike Travis <travis@sgi.com>
> Cc: Dimitri Sivanich <sivanich@sgi.com>
> Cc: Juergen Gross <jgross@suse.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
> arch/x86/include/asm/mmu_context.h |   6 +-
> arch/x86/include/asm/tlbflush.h    |   4 -
> arch/x86/mm/init.c                 |   1 -
> arch/x86/mm/tlb.c                  | 242 =
+++++++++++++++++++------------------
> 4 files changed, 131 insertions(+), 122 deletions(-)
>=20
> diff --git a/arch/x86/include/asm/mmu_context.h =
b/arch/x86/include/asm/mmu_context.h
> index e5295d485899..69a4f1ee86ac 100644
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -125,8 +125,10 @@ static inline void switch_ldt(struct mm_struct =
*prev, struct mm_struct *next)
>=20
> static inline void enter_lazy_tlb(struct mm_struct *mm, struct =
task_struct *tsk)
> {
> -	if (this_cpu_read(cpu_tlbstate.state) =3D=3D TLBSTATE_OK)
> -		this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
> +	int cpu =3D smp_processor_id();
> +
> +	if (cpumask_test_cpu(cpu, mm_cpumask(mm)))
> +		cpumask_clear_cpu(cpu, mm_cpumask(mm));

The indication for laziness that was in cpu_tlbstate.state may be a =
better
indication whether the cpu needs to be cleared from the previous =
mm_cpumask().
If you kept this indication, you could have used this per-cpu =
information in
switch_mm_irqs_off() instead of "cpumask_test_cpu(cpu, =
mm_cpumask(next))=E2=80=9D,
which might have been accessed by another core.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
