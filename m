Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 72CB26B006C
	for <linux-mm@kvack.org>; Thu, 18 Sep 2014 02:13:31 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u57so342299wes.36
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 23:13:31 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
        by mx.google.com with ESMTPS id j2si30922445wjy.1.2014.09.17.23.13.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 23:13:30 -0700 (PDT)
Received: by mail-wi0-f169.google.com with SMTP id e4so1105427wiv.4
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 23:13:29 -0700 (PDT)
Date: Thu, 18 Sep 2014 09:13:26 +0300
From: Gleb Natapov <gleb@kernel.org>
Subject: Re: [PATCH v2] kvm: Faults which trigger IO release the mmap_sem
Message-ID: <20140918061326.GC30733@minantech.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
 <1410976308-7683-1-git-send-email-andreslc@google.com>
 <20140918002917.GA3921@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140918002917.GA3921@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@linux.intel.com>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Sep 18, 2014 at 08:29:17AM +0800, Wanpeng Li wrote:
> Hi Andres,
> On Wed, Sep 17, 2014 at 10:51:48AM -0700, Andres Lagar-Cavilla wrote:
> [...]
> > static inline int check_user_page_hwpoison(unsigned long addr)
> > {
> > 	int rc, flags = FOLL_TOUCH | FOLL_HWPOISON | FOLL_WRITE;
> >@@ -1177,9 +1214,15 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
> > 		npages = get_user_page_nowait(current, current->mm,
> > 					      addr, write_fault, page);
> > 		up_read(&current->mm->mmap_sem);
> >-	} else
> >-		npages = get_user_pages_fast(addr, 1, write_fault,
> >-					     page);
> >+	} else {
> >+		/*
> >+		 * By now we have tried gup_fast, and possibly async_pf, and we
> >+		 * are certainly not atomic. Time to retry the gup, allowing
> >+		 * mmap semaphore to be relinquished in the case of IO.
> >+		 */
> >+		npages = kvm_get_user_page_io(current, current->mm, addr,
> >+					      write_fault, page);
> >+	}
> 
> try_async_pf 
>  gfn_to_pfn_async 
>   __gfn_to_pfn  			async = false 
                                        *async = false

>    __gfn_to_pfn_memslot
>     hva_to_pfn 
> 	 hva_to_pfn_fast 
> 	 hva_to_pfn_slow 
hva_to_pfn_slow checks async not *async.

> 	  kvm_get_user_page_io
> 
> page will always be ready after kvm_get_user_page_io which leads to APF
> don't need to work any more.
> 
> Regards,
> Wanpeng Li
> 
> > 	if (npages != 1)
> > 		return npages;
> > 
> >-- 
> >2.1.0.rc2.206.gedb03e5
> >
> >--
> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >the body to majordomo@kvack.org.  For more info on Linux MM,
> >see: http://www.linux-mm.org/ .
> >Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
