Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CBB056B000A
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 13:21:34 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s7-v6so12610012pgp.3
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 10:21:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1-v6si7917726plm.41.2018.10.14.10.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 14 Oct 2018 10:21:33 -0700 (PDT)
Date: Sun, 14 Oct 2018 10:21:31 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 10/25] vfs: create generic_remap_file_range_touch to
 update inode metadata
Message-ID: <20181014172131.GE30673@infradead.org>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938921180.8361.13556945128095535605.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153938921180.8361.13556945128095535605.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

> +/* Update inode timestamps and remove security privileges when remapping. */
> +int generic_remap_file_range_touch(struct file *file, bool is_dedupe)
> +{
> +	int ret;
> +
> +	/* If can't alter the file contents, we're done. */
> +	if (is_dedupe)
> +		return 0;
> +
> +	/* Update the timestamps, since we can alter file contents. */
> +	if (!(file->f_mode & FMODE_NOCMTIME)) {
> +		ret = file_update_time(file);
> +		if (ret)
> +			return ret;
> +	}
> +
> +	/*
> +	 * Clear the security bits if the process is not being run by root.
> +	 * This keeps people from modifying setuid and setgid binaries.
> +	 */
> +	return file_remove_privs(file);
> +}
> +EXPORT_SYMBOL(generic_remap_file_range_touch);

The name seems a little out of touch with what it actually does.
Also why a bool argument instead of the more descriptive flags which
introduced a few patches ago?
