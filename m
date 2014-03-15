Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3CEF56B0055
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 23:18:02 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id x48so2831397wes.10
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 20:18:01 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id v6si638392wif.28.2014.03.14.20.18.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 20:18:01 -0700 (PDT)
Date: Sat, 15 Mar 2014 04:17:59 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/6] mm/memory-failure.c: report and recovery for
 memory error on dirty pagecache
Message-ID: <20140315031759.GC22728@two.firstfloor.org>
References: <1394746786-6397-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1394746786-6397-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394746786-6397-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org

On Thu, Mar 13, 2014 at 05:39:42PM -0400, Naoya Horiguchi wrote:
> Unifying error reporting between memory error and normal IO errors is ideal
> in a long run, but at first let's solve it separately. I hope that some code
> in this patch will be helpful when thinking of the unification.

The mechanisms should be very similar, right? 

It may be better to do both at the same time.

> index 60829565e552..1e8966919044 100644
> --- v3.14-rc6.orig/include/linux/fs.h
> +++ v3.14-rc6/include/linux/fs.h
> @@ -475,6 +475,9 @@ struct block_device {
>  #define PAGECACHE_TAG_DIRTY	0
>  #define PAGECACHE_TAG_WRITEBACK	1
>  #define PAGECACHE_TAG_TOWRITE	2
> +#ifdef CONFIG_MEMORY_FAILURE
> +#define PAGECACHE_TAG_HWPOISON	3
> +#endif

No need to ifdef defines

> @@ -1133,6 +1139,10 @@ static void do_generic_file_read(struct file *filp, loff_t *ppos,
>  			if (unlikely(page == NULL))
>  				goto no_cached_page;
>  		}
> +		if (unlikely(PageHWPoison(page))) {
> +			error = -EHWPOISON;
> +			goto readpage_error;
> +		}

Didn't we need this check before independent of the rest of the patch?

>  		if (PageReadahead(page)) {
>  			page_cache_async_readahead(mapping,
>  					ra, filp, page,
> @@ -2100,6 +2110,10 @@ inline int generic_write_checks(struct file *file, loff_t *pos, size_t *count, i
>          if (unlikely(*pos < 0))
>                  return -EINVAL;
>  
> +	if (unlikely(mapping_hwpoisoned_range(file->f_mapping, *pos,
> +					      *pos + *count)))
> +		return -EHWPOISON;

How expensive is that check? This will happen on every write.
Can it be somehow combined with the normal page cache lookup?

>   * Dirty pagecache page
> + *
> + * Memory error reporting (important especially on dirty pagecache error
> + * because dirty data is lost) with AS_EIO flag has some problems:

It doesn't make sense to have changelogs in comments. That is what
git is for.  At some point noone will care about the previous code.

> + * To solve these, we handle dirty pagecache errors by replacing the error

This part of the comment is good.

> +	pgoff_t index;
> +	struct inode *inode = NULL;
> +	struct page *new;
>  
>  	SetPageError(p);
> -	/* TBD: print more information about the file. */
>  	if (mapping) {
> +		index = page_index(p);
> +		/*
> +		 * we take inode refcount to keep it's pagecache or mapping
> +		 * on the memory until the error is resolved.

How does that work? Who "resolves" the error? 

> +		 */
> +		inode = igrab(mapping->host);
> +		pr_info("MCE %#lx: memory error on dirty pagecache (page offset:%lu, inode:%lu, dev:%s)\n",

Add the word file somewhere, you need to explain this in terms normal
sysadmins and not only kernel hackers can understand.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
