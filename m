Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3522F6B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 05:26:41 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so8508825wib.5
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 02:26:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ne11si2409443wic.77.2014.04.09.02.26.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 02:26:39 -0700 (PDT)
Date: Wed, 9 Apr 2014 11:26:35 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 08/22] Replace xip_truncate_page with dax_truncate_page
Message-ID: <20140409092635.GB32103@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <fd328c564ddc79b41a3a8d754080e6e6e77bbf4f.1395591795.git.matthew.r.wilcox@intel.com>
 <20140408221759.GD26019@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140408221759.GD26019@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Wed 09-04-14 00:17:59, Jan Kara wrote:
> On Sun 23-03-14 15:08:34, Matthew Wilcox wrote:
> > +/**
> > + * dax_truncate_page - handle a partial page being truncated in a DAX file
> > + * @inode: The file being truncated
> > + * @from: The file offset that is being truncated to
> > + * @get_block: The filesystem method used to translate file offsets to blocks
> > + *
> > + * Similar to block_truncate_page(), this function can be called by a
> > + * filesystem when it is truncating an DAX file to handle the partial page.
> > + *
> > + * We work in terms of PAGE_CACHE_SIZE here for commonality with
> > + * block_truncate_page(), but we could go down to PAGE_SIZE if the filesystem
> > + * took care of disposing of the unnecessary blocks.  Even if the filesystem
> > + * block size is smaller than PAGE_SIZE, we have to zero the rest of the page
> > + * since the file might be mmaped.
>   Well, DAX mmap support pretty much relies on PAGE_CACHE_SIZE == block
> size (we cannot really map only a part of a physical page directly...). So
> the comment seems somewhat misleading.
  I thought about this for a while and classical IO, truncation etc. could
easily work for blocksize < pagesize. And for mmap() you could just use
pagecache. Not sure if it's worth the complications though. Anyway we
should decide whether we don't care about blocksize < PAGE_CACHE_SIZE at
all, or whether we try to make things which can work reasonably easily
functional. In that case dax_truncate_page() needs some tweaking because it
currently assumes blocksize == PAGE_CACHE_SIZE.

								Honza
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
