Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5E56B0278
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 14:20:58 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y6so18002809lff.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 11:20:58 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id p82si15427881wmb.121.2016.09.21.11.20.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 11:20:57 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id w84so208820119wmg.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 11:20:57 -0700 (PDT)
Date: Wed, 21 Sep 2016 20:20:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/1] memory offline issues with hugepage size > memory
 block size
Message-ID: <20160921182054.GK24210@dhcp22.suse.cz>
References: <20160920155354.54403-1-gerald.schaefer@de.ibm.com>
 <bc000c05-3186-da92-e868-f2dbf0c28a98@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bc000c05-3186-da92-e868-f2dbf0c28a98@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Tue 20-09-16 10:37:04, Mike Kravetz wrote:
> On 09/20/2016 08:53 AM, Gerald Schaefer wrote:
> > dissolve_free_huge_pages() will either run into the VM_BUG_ON() or a
> > list corruption and addressing exception when trying to set a memory
> > block offline that is part (but not the first part) of a gigantic
> > hugetlb page with a size > memory block size.
> > 
> > When no other smaller hugepage sizes are present, the VM_BUG_ON() will
> > trigger directly. In the other case we will run into an addressing
> > exception later, because dissolve_free_huge_page() will not use the head
> > page of the compound hugetlb page which will result in a NULL hstate
> > from page_hstate(). list_del() would also not work well on a tail page.
> > 
> > To fix this, first remove the VM_BUG_ON() because it is wrong, and then
> > use the compound head page in dissolve_free_huge_page().
> > 
> > However, this all assumes that it is the desired behaviour to remove
> > a (gigantic) unused hugetlb page from the pool, just because a small
> > (in relation to the  hugepage size) memory block is going offline. Not
> > sure if this is the right thing, and it doesn't look very consistent
> > given that in this scenario it is _not_ possible to migrate
> > such a (gigantic) hugepage if it is in use. OTOH, has_unmovable_pages()
> > will return false in both cases, i.e. the memory block will be reported
> > as removable, no matter if the hugepage that it is part of is unused or
> > in use.
> > 
> > This patch is assuming that it would be OK to remove the hugepage,
> > i.e. memory offline beats pre-allocated unused (gigantic) hugepages.
> > 
> > Any thoughts?
> 
> Cc'ed Rui Teng and Dave Hansen as they were discussing the issue in
> this thread:
> https://lkml.org/lkml/2016/9/13/146
> 
> Their approach (I believe) would be to fail the offline operation in
> this case.  However, I could argue that failing the operation, or
> dissolving the unused huge page containing the area to be offlined is
> the right thing to do.

I am sorry I have noticed this thread only now. I was arguing about this
in the original thread. I would be rather reluctant to free gigantic
page just because somebody wants to offline a small part of it because
setup is really expensive and a lost page would be really hard to get
back.

I would even question the per page block offlining itself. Why would
anybody want to offline few blocks rather than the whole node? What is
the usecase here?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
