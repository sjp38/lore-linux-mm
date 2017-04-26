Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 473756B0038
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 00:47:21 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id h72so248342880iod.0
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 21:47:21 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id 89si2117594ior.64.2017.04.25.21.47.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 21:47:20 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/2] mm: Uncharge poisoned pages
Date: Wed, 26 Apr 2017 04:46:09 +0000
Message-ID: <20170426044608.GA32451@hori1.linux.bs1.fc.nec.co.jp>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493171698.4828.1.camel@gmail.com>
 <20170426023410.GA11619@hori1.linux.bs1.fc.nec.co.jp>
 <1493178300.4828.5.camel@gmail.com>
In-Reply-To: <1493178300.4828.5.camel@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B75C875EEA53464D864911466F69A183@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, Apr 26, 2017 at 01:45:00PM +1000, Balbir Singh wrote:
> > > >  static int delete_from_lru_cache(struct page *p)
> > > >  {
> > > > +	if (memcg_kmem_enabled())
> > > > +		memcg_kmem_uncharge(p, 0);
> > > > +
> > >=20
> > > The changelog is not quite clear, so we are uncharging a page using
> > > memcg_kmem_uncharge for a page in swap cache/page cache?
> >=20
> > Hi Balbir,
> >=20
> > Yes, in the normal page lifecycle, uncharge is done in page free time.
> > But in memory error handling case, in-use pages (i.e. swap cache and pa=
ge
> > cache) are removed from normal path and they don't pass page freeing co=
de.
> > So I think that this change is to keep the consistent charging for such=
 a case.
>=20
> I agree we should uncharge, but looking at the API name, it seems to
> be for kmem pages, why are we not using mem_cgroup_uncharge()? Am I missi=
ng
> something?

Thank you for pointing out.
Actually I had the same question and this surely looks strange.
But simply calling mem_cgroup_uncharge() here doesn't work because it
assumes that page_refcount(p) =3D=3D 0, which is not true in hwpoison conte=
xt.
We need some other clearer way or at least some justifying comment about
why this is ok.

- Naoya=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
