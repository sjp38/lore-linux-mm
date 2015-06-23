Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A49D96B0032
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 15:00:21 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so12476879pac.2
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 12:00:21 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id a5si35950000pat.91.2015.06.23.12.00.20
        for <linux-mm@kvack.org>;
        Tue, 23 Jun 2015 12:00:20 -0700 (PDT)
Message-ID: <5589ACC3.3060401@intel.com>
Date: Tue, 23 Jun 2015 12:00:19 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/23] userfaultfd: add new syscall to provide memory
 externalization
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com> <1431624680-20153-11-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-11-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On 05/14/2015 10:31 AM, Andrea Arcangeli wrote:
> +static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
> +				     int wake_flags, void *key)
> +{
> +	struct userfaultfd_wake_range *range = key;
> +	int ret;
> +	struct userfaultfd_wait_queue *uwq;
> +	unsigned long start, len;
> +
> +	uwq = container_of(wq, struct userfaultfd_wait_queue, wq);
> +	ret = 0;
> +	/* don't wake the pending ones to avoid reads to block */
> +	if (uwq->pending && !ACCESS_ONCE(uwq->ctx->released))
> +		goto out;
> +	/* len == 0 means wake all */
> +	start = range->start;
> +	len = range->len;
> +	if (len && (start > uwq->address || start + len <= uwq->address))
> +		goto out;
> +	ret = wake_up_state(wq->private, mode);
> +	if (ret)
> +		/* wake only once, autoremove behavior */
> +		list_del_init(&wq->task_list);
> +out:
> +	return ret;
> +}
...
> +static __always_inline int validate_range(struct mm_struct *mm,
> +					  __u64 start, __u64 len)
> +{
> +	__u64 task_size = mm->task_size;
> +
> +	if (start & ~PAGE_MASK)
> +		return -EINVAL;
> +	if (len & ~PAGE_MASK)
> +		return -EINVAL;
> +	if (!len)
> +		return -EINVAL;
> +	if (start < mmap_min_addr)
> +		return -EINVAL;
> +	if (start >= task_size)
> +		return -EINVAL;
> +	if (len > task_size - start)
> +		return -EINVAL;
> +	return 0;
> +}

Hey Andrea,

Down in userfaultfd_wake_function(), it looks like you intended for a
len=0 to mean "wake all".  But the validate_range() that we do from
userspace has a !len check in it, which keeps us from passing a len=0 in
from userspace.

Was that "wake all" for some internal use, or is the check too strict?

I was trying to use the wake ioctl after an madvise() (as opposed to
filling things in using a userfd copy).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
