Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 598CC280255
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 07:43:43 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id d186so47251691lfg.7
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:43:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q6si17165289wjy.190.2016.10.13.04.43.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 04:43:41 -0700 (PDT)
Date: Thu, 13 Oct 2016 11:44:41 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHv3 17/41] filemap: handle huge pages in
 filemap_fdatawait_range()
Message-ID: <20161013094441.GC26241@quack2.suse.cz>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-18-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160915115523.29737-18-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu 15-09-16 14:54:59, Kirill A. Shutemov wrote:
> We writeback whole huge page a time.

This is one of the things I don't understand. Firstly I didn't see where
changes of writeback like this would happen (maybe they come later).
Secondly I'm not sure why e.g. writeback should behave atomically wrt huge
pages. Is this because radix-tree multiorder entry tracks dirtiness for us
at that granularity? BTW, can you also explain why do we need multiorder
entries? What do they solve for us?

I'm sorry for these basic questions but I'd just like to understand how is
this supposed to work...

								Honza


> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/filemap.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 05b42d3e5ed8..53da93156e60 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -372,9 +372,14 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
>  			if (page->index > end)
>  				continue;
>  
> +			page = compound_head(page);
>  			wait_on_page_writeback(page);
>  			if (TestClearPageError(page))
>  				ret = -EIO;
> +			if (PageTransHuge(page)) {
> +				index = page->index + HPAGE_PMD_NR;
> +				i += index - pvec.pages[i]->index - 1;
> +			}
>  		}
>  		pagevec_release(&pvec);
>  		cond_resched();
> -- 
> 2.9.3
> 
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
