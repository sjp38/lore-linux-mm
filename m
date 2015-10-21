Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4E89582F64
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 11:12:06 -0400 (EDT)
Received: by wikq8 with SMTP id q8so98386767wik.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 08:12:05 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id v3si12152097wje.147.2015.10.21.08.12.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 08:12:05 -0700 (PDT)
Received: by wikq8 with SMTP id q8so98385725wik.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 08:12:04 -0700 (PDT)
Date: Wed, 21 Oct 2015 18:12:02 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, hugetlb: use memory policy when available
Message-ID: <20151021151202.GD10597@node.shutemov.name>
References: <20151020195317.ADA052D8@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151020195317.ADA052D8@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

On Tue, Oct 20, 2015 at 12:53:17PM -0700, Dave Hansen wrote:
> @@ -1445,6 +1514,10 @@ static struct page *alloc_buddy_huge_pag
>  	if (hstate_is_gigantic(h))
>  		return NULL;
>  
> +	if (vma || addr) {
> +		WARN_ON_ONCE(!addr || addr == -1);

Trinity triggered the WARN for me:

[  118.647212] WARNING: CPU: 10 PID: 9621 at /home/kas/linux/mm/mm/hugetlb.c:1514 __alloc_buddy_huge_page+0x2c8/0x300()
[  118.648698] Modules linked in:
[  118.649105] CPU: 10 PID: 9621 Comm: trinity-c147 Not tainted 4.2.0-dirty #651
[  118.649909] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS Debian-1.8.2-1 04/01/2014
[  118.650929]  ffffffff81ca6ad8 ffff88081f7f3c68 ffffffff818a9977 0000000080000001
[  118.651889]  0000000000000000 ffff88081f7f3ca8 ffffffff810574d6 ffff88081f7f3c98
[  118.652965]  0000000000000000 ffffffff830a87e0 00000000ffffffff ffffffffffffffff
[  118.653988] Call Trace:
[  118.654315]  [<ffffffff818a9977>] dump_stack+0x4f/0x7b
[  118.654936]  [<ffffffff810574d6>] warn_slowpath_common+0x86/0xc0
[  118.655630]  [<ffffffff810575ca>] warn_slowpath_null+0x1a/0x20
[  118.656427]  [<ffffffff811ac5e8>] __alloc_buddy_huge_page+0x2c8/0x300
[  118.657185]  [<ffffffff811ad081>] hugetlb_acct_memory+0xa1/0x3d0
[  118.657897]  [<ffffffff811ab241>] ? region_chg+0x1f1/0x200
[  118.658559]  [<ffffffff811ae932>] hugetlb_reserve_pages+0x92/0x250
[  118.659289]  [<ffffffff812d517c>] hugetlb_file_setup+0x14c/0x320
[  118.659994]  [<ffffffff813d2fd5>] newseg+0x135/0x370
[  118.660713]  [<ffffffff813cc134>] ? ipcget+0x44/0x2d0
[  118.661306]  [<ffffffff813cc360>] ipcget+0x270/0x2d0
[  118.661911]  [<ffffffff813d3525>] SyS_shmget+0x45/0x50
[  118.663409]  [<ffffffff818b2c7c>] tracesys_phase2+0x84/0x89
[  118.664199] ---[ end trace d2829191292b44ef ]---


> +		WARN_ON_ONCE(nid != NUMA_NO_NODE);
> +	}
>  	/*
>  	 * Assume we will successfully allocate the surplus page to
>  	 * prevent racing processes from causing the surplus to exceed
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
