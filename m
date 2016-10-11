Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 938C26B0266
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:42:32 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id z189so503101wmb.5
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 11:42:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z1si6383561wjm.224.2016.10.11.11.42.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 11:42:31 -0700 (PDT)
Date: Tue, 11 Oct 2016 17:40:31 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHv3 11/41] thp: try to free page's buffers before attempt
 split
Message-ID: <20161011154031.GK6952@quack2.suse.cz>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-12-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160915115523.29737-12-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu 15-09-16 14:54:53, Kirill A. Shutemov wrote:
> We want page to be isolated from the rest of the system before spliting
> it. We rely on page count to be 2 for file pages to make sure nobody
> uses the page: one pin to caller, one to radix-tree.
> 
> Filesystems with backing storage can have page count increased if it has
> buffers.
> 
> Let's try to free them, before attempt split. And remove one guarding
> VM_BUG_ON_PAGE().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
...
> @@ -2041,6 +2041,23 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  			goto out;
>  		}
>  
> +		/* Try to free buffers before attempt split */
> +		if (!PageSwapBacked(head) && PagePrivate(page)) {
> +			/*
> +			 * We cannot trigger writeback from here due possible
> +			 * recursion if triggered from vmscan, only wait.
> +			 *
> +			 * Caller can trigger writeback it on its own, if safe.
> +			 */
> +			wait_on_page_writeback(head);
> +
> +			if (page_has_buffers(head) &&
> +					!try_to_free_buffers(head)) {
> +				ret = -EBUSY;
> +				goto out;
> +			}

Shouldn't you rather use try_to_release_page() here? Because filesystems
have their ->releasepage() callbacks for freeing data associated with a
page. It is not guaranteed page private data are buffers although it is
true for ext4...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
