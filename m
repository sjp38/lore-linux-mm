Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id E44CB6B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 09:52:02 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id i50so5570360qgf.34
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 06:52:02 -0700 (PDT)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id v3si19112863qap.120.2014.09.16.06.52.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 06:52:00 -0700 (PDT)
Received: by mail-qa0-f53.google.com with SMTP id n8so5529087qaq.40
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 06:52:00 -0700 (PDT)
Message-ID: <54184078.4070505@redhat.com>
Date: Tue, 16 Sep 2014 15:51:52 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
In-Reply-To: <1410811885-17267-1-git-send-email-andreslc@google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Il 15/09/2014 22:11, Andres Lagar-Cavilla ha scritto:
> +	if (!locked) {
> +		BUG_ON(npages != -EBUSY);

VM_BUG_ON perhaps?

> @@ -1177,9 +1210,15 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
>  		npages = get_user_page_nowait(current, current->mm,
>  					      addr, write_fault, page);
>  		up_read(&current->mm->mmap_sem);
> -	} else
> -		npages = get_user_pages_fast(addr, 1, write_fault,
> -					     page);
> +	} else {
> +		/*
> +		 * By now we have tried gup_fast, and possible async_pf, and we
> +		 * are certainly not atomic. Time to retry the gup, allowing
> +		 * mmap semaphore to be relinquished in the case of IO.
> +		 */
> +		npages = kvm_get_user_page_retry(current, current->mm, addr,
> +						 write_fault, page);

This is a separate logical change.  Was this:

	down_read(&mm->mmap_sem);
	npages = get_user_pages(NULL, mm, addr, 1, 1, 0, NULL, NULL);
	up_read(&mm->mmap_sem);

the intention rather than get_user_pages_fast?

I think a first patch should introduce kvm_get_user_page_retry ("Retry a
fault after a gup with FOLL_NOWAIT.") and the second would add
FOLL_TRIED ("This properly relinquishes mmap semaphore if the
filemap/swap has to wait on page lock (and retries the gup to completion
after that").

Apart from this, the patch looks good.  The mm/ parts are minimal, so I
think it's best to merge it through the KVM tree with someone's Acked-by.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
