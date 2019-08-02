Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2657C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 06:46:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43FBA20657
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 06:46:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43FBA20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94F926B0003; Fri,  2 Aug 2019 02:46:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FF576B0005; Fri,  2 Aug 2019 02:46:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EF146B0006; Fri,  2 Aug 2019 02:46:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BBDD6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 02:46:26 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y66so47544246pfb.21
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 23:46:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=3hbhQyMnJutQ4qhMXj9hIej7qsU3BwtmRe3TITArMXQ=;
        b=oObO+3xMoGGpRR3Ii++yTJhpOrtFnjGMpg9zg2hdLJ0nHt7nSPSyJrT3EW72D/fCMD
         DpWzzUcvy9Egh+dDqzLoks6TV8rQwRWHw/nGsl/rQlMTso26SI2APIZyKco7nbEIEZp4
         /wVDUrrZIKMzyGGkxzsvd0Bh8o8l2VNboYmQ3oOW+7YVp/zxCTtL0O2Qe06aBZtK0J+/
         Vk1hTpY0eyD3ZesLr9CYLzqIyq4x2eYIp5J0DjeUH4qvkICu+X3C29eI/r3uK69ZnGTJ
         0XzN1jLd5LcNQHztqmW7uTtpO9RwzuIcolc1JdS2naSo8gnHFjwknxl4YgkyscKVfJ0d
         6NcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXberPnXVdC8JDEtbaTWsbVEhmr4DNVg5Oa1yuBqvtkcvSB58aF
	4ZGJP573bamKrn+Og8r/6rGljNd2J8gmBN+kypmHJcGbj2IjFVwvr3CIheQS0MRpF3iIRWtHLUA
	/LGTEfYQqU1DXyFyto9DB3bbXV2Wo/LZV8kUe9gjYyyLYoElTUstnZ3GSoTqRW/uHXA==
X-Received: by 2002:aa7:9834:: with SMTP id q20mr58731040pfl.196.1564728385851;
        Thu, 01 Aug 2019 23:46:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJxwP6krGrlpNcH0tFIFOtLCq0zXrGcAM1QCXpqRYnf4eWb3IZyygYzrQGd3KyrVCvaFOr
X-Received: by 2002:aa7:9834:: with SMTP id q20mr58730982pfl.196.1564728385021;
        Thu, 01 Aug 2019 23:46:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564728385; cv=none;
        d=google.com; s=arc-20160816;
        b=qlwGbvkHTalfg56eeeR3NLzc8itHSxwiwqhZHAV6XZp1UTcisI+y7V8TyvWIrJt+ZO
         Y50HbjkuB9eDshyq0mgY9p4At212nbIvio2wTLHxZLNNqXUSGob4FTaemjeAcDpIwQrq
         8XYLrZkIN8+jM3QHuPrjBcyQymtL3PxmhHkmSh+7N9Fq38cC0/aaEMvUkrvXRxOfF8Q1
         ED9AzUWbLEEZli/WLiYqSwrM0FNEJiC/4X0KRTgLPhzqccj74mDb62oCRCgeT5wD51de
         55elwaITDsp793vtizV1Mj5WG2+dSRDRAE3Mw6+pAtxBlMNPlud1bJ10xF8UHzghju5F
         E0fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=3hbhQyMnJutQ4qhMXj9hIej7qsU3BwtmRe3TITArMXQ=;
        b=BirN9QyiJG8JaM5efI5z2kgcKTQtvWyT+/+yhrZoaj7mwoiwKZJc4NajlpA2X1IYit
         KOEdDJbP6lxExoQUGtwircfnKq8Eh5oS8Vx0gk6t34lj1930rR+26enyU9HJX2mFJ2Ok
         ncOS1foFSx3EBTMSvEPlYrNhl+QO0/RDjx85oWktYWF+0dLG2SR85b0zYYsUrxclguSV
         1sIrQK/dDC6z4jW9JuNbhKtlhRuHjByBejvhr4TwiFT8c47T405UJ0xTirJJUXkjP/gH
         t0/XTIjPTlqrjCq5JHZkfuX/uWPAq2Mfl6d3cK01/zjSQvPphRW4a2qWikLp7/09hQBC
         yEyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id g1si34078546plg.353.2019.08.01.23.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 23:46:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 Aug 2019 23:46:23 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,337,1559545200"; 
   d="scan'208";a="167149268"
Received: from orsmsx103.amr.corp.intel.com ([10.22.225.130])
  by orsmga008.jf.intel.com with ESMTP; 01 Aug 2019 23:46:23 -0700
Received: from orsmsx157.amr.corp.intel.com (10.22.240.23) by
 ORSMSX103.amr.corp.intel.com (10.22.225.130) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Thu, 1 Aug 2019 23:46:23 -0700
Received: from orsmsx114.amr.corp.intel.com ([169.254.8.96]) by
 ORSMSX157.amr.corp.intel.com ([169.254.9.94]) with mapi id 14.03.0439.000;
 Thu, 1 Aug 2019 23:46:23 -0700
From: "Prakhya, Sai Praneeth" <sai.praneeth.prakhya@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "Hansen, Dave"
	<dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra
	<peterz@infradead.org>
Subject: RE: [PATCH] fork: Improve error message for corrupted page tables
Thread-Topic: [PATCH] fork: Improve error message for corrupted page tables
Thread-Index: AQHVSCCBTlnukuaks0aiZwfZ/9aV0qbnaerQ
Date: Fri, 2 Aug 2019 06:46:23 +0000
Message-ID: <FFF73D592F13FD46B8700F0A279B802F4F9D61B5@ORSMSX114.amr.corp.intel.com>
References: <20190730221820.7738-1-sai.praneeth.prakhya@intel.com>
	<20190731152753.b17d9c4418f4bf6815a27ad8@linux-foundation.org>
	<a05920e5994fb74af480255471a6c3f090f29b27.camel@intel.com>
 <20190731212052.5c262ad084cbd6cf475df005@linux-foundation.org>
In-Reply-To: <20190731212052.5c262ad084cbd6cf475df005@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiZTA1ZTgzNWMtZTdlZS00NjAxLWEzYWEtNDMxMDE2NzU0MDQyIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiXC9vODNtelwvV0pQeHloZ2YzM0czTnRRSVYrRXNoVzlSU3hZWDRPa1RYcmppbkN2NjVUQmRUcVJaSHRGdld4cVljIn0=
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [10.22.254.138]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > > > +static const char * const resident_page_types[NR_MM_COUNTERS] =3D =
{
> > > > +	"MM_FILEPAGES",
> > > > +	"MM_ANONPAGES",
> > > > +	"MM_SWAPENTS",
> > > > +	"MM_SHMEMPAGES",
> > > > +};
> > >
> > > But please let's not put this in a header file.  We're asking the
> > > compiler to put a copy of all of this into every compilation unit
> > > which includes the header.  Presumably the compiler is smart enough
> > > not to do that, but it's not good practice.
> >
> > Thanks for the explanation. Makes sense to me.
> >
> > Just wanted to check before sending V2, Is it OK if I add this to
> > kernel/fork.c? or do you have something else in mind?
>=20
> I was thinking somewhere like mm/util.c so the array could be used by oth=
er
> code.  But it seems there is no such code.  Perhaps it's best to just lea=
ve fork.c as
> it is now.

Ok, so does that mean have the struct in header file itself?
Sorry! for too many questions. I wanted to check with you before changing=20
because it's *the* fork.c file (I presume random changes will not be encour=
aged here)

I am not yet clear on what's the right thing to do here :(
So, could you please help me in deciding.

Regards,
Sai

