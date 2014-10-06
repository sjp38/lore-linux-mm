Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id C6B4F6B0069
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 05:25:31 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id hi2so6167821wib.1
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 02:25:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gt1si16716167wjc.54.2014.10.06.02.25.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Oct 2014 02:25:30 -0700 (PDT)
Date: Mon, 6 Oct 2014 11:25:29 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] vfs: fix compilation for no-MMU configurations
Message-ID: <20141006092529.GB7526@quack.suse.cz>
References: <1412499516-12839-1-git-send-email-u.kleine-koenig@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1412499516-12839-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Cc: Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, kernel@pengutronix.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

On Sun 05-10-14 10:58:36, Uwe Kleine-Konig wrote:
> Commit ac4dd23b76ce introduced a new function pagecache_isize_extended.
> In <linux/mm.h> it was declared static inline and empty for no-MMU and
> defined unconditionally in mm/truncate.c which results a compiler
> error:
> 
> 	  CC      mm/truncate.o
> 	mm/truncate.c:751:6: error: redefinition of 'pagecache_isize_extended'
> 	 void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
> 	      ^
> 	In file included from mm/truncate.c:13:0:
> 	include/linux/mm.h:1161:91: note: previous definition of 'pagecache_isize_extended' was here
> 	 static inline void pagecache_isize_extended(struct inode *inode, loff_t from,
> 												   ^
> 	scripts/Makefile.build:257: recipe for target 'mm/truncate.o' failed
> 
> (tested with ARCH=arm efm32_defconfig).
> 
> Fixes: ac4dd23b76ce ("vfs: fix data corruption when blocksize < pagesize for mmaped data")
> Signed-off-by: Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>
  Yeah, sorry for the breakage. It should be already fixed in Ted's tree.
I've actually chosen to just remove the inline definition. It is true that
currently the function doesn't need to do anything for systems not
supporting mmap but that may change in future and the functions is
reasonably cheap anyway...

								Honza
> ---
> Hello,
> 
> the bad commit sits in
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git#dev
> 
> and is included in next.
> 
> Best regards
> Uwe
> 
>  mm/truncate.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 261eaf6e5a19..0d9c4ebd5ecc 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -729,6 +729,7 @@ void truncate_setsize(struct inode *inode, loff_t newsize)
>  }
>  EXPORT_SYMBOL(truncate_setsize);
>  
> +#ifdef CONFIG_MMU
>  /**
>   * pagecache_isize_extended - update pagecache after extension of i_size
>   * @inode:	inode for which i_size was extended
> @@ -780,6 +781,7 @@ void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
>  	page_cache_release(page);
>  }
>  EXPORT_SYMBOL(pagecache_isize_extended);
> +#endif
>  
>  /**
>   * truncate_pagecache_range - unmap and remove pagecache that is hole-punched
> -- 
> 2.1.0
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
