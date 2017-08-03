Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 134CC6B06D1
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 11:18:07 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j83so15761043pfe.10
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 08:18:07 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q71si15011137pfl.438.2017.08.03.08.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 08:18:05 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v13 3/5] virtio-balloon: VIRTIO_BALLOON_F_SG
Date: Thu, 3 Aug 2017 15:17:59 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73928C952@shsmsx102.ccr.corp.intel.com>
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
 <1501742299-4369-4-git-send-email-wei.w.wang@intel.com>
 <20170803151212-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170803151212-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Thursday, August 3, 2017 10:23 PM, Michael S. Tsirkin wrote:
> On Thu, Aug 03, 2017 at 02:38:17PM +0800, Wei Wang wrote:
> > +static void send_one_sg(struct virtio_balloon *vb, struct virtqueue *v=
q,
> > +			void *addr, uint32_t size)
> > +{
> > +	struct scatterlist sg;
> > +	unsigned int len;
> > +
> > +	sg_init_one(&sg, addr, size);
> > +	while (unlikely(virtqueue_add_inbuf(vq, &sg, 1, vb, GFP_KERNEL)
> > +			=3D=3D -ENOSPC)) {
> > +		/*
> > +		 * It is uncommon to see the vq is full, because the sg is sent
> > +		 * one by one and the device is able to handle it in time. But
> > +		 * if that happens, we kick and wait for an entry is released.
>=20
> is released -> to get used.
>=20
> > +		 */
> > +		virtqueue_kick(vq);
> > +		while (!virtqueue_get_buf(vq, &len) &&
> > +		       !virtqueue_is_broken(vq))
> > +			cpu_relax();
>=20
> Please rework to use wait_event in that case too.

For the balloon page case here, it is fine to use wait_event. But for the f=
ree page
case, I think it might not be suitable because the mm lock is being held.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
