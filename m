Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 706766B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 15:28:16 -0400 (EDT)
Message-ID: <519BCACD.4020106@sr71.net>
Date: Tue, 21 May 2013 12:28:13 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 09/39] thp, mm: introduce mapping_can_have_hugepages()
 predicate
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-10-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> Returns true if mapping can have huge pages. Just check for __GFP_COMP
> in gfp mask of the mapping for now.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/pagemap.h |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index e3dea75..28597ec 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -84,6 +84,18 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
>  				(__force unsigned long)mask;
>  }
>  
> +static inline bool mapping_can_have_hugepages(struct address_space *m)
> +{
> +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE)) {
> +		gfp_t gfp_mask = mapping_gfp_mask(m);
> +		/* __GFP_COMP is key part of GFP_TRANSHUGE */
> +		return !!(gfp_mask & __GFP_COMP) &&
> +			transparent_hugepage_pagecache();
> +	}
> +
> +	return false;
> +}

transparent_hugepage_pagecache() already has the same IS_ENABLED()
check,  Is it really necessary to do it again here?

IOW, can you do this?

> +static inline bool mapping_can_have_hugepages(struct address_space
> +{
> +		gfp_t gfp_mask = mapping_gfp_mask(m);
		if (!transparent_hugepage_pagecache())
			return false;
> +		/* __GFP_COMP is key part of GFP_TRANSHUGE */
> +		return !!(gfp_mask & __GFP_COMP);
> +}

I know we talked about this in the past, but I've forgotten already.
Why is this checking for __GFP_COMP instead of GFP_TRANSHUGE?

Please flesh out the comment.

Also, what happens if "transparent_hugepage_flags &
(1<<TRANSPARENT_HUGEPAGE_PAGECACHE)" becomes false at runtime and you
have some already-instantiated huge page cache mappings around?  Will
things like mapping_align_mask() break?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
