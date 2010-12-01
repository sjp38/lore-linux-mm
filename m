Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CC7286B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 23:42:12 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB14g97w026633
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 13:42:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EF67E45DE5C
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 13:42:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C2AC045DE57
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 13:42:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B57F8E18005
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 13:42:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E643E18002
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 13:42:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] mlock: release mmap_sem every 256 faulted pages
In-Reply-To: <20101123050052.GA24039@google.com>
References: <20101123050052.GA24039@google.com>
Message-Id: <20101201134020.ABC8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Dec 2010 13:42:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@kernel.dk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


minor additionl comments.

> +		/*
> +		 * Limit batch size to 256 pages in order to reduce
> +		 * mmap_sem hold time.
> +		 */
> +		nfault = nstart + 256 * PAGE_SIZE;

You made 256 pages batch and __mlock_vma_pages_range() has 16 pages 
another batch.
Can we unify this two batch?

Plus, PeterZ implemeted mutex contention detect method (see "[PATCH 18/21] 
mutex: Provide mutex_is_contended"). now you can easily implemnt akpm proposed
efficient batching.

Thanks.


> +
> +		/*
> +		 * Now fault in a batch of pages. We need to check the vma
> +		 * flags again, as we've not been holding mmap_sem.
> +		 */
> +		if ((vma->vm_flags & (VM_DONTEXPAND | VM_RESERVED)) ||
> +		    is_vm_hugetlb_page(vma) || vma == get_gate_vma(current)) {
> +			if (nfault < nend)
> +				nend = nfault;
> +			make_pages_present(nstart, nend);
> +		} else if (vma->vm_flags & VM_LOCKED) {
> +			if (nfault < nend)
> +				nend = nfault;
> +			error = __mlock_vma_pages_range(vma, nstart, nend);
> +		}
> +	up:
> +		up_read(&mm->mmap_sem);
> +		if (error)
> +			return __mlock_posix_error_return(error);
> +	}
> +	return 0;
> +}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
