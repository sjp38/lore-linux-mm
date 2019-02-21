Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 632D8C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 06:09:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BA192147A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 06:09:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BA192147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACD518E005E; Thu, 21 Feb 2019 01:09:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7C908E0002; Thu, 21 Feb 2019 01:09:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96C118E005E; Thu, 21 Feb 2019 01:09:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 571C98E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 01:09:16 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 59so19396524plc.13
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 22:09:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zhP5FOalUoLpV2/9wvX+5Z/lEP4pxisJV8efLcU+c0s=;
        b=WsIoET6bUtlu+n5/OmA7VGZwKGE7TCjiOB9LeN2kSJ0x0MiAsB+Q60yRqVYK0q0vwp
         CcOLeGxvcDeJWqwerKL8eTMokkQJg53s1mF6coJRdIxzSEnY/LJZtgWUrMHbWk+SuXrs
         2r55kg5ASwi67IXrquT9dXyEo1NNlcgsqKYAVaDmTdbgbOQtjdH6QzKGpSKiUhIZSYTO
         4vHCoWsJ0JAQTvWUaQvBpKHYE1YAmY8SZFxkyz1olgZewdMdB4pJTzLaC1DdJaZDRxHy
         MseTLJAcQtuNvVYW2cdfaDvCrCG5BORav/9WGJZP8S9r6nJIXGcwOpop0vJrgSz8ykEn
         CHBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuZPG9YvcdKgdgJMX/YiHXCOzsD2EzP/y6yCyJy05pD+Z5Y2+9bV
	SRKAO1mAy/983Y2qCc8Q4S6B0llcsjiI0dD7nv6VNh9u/paiwwRaXrDSb5UHOOOvAnofoclz4AJ
	MliMQuHnJjb9xywldRIw5qxVkZXY3Q0AhMzhWOd5/XULYpnlEkTiI0BE1DRqFLrj/vg==
X-Received: by 2002:a63:6bc9:: with SMTP id g192mr3564750pgc.198.1550729356011;
        Wed, 20 Feb 2019 22:09:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZuQeunL2UcSkX1ryQUUvSXQCrQxKqBX003Au96QF4JfFUBlyVaB+eTmQgFsmB5MFmc3MOR
X-Received: by 2002:a63:6bc9:: with SMTP id g192mr3564675pgc.198.1550729354799;
        Wed, 20 Feb 2019 22:09:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550729354; cv=none;
        d=google.com; s=arc-20160816;
        b=RppGTTF9jDpzIzrONfWDMXpIFj58/86xqyTfHdlqdH+pzdASLYwA0ckdDEg5CKBJFt
         fV1xS57foZ6nmOPsMsgQOCjGWBGx9+e79O+lC2w2vUWRwbnYw4L37fF45b6DSNVUzm+k
         7mFOtIkQX/bozs6ZE84SEc7Bibggt9C9oXc21+eqfEIatRfwjcjvITSWTj3rfMAymcWU
         Tc2+F5sVwYiloXKVRARlBeccbXfmCsdPPz2xzwVuQY72/eagpclWlvhQWQgvhYgNeKkP
         Rc7lZ8DryvafAJzyTrwktoMSwIndE6OK8fBBox87SbYNDz7GkMZJZ2qbkZfhBvp1aFrs
         cgEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=zhP5FOalUoLpV2/9wvX+5Z/lEP4pxisJV8efLcU+c0s=;
        b=mOpHAAZ9T2mCNu22hyuOm+1QRDaZCjFhQRbDbFreBX5V93TxbJoIMBww326hzx4keM
         +RpsxeptSeY5CMoQXzpfMJVoFzaPKbivYv+U7FkxhZ7AuG2j/77ZtQLmkM8w21kAZudr
         E0RJb2+qLLbXGkJRzEl1IupohU98PD55aLv4ZYH0RtC4yI5LHM+8LDCWN1uk6TiEOI9W
         rELXESdJGSNX3B/tcquKRgSvXA/dXqJEQ08wLh+qcB5YbtURAmPYPa0FBBtRIFu2GVyz
         L8T9oNX/kksEASMAWnlB9e6MjVGfO8AOOTZg2zgSUEyWd7qqJuNA9RNSt0mPLi0bxYv4
         BbJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 1si19008872pla.155.2019.02.20.22.09.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 22:09:14 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 9B2CD3810;
	Thu, 21 Feb 2019 06:09:13 +0000 (UTC)
Date: Wed, 20 Feb 2019 22:09:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko
 <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea
 Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov"
 <kirill.shutemov@linux.intel.com>, Mel Gorman
 <mgorman@techsingularity.net>, Davidlohr Bueso <dave@stgolabs.net>,
 stable@vger.kernel.org
Subject: Re: [PATCH] huegtlbfs: fix races and page leaks during migration
Message-Id: <20190220220910.265bff9a7695540ee4121b80@linux-foundation.org>
In-Reply-To: <20190212221400.3512-1-mike.kravetz@oracle.com>
References: <803d2349-8911-0b47-bc5b-4f2c6cc3f928@oracle.com>
	<20190212221400.3512-1-mike.kravetz@oracle.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019 14:14:00 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> hugetlb pages should only be migrated if they are 'active'.  The routines
> set/clear_page_huge_active() modify the active state of hugetlb pages.
> When a new hugetlb page is allocated at fault time, set_page_huge_active
> is called before the page is locked.  Therefore, another thread could
> race and migrate the page while it is being added to page table by the
> fault code.  This race is somewhat hard to trigger, but can be seen by
> strategically adding udelay to simulate worst case scheduling behavior.
> Depending on 'how' the code races, various BUG()s could be triggered.
> 
> To address this issue, simply delay the set_page_huge_active call until
> after the page is successfully added to the page table.
> 
> Hugetlb pages can also be leaked at migration time if the pages are
> associated with a file in an explicitly mounted hugetlbfs filesystem.
> For example, a test program which hole punches, faults and migrates
> pages in such a file (1G in size) will eventually fail because it
> can not allocate a page.  Reported counts and usage at time of failure:
> 
> node0
> 537     free_hugepages
> 1024    nr_hugepages
> 0       surplus_hugepages
> node1
> 1000    free_hugepages
> 1024    nr_hugepages
> 0       surplus_hugepages
> 
> Filesystem                         Size  Used Avail Use% Mounted on
> nodev                              4.0G  4.0G     0 100% /var/opt/hugepool
> 
> Note that the filesystem shows 4G of pages used, while actual usage is
> 511 pages (just under 1G).  Failed trying to allocate page 512.
> 
> If a hugetlb page is associated with an explicitly mounted filesystem,
> this information in contained in the page_private field.  At migration
> time, this information is not preserved.  To fix, simply transfer
> page_private from old to new page at migration time if necessary.
> 
> Cc: <stable@vger.kernel.org>
> Fixes: bcc54222309c ("mm: hugetlb: introduce page_huge_active")
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

cc:stable.  It would be nice to get some review of this one, please?

> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -859,6 +859,18 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
>  	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
>  	if (rc != MIGRATEPAGE_SUCCESS)
>  		return rc;
> +
> +	/*
> +	 * page_private is subpool pointer in hugetlb pages.  Transfer to
> +	 * new page.  PagePrivate is not associated with page_private for
> +	 * hugetlb pages and can not be set here as only page_huge_active
> +	 * pages can be migrated.
> +	 */
> +	if (page_private(page)) {
> +		set_page_private(newpage, page_private(page));
> +		set_page_private(page, 0);
> +	}
> +
>  	if (mode != MIGRATE_SYNC_NO_COPY)
>  		migrate_page_copy(newpage, page);
>  	else
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a80832487981..f859e319e3eb 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3625,7 +3625,6 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  	copy_user_huge_page(new_page, old_page, address, vma,
>  			    pages_per_huge_page(h));
>  	__SetPageUptodate(new_page);
> -	set_page_huge_active(new_page);
>  
>  	mmun_start = haddr;
>  	mmun_end = mmun_start + huge_page_size(h);
> @@ -3647,6 +3646,7 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  				make_huge_pte(vma, new_page, 1));
>  		page_remove_rmap(old_page, true);
>  		hugepage_add_new_anon_rmap(new_page, vma, haddr);
> +		set_page_huge_active(new_page);
>  		/* Make the old page be freed below */
>  		new_page = old_page;
>  	}
> @@ -3792,7 +3792,6 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
>  		}
>  		clear_huge_page(page, address, pages_per_huge_page(h));
>  		__SetPageUptodate(page);
> -		set_page_huge_active(page);
>  
>  		if (vma->vm_flags & VM_MAYSHARE) {
>  			int err = huge_add_to_page_cache(page, mapping, idx);
> @@ -3863,6 +3862,10 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
>  	}
>  
>  	spin_unlock(ptl);
> +
> +	/* May already be set if not newly allocated page */
> +	set_page_huge_active(page);
> +
>  	unlock_page(page);
>  out:
>  	return ret;
> @@ -4097,7 +4100,6 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  	 * the set_pte_at() write.
>  	 */
>  	__SetPageUptodate(page);
> -	set_page_huge_active(page);
>  
>  	mapping = dst_vma->vm_file->f_mapping;
>  	idx = vma_hugecache_offset(h, dst_vma, dst_addr);
> @@ -4165,6 +4167,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  	update_mmu_cache(dst_vma, dst_addr, dst_pte);
>  
>  	spin_unlock(ptl);
> +	set_page_huge_active(page);
>  	if (vm_shared)
>  		unlock_page(page);
>  	ret = 0;
> -- 
> 2.17.2

