Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 386686B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 10:07:14 -0400 (EDT)
Message-ID: <4CA5EB03.1070403@redhat.com>
Date: Fri, 01 Oct 2010 10:06:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] Release mmap_sem when page fault blocks on disk transfer.
References: <1285909484-30958-1-git-send-email-walken@google.com> <1285909484-30958-3-git-send-email-walken@google.com>
In-Reply-To: <1285909484-30958-3-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On 10/01/2010 01:04 AM, Michel Lespinasse wrote:
> This change reduces mmap_sem hold times that are caused by waiting for
> disk transfers when accessing file mapped VMAs. It introduces the
> VM_FAULT_RELEASED flag, which indicates that the call site holds mmap_lock
> and wishes for it to be released if blocking on a pending disk transfer.
> In that case, filemap_fault() returns the VM_FAULT_RELEASED status bit
> and do_page_fault() will then re-acquire mmap_sem and retry the page fault.
> It is expected that the retry will hit the same page which will now be cached,
> and thus it will complete with a low mmap_sem hold time.

The concept makes sense.  A nitpick, though...

> +	if (release_flag) {	/* Did not go through a retry */
> +		if (fault&  VM_FAULT_MAJOR) {
> +			tsk->maj_flt++;
> +			perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ, 1, 0,
> +				      regs, address);
> +		} else {
> +			tsk->min_flt++;
> +			perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN, 1, 0,
> +				      regs, address);
> +		}
> +		if (fault&  VM_FAULT_RELEASED) {
> +			/*
> +			 * handle_mm_fault() found that the desired page was
> +			 * locked. We asked for it to release mmap_sem in that
> +			 * case, so as to avoid holding it for too long.
> +			 * Retry starting at the mmap_sem acquire, this time
> +			 * without FAULT_FLAG_RETRY so that we avoid any
> +			 * risk of starvation.
> +			 */
> +			release_flag = 0;
> +			goto retry;
> +		}

Do we really want to count a minor page fault when we
got VM_FAULT_RELEASED?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
