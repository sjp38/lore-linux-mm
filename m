Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 80CCB6B025F
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 11:25:19 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 61so3051181plz.1
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 08:25:19 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h9si3195355pli.42.2017.11.30.08.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 08:25:18 -0800 (PST)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v18 07/10] virtio-balloon: VIRTIO_BALLOON_F_SG
Date: Thu, 30 Nov 2017 16:25:09 +0000
Message-ID: <286AC319A985734F985F78AFA26841F739376336@shsmsx102.ccr.corp.intel.com>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
	<1511963726-34070-8-git-send-email-wei.w.wang@intel.com>
 <201711301935.EHF86450.MSFLOOHFJtFOQV@I-love.SAKURA.ne.jp>
In-Reply-To: <201711301935.EHF86450.MSFLOOHFJtFOQV@I-love.SAKURA.ne.jp>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "willy@infradead.org" <willy@infradead.org>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>

On Thursday, November 30, 2017 6:36 PM, Tetsuo Handa wrote:
> Wei Wang wrote:
> > +static inline int xb_set_page(struct virtio_balloon *vb,
> > +			       struct page *page,
> > +			       unsigned long *pfn_min,
> > +			       unsigned long *pfn_max)
> > +{
> > +	unsigned long pfn =3D page_to_pfn(page);
> > +	int ret;
> > +
> > +	*pfn_min =3D min(pfn, *pfn_min);
> > +	*pfn_max =3D max(pfn, *pfn_max);
> > +
> > +	do {
> > +		ret =3D xb_preload_and_set_bit(&vb->page_xb, pfn,
> > +					     GFP_NOWAIT | __GFP_NOWARN);
>=20
> It is a bit of pity that __GFP_NOWARN here is applied to only xb_preload(=
).
> Memory allocation by xb_set_bit() will after all emit warnings. Maybe
>=20
>   xb_init(&vb->page_xb);
>   vb->page_xb.gfp_mask |=3D __GFP_NOWARN;
>=20
> is tolerable? Or, unconditionally apply __GFP_NOWARN at xb_init()?
>=20



Please have a check this one: radix_tree_node_alloc()

In our case, I think the code path goes to=20

if (!gfpflags_allow_blocking(gfp_mask) && !in_interrupt()) {
...
ret =3D kmem_cache_alloc(radix_tree_node_cachep,
                                       gfp_mask | __GFP_NOWARN);
...
goto out;
}

So I think the __GFP_NOWARN is already there.



>   static inline void xb_init(struct xb *xb)
>   {
>           INIT_RADIX_TREE(&xb->xbrt, IDR_RT_MARKER | GFP_NOWAIT);
>   }
>=20
> > +	} while (unlikely(ret =3D=3D -EAGAIN));
> > +
> > +	return ret;
> > +}
> > +
>=20
>=20
>=20
> > @@ -172,11 +283,18 @@ static unsigned fill_balloon(struct virtio_balloo=
n
> *vb, size_t num)
> >  	vb->num_pfns =3D 0;
> >
> >  	while ((page =3D balloon_page_pop(&pages))) {
> > +		if (use_sg) {
> > +			if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0) {
> > +				__free_page(page);
> > +				break;
>=20
> You cannot "break;" without consuming all pages in "pages".


Right, I think it should be "continue" here. Thanks.=20

>=20
> > +			}
> > +		} else {
> > +			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> > +		}
> > +
> >  		balloon_page_enqueue(&vb->vb_dev_info, page);
> >
> >  		vb->num_pfns +=3D VIRTIO_BALLOON_PAGES_PER_PAGE;
> > -
> > -		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> >  		vb->num_pages +=3D VIRTIO_BALLOON_PAGES_PER_PAGE;
> >  		if (!virtio_has_feature(vb->vdev,
> >
> 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
>=20
>=20
>=20
> > @@ -212,9 +334,12 @@ static unsigned leak_balloon(struct virtio_balloon
> *vb, size_t num)
> >  	struct page *page;
> >  	struct balloon_dev_info *vb_dev_info =3D &vb->vb_dev_info;
> >  	LIST_HEAD(pages);
> > +	bool use_sg =3D virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
>=20
> You can pass use_sg as an argument to leak_balloon(). Then, you won't nee=
d
> to define leak_balloon_sg_oom(). Since xbitmap allocation does not use
> __GFP_DIRECT_RECLAIM, it is safe to reuse leak_balloon() for OOM path.
> Just be sure to pass use_sg =3D=3D false because memory allocation for us=
e_sg =3D=3D
> true likely fails when called from OOM path. (But trying use_sg =3D=3D tr=
ue for
> OOM path and then fallback to use_sg =3D=3D false is not bad?)
>=20


But once the SG mechanism is in use, we cannot use the non-SG mechanism, be=
cause the interface between the guest and host is not the same for SG and n=
on-SG. Methods to make the host support both mechanisms at the same time wo=
uld complicate the interface and implementation.=20

I also think the old non-SG mechanism should be deprecated to use since its=
 implementation isn't perfect in some sense, e.g. it balloons pages using o=
utbuf which implies that no changes are allowed to the balloon pages and th=
is isn't true for ballooning. The new mechanism (SG) has changed it to use =
inbuf.

So I think using leak_balloon_sg_oom() would be better. Is there any reason=
 that we couldn't use it?

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
