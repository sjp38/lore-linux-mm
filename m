Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCD136B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:50:27 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o5so89849795qki.2
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:50:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k30si3318001qtb.392.2017.07.26.12.50.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 12:50:27 -0700 (PDT)
Date: Wed, 26 Jul 2017 15:50:22 -0400 (EDT)
From: Bob Peterson <rpeterso@redhat.com>
Message-ID: <4829887.34737343.1501098622466.JavaMail.zimbra@redhat.com>
In-Reply-To: <20170726175538.13885-3-jlayton@kernel.org>
References: <20170726175538.13885-1-jlayton@kernel.org> <20170726175538.13885-3-jlayton@kernel.org>
Subject: Re: [PATCH v2 2/4] mm: add file_fdatawait_range and
 file_write_and_wait
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

----- Original Message -----
| From: Jeff Layton <jlayton@redhat.com>
| 
| Some filesystem fsync routines will need these.
| 
| Signed-off-by: Jeff Layton <jlayton@redhat.com>
| ---
|  include/linux/fs.h |  7 ++++++-
|  mm/filemap.c       | 56
|  ++++++++++++++++++++++++++++++++++++++++++++++++++++++
|  2 files changed, 62 insertions(+), 1 deletion(-)
(snip)
| diff --git a/mm/filemap.c b/mm/filemap.c
| index 72e46e6f0d9a..b904a8dfa43d 100644
| --- a/mm/filemap.c
| +++ b/mm/filemap.c
(snip)
| @@ -675,6 +698,39 @@ int file_write_and_wait_range(struct file *file, loff_t
| lstart, loff_t lend)
|  EXPORT_SYMBOL(file_write_and_wait_range);
|  
|  /**
| + * file_write_and_wait - write out whole file and wait on it and return any
| + * 			 writeback errors since we last checked
| + * @file: file to write back and wait on
| + *
| + * Write back the whole file and wait on its mapping. Afterward, check for
| + * errors that may have occurred since our file->f_wb_err cursor was last
| + * updated.
| + */
| +int file_write_and_wait(struct file *file)
| +{
| +	int err = 0, err2;
| +	struct address_space *mapping = file->f_mapping;
| +
| +	if ((!dax_mapping(mapping) && mapping->nrpages) ||
| +	    (dax_mapping(mapping) && mapping->nrexceptional)) {

Seems like we should make the new function mapping_needs_writeback more
central (mm.h or fs.h?) and call it here ^.

| +		err = filemap_fdatawrite(mapping);
| +		/* See comment of filemap_write_and_wait() */
| +		if (err != -EIO) {
| +			loff_t i_size = i_size_read(mapping->host);
| +
| +			if (i_size != 0)
| +				__filemap_fdatawait_range(mapping, 0,
| +							  i_size - 1);
| +		}
| +	}
| +	err2 = file_check_and_advance_wb_err(file);
| +	if (!err)
| +		err = err2;
| +	return err;

In the past, I've seen more elegant constructs like:
        return (err ? err : err2);
but I don't know what's considered more ugly or hackish.

Regards,

Bob Peterson
Red Hat File Systems

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
