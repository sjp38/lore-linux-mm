Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 769C56B0103
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 16:01:40 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id w7so788174qcr.8
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 13:01:40 -0700 (PDT)
Date: Wed, 2 Apr 2014 13:01:33 -0700
From: Zach Brown <zab@redhat.com>
Subject: Re: [PATCH 3/6] aio/dio: enable PI passthrough
Message-ID: <20140402200133.GK2394@lenny.home.zabbo.net>
References: <20140324162231.10848.4863.stgit@birch.djwong.org>
 <20140324162251.10848.56452.stgit@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140324162251.10848.56452.stgit@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, jmoyer@redhat.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

> +static int setup_pi_ext(struct kiocb *req, int is_write)
> +{
> +	struct file *file = req->ki_filp;
> +	struct io_extension *ext = &req->ki_ioext->ke_kern;
> +	void *p;
> +	unsigned long start, end;
> +	int retval;
> +
> +	if (!(file->f_flags & O_DIRECT)) {
> +		pr_debug("EINVAL: can't use PI without O_DIRECT.\n");
> +		return -EINVAL;
> +	}
> +
> +	BUG_ON(req->ki_ioext->ke_pi_iter.pi_userpages);
> +
> +	end = (((unsigned long)ext->ie_pi_buf) + ext->ie_pi_buflen +
> +		PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	start = ((unsigned long)ext->ie_pi_buf) >> PAGE_SHIFT;
> +	req->ki_ioext->ke_pi_iter.pi_offset = offset_in_page(ext->ie_pi_buf);
> +	req->ki_ioext->ke_pi_iter.pi_len = ext->ie_pi_buflen;
> +	req->ki_ioext->ke_pi_iter.pi_nrpages = end - start;
> +	p = kzalloc(req->ki_ioext->ke_pi_iter.pi_nrpages *
> +		    sizeof(struct page *),
> +		    GFP_NOIO);

Can userspace give us bad data and get us to generate insane allcation
attempt warnings?

> +	if (p == NULL) {
> +		pr_err("%s: no room for page array?\n", __func__);
> +		return -ENOMEM;
> +	}
> +	req->ki_ioext->ke_pi_iter.pi_userpages = p;
> +
> +	retval = get_user_pages_fast((unsigned long)ext->ie_pi_buf,
> +				     req->ki_ioext->ke_pi_iter.pi_nrpages,
> +				     is_write,

Isn't this is_write backwards?  If it's a write syscall then the PI
pages is going to be read from.

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
