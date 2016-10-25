Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 791556B0282
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 21:21:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i85so132782382pfa.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 18:21:26 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q199si18198903pgq.205.2016.10.24.18.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 18:21:25 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RESEND PATCH v3 kernel 2/7] virtio-balloon: define new feature
 bit and page bitmap head
Date: Tue, 25 Oct 2016 01:21:21 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A0FB4FF@shsmsx102.ccr.corp.intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <1477031080-12616-3-git-send-email-liang.z.li@intel.com>
 <580E3C07.701@intel.com>
In-Reply-To: <580E3C07.701@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>

> On 10/20/2016 11:24 PM, Liang Li wrote:
> > Add a new feature which supports sending the page information with a
> > bitmap. The current implementation uses PFNs array, which is not very
> > efficient. Using bitmap can improve the performance of
> > inflating/deflating significantly
>=20
> Why is it not efficient?  How is using a bitmap more efficient?  What kin=
ds of
> cases is the bitmap inefficient?
>=20
> > The page bitmap header will used to tell the host some information
> > about the page bitmap. e.g. the page size, page bitmap length and
> > start pfn.
>=20
> Why did you choose to add these features to the structure?  What benefits
> do they add?
>=20
> Could you describe your solution a bit here, and describe its strengths a=
nd
> weaknesses?
>=20

Will elaborate the solution in V4.

> >  /* Size of a PFN in the balloon interface. */  #define
> > VIRTIO_BALLOON_PFN_SHIFT 12 @@ -82,4 +83,22 @@ struct
> > virtio_balloon_stat {
> >  	__virtio64 val;
> >  } __attribute__((packed));
> >
> > +/* Page bitmap header structure */
> > +struct balloon_bmap_hdr {
> > +	/* Used to distinguish different request */
> > +	__virtio16 cmd;
> > +	/* Shift width of page in the bitmap */
> > +	__virtio16 page_shift;
> > +	/* flag used to identify different status */
> > +	__virtio16 flag;
> > +	/* Reserved */
> > +	__virtio16 reserved;
> > +	/* ID of the request */
> > +	__virtio64 req_id;
> > +	/* The pfn of 0 bit in the bitmap */
> > +	__virtio64 start_pfn;
> > +	/* The length of the bitmap, in bytes */
> > +	__virtio64 bmap_len;
> > +};
>=20
> FWIW this is totally unreadable.  Please do something like this:
>=20
> > +struct balloon_bmap_hdr {
> > +	__virtio16 cmd; 	/* Used to distinguish different ...
> > +	__virtio16 page_shift; 	/* Shift width of page in the bitmap */
> > +	__virtio16 flag; 	/* flag used to identify different...
> > +	__virtio16 reserved;	/* Reserved */
> > +	__virtio64 req_id;	/* ID of the request */
> > +	__virtio64 start_pfn;	/* The pfn of 0 bit in the bitmap */
> > +	__virtio64 bmap_len;	/* The length of the bitmap, in bytes */
> > +};
>=20
> and please make an effort to add useful comments.  "/* Reserved */"
> seems like a waste of bytes to me.

OK. Maybe 'padding' is better than 'reserved' .

Thanks for your comments!

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
