Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9969B6B007E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 22:28:39 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id td3so54542495pab.2
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 19:28:39 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id tn1si4068757pab.54.2016.03.30.19.28.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Mar 2016 19:28:38 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 2/2] x86/hugetlb: Attempt PUD_SIZE mapping alignment
 if PMD sharing enabled
Date: Thu, 31 Mar 2016 02:26:56 +0000
Message-ID: <20160331022655.GA24293@hori1.linux.bs1.fc.nec.co.jp>
References: <1459213970-17957-1-git-send-email-mike.kravetz@oracle.com>
 <1459213970-17957-3-git-send-email-mike.kravetz@oracle.com>
 <20160329083510.GA27941@gmail.com> <56FAB5DB.8070003@oracle.com>
In-Reply-To: <56FAB5DB.8070003@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <9F368A9A34165248A39CDDA955E4A1B4@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Hugh Dickins <hughd@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@linaro.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Mar 29, 2016 at 10:05:31AM -0700, Mike Kravetz wrote:
> On 03/29/2016 01:35 AM, Ingo Molnar wrote:
> >=20
> > * Mike Kravetz <mike.kravetz@oracle.com> wrote:
> >=20
> >> When creating a hugetlb mapping, attempt PUD_SIZE alignment if the
> >> following conditions are met:
> >> - Address passed to mmap or shmat is NULL
> >> - The mapping is flaged as shared
> >> - The mapping is at least PUD_SIZE in length
> >> If a PUD_SIZE aligned mapping can not be created, then fall back to a
> >> huge page size mapping.
> >>
> >> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> >> ---
> >>  arch/x86/mm/hugetlbpage.c | 64 ++++++++++++++++++++++++++++++++++++++=
++++++---
> >>  1 file changed, 61 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> >> index 42982b2..4f53af5 100644
> >> --- a/arch/x86/mm/hugetlbpage.c
> >> +++ b/arch/x86/mm/hugetlbpage.c
> >> @@ -78,14 +78,39 @@ static unsigned long hugetlb_get_unmapped_area_bot=
tomup(struct file *file,
> >>  {
> >>  	struct hstate *h =3D hstate_file(file);
> >>  	struct vm_unmapped_area_info info;
> >> +	bool pud_size_align =3D false;
> >> +	unsigned long ret_addr;
> >> +
> >> +	/*
> >> +	 * If PMD sharing is enabled, align to PUD_SIZE to facilitate
> >> +	 * sharing.  Only attempt alignment if no address was passed in,
> >> +	 * flags indicate sharing and size is big enough.
> >> +	 */
> >> +	if (IS_ENABLED(CONFIG_ARCH_WANT_HUGE_PMD_SHARE) &&
> >> +	    !addr && flags & MAP_SHARED && len >=3D PUD_SIZE)
> >> +		pud_size_align =3D true;
> >> =20
> >>  	info.flags =3D 0;
> >>  	info.length =3D len;
> >>  	info.low_limit =3D current->mm->mmap_legacy_base;
> >>  	info.high_limit =3D TASK_SIZE;
> >> -	info.align_mask =3D PAGE_MASK & ~huge_page_mask(h);
> >> +	if (pud_size_align)
> >> +		info.align_mask =3D PAGE_MASK & (PUD_SIZE - 1);
> >> +	else
> >> +		info.align_mask =3D PAGE_MASK & ~huge_page_mask(h);
> >>  	info.align_offset =3D 0;
> >> -	return vm_unmapped_area(&info);
> >> +	ret_addr =3D vm_unmapped_area(&info);
> >> +
> >> +	/*
> >> +	 * If failed with PUD_SIZE alignment, try again with huge page
> >> +	 * size alignment.
> >> +	 */
> >> +	if ((ret_addr & ~PAGE_MASK) && pud_size_align) {
> >> +		info.align_mask =3D PAGE_MASK & ~huge_page_mask(h);
> >> +		ret_addr =3D vm_unmapped_area(&info);
> >> +	}
> >=20
> > So AFAICS 'ret_addr' is either page aligned, or is an error code. Would=
n't it be a=20
> > lot easier to read to say:
> >=20
> > 	if ((long)ret_addr > 0 && pud_size_align) {
> > 		info.align_mask =3D PAGE_MASK & ~huge_page_mask(h);
> > 		ret_addr =3D vm_unmapped_area(&info);
> > 	}
> >=20
> > 	return ret_addr;
> >=20
> > to make it clear that it's about error handling, not some alignment=20
> > requirement/restriction?
>=20
> Yes, I agree that is easier to read.  However, it assumes that process
> virtual addresses can never evaluate to a negative long value.  This may
> be the case for x86_64 today.  But, there are other architectures where
> this is not the case.  I know this is x86 specific code, but might it be
> possible that x86 virtual addresses could be negative longs in the future=
?
>=20
> It appears that all callers of vm_unmapped_area() are using the page alig=
ned
> check to determine error.   I would prefer to do the same, and can add
> comments to make that more clear.

IS_ERR_VALUE() might be helpful?=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
