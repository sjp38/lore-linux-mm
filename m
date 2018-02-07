Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id CFF6E6B02B2
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 20:16:30 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id g9so2166431otc.3
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 17:16:30 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 74si102120otn.114.2018.02.06.17.16.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 17:16:29 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB
 hugepage
Date: Wed, 7 Feb 2018 01:14:57 +0000
Message-ID: <20180207011455.GA15214@hori1.linux.bs1.fc.nec.co.jp>
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
 <1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87inbbjx2w.fsf@e105922-lin.cambridge.arm.com>
In-Reply-To: <87inbbjx2w.fsf@e105922-lin.cambridge.arm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6B62D0280E0A10418C5802502EDC15BD@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Punit,

On Mon, Feb 05, 2018 at 03:05:43PM +0000, Punit Agrawal wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
>=20
> > Recently the following BUG was reported:
> >
> >     Injecting memory failure for pfn 0x3c0000 at process virtual addres=
s 0x7fe300000000
> >     Memory failure: 0x3c0000: recovery action for huge page: Recovered
> >     BUG: unable to handle kernel paging request at ffff8dfcc0003000
> >     IP: gup_pgd_range+0x1f0/0xc20
> >     PGD 17ae72067 P4D 17ae72067 PUD 0
> >     Oops: 0000 [#1] SMP PTI
> >     ...
> >     CPU: 3 PID: 5467 Comm: hugetlb_1gb Not tainted 4.15.0-rc8-mm1-abc+ =
#3
> >     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-1=
.fc25 04/01/2014
> >
> > You can easily reproduce this by calling madvise(MADV_HWPOISON) twice o=
n
> > a 1GB hugepage. This happens because get_user_pages_fast() is not aware
> > of a migration entry on pud that was created in the 1st madvise() event=
.
>=20
> Maybe I'm doing something wrong but I wasn't able to reproduce the issue
> using the test at the end. I get -
>=20
>     $ sudo ./hugepage
>=20
>     Poisoning page...once
>     [  121.295771] Injecting memory failure for pfn 0x8300000 at process =
virtual address 0x400000000000
>     [  121.386450] Memory failure: 0x8300000: recovery action for huge pa=
ge: Recovered
>=20
>     Poisoning page...once again
>     madvise: Bad address
>=20
> What am I missing?

The test program below is exactly what I intended, so you did right testing=
.
I try to guess what could happen. The related code is like below:

  static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end=
,
                           int write, struct page **pages, int *nr)
  {
          ...
          do {
                  pud_t pud =3D READ_ONCE(*pudp);

                  next =3D pud_addr_end(addr, end);
                  if (pud_none(pud))
                          return 0;
                  if (unlikely(pud_huge(pud))) {
                          if (!gup_huge_pud(pud, pudp, addr, next, write,
                                            pages, nr))
                                  return 0;

pud_none() always returns false for hwpoison entry in any arch.
I guess that pud_huge() could behave in undefined manner for hwpoison entry
because pud_huge() assumes that a given pud has the present bit set, which
is not true for hwpoison entry. As a result, pud_huge() checks an irrelevan=
t
bit used for other purpose depending on non-present page table format of
each arch.
If pud_huge() returns false for hwpoison entry, we try to go to the lower
level and the kernel highly likely to crash. So I guess your kernel fell ba=
ck
the slow path and somehow ended up with returning EFAULT.

So I don't think that the above test result means that errors are properly
handled, and the proposed patch should help for arm64.

Thanks,
Naoya Horiguchi

>=20
>=20
> --------- >8 ---------
> #include <stdio.h>
> #include <string.h>
> #include <sys/mman.h>
>=20
> int main(int argc, char *argv[])
> {
> 	int flags =3D MAP_HUGETLB | MAP_ANONYMOUS | MAP_PRIVATE;
> 	int prot =3D PROT_READ | PROT_WRITE;
> 	size_t hugepage_sz;
> 	void *hugepage;
> 	int ret;
>=20
> 	hugepage_sz =3D 1024 * 1024 * 1024; /* 1GB */
> 	hugepage =3D mmap(NULL, hugepage_sz, prot, flags, -1, 0);
> 	if (hugepage =3D=3D MAP_FAILED) {
> 		perror("mmap");
> 		return 1;
> 	}
>=20
> 	memset(hugepage, 'b', hugepage_sz);
> 	getchar();
>=20
> 	printf("Poisoning page...once\n");
> 	ret =3D madvise(hugepage, hugepage_sz, MADV_HWPOISON);
> 	if (ret) {
> 		perror("madvise");
> 		return 1;
> 	}
> 	getchar();
>=20
> 	printf("Poisoning page...once again\n");
> 	ret =3D madvise(hugepage, hugepage_sz, MADV_HWPOISON);
> 	if (ret) {
> 		perror("madvise");
> 		return 1;
> 	}
> 	getchar();
>=20
> 	memset(hugepage, 'c', hugepage_sz);
> 	ret =3D munmap(hugepage, hugepage_sz);
> 	if (ret) {
> 		perror("munmap");
> 		return 1;
> 	}
> =09
> 	return 0;
> }
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
