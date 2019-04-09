Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4E76C282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 14:55:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADA1420674
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 14:55:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADA1420674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BE186B0010; Tue,  9 Apr 2019 10:55:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46E6B6B0269; Tue,  9 Apr 2019 10:55:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3112C6B026A; Tue,  9 Apr 2019 10:55:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E6A4B6B0010
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 10:55:35 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d16so9650930pll.21
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 07:55:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=Dm6PQcRpv29dCuhToqNEWUo1dqcLMQHVXPlhT9IPJk4=;
        b=DAKn20Ao45WFU7E4oRRdxFRGPKdUugQOEFeReFcSdEbYI6HRwg7wgs1/w7fjE8cuJL
         lFJUxoP3Ggw2BEWy0THvMeBwnOg6sbmdXEkYRVLHz2PnF4GFCPOO1ADcWEqm23QeC0OS
         aMfMuCM/pNMdHsaB81xOao048bAvMOA2uOGRRnJiOOXdIWME/3vHNtyybpjtxqtWCH3+
         mr7BYJHmxcxMzol4VAoAA5GZi4hTc3S5GZmFGSrEVw0T5bboEj+WgHSs7b4CNXVcA+QC
         YEn2OLbcN5tHaMczqYGO5kGm5gnkkqUdhYXV7Bo+YBmABz4Dhkgt/UuE5yUn3YCgrR0b
         Apvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVjPswfv4adJu1LpjZAbBEw+RpbJPP+GoOk4+THTsqXImjpjLg6
	lEOXisV94aBLNrm6OFBEtqIju+R1sQYXGkfmhBd1Tq8YbKh7e8HYp584SldUNL+t7CnFu8IwS3r
	FjPbqqlMXXOwLj4A8K/qOJXFSSZ0wEU4tLguf14v7TqdBvhKV0mL4Nh77tRWbmI5qEA==
X-Received: by 2002:a17:902:1621:: with SMTP id g30mr6567828plg.168.1554821735485;
        Tue, 09 Apr 2019 07:55:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygjaQpRFeLJ+3bkdvE9EUDExxIrBo647LVsjfzsN1xECQ9o01Fv3g80BF81s9WdaHdqcgA
X-Received: by 2002:a17:902:1621:: with SMTP id g30mr6567792plg.168.1554821734744;
        Tue, 09 Apr 2019 07:55:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554821734; cv=none;
        d=google.com; s=arc-20160816;
        b=wmeXbD4jtZy/lxQZydAp5gdhQt+MHpbCmq5nZREVR0+0uiRmA3UpCgmi+N6O4K18dW
         ItHNAC+o01yz6Sij8VRJj0VtVQGJEFwOUVASNbVDB8IKfhHWXW0HUE+ZUisgU1dB9V1V
         92kR/70aLAB5Ulmd9JxeC+ELpua5jvcLDBg3KL9rCrFCDhHrbCTl875iLM3BBbXyGE/0
         HmuMdCkHOhO2t+h2su9Ul0vyExXM91DElqzwDy5tPkyXrX7mytc+dY4i/O6Jd9iWGS7L
         Gq9za9woparj+tcLezevOvwm89GGheZmCq8EhkjQk42sJWd6Oc0adrdJzkYaJG9aGOAd
         8vXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=Dm6PQcRpv29dCuhToqNEWUo1dqcLMQHVXPlhT9IPJk4=;
        b=HtLs+tK9twrTjms8BR8BSzThrsCYnK8tsW514SBBfWm9kuqXhx3TtUf4g44faevCSd
         afrBGk9UUhjfG4HYjDoBBpmDM5jXQNvU0DyDtdl7mSMfw5LPfV/wpPPWUOQPjbZ18ALQ
         c4/CWVsycC+x7kDjRYcCEzNroNfaTOaaKWeeD/T3GQXiHmkWbW45/Nn4RyhFZypuUdkr
         P1x5b94UpfGso/7xmHgc5YFIEXVU4G1y+539LB3oQhDmmrE/WLhth8c73HkuUKPdkIuU
         ydBg825yUQm7zCHsiPKSCEwR41yecLPZ62kkyuJ8H8j7TDL4pvws3rNaqOUThsNkgslS
         0VWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c17si21885150pls.23.2019.04.09.07.55.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 07:55:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Apr 2019 07:55:34 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,329,1549958400"; 
   d="scan'208";a="129878638"
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by orsmga007.jf.intel.com with ESMTP; 09 Apr 2019 07:55:33 -0700
Received: from fmsmsx126.amr.corp.intel.com (10.18.125.43) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Tue, 9 Apr 2019 07:55:33 -0700
Received: from crsmsx103.amr.corp.intel.com (172.18.63.31) by
 FMSMSX126.amr.corp.intel.com (10.18.125.43) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Tue, 9 Apr 2019 07:55:33 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.94]) by
 CRSMSX103.amr.corp.intel.com ([169.254.4.179]) with mapi id 14.03.0415.000;
 Tue, 9 Apr 2019 08:55:31 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>, Huang Shijie <sjhuang@iluvatar.ai>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"palmer@sifive.com" <palmer@sifive.com>, "axboe@kernel.dk" <axboe@kernel.dk>,
	"keescook@chromium.org" <keescook@chromium.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 1/2] mm/gup.c: fix the wrong comments
Thread-Topic: [PATCH 1/2] mm/gup.c: fix the wrong comments
Thread-Index: AQHU7bQlN2diAK7eV0icdWdVKwXx36Yys5SAgAC3GYCAABwzgIAABCQAgACKPoD//9cAcA==
Date: Tue, 9 Apr 2019 14:55:31 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79CA51BA@CRSMSX101.amr.corp.intel.com>
References: <20190408023746.16916-1-sjhuang@iluvatar.ai>
 <20190408141313.GU22763@bombadil.infradead.org>
 <20190409010832.GA28081@hsj-Precision-5520>
 <20190409024929.GW22763@bombadil.infradead.org>
 <20190409030417.GA3324@hsj-Precision-5520>
 <20190409111905.GY22763@bombadil.infradead.org>
In-Reply-To: <20190409111905.GY22763@bombadil.infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiMzRhODcyZmYtMzU1Yi00NzdjLTk0ODItMzE5OTNlNDc2YmY3IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoianRaRFRkODRvY1wvbGYyQzVXQzNsSmE1SlwvVW9qOWlhSHlBcWNLQUlCeCtmaGpGcHdOMmVxdjY2Z3hIejBPU0tPIn0=
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

> On Tue, Apr 09, 2019 at 11:04:18AM +0800, Huang Shijie wrote:
> > On Mon, Apr 08, 2019 at 07:49:29PM -0700, Matthew Wilcox wrote:
> > > On Tue, Apr 09, 2019 at 09:08:33AM +0800, Huang Shijie wrote:
> > > > On Mon, Apr 08, 2019 at 07:13:13AM -0700, Matthew Wilcox wrote:
> > > > > On Mon, Apr 08, 2019 at 10:37:45AM +0800, Huang Shijie wrote:
> > > > > > The root cause is that sg_alloc_table_from_pages() requires
> > > > > > the page order to keep the same as it used in the user space,
> > > > > > but
> > > > > > get_user_pages_fast() will mess it up.
> > > > >
> > > > > I don't understand how get_user_pages_fast() can return the
> > > > > pages in a different order in the array from the order they appea=
r in
> userspace.
> > > > > Can you explain?
> > > > Please see the code in gup.c:
> > > >
> > > > 	int get_user_pages_fast(unsigned long start, int nr_pages,
> > > > 				unsigned int gup_flags, struct page **pages)
> > > > 	{
> > > > 		.......
> > > > 		if (gup_fast_permitted(start, nr_pages)) {
> > > > 			local_irq_disable();
> > > > 			gup_pgd_range(addr, end, gup_flags, pages, &nr);
> // The @pages array maybe filled at the first time.
> > >
> > > Right ... but if it's not filled entirely, it will be filled
> > > part-way, and then we stop.
> > >
> > > > 			local_irq_enable();
> > > > 			ret =3D nr;
> > > > 		}
> > > > 		.......
> > > > 		if (nr < nr_pages) {
> > > > 			/* Try to get the remaining pages with
> get_user_pages */
> > > > 			start +=3D nr << PAGE_SHIFT;
> > > > 			pages +=3D nr;                                                  =
// The
> @pages is moved forward.
> > >
> > > Yes, to the point where gup_pgd_range() stopped.
> > >
> > > > 			if (gup_flags & FOLL_LONGTERM) {
> > > > 				down_read(&current->mm->mmap_sem);
> > > > 				ret =3D __gup_longterm_locked(current,
> current->mm,      // The @pages maybe filled at the second time
> > >
> > > Right.
> > >
> > > > 				/*
> > > > 				 * retain FAULT_FOLL_ALLOW_RETRY
> optimization if
> > > > 				 * possible
> > > > 				 */
> > > > 				ret =3D get_user_pages_unlocked(start,
> nr_pages - nr,    // The @pages maybe filled at the second time.
> > > > 							      pages, gup_flags);
> > >
> > > Yes.  But they'll be in the same order.
> > >
> > > > BTW, I do not know why we mess up the page order. It maybe used in
> some special case.
> > >
> > > I'm not discounting the possibility that you've found a bug.
> > > But documenting that a bug exists is not the solution; the solution
> > > is fixing the bug.
> > I do not think it is a bug :)
> >
> > If we use the get_user_pages_unlocked(), DMA is okay, such as:
> >                      ....
> > 		     get_user_pages_unlocked()
> > 		     sg_alloc_table_from_pages()
> > 	             .....
> >
> > I think the comment is not accurate enough. So just add more comments,
> > and tell the driver users how to use the GUPs.
>=20
> gup_fast() and gup_unlocked() should return the pages in the same order.
> If they do not, then it is a bug.

Is there a reproducer for this?  Or do you have some debug output which sho=
ws this problem?

Ira

