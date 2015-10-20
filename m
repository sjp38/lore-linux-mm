Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 58CDD6B0254
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 18:19:43 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so33312695pab.0
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 15:19:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z5si8215589pbt.98.2015.10.20.15.19.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Oct 2015 15:19:42 -0700 (PDT)
Date: Tue, 20 Oct 2015 15:19:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, hugetlb: use memory policy when available
Message-Id: <20151020151941.f603ab55d4d760bca8ce5dbb@linux-foundation.org>
In-Reply-To: <20151020195317.ADA052D8@viggo.jf.intel.com>
References: <20151020195317.ADA052D8@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

On Tue, 20 Oct 2015 12:53:17 -0700 Dave Hansen <dave@sr71.net> wrote:

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> I have a hugetlbfs user which is never explicitly allocating huge pages
> with 'nr_hugepages'.  They only set 'nr_overcommit_hugepages' and then let
> the pages be allocated from the buddy allocator at fault time.
> 
> This works, but they noticed that mbind() was not doing them any good and
> the pages were being allocated without respect for the policy they
> specified.
> 
> The code in question is this:
> 
> > struct page *alloc_huge_page(struct vm_area_struct *vma,
> ...
> >         page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, gbl_chg);
> >         if (!page) {
> >                 page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> 
> dequeue_huge_page_vma() is smart and will respect the VMA's memory policy.
> But, it only grabs _existing_ huge pages from the huge page pool.  If the
> pool is empty, we fall back to alloc_buddy_huge_page() which obviously
> can't do anything with the VMA's policy because it isn't even passed the
> VMA.
> 
> Almost everybody preallocates huge pages.  That's probably why nobody has
> ever noticed this.  Looking back at the git history, I don't think this
> _ever_ worked from when alloc_buddy_huge_page() was introduced in 7893d1d5,
> 8 years ago.
> 
> The fix is to pass vma/addr down in to the places where we actually call in
> to the buddy allocator.  It's fairly straightforward plumbing.  This has
> been lightly tested.

huh.  Fair enough.

>  b/mm/hugetlb.c |  111 ++++++++++++++++++++++++++++++++++++++++++++++++++-------

Is it worth deporking this for the CONFIG_NUMA=n case?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
