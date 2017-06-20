Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5837D6B0315
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 08:56:20 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g83so35946393qkb.14
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 05:56:20 -0700 (PDT)
Received: from mail-qt0-f173.google.com (mail-qt0-f173.google.com. [209.85.216.173])
        by mx.google.com with ESMTPS id l64si11054229qkl.189.2017.06.20.05.56.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 05:56:19 -0700 (PDT)
Received: by mail-qt0-f173.google.com with SMTP id w1so131932483qtg.2
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 05:56:19 -0700 (PDT)
Message-ID: <1497963376.4555.4.camel@redhat.com>
Subject: Re: [PATCH v7 11/22] fs: new infrastructure for writeback error
 handling and reporting
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 20 Jun 2017 08:56:16 -0400
In-Reply-To: <20170620123433.GB19781@infradead.org>
References: <20170616193427.13955-1-jlayton@redhat.com>
	 <20170616193427.13955-12-jlayton@redhat.com>
	 <20170620123433.GB19781@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, Jan Kara <jack@suse.cz>, tytso@mit.edu, axboe@kernel.dk, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, corbet@lwn.net, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, Carlos Maiolino <cmaiolino@redhat.com>, Eryu Guan <eguan@redhat.com>, David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-block@vger.kernel.org

On Tue, 2017-06-20 at 05:34 -0700, Christoph Hellwig wrote:
> > @@ -393,6 +394,7 @@ struct address_space {
> >  	gfp_t			gfp_mask;	/* implicit gfp mask for allocations */
> >  	struct list_head	private_list;	/* ditto */
> >  	void			*private_data;	/* ditto */
> > +	errseq_t		wb_err;
> >  } __attribute__((aligned(sizeof(long))));
> >  	/*
> >  	 * On most architectures that alignment is already the case; but
> > @@ -847,6 +849,7 @@ struct file {
> >  	 * Must not be taken from IRQ context.
> >  	 */
> >  	spinlock_t		f_lock;
> > +	errseq_t		f_wb_err;
> >  	atomic_long_t		f_count;
> >  	unsigned int 		f_flags;
> >  	fmode_t			f_mode;
> 
> Did you check the sizes of the structure before and after?
> These places don't look like holes in the packing, but there probably
> are some available.
> 

Yes. That one actually plugs a 4 byte hole in struct file on x86_64.

> > +static inline int filemap_check_wb_err(struct address_space *mapping, errseq_t since)
> 
> Overly long line here (the patch has a few more)
> 

Ok, I'll fix those up.

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
