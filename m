Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6496B02C3
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 17:36:40 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v31so10348263wrc.7
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 14:36:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l8si11554wmi.78.2017.08.09.14.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 14:36:39 -0700 (PDT)
Date: Wed, 9 Aug 2017 14:36:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v13 1/5] Introduce xbitmap
Message-Id: <20170809143636.e2c2d2713f58768c1427855d@linux-foundation.org>
In-Reply-To: <1501742299-4369-2-git-send-email-wei.w.wang@intel.com>
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
	<1501742299-4369-2-git-send-email-wei.w.wang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, mawilcox@microsoft.com, virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Thu,  3 Aug 2017 14:38:15 +0800 Wei Wang <wei.w.wang@intel.com> wrote:

> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> The eXtensible Bitmap is a sparse bitmap representation which is
> efficient for set bits which tend to cluster.  It supports up to
> 'unsigned long' worth of bits, and this commit adds the bare bones --
> xb_set_bit(), xb_clear_bit() and xb_test_bit().

Would like to see some additional details here justifying the change. 
The sole user is virtio-balloon, yes?  What alternatives were examined
and what are the benefits of this approach?

Have you identified any other subsystems which could utilize this?

>
> ...
>
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -37,6 +37,7 @@
>  #include <linux/rcupdate.h>
>  #include <linux/slab.h>
>  #include <linux/string.h>
> +#include <linux/xbitmap.h>
>  
>  
>  /* Number of nodes in fully populated tree of given height */
> @@ -78,6 +79,14 @@ static struct kmem_cache *radix_tree_node_cachep;
>  #define IDA_PRELOAD_SIZE	(IDA_MAX_PATH * 2 - 1)
>  
>  /*
> + * The XB can go up to unsigned long, but also uses a bitmap.

This comment is hard to understand.

> + */
> +#define XB_INDEX_BITS		(BITS_PER_LONG - ilog2(IDA_BITMAP_BITS))
> +#define XB_MAX_PATH		(DIV_ROUND_UP(XB_INDEX_BITS, \
> +					      RADIX_TREE_MAP_SHIFT))
> +#define XB_PRELOAD_SIZE		(XB_MAX_PATH * 2 - 1)
> +
>
> ...
>  
> +void xb_preload(gfp_t gfp)
> +{
> +	__radix_tree_preload(gfp, XB_PRELOAD_SIZE);
> +	if (!this_cpu_read(ida_bitmap)) {
> +		struct ida_bitmap *bitmap = kmalloc(sizeof(*bitmap), gfp);
> +
> +		if (!bitmap)
> +			return;
> +		bitmap = this_cpu_cmpxchg(ida_bitmap, NULL, bitmap);
> +		kfree(bitmap);
> +	}
> +}
> +EXPORT_SYMBOL(xb_preload);

Please document the exported API.  It's conventional to do this in
kerneldoc but for some reason kerneldoc makes people write
uninteresting and unuseful documentation.  Be sure to cover the
*useful* stuff: what it does, why it does it, under which circumstances
it should be used, what the caller-provided locking should look like,
what the return values mean, etc.  Stuff which programmers actually
will benefit from knowing.

> +int xb_set_bit(struct xb *xb, unsigned long bit)
>
> ...
>
> +int xb_clear_bit(struct xb *xb, unsigned long bit)

There's quite a lot of common code here.  Did you investigate factoring
that out in some fashion?

> +bool xb_test_bit(const struct xb *xb, unsigned long bit)
> +{
> +	unsigned long index = bit / IDA_BITMAP_BITS;
> +	const struct radix_tree_root *root = &xb->xbrt;
> +	struct ida_bitmap *bitmap = radix_tree_lookup(root, index);
> +
> +	bit %= IDA_BITMAP_BITS;
> +
> +	if (!bitmap)
> +		return false;
> +	if (radix_tree_exception(bitmap)) {
> +		bit += RADIX_TREE_EXCEPTIONAL_SHIFT;
> +		if (bit > BITS_PER_LONG)
> +			return false;
> +		return (unsigned long)bitmap & (1UL << bit);
> +	}
> +	return test_bit(bit, bitmap->bitmap);
> +}
> +

Missing EXPORT_SYMBOL?


Perhaps all this code should go into a new lib/xbitmap.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
