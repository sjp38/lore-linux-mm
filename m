Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1857B6B0072
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 06:31:53 -0500 (EST)
Received: by mail-ie0-f182.google.com with SMTP id y20so496823ier.27
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 03:31:52 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id pg8si2961844icb.122.2014.02.28.03.31.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Feb 2014 03:31:52 -0800 (PST)
Date: Fri, 28 Feb 2014 12:31:46 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V3] mm: numa: bugfix for LAST_CPUPID_NOT_IN_PAGE_FLAGS
Message-ID: <20140228113146.GJ27965@twins.programming.kicks-ass.net>
References: <1393578122-6500-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1393578122-6500-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Liu Ping Fan <pingfank@linux.vnet.ibm.com>

On Fri, Feb 28, 2014 at 02:32:02PM +0530, Aneesh Kumar K.V wrote:
> From: Liu Ping Fan <pingfank@linux.vnet.ibm.com>
> 
> When doing some numa tests on powerpc, I triggered an oops bug. I find
> it is caused by using page->_last_cpupid.  It should be initialized as
> "-1 & LAST_CPUPID_MASK", but not "-1". Otherwise, in task_numa_fault(),
> we will miss the checking (last_cpupid == (-1 & LAST_CPUPID_MASK)).
> And finally cause an oops bug in task_numa_group(), since the online cpu is
> less than possible cpu. This happen with CONFIG_SPARSE_VMEMMAP disabled
> 
> Signed-off-by: Liu Ping Fan <pingfank@linux.vnet.ibm.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


Acked-by: Peter Zijlstra <peterz@infradead.org>

> ---
>   
>  include/linux/mm.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f28f46eade6a..86245839c9fa 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -757,7 +757,7 @@ static inline bool __cpupid_match_pid(pid_t task_pid, int cpupid)
>  #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
>  static inline int page_cpupid_xchg_last(struct page *page, int cpupid)
>  {
> -	return xchg(&page->_last_cpupid, cpupid);
> +	return xchg(&page->_last_cpupid, cpupid & LAST_CPUPID_MASK);
>  }
>  
>  static inline int page_cpupid_last(struct page *page)
> @@ -766,7 +766,7 @@ static inline int page_cpupid_last(struct page *page)
>  }
>  static inline void page_cpupid_reset_last(struct page *page)
>  {
> -	page->_last_cpupid = -1;
> +	page->_last_cpupid = -1 & LAST_CPUPID_MASK;
>  }
>  #else
>  static inline int page_cpupid_last(struct page *page)
> -- 
> 1.8.3.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
