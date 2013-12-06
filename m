Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 161016B0095
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 13:44:03 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id c9so791127qcz.30
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 10:44:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id i2si2841462qaz.76.2013.12.06.10.44.01
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 10:44:01 -0800 (PST)
Date: Fri, 06 Dec 2013 13:43:57 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386355437-ly5a1ny8-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386319310-28016-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386319310-28016-2-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/4] mm/mempolicy: correct putback method for isolate
 pages if failed
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Joonsoo,

On Fri, Dec 06, 2013 at 05:41:48PM +0900, Joonsoo Kim wrote:
> queue_pages_range() isolates hugetlbfs pages and putback_lru_pages() can't
> handle these. We should change it to putback_movable_pages().
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Nice fix, thanks.
I think that this patch is worth going into -stable 3.12,
because it can break in-use hugepage list.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index eca4a31..6d04d37 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1318,7 +1318,7 @@ static long do_mbind(unsigned long start, unsigned long len,
>  		if (nr_failed && (flags & MPOL_MF_STRICT))
>  			err = -EIO;
>  	} else
> -		putback_lru_pages(&pagelist);
> +		putback_movable_pages(&pagelist);
>  
>  	up_write(&mm->mmap_sem);
>   mpol_out:
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
