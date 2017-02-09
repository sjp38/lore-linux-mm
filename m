Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6462B28089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 23:02:18 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z67so217211584pgb.0
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 20:02:18 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w28si8939994pfk.112.2017.02.08.20.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 20:02:17 -0800 (PST)
Date: Wed, 8 Feb 2017 20:01:13 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHv6 03/37] page-flags: relax page flag policy for few flags
Message-ID: <20170209040113.GR2267@bombadil.infradead.org>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
 <20170126115819.58875-4-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170126115819.58875-4-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Jan 26, 2017 at 02:57:45PM +0300, Kirill A. Shutemov wrote:
> These flags are in use for filesystems with backing storage: PG_error,
> PG_writeback and PG_readahead.

Oh ;-)  Then I amend my comment on patch 1 to be "patch 3 needs to go
ahead of patch 1" ;-)

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/page-flags.h | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 6b5818d6de32..b85b73cfb1b3 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -263,7 +263,7 @@ static inline int TestClearPage##uname(struct page *page) { return 0; }
>  
>  __PAGEFLAG(Locked, locked, PF_NO_TAIL)
>  PAGEFLAG(Waiters, waiters, PF_ONLY_HEAD) __CLEARPAGEFLAG(Waiters, waiters, PF_ONLY_HEAD)
> -PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
> +PAGEFLAG(Error, error, PF_NO_TAIL) TESTCLEARFLAG(Error, error, PF_NO_TAIL)
>  PAGEFLAG(Referenced, referenced, PF_HEAD)
>  	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
>  	__SETPAGEFLAG(Referenced, referenced, PF_HEAD)
> @@ -303,15 +303,15 @@ PAGEFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
>   * Only test-and-set exist for PG_writeback.  The unconditional operators are
>   * risky: they bypass page accounting.
>   */
> -TESTPAGEFLAG(Writeback, writeback, PF_NO_COMPOUND)
> -	TESTSCFLAG(Writeback, writeback, PF_NO_COMPOUND)
> +TESTPAGEFLAG(Writeback, writeback, PF_NO_TAIL)
> +	TESTSCFLAG(Writeback, writeback, PF_NO_TAIL)
>  PAGEFLAG(MappedToDisk, mappedtodisk, PF_NO_TAIL)
>  
>  /* PG_readahead is only used for reads; PG_reclaim is only for writes */
>  PAGEFLAG(Reclaim, reclaim, PF_NO_TAIL)
>  	TESTCLEARFLAG(Reclaim, reclaim, PF_NO_TAIL)
> -PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
> -	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
> +PAGEFLAG(Readahead, reclaim, PF_NO_TAIL)
> +	TESTCLEARFLAG(Readahead, reclaim, PF_NO_TAIL)
>  
>  #ifdef CONFIG_HIGHMEM
>  /*
> -- 
> 2.11.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
