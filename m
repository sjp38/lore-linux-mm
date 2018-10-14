Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3E8B6B026D
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 13:43:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c28-v6so4268660pfe.4
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 10:43:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w4-v6si7806327pll.214.2018.10.14.10.43.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 14 Oct 2018 10:43:26 -0700 (PDT)
Date: Sun, 14 Oct 2018 10:43:24 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 18/25] vfs: hide file range comparison function
Message-ID: <20181014174324.GC6400@infradead.org>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938927103.8361.6327676425188043040.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153938927103.8361.6327676425188043040.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

> +static struct page *vfs_dedupe_get_page(struct inode *inode, loff_t offset)
> +{
> +	struct address_space *mapping;
> +	struct page *page;
> +	pgoff_t n;
> +
> +	n = offset >> PAGE_SHIFT;
> +	mapping = inode->i_mapping;
> +	page = read_mapping_page(mapping, n, NULL);
> +	if (IS_ERR(page))
> +		return page;
> +	if (!PageUptodate(page)) {
> +		put_page(page);
> +		return ERR_PTR(-EIO);
> +	}
> +	lock_page(page);
> +	return page;
> +}

Might be worth to clean ths up a bit while you are at it:

+static struct page *vfs_dedupe_get_page(struct inode *inode, loff_t offset)
{
	struct page *page;

	page = read_mapping_page(inode->i_mapping, offset >> PAGE_SHIFT, NULL);
	...

Otherwise looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>
