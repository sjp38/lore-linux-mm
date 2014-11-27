Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 671876B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 04:13:21 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so7583714wiv.13
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 01:13:20 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gr2si12024311wib.74.2014.11.27.01.13.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Nov 2014 01:13:20 -0800 (PST)
Date: Thu, 27 Nov 2014 10:13:17 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3] mm: prevent endless growth of anon_vma hierarchy
Message-ID: <20141127091317.GA19157@dhcp22.suse.cz>
References: <20141126191145.3089.90947.stgit@zurg>
 <20141126210559.GA12060@cosmos.ssec.wisc.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141126210559.GA12060@cosmos.ssec.wisc.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Tim Hartrick <tim@edgecast.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>

On Wed 26-11-14 15:05:59, Daniel Forrest wrote:
> On Wed, Nov 26, 2014 at 10:11:45PM +0400, Konstantin Khlebnikov wrote:
> 
> > Constantly forking task causes unlimited grow of anon_vma chain.
> > Each next child allocate new level of anon_vmas and links vmas to all
> > previous levels because it inherits pages from them. None of anon_vmas
> > cannot be freed because there might be pages which points to them.
> > 
> > This patch adds heuristic which decides to reuse existing anon_vma instead
> > of forking new one. It counts vmas and direct descendants for each anon_vma.
> > Anon_vma with degree lower than two will be reused at next fork.
> > 
> > As a result each anon_vma has either alive vma or at least two descendants,
> > endless chains are no longer possible and count of anon_vmas is no more than
> > two times more than count of vmas.
> 
> While I was working on the previous fix for this bug, Andrew Morton
> noticed that the error return from anon_vma_clone() was being dropped
> and replaced with -ENOMEM (which is not itself a bug because the only
> error return value from anon_vma_clone() is -ENOMEM).
> 
> I did an audit of callers of anon_vma_clone() and discovered an actual
> bug where the error return was being lost.  In __split_vma(), between
> Linux 3.11 and 3.12 the code was changed so the err variable is used
> before the call to anon_vma_clone() and the default initial value of
> -ENOMEM is overwritten.  So a failure of anon_vma_clone() will return
> success since err at this point is now zero.
> 
> Below is a patch which fixes this bug and also propagates the error
> return value from anon_vma_clone() in all cases.
> 
> I can send this as a separate patch, but maybe it would be easier if
> you were to incorporate it into yours?

I would prefer two patches as they address two different things and also
target different set of stable trees.

> Signed-off-by: Daniel Forrest <dan.forrest@ssec.wisc.edu>

Fixes: ef0855d334e1 (mm: mempolicy: turn vma_set_policy() into vma_dup_policy())

and mark for stable (3.12+) please.

Feel free to add
Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> 
> ---
>  mmap.c |   10 +++++++---
>  rmap.c |    6 ++++--
>  2 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff -rup a/mm/mmap.c b/mm/mmap.c
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -776,8 +776,11 @@ again:			remove_next = 1 + (end > next->
>  		 * shrinking vma had, to cover any anon pages imported.
>  		 */
>  		if (exporter && exporter->anon_vma && !importer->anon_vma) {
> -			if (anon_vma_clone(importer, exporter))
> -				return -ENOMEM;
> +			int error;
> +
> +			error = anon_vma_clone(importer, exporter);
> +			if (error)
> +				return error;
>  			importer->anon_vma = exporter->anon_vma;
>  		}
>  	}
> @@ -2469,7 +2472,8 @@ static int __split_vma(struct mm_struct 
>  	if (err)
>  		goto out_free_vma;
>  
> -	if (anon_vma_clone(new, vma))
> +	err = anon_vma_clone(new, vma);
> +	if (err)
>  		goto out_free_mpol;
>  
>  	if (new->vm_file)
> diff -rup a/mm/rmap.c b/mm/rmap.c
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -274,6 +274,7 @@ int anon_vma_fork(struct vm_area_struct 
>  {
>  	struct anon_vma_chain *avc;
>  	struct anon_vma *anon_vma;
> +	int error;
>  
>  	/* Don't bother if the parent process has no anon_vma here. */
>  	if (!pvma->anon_vma)
> @@ -283,8 +284,9 @@ int anon_vma_fork(struct vm_area_struct 
>  	 * First, attach the new VMA to the parent VMA's anon_vmas,
>  	 * so rmap can find non-COWed pages in child processes.
>  	 */
> -	if (anon_vma_clone(vma, pvma))
> -		return -ENOMEM;
> +	error = anon_vma_clone(vma, pvma);
> +	if (error)
> +		return error;
>  
>  	/* Then add our own anon_vma. */
>  	anon_vma = anon_vma_alloc();
> 
> -- 
> Daniel K. Forrest		Space Science and
> dan.forrest@ssec.wisc.edu	Engineering Center
> (608) 890 - 0558		University of Wisconsin, Madison
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
