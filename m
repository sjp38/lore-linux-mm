Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B30E06B00A3
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:11:40 -0400 (EDT)
Received: from int-mx07.intmail.prod.int.phx2.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n7PKBhds014773
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:11:43 -0400
Date: Tue, 25 Aug 2009 20:50:16 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv4 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090825175016.GA15790@redhat.com>
References: <cover.1250693417.git.mst@redhat.com> <20090819150309.GC4236@redhat.com> <200908252140.41295.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200908252140.41295.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 09:40:40PM +0930, Rusty Russell wrote:
> > +	u32 __user *featurep = argp;
> > +	int __user *fdp = argp;
> > +	u32 features;
> > +	int fd, r;
> > +	switch (ioctl) {
> > +	case VHOST_NET_SET_SOCKET:
> > +		r = get_user(fd, fdp);
> > +		if (r < 0)
> > +			return r;
> > +		return vhost_net_set_socket(n, fd);
> > +	case VHOST_GET_FEATURES:
> > +		/* No features for now */
> > +		features = 0;
> > +		return put_user(features, featurep);
> 
> We may well get more than 32 feature bits, at least for virtio_net, which will
> force us to do some trickery in virtio_pci.

Unlike PCI, if we ever run out of bits we can just
add FEATURES_EXTENDED ioctl, no need for trickery.

>  I'd like to avoid that here,
> though it's kind of ugly.  We'd need VHOST_GET_FEATURES (and ACK) to take a
> struct like:
> 
> 	u32 feature_size;
> 	u32 features[];


Thinking about this proposal some more, how will the guest
determine the size to supply the GET_FEATURES ioctl?

Since we are a bit tight in 32 bit space already,
let's just use a 64 bit integer and be done with it?
Right?

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
