Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C2EEB6B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 04:49:27 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id b13so3038950wgh.31
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 01:49:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si13853347wjy.47.2014.02.18.01.49.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 01:49:26 -0800 (PST)
Date: Tue, 18 Feb 2014 10:49:20 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH V6 ] mm readahead: Fix readahead fail for memoryless cpu
 and limit readahead pages
Message-ID: <20140218094920.GB29660@quack.suse.cz>
References: <1392708338-19685-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1392708338-19685-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, rientjes@google.com, Linus <torvalds@linux-foundation.org>, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 18-02-14 12:55:38, Raghavendra K T wrote:
> Currently max_sane_readahead() returns zero on the cpu having no local memory node
> which leads to readahead failure. Fix the readahead failure by returning
> minimum of (requested pages, 512). Users running application on a memory-less cpu
> which needs readahead such as streaming application see considerable boost in the
> performance.
> 
> Result:
> fadvise experiment with FADV_WILLNEED on a PPC machine having memoryless CPU
> with 1GB testfile ( 12 iterations) yielded around 46.66% improvement.
> 
> fadvise experiment with FADV_WILLNEED on a x240 machine with 1GB testfile
> 32GB* 4G RAM  numa machine ( 12 iterations) showed no impact on the normal
> NUMA cases w/ patch.
  Can you try one more thing please? Compare startup time of some big
executable (Firefox or LibreOffice come to my mind) for the patched and
normal kernel on a machine which wasn't hit by this NUMA issue. And don't
forget to do "echo 3 >/proc/sys/vm/drop_caches" before each test to flush
the caches. If this doesn't show significant differences, I'm OK with the
patch.

								Honza

> Kernel     Avg  Stddev
> base	7.4975	3.92%
> patched	7.4174  3.26%
> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> [Andrew: making return value PAGE_SIZE independent]
> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> ---
>  I would like to thank Honza, David for their valuable suggestions and 
>  patiently reviewing the patches.
> 
>  Changes in V6:
>   - Just limit the readahead to 2MB on 4k pages system as suggested by Linus.
>  and make it independent of PAGE_SIZE. 
> 
>  Changes in V5:
>  - Drop the 4k limit for normal readahead. (Jan Kara)
> 
>  Changes in V4:
>  - Check for total node memory to decide whether we don't
>    have local memory (jan Kara)
>  - Add 4k page limit on readahead for normal and remote readahead (Linus)
>    (Linus suggestion was 16MB limit).
> 
>  Changes in V3:
>  - Drop iterating over numa nodes that calculates total free pages (Linus)
> 
>  Agree that we do not have control on allocation for readahead on a
>  particular numa node and hence for remote readahead we can not further
>  sanitize based on potential free pages of that node. and also we do
>  not want to itererate through all nodes to find total free pages.
> 
>  Suggestions and comments welcome
>  mm/readahead.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 0de2360..1fa0d6f 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -233,14 +233,14 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  	return 0;
>  }
>  
> +#define MAX_READAHEAD   ((512*4096)/PAGE_CACHE_SIZE)
>  /*
>   * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
>   * sensible upper limit.
>   */
>  unsigned long max_sane_readahead(unsigned long nr)
>  {
> -	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
> -		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
> +	return min(nr, MAX_READAHEAD);
>  }
>  
>  /*
> -- 
> 1.7.11.7
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
