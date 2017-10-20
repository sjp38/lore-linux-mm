Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E30F76B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 22:30:50 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q4so9761760oic.12
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:30:50 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id x73si4634551oif.0.2017.10.19.19.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 19:30:49 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/1] mm:hugetlbfs: Fix hwpoison reserve accounting
Date: Fri, 20 Oct 2017 02:30:20 +0000
Message-ID: <20171020023019.GA9318@hori1.linux.bs1.fc.nec.co.jp>
References: <20171019230007.17043-1-mike.kravetz@oracle.com>
 <20171019230007.17043-2-mike.kravetz@oracle.com>
In-Reply-To: <20171019230007.17043-2-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <089536352FB03D45AC41EAD2A70AC4DE@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Thu, Oct 19, 2017 at 04:00:07PM -0700, Mike Kravetz wrote:
> Calling madvise(MADV_HWPOISON) on a hugetlbfs page will result in
> bad (negative) reserved huge page counts.  This may not happen
> immediately, but may happen later when the underlying file is
> removed or filesystem unmounted.  For example:
> AnonHugePages:         0 kB
> ShmemHugePages:        0 kB
> HugePages_Total:       1
> HugePages_Free:        0
> HugePages_Rsvd:    18446744073709551615
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
>
> In routine hugetlbfs_error_remove_page(), hugetlb_fix_reserve_counts
> is called after remove_huge_page.  hugetlb_fix_reserve_counts is
> designed to only be called/used only if a failure is returned from
> hugetlb_unreserve_pages.  Therefore, call hugetlb_unreserve_pages
> as required and only call hugetlb_fix_reserve_counts in the unlikely
> event that hugetlb_unreserve_pages returns an error.

Hi Mike,

Thank you for addressing this. The patch itself looks good to me, but
the reported issue (negative reserve count) doesn't reproduce in my trial
with v4.14-rc5, so could you share the exact procedure for this issue?

When error handler runs over a huge page, the reserve count is incremented
so I'm not sure why the reserve count goes negative. My operation is like b=
elow:

  $ sysctl vm.nr_hugepages=3D10
  $ grep HugePages_ /proc/meminfo
  HugePages_Total:      10
  HugePages_Free:       10
  HugePages_Rsvd:        0
  HugePages_Surp:        0
  $ ./test_alloc_generic -B hugetlb_file -N1 -L "mmap access memory_error_i=
njection:error_type=3Dmadv_hard"  // allocate a 2MB file on hugetlbfs, then=
 madvise(MADV_HWPOISON) on it.
  $ grep HugePages_ /proc/meminfo
  HugePages_Total:      10
  HugePages_Free:        9
  HugePages_Rsvd:        1  // reserve count is incremented
  HugePages_Surp:        0
  $ rm work/hugetlbfs/testfile
  $ grep HugePages_ /proc/meminfo
  HugePages_Total:      10
  HugePages_Free:        9
  HugePages_Rsvd:        0  // reserve count is gone
  HugePages_Surp:        0
  $ /src/linux-dev/tools/vm/page-types -b hwpoison -x // unpoison the huge =
page
  $ grep HugePages_ /proc/meminfo
  HugePages_Total:      10
  HugePages_Free:       10  // all huge pages are free (back to the beginni=
ng)
  HugePages_Rsvd:        0
  HugePages_Surp:        0

Thanks,
Naoya Horiguchi

>
> Fixes: 78bb920344b8 ("mm: hwpoison: dissolve in-use hugepage in unrecover=
able memory error")
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  fs/hugetlbfs/inode.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 59073e9f01a4..ed113ea17aff 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -842,9 +842,12 @@ static int hugetlbfs_error_remove_page(struct addres=
s_space *mapping,
>  				struct page *page)
>  {
>  	struct inode *inode =3D mapping->host;
> +	pgoff_t index =3D page->index;
>
>  	remove_huge_page(page);
> -	hugetlb_fix_reserve_counts(inode);
> +	if (unlikely(hugetlb_unreserve_pages(inode, index, index + 1, 1)))
> +		hugetlb_fix_reserve_counts(inode);
> +
>  	return 0;
>  }
>
> --
> 2.13.6
>
>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
