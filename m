Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 622046B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:13:12 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id k72so89952678pfj.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:13:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c9si10159724pgt.207.2017.07.26.12.13.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 12:13:11 -0700 (PDT)
Date: Wed, 26 Jul 2017 12:13:05 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 2/4] mm: add file_fdatawait_range and
 file_write_and_wait
Message-ID: <20170726191305.GC15980@bombadil.infradead.org>
References: <20170726175538.13885-1-jlayton@kernel.org>
 <20170726175538.13885-3-jlayton@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726175538.13885-3-jlayton@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

On Wed, Jul 26, 2017 at 01:55:36PM -0400, Jeff Layton wrote:
> +int file_write_and_wait(struct file *file)
> +{
> +	int err = 0, err2;
> +	struct address_space *mapping = file->f_mapping;
> +
> +	if ((!dax_mapping(mapping) && mapping->nrpages) ||
> +	    (dax_mapping(mapping) && mapping->nrexceptional)) {

Since patch 1 exists, shouldn't this use the new helper?

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
> +	err2 = file_check_and_advance_wb_err(file);
> +	if (!err)
> +		err = err2;
> +	return err;

Would this be clearer written as:

	if (err)
		return err;
	return err2;

or even ...

	return err ? err : err2;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
