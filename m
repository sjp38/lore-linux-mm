Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E9E4E6B004D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 09:41:13 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv4 2/2] vhost_net: a kernel-level virtio server
Date: Wed, 26 Aug 2009 15:40:59 +0200
References: <cover.1250693417.git.mst@redhat.com> <200908252140.41295.rusty@rustcorp.com.au> <20090825175016.GA15790@redhat.com>
In-Reply-To: <20090825175016.GA15790@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200908261540.59900.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: virtualization@lists.linux-foundation.org
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, mingo@elte.hu, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tuesday 25 August 2009, Michael S. Tsirkin wrote:
> >  I'd like to avoid that here,
> > though it's kind of ugly.  We'd need VHOST_GET_FEATURES (and ACK) to take a
> > struct like:
> > 
> >       u32 feature_size;
> >       u32 features[];

Hmm, variable length ioctl arguments, I'd rather not go there.
The ioctl infrastructure already has a length argument encoded
in the ioctl number. We can use that if we need more, e.g.

/* now */
#define VHOST_GET_FEATURES     _IOR(VHOST_VIRTIO, 0x00, __u64)
/*
 * uncomment if we run out of feature bits:

struct vhost_get_features2 {
	__u64 bits[2];
};
#define VHOST_GET_FEATURES2     _IOR(VHOST_VIRTIO, 0x00, \
			struct  vhost_get_features2)
 */

> Thinking about this proposal some more, how will the guest
> determine the size to supply the GET_FEATURES ioctl?

Wait, the *guest*?

Maybe I misunderstood something in a major way here, but
I expected the features to be negotiated between host
user space (qemu) and host kernel, as well as between
guest and qemu (as they are already), but never between
guest and kernel.

I would certainly expect the bits to be distinct from
the virtio-net feature bits. E.g. stuff like TAP frame
format opposed to TCP socket frame format (length+date)
is something we need to negotiate here but that the
guest does not care about.

> Since we are a bit tight in 32 bit space already,
> let's just use a 64 bit integer and be done with it?

Can't hurt, but don't use a struct unless you think
we are going to need more than 64 bits.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
