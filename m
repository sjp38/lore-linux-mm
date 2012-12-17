Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 84C916B002B
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 15:49:51 -0500 (EST)
Date: Mon, 17 Dec 2012 12:49:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Suppress mm/memory.o warning on older compilers if
 !CONFIG_NUMA_BALANCING
Message-Id: <20121217124949.3024dda3.akpm@linux-foundation.org>
In-Reply-To: <20121217114917.GF9887@suse.de>
References: <20121217114917.GF9887@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kbuild test robot <fengguang.wu@intel.com>

On Mon, 17 Dec 2012 11:49:17 +0000
Mel Gorman <mgorman@suse.de> wrote:

> The kbuild test robot reported the following after the merge of Automatic
> NUMA Balancing when cross-compiling for avr32.
> 
> mm/memory.c: In function 'do_pmd_numa_page':
> mm/memory.c:3593: warning: no return statement in function returning non-void
> 
> The code is unreachable but the avr32 cross-compiler was not new enough
> to know that. This patch suppresses the warning.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/memory.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e6a3b93..23f1fdf 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3590,6 +3590,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		     unsigned long addr, pmd_t *pmdp)
>  {
>  	BUG();
> +	return 0;
>  }
>  #endif /* CONFIG_NUMA_BALANCING */

Odd.  avr32's BUG() includes a call to unreachable(), which should
evaluate to "do { } while (1)".  Can you check that this is working?

Perhaps it _is_ working, but the compiler incorrectly thinks that the
function can return?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
