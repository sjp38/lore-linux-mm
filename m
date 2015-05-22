Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A742C829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 16:18:24 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so27428773pdf.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 13:18:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tt6si4914574pac.36.2015.05.22.13.18.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 13:18:23 -0700 (PDT)
Date: Fri, 22 May 2015 13:18:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 22/23] userfaultfd: avoid mmap_sem read recursion in
 mcopy_atomic
Message-Id: <20150522131822.74f374dd5a75a0285577c714@linux-foundation.org>
In-Reply-To: <1431624680-20153-23-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
	<1431624680-20153-23-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Thu, 14 May 2015 19:31:19 +0200 Andrea Arcangeli <aarcange@redhat.com> wrote:

> If the rwsem starves writers it wasn't strictly a bug but lockdep
> doesn't like it and this avoids depending on lowlevel implementation
> details of the lock.
> 
> ...
>
> @@ -229,13 +246,33 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  
>  		if (!zeropage)
>  			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
> -					       dst_addr, src_addr);
> +					       dst_addr, src_addr, &page);
>  		else
>  			err = mfill_zeropage_pte(dst_mm, dst_pmd, dst_vma,
>  						 dst_addr);
>  
>  		cond_resched();
>  
> +		if (unlikely(err == -EFAULT)) {
> +			void *page_kaddr;
> +
> +			BUILD_BUG_ON(zeropage);

I'm not sure what this is trying to do.  BUILD_BUG_ON(local_variable)?

It goes bang in my build.  I'll just delete it.

> +			up_read(&dst_mm->mmap_sem);
> +			BUG_ON(!page);
> +
> +			page_kaddr = kmap(page);
> +			err = copy_from_user(page_kaddr,
> +					     (const void __user *) src_addr,
> +					     PAGE_SIZE);
> +			kunmap(page);
> +			if (unlikely(err)) {
> +				err = -EFAULT;
> +				goto out;
> +			}
> +			goto retry;
> +		} else
> +			BUG_ON(page);
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
