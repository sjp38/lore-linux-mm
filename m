Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75636C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:45:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DA722190F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 22:45:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DA722190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B88C76B0003; Tue,  2 Jul 2019 18:45:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B12098E0003; Tue,  2 Jul 2019 18:45:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B3718E0001; Tue,  2 Jul 2019 18:45:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F39B6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 18:45:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y5so155836pfb.20
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 15:45:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=dVx2A0Jvon8R6kUdvQexFV0G7rVcXeP4iey51gRjA8I=;
        b=rb11rLt1JClyfNa7z+PYId/USO5GIDs57eqS6FlMWLlJxl7KqydllGRXjPB3UGyACA
         hB/Z5pgB5/IhGKYBYRbPO4An9aSR73LZCx+nb7YXLPm5bKVUYLc7iDYQgeJxudw7Sv9E
         EjKXXDTPLm2XjmG2KwpiUznzhcDUeCqDIO0RECGQpKyePOWx3UHbdRKVp/Ph/7G/sd+8
         zpXZXQBq7bFR5CxdQG06cOvlup+VK+IfzF5MN4oJ66HXu2h9feUnYe0dxn4pJPknpwOR
         6lASlCcoEJku5XGySIVwAxou1ZDXsukwU9TfHUU3LWwUN+08tzKfKPsy2XY14rSQ37Ug
         SDwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXKlto5LcMPjlaUmEfwH6toSOu9bFeP0NHKRSsw6wFdcJ7SngMg
	WFT+vjesHJ8jkHDoZB17O/mD0Y7FjBDp44uO+5yxlN8M8ajstMDtOIcT1SGeLmpbnWAThIRoc+n
	lXX/bj4ovH0u92c8ne9VWRvkM86qcKGXKsVHAAqTiD9I0XMXs8CSZotGtVkoMcj7D0A==
X-Received: by 2002:a17:90a:2385:: with SMTP id g5mr8571710pje.12.1562107538031;
        Tue, 02 Jul 2019 15:45:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxKDjJH/vEjz20vfwKscTqHGMFvP9UJcPUnCl7tEo2S+eS7+qL9j/zF08X07snyDlEx+FE
X-Received: by 2002:a17:90a:2385:: with SMTP id g5mr8571651pje.12.1562107537238;
        Tue, 02 Jul 2019 15:45:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562107537; cv=none;
        d=google.com; s=arc-20160816;
        b=rM2bwlcUZXSufmFg/MtleMosmKMuCSeTwn++sZlUjaKW4Axj+oSs5XVO7YVqXe+MFR
         YwgIVJR+fc2fF22+tmBY74HYS3mjznm7TQtKbIDpS9br9Um82fqKMJPr/W2KR84OgOzw
         HFq/2wbU6zvYxxAdl8EccxfV/J2alAbhaVamiGxn90ezr6PUEe8H8sFvrTcTNKXeMcqH
         wKiEHpDUNJFkI7VGWfwgv9asoXq2GsJ3URnzoeVFBsZAYxpWo8pvD9utYgxGDEd7Bzy7
         NnNLteV5p+gafLKsR4MpphCI1mB55cBEocevMsJB14BNtr+zSqqzVQ7UKnGYfVf/uzYb
         ImMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=dVx2A0Jvon8R6kUdvQexFV0G7rVcXeP4iey51gRjA8I=;
        b=TbLIUAtE2JRCvEltAx7Np+Kh/xcr/spspYBUl4JpBiVwXt9YugHWUm9LtVsDuSW4XK
         dMy/PDrJ+zb+6NRiHvDwKxzbOoj8eClapr+74tQ44Aux/y2DP6L2Dp05REEBP3NS+Znb
         yCoyN/5x73Q5wbANbNdabRtqN5Fix5q6kEhm7jVvLt9f0vJhZZQDIbCveNzJzVESd3Fm
         CaQvbABtneoYY8vNAPpcHAjTihvsZD6657HH8GWKl4J4GRqX3RxqQ/fooiZeCdo7/wVs
         avSXYNFmNjL3CKvspqyQJmmFbg8YubXf7TlAb+LzShyzXjAsQZP3tag2b7ONkVW72h8q
         XK8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l4si3160826pjq.69.2019.07.02.15.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 15:45:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Jul 2019 15:45:36 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,444,1557212400"; 
   d="scan'208";a="171943496"
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by FMSMGA003.fm.intel.com with ESMTP; 02 Jul 2019 15:45:36 -0700
Received: from fmsmsx152.amr.corp.intel.com (10.18.125.5) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Tue, 2 Jul 2019 15:45:36 -0700
Received: from crsmsx104.amr.corp.intel.com (172.18.63.32) by
 FMSMSX152.amr.corp.intel.com (10.18.125.5) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Tue, 2 Jul 2019 15:45:36 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.124]) by
 CRSMSX104.amr.corp.intel.com ([169.254.6.189]) with mapi id 14.03.0439.000;
 Tue, 2 Jul 2019 16:45:34 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>
CC: "Williams, Dan J" <dan.j.williams@intel.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: dev_pagemap related cleanups v4
Thread-Topic: dev_pagemap related cleanups v4
Thread-Index: AQHVL9UWGRaDoyThvUmAcd/teNbddKa10fGAgAI+rID//8OxIA==
Date: Tue, 2 Jul 2019 22:45:34 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79DEA747@CRSMSX101.amr.corp.intel.com>
References: <20190701062020.19239-1-hch@lst.de>
 <20190701082517.GA22461@lst.de> <20190702184201.GO31718@mellanox.com>
In-Reply-To: <20190702184201.GO31718@mellanox.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiYjc2ZTdhMmQtMWM5Zi00ZTAzLWJmY2UtNGZjYTkyNTYxNjZjIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiV2VKQ1gzZk1WV2hvSmx0bEFBUjRyWFNOT0JNemtQSkdVaHlIbkdveVFhVFdxSlh0T2h3ZytucCt4dWx6djFPTSJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>=20
> On Mon, Jul 01, 2019 at 10:25:17AM +0200, Christoph Hellwig wrote:
> > And I've demonstrated that I can't send patch series..  While this has
> > all the right patches, it also has the extra patches already in the
> > hmm tree, and four extra patches I wanted to send once this series is
> > merged.  I'll give up for now, please use the git url for anything
> > serious, as it contains the right thing.
>=20
> Okay, I sorted it all out and temporarily put it here:
>=20
> https://github.com/jgunthorpe/linux/commits/hmm
>=20
> Bit involved job:
> - Took Ira's v4 patch into hmm.git and confirmed it matches what
>   Andrew has in linux-next after all the fixups

Looking at the final branch seems good.

Ira

> - Checked your github v4 and the v3 that hit the mailing list were
>   substantially similar (I never did get a clean v4) and largely
>   went with the github version
> - Based CH's v4 series on -rc7 and put back the removal hunk in swap.c
>   so it compiles
> - Merge'd CH's series to hmm.git and fixed all the conflicts with Ira
>   and Ralph's patches (such that swap.c remains unchanged)
> - Added Dan's ack's and tested-by's
>=20
> I think this fairly closely follows what was posted to the mailing list.
>=20
> As it was more than a simple 'git am', I'll let it sit on github until I =
hear OK's
> then I'll move it to kernel.org's hmm.git and it will hit linux-next. 0-d=
ay
> should also run on this whole thing from my github.
>=20
> What I know is outstanding:
>  - The conflicting ARM patches, I understand Andrew will handle these
>    post-linux-next
>  - The conflict with AMD GPU in -next, I am waiting to hear from AMD
>=20
> Otherwise I think we are done with hmm.git for this cycle.
>=20
> Unfortunately this is still not enough to progress rdma's ODP, so we will=
 need
> to do this again next cycle :( I'll be working on patches once I get all =
the
> merge window prep I have to do done.
>=20
> Regards,
> Jason

