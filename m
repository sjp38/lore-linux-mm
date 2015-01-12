Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id CA8716B0032
	for <linux-mm@kvack.org>; Mon, 12 Jan 2015 04:50:49 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so12697386wib.1
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 01:50:49 -0800 (PST)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id p16si12757163wiw.104.2015.01.12.01.50.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Jan 2015 01:50:48 -0800 (PST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so13364615wid.0
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 01:50:48 -0800 (PST)
Date: Mon, 12 Jan 2015 10:50:46 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fix corner case in anon_vma endless growing
 prevention
Message-ID: <20150112095046.GB4877@dhcp22.suse.cz>
References: <20150111135406.13266.42007.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150111135406.13266.42007.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, "Elifaz, Dana" <Dana.Elifaz@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>, Chris Clayton <chris2553@googlemail.com>, Oded Gabbay <oded.gabbay@amd.com>

On Sun 11-01-15 16:54:06, Konstantin Khlebnikov wrote:
> Fix for BUG_ON(anon_vma->degree) splashes in unlink_anon_vmas()
> ("kernel BUG at mm/rmap.c:399!").
> 
> Anon_vma_clone() is usually called for a copy of source vma in destination
> argument. If source vma has anon_vma it should be already in dst->anon_vma.
> NULL in dst->anon_vma is used as a sign that it's called from anon_vma_fork().
> In this case anon_vma_clone() finds anon_vma for reusing.
> 
> Vma_adjust() calls it differently and this breaks anon_vma reusing logic:
> anon_vma_clone() links vma to old anon_vma and updates degree counters but
> vma_adjust() overrides vma->anon_vma right after that. As a result final
> unlink_anon_vmas() decrements degree for wrong anon_vma.
> 
> This patch assigns ->anon_vma before calling anon_vma_clone().
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> Fixes: 7a3ef208e662 ("mm: prevent endless growth of anon_vma hierarchy")
> Tested-by: Chris Clayton <chris2553@googlemail.com>
> Tested-by: Oded Gabbay <oded.gabbay@amd.com>
> Cc: Daniel Forrest <dan.forrest@ssec.wisc.edu>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Rik van Riel <riel@redhat.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/mmap.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 7b36aa7..12616c5 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -778,10 +778,12 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		if (exporter && exporter->anon_vma && !importer->anon_vma) {
>  			int error;
>  
> +			importer->anon_vma = exporter->anon_vma;
>  			error = anon_vma_clone(importer, exporter);
> -			if (error)
> +			if (error) {
> +				importer->anon_vma = NULL;
>  				return error;
> -			importer->anon_vma = exporter->anon_vma;
> +			}
>  		}
>  	}
>  
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
