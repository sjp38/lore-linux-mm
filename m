Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id A0CE26B0253
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 09:46:02 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l66so57534448wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 06:46:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id it4si22516894wjb.239.2016.01.29.06.46.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Jan 2016 06:46:01 -0800 (PST)
Subject: Re: [PATCH 4/5] mm: Use radix_tree_iter_retry()
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453929472-25566-5-git-send-email-matthew.r.wilcox@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56AB7B27.3090805@suse.cz>
Date: Fri, 29 Jan 2016 15:45:59 +0100
MIME-Version: 1.0
In-Reply-To: <1453929472-25566-5-git-send-email-matthew.r.wilcox@intel.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 01/27/2016 10:17 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> Instead of a 'goto restart', we can now use radix_tree_iter_retry()
> to restart from our current position.  This will make a difference
> when there are more ways to happen across an indirect pointer.  And it
> eliminates some confusing gotos.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>

[...]

> diff --git a/mm/shmem.c b/mm/shmem.c
> index fa2ceb2d2655..6ec14b70d82d 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -388,8 +388,10 @@ restart:
>  		 * don't need to reset the counter, nor do we risk infinite
>  		 * restarts.
>  		 */
> -		if (radix_tree_deref_retry(page))
> -			goto restart;
> +		if (radix_tree_deref_retry(page)) {
> +			slot = radix_tree_iter_retry(&iter);
> +			continue;
> +		}
>  
>  		if (radix_tree_exceptional_entry(page))
>  			swapped++;

This should be applied on top. There are no restarts anymore.

----8<----
