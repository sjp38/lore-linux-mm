Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9609A6B0083
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 01:10:43 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so210213wib.15
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 22:10:42 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id eg1si222668wib.76.2014.06.12.22.10.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 22:10:41 -0700 (PDT)
Date: Fri, 13 Jun 2014 01:10:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm/vmscan.c: wrap five parameters into shrink_result
 for reducing the stack consumption
Message-ID: <20140613051033.GM2878@cmpxchg.org>
References: <1402634191-3442-1-git-send-email-slaoub@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402634191-3442-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 13, 2014 at 12:36:31PM +0800, Chen Yucong wrote:
> shrink_page_list() has too many arguments that have already reached ten.
> Some of those arguments and temporary variables introduces extra 80 bytes
> on the stack. This patch wraps five parameters into shrink_result and removes
> some temporary variables, thus making the relative functions to consume fewer
> stack space.
> 
> Before mm/vmscan.c is changed:
>    text    data     bss     dec     hex filename
> 6876698  957224  966656 8800578  864942 vmlinux-3.15
> 
> After mm/vmscan.c is changed:
>    text    data     bss     dec     hex filename
> 6876506  957224  966656 8800386  864882 vmlinux-3.15
> 
> 
> scripts/checkstack.pl can be used for checking the change of the target function stack.
> 
> Before mm/vmscan.c is changed:
> 
> 0xffffffff810af103 shrink_inactive_list []:		152
> 0xffffffff810af43d shrink_inactive_list []:		152
> -------------------------------------------------------------
> 0xffffffff810aede8 reclaim_clean_pages_from_list []:	184
> 0xffffffff810aeef8 reclaim_clean_pages_from_list []:	184
> -------------------------------------------------------------
> 0xffffffff810ae582 shrink_page_list []:			232
> 0xffffffff810aedb5 shrink_page_list []:			232
> 
> After mm/vmscan.c is changed::
> 
> 0xffffffff810af078 shrink_inactive_list []:		120
> 0xffffffff810af36d shrink_inactive_list []:		120
> -------------------------------------------------------------
> 0xffffffff810aed6c reclaim_clean_pages_from_list []:	152
> 0xffffffff810aee68 reclaim_clean_pages_from_list []:	152
> --------------------------------------------------------------------------------------
> 0xffffffff810ae586 shrink_page_list []:			184   ---> sub    $0xb8,%rsp
> 0xffffffff810aed36 shrink_page_list []:			184   ---> add    $0xb8,%rsp
> 
> Via the above figures, we can find that the difference value of the stack is 32 for
> shrink_inactive_list and reclaim_clean_pages_from_list, and this value is 48(232-184)
> for shrink_page_list. From the hierarchy of functions called, the total difference
> value is 80(32+48) for this change.

We just increased the stack size by 8k.  I'm not saying that we
shouldn't work on our stack footprint, but is this really worth it?
It doesn't make that code easier to follow exactly.

> Changes since v1: https://lkml.org/lkml/2014/6/12/159
>      * Rename arg_container to shrink_result
>      * Change the the way of initializing shrink_result object.
> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>
> ---
>  mm/vmscan.c |   62 ++++++++++++++++++++++++++---------------------------------
>  1 file changed, 27 insertions(+), 35 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a8ffe4e..3f28e39 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -791,28 +791,31 @@ static void page_check_dirty_writeback(struct page *page,
>  }
>  
>  /*
> + * Callers pass a prezeroed shrink_result into the shrink functions to gather
> + * statistics about how many pages of particular states were processed
> + */
> +struct shrink_result {
> +	unsigned long nr_dirty;
> +	unsigned long nr_unqueued_dirty;
> +	unsigned long nr_congested;
> +	unsigned long nr_writeback;
> +	unsigned long nr_immediate;
> +};

This exclusively contains statistics on the writeback states of the
scanned pages.  struct writeback_stats?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
