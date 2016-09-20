Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 62BC86B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 13:37:31 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p53so46639854qtp.0
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 10:37:31 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id j123si3822371vkc.170.2016.09.20.10.37.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 10:37:15 -0700 (PDT)
Subject: Re: [PATCH 0/1] memory offline issues with hugepage size > memory
 block size
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <bc000c05-3186-da92-e868-f2dbf0c28a98@oracle.com>
Date: Tue, 20 Sep 2016 10:37:04 -0700
MIME-Version: 1.0
In-Reply-To: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

On 09/20/2016 08:53 AM, Gerald Schaefer wrote:
> dissolve_free_huge_pages() will either run into the VM_BUG_ON() or a
> list corruption and addressing exception when trying to set a memory
> block offline that is part (but not the first part) of a gigantic
> hugetlb page with a size > memory block size.
> 
> When no other smaller hugepage sizes are present, the VM_BUG_ON() will
> trigger directly. In the other case we will run into an addressing
> exception later, because dissolve_free_huge_page() will not use the head
> page of the compound hugetlb page which will result in a NULL hstate
> from page_hstate(). list_del() would also not work well on a tail page.
> 
> To fix this, first remove the VM_BUG_ON() because it is wrong, and then
> use the compound head page in dissolve_free_huge_page().
> 
> However, this all assumes that it is the desired behaviour to remove
> a (gigantic) unused hugetlb page from the pool, just because a small
> (in relation to the  hugepage size) memory block is going offline. Not
> sure if this is the right thing, and it doesn't look very consistent
> given that in this scenario it is _not_ possible to migrate
> such a (gigantic) hugepage if it is in use. OTOH, has_unmovable_pages()
> will return false in both cases, i.e. the memory block will be reported
> as removable, no matter if the hugepage that it is part of is unused or
> in use.
> 
> This patch is assuming that it would be OK to remove the hugepage,
> i.e. memory offline beats pre-allocated unused (gigantic) hugepages.
> 
> Any thoughts?

Cc'ed Rui Teng and Dave Hansen as they were discussing the issue in
this thread:
https://lkml.org/lkml/2016/9/13/146

Their approach (I believe) would be to fail the offline operation in
this case.  However, I could argue that failing the operation, or
dissolving the unused huge page containing the area to be offlined is
the right thing to do.

I never thought too much about the VM_BUG_ON(), but you are correct in
that it should be removed in either case.

The other thing that needs to be changed is the locking in
dissolve_free_huge_page().  I believe the lock only needs to be held if
we are removing the huge page from the pool.  It is not a correctness
but performance issue.

-- 
Mike Kravetz

> 
> 
> Gerald Schaefer (1):
>   mm/hugetlb: fix memory offline with hugepage size > memory block size
> 
>  mm/hugetlb.c | 16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
