Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF6356B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 21:57:38 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id v17so6598253uak.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 18:57:38 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y30sor3002018uab.137.2018.04.05.18.57.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 18:57:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <65E6BD75-FBA6-43AC-AC5A-B952DE409BC8@cs.rutgers.edu>
References: <20180404032257.11422-1-ying.huang@intel.com> <65E6BD75-FBA6-43AC-AC5A-B952DE409BC8@cs.rutgers.edu>
From: huang ying <huang.ying.caritas@gmail.com>
Date: Fri, 6 Apr 2018 09:57:37 +0800
Message-ID: <CAC=cRTOjybaa+nEBcagDebGWh9Ty49TkcJkWi+BcqVcu3at2vA@mail.gmail.com>
Subject: Re: [PATCH -mm] mm, gup: prevent pmd checking race in follow_pmd_mask()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Apr 4, 2018 at 11:02 PM, Zi Yan <zi.yan@cs.rutgers.edu> wrote:
> On 3 Apr 2018, at 23:22, Huang, Ying wrote:
>
>> From: Huang Ying <ying.huang@intel.com>
>>
>> mmap_sem will be read locked when calling follow_pmd_mask().  But this
>> cannot prevent PMD from being changed for all cases when PTL is
>> unlocked, for example, from pmd_trans_huge() to pmd_none() via
>> MADV_DONTNEED.  So it is possible for the pmd_present() check in
>> follow_pmd_mask() encounter a none PMD.  This may cause incorrect
>> VM_BUG_ON() or infinite loop.  Fixed this via reading PMD entry again
>> but only once and checking the local variable and pmd_none() in the
>> retry loop.
>>
>> As Kirill pointed out, with PTL unlocked, the *pmd may be changed
>> under us, so read it directly again and again may incur weird bugs.
>> So although using *pmd directly other than pmd_present() checking may
>> be safe, it is still better to replace them to read *pmd once and
>> check the local variable for multiple times.
>
> I see you point there. The patch wants to provide a consistent value
> for all race checks. Specifically, this patch is trying to avoid the inconsistent
> reads of *pmd for if-statements, which causes problem when both if-condition reads *pmd and
> the statements inside "if" reads *pmd again and two reads can give different values.
> Am I right about this?

Yes.

> If yes, the problem can be solved by something like:
>
> if (!pmd_present(tmpval = *pmd)) {
>     check tmpval instead of *pmd;
> }
>
> Right?

I think this isn't enough yet.  we need

tmpval = READ_ONCE(*pmd);

To prevent compiler to generate code to read *pmd again and again.
Please check the comments of pmd_none_or_trans_huge_or_clear_bad()
about barrier.

Best Regards,
Huang, Ying

> I just wonder if we need some general code for all race checks.
>
> Thanks.
>
> --
> Best Regards
> Yan Zi
