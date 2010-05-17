Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EA05B6B01F9
	for <linux-mm@kvack.org>; Mon, 17 May 2010 09:21:23 -0400 (EDT)
Received: from f199130.upc-f.chello.nl ([80.56.199.130] helo=dyad.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1OE0Fz-00059k-77
	for linux-mm@kvack.org; Mon, 17 May 2010 13:21:19 +0000
Subject: Re: [PATCH] Split executable and non-executable mmap tracking
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1273223135-22695-1-git-send-email-ebmunson@us.ibm.com>
References: <1273223135-22695-1-git-send-email-ebmunson@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 17 May 2010 15:21:15 +0200
Message-ID: <1274102475.1674.1494.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: mingo@elte.hu, acme@redhat.com, arjan@linux.intel.com, anton@samba.org, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-05-07 at 10:05 +0100, Eric B Munson wrote:
> This patch splits tracking of executable and non-executable mmaps.
> Executable mmaps are tracked normally and non-executable are
> tracked when --data is used.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> 
> Updated code for stable perf ABI
> Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>

> +++ b/include/linux/perf_event.h
> @@ -197,6 +197,7 @@ struct perf_event_attr {
>  				exclude_hv     :  1, /* ditto hypervisor      */
>  				exclude_idle   :  1, /* don't count when idle */
>  				mmap           :  1, /* include mmap data     */
> +				mmap_exec      :  1, /* include exec mmap data*/
>  				comm	       :  1, /* include comm data     */
>  				freq           :  1, /* use freq, not period  */
>  				inherit_stat   :  1, /* per task counts       */

You cannot add a field in the middle, that breaks ABI.

> -static inline void perf_event_mmap(struct vm_area_struct *vma)
> -{
> -	if (vma->vm_flags & VM_EXEC)
> -		__perf_event_mmap(vma);
> -}

Also, the current behaviour of perf_event_attr::mmap() is to trace
VM_EXEC maps only, apps relying on that will be broken after this patch
because they'd have to set mmap_exec.

If you want to do this, you'll have to add mmap_data (to the tail of the
bitfield) and have that add !VM_EXEC mmap() tracing.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
