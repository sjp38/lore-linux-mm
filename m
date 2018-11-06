Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5716E6B02A0
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 20:34:38 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id e3so7728656otd.22
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 17:34:38 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id v33si2716587otb.88.2018.11.05.17.34.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 17:34:37 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] hugetlbfs: fix kernel BUG at fs/hugetlbfs/inode.c:444!
Date: Tue, 6 Nov 2018 01:32:53 +0000
Message-ID: <20181106013253.GA23554@hori1.linux.bs1.fc.nec.co.jp>
References: <20181105212315.14125-1-mike.kravetz@oracle.com>
In-Reply-To: <20181105212315.14125-1-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4C75139DA4D603429C61FE4CB6ABE3DA@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Nov 05, 2018 at 01:23:15PM -0800, Mike Kravetz wrote:
> This bug has been experienced several times by Oracle DB team.
> The BUG is in the routine remove_inode_hugepages() as follows:
> 	/*
> 	 * If page is mapped, it was faulted in after being
> 	 * unmapped in caller.  Unmap (again) now after taking
> 	 * the fault mutex.  The mutex will prevent faults
> 	 * until we finish removing the page.
> 	 *
> 	 * This race can only happen in the hole punch case.
> 	 * Getting here in a truncate operation is a bug.
> 	 */
> 	if (unlikely(page_mapped(page))) {
> 		BUG_ON(truncate_op);
>=20
> In this case, the elevated map count is not the result of a race.
> Rather it was incorrectly incremented as the result of a bug in the
> huge pmd sharing code.  Consider the following:
> - Process A maps a hugetlbfs file of sufficient size and alignment
>   (PUD_SIZE) that a pmd page could be shared.
> - Process B maps the same hugetlbfs file with the same size and alignment
>   such that a pmd page is shared.
> - Process B then calls mprotect() to change protections for the mapping
>   with the shared pmd.  As a result, the pmd is 'unshared'.
> - Process B then calls mprotect() again to chage protections for the
>   mapping back to their original value.  pmd remains unshared.
> - Process B then forks and process C is created.  During the fork process=
,
>   we do dup_mm -> dup_mmap -> copy_page_range to copy page tables.  Copyi=
ng
>   page tables for hugetlb mappings is done in the routine
>   copy_hugetlb_page_range.
>=20
> In copy_hugetlb_page_range(), the destination pte is obtained by:
> 	dst_pte =3D huge_pte_alloc(dst, addr, sz);
> If pmd sharing is possible, the returned pointer will be to a pte in
> an existing page table.  In the situation above, process C could share
> with either process A or process B.  Since process A is first in the
> list, the returned pte is a pointer to a pte in process A's page table.
>=20
> However, the following check for pmd sharing is in copy_hugetlb_page_rang=
e.
> 	/* If the pagetables are shared don't copy or take references */
> 	if (dst_pte =3D=3D src_pte)
> 		continue;
>=20
> Since process C is sharing with process A instead of process B, the above
> test fails.  The code in copy_hugetlb_page_range which follows assumes
> dst_pte points to a huge_pte_none pte.  It copies the pte entry from
> src_pte to dst_pte and increments this map count of the associated page.
> This is how we end up with an elevated map count.
>=20
> To solve, check the dst_pte entry for huge_pte_none.  If !none, this
> implies PMD sharing so do not copy.
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=
