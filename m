Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0A736B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 10:53:59 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id h28so11402709pfh.16
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 07:53:59 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0123.outbound.protection.outlook.com. [104.47.42.123])
        by mx.google.com with ESMTPS id 91si10165350ply.301.2017.11.06.07.53.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 07:53:58 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC -mm] mm, userfaultfd, THP: Avoid waiting when PMD under THP
 migration
Date: Mon, 06 Nov 2017 10:53:48 -0500
Message-ID: <AC486A3D-F3D4-403D-B3EB-DB2A14CF4042@cs.rutgers.edu>
In-Reply-To: <CAC=cRTPCw4gBLCequmo6+osqGOrV_+n8puXn=R7u+XOVHLQxxA@mail.gmail.com>
References: <20171103075231.25416-1-ying.huang@intel.com>
 <D3FBD1E2-FC24-46B1-9CFF-B73295292675@cs.rutgers.edu>
 <CAC=cRTPCw4gBLCequmo6+osqGOrV_+n8puXn=R7u+XOVHLQxxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: huang ying <huang.ying.caritas@gmail.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>

On 4 Nov 2017, at 23:01, huang ying wrote:

> On Fri, Nov 3, 2017 at 11:00 PM, Zi Yan <zi.yan@cs.rutgers.edu> wrote:
>> On 3 Nov 2017, at 3:52, Huang, Ying wrote:
>>
>>> From: Huang Ying <ying.huang@intel.com>
>>>
>>> If THP migration is enabled, the following situation is possible,
>>>
>>> - A THP is mapped at source address
>>> - Migration is started to move the THP to another node
>>> - Page fault occurs
>>> - The PMD (migration entry) is copied to the destination address in 
>>> mremap
>>>
>>
>> You mean the page fault path follows the source address and sees 
>> pmd_none() now
>> because mremap() clears it and remaps the page with dest address.
>> Otherwise, it seems not possible to get into handle_userfault(), 
>> since it is called in
>> pmd_none() branch inside do_huge_pmd_anonymous_page().
>>
>>
>>> That is, it is possible for handle_userfault() encounter a PMD entry
>>> which has been handled but !pmd_present().  In the current
>>> implementation, we will wait for such PMD entries, which may cause
>>> unnecessary waiting, and potential soft lockup.
>>
>> handle_userfault() should only see pmd_none() in the situation you 
>> describe,
>> whereas !pmd_present() (migration entry case) should lead to
>> pmd_migration_entry_wait().
>
> Yes.  This is my understanding of the source code too.  And I
> described it in the original patch description too.  I just want to
> make sure whether it is possible that !pmd_none() and !pmd_present()
> for a PMD in userfaultfd_must_wait().  And, whether it is possible for
> us to implement PMD mapping copying in UFFDIO_COPY in the future?
>

Thanks for clarifying it. We both agree that !pmd_present(), which means
PMD migration entry, does not get into userfaultfd_must_wait(),
then there seems to be no issue with current code yet.

However, the if (!pmd_present(_pmd)) in userfaultfd_must_wait() does not 
match
the exact condition. How about the patch below? It can catch pmd 
migration entries,
which are only possible in x86_64 at the moment.

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 1c713fd5b3e6..dda25444a6ee 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -294,9 +294,11 @@ static inline bool userfaultfd_must_wait(struct 
userfaultfd_ctx *ctx,
          * pmd_trans_unstable) of the pmd.
          */
         _pmd = READ_ONCE(*pmd);
-       if (!pmd_present(_pmd))
+       if (pmd_none(_pmd))
                 goto out;

+       VM_BUG_ON(thp_migration_supported() && 
is_pmd_migration_entry(_pmd));
+
         ret = false;
         if (pmd_trans_huge(_pmd))
                 goto out;



a??
Best Regards,
Yan Zi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
