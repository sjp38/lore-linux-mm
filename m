Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0496D6B0008
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 23:34:07 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e3-v6so24900441pld.13
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 20:34:06 -0700 (PDT)
Received: from ipmailnode02.adl6.internode.on.net (ipmailnode02.adl6.internode.on.net. [150.101.137.148])
        by mx.google.com with ESMTP id l4-v6si23345386pgf.344.2018.10.18.20.34.04
        for <linux-mm@kvack.org>;
        Thu, 18 Oct 2018 20:34:05 -0700 (PDT)
Date: Fri, 19 Oct 2018 14:34:02 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 5/7] mm: add a flag to indicate we used a cached page
Message-ID: <20181019033402.GK18822@dastard>
References: <20181018202318.9131-1-josef@toxicpanda.com>
 <20181018202318.9131-6-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018202318.9131-6-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, riel@fb.com, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 04:23:16PM -0400, Josef Bacik wrote:
> This is preparation for dropping the mmap_sem in page_mkwrite.  We need
> to know if we used our cached page so we can be sure it is the page we
> already did the page_mkwrite stuff on so we don't have to redo all of
> that work.
> 
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> ---
>  include/linux/mm.h | 6 +++++-
>  mm/filemap.c       | 5 ++++-
>  2 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4a84ec976dfc..a7305d193c71 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -318,6 +318,9 @@ extern pgprot_t protection_map[16];
>  #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
>  #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
>  #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
> +#define FAULT_FLAG_USED_CACHED	0x200	/* Our vmf->page was from a previous
> +					 * loop through the fault handler.
> +					 */
>  
>  #define FAULT_FLAG_TRACE \
>  	{ FAULT_FLAG_WRITE,		"WRITE" }, \
> @@ -328,7 +331,8 @@ extern pgprot_t protection_map[16];
>  	{ FAULT_FLAG_TRIED,		"TRIED" }, \
>  	{ FAULT_FLAG_USER,		"USER" }, \
>  	{ FAULT_FLAG_REMOTE,		"REMOTE" }, \
> -	{ FAULT_FLAG_INSTRUCTION,	"INSTRUCTION" }
> +	{ FAULT_FLAG_INSTRUCTION,	"INSTRUCTION" }, \
> +	{ FAULT_FLAG_USED_CACHED,	"USED_CACHED" }
>  
>  /*
>   * vm_fault is filled by the the pagefault handler and passed to the vma's
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 5212ab637832..e9cb44bd35aa 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2556,6 +2556,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>  		if (cached_page->mapping == mapping &&
>  		    cached_page->index == offset) {
>  			page = cached_page;
> +			vmf->flags |= FAULT_FLAG_USED_CACHED;

This is really saying the page has been initialised by a prior
fault attempt, not that "we used a cached page". "cached page" is a
horribly overloaded term - I suspect we should not overload it more,
especially as the flag get cleared if the cached page is not up to
date (i.e. the data on it hasn't been fully initialised).

FAULT_FLAG_PAGE_INITIALISED?

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com
