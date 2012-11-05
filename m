Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 764016B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 17:01:56 -0500 (EST)
Date: Mon, 5 Nov 2012 14:01:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2 v2] mm: print out information of file affected by
 memory error
Message-Id: <20121105140154.fce89f05.akpm@linux-foundation.org>
In-Reply-To: <1351873993-9373-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1351873993-9373-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1351873993-9373-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Tony Luck <tony.luck@intel.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Fri,  2 Nov 2012 12:33:13 -0400
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Printing out the information about which file can be affected by a
> memory error in generic_error_remove_page() is helpful for user to
> estimate the impact of the error.
> 
> Changelog v2:
>   - dereference mapping->host after if (!mapping) check for robustness
> 
> ...
>
> --- v3.7-rc3.orig/mm/truncate.c
> +++ v3.7-rc3/mm/truncate.c
> @@ -151,14 +151,20 @@ int truncate_inode_page(struct address_space *mapping, struct page *page)
>   */
>  int generic_error_remove_page(struct address_space *mapping, struct page *page)
>  {
> +	struct inode *inode;
> +
>  	if (!mapping)
>  		return -EINVAL;
> +	inode = mapping->host;
>  	/*
>  	 * Only punch for normal data pages for now.
>  	 * Handling other types like directories would need more auditing.
>  	 */
> -	if (!S_ISREG(mapping->host->i_mode))
> +	if (!S_ISREG(inode->i_mode))
>  		return -EIO;
> +	pr_info("MCE %#lx: file info pgoff:%lu, inode:%lu, dev:%s\n",
> +		page_to_pfn(page), page_index(page),
> +		inode->i_ino, inode->i_sb->s_id);
>  	return truncate_inode_page(mapping, page);
>  }
>  EXPORT_SYMBOL(generic_error_remove_page);

A couple of things.

- I worry that if a hardware error occurs, it might affect a large
  amount of memory all at the same time.  For example, if a 4G memory
  block goes bad, this message will be printed a million times?

- hard-wiring "MCE" in here seems a bit of a layering violation? 
  What right does the generic, core .error_remove_page() implementation
  have to assume that it was called because of an MCE?  Many CPU types
  don't eveh have such a thing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
