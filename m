Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F80B6B0292
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 04:49:16 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 185so7152417wmk.12
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 01:49:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t16si7708005wra.201.2017.07.27.01.49.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 01:49:15 -0700 (PDT)
Date: Thu, 27 Jul 2017 10:49:14 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/4] mm: add file_fdatawait_range and
 file_write_and_wait
Message-ID: <20170727084914.GC21100@quack2.suse.cz>
References: <20170726175538.13885-1-jlayton@kernel.org>
 <20170726175538.13885-3-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726175538.13885-3-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

On Wed 26-07-17 13:55:36, Jeff Layton wrote:
> +int file_write_and_wait(struct file *file)
> +{
> +	int err = 0, err2;
> +	struct address_space *mapping = file->f_mapping;
> +
> +	if ((!dax_mapping(mapping) && mapping->nrpages) ||
> +	    (dax_mapping(mapping) && mapping->nrexceptional)) {
> +		err = filemap_fdatawrite(mapping);
> +		/* See comment of filemap_write_and_wait() */
> +		if (err != -EIO) {
> +			loff_t i_size = i_size_read(mapping->host);
> +
> +			if (i_size != 0)
> +				__filemap_fdatawait_range(mapping, 0,
> +							  i_size - 1);
> +		}
> +	}

Err, what's the i_size check doing here? I'd just pass ~0 as the end of the
range and ignore i_size. It is much easier than trying to wrap your head
around possible races with file operations modifying i_size.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
