Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 876326B0121
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 18:08:37 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so822869pbb.39
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 15:08:37 -0700 (PDT)
Date: Wed, 2 Apr 2014 15:08:26 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 2/6] io: define an interface for IO extensions
Message-ID: <20140402220826.GC10230@birch.djwong.org>
References: <20140324162231.10848.4863.stgit@birch.djwong.org>
 <20140324162244.10848.46322.stgit@birch.djwong.org>
 <x49ha6btu37.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49ha6btu37.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: axboe@kernel.dk, zab@redhat.com, martin.petersen@oracle.com, JBottomley@parallels.com, bcrl@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On Wed, Apr 02, 2014 at 03:22:20PM -0400, Jeff Moyer wrote:
> "Darrick J. Wong" <darrick.wong@oracle.com> writes:
> 
> > Define a generic interface to allow userspace to attach metadata to an
> > IO operation.  This interface will be used initially to implement
> > protection information (PI) pass through, though it ought to be usable
> > by anyone else desiring to extend the IO interface.  It should not be
> > difficult to modify the non-AIO calls to use this mechanism.
> 
> My main issue with this patch is determining what exactly gets returned
> to userspace when there is an issue in the teardown_extensions path.
> It looks like you'll get the first error propagated from
> io_teardown_extensions, others are ignored.  Then, in aio_complete, if
> there was no error with the I/O, then you'll get the teardown error
> reported in event->res, otherwise you'll get it in event->res2.  So,
> what are the valid errors returned by the teardown routine for
> extensions?  How is the userspace app supposed to determine where the
> error came from, the I/O or a failure in the extension teardown?

There's also the question of which extension spat out the error.  One solution
would be to augment struct io_extension with all the error fields that we want
(an extension can declare its own if needed) as we do now, and if errors happen
during setup, we can just copy_to_user them back.  If nothing else fails with
the IO setup, the setup routine can return -EINVAL, and userspace can look for
updated error fields in the struct.

Unfortunately for the teardown error case you'd have to pin the whole page in
memory for the duration of the IO just to have it around.  For now this isn't a
problem because teardown can't fail anyway.

> I think it may make sense to only use res2 for reporting io extension
> teardown failures.  Any new code that will use extensions can certainly
> be written to check both res and res2, and this method would prevent the
> ambiguity I mentioned.

Hmm, doesn't look like anyone actually uses res2 except for USB gadgets.

It's tempting just to shove the first ioextension error code that comes along
into res2 and abort the whole thing, and let userspace guess where the res2
code came from.  I think there's an additional problem with stuffing return
codes: in the case of synchronous IO syscalls, we'd have to deal with how to
cram error codes from (potentially) multiple sources into the single return
value, while not giving userspace any help as to where the code came from.

Now that I've written all that out, I don't like this idea so I'll drop it. :)

> Finally, I know this is an RFC, but please add some man-page changes to
> your patch set, and CC linux-man.  Michael Kerrisk typically has
> valuable advice on new APIs.

I'll do that the next time I rev the patches.  Thank you for the suggestion.

--D
> 
> Cheers,
> Jeff
> 
> >
> > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > ---
> >  fs/aio.c                     |  180 +++++++++++++++++++++++++++++++++++++++++-
> >  include/linux/aio.h          |    7 ++
> >  include/uapi/linux/aio_abi.h |   15 +++-
> >  3 files changed, 197 insertions(+), 5 deletions(-)
> >
> >
> > diff --git a/fs/aio.c b/fs/aio.c
> > index 062a5f6..0c40bdc 100644
> > --- a/fs/aio.c
> > +++ b/fs/aio.c
> > @@ -158,6 +158,11 @@ static struct vfsmount *aio_mnt;
> >  static const struct file_operations aio_ring_fops;
> >  static const struct address_space_operations aio_ctx_aops;
> >  
> > +static int io_teardown_extensions(struct kiocb *req);
> > +static int io_setup_extensions(struct kiocb *req, int is_write,
> > +			       struct io_extension __user *ioext);
> > +static int iocb_setup_extensions(struct iocb *iocb, struct kiocb *req);
> > +
> >  static struct file *aio_private_file(struct kioctx *ctx, loff_t nr_pages)
> >  {
> >  	struct qstr this = QSTR_INIT("[aio]", 5);
> > @@ -916,6 +921,17 @@ void aio_complete(struct kiocb *iocb, long res, long res2)
> >  	struct io_event	*ev_page, *event;
> >  	unsigned long	flags;
> >  	unsigned tail, pos;
> > +	int ret;
> > +
> > +	ret = io_teardown_extensions(iocb);
> > +	if (ret) {
> > +		if (!res)
> > +			res = ret;
> > +		else if (!res2)
> > +			res2 = ret;
> > +		else
> > +			pr_err("error %d tearing down aio extensions\n", ret);
> > +	}
> >  
> >  	/*
> >  	 * Special case handling for sync iocbs:
> > @@ -1350,15 +1366,167 @@ rw_common:
> >  	return 0;
> >  }
> >  
> > +/* IO extension code */
> > +#define REQUIRED_STRUCTURE_SIZE(type, member)	\
> > +	(offsetof(type, member) + sizeof(((type *)NULL)->member))
> > +#define IO_EXT_SIZE(member) \
> > +	REQUIRED_STRUCTURE_SIZE(struct io_extension, member)
> > +
> > +struct io_extension_type {
> > +	unsigned int type;
> > +	unsigned int extension_struct_size;
> > +	int (*setup_fn)(struct kiocb *, int is_write);
> > +	int (*destroy_fn)(struct kiocb *);
> > +};
> > +
> > +static struct io_extension_type extensions[] = {
> > +	{IO_EXT_INVALID, 0, NULL, NULL},
> > +};
> > +
> > +static int is_write_iocb(struct iocb *iocb)
> > +{
> > +	switch (iocb->aio_lio_opcode) {
> > +	case IOCB_CMD_PWRITE:
> > +	case IOCB_CMD_PWRITEV:
> > +		return 1;
> > +	default:
> > +		return 0;
> > +	}
> > +}
> > +
> > +static int io_teardown_extensions(struct kiocb *req)
> > +{
> > +	struct io_extension_type *iet;
> > +	int ret, ret2;
> > +
> > +	if (req->ki_ioext == NULL)
> > +		return 0;
> > +
> > +	/* Shut down all the extensions */
> > +	ret = 0;
> > +	for (iet = extensions; iet->type != IO_EXT_INVALID; iet++) {
> > +		if (!(req->ki_ioext->ke_kern.ie_has & iet->type))
> > +			continue;
> > +		ret2 = iet->destroy_fn(req);
> > +		if (ret2 && !ret)
> > +			ret = ret2;
> > +	}
> > +
> > +	/* Copy out return values */
> > +	if (unlikely(copy_to_user(req->ki_ioext->ke_user,
> > +				  &req->ki_ioext->ke_kern,
> > +				  sizeof(struct io_extension)))) {
> > +		if (!ret)
> > +			ret = -EFAULT;
> > +	}
> > +
> > +	kfree(req->ki_ioext);
> > +	req->ki_ioext = NULL;
> > +	return ret;
> > +}
> > +
> > +static int io_check_bufsize(__u64 has, __u64 size)
> > +{
> > +	struct io_extension_type *iet;
> > +	__u64 all_flags = 0;
> > +
> > +	for (iet = extensions; iet->type != IO_EXT_INVALID; iet++) {
> > +		all_flags |= iet->type;
> > +		if (!(has & iet->type))
> > +			continue;
> > +		if (iet->extension_struct_size > size)
> > +			return -EINVAL;
> > +	}
> > +
> > +	if (has & ~all_flags)
> > +		return -EINVAL;
> > +
> > +	return 0;
> > +}
> > +
> > +static int io_setup_extensions(struct kiocb *req, int is_write,
> > +			       struct io_extension __user *ioext)
> > +{
> > +	struct io_extension_type *iet;
> > +	__u64 sz, has;
> > +	int ret;
> > +
> > +	/* Check size of buffer */
> > +	if (unlikely(copy_from_user(&sz, &ioext->ie_size, sizeof(sz))))
> > +		return -EFAULT;
> > +	if (sz > PAGE_SIZE ||
> > +	    sz > sizeof(struct io_extension) ||
> > +	    sz < IO_EXT_SIZE(ie_has))
> > +		return -EINVAL;
> > +
> > +	/* Check that the buffer's big enough */
> > +	if (unlikely(copy_from_user(&has, &ioext->ie_has, sizeof(has))))
> > +		return -EFAULT;
> > +	ret = io_check_bufsize(has, sz);
> > +	if (ret)
> > +		return ret;
> > +
> > +	/* Copy from userland */
> > +	req->ki_ioext = kzalloc(sizeof(struct kio_extension), GFP_NOIO);
> > +	if (!req->ki_ioext)
> > +		return -ENOMEM;
> > +
> > +	req->ki_ioext->ke_user = ioext;
> > +	if (unlikely(copy_from_user(&req->ki_ioext->ke_kern, ioext, sz))) {
> > +		ret = -EFAULT;
> > +		goto out;
> > +	}
> > +
> > +	/* Try to initialize all the extensions */
> > +	has = 0;
> > +	for (iet = extensions; iet->type != IO_EXT_INVALID; iet++) {
> > +		if (!(req->ki_ioext->ke_kern.ie_has & iet->type))
> > +			continue;
> > +		ret = iet->setup_fn(req, is_write);
> > +		if (ret) {
> > +			req->ki_ioext->ke_kern.ie_has = has;
> > +			goto out_destroy;
> > +		}
> > +		has |= iet->type;
> > +	}
> > +
> > +	return 0;
> > +out_destroy:
> > +	io_teardown_extensions(req);
> > +out:
> > +	kfree(req->ki_ioext);
> > +	req->ki_ioext = NULL;
> > +	return ret;
> > +}
> > +
> > +static int iocb_setup_extensions(struct iocb *iocb, struct kiocb *req)
> > +{
> > +	struct io_extension __user *user_ext;
> > +
> > +	if (!(iocb->aio_flags & IOCB_FLAG_EXTENSIONS))
> > +		return 0;
> > +
> > +	user_ext = (struct io_extension __user *)iocb->aio_extension_ptr;
> > +	return io_setup_extensions(req, is_write_iocb(iocb), user_ext);
> > +}
> > +
> >  static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
> >  			 struct iocb *iocb, bool compat)
> >  {
> >  	struct kiocb *req;
> >  	ssize_t ret;
> >  
> > +	/* check for flags we don't know about */
> > +	if (iocb->aio_flags & ~IOCB_FLAG_ALL) {
> > +		pr_debug("EINVAL: invalid flags\n");
> > +		return -EINVAL;
> > +	}
> > +
> >  	/* enforce forwards compatibility on users */
> > -	if (unlikely(iocb->aio_reserved1 || iocb->aio_reserved2)) {
> > -		pr_debug("EINVAL: reserve field set\n");
> > +	if (unlikely(iocb->aio_reserved1 ||
> > +	    (!(iocb->aio_flags & IOCB_FLAG_EXTENSIONS) &&
> > +	     iocb->aio_extension_ptr))) {
> > +		pr_debug("EINVAL: reserved field set\n");
> >  		return -EINVAL;
> >  	}
> >  
> > @@ -1408,13 +1576,19 @@ static int io_submit_one(struct kioctx *ctx, struct iocb __user *user_iocb,
> >  	req->ki_pos = iocb->aio_offset;
> >  	req->ki_nbytes = iocb->aio_nbytes;
> >  
> > +	ret = iocb_setup_extensions(iocb, req);
> > +	if (unlikely(ret))
> > +		goto out_del_ext;
> > +
> >  	ret = aio_run_iocb(req, iocb->aio_lio_opcode,
> >  			   (char __user *)(unsigned long)iocb->aio_buf,
> >  			   compat);
> >  	if (ret)
> > -		goto out_put_req;
> > +		goto out_del_ext;
> >  
> >  	return 0;
> > +out_del_ext:
> > +	io_teardown_extensions(req);
> >  out_put_req:
> >  	put_reqs_available(ctx, 1);
> >  	percpu_ref_put(&ctx->reqs);
> > diff --git a/include/linux/aio.h b/include/linux/aio.h
> > index d9c92da..60f4364 100644
> > --- a/include/linux/aio.h
> > +++ b/include/linux/aio.h
> > @@ -29,6 +29,10 @@ struct kiocb;
> >  
> >  typedef int (kiocb_cancel_fn)(struct kiocb *);
> >  
> > +struct kio_extension {
> > +	struct io_extension __user *ke_user;
> > +	struct io_extension ke_kern;
> > +};
> >  struct kiocb {
> >  	struct file		*ki_filp;
> >  	struct kioctx		*ki_ctx;	/* NULL for sync ops */
> > @@ -52,6 +56,9 @@ struct kiocb {
> >  	 * this is the underlying eventfd context to deliver events to.
> >  	 */
> >  	struct eventfd_ctx	*ki_eventfd;
> > +
> > +	/* Kernel copy of extension descriptors */
> > +	struct kio_extension	*ki_ioext;
> >  };
> >  
> >  static inline bool is_sync_kiocb(struct kiocb *kiocb)
> > diff --git a/include/uapi/linux/aio_abi.h b/include/uapi/linux/aio_abi.h
> > index bb2554f..07ffd1f 100644
> > --- a/include/uapi/linux/aio_abi.h
> > +++ b/include/uapi/linux/aio_abi.h
> > @@ -53,6 +53,8 @@ enum {
> >   *                   is valid.
> >   */
> >  #define IOCB_FLAG_RESFD		(1 << 0)
> > +#define IOCB_FLAG_EXTENSIONS	(1 << 1)
> > +#define IOCB_FLAG_ALL		(IOCB_FLAG_RESFD | IOCB_FLAG_EXTENSIONS)
> >  
> >  /* read() from /dev/aio returns these structures. */
> >  struct io_event {
> > @@ -70,6 +72,15 @@ struct io_event {
> >  #error edit for your odd byteorder.
> >  #endif
> >  
> > +/* IO extension types */
> > +#define IO_EXT_INVALID	(0)
> > +
> > +/* IO extension descriptor */
> > +struct io_extension {
> > +	__u64 ie_size;
> > +	__u64 ie_has;
> > +};
> > +
> >  /*
> >   * we always use a 64bit off_t when communicating
> >   * with userland.  its up to libraries to do the
> > @@ -91,8 +102,8 @@ struct iocb {
> >  	__u64	aio_nbytes;
> >  	__s64	aio_offset;
> >  
> > -	/* extra parameters */
> > -	__u64	aio_reserved2;	/* TODO: use this for a (struct sigevent *) */
> > +	/* aio extensions, only present if IOCB_FLAG_EXTENSIONS */
> > +	__u64	aio_extension_ptr;
> >  
> >  	/* flags for the "struct iocb" */
> >  	__u32	aio_flags;
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
