Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47AFCC41514
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:15:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 172F0214C6
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:15:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 172F0214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A19786B0003; Fri,  9 Aug 2019 14:15:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C9C06B0007; Fri,  9 Aug 2019 14:15:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86ABC6B000C; Fri,  9 Aug 2019 14:15:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8536B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 14:15:02 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x10so2257189pfn.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 11:15:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=en3CzdQagzFz7YO+P1ff0kJGEuG8d3EEdzFsbU/my7k=;
        b=G0wpNYxti20jBtH2jXXE95okBsqhniYf4mqzCenQlJ7SX8wWabg/+gZ2ybVCy7EmBG
         JND5tIE1WjW9CciaK6dxz/IOlNQhjFA+ZVhslahWKn9hzbQ5gKUCWjDvwZcAXViwchfh
         axP39t5GijLJmi0dQ6iWJPyRcgQP56SzjPpm7EHtRf94ivg5z7Th131o1FbXDspqWpfy
         F4rFLOi7A3wJaW5AHwL9vGRxQO/19AGU4G9HrroeUlCxvJOOSQFMx8QwjcvgVSnzM+Nd
         T0uwUQpUME7+zBlcJXBr0tdf0NhONNDTXwS7H9oXH3Bnaus8E37aS+jVp6bzvPXhM1jB
         10kQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVc5NsFPeF5uIhwUxPhWKk23tIffeMwe6nnGLBwGjPxGad3JgrZ
	tcZvXCfuUcoPbgY5ys9xNs1v7X/RgvNGOYW5/eO3aARA5bvKlBy4jOdLQr0A5SQUCayKhZAsxzs
	pHUsLJXgeuyzTPE2euTmeuJ1DhRyXb+Mb+/172WsoO1OWWoW7b3RBc2GLTWLF2BOFag==
X-Received: by 2002:a17:90a:d996:: with SMTP id d22mr10751944pjv.86.1565374501951;
        Fri, 09 Aug 2019 11:15:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsvtaS444E+f0nadzPogH3RwZB689HThhlpt8zXGriXlahbG2+qmda2A9Iao7yuAlskrSU
X-Received: by 2002:a17:90a:d996:: with SMTP id d22mr10751886pjv.86.1565374500991;
        Fri, 09 Aug 2019 11:15:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565374500; cv=none;
        d=google.com; s=arc-20160816;
        b=EhZUZjZC4o4pkhbTs1nOP9knAJTtTf5sFajIdbX/RVBBLxXZOzrCKWatx/smimUnTC
         n3zDBuiipLZfbn20gcs6z9avLRLmc7/g4XNfGap/psLc/C5AdT4XYsnqwmETPOCPbf1L
         y3+cTnBdkRuBh6VqvvJ1GpELDZG88oDuOyZlBe5k8p6UpAMnMyOIoNwwIKZ3D3i/RTi/
         noceDRrkRRQ/7KgKX8bXnUcErB9YTHItRBm4hv7fqSW0cWyHBmSpn0Y1rKsWrqhoB0z8
         y8oSJajhddVQvg2fED5bMiLwqXH3TEihzY81t5nu2mPyhRcn5HEvZ6Q15k9tZy4PZr4Z
         DrVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=en3CzdQagzFz7YO+P1ff0kJGEuG8d3EEdzFsbU/my7k=;
        b=DG8lBWyTEKn5sNo6lg09EuqFrjTZHEvNBc5qcbP4JZYdud9JzoMgWl5KN1E3m571kv
         QCXFJGwTL/l6fGbnpOyYOZZhyKkLc55lP3C25belXn9UGSOCBY0MhryphqY/6myLiHFm
         dvVWSaFC6zmOwzvhv9kiwrw0Wwljpw7W9N/kkz/uiJVMYtpTuBobfmaUrcn80PVNE4lN
         jYpZOevUrgoJlUAXQpdFm8aSHR18YmZr2fH8QQjVUUzO1UNdiWpASPbnxAEW3MXNGeJv
         zOAKG9rERb6thi315JbNDxagTGqHj8+qVMPQwPZYUWwOU7uYpP6PX2TtSx/dVf0Tvo9g
         PUdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x130si60051123pgx.526.2019.08.09.11.15.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 11:15:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 11:15:00 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,366,1559545200"; 
   d="scan'208";a="180209320"
Received: from fmsmsx106.amr.corp.intel.com ([10.18.124.204])
  by orsmga006.jf.intel.com with ESMTP; 09 Aug 2019 11:14:59 -0700
Received: from fmsmsx161.amr.corp.intel.com (10.18.125.9) by
 FMSMSX106.amr.corp.intel.com (10.18.124.204) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Fri, 9 Aug 2019 11:14:59 -0700
Received: from crsmsx152.amr.corp.intel.com (172.18.7.35) by
 FMSMSX161.amr.corp.intel.com (10.18.125.9) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Fri, 9 Aug 2019 11:14:58 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.115]) by
 CRSMSX152.amr.corp.intel.com ([169.254.5.138]) with mapi id 14.03.0439.000;
 Fri, 9 Aug 2019 12:14:56 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>
CC: John Hubbard <jhubbard@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse
	<jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, "Williams, Dan J"
	<dan.j.williams@intel.com>, Daniel Black <daniel@linux.ibm.com>, "Matthew
 Wilcox" <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>
Subject: RE: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
Thread-Topic: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
Thread-Index: AQHVS9wAqKeuPoXzZkyLXp0tqoyMNKbv6+CAgADRpQCAAHJ+gIAAUE4AgACJIACAAD05gIAAmqkAgAAC4oCAAF2ggIAAQV0A//+ec3A=
Date: Fri, 9 Aug 2019 18:14:56 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79E7F3E7@CRSMSX101.amr.corp.intel.com>
References: <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
 <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
 <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
 <420a5039-a79c-3872-38ea-807cedca3b8a@suse.cz>
 <20190809082307.GL18351@dhcp22.suse.cz>
 <20190809135813.GF17568@quack2.suse.cz>
 <20190809175210.GR18351@dhcp22.suse.cz>
In-Reply-To: <20190809175210.GR18351@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiMzllYmM1OGYtMTcyOS00MGM5LWJhMmMtNWU1NmE2YjQ4ZGJmIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiRnhqSFY1Z1NibnZacG1oTUhVT25EaDNENWcxZzJTbVlTaGlyQXF6Z2lSdXNEQmtDR1JLOXJVcFZYN1NqaHFtViJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.2.0.6
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

> On Fri 09-08-19 15:58:13, Jan Kara wrote:
> > On Fri 09-08-19 10:23:07, Michal Hocko wrote:
> > > On Fri 09-08-19 10:12:48, Vlastimil Babka wrote:
> > > > On 8/9/19 12:59 AM, John Hubbard wrote:
> > > > >>> That's true. However, I'm not sure munlocking is where the
> > > > >>> put_user_page() machinery is intended to be used anyway? These
> > > > >>> are short-term pins for struct page manipulation, not e.g.
> > > > >>> dirtying of page contents. Reading commit fc1d8e7cca2d I don't
> > > > >>> think this case falls within the reasoning there. Perhaps not
> > > > >>> all GUP users should be converted to the planned separate GUP
> > > > >>> tracking, and instead we should have a GUP/follow_page_mask()
> variant that keeps using get_page/put_page?
> > > > >>>
> > > > >>
> > > > >> Interesting. So far, the approach has been to get all the gup
> > > > >> callers to release via put_user_page(), but if we add in Jan's
> > > > >> and Ira's vaddr_pin_pages() wrapper, then maybe we could leave
> some sites unconverted.
> > > > >>
> > > > >> However, in order to do so, we would have to change things so
> > > > >> that we have one set of APIs (gup) that do *not* increment a
> > > > >> pin count, and another set
> > > > >> (vaddr_pin_pages) that do.
> > > > >>
> > > > >> Is that where we want to go...?
> > > > >>
> > > >
> > > > We already have a FOLL_LONGTERM flag, isn't that somehow related?
> > > > And if it's not exactly the same thing, perhaps a new gup flag to
> > > > distinguish which kind of pinning to use?
> > >
> > > Agreed. This is a shiny example how forcing all existing gup users
> > > into the new scheme is subotimal at best. Not the mention the overal
> > > fragility mention elsewhere. I dislike the conversion even more now.
> > >
> > > Sorry if this was already discussed already but why the new pinning
> > > is not bound to FOLL_LONGTERM (ideally hidden by an interface so
> > > that users do not have to care about the flag) only?
> >
> > The new tracking cannot be bound to FOLL_LONGTERM. Anything that gets
> > page reference and then touches page data (e.g. direct IO) needs the
> > new kind of tracking so that filesystem knows someone is messing with t=
he
> page data.
> > So what John is trying to address is a different (although related)
> > problem to someone pinning a page for a long time.
>=20
> OK, I see. Thanks for the clarification.

Not to beat a dead horse but FOLL_LONGTERM also has implications now for CM=
A pages which may or may not (I'm not an expert on those pages) need specia=
l tracking.=20

>=20
> > In principle, I'm not strongly opposed to a new FOLL flag to determine
> > whether a pin or an ordinary page reference will be acquired at least
> > as an internal implementation detail inside mm/gup.c. But I would
> > really like to discourage new GUP users taking just page reference as
> > the most clueless users (drivers) usually need a pin in the sense John
> > implements. So in terms of API I'd strongly prefer to deprecate GUP as
> > an API, provide
> > vaddr_pin_pages() for drivers to get their buffer pages pinned and
> > then for those few users who really know what they are doing (and who
> > are not interested in page contents) we can have APIs like
> > follow_page() to get a page reference from a virtual address.
>=20
> Yes, going with a dedicated API sounds much better to me. Whether a
> dedicated FOLL flag is used internally is not that important. I am also f=
or
> making the underlying gup to be really internal to the core kernel.

+1

I think GUP is too confusing.  I've been working with the details for many =
months now and it continues to confuse me.  :-(

My patches should be posted soon (based on mmotm) and I'll have my flame su=
it on so we can debate the interface.

Ira

