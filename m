Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7A86C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:40:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E210217FA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:40:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E210217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 202928E0176; Mon, 11 Feb 2019 17:40:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18BFC8E0163; Mon, 11 Feb 2019 17:40:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02CA68E0176; Mon, 11 Feb 2019 17:40:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B16FF8E0163
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:40:13 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id q20so473888pls.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:40:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=DdYA1OTtNjnNKRqMs89YyRfY6+GlG8f6w1gj90ByOME=;
        b=FX7P1NyHgAy/kifJ2Aah1JBjE5+TU3JBaNLgAayqz5GxRDpUzxP0fLoUz2WCtYjJxe
         r5f33nmpG/YOiLZpzdVWRtssRBzoEn9B60RVDwMYsJnbsU2nmF79zcUBK9ISjp9eC29w
         h39JhE+k5cLkm9Mw2HJe+dgtOfomCUaGpWHGOeDa9BUfeeu6Z8lxj6T6UNYRqsnvK//T
         vd+tIXLREaWsZ6j17+wUBvggoQkDqMUxEvIE7s+u/sWmsorc4E5g5zzBMAYRrqLfBQdH
         hBWbm1DEMRDWJ5lKh+a1IGDASmqznAJnEiqIckvfJkvp6frJUyi4f8xj2QZlsKqqCXsx
         QMpw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaUodjNGMT1ZYhEu7xRgPhI/Njug0gZyV5UrrkFHTE0bjI7d8bf
	RR46pP6DXiN+p402zY5pNBRsx6z5tj8MzaipfXqV7Mm+YRqeVBfs9BnP6nnV/oq0+0mB8hFTdRU
	VaJniy1GEWS0v6WyHo2OiicR2Jn7Hf6IqtHglQUo4840S+AEltN2t6x9DkXDKST7vWw==
X-Received: by 2002:a65:6497:: with SMTP id e23mr550593pgv.89.1549924813376;
        Mon, 11 Feb 2019 14:40:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZgPbd1sRnTMFZRK12zN6TFz+TgKM3xxcL8djEf2WEwKfD7reIHvXVvUmp/oX5R9FIVZ4Dq
X-Received: by 2002:a65:6497:: with SMTP id e23mr550489pgv.89.1549924811871;
        Mon, 11 Feb 2019 14:40:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549924811; cv=none;
        d=google.com; s=arc-20160816;
        b=XIjvzcGpy6lUE04JJMJerDA/iywWb/4kjmqBFx0BeAGf2oTxNn9LTcN1j7rKH8FF89
         6p/Ik4KwMBekTy6/XCS6R1VP0npUvDrCb6+H+9YdppMnbawzT1ulIomskjCw4tJzEtAm
         2gKGpqNVrnE+heQCfoV4k6RzNZSjBBYWMVRhauXjOd2xdoDDl6NM+4k4pk40sDO69veo
         oc6FOkXoLMzBHvplUFGnYDNUbooMubp3Rql5oLafngr4EVg7cKPmY1VQ86W/Gdg3aD8h
         cHbx7hHwlgsodmZ9RR1aLLIJGw67OxH1QWE0WGvTl2d//SAz/pTZ8VbleWcO0vwhANR8
         SFRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=DdYA1OTtNjnNKRqMs89YyRfY6+GlG8f6w1gj90ByOME=;
        b=IHQVY0h0hcLmhTdg4L/L2fJFGDiqVeTQ1gugxCtJUIxTnseYcv3NHLsdokiEmNJWuZ
         +JRnhAtSXbXb454AvVun6GsiYj8q6rnczJh8pS3ioLfZY5XOtxLE46VTk2WW6X/2UG6p
         SlSdIs+XBBOnoVOJ1E6HrIvaMNe/L6X0qPkH5gCSHJwtQACaMSXPsAPCwYKd6OdR3uRy
         pXWZnXY0oPnucY+5zVPJIOFG0KENSOTIX7lV4uKFid6P6wFHwVqz32nymIKuQaz8Jrnp
         Ne2tS/kun7+DrkScEAhjTDz7qtcnU/23Tzi/jwQdqnXUlpiprzJsmT7s4HHvNQkwLNR/
         gpZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id c17si4789073pfb.81.2019.02.11.14.40.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:40:11 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 14:40:08 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="123707844"
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by fmsmga008.fm.intel.com with ESMTP; 11 Feb 2019 14:40:08 -0800
Received: from fmsmsx116.amr.corp.intel.com (10.18.116.20) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 11 Feb 2019 14:40:08 -0800
Received: from crsmsx151.amr.corp.intel.com (172.18.7.86) by
 fmsmsx116.amr.corp.intel.com (10.18.116.20) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 11 Feb 2019 14:40:06 -0800
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.57]) by
 CRSMSX151.amr.corp.intel.com ([169.254.3.79]) with mapi id 14.03.0415.000;
 Mon, 11 Feb 2019 16:40:03 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Daniel Borkmann
	<daniel@iogearbox.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Marciniszyn, Mike" <mike.marciniszyn@intel.com>, "Dalessandro, Dennis"
	<dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, "Andrew
 Morton" <akpm@linux-foundation.org>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, "Williams, Dan J"
	<dan.j.williams@intel.com>
Subject: RE: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Thread-Topic: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Thread-Index: AQHUwkbGJiw3VF3kpESe1yhfT7MilqXbcliAgAADmgD//4l5gIAAkQ8A//+b9cA=
Date: Mon, 11 Feb 2019 22:40:02 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79BCF37B@CRSMSX101.amr.corp.intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211203417.a2c2kbmjai43flyz@linux-r8p5>
 <20190211204710.GE24692@ziepe.ca>
 <20190211214257.GA7891@iweiny-DESK2.sc.intel.com>
 <20190211222208.GJ24692@ziepe.ca>
In-Reply-To: <20190211222208.GJ24692@ziepe.ca>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiMGMyMmNiMGEtNzUwMC00NDMxLWE1ZmMtNWMwYjg2ZmU5ZDRlIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiT2hFSXpPU0p0Mlg2VVJBcFR2RStXWkpkNTRTck9rOXAzR3pXUUF0MytVcXQ2c2VMa28wc2huVkI0ODJEN3lBNiJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.400.15
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, Feb 11, 2019 at 01:42:57PM -0800, Ira Weiny wrote:
> > On Mon, Feb 11, 2019 at 01:47:10PM -0700, Jason Gunthorpe wrote:
> > > On Mon, Feb 11, 2019 at 12:34:17PM -0800, Davidlohr Bueso wrote:
> > > > On Mon, 11 Feb 2019, ira.weiny@intel.com wrote:
> > > > > Ira Weiny (3):
> > > > >  mm/gup: Change "write" parameter to flags
> > > > >  mm/gup: Introduce get_user_pages_fast_longterm()
> > > > >  IB/HFI1: Use new get_user_pages_fast_longterm()
> > > >
> > > > Out of curiosity, are you planning on having all rdma drivers use
> > > > get_user_pages_fast_longterm()? Ie:
> > > >
> > > > hw/mthca/mthca_memfree.c:       ret =3D get_user_pages_fast(uaddr &
> PAGE_MASK, 1, FOLL_WRITE, pages);
> > >
> > > This one is certainly a mistake - this should be done with a umem.
> >
> > It looks like this is mapping a page allocated by user space for a
> > doorbell?!?!
>=20
> Many drivers do this, the 'doorbell' is a PCI -> CPU thing of some sort

My surprise is why does _userspace_ allocate this memory?

>=20
> > This does not seem to be allocating memory regions.  Jason, do you
> > want a patch to just convert these calls and consider it legacy code?
>=20
> It needs to use umem like all the other drivers on this path.
> Otherwise it doesn't get the page pinning logic right

Not sure what you mean regarding the pinning logic?

>=20
> There is also something else rotten with these longterm callsites, they s=
eem
> to have very different ideas how to handle RLIMIT_MEMLOCK.
>=20
> ie vfio doesn't even touch pinned_vm.. and rdma is applying
> RLIMIT_MEMLOCK to mm->pinned_vm, while vfio is using locked_vm.. No
> idea which is right, but they should be the same, and this pattern should
> probably be in core code someplace.

Neither do I.  But AFAIK pinned_vm is a subset of locked_vm.

So should we be accounting both of the counters?

Ira

