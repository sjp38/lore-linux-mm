Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05357C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:50:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEEF2218D9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:50:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEEF2218D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5425C8E00FC; Wed,  6 Feb 2019 15:50:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F1638E00CE; Wed,  6 Feb 2019 15:50:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4094D8E00FC; Wed,  6 Feb 2019 15:50:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 13A8D8E00CE
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:50:47 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id b6so7625196qkg.4
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:50:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=OAeI+sH++9bha5Pki9gskVbEXdziLK/+k2M831yB/WM=;
        b=Ttd9FyRiHU91bTkbZ3F8lDI/ujQY33e7bT6JbThKIGmadABmvLz+z8NbflSmjhptsh
         fymkap67ggvGymmVTR7CYZaYZRAZ9ZlxW68XSTM/iS8xNWEyzvM/6e3VoQo45kS44rNX
         d9jG2xxjx+fzOyFJF6htjHqg3k+z9XQ2kN3bZQq9zByHMiiTVfHfylVDDFE1yN8lPFLA
         KI8b8N+lDch3RGgFgDpqP1t+OymKwtKpju6dKps+SymHk6kk/uKGbQI8ids0on1cc0nn
         qgvAaDc0L7OinOYfMC8nlLF+iLNlwOITAMk5E6jUnDJLVoMpp9uWd+p5/jMTl6A3RBAq
         Pt6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZH2xopOuTioCaOHn20UI55+XbWwZCLx16PGuCkgGJQDGYbYL8m
	QiIwA4GUHE2EDAT/XOkR9dUwivqcsM3ufDw/8ogqhzRFbQXr9GelFo09shPFZo9lwtXpJi7F26V
	F1EyeSC6AnKSD2Jiro++y15GJ5E9kA/3qrPGIcoNXHjfMkr2KrdwVCmuZY9g9ei1P1w==
X-Received: by 2002:a0c:9d41:: with SMTP id n1mr9390978qvf.212.1549486246832;
        Wed, 06 Feb 2019 12:50:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYtje/A+YYDomRw8C4zOmoimZrbyPaASvct7/MrOdqPSrqa2WEElSmf5lLDc9aJugFjM2o0
X-Received: by 2002:a0c:9d41:: with SMTP id n1mr9390941qvf.212.1549486246172;
        Wed, 06 Feb 2019 12:50:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549486246; cv=none;
        d=google.com; s=arc-20160816;
        b=tuDD/uQ8fQDdjTmxdFx28Z0oUORLRiJYLUsG5DUY4YjW+A1tIGswZBEL3/XSL2rEwM
         A8jI4V69EAa+/hoTuC7hx6lurWHcpWBiG+SUYS87v2bDzu56Drf03Ljd7Z4EbvJfYUjV
         dNh8A5FAz3XgKHlHiUNa8LIurfE0J+cicLTmWDwdeoMhgr/P8rdkZO7C+DW5EJ5voOBp
         lXfrzR+68gloWgQH1NNSO86hNCQxFC4HkGQWzDtDIqEVV+etzEn6aZpwFubti9hLvWO3
         E9vs9HOIm+PMWU3GHKs3+Oeim+L3WHjaycocvrNFRdfJKyXK8FvBRfJ7PN/qxEDR74Bo
         sWWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=OAeI+sH++9bha5Pki9gskVbEXdziLK/+k2M831yB/WM=;
        b=C7zHIke452s71e6XSkHseXyUVFfIlLlGrTgZOn267xGcouEKJfbdOB0+nmSFvi+xEn
         FXvv+z4Z1vLfqWjOLKMI8OA+RQFosiPbbLJmlqVvlml25HVK7eRY/8M9TngsXvLfdgBo
         A4cQl1+taWSkK08qeOssOf/idBVPEBXgN4i6BYPPXnVtJzGTSN7e15jWOTNX0ergu76n
         O+oN9AjEO2T0yLoCy84aTlXPraBZ4PHgXt2yAmTxAGPSgf1axWt2syI+9/pSZe/u1IZH
         wGHvLYRvv83m/cvZkHEsUC/CN14gYKSUT2z8IA4MKTpHpRPjGAQWezB6iz4RPuGSnDn7
         2oww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h1si2871010qkj.187.2019.02.06.12.50.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 12:50:46 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 152B6144040;
	Wed,  6 Feb 2019 20:50:45 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7A5AC1C94A;
	Wed,  6 Feb 2019 20:50:42 +0000 (UTC)
Message-ID: <f84dfa9d5e34ce76b5f599086f5fbaa12f7903bf.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
From: Doug Ledford <dledford@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Jan
 Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>,
 lsf-pc@lists.linux-foundation.org,  linux-rdma@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,  John Hubbard
 <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, Dan Williams
 <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Michal
 Hocko <mhocko@kernel.org>
Date: Wed, 06 Feb 2019 15:50:39 -0500
In-Reply-To: <20190206204954.GS21860@bombadil.infradead.org>
References: <20190206173114.GB12227@ziepe.ca>
	 <20190206175233.GN21860@bombadil.infradead.org>
	 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
	 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
	 <20190206194055.GP21860@bombadil.infradead.org>
	 <a9df9be75966f34f55f843a3cd7e1ee7d497c7fa.camel@redhat.com>
	 <20190206202021.GQ21860@bombadil.infradead.org>
	 <a8dc27e81182060b3480127332c77ac624abcb22.camel@redhat.com>
	 <20190206204128.GR21860@bombadil.infradead.org>
	 <fbdeccb01f7d0ba2f6ebb69660b7aa3d99690042.camel@redhat.com>
	 <20190206204954.GS21860@bombadil.infradead.org>
Organization: Red Hat, Inc.
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-npO7kZeSLN7JvETiEniW"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 06 Feb 2019 20:50:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-npO7kZeSLN7JvETiEniW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-02-06 at 12:49 -0800, Matthew Wilcox wrote:
> On Wed, Feb 06, 2019 at 03:47:53PM -0500, Doug Ledford wrote:
> > On Wed, 2019-02-06 at 12:41 -0800, Matthew Wilcox wrote:
> > > On Wed, Feb 06, 2019 at 03:28:35PM -0500, Doug Ledford wrote:
> > > > On Wed, 2019-02-06 at 12:20 -0800, Matthew Wilcox wrote:
> > > > > Not hot-unplugging the RDMA device but hot-unplugging an NV-DIMM.
>=20
> ^^^ I think you missed this line ^^^

Indeed, I did ;-)

>=20
> > You said "now that I think about it, there was a desire to support hot-
> > unplug which also needed revoke".  For us, hot unplug is done at the
> > device level and means all connections must be torn down.  So in the
> > context of this argument, if people want revoke so DAX can migrate from
> > one NV-DIMM to another, ok.  But revoke does not help RDMA migrate.
> >=20
> > If, instead, you mean that you want to support hot unplug of an NV-DIMM
> > that is currently the target of RDMA transfers, then I believe
> > Christoph's answer on this is correct.  It all boils down to which
> > device you are talking about doing the hot unplug on.

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-npO7kZeSLN7JvETiEniW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxbSJ8ACgkQuCajMw5X
L91Y+hAAusyH3LPRH/wvWQK4kvGUWublDXN9K/Udjlf1z1agPHTyDxMEP4lqYbkz
+dlHYgggahnY4m/J8N1ctQ/wVqdxnT/aO/iKuAmZszWwPDNl6D6cksEXnW4Gsdh/
AGp+06hK1ZtigzRLXajHbcLZqgWTfCE8Y00PhiUe26M8BTx2dNM3pHvH0aQtkcnK
I6k4ZBMu4t0zojN3flit89NuRnfE+1b0dnH+9XqzLlCKRmfN9ZnJtvBLu3vKyd1d
wK2nms1N8Zsn7hrI0d7L8hDFZudfd7tcsdGLEKr48I6JcOnfppzr7fNl8hCT62xn
xkE/HXyz1K8TQrKn8plAzGFFVANCy7VqQPD+xN49G7dg7+go9srl7OO0o5JxPdY2
xQlRSa03pP4/Qt2NS7+Ar0FUi9UAISSmcAc+A5hZAdEIICj9sjSavSotCx2jTFcB
zHml+SejW2r5CEfPrDNzoeBe1m4H4nS113bSujtgjrVkW2uN3GrXLFwAaD0dKJSN
YNXmbNxGUCcXPfWnL/AK27DXnmLhC48wRpk1YhHjuNpJ/kgwPVtO37QDqPK7wjpY
1tJigUxaFXfvfryOtTnvoPcZM5Icyo60ocREqJP4Y62xTbL2rLQvL7Qm1oZlO5jN
ZIxjvEVS25lqOehKH6ldv0KP0Zqrv1CwQ7Q6FDDeSaeEcRrVyzg=
=EurJ
-----END PGP SIGNATURE-----

--=-npO7kZeSLN7JvETiEniW--

