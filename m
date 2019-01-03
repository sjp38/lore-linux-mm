Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D004B8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:31:21 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id k203so40272599qke.2
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:31:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c66si2815428qkf.32.2019.01.03.06.31.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 06:31:21 -0800 (PST)
Date: Thu, 3 Jan 2019 09:31:16 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] Initialise mmu_notifier_range correctly
Message-ID: <20190103143116.GB3395@redhat.com>
References: <20190103002126.GM6310@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190103002126.GM6310@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>

On Wed, Jan 02, 2019 at 04:21:26PM -0800, Matthew Wilcox wrote:
> 
> One of the paths in follow_pte_pmd() initialised the mmu_notifier_range
> incorrectly.
> 
> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> Fixes: ac46d4f3c432 ("mm/mmu_notifier: use structure for invalidate_range_start/end calls v2")
> Tested-by: Dave Chinner <dchinner@redhat.com>

Actually now that i have read the code again this is not ok to
do so. The caller of follow_pte_pmd() will call range_init and
follow pmd will only update the range address. So existing code
is ok.

I know this is kind of ugly but i do not see a way around that
uglyness.

> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 2dd2f9ab57f4..21a650368be0 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4078,8 +4078,8 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
>  		goto out;
>  
>  	if (range) {
> -		range->start = address & PAGE_MASK;
> -		range->end = range->start + PAGE_SIZE;
> +		mmu_notifier_range_init(range, mm, address & PAGE_MASK,
> +				     (address & PAGE_MASK) + PAGE_SIZE);
>  		mmu_notifier_invalidate_range_start(range);
>  	}
>  	ptep = pte_offset_map_lock(mm, pmd, address, ptlp);
