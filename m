Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFDCC6B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 11:34:38 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id o65so118060380yba.3
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 08:34:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 53si5193294qtx.279.2017.01.20.08.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 08:34:37 -0800 (PST)
Date: Fri, 20 Jan 2017 18:34:34 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v6 kernel 3/5] virtio-balloon: speed up inflate/deflate
 process
Message-ID: <20170120183215-mutt-send-email-mst@kernel.org>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
 <1482303148-22059-4-git-send-email-liang.z.li@intel.com>
 <20170117211131-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E3C355672@shsmsx102.ccr.corp.intel.com>
 <20170118172401-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E3C3578BF@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3C3578BF@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "david@redhat.com" <david@redhat.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>

On Thu, Jan 19, 2017 at 01:44:36AM +0000, Li, Liang Z wrote:
> > > > > +		*range = cpu_to_le64((base_pfn <<
> > > > > +				VIRTIO_BALLOON_NR_PFN_BITS) | 0);
> > > > > +		*(range + 1) = cpu_to_le64(pages);
> > > > > +		vb->resp_pos += 2;
> > > >
> > > > Pls use structs for this kind of stuff.
> > >
> > > I am not sure if you mean to use
> > >
> > > struct  range {
> > >  	__le64 pfn: 52;
> > > 	__le64 nr_page: 12
> > > }
> > > Instead of the shift operation?
> > 
> > Not just that. You want to add a pages field as well.
> > 
> 
> pages field? Could you give more hints?

Well look how you are formatting it manually above.
There is clearly a structure with two 64 bit fields.
First one includes pfn and 0 (no idea why does | 0 make
sense but that's a separate issue).
Second one includes the pages value.


> > Generally describe the format in the header in some way so host and guest
> > can easily stay in sync.
> 
> 'VIRTIO_BALLOON_NR_PFN_BITS' is for this purpose and it will be passed to the
> related function in page_alloc.c as a parameter.
> 
> Thanks!
> Liang
> > All the pointer math and void * means we get zero type safety and I'm not
> > happy about it.
> > 
> > It's not good that virtio format seeps out to page_alloc anyway.
> > If unavoidable it is not a good idea to try to hide this fact, people will assume
> > they can change the format at will.
> > 
> > --
> > MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
