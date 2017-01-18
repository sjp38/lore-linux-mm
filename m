Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7A506B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:30:16 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id a195so13340564qkg.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:30:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 12si428075qtq.202.2017.01.18.07.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 07:30:15 -0800 (PST)
Date: Wed, 18 Jan 2017 17:30:12 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v6 kernel 3/5] virtio-balloon: speed up inflate/deflate
 process
Message-ID: <20170118172401-mutt-send-email-mst@kernel.org>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
 <1482303148-22059-4-git-send-email-liang.z.li@intel.com>
 <20170117211131-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E3C355672@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3C355672@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "david@redhat.com" <david@redhat.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>

On Wed, Jan 18, 2017 at 04:56:58AM +0000, Li, Liang Z wrote:
> > > -	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> > > -	virtqueue_kick(vq);
> > > +static void do_set_resp_bitmap(struct virtio_balloon *vb,
> > > +		unsigned long base_pfn, int pages)
> > >
> > > -	/* When host has read buffer, this completes via balloon_ack */
> > > -	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> > > +{
> > > +	__le64 *range = vb->resp_data + vb->resp_pos;
> > >
> > > +	if (pages > (1 << VIRTIO_BALLOON_NR_PFN_BITS)) {
> > > +		/* when the length field can't contain pages, set it to 0 to
> > 
> > /*
> >  * Multi-line
> >  * comments
> >  * should look like this.
> >  */
> > 
> > Also, pls start sentences with an upper-case letter.
> > 
> 
> Sorry for that.
> 
> > > +		 * indicate the actual length is in the next __le64;
> > > +		 */
> > 
> > This is part of the interface so should be documented as such.
> > 
> > > +		*range = cpu_to_le64((base_pfn <<
> > > +				VIRTIO_BALLOON_NR_PFN_BITS) | 0);
> > > +		*(range + 1) = cpu_to_le64(pages);
> > > +		vb->resp_pos += 2;
> > 
> > Pls use structs for this kind of stuff.
> 
> I am not sure if you mean to use 
> 
> struct  range {
>  	__le64 pfn: 52;
> 	__le64 nr_page: 12
> }
> Instead of the shift operation?

Not just that. You want to add a pages field as well.

Generally describe the format in the header in some way
so host and guest can easily stay in sync.

All the pointer math and void * means we get zero type
safety and I'm not happy about it.


> I didn't use this way because I don't want to include 'virtio-balloon.h' in page_alloc.c,
> or copy the define of this struct in page_alloc.c
> 
> Thanks!
> Liang


It's not good that virtio format seeps out to page_alloc anyway.
If unavoidable it is not a good idea to try to hide this fact,
people will assume they can change the format at will.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
