Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 951466B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 14:01:11 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id t17so1218456oij.23
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 11:01:11 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a17si861919oic.512.2018.02.13.11.01.09
        for <linux-mm@kvack.org>;
        Tue, 13 Feb 2018 11:01:10 -0800 (PST)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB hugepage
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
	<1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<87inbbjx2w.fsf@e105922-lin.cambridge.arm.com>
	<20180207011455.GA15214@hori1.linux.bs1.fc.nec.co.jp>
	<87fu6bfytm.fsf@e105922-lin.cambridge.arm.com>
	<84c6e1f7-e693-30f3-d208-c3a094d9e3b0@ah.jp.nec.com>
Date: Tue, 13 Feb 2018 19:01:06 +0000
In-Reply-To: <84c6e1f7-e693-30f3-d208-c3a094d9e3b0@ah.jp.nec.com> (Naoya
	Horiguchi's message of "Fri, 9 Feb 2018 01:17:48 +0000")
Message-ID: <87607067f1.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> On 02/08/2018 09:30 PM, Punit Agrawal wrote:

[...]

>> I'll look to update the arm64 helpers once this patch gets merged. But
>> it would be helpful if there was a clear expression of semantics for
>> pud_huge() for various cases. Is there any version that can be used as
>> reference?
>
> Sorry if I misunderstand you, but with this patch there is no non-present
> pud entry, so I feel that you don't have to change pud_huge() in arm64.
>
> When we get to have non-present pud entries (by enabling hwpoison or 1GB
> hugepage migration), we need to explicitly check pud_present in every page
> table walk. So I think the current semantics is like:
>
>   if (pud_none(pud))
>           /* skip this entry */
>   else if (pud_huge(pud))
>           /* do something for pud-hugetlb */
>   else
>           /* go to next (pmd) level */
>
> and after enabling hwpoison or migartion:
>
>   if (pud_none(pud))
>           /* skip this entry */
>   else if (!pud_present(pud))
>           /* do what we need to handle peculiar cases */
>   else if (pud_huge(pud))
>           /* do something for pud-hugetlb */
>   else
>           /* go to next (pmd) level */
>
> What we did for pmd can also be a reference to what we do for pud.

Thanks for clarifying this.

Based on the above - p*d_huge() should never be called with swap entries
(here and in other parts of the kernel as well). If that's the case,
then no change is needed for arm64.

Thanks,
Punit

[...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
