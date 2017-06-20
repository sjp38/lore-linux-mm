Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B38F56B02FA
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 08:35:53 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id t87so93415232ioe.7
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 05:35:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 66si12441191ioy.19.2017.06.20.05.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 05:35:50 -0700 (PDT)
Date: Tue, 20 Jun 2017 05:35:44 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v7 16/22] block: convert to errseq_t based writeback
 error tracking
Message-ID: <20170620123544.GC19781@infradead.org>
References: <20170616193427.13955-1-jlayton@redhat.com>
 <20170616193427.13955-17-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170616193427.13955-17-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

>  	error = filemap_write_and_wait_range(filp->f_mapping, start, end);
>  	if (error)
> -		return error;
> +		goto out;
>  
>  	/*
>  	 * There is no need to serialise calls to blkdev_issue_flush with
> @@ -640,6 +640,10 @@ int blkdev_fsync(struct file *filp, loff_t start, loff_t end, int datasync)
>  	if (error == -EOPNOTSUPP)
>  		error = 0;
>  
> +out:
> +	wberr = filemap_report_wb_err(filp);
> +	if (!error)
> +		error = wberr;

Just curious: what's the reason filemap_write_and_wait_range couldn't
query for the error using filemap_report_wb_err internally?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
