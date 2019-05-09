Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A488C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:22:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD1F6217D6
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:22:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD1F6217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 618FF6B000C; Thu,  9 May 2019 12:22:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C99A6B000D; Thu,  9 May 2019 12:22:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B8436B000E; Thu,  9 May 2019 12:22:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 15F716B000C
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:22:51 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id x5so1854338pll.2
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:22:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=MnJUOeGEfxoXATq898/79HSPqxNr6uBR2VgKy0JDKm8=;
        b=cI0d6U038z1tlNAbCmFJGGssd5rkSxBrKxdjQhZnWN0zibkjO67TIKakre2/xsyjqo
         MN67q/TJ8gY3NCYjLjWylUPdMJsJQdTvTWNrytUEVTJvhSyK3jts1gZV2ZGykzhHbpkw
         mwB/Zkpr2FAVp2Ng7bMwek9YT4mw+Y0s424VnMvDZSw2Lrt7Y4sE+1awbazJi8KUTPeq
         mvA0IzOTB3Q49KXHEhsWU8vv43nqon8Sc/RebO0QGc+sHTgiRJYdIKLAxxJFFRzxK41a
         K0hkYoJMzebtatl807NUGNYu5D1ZYR2zsIc0Y2dCTkXhuAP4H/IPQ0/iju+1ytjF3ddh
         tzIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVjIGwejX6tCdtJ+KF7AJx3rmBHb6+QS2kIBPwIn+fWP6SFaf26
	j8QCWmndRknPefpd54NiyNAc+gl7VtvDEfNn3UURAWu8RzOdIhBBMHe8/n/WLXoXTI5GriBmRrQ
	SJxqTBUUF//wigncWLpCISkRmt5ng8WsOc/4EZ9+zqxQZ6n7GQB0snaXfNqlvI4m0tQ==
X-Received: by 2002:aa7:8e04:: with SMTP id c4mr6470044pfr.48.1557418970717;
        Thu, 09 May 2019 09:22:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVL09ur8DF/uXa3vFWKKNV3C3Q71OvFC+rw3AvNfVg3wXvvsRJGDNaL/K9Mb7YJQ6Y2Xv0
X-Received: by 2002:aa7:8e04:: with SMTP id c4mr6469964pfr.48.1557418970051;
        Thu, 09 May 2019 09:22:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557418970; cv=none;
        d=google.com; s=arc-20160816;
        b=PKa9Xu+fOPDqRxRKEcrK+brrFmAft9bZAemtE8lelQkA+BAM1I4DqhX7it1nmlpHIr
         UER0LtuzKsoiyGEW7SqP8l9Dkajg0vBgkEUxm6nW9Hw1cS9RhNnkybEjphfgKjaFCf1D
         FxBVR2DG+w9RHkfeoFmrqN+poyo9m2q5yzKsU3lVdgj7ga6p7IfktbXK4CEvn0JUaLxr
         Mzc4M+oRChLJfWPl9SHFkQ8fGtmzoqD3o8SFp8GGf3uUg98zO3n9+Umx8xZbgMo0EtYh
         cCisR9HWxqLAB/LSjYoggTEhXXVq6GkHHT5J2YjrbAF8tFJ5ul9WkUr8V+53t2HkTVrj
         deQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=MnJUOeGEfxoXATq898/79HSPqxNr6uBR2VgKy0JDKm8=;
        b=NiaEMVytZRw8KczHQI3LeT8odF7bvoqT9PGEdEyD7qem680asQ19hehdDGfpz50ues
         8deTEo7UJAJWVcyQ5FnfRwiSiU5eG1NrcDjidw1qI4dsfdkgmVcXMc5GZ7pP5+ObzKcd
         frOsOVDOKHNcnuHruBcslhAEkVmYYfpFElwAn2c1qagoWnKSAyv7JhkDf0hnFOK0Sd+g
         Hf7gxdxO0qubuab3yqnLV4h2wdIlyPbOMqeuUpLgsPtBtiK7k0LgqgZaZ4CFoQeJt4VH
         VGCNiAUOI/xHGy4ZuFdBf+L2K2ks/CsC4UKuqMfjPCMMUlyaQopmbTKAY36V9+yoIGFY
         ap/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id o15si3909382pgh.181.2019.05.09.09.22.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 09:22:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 May 2019 09:22:37 -0700
X-ExtLoop1: 1
Received: from fmsmsx108.amr.corp.intel.com ([10.18.124.206])
  by fmsmga004.fm.intel.com with ESMTP; 09 May 2019 09:22:37 -0700
Received: from fmsmsx125.amr.corp.intel.com (10.18.125.40) by
 FMSMSX108.amr.corp.intel.com (10.18.124.206) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 9 May 2019 09:22:36 -0700
Received: from crsmsx103.amr.corp.intel.com (172.18.63.31) by
 FMSMSX125.amr.corp.intel.com (10.18.125.40) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 9 May 2019 09:22:36 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.116]) by
 CRSMSX103.amr.corp.intel.com ([169.254.4.184]) with mapi id 14.03.0415.000;
 Thu, 9 May 2019 10:22:33 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: RE: [PATCH 02/11] mm: Pass order to __alloc_pages_nodemask in GFP
 flags
Thread-Topic: [PATCH 02/11] mm: Pass order to __alloc_pages_nodemask in GFP
 flags
Thread-Index: AQHVBIqaXqt0fPnBZEirHr/43yV0JKZh+T+AgAFAwAD//8NusA==
Date: Thu, 9 May 2019 16:22:33 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79D0CEBC@CRSMSX101.amr.corp.intel.com>
References: <20190507040609.21746-1-willy@infradead.org>
 <20190507040609.21746-3-willy@infradead.org>
 <20190509015015.GA26131@iweiny-DESK2.sc.intel.com>
 <20190509135816.GA23561@bombadil.infradead.org>
In-Reply-To: <20190509135816.GA23561@bombadil.infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiNDFmY2E1MjYtY2U5OS00ZmI1LTk2NDYtODg4MmFlOTI2NGEzIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiamlnWkpnNU5yWXFGbXphSndCeGxCTTVTUDhMNXVFNFQwaENOdGhiQ2kzWnc4b1FHMzlPXC9RaTYxeGlTY1pWQ08ifQ==
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
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

>=20
> On Wed, May 08, 2019 at 06:50:16PM -0700, Ira Weiny wrote:
> > On Mon, May 06, 2019 at 09:06:00PM -0700, Matthew Wilcox wrote:
> > > Save marshalling an extra argument in all the callers at the expense
> > > of using five bits of the GFP flags.  We still have three GFP bits
> > > remaining after doing this (and we can release one more by
> > > reallocating NORETRY, RETRY_MAYFAIL and NOFAIL).
>=20
> > > -static void *dsalloc_pages(size_t size, gfp_t flags, int cpu)
> > > +static void *dsalloc_pages(size_t size, gfp_t gfp, int cpu)
> > >  {
> > >  	unsigned int order =3D get_order(size);
> > >  	int node =3D cpu_to_node(cpu);
> > >  	struct page *page;
> > >
> > > -	page =3D __alloc_pages_node(node, flags | __GFP_ZERO, order);
> > > +	page =3D __alloc_pages_node(node, gfp | __GFP_ZERO |
> > > +__GFP_ORDER(order));
> >
> > Order was derived from size in this function.  Is this truely equal to
> > the old function?
> >
> > At a minimum if I am wrong the get_order call above should be removed,
> no?
>=20
> I think you have a misunderstanding, but I'm not sure what it is.
>=20
> Before this patch, we pass 'order' (a small integer generally less than 1=
0) in
> the bottom few bits of a parameter called 'order'.  After this patch, we =
pass
> the order in some of the high bits of the GFP flags.  So we can't remove =
the
> call to get_order() because that's what calculates 'order' from 'size'.

Ah I see it now.  Sorry was thinking the wrong thing when I saw that line.

Yep you are correct,
Ira


>=20
> > > +#define __GFP_ORDER(order) ((__force gfp_t)(order <<
> __GFP_BITS_SHIFT))
> > > +#define __GFP_ORDER_PMD	__GFP_ORDER(PMD_SHIFT -
> PAGE_SHIFT)
> > > +#define __GFP_ORDER_PUD	__GFP_ORDER(PUD_SHIFT -
> PAGE_SHIFT)
> > > +
> > > +/*
> > > + * Extract the order from a GFP bitmask.
> > > + * Must be the top bits to avoid an AND operation.  Don't let
> > > + * __GFP_BITS_SHIFT get over 27, or we won't be able to encode
> > > +orders
> > > + * above 15 (some architectures allow configuring MAX_ORDER up to
> > > +64,
> > > + * but I doubt larger than 31 are ever used).
> > > + */
> > > +#define gfp_order(gfp)	(((__force unsigned int)gfp) >>
> __GFP_BITS_SHIFT)

