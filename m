Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 994496B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 02:10:57 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id c20so117579853pfc.1
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 23:10:57 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [125.16.236.9])
        by mx.google.com with ESMTPS id c62si1480453pfd.69.2016.04.10.23.10.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 10 Apr 2016 23:10:56 -0700 (PDT)
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 11 Apr 2016 11:40:54 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3B6AlnV6095162
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:40:47 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3B6AhsW009363
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:40:45 +0530
Message-ID: <570B3FDB.90305@linux.vnet.ibm.com>
Date: Mon, 11 Apr 2016 11:40:35 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] mm/hugetlb: Add PGD based implementation awareness
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com> <1460007464-26726-3-git-send-email-khandual@linux.vnet.ibm.com> <570622B4.5020407@gmail.com> <570B3531.2000808@linux.vnet.ibm.com>
In-Reply-To: <570B3531.2000808@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 04/11/2016 10:55 AM, Anshuman Khandual wrote:
> On 04/07/2016 02:34 PM, Balbir Singh wrote:
>> > 
>> > 
>> > On 07/04/16 15:37, Anshuman Khandual wrote:
>>> >> Currently the config ARCH_WANT_GENERAL_HUGETLB enabled functions like
>>> >> 'huge_pte_alloc' and 'huge_pte_offset' dont take into account HugeTLB
>>> >> page implementation at the PGD level. This is also true for functions
>>> >> like 'follow_page_mask' which is called from move_pages() system call.
>>> >> This lack of PGD level huge page support prohibits some architectures
>>> >> to use these generic HugeTLB functions.
>>> >>
>> > 
>> > From what I know of move_pages(), it will always call follow_page_mask()
>> > with FOLL_GET (I could be wrong here) and the implementation below
>> > returns NULL for follow_huge_pgd().
> You are right. This patch makes ARCH_WANT_GENERAL_HUGETLB functions aware
> of PGD implementation so that we can do all transactions on 16GB pages
> using these function instead of the present arch overrides. But that also
> requires follow_page_mask() changes for every other access to the page
> than the migrate_pages() usage.
> 
> But yes, we dont support migrate_pages() on PGD based pages yet, hence
> it just returns NULL in that case. May be the commit message needs to
> reflect this.

The next commit actually changes follow_huge_pud|pgd() functions to
support FOLL_GET and PGD based huge page migration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
