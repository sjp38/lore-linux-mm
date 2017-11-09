Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 858C8440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 02:33:42 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b5so744258itc.2
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 23:33:42 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id r8si5691632pli.733.2017.11.08.23.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 23:33:41 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [RFC -mm] mm, userfaultfd, THP: Avoid waiting when PMD under THP migration
References: <20171103075231.25416-1-ying.huang@intel.com>
	<D3FBD1E2-FC24-46B1-9CFF-B73295292675@cs.rutgers.edu>
	<CAC=cRTPCw4gBLCequmo6+osqGOrV_+n8puXn=R7u+XOVHLQxxA@mail.gmail.com>
	<20171106202148.GA26645@redhat.com>
Date: Thu, 09 Nov 2017 15:33:37 +0800
In-Reply-To: <20171106202148.GA26645@redhat.com> (Andrea Arcangeli's message
	of "Mon, 6 Nov 2017 21:21:48 +0100")
Message-ID: <87d14rzz1q.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: huang ying <huang.ying.caritas@gmail.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "Huang, Ying" <ying.huang@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>

Andrea Arcangeli <aarcange@redhat.com> writes:

> Hello,
>
> On Sun, Nov 05, 2017 at 11:01:05AM +0800, huang ying wrote:
>> On Fri, Nov 3, 2017 at 11:00 PM, Zi Yan <zi.yan@cs.rutgers.edu> wrote:
>> > On 3 Nov 2017, at 3:52, Huang, Ying wrote:
>> >
>> >> From: Huang Ying <ying.huang@intel.com>
>> >>
>> >> If THP migration is enabled, the following situation is possible,
>> >>
>> >> - A THP is mapped at source address
>> >> - Migration is started to move the THP to another node
>> >> - Page fault occurs
>> >> - The PMD (migration entry) is copied to the destination address in mremap
>> >>
>> >
>> > You mean the page fault path follows the source address and sees pmd_none() now
>> > because mremap() clears it and remaps the page with dest address.
>> > Otherwise, it seems not possible to get into handle_userfault(), since it is called in
>> > pmd_none() branch inside do_huge_pmd_anonymous_page().
>> >
>> >
>> >> That is, it is possible for handle_userfault() encounter a PMD entry
>> >> which has been handled but !pmd_present().  In the current
>> >> implementation, we will wait for such PMD entries, which may cause
>> >> unnecessary waiting, and potential soft lockup.
>> >
>> > handle_userfault() should only see pmd_none() in the situation you describe,
>> > whereas !pmd_present() (migration entry case) should lead to
>> > pmd_migration_entry_wait().
>> 
>> Yes.  This is my understanding of the source code too.  And I
>> described it in the original patch description too.  I just want to
>> make sure whether it is possible that !pmd_none() and !pmd_present()
>> for a PMD in userfaultfd_must_wait().  And, whether it is possible for
>
> I don't see how mremap is relevant above. mremap runs with mmap_sem
> for writing, so it can't race against userfaultfd_must_wait.
>
> However the concern of set_pmd_migration_entry() being called with
> only the mmap_sem for reading through TTU_MIGRATION in
> __unmap_and_move and being interpreted as a "missing" THP page by
> userfaultfd_must_wait seems valid.
>
> Compaction won't normally compact pages that are already THP sized so
> you cannot see this normally because VM don't normally get migrated
> over SHM/hugetlbfs with hard bindings while userfaults are in
> progress.
>
> Overall your patch looks more correct than current code so it's good
> idea to apply and it should avoid surprises with the above corner
> case if CONFIG_ARCH_ENABLE_THP_MIGRATION is set.
>
> Worst case the process would hang in handle_userfault(), but it will
> still respond fine to sigkill, so it's not concerning, but it should
> be fixed nevertheless.
>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks!  I will revise the patch description and send the new version!

Best Regards,
Huang, Ying

[snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
