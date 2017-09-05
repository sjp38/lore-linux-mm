Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24B13280300
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 12:21:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x78so7975330pff.7
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 09:21:24 -0700 (PDT)
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com. [15.241.140.73])
        by mx.google.com with ESMTPS id v8si543805plp.729.2017.09.05.09.21.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Sep 2017 09:21:19 -0700 (PDT)
Date: Tue, 5 Sep 2017 11:21:12 -0500
From: Dimitri Sivanich <sivanich@hpe.com>
Subject: Re: [PATCH 10/13] sgi-gru: update to new mmu_notifier semantic
Message-ID: <20170905162112.GC14176@hpe.com>
References: <20170831211738.17922-1-jglisse@redhat.com>
 <20170831211738.17922-11-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170831211738.17922-11-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dimitri Sivanich <sivanich@hpe.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Dimitri Sivanich <sivanich@hpe.com>

On Thu, Aug 31, 2017 at 05:17:35PM -0400, jglisse@redhat.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> Call to mmu_notifier_invalidate_page() are replaced by call to
> mmu_notifier_invalidate_range() and thus call are bracketed by
> call to mmu_notifier_invalidate_range_start()/end()
> 
> Remove now useless invalidate_page callback.
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Cc: Dimitri Sivanich <sivanich@sgi.com>
> Cc: Jack Steiner <steiner@sgi.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  drivers/misc/sgi-gru/grutlbpurge.c | 12 ------------
>  1 file changed, 12 deletions(-)
> 
> diff --git a/drivers/misc/sgi-gru/grutlbpurge.c b/drivers/misc/sgi-gru/grutlbpurge.c
> index e936d43895d2..9918eda0e05f 100644
> --- a/drivers/misc/sgi-gru/grutlbpurge.c
> +++ b/drivers/misc/sgi-gru/grutlbpurge.c
> @@ -247,17 +247,6 @@ static void gru_invalidate_range_end(struct mmu_notifier *mn,
>  	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx\n", gms, start, end);
>  }
>  
> -static void gru_invalidate_page(struct mmu_notifier *mn, struct mm_struct *mm,
> -				unsigned long address)
> -{
> -	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
> -						 ms_notifier);
> -
> -	STAT(mmu_invalidate_page);
> -	gru_flush_tlb_range(gms, address, PAGE_SIZE);
> -	gru_dbg(grudev, "gms %p, address 0x%lx\n", gms, address);
> -}
> -
>  static void gru_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  {
>  	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
> @@ -269,7 +258,6 @@ static void gru_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  
>  
>  static const struct mmu_notifier_ops gru_mmuops = {
> -	.invalidate_page	= gru_invalidate_page,
>  	.invalidate_range_start	= gru_invalidate_range_start,
>  	.invalidate_range_end	= gru_invalidate_range_end,
>  	.release		= gru_release,
> -- 
> 2.13.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
