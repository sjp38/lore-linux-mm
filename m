Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8246B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 08:39:36 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p5so14646493pgn.7
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 05:39:36 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id l6si2765465plt.250.2017.10.02.05.39.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 05:39:35 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v16 3/5] virtio-balloon: VIRTIO_BALLOON_F_SG
Date: Mon, 2 Oct 2017 12:39:30 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73931FDB5@shsmsx102.ccr.corp.intel.com>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
 <1506744354-20979-4-git-send-email-wei.w.wang@intel.com>
 <20171002072106-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171002072106-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Michael S. Tsirkin'" <mst@redhat.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "willy@infradead.org" <willy@infradead.org>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Monday, October 2, 2017 12:30 PM, Michael S. Tsirkin wrote:
> On Sat, Sep 30, 2017 at 12:05:52PM +0800, Wei Wang wrote:
> > +static int send_balloon_page_sg(struct virtio_balloon *vb,
> > +				 struct virtqueue *vq,
> > +				 void *addr,
> > +				 uint32_t size,
> > +				 bool batch)
> > +{
> > +	int err;
> > +
> > +	err =3D add_one_sg(vq, addr, size);
> > +
> > +	/* If batchng is requested, we batch till the vq is full */
>=20
> typo
>=20
> > +	if (!batch || !vq->num_free)
> > +		kick_and_wait(vq, vb->acked);
> > +
> > +	return err;
> > +}
>=20
> If add_one_sg fails, kick_and_wait will hang forever.
>=20
> The reason this might work in because
> 1. with 1 sg there are no memory allocations 2. if adding fails on vq ful=
l, then
> something
>    is in queue and will wake up kick_and_wait.
>=20
> So in short this is expected to never fail.
> How about a BUG_ON here then?
> And make it void, and add a comment with above explanation.
>=20


Yes, agree that this wouldn't fail - the worker thread performing the ballo=
oning operations has been put into sleep when the vq is full, so I think th=
ere shouldn't be anyone else to put more sgs onto the vq then.
Btw, not sure if we need to mention memory allocation in the comment, I fou=
nd virtqueue_add() doesn't return any error when allocation (for indirect d=
esc-s) fails - it simply avoids the use of indirect desc.

What do you think of the following?=20

err =3D add_one_sg(vq, addr, size);
/*=20
  * This is expected to never fail: there is always at least 1 entry availa=
ble on the vq,
  * because when the vq is full the worker thread that adds the sg will be =
put into
  * sleep until at least 1 entry is available to use.
  */
BUG_ON(err);

Best,
Wei



=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
