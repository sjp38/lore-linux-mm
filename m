Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 76B5F6B00F9
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 15:49:50 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id j15so670394qaq.30
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 12:49:50 -0700 (PDT)
Date: Wed, 2 Apr 2014 12:49:47 -0700
From: Zach Brown <zab@redhat.com>
Subject: Re: [PATCH 2/6] io: define an interface for IO extensions
Message-ID: <20140402194947.GJ2394@lenny.home.zabbo.net>
References: <20140324162231.10848.4863.stgit@birch.djwong.org>
 <20140324162244.10848.46322.stgit@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140324162244.10848.46322.stgit@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: axboe@kernel.dk, martin.petersen@oracle.com, JBottomley@parallels.com, jmoyer@redhat.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org

> @@ -916,6 +921,17 @@ void aio_complete(struct kiocb *iocb, long res, long res2)
>  	struct io_event	*ev_page, *event;
>  	unsigned long	flags;
>  	unsigned tail, pos;
> +	int ret;
> +
> +	ret = io_teardown_extensions(iocb);
> +	if (ret) {
> +		if (!res)
> +			res = ret;
> +		else if (!res2)
> +			res2 = ret;
> +		else
> +			pr_err("error %d tearing down aio extensions\n", ret);
> +	}

This ends up trying to copy the kernel's io_extension copy back to
userspace from interrupts, which obviously won't fly.

And to what end?  So that maybe someone can later add an 'extension'
that can fill in some field that's then copied to userspace?  But by
copying the entire argument struct back?

Let's not get ahead of ourselves.  If they're going to try and give
userspace some feedback after IO completion they're going to have to try
a lot harder because they don't have acces to the submitting task
context anymore.  They'd have to pin some reference to a feedback
mechanism in the in-flight io.  I think we'd want that explicit in the
iocb, not hiding off on the other side of this extension interface.

I'd just remove this generic teardown callback path entirely.  If
there's PI state hanging off the iocb tear it down during iocb teardown.

> +struct io_extension_type {
> +	unsigned int type;
> +	unsigned int extension_struct_size;
> +	int (*setup_fn)(struct kiocb *, int is_write);
> +	int (*destroy_fn)(struct kiocb *);
> +};

I'd also get rid of all of this.  More below.

> +static int io_setup_extensions(struct kiocb *req, int is_write,
> +			       struct io_extension __user *ioext)
> +{
> +	struct io_extension_type *iet;
> +	__u64 sz, has;
> +	int ret;
> +
> +	/* Check size of buffer */
> +	if (unlikely(copy_from_user(&sz, &ioext->ie_size, sizeof(sz))))
> +		return -EFAULT;
> +	if (sz > PAGE_SIZE ||
> +	    sz > sizeof(struct io_extension) ||
> +	    sz < IO_EXT_SIZE(ie_has))
> +		return -EINVAL;
> +
> +	/* Check that the buffer's big enough */
> +	if (unlikely(copy_from_user(&has, &ioext->ie_has, sizeof(has))))
> +		return -EFAULT;
> +	ret = io_check_bufsize(has, sz);
> +	if (ret)
> +		return ret;
> +
> +	/* Copy from userland */
> +	req->ki_ioext = kzalloc(sizeof(struct kio_extension), GFP_NOIO);
> +	if (!req->ki_ioext)
> +		return -ENOMEM;
> +
> +	req->ki_ioext->ke_user = ioext;
> +	if (unlikely(copy_from_user(&req->ki_ioext->ke_kern, ioext, sz))) {
> +		ret = -EFAULT;
> +		goto out;
> +	}

(Isn't there some allocate-and-copy-from-userspace helper now? But..)

I don't like the rudundancy of the implicit size requirement by a
field's flag being set being duplicated by the explicit size argument.
What does that give us, exactly?

Our notion of the total size only seems to only matter if we're copying
the entire struct from userspace and I'm don't think we need to do that.

For each argument, we're translating it into some kernel equivalent,
right?  Fields in the iocb  As each of these are initialized I'd just
test the presence bits and __get_user() the userspace arguemnts
directly, or copy_from_user() something slightly more complicated on to
the stack.

That gets rid of us having to care about the size at all.  It stops us
from allocating a kernel copy and pinning it for the duration of the IO.
We'd just be sampling the present userspace arguments as we initialie
the iocb during submission.

> +	/* Try to initialize all the extensions */
> +	has = 0;
> +	for (iet = extensions; iet->type != IO_EXT_INVALID; iet++) {
> +		if (!(req->ki_ioext->ke_kern.ie_has & iet->type))
> +			continue;
> +		ret = iet->setup_fn(req, is_write);
> +		if (ret) {
> +			req->ki_ioext->ke_kern.ie_has = has;
> +			goto out_destroy;
> +		}
> +		has |= iet->type;
> +	}

So instead of doing all this we'd test explicit bits and act
accordingly.  If they're trivial translations between userspace fields
and iocb fields we could just do it inline in this helper that'd be more
like iocb_parse_more_args(iocb, struct __user *ptr).  For more
complicated stuff, like the PI page pinning, it could call out to PI.

> +	user_ext = (struct io_extension __user *)iocb->aio_extension_ptr;

Need a __force there?  Has this been run through sparse?

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
