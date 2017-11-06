Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0891E6B0033
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 15:35:31 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 82so11063268oid.11
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 12:35:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q82si5601801oih.443.2017.11.06.12.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 12:35:30 -0800 (PST)
Date: Mon, 6 Nov 2017 21:35:27 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC -mm] mm, userfaultfd, THP: Avoid waiting when PMD under THP
 migration
Message-ID: <20171106203527.GB26645@redhat.com>
References: <20171103075231.25416-1-ying.huang@intel.com>
 <D3FBD1E2-FC24-46B1-9CFF-B73295292675@cs.rutgers.edu>
 <CAC=cRTPCw4gBLCequmo6+osqGOrV_+n8puXn=R7u+XOVHLQxxA@mail.gmail.com>
 <AC486A3D-F3D4-403D-B3EB-DB2A14CF4042@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AC486A3D-F3D4-403D-B3EB-DB2A14CF4042@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: huang ying <huang.ying.caritas@gmail.com>, "Huang, Ying" <ying.huang@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>

On Mon, Nov 06, 2017 at 10:53:48AM -0500, Zi Yan wrote:
> Thanks for clarifying it. We both agree that !pmd_present(), which means
> PMD migration entry, does not get into userfaultfd_must_wait(),
> then there seems to be no issue with current code yet.
> 
> However, the if (!pmd_present(_pmd)) in userfaultfd_must_wait() does not 
> match
> the exact condition. How about the patch below? It can catch pmd 
> migration entries,
> which are only possible in x86_64 at the moment.
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 1c713fd5b3e6..dda25444a6ee 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -294,9 +294,11 @@ static inline bool userfaultfd_must_wait(struct 
> userfaultfd_ctx *ctx,
>           * pmd_trans_unstable) of the pmd.
>           */
>          _pmd = READ_ONCE(*pmd);
> -       if (!pmd_present(_pmd))
> +       if (pmd_none(_pmd))
>                  goto out;
> 
> +       VM_BUG_ON(thp_migration_supported() && is_pmd_migration_entry(_pmd));
> +

As I wrote in prev email I'm not sure about this invariant to be
correct 100% of the time (plus we'd want a VM_WARN_ON only
here). Specifically, what does prevent try_to_unmap to run on a THP
backed mapping with only the mmap_sem for reading?

I know what prevents to ever reproduce this in practice though (aside
from the fact the race between the is_swap_pmd() check in the main
page fault and the above check is small) and it's because compaction
won't migrate THP and even the numa faults will not use the migration
entry. So it'd require some more explicit migration numactl while
userfaults are running to ever see an hang in there.

I think it's a regression since the introduction of THP migration
around commits 84c3fc4e9c563d8fb91cfdf5948da48fe1af34d3 /
616b8371539a6c487404c3b8fb04078016dab4ba /
9c670ea37947a82cb6d4df69139f7e46ed71a0ac etc.. before that pmd_none or
!pmd_present used to be equivalent, not the case any longer. Of course
pmd_none would have been better before too.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
