Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5A2B6B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 03:34:54 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j126so17660247oib.9
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 00:34:54 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id e8si1947983oib.8.2017.10.23.00.34.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 00:34:53 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/1] mm:hugetlbfs: Fix hwpoison reserve accounting
Date: Mon, 23 Oct 2017 07:32:59 +0000
Message-ID: <20171023073258.GA5115@hori1.linux.bs1.fc.nec.co.jp>
References: <20171019230007.17043-1-mike.kravetz@oracle.com>
 <20171019230007.17043-2-mike.kravetz@oracle.com>
 <20171020023019.GA9318@hori1.linux.bs1.fc.nec.co.jp>
 <5016e528-8ea9-7597-3420-086ae57f3d9d@oracle.com>
In-Reply-To: <5016e528-8ea9-7597-3420-086ae57f3d9d@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <9757830B7DCA5644B8C854230E3B38EC@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Fri, Oct 20, 2017 at 10:49:46AM -0700, Mike Kravetz wrote:
> On 10/19/2017 07:30 PM, Naoya Horiguchi wrote:
> > On Thu, Oct 19, 2017 at 04:00:07PM -0700, Mike Kravetz wrote:
> >
> > Thank you for addressing this. The patch itself looks good to me, but
> > the reported issue (negative reserve count) doesn't reproduce in my tri=
al
> > with v4.14-rc5, so could you share the exact procedure for this issue?
>
> Sure, but first one question on your test scenario below.
>
> >
> > When error handler runs over a huge page, the reserve count is incremen=
ted
> > so I'm not sure why the reserve count goes negative.
>
> I'm not sure I follow.  What specific code is incrementing the reserve
> count?

The call path is like below:

  hugetlbfs_error_remove_page
    hugetlb_fix_reserve_counts
      hugepage_subpool_get_pages(spool, 1)
        hugetlb_acct_memory(h, 1);
          gather_surplus_pages
            h->resv_huge_pages +=3D delta;

>
> >                                                      My operation is li=
ke below:
> >
> >   $ sysctl vm.nr_hugepages=3D10
> >   $ grep HugePages_ /proc/meminfo
> >   HugePages_Total:      10
> >   HugePages_Free:       10
> >   HugePages_Rsvd:        0
> >   HugePages_Surp:        0
> >   $ ./test_alloc_generic -B hugetlb_file -N1 -L "mmap access memory_err=
or_injection:error_type=3Dmadv_hard"  // allocate a 2MB file on hugetlbfs, =
then madvise(MADV_HWPOISON) on it.
> >   $ grep HugePages_ /proc/meminfo
> >   HugePages_Total:      10
> >   HugePages_Free:        9
> >   HugePages_Rsvd:        1  // reserve count is incremented
> >   HugePages_Surp:        0
>
> This is confusing to me.  I can not create a test where there is a reserv=
e
> count after poisoning page.
>
> I tried to recreate your test.  Running unmodified 4.14.0-rc5.
>
> Before test
> -----------
> HugePages_Total:       1
> HugePages_Free:        1
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
>
> After open(creat) and mmap of 2MB hugetlbfs file
> ------------------------------------------------
> HugePages_Total:       1
> HugePages_Free:        1
> HugePages_Rsvd:        1
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
>
> Reserve count is 1 as expected/normal
>
> After madvise(MADV_HWPOISON) of the single huge page in mapping/file
> --------------------------------------------------------------------
> HugePages_Total:       1
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
>
> In this case, the reserve (and free) count were decremented.  Note that
> before the poison operation the page was not associated with the mapping/
> file.  I did not look closely at the code, but assume the madvise may
> cause the page to be 'faulted in'.
>
> The counts remain the same when the program exits
> -------------------------------------------------
> HugePages_Total:       1
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
>
> Remove the file (rm /var/opt/oracle/hugepool/foo)
> -------------------------------------------------
> HugePages_Total:       1
> HugePages_Free:        0
> HugePages_Rsvd:    18446744073709551615
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
>
> I am still confused about how your test maintains a reserve count after
> poisoning.  It may be a good idea for you to test my patch with your
> test scenario as I can not recreate here.

Interestingly, I found that this reproduces if all hugetlb pages are
reserved when poisoning.
Your testing meets the condition, and mine doesn't.

In gather_surplus_pages() we determine whether we extend hugetlb pool
with surplus pages like below:

    needed =3D (h->resv_huge_pages + delta) - h->free_huge_pages;
    if (needed <=3D 0) {
            h->resv_huge_pages +=3D delta;
            return 0;
    }
    ...

needed is 1 if h->resv_huge_pages =3D=3D h->free_huge_pages, and then
the reserve count gets inconsistent.
I confirmed that your patch fixes the issue, so I'm OK with it.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
