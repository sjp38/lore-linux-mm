Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id D7974280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 15:07:01 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id h3so1503552igd.13
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 12:07:01 -0700 (PDT)
Received: from mail-ig0-x24a.google.com (mail-ig0-x24a.google.com. [2607:f8b0:4001:c05::24a])
        by mx.google.com with ESMTPS id o10si16785551ics.72.2014.10.31.12.07.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 12:07:00 -0700 (PDT)
Received: by mail-ig0-f202.google.com with SMTP id r10so213340igi.5
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 12:07:00 -0700 (PDT)
Date: Fri, 31 Oct 2014 12:06:58 -0700
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH 4/5] mm: gup: use get_user_pages_unlocked
Message-ID: <20141031190658.GA38315@google.com>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
 <1414600520-7664-5-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414600520-7664-5-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Wed, Oct 29, 2014 at 05:35:19PM +0100, Andrea Arcangeli wrote:
> This allows those get_user_pages calls to pass FAULT_FLAG_ALLOW_RETRY
> to the page fault in order to release the mmap_sem during the I/O.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Peter Feiner <pfeiner@google.com>

> diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
> index 5550130..096d914 100644
> --- a/net/ceph/pagevec.c
> +++ b/net/ceph/pagevec.c
> @@ -23,17 +23,15 @@ struct page **ceph_get_direct_page_vector(const void __user *data,
>  	if (!pages)
>  		return ERR_PTR(-ENOMEM);
>  
> -	down_read(&current->mm->mmap_sem);
>  	while (got < num_pages) {
> -		rc = get_user_pages(current, current->mm,
> +		rc = get_user_pages_unlocked(current, current->mm,
>  		    (unsigned long)data + ((unsigned long)got * PAGE_SIZE),
> -		    num_pages - got, write_page, 0, pages + got, NULL);
> +		    num_pages - got, write_page, 0, pages + got);
>  		if (rc < 0)
>  			break;
>  		BUG_ON(rc == 0);
>  		got += rc;
>  	}
> -	up_read(&current->mm->mmap_sem);
>  	if (rc < 0)
>  		goto fail;
>  	return pages;

I spent a while looking at this to make sure that BUG_ON(rc == 0) won't
trigger. AFAICT, __get_user_pages_locked can't return 0 since __get_user_pages
only returns 0 when nonblocking is not NULL; when __get_user_pages_locked
calls __get_user_pages with nonblocking != NULL (i.e., the first call in the
body of the for(;;) loop) and __get_user_pages returns 0, then
__get_user_pages_locked will call __get_user_pages again with nonblocking ==
NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
