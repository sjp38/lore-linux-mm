Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E83AA6B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 06:50:08 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id n4so3475686plp.23
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 03:50:08 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 66si1999074plc.230.2017.12.17.03.50.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Dec 2017 03:50:07 -0800 (PST)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v19 3/7] xbitmap: add more operations
Date: Sun, 17 Dec 2017 11:50:03 +0000
Message-ID: <286AC319A985734F985F78AFA26841F739387B68@shsmsx102.ccr.corp.intel.com>
References: <1513079759-14169-4-git-send-email-wei.w.wang@intel.com>
	<20171215184256.GA27160@bombadil.infradead.org>	<5A34F193.5040700@intel.com>
	<201712162028.FEB87079.FOJFMQHVOSLtFO@I-love.SAKURA.ne.jp>
	<5A35FF89.8040500@intel.com>
 <201712171921.IBB30790.VOOOFMQHFSLFJt@I-love.SAKURA.ne.jp>
In-Reply-To: <201712171921.IBB30790.VOOOFMQHFSLFJt@I-love.SAKURA.ne.jp>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "willy@infradead.org" <willy@infradead.org>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>



> -----Original Message-----
> From: Tetsuo Handa [mailto:penguin-kernel@I-love.SAKURA.ne.jp]
> Sent: Sunday, December 17, 2017 6:22 PM
> To: Wang, Wei W <wei.w.wang@intel.com>; willy@infradead.org
> Cc: virtio-dev@lists.oasis-open.org; linux-kernel@vger.kernel.org; qemu-
> devel@nongnu.org; virtualization@lists.linux-foundation.org;
> kvm@vger.kernel.org; linux-mm@kvack.org; mst@redhat.com;
> mhocko@kernel.org; akpm@linux-foundation.org; mawilcox@microsoft.com;
> david@redhat.com; cornelia.huck@de.ibm.com;
> mgorman@techsingularity.net; aarcange@redhat.com;
> amit.shah@redhat.com; pbonzini@redhat.com;
> liliang.opensource@gmail.com; yang.zhang.wz@gmail.com;
> quan.xu@aliyun.com; nilal@redhat.com; riel@redhat.com
> Subject: Re: [PATCH v19 3/7] xbitmap: add more operations
>=20
> Wei Wang wrote:
> > > But passing GFP_NOWAIT means that we can handle allocation failure.
> > > There is no need to use preload approach when we can handle allocatio=
n
> failure.
> >
> > I think the reason we need xb_preload is because radix tree insertion
> > needs the memory being preallocated already (it couldn't suffer from
> > memory failure during the process of inserting, probably because
> > handling the failure there isn't easy, Matthew may know the backstory
> > of
> > this)
>=20
> According to https://lwn.net/Articles/175432/ , I think that preloading i=
s
> needed only when failure to insert an item into a radix tree is a signifi=
cant
> problem.
> That is, when failure to insert an item into a radix tree is not a proble=
m, I
> think that we don't need to use preloading.

It also mentions that the preload attempts to allocate sufficient memory to=
 *guarantee* that the next radix tree insertion cannot fail.

If we check radix_tree_node_alloc(), the comments there says "this assumes =
that the caller has performed appropriate preallocation".

So, I think we would get a risk of triggering some issue without preload().

> >
> > So, I think we can handle the memory failure with xb_preload, which
> > stops going into the radix tree APIs, but shouldn't call radix tree
> > APIs without the related memory preallocated.
>=20
> It seems to me that virtio-ballon case has no problem without using
> preloading.

Why is that?

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
