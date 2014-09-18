Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2A96B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 20:27:48 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id ey11so198427pad.20
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 17:27:48 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id v4si37257510pdl.30.2014.09.17.17.27.43
        for <linux-mm@kvack.org>;
        Wed, 17 Sep 2014 17:27:43 -0700 (PDT)
Date: Thu, 18 Sep 2014 08:29:17 +0800
From: Wanpeng Li <wanpeng.li@linux.intel.com>
Subject: Re: [PATCH v2] kvm: Faults which trigger IO release the mmap_sem
Message-ID: <20140918002917.GA3921@kernel>
Reply-To: Wanpeng Li <wanpeng.li@linux.intel.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
 <1410976308-7683-1-git-send-email-andreslc@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1410976308-7683-1-git-send-email-andreslc@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Andres,
On Wed, Sep 17, 2014 at 10:51:48AM -0700, Andres Lagar-Cavilla wrote:
[...]
> static inline int check_user_page_hwpoison(unsigned long addr)
> {
> 	int rc, flags = FOLL_TOUCH | FOLL_HWPOISON | FOLL_WRITE;
>@@ -1177,9 +1214,15 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
> 		npages = get_user_page_nowait(current, current->mm,
> 					      addr, write_fault, page);
> 		up_read(&current->mm->mmap_sem);
>-	} else
>-		npages = get_user_pages_fast(addr, 1, write_fault,
>-					     page);
>+	} else {
>+		/*
>+		 * By now we have tried gup_fast, and possibly async_pf, and we
>+		 * are certainly not atomic. Time to retry the gup, allowing
>+		 * mmap semaphore to be relinquished in the case of IO.
>+		 */
>+		npages = kvm_get_user_page_io(current, current->mm, addr,
>+					      write_fault, page);
>+	}

try_async_pf 
 gfn_to_pfn_async 
  __gfn_to_pfn  			async = false 
   __gfn_to_pfn_memslot
    hva_to_pfn 
	 hva_to_pfn_fast 
	 hva_to_pfn_slow 
	  kvm_get_user_page_io

page will always be ready after kvm_get_user_page_io which leads to APF
don't need to work any more.

Regards,
Wanpeng Li

> 	if (npages != 1)
> 		return npages;
> 
>-- 
>2.1.0.rc2.206.gedb03e5
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
