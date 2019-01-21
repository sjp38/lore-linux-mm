Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D74538E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 11:25:07 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 42so21100877qtr.7
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 08:25:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u198si3787881qka.181.2019.01.21.08.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 08:25:06 -0800 (PST)
Date: Mon, 21 Jan 2019 11:24:55 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH RFC 04/24] mm: gup: allow VM_FAULT_RETRY for multiple
 times
Message-ID: <20190121162455.GC3711@redhat.com>
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-5-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190121075722.7945-5-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Mon, Jan 21, 2019 at 03:57:02PM +0800, Peter Xu wrote:
> This is the gup counterpart of the change that allows the VM_FAULT_RETRY
> to happen for more than once.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

So it would be nice to add a comment in the code and in the commit message
about possible fault starvation (mostly due to previous patch changes) as
if some one experience that and try to bisect it might overlook the commit.

Otherwise:

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  mm/gup.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 7b1f452cc2ef..22f1d419a849 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -528,7 +528,10 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
>  	if (*flags & FOLL_NOWAIT)
>  		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
>  	if (*flags & FOLL_TRIED) {
> -		VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
> +		/*
> +		 * Note: FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_TRIED
> +		 * can co-exist
> +		 */
>  		fault_flags |= FAULT_FLAG_TRIED;
>  	}
>  
> @@ -943,17 +946,23 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
>  		/* VM_FAULT_RETRY triggered, so seek to the faulting offset */
>  		pages += ret;
>  		start += ret << PAGE_SHIFT;
> +		lock_dropped = true;
>  
> +retry:
>  		/*
>  		 * Repeat on the address that fired VM_FAULT_RETRY
> -		 * without FAULT_FLAG_ALLOW_RETRY but with
> +		 * with both FAULT_FLAG_ALLOW_RETRY and
>  		 * FAULT_FLAG_TRIED.
>  		 */
>  		*locked = 1;
> -		lock_dropped = true;
>  		down_read(&mm->mmap_sem);
>  		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
> -				       pages, NULL, NULL);
> +				       pages, NULL, locked);
> +		if (!*locked) {
> +			/* Continue to retry until we succeeded */
> +			BUG_ON(ret != 0);
> +			goto retry;
> +		}
>  		if (ret != 1) {
>  			BUG_ON(ret > 1);
>  			if (!pages_done)
> -- 
> 2.17.1
> 
