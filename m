Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EDD06B0003
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 02:28:18 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q12-v6so8226528pgp.6
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 23:28:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 59-v6si19318278plb.415.2018.08.13.23.28.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Aug 2018 23:28:17 -0700 (PDT)
Date: Tue, 14 Aug 2018 08:28:13 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2] mm: migration: fix migration of huge PMD shared pages
Message-ID: <20180814062813.GA22413@kroah.com>
References: <201808131221.zDDttbc8%fengguang.wu@intel.com>
 <20180814003058.19732-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180814003058.19732-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Mon, Aug 13, 2018 at 05:30:58PM -0700, Mike Kravetz wrote:
> The page migration code employs try_to_unmap() to try and unmap the
> source page.  This is accomplished by using rmap_walk to find all
> vmas where the page is mapped.  This search stops when page mapcount
> is zero.  For shared PMD huge pages, the page map count is always 1
> no matter the number of mappings.  Shared mappings are tracked via
> the reference count of the PMD page.  Therefore, try_to_unmap stops
> prematurely and does not completely unmap all mappings of the source
> page.
> 
> This problem can result is data corruption as writes to the original
> source page can happen after contents of the page are copied to the
> target page.  Hence, data is lost.
> 
> This problem was originally seen as DB corruption of shared global
> areas after a huge page was soft offlined due to ECC memory errors.
> DB developers noticed they could reproduce the issue by (hotplug)
> offlining memory used to back huge pages.  A simple testcase can
> reproduce the problem by creating a shared PMD mapping (note that
> this must be at least PUD_SIZE in size and PUD_SIZE aligned (1GB on
> x86)), and using migrate_pages() to migrate process pages between
> nodes while continually writing to the huge pages being migrated.
> 
> To fix, have the try_to_unmap_one routine check for huge PMD sharing
> by calling huge_pmd_unshare for hugetlbfs huge pages.  If it is a
> shared mapping it will be 'unshared' which removes the page table
> entry and drops the reference on the PMD page.  After this, flush
> caches and TLB.
> 
> Fixes: 39dde65c9940 ("shared page table for hugetlb page")
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
> v2: Fixed build issue for !CONFIG_HUGETLB_PAGE and typos in comment
> 

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read:
    https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
for how to do this properly.

</formletter>
