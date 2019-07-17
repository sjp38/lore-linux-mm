Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC406C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 15:47:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7550F2173B
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 15:47:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7550F2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B46586B0006; Wed, 17 Jul 2019 11:47:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF7FD6B000A; Wed, 17 Jul 2019 11:47:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E6306B000D; Wed, 17 Jul 2019 11:47:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 640356B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 11:47:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id t18so4949997pgu.20
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 08:47:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=Q3EncJAqfgHcWLzZnICoakAZpphC3++HC4cHk1Li5aM=;
        b=c7zHBJe6NYVku4NK403KTXubXi2XbfYPC+Sutx/3R97+yFM7K1WE7zO16JQDXS+22X
         OCDMBtU8aKzOiPxuNgviEpGIgdwEtuv5My9quv5PIDbtXIsfG+d69TcdlEakNxDyoi9m
         5DpKliXXGOprhRP+44hJd/B098/3wzPSGwom65U8lmED7NzIVYviHiFbN/7yN1V2B8Ho
         ztRYwoZTUN2iuPRToE5Wx2CVIv5C3wvLbiZsjI6i2iErWRv3N9QjljRf5o2kvtFIkb+3
         L8E9OCHK1MxMBqMA368K3uEm4D0/+kbnZ3AiwCCXmyuCDvyk/4z8mOeFEl8c/++6HPNx
         QCaw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAULUhqc8G+cOEPl4MJhT0meC8htyEVdP2a6td0W//CDWcQGpB+/
	TDelONCIMfXNlmxpOLZcrABP7D4VjxcXtJgoishYYmSlD7TRVU68QrFQOYvD0pLxBlGPrqeH0Ll
	bsZYs5Rd9ho1Cla4mJUUngOHhg9QlaopbxYB7OL0UiU+yIJG26bPfUJH4zAtfAqW81g==
X-Received: by 2002:a63:eb06:: with SMTP id t6mr37022739pgh.107.1563378422951;
        Wed, 17 Jul 2019 08:47:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwb5H3y359qqigjcbfVzGG9Kzq0uykblpyhxmCfyD+bWD/U8Iwb9bOR240naAZIeb8BkYrQ
X-Received: by 2002:a63:eb06:: with SMTP id t6mr37022601pgh.107.1563378421879;
        Wed, 17 Jul 2019 08:47:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563378421; cv=none;
        d=google.com; s=arc-20160816;
        b=XKwD0vgHBjUKu/o3clEChg18gkbQSNok9gsdyoS3L90Vko28uzSl85TMhkrOo5mecn
         LKGX93p8llj16fEsYhUiLV09Mf+nVzvl7LbfTc/lG3pvWTgLKBSuJ+T83lrjbsSugAsJ
         VAv0UyqeQX7XhQTv/kZ1AI+owBfm7twBgMuXMb21xRpGh4+NRfg9dxB5nhYMF20qB+Yf
         JRKmvurBkNciK1VmyCMpUQHftwPL7HNT8K9TKznu8JwBUEEdXavqf1YU7i1l3x3qCI4S
         /eoDJAPo4HDPUr2BJj++57tgYMvt0dqn99E42TPw5TKlgSJG1HQVcyuAf74IryZirZY+
         qZaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=Q3EncJAqfgHcWLzZnICoakAZpphC3++HC4cHk1Li5aM=;
        b=uU1r3okI67WXibsOxugM2BpjKLpsvDp53BWPKusCRMidYa7IYNsQIA5GmkIkfv5P5G
         +bDysmr8+U7tUgLHqQLQW5R1iqy0y4FIRoAfqEXBGoDeBts3q3+doEs3zLcRaiReBzMM
         MORkmEbbkxDH4U+8ef7YodbWzWrEL0EGXqEI9IMwwfu2M/mH7N3sXmNTthdEIEeNR1kq
         pK3nkKh2eT6Maf28sua8IP/UgwDBRe4nDvNkuBMNtnKe+Xc22Y2UwrDLYfVDmgKRl1Dz
         feHmKaJUeZAT4KvzMA7yra7WfGf7rASxsiFyaN0ZK9Sf0kerLj0J5rjo1x6aCOospJVQ
         /Axw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id x1si6995211plb.28.2019.07.17.08.47.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 08:47:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jul 2019 08:46:59 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,274,1559545200"; 
   d="scan'208";a="169592189"
Received: from fmsmsx105.amr.corp.intel.com ([10.18.124.203])
  by fmsmga007.fm.intel.com with ESMTP; 17 Jul 2019 08:46:59 -0700
Received: from shsmsx154.ccr.corp.intel.com (10.239.6.54) by
 FMSMSX105.amr.corp.intel.com (10.18.124.203) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Wed, 17 Jul 2019 08:46:59 -0700
Received: from shsmsx102.ccr.corp.intel.com ([169.254.2.3]) by
 SHSMSX154.ccr.corp.intel.com ([169.254.7.240]) with mapi id 14.03.0439.000;
 Wed, 17 Jul 2019 23:46:57 +0800
From: "Wang, Wei W" <wei.w.wang@intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Alexander Duyck
	<alexander.duyck@gmail.com>
CC: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "Andrew
 Morton" <akpm@linux-foundation.org>, Yang Zhang <yang.zhang.wz@gmail.com>,
	"pagupta@redhat.com" <pagupta@redhat.com>, Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "lcapitulino@redhat.com"
	<lcapitulino@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Paolo
 Bonzini" <pbonzini@redhat.com>, "Williams, Dan J" <dan.j.williams@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: RE: use of shrinker in virtio balloon free page hinting
Thread-Topic: use of shrinker in virtio balloon free page hinting
Thread-Index: AQHVPJG4M96i+fJ6kUytx6sFNaZpP6bO17og
Date: Wed, 17 Jul 2019 15:46:57 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73E16D4B2@shsmsx102.ccr.corp.intel.com>
References: <20190717071332-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190717071332-mutt-send-email-mst@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiZWQwOTNjZDctYzMyOC00Mzg1LTgwOWMtNjNkNjliYmY2Yjg3IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiUzNSVGk4aHVLTE8xK2Q3XC9QXC9lVVhRTitQNEdsR3pPaWlqRlh4QWdFOGhJWDJFSGlLd3AxNWxZcnRXS082ZDgxIn0=
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [10.239.127.40]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday, July 17, 2019 7:21 PM, Michael S. Tsirkin wrote:
>=20
> Wei, others,
>=20
> ATM virtio_balloon_shrinker_scan will only get registered when deflate on
> oom feature bit is set.
>=20
> Not sure whether that's intentional.=20

Yes, we wanted to follow the old oom behavior, which allows the oom notifie=
r
to deflate pages only when this feature bit has been negotiated.


> Assuming it is:
>=20
> virtio_balloon_shrinker_scan will try to locate and free pages that are
> processed by host.
> The above seems broken in several ways:
> - count ignores the free page list completely

Do you mean virtio_balloon_shrinker_count()? It just reports to
do_shrink_slab the amount of freeable memory that balloon has.
(vb->num_pages and vb->num_free_page_blocks are all included )

> - if free pages are being reported, pages freed
>   by shrinker will just get re-allocated again

fill_balloon will re-try the allocation after sleeping 200ms once allocatio=
n fails.

=20
> I was unable to make this part of code behave in any reasonable way - was
> shrinker usage tested? What's a good way to test that?

Please see the example that I tested before : https://lkml.org/lkml/2018/8/=
6/29
(just the first one: *1. V3 patches)

What problem did you see?

I just tried the latest code, and find ballooning reports a #GP (seems caus=
ed by
418a3ab1e).=20
I'll take a look at the details in the office tomorrow.

Best,
Wei

