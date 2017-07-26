Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59A2F6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 18:18:33 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i19so58303670qte.5
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:18:33 -0700 (PDT)
Received: from mail-qt0-f174.google.com (mail-qt0-f174.google.com. [209.85.216.174])
        by mx.google.com with ESMTPS id v25si13872891qtf.92.2017.07.26.15.18.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 15:18:32 -0700 (PDT)
Received: by mail-qt0-f174.google.com with SMTP id p3so52162751qtg.2
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:18:32 -0700 (PDT)
Message-ID: <1501107510.15159.4.camel@redhat.com>
Subject: Re: [PATCH v2 2/4] mm: add file_fdatawait_range and
 file_write_and_wait
From: Jeff Layton <jlayton@redhat.com>
Date: Wed, 26 Jul 2017 18:18:30 -0400
In-Reply-To: <20170726191305.GC15980@bombadil.infradead.org>
References: <20170726175538.13885-1-jlayton@kernel.org>
	 <20170726175538.13885-3-jlayton@kernel.org>
	 <20170726191305.GC15980@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, "J .
 Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

On Wed, 2017-07-26 at 12:13 -0700, Matthew Wilcox wrote:
> On Wed, Jul 26, 2017 at 01:55:36PM -0400, Jeff Layton wrote:
> > +int file_write_and_wait(struct file *file)
> > +{
> > +	int err = 0, err2;
> > +	struct address_space *mapping = file->f_mapping;
> > +
> > +	if ((!dax_mapping(mapping) && mapping->nrpages) ||
> > +	    (dax_mapping(mapping) && mapping->nrexceptional)) {
> 
> Since patch 1 exists, shouldn't this use the new helper?
> 

<facepalm>

yes, will fix


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
> > +	err2 = file_check_and_advance_wb_err(file);
> > +	if (!err)
> > +		err = err2;
> > +	return err;
> 
> Would this be clearer written as:
> 
> 	if (err)
> 		return err;
> 	return err2;
> 
> or even ...
> 
> 	return err ? err : err2;
> 

Meh -- I like it the way I have it. If we don't have an error already,
then just take the one from the check and advance.

That said, I don't have a terribly strong preference here, so if anyone
does, then I can be easily persuaded.

-- 
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
