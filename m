Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20F39C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:02:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBBAA2175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:02:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBBAA2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53F538E0043; Thu,  7 Feb 2019 11:02:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EEFD8E0002; Thu,  7 Feb 2019 11:02:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E07E8E0043; Thu,  7 Feb 2019 11:02:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1445A8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:02:48 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id x125so256297qka.17
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:02:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=y+n8kFPfWw/N8uRt1dDpNNMomMdTM5ckddxJelyyTNo=;
        b=CuZC3EoX9Zy/mI3XzuYxnAcmfXFvGK4VTPB6AhCil+zwgD1X1pZ+CePO8/8ospx14P
         o2WHtRyuO6JtJNXRckVgzeZ9be+6w2xdcPGhEL3mhrPhKii9AemlL5zndMPjeS6L39PS
         VsnnBQ2HOkC9JgNkzBQRehnxJ8p0hoC6VAvUUgKApi92lDYKhiknbF++rzuvr4eqVklN
         Rg5S/G6YnokXhUbD/G+lFLVd+gzNFr/8A/3jTYvX2kARj8tyR5aWBK2KD6LhlmsG6eUJ
         7Ck9CcOKQf5PHXcYfZcUeu9FwnsPcbLj/EVJr1L4aKW43lGGde7eoJq6q3le+XFLmV/m
         vApA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZeM043YxKtXgt+ixX534p4d4KiGVnz0HysktZRY4ON9t+DLXeK
	kJvQqhrL+nZrNS1/w/7XWvNCvAN69/dJuVlWSyfbRqCHFsPDY0Ys9P+zUu7LOaDT4y3i1LTrQAO
	qVpSm3PM6P7v1dwjEyHBlcoWMggJimi8Cqyb79btcoEKcsLctsEMqfujgDFQqxU0tag==
X-Received: by 2002:a37:74a:: with SMTP id 71mr2530059qkh.47.1549555367797;
        Thu, 07 Feb 2019 08:02:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbUkj5J4secfZ7nnpvY5p52oobuGNKhEkooiZ5Pt4+ZUPFi5hDmXAkTs0mWSpsHYHnG6RMT
X-Received: by 2002:a37:74a:: with SMTP id 71mr2529996qkh.47.1549555366914;
        Thu, 07 Feb 2019 08:02:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549555366; cv=none;
        d=google.com; s=arc-20160816;
        b=RcWQTdEGq0IyXBOv3060ROd5vdOCaZF2VL66VlU6MKx1qJBV5hDB6s0uqiNt4N3Cqk
         J9o7htfMy3/wbIZnTYCvj/Bx2P5KivayeoIT160ITMA+xttnLe2cO6TLKhzQzOsa2pRi
         WtMSr7Vd3ozaiskrP+WG46HZt2oYVPwgvjP4/U2WmEwjfKCnSboqqxZUgUZyAg788yOq
         AkBTYuEbHlbFPNAjfMt8VR+1aS3y4w6wi3lufTK2u9RgR24pWSmygYghZxTYxs24pIsO
         zQFwvudl9Kbliq4aD7hoYAc5fq6SgZZYyjFWgb64n6aA9zorvY+MYjGn4JmCcwFB4zvj
         DisQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=y+n8kFPfWw/N8uRt1dDpNNMomMdTM5ckddxJelyyTNo=;
        b=GsGm233BI+o47eHl2kiWjxuYiLe3pyDm1KmxqpPZxGclf7AEpiWlavFX/Bp5NsEC4c
         X7+kEzctOKDNXuCO5q+ljGUMxWL0cTGE7qVFWdj76EQwRbFBSjUvN8AuBenRgtfvj5ea
         G7mfofcVZvmjBSfsK0PKIg90KujG0ZTkjSwkFKCCxdumBSINkBJuJjs0nTvqVRo99LJ3
         7sB1VYaiXci/WpeLkGNeTyJJnwtSnmev7oRcZ5cLidzWFP8gelqJA9aKUDHr12SLhj6B
         7l0XyN7QjSjWK01xr0PM3yeqNRMHmc3SZJuvJmzl8iukG6aqPxQz1TrVtJ2xE76gu2Az
         l/MA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i15si2028502qkg.87.2019.02.07.08.02.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 08:02:46 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B85CC89AD0;
	Thu,  7 Feb 2019 16:02:45 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3266C972EF;
	Thu,  7 Feb 2019 15:56:38 +0000 (UTC)
Message-ID: <68c1e70d768922f6b1b4b833c433aff12a87336a.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
From: Doug Ledford <dledford@redhat.com>
To: Tom Talpey <tom@talpey.com>, Chuck Lever <chuck.lever@oracle.com>, Jason
	Gunthorpe <jgg@ziepe.ca>
Cc: Dave Chinner <david@fromorbit.com>, Christopher Lameter <cl@linux.com>, 
 Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Ira Weiny
 <ira.weiny@intel.com>,  lsf-pc@lists.linux-foundation.org, linux-rdma
 <linux-rdma@vger.kernel.org>,  linux-mm@kvack.org, Linux Kernel Mailing
 List <linux-kernel@vger.kernel.org>,  John Hubbard <jhubbard@nvidia.com>,
 Jerome Glisse <jglisse@redhat.com>, Dan Williams
 <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>
Date: Thu, 07 Feb 2019 10:56:35 -0500
In-Reply-To: <ea175620-3dc2-c7f0-1590-02080216edf8@talpey.com>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
	 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
	 <20190206175233.GN21860@bombadil.infradead.org>
	 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
	 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
	 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
	 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
	 <20190207035258.GD6173@dastard> <20190207052310.GA22726@ziepe.ca>
	 <CC414509-F046-49E3-9D0C-F66FD488AC64@oracle.com>
	 <6b260348-966a-bc95-162b-44ae8265cf03@talpey.com>
	 <f000f699219a8f636dccfbe1fde3e17acdc674a4.camel@redhat.com>
	 <ea175620-3dc2-c7f0-1590-02080216edf8@talpey.com>
Organization: Red Hat, Inc.
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-G+f9gGSQ2dAX1z2qQpRX"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 07 Feb 2019 16:02:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-G+f9gGSQ2dAX1z2qQpRX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2019-02-07 at 10:41 -0500, Tom Talpey wrote:
> On 2/7/2019 10:37 AM, Doug Ledford wrote:
> > On Thu, 2019-02-07 at 10:28 -0500, Tom Talpey wrote:
> > > On 2/7/2019 10:04 AM, Chuck Lever wrote:
> > > > > On Feb 7, 2019, at 12:23 AM, Jason Gunthorpe <jgg@ziepe.ca> wrote=
:
> > > > >=20
> > > > > On Thu, Feb 07, 2019 at 02:52:58PM +1100, Dave Chinner wrote:
> > > > >=20
> > > > > > Requiring ODP capable hardware and applications that control RD=
MA
> > > > > > access to use file leases and be able to cancel/recall client s=
ide
> > > > > > delegations (like NFS is already able to do!) seems like a pret=
ty
> > > > >=20
> > > > > So, what happens on NFS if the revoke takes too long?
> > > >=20
> > > > NFS distinguishes between "recall" and "revoke". Dave used "recall"
> > > > here, it means that the server recalls the client's delegation. If
> > > > the client doesn't respond, the server revokes the delegation
> > > > unilaterally and other users are allowed to proceed.
> > >=20
> > > The SMB3 protocol has a similar "lease break" mechanism, btw.
> > >=20
> > > SMB3 "push mode" has long-expected to allow DAX mapping of files
> > > only when an exclusive lease is held by the requesting client.
> > > The server may recall the lease if the DAX mapping needs to change.
> > >=20
> > > Once local (MMU) and remote (RDMA) mappings are dropped, the
> > > client may re-request that the server reestablish them. No
> > > connection or process is terminated, and no data is silently lost.
> >=20
> > Yeah, but you're referring to a situation where the communication agent
> > and the filesystem agent are one and the same and they work
> > cooperatively to resolve the issue.  With DAX under Linux, the
> > filesystem agent and the communication agent are separate, and right
> > now, to my knowledge, the filesystem agent doesn't tell the
> > communication agent about a broken lease, it want's to be able to do
> > things 100% transparently without any work on the communication agent's
> > part.  That works for ODP, but not for anything else.  If the filesyste=
m
> > notified the communication agent of the need to drop the MMU region and
> > rebuild it, the communication agent could communicate that to the remot=
e
> > host, and things would work.  But there's no POSIX message for "your
> > file is moving on media, redo your mmap".
>=20
> Indeed, the MMU notifier and the filesystem need to be integrated.

And right now, the method of sharing this across the network is:

persistent memory in machine
  local filesystem supporting a DAX mount
    custom application that knows how to mmap then rdma map files,
    and can manage the connection long term

The point being that every single method of sharing this stuff is a one
off custom application (Oracle just being one).  I'm not really all that
thrilled about the idea of writing the same mmap/rdma map/oob-management=
=20
code in every single app out there.  To me, this problem is screaming
for a more general purpose kernel solution, just like NVMe over Fabrics.
I'm thinking a clustered filesystem on top of a shared memory segment
between hosts is a much more natural fit.  Then applications just mmap
the files locally, and the kernel does the rest.

> I'm unmoved by the POSIX argument. This stuff didn't happen in 1990.
>=20
> Tom.

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-G+f9gGSQ2dAX1z2qQpRX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxcVTMACgkQuCajMw5X
L90Z/w//W7vouBfKgeHWd7q/6pHaRFPVjV7bGkmFwaHGvrbnQU3Fnfcj8Ts8ShZW
T4p4pJKmARkSPJqqR/hvH+Ln3SJCVf49tdhCbu7VaYkYk3iZJmWfdvF/oItdH7//
g2iIbUEYujIF5ZsAEss93Ma3SXP8Bvre0Vq15GX8Zu7oogXtj6zypek+3t9kfbt9
pQl63VTylLbxu4jAJz0VoLz5VpSe2uzR/piuQZpMp/of9t62a8OIQVRU1rC8O/rm
20A9RkrHRNRbUNjC4EqMfv+4t6zVL4sC/QUCUx07rOYwWVLXgqYUv9GqzCkdl/fA
3wJFMohDOW8V9dDg9LroWki2xdCCm22JVtDoQK/pMNhIONDxu5JqHbuSNKs/BcXc
3MgPFSJueLey5j9u4VTGlLwhLSPPBdeUyPTx1MRuqaZInXDRJxDupajQ96MY7vfb
Ckw6SXV1U51eXohXgGnXQRgt7K4JRS8SA6Iky7UyukxCevIIfvF8zD3HPv6wfho+
IPwaUsbfH88HJzjwpnN4KV9RDB6irg4GfNsS1IGbuXOw+0lNGeG5zlfKlfY1y/Yr
YARFzuESMq1ky2CRDntL7fbso2AWEhrrsvic1SycYvNTElztvwbXRQs1rDyvdaKZ
DsU00Sq9PuwzmEosfsm18bYkKHD2SMPEtPR+7k2obc3RRPTjWxc=
=LiqC
-----END PGP SIGNATURE-----

--=-G+f9gGSQ2dAX1z2qQpRX--

