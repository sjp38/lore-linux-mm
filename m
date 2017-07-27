Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id F23406B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:48:32 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c2so3990436qkb.10
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:48:32 -0700 (PDT)
Received: from mail-qt0-f177.google.com (mail-qt0-f177.google.com. [209.85.216.177])
        by mx.google.com with ESMTPS id j21si15861534qtf.103.2017.07.27.05.48.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 05:48:32 -0700 (PDT)
Received: by mail-qt0-f177.google.com with SMTP id v29so41614658qtv.3
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:48:32 -0700 (PDT)
Message-ID: <1501159710.6279.1.camel@redhat.com>
Subject: Re: [PATCH v2 2/4] mm: add file_fdatawait_range and
 file_write_and_wait
From: Jeff Layton <jlayton@redhat.com>
Date: Thu, 27 Jul 2017 08:48:30 -0400
In-Reply-To: <20170727084914.GC21100@quack2.suse.cz>
References: <20170726175538.13885-1-jlayton@kernel.org>
	 <20170726175538.13885-3-jlayton@kernel.org>
	 <20170727084914.GC21100@quack2.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

On Thu, 2017-07-27 at 10:49 +0200, Jan Kara wrote:
> On Wed 26-07-17 13:55:36, Jeff Layton wrote:
> > +int file_write_and_wait(struct file *file)
> > +{
> > +	int err = 0, err2;
> > +	struct address_space *mapping = file->f_mapping;
> > +
> > +	if ((!dax_mapping(mapping) && mapping->nrpages) ||
> > +	    (dax_mapping(mapping) && mapping->nrexceptional)) {
> > +		err = filemap_fdatawrite(mapping);
> > +		/* See comment of filemap_write_and_wait() */
> > +		if (err != -EIO) {
> > +			loff_t i_size = i_size_read(mapping->host);
> > +
> > +			if (i_size != 0)
> > +				__filemap_fdatawait_range(mapping, 0,
> > +							  i_size - 1);
> > +		}
> > +	}
> 
> Err, what's the i_size check doing here? I'd just pass ~0 as the end of the
> range and ignore i_size. It is much easier than trying to wrap your head
> around possible races with file operations modifying i_size.
> 
> 								Honza

I'm basically emulating _exactly_ what filemap_write_and_wait does here,
as I'm leery of making subtle behavior changes in the actual writeback
behavior. For example:

-----------------8<----------------
static inline int __filemap_fdatawrite(struct address_space *mapping,
        int sync_mode)
{
        return __filemap_fdatawrite_range(mapping, 0, LLONG_MAX, sync_mode);
}

int filemap_fdatawrite(struct address_space *mapping)
{
        return __filemap_fdatawrite(mapping, WB_SYNC_ALL);
}
EXPORT_SYMBOL(filemap_fdatawrite);
-----------------8<----------------

...which then sets up the wbc with the right ranges and sync mode and
kicks off writepages. But then, it does the i_size_read to figure out
what range it should wait on (with the shortcut for the size == 0 case).

My assumption was that it was intentionally designed that way, but I'm
guessing from your comments that it wasn't? If so, then we can turn
file_write_and_wait a static inline wrapper around
file_write_and_wait_range.
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
