Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F397C6B025F
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 15:55:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c5so20506564pfc.2
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 12:55:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id kb6si2025488pab.202.2016.07.26.12.55.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 12:55:02 -0700 (PDT)
Date: Tue, 26 Jul 2016 12:55:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kexec: add restriction on kexec_load() segment sizes
Message-Id: <20160726125501.69c8186ab9c3b1cef89899d4@linux-foundation.org>
In-Reply-To: <1469502219-24140-1-git-send-email-zhongjiang@huawei.com>
References: <1469502219-24140-1-git-send-email-zhongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: ebiederm@xmission.com, linux-mm@kvack.org, mm-commits@vger.kernel.org

On Tue, 26 Jul 2016 11:03:39 +0800 zhongjiang <zhongjiang@huawei.com> wrote:

> From: zhong jiang <zhongjiang@huawei.com>
> 
> I hit the following issue when run trinity in my system.  The kernel is
> 3.4 version, but mainline has the same issue.
> 
> The root cause is that the segment size is too large so the kerenl spends
> too long trying to allocate a page.  Other cases will block until the test
> case quits.  Also, OOM conditions will occur.
> 
> Call Trace:
>  [<ffffffff81106eac>] __alloc_pages_nodemask+0x14c/0x8f0
>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>  [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>  [<ffffffff8113e5ef>] alloc_pages_current+0xaf/0x120
>  [<ffffffff810a0da0>] kimage_alloc_pages+0x10/0x60
>  [<ffffffff810a15ad>] kimage_alloc_control_pages+0x5d/0x270
>  [<ffffffff81027e85>] machine_kexec_prepare+0xe5/0x6c0
>  [<ffffffff810a0d52>] ? kimage_free_page_list+0x52/0x70
>  [<ffffffff810a1921>] sys_kexec_load+0x141/0x600
>  [<ffffffff8115e6b0>] ? vfs_write+0x100/0x180
>  [<ffffffff8145fbd9>] system_call_fastpath+0x16/0x1b
> 
> The patch changes sanity_check_segment_list() to verify that no segment is
> larger than half of memory.

"to verify that the usage by all segmetns does not exceed half of memory"

> Suggested-off-by: Eric W. Biederman <ebiederm@xmission.com>

"Suggested-by:"

> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -140,6 +140,7 @@ int kexec_should_crash(struct task_struct *p)
>   * allocating pages whose destination address we do not care about.
>   */
>  #define KIMAGE_NO_DEST	(-1UL)
> +#define PAGE_COUNT(x)	(((x) + PAGE_SIZE - 1) >> PAGE_SHIFT)
>  
>  static struct page *kimage_alloc_page(struct kimage *image,
>  				       gfp_t gfp_mask,
> @@ -149,6 +150,7 @@ int sanity_check_segment_list(struct kimage *image)
>  {
>  	int result, i;
>  	unsigned long nr_segments = image->nr_segments;
> +	unsigned long total_segments = 0;

"total_segments" implies "total number of segments".  ie, nr_segments. 
I'd call this "total_pages" instead.

>  	/*
>  	 * Verify we have good destination addresses.  The caller is
> @@ -210,6 +212,23 @@ int sanity_check_segment_list(struct kimage *image)
>  	}
> 
> +	/*
> +	 * Verify that no segment is larger than half of memory.
> +	 * If a segment from userspace is too large, a large amount
> +	 * of time will be wasted allocating pages, which can cause
> +	 * a soft lockup.
> +	 */

	/*
	 * Verify that the memory usage required for all segments does not
	 * exceed half of all memory.  If the memory usage requested by
	 * userspace is excessive, a large amount of time will be wasted
	 * allocating pages, which can cause a soft lockup.
	 */
	
> +	for (i = 0; i < nr_segments; i++) {
> +		if (PAGE_COUNT(image->segment[i].memsz) > totalram_pages / 2
> +				|| PAGE_COUNT(total_segments) > totalram_pages / 2)
> +			return result;

And I don't think we need this?  Unless we're worried about the sum of
all segments overflowing an unsigned long, which I guess is possible. 
But if we care about that we should handle it in the next statement:

> +		total_segments += image->segment[i].memsz;

Should this be 

		total_pages += PAGE_COUNT(image->segment[i].memsz);

?  I think "yes", if the segments are allocated separately and "no" if
they are all allocated in a big blob.

And it is after this statement that we should check for arithmetic
overflow.

> +	}
> +
> +	if (PAGE_COUNT(total_segments) > totalram_pages / 2)
> +		return result;
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
