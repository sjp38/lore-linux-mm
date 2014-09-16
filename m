Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id C39836B0035
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 16:51:50 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id x13so707935qcv.35
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 13:51:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x10si20495267qci.7.2014.09.16.13.51.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Sep 2014 13:51:49 -0700 (PDT)
Date: Tue, 16 Sep 2014 22:51:10 +0200
From: Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
Message-ID: <20140916205110.GA1273@potion.brq.redhat.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
 <54184078.4070505@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <54184078.4070505@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

2014-09-15 13:11-0700, Andres Lagar-Cavilla:
> +int kvm_get_user_page_retry(struct task_struct *tsk, struct mm_struct *mm,

The suffix '_retry' is not best suited for this.
On first reading, I imagined we will be retrying something from before,
possibly calling it in a loop, but we are actually doing the first and
last try in one call.

Hard to find something that conveys our lock-dropping mechanic,
'_polite' is my best candidate at the moment.

> +	int flags = FOLL_TOUCH | FOLL_HWPOISON |

(FOLL_HWPOISON wasn't used before, but it's harmless.)

2014-09-16 15:51+0200, Paolo Bonzini:
> Il 15/09/2014 22:11, Andres Lagar-Cavilla ha scritto:
> > @@ -1177,9 +1210,15 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
> >  		npages = get_user_page_nowait(current, current->mm,
> >  					      addr, write_fault, page);
> >  		up_read(&current->mm->mmap_sem);
> > -	} else
> > -		npages = get_user_pages_fast(addr, 1, write_fault,
> > -					     page);
> > +	} else {
> > +		/*
> > +		 * By now we have tried gup_fast, and possible async_pf, and we
                                        ^
(If we really tried get_user_pages_fast, we wouldn't be here, so I'd
 prepend two underscores here as well.)

> > +		 * are certainly not atomic. Time to retry the gup, allowing
> > +		 * mmap semaphore to be relinquished in the case of IO.
> > +		 */
> > +		npages = kvm_get_user_page_retry(current, current->mm, addr,
> > +						 write_fault, page);
> 
> This is a separate logical change.  Was this:
> 
> 	down_read(&mm->mmap_sem);
> 	npages = get_user_pages(NULL, mm, addr, 1, 1, 0, NULL, NULL);
> 	up_read(&mm->mmap_sem);
> 
> the intention rather than get_user_pages_fast?

I believe so as well.

(Looking at get_user_pages_fast and __get_user_pages_fast made my
 abstraction detector very sad.)

> I think a first patch should introduce kvm_get_user_page_retry ("Retry a
> fault after a gup with FOLL_NOWAIT.") and the second would add
> FOLL_TRIED ("This properly relinquishes mmap semaphore if the
> filemap/swap has to wait on page lock (and retries the gup to completion
> after that").

Not sure if that would help to understand the goal ...

> Apart from this, the patch looks good.  The mm/ parts are minimal, so I
> think it's best to merge it through the KVM tree with someone's Acked-by.

I would prefer to have the last hunk in a separate patch, but still,

Acked-by: Radim KrA?mA!A? <rkrcmar@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
