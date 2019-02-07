Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B16C4C169C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 02:42:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 535A72175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 02:42:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 535A72175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6C3E8E0010; Wed,  6 Feb 2019 21:42:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1A568E0002; Wed,  6 Feb 2019 21:42:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2F7F8E0010; Wed,  6 Feb 2019 21:42:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 791078E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 21:42:11 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id q11so8976153qtp.3
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 18:42:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:organization
         :user-agent:mime-version;
        bh=wY22i9Lu/9vYtvd8t3OpcdDTuAI/7AD9Ow3yUTH7upc=;
        b=N6OLY03LHuJFQZPEAym6ajTmjAsXZLLewFzz9OcpFBUdRrwzoY56sc0NV+4ccIIQQU
         lfHZKSbfn46uX39Y1DOCgkPv5ZvxezcNhsmPuEE1ZZ2TVtwGx2XqjQrvk2elwE2QGieb
         Nw1u6yflrFa8DrY5MiKBSjtRZ+KPFo3Fc76bc4N5JyIPyRHZRc5Mm1cLOJPmtaEEq32k
         RFCJjmOdN3SfwpAFAVRnyLADxq1gXSPiii6I4teE+kbqc8TuD01MvN03hCQBmwDxOAjq
         zOCf+eF3Si4vbugtIy0sUHeagtsJ/s4D2Jdig/TieWLbSPyGa4w9gnbjaL+Rw1D685cL
         uD/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZ0BArsrDusUiRAavGBqDJpwM+f1Os9C1MnGtNUOcNO9pvXFiiz
	eOk4fC/iQHt8Na3LiKo3hWzHrP8yMd/c0nO9YxEq9YQGrS+z+tuhxuZ46OLRDp7t7RytJTWdKZ8
	5958AZCTC6fuTceiB6Fd4KIqDk0BV5i1H5hTaI3MFglXJn1SiZkMbylj+dlzz2KXUZA==
X-Received: by 2002:a0c:9dc6:: with SMTP id p6mr10428908qvf.217.1549507331192;
        Wed, 06 Feb 2019 18:42:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia9ysy0sF9co1x0j9Jlbus+74lEbCCWW7jo/I5spLWFis7YSMb/YeSrq8Nqy0MUmrChOL4X
X-Received: by 2002:a0c:9dc6:: with SMTP id p6mr10428880qvf.217.1549507330526;
        Wed, 06 Feb 2019 18:42:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549507330; cv=none;
        d=google.com; s=arc-20160816;
        b=kQvkHUES2YytsMLXJ3cg/yPWmzAXQGIUbTEJEPtEeTck7iv5U4HCAHzX39yAT7hb82
         3N2X68wpCmwmBSp+3T+I+xJWy5U378AbVs03+AYapAqf3vSt0N2ZDN2fmiqgE5Ee5wLj
         CQgCPAT6BV+KUuouDbCAEtUe/QpBE5dfVfwhlZ+yjbsmvA8mJoyA//xYw6Q2824/dax1
         yEZ+VSZATSKpyschD9nPZgXwjH21jJX6dv86oH/asLjr+Xbx/X/MQvNyUzkXXbjJQmkB
         opOW2eZxSRcocn6NW/w9tOh2oea9yt0SqORO2bGx0fhLA+D8snaQiXUNqMTXdTQ9JLKA
         sZ3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:organization:references:in-reply-to:date:cc
         :to:from:subject:message-id;
        bh=wY22i9Lu/9vYtvd8t3OpcdDTuAI/7AD9Ow3yUTH7upc=;
        b=0DU7Qy6d7TFClDJCmPbpIfOl8oE1tbD81ijtcjQHHEI3p5Cg2Yh5RAHcbSe6pDzMd2
         2uzNJJ5l3aVG1tnTTitx/wxaJuHbqkkYQWAVdXXAT4DCupsZv4klDCJP1pCryrodrwwS
         ADiEuD3MnDlJBHuBpXI8ycERFAWsx5lGBaLuuV6kHRdmOcjcAU8hqhfAwyA+GwzCPxSV
         oXrDgtaCOOXD1H7B2EsNPme1p9p8iu6eQ1tf47W/qfSMcObIftEGy9FNk2dZ6PhRMRrr
         dzczPrtbGtzzex7R6xHCzKBbpuUrfisdJbDWgrdbhFPUWnEL0Ri43rVpzr87FrvZo7tk
         FkcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u32si526682qvc.119.2019.02.06.18.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 18:42:10 -0800 (PST)
Received-SPF: pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dledford@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dledford@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 15A6C8AE76;
	Thu,  7 Feb 2019 02:42:09 +0000 (UTC)
Received: from haswell-e.nc.xsintricity.com (ovpn-112-17.rdu2.redhat.com [10.10.112.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7A6FE179C9;
	Thu,  7 Feb 2019 02:42:06 +0000 (UTC)
Message-ID: <658363f418a6585a1ffc0038b86c8e95487e8130.camel@redhat.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
From: Doug Ledford <dledford@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Dave Chinner <david@fromorbit.com>, 
 Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>,
 Jan Kara <jack@suse.cz>,  Ira Weiny <ira.weiny@intel.com>,
 lsf-pc@lists.linux-foundation.org, linux-rdma <linux-rdma@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Jerome
 Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
Date: Wed, 06 Feb 2019 21:42:03 -0500
In-Reply-To: <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
	 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
	 <20190206175233.GN21860@bombadil.infradead.org>
	 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
	 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
	 <20190206210356.GZ6173@dastard> <20190206220828.GJ12227@ziepe.ca>
	 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
	 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
Organization: Red Hat, Inc.
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-7DPuKcdbFR8/o52+ZlEI"
User-Agent: Evolution 3.30.4 (3.30.4-1.fc29) 
Mime-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 07 Feb 2019 02:42:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-7DPuKcdbFR8/o52+ZlEI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-02-06 at 14:44 -0800, Dan Williams wrote:
> On Wed, Feb 6, 2019 at 2:25 PM Doug Ledford <dledford@redhat.com> wrote:
> > Can someone give me a real world scenario that someone is *actually*
> > asking for with this?
>=20
> I'll point to this example. At the 6:35 mark Kodi talks about the
> Oracle use case for DAX + RDMA.
>=20
> https://youtu.be/ywKPPIE8JfQ?t=3D395

I watched this, and I see that Oracle is all sorts of excited that their
storage machines can scale out, and they can access the storage and it
has basically no CPU load on the storage server while performing
millions of queries.  What I didn't hear in there is why DAX has to be
in the picture, or why Oracle couldn't do the same thing with a simple
memory region exported directly to the RDMA subsystem, or why reflink or
any of the other features you talk about are needed.  So, while these
things may legitimately be needed, this video did not tell me about
how/why they are needed, just that RDMA is really, *really* cool for
their use case and gets them 0% CPU utilization on their storage
servers.  I didn't watch the whole thing though.  Do they get into that
later on?  Do they get to that level of technical discussion, or is this
all higher level?

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--=-7DPuKcdbFR8/o52+ZlEI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlxbmvsACgkQuCajMw5X
L93hMg/+MsKeTSWBe23u1LbQAPXeHxl4k8Yi91H9RYq8vp1SWYqJCsGxRS8U07tS
lYJcnjNYxdIjjUE35E7tTCVS8HzJ9Kyj6DmxGcErb6UAH0QY7QsSTxlS4kzYt4ea
FArz31ERKCxfCy7wsryKHdthZ2tpChgZNFqKvklv9GI9hbq5dQB+GdAc6XPOB1K6
reIV0BEUGGuTJbEXLTra+pzikeJZ1yzvOs74qx1PAjvE+gxExRA+CfzndwkKCfgE
wgDxfpma8S1bwc9fpke5ea/oQJXsnCBWm6BWpNWZws4/jvAveAWdGECscYiz/6Qu
d5gB5hrR689voX0oivLCZ/PpFEngnOmbdruI1ESR4e3kscl+VmSj74CSOyEFv4cN
t6A3HgESFXKg2/FR0zVTt1laJdOC3f50U7v946erbuYnLKEwTBKLPZvMRpFz8Wp/
NcVPUJXhgVI0mPDYMUATZ/DJhvPq1SQGhYkBNT524PeVLAh5Uk3NwKljZ8Ubkx3V
ISJrWMBSk1G+CHctK6gzh9slamHgjXdw98vJomyxcjdVQFk6LFXk3zWTtOS51YbN
EECT/GIgNJRGy8M+jJfO7NbIMh6DKbwBA2SaC3e0Fa2tA3p8KfQ/CgcvdURASvIJ
XB51Q2p4hb/n4rr8H1305ZJDHnzEbLVyC4dvwLQ2PjU+OGs0iPk=
=xZBH
-----END PGP SIGNATURE-----

--=-7DPuKcdbFR8/o52+ZlEI--

