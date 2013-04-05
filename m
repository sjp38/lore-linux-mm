Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 0F9C36B0006
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 23:45:29 -0400 (EDT)
Received: by mail-da0-f51.google.com with SMTP id g27so1405360dan.10
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 20:45:29 -0700 (PDT)
Message-ID: <515E48D1.2090505@gmail.com>
Date: Fri, 05 Apr 2013 11:45:21 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 07/30] thp, mm: introduce mapping_can_have_hugepages()
 predicate
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-8-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Kirill,
On 03/15/2013 01:50 AM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> Returns true if mapping can have huge pages. Just check for __GFP_COMP
> in gfp mask of the mapping for now.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>   include/linux/pagemap.h |   10 ++++++++++
>   1 file changed, 10 insertions(+)
>
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index e3dea75..3521b0d 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -84,6 +84,16 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
>   				(__force unsigned long)mask;
>   }
>   
> +static inline bool mapping_can_have_hugepages(struct address_space *m)
> +{
> +	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
> +		gfp_t gfp_mask = mapping_gfp_mask(m);
> +		return !!(gfp_mask & __GFP_COMP);

I always see !! in kernel, but why check directly instead of have !! prefix?

> +	}
> +
> +	return false;
> +}
> +
>   /*
>    * The page cache can done in larger chunks than
>    * one page, because it allows for more efficient

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
