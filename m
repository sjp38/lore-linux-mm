Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 348FF6B0254
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 11:32:58 -0400 (EDT)
Received: by wicge2 with SMTP id ge2so5714531wic.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 08:32:57 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id xs10si4755603wjc.81.2015.08.27.08.32.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 08:32:57 -0700 (PDT)
Received: by wicgk12 with SMTP id gk12so12423458wic.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 08:32:56 -0700 (PDT)
Date: Thu, 27 Aug 2015 18:32:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 04/11] ARCv2: mm: THP support
Message-ID: <20150827153254.GA21103@node.dhcp.inet.fi>
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
 <1440666194-21478-5-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440666194-21478-5-git-send-email-vgupta@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arc-linux-dev@synopsys.com

On Thu, Aug 27, 2015 at 02:33:07PM +0530, Vineet Gupta wrote:
> +pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
> +{
> +	struct list_head *lh;
> +	pgtable_t pgtable;
> +	pte_t *ptep;
> +
> +	assert_spin_locked(&mm->page_table_lock);
> +
> +	pgtable = pmd_huge_pte(mm, pmdp);
> +	lh = (struct list_head *) pgtable;
> +	if (list_empty(lh))
> +		pmd_huge_pte(mm, pmdp) = (pgtable_t) NULL;
> +	else {
> +		pmd_huge_pte(mm, pmdp) = (pgtable_t) lh->next;
> +		list_del(lh);
> +	}

Side question: why pgtable_t is unsigned long on ARC and not struct page *
or pte_t *, like on other archs? We could avoid these casts.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
