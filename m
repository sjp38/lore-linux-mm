Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4F96B025E
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 17:48:28 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g18so4835229itg.7
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 14:48:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v125si4545251oie.294.2017.10.02.14.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 14:48:27 -0700 (PDT)
Date: Mon, 2 Oct 2017 17:48:23 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/migrate: Fix early increment of migrate->npages
Message-ID: <20171002214823.GB5184@redhat.com>
References: <1506980642-16541-1-git-send-email-arbab@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1506980642-16541-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 02, 2017 at 04:44:02PM -0500, Reza Arbab wrote:
> The intention here is to set the same array element in src and dst.
> Switch the order of these lines so that migrate->npages is only
> incremented after we've used it.

I already posted a fix for this today from Mark. Either version is
fine i think Andrew already pulled version i posted earlier.

> 
> Fixes: 8315ada7f095 ("mm/migrate: allow migrate_vma() to alloc new page on empty entry")
> Cc: Jerome Glisse <jglisse@redhat.com>
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  mm/migrate.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index dea0ceb..c4546cc 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2146,8 +2146,8 @@ static int migrate_vma_collect_hole(unsigned long start,
>  	unsigned long addr;
>  
>  	for (addr = start & PAGE_MASK; addr < end; addr += PAGE_SIZE) {
> -		migrate->src[migrate->npages++] = MIGRATE_PFN_MIGRATE;
>  		migrate->dst[migrate->npages] = 0;
> +		migrate->src[migrate->npages++] = MIGRATE_PFN_MIGRATE;
>  		migrate->cpages++;
>  	}
>  
> -- 
> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
