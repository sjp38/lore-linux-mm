Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B95EA6B0350
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 15:11:29 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o21so51473663qtb.13
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 12:11:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a7si12777144qkb.333.2017.06.06.12.11.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 12:11:28 -0700 (PDT)
Message-ID: <1496776285.20270.64.camel@redhat.com>
Subject: Re: [RFC 05/11] x86/mm: Rework lazy TLB mode and TLB freshness
 tracking
From: Rik van Riel <riel@redhat.com>
Date: Tue, 06 Jun 2017 15:11:25 -0400
In-Reply-To: <9b939d6218b78352b9f13594ebf97c1c88a6c33d.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
	 <9b939d6218b78352b9f13594ebf97c1c88a6c33d.1496701658.git.luto@kernel.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Ml6CMBFBx0n1aQSFac6r"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>


--=-Ml6CMBFBx0n1aQSFac6r
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2017-06-05 at 15:36 -0700, Andy Lutomirski wrote:

> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -122,8 +122,10 @@ static inline void switch_ldt(struct mm_struct
> *prev, struct mm_struct *next)
> =C2=A0
> =C2=A0static inline void enter_lazy_tlb(struct mm_struct *mm, struct
> task_struct *tsk)
> =C2=A0{
> -	if (this_cpu_read(cpu_tlbstate.state) =3D=3D TLBSTATE_OK)
> -		this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
> +	int cpu =3D smp_processor_id();
> +
> +	if (cpumask_test_cpu(cpu, mm_cpumask(mm)))
> +		cpumask_clear_cpu(cpu, mm_cpumask(mm));
> =C2=A0}

This is an atomic write to a shared cacheline,
every time a CPU goes idle.

I am not sure you really want to do this, since
there are some workloads out there that have a
crazy number of threads, which go idle hundreds,
or even thousands of times a second, on dozens
of CPUs at a time. *cough*Java*cough*

Keeping track of the state in a CPU-local variable,
written with a non-atomic write, would be much more
CPU cache friendly here.

--=20
All rights reversed
--=-Ml6CMBFBx0n1aQSFac6r
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZNv5dAAoJEM553pKExN6D0EQH/3CS75m/jGHxg579bPiR9SYi
4cOFq8VahPtpABSyLuBb2PeXxnm4LF0+8jSpm/d56Fx3JeYGmpar3EsNRr44TSCd
othzVHgZjujzTetPvrKqzCQRYxe5K83DkDk2iZta1xCr08HozvP4vy0ZsIUosbd5
nvEKGMUzlHV4aK9IYkwwARW8SCyk0sYcPTXhcoNmWtQILRuHxErXHw34KcfXPoM3
KquK2y2PPBT9wNqEbDYT86Gs2pFyTe+1DiOsnHMXw2SA4n1bxtGoDcMs08sSKSwE
4BHHdNYuCjPeBqjcTDx1yUY39QYjz9Hv1KhU8+YVYMtJd9Ca+4n26DVpBWiSvjQ=
=xqKu
-----END PGP SIGNATURE-----

--=-Ml6CMBFBx0n1aQSFac6r--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
