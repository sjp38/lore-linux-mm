Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2F9C96B00E9
	for <linux-mm@kvack.org>; Sat,  9 Jul 2011 16:53:10 -0400 (EDT)
Date: Sat, 9 Jul 2011 13:53:08 -0700
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/3] mm/readahead: Move the check for ra_pages after
 VM_SequentialReadHint()
Message-ID: <20110709205308.GC17463@localhost>
References: <cover.1310239575.git.rprabhu@wnohang.net>
 <323ddfc402a7f7b94f0cb02bba15acb2acca786f.1310239575.git.rprabhu@wnohang.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <323ddfc402a7f7b94f0cb02bba15acb2acca786f.1310239575.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Raghavendra D Prabhu <rprabhu@wnohang.net>

On Sun, Jul 10, 2011 at 03:41:20AM +0800, Raghavendra D Prabhu wrote:
> page_cache_sync_readahead checks for ra->ra_pages again, so moving the check after VM_SequentialReadHint.

NAK. This patch adds nothing but overheads.

> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1566,8 +1566,6 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
>  	/* If we don't want any read-ahead, don't bother */
>  	if (VM_RandomReadHint(vma))
>  		return;
> -	if (!ra->ra_pages)
> -		return;
>  
>  	if (VM_SequentialReadHint(vma)) {
>  		page_cache_sync_readahead(mapping, ra, file, offset,
> @@ -1575,6 +1573,9 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
>  		return;
>  	}
>  
> +	if (!ra->ra_pages)
> +		return;
> +

page_cache_sync_readahead() has the same

	if (!ra->ra_pages)
		return;

So the patch adds the call into page_cache_sync_readahead() just to return..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
