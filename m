Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 9EB746B0044
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 18:01:34 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] HWPOISON: improve handling/reporting of memory error on dirty pagecache
Date: Fri, 10 Aug 2012 18:01:15 -0400
Message-Id: <1344636075-14357-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1344634913-13681-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 10, 2012 at 05:41:53PM -0400, Naoya Horiguchi wrote:
...
> +/*
>   * Dirty cache page page
>   * Issues: when the error hit a hole page the error is not properly
>   * propagated.
>   */
>  static int me_pagecache_dirty(struct page *p, unsigned long pfn)
>  {
> -	/*
> -	 * The original memory error handling on dirty pagecache has
> -	 * a bug that user processes who use corrupted pages via read()
> -	 * or write() can't be aware of the memory error and result
> -	 * in throwing out dirty data silently.
> -	 *
> -	 * Until we solve the problem, let's close the path of memory
> -	 * error handling for dirty pagecache. We just leave errors
> -	 * for the 2nd MCE to trigger panics.
> -	 */
> -	return IGNORED;
> +	struct address_space *mapping = page_mapping(p);
> +
> +	SetPageError(p);
> +	if (mapping) {
> +		struct hwp_dirty *hwp;
> +		struct inode *inode = mapping->host;
> +
> +		/*
> +		 * Memory error is reported to userspace by AS_HWPOISON flags
> +		 * in mapping->flags. The mechanism is similar to that of
> +		 * AS_EIO, but we have separete flags because there'are two
> +		 * differences between them:
> +		 *  1. Expected userspace handling. When user processes get
> +		 *     -EIO, they can retry writeback hoping the error in IO
> +		 *     devices is temporary, switch to write to other devices,
> +		 *     or do some other application-specific handling.
> +		 *     For -EHWPOISON, we can clear the error by overwriting
> +		 *     the corrupted page.
> +		 *  2. When to clear. For -EIO, we can think that we recover
> +		 *     from the error when writeback succeeds. For -EHWPOISON
> +		 *     OTOH, we can see that things are back to normal when
> +		 *     corrupted data are overwritten from user buffer.
> +		 */
> +		hwp = kmalloc(sizeof(struct hwp_dirty), GFP_ATOMIC);
> +		hwp->page = p;
> +		hwp->fpage = NULL;
> +		hwp->mapping = mapping;
> +		hwp->index = page_index(p);

> +		hwp->ino = inode->i_ino;
> +		hwp->dev = inode->i_sb->s_dev;

Sorry, these two members are not in struct hwp_dirty in current version.
Please ignore them.

Thanks,
Naoya

> +		add_hwp_dirty(hwp);
> +
> +		pr_err("MCE %#lx: Corrupted dirty pagecache, dev %u:%u, inode:%lu, index:%lu\n",
> +		       pfn, MAJOR(inode->i_sb->s_dev),
> +		       MINOR(inode->i_sb->s_dev), inode->i_ino, page_index(p));
> +		mapping_set_error(mapping, -EHWPOISON);
> +	}
> +
> +	return me_pagecache_clean(p, pfn);
>  }
>  
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
