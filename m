Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A9F86B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 16:26:16 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 91so43280859qkq.2
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:26:16 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id 201si5699292qko.140.2017.06.29.13.26.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 13:26:15 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id w12so12687629qta.2
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:26:15 -0700 (PDT)
Message-ID: <1498767972.5710.4.camel@poochiereds.net>
Subject: Re: [PATCH v8 16/18] ext4: use errseq_t based error handling for
 reporting data writeback errors
From: Jeff Layton <jlayton@poochiereds.net>
Date: Thu, 29 Jun 2017 16:26:12 -0400
In-Reply-To: <20170629141221.GA17251@infradead.org>
References: <20170629131954.28733-1-jlayton@kernel.org>
	 <20170629131954.28733-17-jlayton@kernel.org>
	 <20170629141221.GA17251@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, jlayton@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, Liu Bo <bo.li.liu@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Thu, 2017-06-29 at 07:12 -0700, Christoph Hellwig wrote:
> > -	if (unlikely(ext4_forced_shutdown(EXT4_SB(inode->i_sb))))
> > -		return -EIO;
> > +	if (unlikely(ext4_forced_shutdown(EXT4_SB(inode->i_sb)))) {
> > +		ret = -EIO;
> > +		goto out;
> > +	}
> 
> This just seems to add a call to trace_ext4_sync_file_exit for this
> case, which seems unrelated to the patch.
> 
> >  	if (ret)
> > -		return ret;
> > +		goto out;
> > +
> 
> Same here.
> 
> >  	/*
> >  	 * data=writeback,ordered:
> >  	 *  The caller's filemap_fdatawrite()/wait will sync the data.
> > @@ -152,7 +155,7 @@ int ext4_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
> >  		needs_barrier = true;
> >  	ret = jbd2_complete_transaction(journal, commit_tid);
> >  	if (needs_barrier) {
> > -	issue_flush:
> > +issue_flush:
> >  		err = blkdev_issue_flush(inode->i_sb->s_bdev, GFP_KERNEL, NULL);
> 
> And while I much prefer your new label placement it also doesn't
> seem to belong into this patch.

I revised the patch description earlier to say:

    While we're at it, ensure we always "goto out" instead of just
    returning directly, so that we always hit the exit tracepoint.

...but I'm fine with taking that out if you prefer.
-- 
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
