Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF8A66B0114
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 16:44:27 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so730951pab.38
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 13:44:27 -0700 (PDT)
Date: Wed, 2 Apr 2014 13:44:20 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 3/6] aio/dio: enable PI passthrough
Message-ID: <20140402204420.GB10230@birch.djwong.org>
References: <20140324162231.10848.4863.stgit@birch.djwong.org>
 <20140324162251.10848.56452.stgit@birch.djwong.org>
 <20140402200133.GK2394@lenny.home.zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140402200133.GK2394@lenny.home.zabbo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Brown <zab@redhat.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, jmoyer@redhat.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 02, 2014 at 01:01:33PM -0700, Zach Brown wrote:
> > +static int setup_pi_ext(struct kiocb *req, int is_write)
> > +{
> > +	struct file *file = req->ki_filp;
> > +	struct io_extension *ext = &req->ki_ioext->ke_kern;
> > +	void *p;
> > +	unsigned long start, end;
> > +	int retval;
> > +
> > +	if (!(file->f_flags & O_DIRECT)) {
> > +		pr_debug("EINVAL: can't use PI without O_DIRECT.\n");
> > +		return -EINVAL;
> > +	}
> > +
> > +	BUG_ON(req->ki_ioext->ke_pi_iter.pi_userpages);
> > +
> > +	end = (((unsigned long)ext->ie_pi_buf) + ext->ie_pi_buflen +
> > +		PAGE_SIZE - 1) >> PAGE_SHIFT;
> > +	start = ((unsigned long)ext->ie_pi_buf) >> PAGE_SHIFT;
> > +	req->ki_ioext->ke_pi_iter.pi_offset = offset_in_page(ext->ie_pi_buf);
> > +	req->ki_ioext->ke_pi_iter.pi_len = ext->ie_pi_buflen;
> > +	req->ki_ioext->ke_pi_iter.pi_nrpages = end - start;
> > +	p = kzalloc(req->ki_ioext->ke_pi_iter.pi_nrpages *
> > +		    sizeof(struct page *),
> > +		    GFP_NOIO);
> 
> Can userspace give us bad data and get us to generate insane allcation
> attempt warnings?

Easily.  One of the bits I have to work on for the PI part is figuring out how
to check with the PI provider that the arguments (the iovec and the pi buffer)
actually make any sense, in terms of length and alignment requirements (PI
tuples can't cross pages).  I think it's as simple as adding a bio_integrity
ops call, and then calling down to it from the kiocb level.

One thing I'm not sure about: What's the largest IO (in terms of # of blocks,
not # of struct iovecs) that I can throw at the kernel?

> > +	if (p == NULL) {
> > +		pr_err("%s: no room for page array?\n", __func__);
> > +		return -ENOMEM;
> > +	}
> > +	req->ki_ioext->ke_pi_iter.pi_userpages = p;
> > +
> > +	retval = get_user_pages_fast((unsigned long)ext->ie_pi_buf,
> > +				     req->ki_ioext->ke_pi_iter.pi_nrpages,
> > +				     is_write,
> 
> Isn't this is_write backwards?  If it's a write syscall then the PI
> pages is going to be read from.

Yes, I think so.  Good catch!

--D
> 
> - z
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
