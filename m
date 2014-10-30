Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id C2F3290008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 08:18:15 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id gq15so4342916lab.35
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 05:18:15 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id ej7si11797264lad.34.2014.10.30.05.18.13
        for <linux-mm@kvack.org>;
        Thu, 30 Oct 2014 05:18:13 -0700 (PDT)
Date: Thu, 30 Oct 2014 14:17:37 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/5] mm: gup: add __get_user_pages_unlocked to customize
 gup_flags
Message-ID: <20141030121737.GB31134@node.dhcp.inet.fi>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
 <1414600520-7664-3-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414600520-7664-3-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Wed, Oct 29, 2014 at 05:35:17PM +0100, Andrea Arcangeli wrote:
> Some caller (like KVM) may want to set the gup_flags like
> FOLL_HWPOSION to get a proper -EHWPOSION retval instead of -EFAULT to
> take a more appropriate action if get_user_pages runs into a memory
> failure.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/mm.h |  4 ++++
>  mm/gup.c           | 44 ++++++++++++++++++++++++++++++++------------
>  mm/nommu.c         | 16 +++++++++++++---
>  3 files changed, 49 insertions(+), 15 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 99831d9..9a5ada3 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1222,6 +1222,10 @@ long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
>  		    unsigned long start, unsigned long nr_pages,
>  		    int write, int force, struct page **pages,
>  		    int *locked);
> +long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> +			       unsigned long start, unsigned long nr_pages,
> +			       int write, int force, struct page **pages,
> +			       unsigned int gup_flags);
>  long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
>  		    unsigned long start, unsigned long nr_pages,
>  		    int write, int force, struct page **pages);
> diff --git a/mm/gup.c b/mm/gup.c
> index a8521f1..01534ff 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -591,9 +591,9 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
>  						int write, int force,
>  						struct page **pages,
>  						struct vm_area_struct **vmas,
> -						int *locked, bool notify_drop)
> +						int *locked, bool notify_drop,
> +						unsigned int flags)

Argument list getting too long. Should we consider packing them into a
struct?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
