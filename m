Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 254BA6B0099
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 13:01:46 -0500 (EST)
Received: by yhoa41 with SMTP id a41so26563571yho.9
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 10:01:45 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id f188si4098123ykd.88.2015.03.05.10.01.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 10:01:44 -0800 (PST)
Message-ID: <54F899F2.6000904@parallels.com>
Date: Thu, 5 Mar 2015 21:01:22 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 19/21] userfaultfd: remap_pages: UFFDIO_REMAP preparation
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com> <1425575884-2574-20-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-20-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

> +ssize_t remap_pages(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> +		    unsigned long dst_start, unsigned long src_start,
> +		    unsigned long len, __u64 mode)
> +{
> +	struct vm_area_struct *src_vma, *dst_vma;
> +	long err = -EINVAL;
> +	pmd_t *src_pmd, *dst_pmd;
> +	pte_t *src_pte, *dst_pte;
> +	spinlock_t *dst_ptl, *src_ptl;
> +	unsigned long src_addr, dst_addr;
> +	int thp_aligned = -1;
> +	ssize_t moved = 0;
> +
> +	/*
> +	 * Sanitize the command parameters:
> +	 */
> +	BUG_ON(src_start & ~PAGE_MASK);
> +	BUG_ON(dst_start & ~PAGE_MASK);
> +	BUG_ON(len & ~PAGE_MASK);
> +
> +	/* Does the address range wrap, or is the span zero-sized? */
> +	BUG_ON(src_start + len <= src_start);
> +	BUG_ON(dst_start + len <= dst_start);
> +
> +	/*
> +	 * Because these are read sempahores there's no risk of lock
> +	 * inversion.
> +	 */
> +	down_read(&dst_mm->mmap_sem);
> +	if (dst_mm != src_mm)
> +		down_read(&src_mm->mmap_sem);
> +
> +	/*
> +	 * Make sure the vma is not shared, that the src and dst remap
> +	 * ranges are both valid and fully within a single existing
> +	 * vma.
> +	 */
> +	src_vma = find_vma(src_mm, src_start);
> +	if (!src_vma || (src_vma->vm_flags & VM_SHARED))
> +		goto out;
> +	if (src_start < src_vma->vm_start ||
> +	    src_start + len > src_vma->vm_end)
> +		goto out;
> +
> +	dst_vma = find_vma(dst_mm, dst_start);
> +	if (!dst_vma || (dst_vma->vm_flags & VM_SHARED))
> +		goto out;

I again have a concern about the case when one task monitors the VM of the
other one. If the target task (owning the mm) unmaps a VMA then the monitor
task (holding and operating on the ufd) will get plain EINVAL on UFFDIO_REMAP
request. This is not fatal, but still inconvenient as it will be hard to
find out the reason for failure -- dst VMA is removed and the monitor should
just drop the respective pages with data, or some other error has occurred
and some other actions should be taken.

Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
