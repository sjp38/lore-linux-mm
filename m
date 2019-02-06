Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43155C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 22:24:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF9DF218B0
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 22:24:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF9DF218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F4F88E0105; Wed,  6 Feb 2019 17:24:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A4648E0103; Wed,  6 Feb 2019 17:24:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B9DA8E0105; Wed,  6 Feb 2019 17:24:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 505778E0103
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 17:24:57 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q11so8446966qtp.3
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 14:24:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=+UxwOAFhyeC7JDfdcboibx68s8FBpavn7zpZRblDih4=;
        b=CAOsT3S35pbu/tbYTNmsRYuVv8lEiqaX219A7pTgQlocExLjgSRjpzmJ3Tiyz6jZ3f
         y8Vrv/enPdi3xd+4KNw7qXr2SjrMII/k1b50orh3tTqn1K+ESquo0d/p1Zhs9qyocUGc
         2Rqkr39Lf+u8phx9RE3IKvulHt+QKnq255PcXKmwGsRmzLsN1jvvOrPUEpEB3RMHahs3
         kRJyJmIqXnkX5GnsTwlUG5o432TaEmSozc3GBJlUSJ1yPNQg6Opewbi8js3R8HgZOSex
         zdSrwJwao8QG0JoN+ukMa1/ukArooqGasQM2tz5jKJABVbRB5Vk6gTFDRXyu4oYn5Kin
         mIdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZ98fkoJCavk30Wdh2BqUljAW676aYqAW53hDuavrmNvOGuWutU
	0/FXNR+K1GHohHnxS+SXIIVig0doKh5CUXFquzwfsKZ3PDzI1knHpiLdfVjYUv/A7GNmq9xAoV4
	hEd4j+HGtTZ52acrB6MAKt+u5Zn6n+76wIjj5wv+3KpIkJZ2LDotvj11jfar0BAMx0w==
X-Received: by 2002:a05:6214:1042:: with SMTP id l2mr3364551qvr.159.1549491896999;
        Wed, 06 Feb 2019 14:24:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZR8fm98kUOOb7mW2PGluI0JJc+WwInPDUwX9uxw4XE3G0+vuZJ9voTFA24SFbOa78lyeov
X-Received: by 2002:a05:6214:1042:: with SMTP id l2mr3364532qvr.159.1549491896587;
        Wed, 06 Feb 2019 14:24:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549491896; cv=none;
        d=google.com; s=arc-20160816;
        b=xKMgPlAzUoPOSyV46sc/4/Nh/2TSRDqpUJZcq2h5eYnablsrJT0a4zAAAuzvhN6Or7
         YrurPlKTIWJ8L5cVTHfiLMi6fy+rrGX29h/pAySirI/oqaMwqAINVtv4Dpua8kqEPEaP
         Zqk16EwGIJKHEsADyf6nIYsns8ylDINCNShll/WGbWpk9YSMj6t9cU0qBE0cCGOdVXZ+
         s2op9oAlbvjOXCoyoup4LgW3yIvJJp6SEU+Do5GzHGEJWUNkjnyjdFkbJvfYxXZUuEz7
         3S58X8BcSan4pR9Zqtto5azy1lCr2Nt5nLn2vIWOWYUb2wJycvvaldByxt3jgQv/Pxi+
         iwWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=+UxwOAFhyeC7JDfdcboibx68s8FBpavn7zpZRblDih4=;
        b=ZJoxZxkwO2GIBPcjkxrgtsGbOSc4QTSH+BF4JTdD9w8WtfFNQ5juLWBS/c4MKm5Q5o
         E7AE4p94b3P+L+0O2H+FLuElE0Spk4rx2eNA/fVBkGesTiqvokgEbN/5vIL7OxWoH7Kb
         lkvyeICFewb924QsBZ6tHbd3Xy4DU6tHPn0xLvO5FDjZrug+vGYjBjqU94Jm72PHWjZq
         814hZA466kfyVubfRfZWpQR28mhFSF0CMUmbV8QCVrjk88mA182Y2V1xq39X0SnCA0O/
         WN67V8xucHDrUVi3ahIAjapyjYbXkZNGy8iEQCtjrLGJ3CDamrN+IJNDayhpTaa6iD4Y
         bPfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j62si6703464qtb.139.2019.02.06.14.24.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 14:24:56 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1F58B2CD814;
	Wed,  6 Feb 2019 22:24:55 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8A39162FA3;
	Wed,  6 Feb 2019 22:24:52 +0000 (UTC)
Message-ID: <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
From: Doug Ledford <dledford@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>, Dave Chinner <david@fromorbit.com>
Cc: Christopher Lameter <cl@linux.com>, Matthew Wilcox
 <willy@infradead.org>,  Jan Kara <jack@suse.cz>, Ira Weiny
 <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
 linux-rdma@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  John Hubbard <jhubbard@nvidia.com>, Jerome
 Glisse <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>,
 Michal Hocko <mhocko@kernel.org>
Date: Wed, 06 Feb 2019 17:24:50 -0500
In-Reply-To: <20190206220828.GJ12227@ziepe.ca>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
	 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
	 <20190206175233.GN21860@bombadil.infradead.org>
	 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
	 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
	 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
Organization: Red Hat, Inc.
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-5bjhfkCd3CuoQXipvuOM"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 06 Feb 2019 22:24:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-5bjhfkCd3CuoQXipvuOM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-02-06 at 15:08 -0700, Jason Gunthorpe wrote:
> On Thu, Feb 07, 2019 at 08:03:56AM +1100, Dave Chinner wrote:
> > On Wed, Feb 06, 2019 at 07:16:21PM +0000, Christopher Lameter wrote:
> > > On Wed, 6 Feb 2019, Doug Ledford wrote:
> > >=20
> > > > > Most of the cases we want revoke for are things like truncate().
> > > > > Shouldn't happen with a sane system, but we're trying to avoid us=
ers
> > > > > doing awful things like being able to DMA to pages that are now p=
art of
> > > > > a different file.
> > > >=20
> > > > Why is the solution revoke then?  Is there something besides trunca=
te
> > > > that we have to worry about?  I ask because EBUSY is not currently
> > > > listed as a return value of truncate, so extending the API to inclu=
de
> > > > EBUSY to mean "this file has pinned pages that can not be freed" is=
 not
> > > > (or should not be) totally out of the question.
> > > >=20
> > > > Admittedly, I'm coming in late to this conversation, but did I miss=
 the
> > > > portion where that alternative was ruled out?
> > >=20
> > > Coming in late here too but isnt the only DAX case that we are concer=
ned
> > > about where there was an mmap with the O_DAX option to do direct writ=
e
> > > though? If we only allow this use case then we may not have to worry =
about
> > > long term GUP because DAX mapped files will stay in the physical loca=
tion
> > > regardless.
> >=20
> > No, that is not guaranteed. Soon as we have reflink support on XFS,
> > writes will physically move the data to a new physical location.
> > This is non-negotiatiable, and cannot be blocked forever by a gup
> > pin.
> >=20
> > IOWs, DAX on RDMA requires a) page fault capable hardware so that
> > the filesystem can move data physically on write access, and b)
> > revokable file leases so that the filesystem can kick userspace out
> > of the way when it needs to.
>=20
> Why do we need both? You want to have leases for normal CPU mmaps too?
>=20
> > Truncate is a red herring. It's definitely a case for revokable
> > leases, but it's the rare case rather than the one we actually care
> > about. We really care about making copy-on-write capable filesystems li=
ke
> > XFS work with DAX (we've got people asking for it to be supported
> > yesterday!), and that means DAX+RDMA needs to work with storage that
> > can change physical location at any time.
>=20
> Then we must continue to ban longterm pin with DAX..
>=20
> Nobody is going to want to deploy a system where revoke can happen at
> any time and if you don't respond fast enough your system either locks
> with some kind of FS meltdown or your process gets SIGKILL.=20
>=20
> I don't really see a reason to invest so much design work into
> something that isn't production worthy.
>=20
> It *almost* made sense with ftruncate, because you could architect to
> avoid ftruncate.. But just any FS op might reallocate? Naw.
>=20
> Dave, you said the FS is responsible to arbitrate access to the
> physical pages..
>=20
> Is it possible to have a filesystem for DAX that is more suited to
> this environment? Ie designed to not require block reallocation (no
> COW, no reflinks, different approach to ftruncate, etc)

Can someone give me a real world scenario that someone is *actually*
asking for with this?  Are DAX users demanding xfs, or is it just the
filesystem of convenience?  Do they need to stick with xfs?  Are they
really trying to do COW backed mappings for the RDMA targets?  Or do
they want a COW backed FS but are perfectly happy if the specific RDMA
targets are *not* COW and are statically allocated?

> > And that's the real problem we need to solve here. RDMA has no trust
> > model other than "I'm userspace, I pinned you, trust me!". That's
> > not good enough for FS-DAX+RDMA....
>=20
> It is baked into the silicon, and I don't see much motion on this
> front right now. My best hope is that IOMMU PASID will get widely
> deployed and RDMA silicon will arrive that can use it. Seems to be
> years away, if at all.
>=20
> At least we have one chip design that can work in a page faulting mode
> ..
>=20
> Jason

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-5bjhfkCd3CuoQXipvuOM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxbXrIACgkQuCajMw5X
L92eWQ/+ODb+cP0wjR0XAf8kfnKl79sjmcte7mdkTwDXOgwrGQ2T1H0sOmNqJ+g/
uJqSNYB5eS1qO7UedYc38TsAGDVIdCWIyHvdNPv2pg6csnujSOJO1cB1DdA5Vsj2
aBDEEbrR0nd/7QNcjooKlmZXtto8VgvVkSmKEauZNSeMaW80koef5dVzzRmkkRyq
nq3Pe+PzB+Ohre4ShN6LRkWnor5lv/aQ73Hg2FAC47rwmJVNCg2SRVw8JSs3BW9E
pwNBttGC5i9T9PPAcH2vAOUaZ7FZXh1O5FhHpTEhJiesu9TzW3gZZTUkCmE9aMPK
TCWBt7FhGa/x+qGJ2DL4fNWFXGW3mrVLQtgP/mdx6+cMxUn07/KkBZDnncT8TVDo
HyeD3yj3YFTG3sJp6zWsbKniyCIVB282pZXbjNudtdYMEt15Hq2WX3xzV4+g9QBs
elLaL4tkvd82G2TgrMgAtCis9dB9YYRWDLskRQA5azhLP82wrbOJF0dfRlQA2+NS
JDdGLpmXbBdwY4Qk4ZYzarE95pZ6Y5VOZSFRynunKnYb59NaCP9ZwrobDOd92m6H
tlpirK/NthJ0aPmkSVMFzu2jHO0zuuS4hkJBW8ZPhijaCSIIAKetS7wgBFqgLpL3
gGJKL35m5O7m5C7v2N5eICXKa/jtqchg00cVKLK1SF1FvFXhYEo=
=ritn
-----END PGP SIGNATURE-----

--=-5bjhfkCd3CuoQXipvuOM--

