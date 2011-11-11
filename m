Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D2BE56B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 12:23:08 -0500 (EST)
Date: Fri, 11 Nov 2011 18:23:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] hugetlb: release pages in the error path of hugetlb_cow()
Message-ID: <20111111172301.GB4479@redhat.com>
References: <CAJd=RBC5Q48r0sYeqF9bucaBJPv3LR4UTAannUZ8KXxoXY_Qcw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBC5Q48r0sYeqF9bucaBJPv3LR4UTAannUZ8KXxoXY_Qcw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Nov 11, 2011 at 09:01:20PM +0800, Hillf Danton wrote:
> If fail to prepare anon_vma, {new, old}_page should be released, or they will
> escape the track and/or control of memory management.
> 
> Thanks
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/hugetlb.c	Fri Nov 11 20:36:32 2011
> +++ b/mm/hugetlb.c	Fri Nov 11 20:43:06 2011
> @@ -2422,6 +2422,8 @@ retry_avoidcopy:
>  	 * anon_vma prepared.
>  	 */
>  	if (unlikely(anon_vma_prepare(vma))) {
> +		page_cache_release(new_page);
> +		page_cache_release(old_page);
>  		/* Caller expects lock to be held */
>  		spin_lock(&mm->page_table_lock);
>  		return VM_FAULT_OOM;

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
