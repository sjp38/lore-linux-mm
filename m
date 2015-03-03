Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 97B236B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 08:36:48 -0500 (EST)
Received: by lbiz11 with SMTP id z11so11122568lbi.3
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 05:36:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mz12si2799115wic.68.2015.03.03.05.36.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 05:36:46 -0800 (PST)
Date: Tue, 3 Mar 2015 14:36:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fix anon_vma->degree underflow in anon_vma endless
 growing prevention
Message-ID: <20150303133642.GC2409@dhcp22.suse.cz>
References: <1425384142-5064-1-git-send-email-chianglungyu@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425384142-5064-1-git-send-email-chianglungyu@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Yu <chianglungyu@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Tue 03-03-15 20:02:15, Leon Yu wrote:
> I have constantly stumbled upon "kernel BUG at mm/rmap.c:399!" after upgrading
> to 3.19 and had no luck with 4.0-rc1 neither.
> 
> So, after looking into new logic introduced by commit 7a3ef208e662, ("mm:
> prevent endless growth of anon_vma hierarchy"), I found chances are that
> unlink_anon_vmas() is called without incrementing dst->anon_vma->degree in
> anon_vma_clone() due to allocation failure. If dst->anon_vma is not NULL in
> error path, its degree will be incorrectly decremented in unlink_anon_vmas()
> and eventually underflow when exiting as a result of another call to
> unlink_anon_vmas(). That's how "kernel BUG at mm/rmap.c:399!" is triggered
> for me.
> 
> This patch fixes the underflow by dropping dst->anon_vma when allocation
> fails. It's safe to do so regardless of original value of dst->anon_vma
> because dst->anon_vma doesn't have valid meaning if anon_vma_clone() fails.
> Besides, callers don't care dst->anon_vma in such case neither.
> 
> Signed-off-by: Leon Yu <chianglungyu@gmail.com>
> Fixes: 7a3ef208e662 ("mm: prevent endless growth of anon_vma hierarchy")
> Cc: stable@vger.kernel.org # v3.19

Reviewed-by: Michal Hocko <mhocko@suse.cz>

I think we can safely remove the following code as well, because it is
anon_vma_clone which is responsible to do all the cleanups.

diff --git a/mm/mmap.c b/mm/mmap.c
index 943c6ad18b1d..06a6076c92e5 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -774,10 +774,8 @@ again:			remove_next = 1 + (end > next->vm_end);
 
 			importer->anon_vma = exporter->anon_vma;
 			error = anon_vma_clone(importer, exporter);
-			if (error) {
-				importer->anon_vma = NULL;
+			if (error)
 				return error;
-			}
 		}
 	}
 

> ---
>  mm/rmap.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 5e3e090..bed3cf2 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -287,6 +287,13 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
>  	return 0;
>  
>   enomem_failure:
> +	/*
> +	 * dst->anon_vma is dropped here otherwise its degree can be incorrectly
> +	 * decremented in unlink_anon_vmas().
> +	 * We can safely do this because calllers of anon_vma_clone() wouldn't
> +	 * care dst->anon_vma if anon_vma_clone() failed.
> +	 */
> +	dst->anon_vma = NULL;
>  	unlink_anon_vmas(dst);
>  	return -ENOMEM;
>  }
> -- 
> 2.3.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
