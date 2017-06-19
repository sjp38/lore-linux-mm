Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52CF26B0292
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 13:11:39 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d191so119684093pga.15
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 10:11:39 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id d7si515630plj.219.2017.06.19.10.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 10:11:38 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id f127so17083238pgc.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 10:11:38 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCHv2 1/3] x86/mm: Provide pmdp_establish() helper
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170615145224.66200-2-kirill.shutemov@linux.intel.com>
Date: Mon, 19 Jun 2017 10:11:35 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <D16802A9-161A-4074-A2C6-DCEA73E2E608@gmail.com>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> We need an atomic way to setup pmd page table entry, avoiding races =
with
> CPU setting dirty/accessed bits. This is required to implement
> pmdp_invalidate() that doesn't loose these bits.
>=20
> On PAE we have to use cmpxchg8b as we cannot assume what is value of =
new pmd and
> setting it up half-by-half can expose broken corrupted entry to CPU.

...

>=20
> +#ifndef pmdp_establish
> +#define pmdp_establish pmdp_establish
> +static inline pmd_t pmdp_establish(pmd_t *pmdp, pmd_t pmd)
> +{
> +	if (IS_ENABLED(CONFIG_SMP)) {
> +		return xchg(pmdp, pmd);
> +	} else {
> +		pmd_t old =3D *pmdp;
> +		*pmdp =3D pmd;

I think you may want to use WRITE_ONCE() here - otherwise nobody =
guarantees
that the compiler will not split writes to *pmdp. Although the kernel =
uses
similar code to setting PTEs and PMDs, I think that it is best to start
fixing it. Obviously, you might need a different code path for 32-bit
kernels.

Regards,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
