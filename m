Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 712718E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 16:58:01 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so3293068edm.18
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 13:58:01 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id s1-v6si2124296ejs.111.2018.12.14.13.57.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 13:57:59 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC 2/4] mm: separate memory allocation and actual work in
 alloc_vmap_area()
Date: Fri, 14 Dec 2018 21:57:19 +0000
Message-ID: <20181214215713.GA27488@tower.DHCP.thefacebook.com>
References: <20181214180720.32040-1-guro@fb.com>
 <20181214180720.32040-3-guro@fb.com>
 <20181214181322.GC10600@bombadil.infradead.org>
 <0192c1984f42ad0a33e4c9aca04df90c97ebf412.camel@perches.com>
 <20181214194500.GF10600@bombadil.infradead.org>
In-Reply-To: <20181214194500.GF10600@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B16C1316E2CD244C86578D5E121C40FD@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Joe Perches <joe@perches.com>, Roman Gushchin <guroan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexey Dobriyan <adobriyan@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>

On Fri, Dec 14, 2018 at 11:45:00AM -0800, Matthew Wilcox wrote:
> On Fri, Dec 14, 2018 at 11:40:45AM -0800, Joe Perches wrote:
> > On Fri, 2018-12-14 at 10:13 -0800, Matthew Wilcox wrote:
> > > On Fri, Dec 14, 2018 at 10:07:18AM -0800, Roman Gushchin wrote:
> > > > +/*
> > > > + * Allocate a region of KVA of the specified size and alignment, w=
ithin the
> > > > + * vstart and vend.
> > > > + */
> > > > +static struct vmap_area *alloc_vmap_area(unsigned long size,
> > > > +					 unsigned long align,
> > > > +					 unsigned long vstart,
> > > > +					 unsigned long vend,
> > > > +					 int node, gfp_t gfp_mask)
> > > > +{
> > > > +	struct vmap_area *va;
> > > > +	int ret;
> > > > +
> > > > +	va =3D kmalloc_node(sizeof(struct vmap_area),
> > > > +			gfp_mask & GFP_RECLAIM_MASK, node);
> > > > +	if (unlikely(!va))
> > > > +		return ERR_PTR(-ENOMEM);
> > > > +
> > > > +	ret =3D init_vmap_area(va, size, align, vstart, vend, node, gfp_m=
ask);
> > > > +	if (ret) {
> > > > +		kfree(va);
> > > > +		return ERR_PTR(ret);
> > > > +	}
> > > > +
> > > > +	return va;
> > > >  }
> > > > =20
> > > > +
> > >=20
> > > Another spurious blank line?
> >=20
> > I don't think so.
> >=20
> > I think it is the better style to separate
> > the error return from the normal return.
>=20
> Umm ... this blank line changed the file from having one blank line
> after the function to having two blank lines after the function.
>=20

Yes, it's an odd free line (here and above), will remove them in v2.
Thanks!
