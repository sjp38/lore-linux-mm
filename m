Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 48AFB6B0033
	for <linux-mm@kvack.org>; Sat,  4 Nov 2017 23:01:08 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id n61so4707850qte.3
        for <linux-mm@kvack.org>; Sat, 04 Nov 2017 20:01:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b7sor5868199qkg.96.2017.11.04.20.01.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 04 Nov 2017 20:01:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <D3FBD1E2-FC24-46B1-9CFF-B73295292675@cs.rutgers.edu>
References: <20171103075231.25416-1-ying.huang@intel.com> <D3FBD1E2-FC24-46B1-9CFF-B73295292675@cs.rutgers.edu>
From: huang ying <huang.ying.caritas@gmail.com>
Date: Sun, 5 Nov 2017 11:01:05 +0800
Message-ID: <CAC=cRTPCw4gBLCequmo6+osqGOrV_+n8puXn=R7u+XOVHLQxxA@mail.gmail.com>
Subject: Re: [RFC -mm] mm, userfaultfd, THP: Avoid waiting when PMD under THP migration
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: "Huang, Ying" <ying.huang@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>

On Fri, Nov 3, 2017 at 11:00 PM, Zi Yan <zi.yan@cs.rutgers.edu> wrote:
> On 3 Nov 2017, at 3:52, Huang, Ying wrote:
>
>> From: Huang Ying <ying.huang@intel.com>
>>
>> If THP migration is enabled, the following situation is possible,
>>
>> - A THP is mapped at source address
>> - Migration is started to move the THP to another node
>> - Page fault occurs
>> - The PMD (migration entry) is copied to the destination address in mremap
>>
>
> You mean the page fault path follows the source address and sees pmd_none() now
> because mremap() clears it and remaps the page with dest address.
> Otherwise, it seems not possible to get into handle_userfault(), since it is called in
> pmd_none() branch inside do_huge_pmd_anonymous_page().
>
>
>> That is, it is possible for handle_userfault() encounter a PMD entry
>> which has been handled but !pmd_present().  In the current
>> implementation, we will wait for such PMD entries, which may cause
>> unnecessary waiting, and potential soft lockup.
>
> handle_userfault() should only see pmd_none() in the situation you describe,
> whereas !pmd_present() (migration entry case) should lead to
> pmd_migration_entry_wait().

Yes.  This is my understanding of the source code too.  And I
described it in the original patch description too.  I just want to
make sure whether it is possible that !pmd_none() and !pmd_present()
for a PMD in userfaultfd_must_wait().  And, whether it is possible for
us to implement PMD mapping copying in UFFDIO_COPY in the future?

Best Regards,
Huang, Ying

> Am I missing anything here?
>
>
> --
> Best Regards
> Yan Zi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
