Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89537280284
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 22:18:32 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c4so3389570pfb.7
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 19:18:32 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 123si7851863pgj.89.2016.11.10.19.18.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 19:18:31 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAB3DpGH130020
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 22:18:30 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26mxqpgejm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 22:18:30 -0500
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 11 Nov 2016 08:48:27 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 8CB72E005F
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 08:48:30 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAB3IOtC44892316
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 08:48:24 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAB3IKRI015843
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 08:48:23 +0530
Subject: Re: [PATCH v2 03/12] mm: thp: introduce separate TTU flag for thp
 freezing
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5824307C.7070105@linux.vnet.ibm.com>
 <20161110090904.GA9173@hori1.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2016 08:48:19 +0530
MIME-Version: 1.0
In-Reply-To: <20161110090904.GA9173@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Message-Id: <5825387B.2060606@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 11/10/2016 02:39 PM, Naoya Horiguchi wrote:
> On Thu, Nov 10, 2016 at 02:01:56PM +0530, Anshuman Khandual wrote:
>> > On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
>>> > > TTU_MIGRATION is used to convert pte into migration entry until thp split
>>> > > completes. This behavior conflicts with thp migration added later patches,
>> >
>> > Hmm, could you please explain why it conflicts with the PMD based
>> > migration without split ? Why TTU_MIGRATION cannot be used to
>> > freeze/hold on the PMD while it's being migrated ?
> try_to_unmap() is used both for thp split (via freeze_page()) and page
> migration (via __unmap_and_move()). In freeze_page(), ttu_flag given for
> head page is like below (assuming anonymous thp):
> 
>     (TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS | TTU_RMAP_LOCKED | \
>      TTU_MIGRATION | TTU_SPLIT_HUGE_PMD)

Right.

> 
> and ttu_flag given for tail pages is:
> 
>     (TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS | TTU_RMAP_LOCKED | \
>      TTU_MIGRATION)

Right.

> 
> __unmap_and_move() calls try_to_unmap() with ttu_flag:
> 
>     (TTU_MIGRATION | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS)
> 
> Now I'm trying to insert a branch for thp migration at the top of
> try_to_unmap_one() like below
> 
> 
>   static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>                        unsigned long address, void *arg)
>   {
>           ...
>           if (flags & TTU_MIGRATION) {
>                   if (!PageHuge(page) && PageTransCompound(page)) {
>                           set_pmd_migration_entry(page, vma, address);
>                           goto out;
>                   }
>           }
> 
> , so try_to_unmap() for tail pages called by thp split can go into thp
> migration code path (which converts *pmd* into migration entry), while
> the expectation is to freeze thp (which converts *pte* into migration entry.)

Got it.

> 
> I detected this failure as a "bad page state" error in a testcase where
> split_huge_page() is called from queue_pages_pte_range().
> 
> Anyway, I'll add this explanation into the patch description in the next post.

Sure, thanks for the explanation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
