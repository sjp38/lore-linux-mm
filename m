Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3B06B0382
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 01:48:15 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u8so106491477pgo.11
        for <linux-mm@kvack.org>; Sun, 18 Jun 2017 22:48:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t193si7520525pgc.360.2017.06.18.22.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Jun 2017 22:48:14 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5J5i1kf064275
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 01:48:14 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b5j9qnxt8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 01:48:14 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 19 Jun 2017 06:48:11 +0100
Date: Mon, 19 Jun 2017 07:48:01 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCHv2 1/3] x86/mm: Provide pmdp_establish() helper
In-Reply-To: <20170615145224.66200-2-kirill.shutemov@linux.intel.com>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
	<20170615145224.66200-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Message-Id: <20170619074801.18fa2a16@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S.
 Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter
 Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Thu, 15 Jun 2017 17:52:22 +0300
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> We need an atomic way to setup pmd page table entry, avoiding races with
> CPU setting dirty/accessed bits. This is required to implement
> pmdp_invalidate() that doesn't loose these bits.
>=20
> On PAE we have to use cmpxchg8b as we cannot assume what is value of new =
pmd and
> setting it up half-by-half can expose broken corrupted entry to CPU.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: H. Peter Anvin <hpa@zytor.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> ---
>  arch/x86/include/asm/pgtable-3level.h | 18 ++++++++++++++++++
>  arch/x86/include/asm/pgtable.h        | 14 ++++++++++++++
>  2 files changed, 32 insertions(+)
>=20
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtabl=
e.h
> index f5af95a0c6b8..a924fc6a96b9 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -1092,6 +1092,20 @@ static inline void pmdp_set_wrprotect(struct mm_st=
ruct *mm,
>  	clear_bit(_PAGE_BIT_RW, (unsigned long *)pmdp);
>  }
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
> +		return old;
> +	}
> +}
> +#endif
> +
>  /*
>   * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
>   *

For the s390 version of the pmdp_establish function we need the mm to be ab=
le
to do the TLB flush correctly. Can we please add a "struct vm_area_struct *=
vma"
argument to pmdp_establish analog to pmdp_invalidate?

The s390 patch would then look like this:
--
=46rom 4d4641249d5e826c21c522d149553e89d73fcd4f Mon Sep 17 00:00:00 2001
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Mon, 19 Jun 2017 07:40:11 +0200
Subject: [PATCH] s390/mm: add pmdp_establish

Define the pmdp_establish function to replace a pmd entry with a new
one and return the old value.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/include/asm/pgtable.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtabl=
e.h
index bb59a0aa3249..dedeecd5455c 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1511,6 +1511,13 @@ static inline void pmdp_invalidate(struct vm_area_st=
ruct *vma,
 	pmdp_xchg_direct(vma->vm_mm, addr, pmdp, __pmd(_SEGMENT_ENTRY_EMPTY));
 }
=20
+static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
+				   pmd_t *pmdp, pmd_t pmd)
+{
+	return pmdp_xchg_direct(vma->vm_mm, addr, pmdp, pmd);
+}
+#define pmdp_establish pmdp_establish
+
 #define __HAVE_ARCH_PMDP_SET_WRPROTECT
 static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 				      unsigned long addr, pmd_t *pmdp)
--=20
2.11.2


--=20
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
