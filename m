Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0EFA1900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 08:18:23 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so74765537qcy.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 05:18:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fm10si1626897qcb.45.2015.04.21.05.18.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Apr 2015 05:18:21 -0700 (PDT)
Date: Tue, 21 Apr 2015 14:18:17 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/3] uffd: Introduce the v2 API
Message-ID: <20150421121817.GD4481@redhat.com>
References: <5509D342.7000403@parallels.com>
 <5509D375.7000809@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5509D375.7000809@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>

On Wed, Mar 18, 2015 at 10:35:17PM +0300, Pavel Emelyanov wrote:
> +		if (!(ctx->features & UFFD_FEATURE_LONGMSG)) {

If we are to use different protocols, it'd be nicer to have two
different methods to assign to userfaultfd_fops.read that calls an
__always_inline function, so that the above check can be optimized
away at build time when the inline is expanded. So the branch is
converted to calling a different pointer to function which is zero
additional cost.

> +			/* careful to always initialize addr if ret == 0 */
> +			__u64 uninitialized_var(addr);
> +			__u64 uninitialized_var(mtype);
> +			if (count < sizeof(addr))
> +				return ret ? ret : -EINVAL;
> +			_ret = userfaultfd_ctx_read(ctx, no_wait, &mtype, &addr);
> +			if (_ret < 0)
> +				return ret ? ret : _ret;
> +			BUG_ON(mtype != UFFD_PAGEFAULT);
> +			if (put_user(addr, (__u64 __user *) buf))
> +				return ret ? ret : -EFAULT;
> +			_ret = sizeof(addr);
> +		} else {
> +			struct uffd_v2_msg msg;
> +			if (count < sizeof(msg))
> +				return ret ? ret : -EINVAL;
> +			_ret = userfaultfd_ctx_read(ctx, no_wait, &msg.type, &msg.arg);
> +			if (_ret < 0)
> +				return ret ? ret : _ret;
> +			if (copy_to_user(buf, &msg, sizeof(msg)))
> +				return ret ? ret : -EINVAL;
> +			_ret = sizeof(msg);

Reading 16bytes instead of 8bytes for each fault, probably wouldn't
move the needle much in terms of userfaultfd_read performance. Perhaps
we could consider using the uffd_v2_msg unconditionally and then have
a single protocol differentiated by the feature bits.

The only reason to have two different protocols would be to be able to
read 8 bytes per userfault, in the cooperative usage (i.e. qemu
postcopy). But if we do that we want to use the __always_inline trick
to avoid branches and additional runtime costs (otherwise we may as
well forget all microoptimizations and read 16bytes always).

> @@ -992,6 +1013,12 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
>  	/* careful not to leak info, we only read the first 8 bytes */
>  	uffdio_api.bits = UFFD_API_BITS;
>  	uffdio_api.ioctls = UFFD_API_IOCTLS;
> +
> +	if (uffdio_api.api == UFFD_API_V2) {
> +		ctx->features |= UFFD_FEATURE_LONGMSG;
> +		uffdio_api.bits |= UFFD_API_V2_BITS;
> +	}
> +
>  	ret = -EFAULT;
>  	if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
>  		goto out;

The original meaning of the bits is:

If UFFD_BIT_WRITE was set in api.bits, it means the
!!(address&UFFD_BIT_WRITE) tells if it was a write fault (missing or
WP).

If UFFD_BIT_WP was set in api.bits, it means the
!!(address&UFFD_BIT_WP) tells if it was a WP fault (if not set it
means it was a missing fault).

Currently api.bits sets only UFFD_BIT_WRITE, and UFFD_BIT_WP will be
set later, after the WP tracking mode will be implemented.

I'm uncertain how bits translated to features and if they should be
unified or only have features.

> +struct uffd_v2_msg {
> +	__u64	type;
> +	__u64	arg;
> +};
> +
> +#define UFFD_PAGEFAULT	0x1
> +
> +#define UFFD_PAGEFAULT_BIT	(1 << (UFFD_PAGEFAULT - 1))
> +#define __UFFD_API_V2_BITS	(UFFD_PAGEFAULT_BIT)
> +
> +/*
> + * Lower PAGE_SHIFT bits are used to report those supported
> + * by the pagefault message itself. Other bits are used to
> + * report the message types v2 API supports
> + */
> +#define UFFD_API_V2_BITS	(__UFFD_API_V2_BITS << 12)
> +

And why exactly is this 12 hardcoded? And which field should be masked
with the bits? In the V1 protocol it was the "arg" (userfault address)
not the "type". So this is a bit confusing and probably requires
simplification.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
