Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1E36B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 09:44:52 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id vb8so1502836obc.21
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:44:52 -0800 (PST)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id jb8si13640258obb.1.2013.12.11.06.44.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 06:44:51 -0800 (PST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 07:44:50 -0700
Received: from b03cxnp07027.gho.boulder.ibm.com (b03cxnp07027.gho.boulder.ibm.com [9.17.130.14])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id B8B9D19D8048
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 07:44:41 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBBCgecX6226248
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 13:42:40 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rBBElo8S000944
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 07:47:50 -0700
Date: Wed, 11 Dec 2013 06:44:47 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: numa: Guarantee that tlb_flush_pending updates are
 visible before page table updates
Message-ID: <20131211144446.GP4208@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
 <20131211132109.GB24125@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131211132109.GB24125@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 11, 2013 at 01:21:09PM +0000, Mel Gorman wrote:
> According to documentation on barriers, stores issued before a LOCK can
> complete after the lock implying that it's possible tlb_flush_pending can
> be visible after a page table update. As per revised documentation, this patch
> adds a smp_mb__before_spinlock to guarantee the correct ordering.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Assuming that there is a lock acquisition after calls to
set_tlb_flush_pending():

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

(I don't see set_tlb_flush_pending() in mainline.)

> ---
>  include/linux/mm_types.h | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index c122bb1..a12f2ab 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -482,7 +482,12 @@ static inline bool tlb_flush_pending(struct mm_struct *mm)
>  static inline void set_tlb_flush_pending(struct mm_struct *mm)
>  {
>  	mm->tlb_flush_pending = true;
> -	barrier();
> +
> +	/*
> +	 * Guarantee that the tlb_flush_pending store does not leak into the
> +	 * critical section updating the page tables
> +	 */
> +	smp_mb__before_spinlock();
>  }
>  /* Clearing is done after a TLB flush, which also provides a barrier. */
>  static inline void clear_tlb_flush_pending(struct mm_struct *mm)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
