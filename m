Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC1816B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 01:39:36 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j66so235410804oib.2
        for <linux-mm@kvack.org>; Wed, 24 May 2017 22:39:36 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id o126si7474160oih.92.2017.05.24.22.39.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 22:39:35 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hugetlb: Report -EHWPOISON not -EFAULT when
 FOLL_HWPOISON is specified
Date: Thu, 25 May 2017 05:38:19 +0000
Message-ID: <20170525053817.GA27843@hori1.linux.bs1.fc.nec.co.jp>
References: <20170524160900.28786-1-james.morse@arm.com>
In-Reply-To: <20170524160900.28786-1-james.morse@arm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <177EAE37C1F0114689473F9A6D52C41A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Punit Agrawal <punit.agrawal@arm.com>

On Wed, May 24, 2017 at 05:09:00PM +0100, James Morse wrote:
> KVM uses get_user_pages() to resolve its stage2 faults. KVM sets the
> FOLL_HWPOISON flag causing faultin_page() to return -EHWPOISON when it
> finds a VM_FAULT_HWPOISON. KVM handles these hwpoison pages as a special
> case. (check_user_page_hwpoison())
>=20
> When huge pages are involved, this doesn't work so well. get_user_pages()
> calls follow_hugetlb_page(), which stops early if it receives
> VM_FAULT_HWPOISON from hugetlb_fault(), eventually returning -EFAULT to
> the caller. The step to map this to -EHWPOISON based on the FOLL_ flags
> is missing. The hwpoison special case is skipped, and -EFAULT is returned
> to user-space, causing Qemu or kvmtool to exit.
>=20
> Instead, move this VM_FAULT_ to errno mapping code into a header file
> and use it from faultin_page() and follow_hugetlb_page().
>=20
> With this, KVM works as expected.
>=20
> CC: Punit Agrawal <punit.agrawal@arm.com>
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
> This isn't a problem for arm64 today as we haven't enabled MEMORY_FAILURE=
,
> but I can't see any reason this doesn't happen on x86 too, so I think thi=
s
> should be a fix. This doesn't apply earlier than stable's v4.11.1 due to
> all sorts of cleanup. My best offer is:
> Cc: stable@vger.kernel.org # 4.11.1
>=20
>  include/linux/mm.h | 10 ++++++++++
>  mm/gup.c           |  9 +++------
>  mm/hugetlb.c       |  3 +++
>  3 files changed, 16 insertions(+), 6 deletions(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7cb17c6b97de..48b47c214c50 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2327,6 +2327,16 @@ static inline struct page *follow_page(struct vm_a=
rea_struct *vma,
>  #define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
>  #define FOLL_COW	0x4000	/* internal GUP flag */
> =20
> +static inline int vm_fault_to_errno(int vm_fault, int foll_flags) {

According to coding style, opening bracket should come with a new line.

> +	if (vm_fault & VM_FAULT_OOM)
> +		return -ENOMEM;
> +	if (vm_fault & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))
> +		return (foll_flags & FOLL_HWPOISON) ? -EHWPOISON : -EFAULT;
> +	if (vm_fault & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV))
> +		return -EFAULT;
> +	return 0;
> +}
> +

Can you apply this function to fixup_user_fault()?  fixup_user_fault()
now returns -EHWPOISON if handle_mm_fault returns VM_FAULT_HWPOISON*,
but I think there's no specific reason to choose EHWPOISON.
Callers of fixup_user_fault() have no interest in hwpoison code, and
they just use the return value to check success/failure (=3D=3D 0 or !=3D 0=
.)
So using vm_fault_to_errno(ret, 0) should be OK.

>  typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
>  			void *data);
>  extern int apply_to_page_range(struct mm_struct *mm, unsigned long addre=
ss,
> diff --git a/mm/gup.c b/mm/gup.c
> index d9e6fddcc51f..69f6cec279b3 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -407,12 +407,9 @@ static int faultin_page(struct task_struct *tsk, str=
uct vm_area_struct *vma,
> =20
>  	ret =3D handle_mm_fault(vma, address, fault_flags);
>  	if (ret & VM_FAULT_ERROR) {
> -		if (ret & VM_FAULT_OOM)
> -			return -ENOMEM;
> -		if (ret & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))
> -			return *flags & FOLL_HWPOISON ? -EHWPOISON : -EFAULT;
> -		if (ret & (VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV))
> -			return -EFAULT;
> +		int err =3D vm_fault_to_errno(ret, *flags);
> +		if (err)
> +			return err;
>  		BUG();
>  	}
> =20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e5828875f7bb..08f69dadbc63 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4170,7 +4170,10 @@ long follow_hugetlb_page(struct mm_struct *mm, str=
uct vm_area_struct *vma,
>  			}
>  			ret =3D hugetlb_fault(mm, vma, vaddr, fault_flags);
>  			if (ret & VM_FAULT_ERROR) {
> +				int err =3D vm_fault_to_errno(ret, flags);
>  				remainder =3D 0;
> +				if (err)
> +					return err;

(nitpick) checking err comes before remainder =3D 0 ?
# although compiler optimizes it by itself.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
