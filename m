Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id B21F36B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 22:00:45 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so6365716pde.24
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 19:00:45 -0700 (PDT)
Message-ID: <52390907.7050101@asianux.com>
Date: Wed, 18 Sep 2013 09:59:35 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] m: readahead: return the value which force_page_cache_readahead()
 returns
References: <5212E328.40804@asianux.com> <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org> <521428D0.2020708@asianux.com> <20130917155644.cc988e7e929fee10e9c86d86@linux-foundation.org>
In-Reply-To: <20130917155644.cc988e7e929fee10e9c86d86@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, rientjes@google.com, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

On 09/18/2013 06:56 AM, Andrew Morton wrote:
> On Wed, 21 Aug 2013 10:41:20 +0800 Chen Gang <gang.chen@asianux.com> wrote:
> 
>> force_page_cache_readahead() may fail, so need let the related upper
>> system calls know about it by its return value.
>>
>> For system call fadvise64_64(), ignore return value because fadvise()
>> shall return success even if filesystem can't retrieve a hint.
>>
> 
> Actually, force_page_cache_readahead() cannot fail - I see no code path
> via which it returns a -ve errno.
>

Hmm... except return -EINVAL, currently it is.

> Of course, that might change in the future and although readahead is
> usually a best-effort-dont-care-if-it-fails thing, I suppose that in
> the case of madvise() and sys_readahead() we should inform userspace,
> as readhead is the primary reason for thier performing the syscall.
> 

Yeah.

> 
> While we're there, please review...
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/readahead.c:do_readhead(): don't check for ->readpage
> 
> The callee force_page_cache_readahead() already does this and unlike
> do_readahead(), force_page_cache_readahead() remembers to check for
> ->readpages() as well.
> 
> 
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/readahead.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN mm/readahead.c~a mm/readahead.c
> --- a/mm/readahead.c~a
> +++ a/mm/readahead.c
> @@ -569,7 +569,7 @@ static ssize_t
>  do_readahead(struct address_space *mapping, struct file *filp,
>  	     pgoff_t index, unsigned long nr)
>  {
> -	if (!mapping || !mapping->a_ops || !mapping->a_ops->readpage)
> +	if (!mapping || !mapping->a_ops)
>  		return -EINVAL;
>  
>  	return force_page_cache_readahead(mapping, filp, index, nr);
> _
> 
> 
> 

At least for me, this patch sounds good.


And for the code below in "mm/readahead.c", I guess, skipping return
value of force_page_cache_readahead() is acceptable, but still better to
get some comments for it


505 void page_cache_sync_readahead(struct address_space *mapping,
506                                struct file_ra_state *ra, struct file
*filp,
507                                pgoff_t offset, unsigned long req_size)
508 {
509         /* no read-ahead */
510         if (!ra->ra_pages)
511                 return;
512
513         /* be dumb */
514         if (filp && (filp->f_mode & FMODE_RANDOM)) {
515                 force_page_cache_readahead(mapping, filp, offset,
req_size);
516                 return;
517         }
518
519         /* do read-ahead */
520         ondemand_readahead(mapping, ra, filp, false, offset, req_size);
521 }
522 EXPORT_SYMBOL_GPL(page_cache_sync_readahead);


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
