Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FCC3C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 07:25:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25CA020874
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 07:25:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25CA020874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A90AF6B0006; Wed, 12 Jun 2019 03:25:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A18D16B000A; Wed, 12 Jun 2019 03:25:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 845336B0008; Wed, 12 Jun 2019 03:25:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A83F6B0005
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 03:25:37 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id b124so5106688oii.11
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 00:25:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=RyElY0AUtHjxRkXj3SVJtw6OYlhrn/m8A8wExscqmLU=;
        b=WNLA4otS6XriTuay7nlEWMaU4f4izVTlOKZw1NFrv4Ls8AY8fkS4gx1OJLpyPyLLyZ
         QYaEXy9/k/pK612QTIhegwDsBxR5Gis67xBi7oFrRxteaCjit7++AbnDwxQ4DQriiBR5
         +ip70dGrZnB5zuPzVCv4UsZDrelL/9ISylDC5eoPgWsQG6RcmK3dN8UN5DQMruVwRWSA
         KB5JOaabO/gkYuNQpsfJ/1zEDUWhLPiP/k3qEw1txjEBJVUaYUYGk4JUlWqCpwvaI5Ci
         m+ISFDVR959R5WG4AqNgC+KnCJLlXfhFSCEDeSClM3yKXUoD3oPYJrj5+IKT/SBuQWMd
         R3PQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAUhmczl5Oc2meYtNhtjaO2d3Jpk0o0zJKLFdvlQ5Y4yvXkK/k+r
	uCmPzlMoJ8PFxQToHjF5IZ4NGWBX/kqCx53W6z7HMGkWycC+e4+TYhPf1RDsEUyEUtKdAtWl01y
	cGPkVeGTBu6JlQ7OgmaLGqScnCwiAElPES+3N0CgalQngNOVF72H87sjP6gIK0zaZ1Q==
X-Received: by 2002:a05:6830:103:: with SMTP id i3mr29955280otp.219.1560324336944;
        Wed, 12 Jun 2019 00:25:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyugAGpccdUUolNkvG/V917tu0b4Np2Y4F0qNqKCNoveuvlOfpLQjNWoYnF9mzmOBw0p9NK
X-Received: by 2002:a05:6830:103:: with SMTP id i3mr29955252otp.219.1560324336273;
        Wed, 12 Jun 2019 00:25:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560324336; cv=none;
        d=google.com; s=arc-20160816;
        b=GCUUrGSYJJw7Ucol4wDSQyx84XL5SmyFiKs9zWyRVga8xuEWDbJDebGMJ1wsro4yT3
         dK96lFTMW5JCBh90mRs71dp5e9tuSyNtqsMdiRv5qLRNfL19oo2hoWGlSKUa2I6wIjaA
         QcGDBh+V/go9n+P5ac5s2yHKB7Ry4V713Go0o5HCc0P0LDJxzNAphofnuitT/srtKAcw
         JrSBFlwbShACFVKV+jy29W+IsM5XkML+3E6xjrWaTYKmbh7hhNBVR8jwoYmo3xCGepNO
         RavZNQSfv/4w5Dt0fJCKU7miaOBGc60goPQc1zy4NHfxfMG5NRjTsEFYERELau8fycfe
         cB+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=RyElY0AUtHjxRkXj3SVJtw6OYlhrn/m8A8wExscqmLU=;
        b=FQD3clnZ+aKfMEzO+GjMY4w+DcPBhaHTQJJtjo+jenU7zKb79Vf9d23Pe7vnQTUB/o
         wc/ErmdgnvlsHNmV3O/iTNWsB9M1HnHJDFJti3DxIHhAML3V1Kz6d5UpYgzGan0aUg4w
         zJmzxlTt9n7e27W4f+/dVQyfpvrsA0T6fH1dH5ySiAwD2jgf2+4pxwTuCD/pl9ZVOswR
         dLrV7xOVw+i2tSHwDZjBmnvOubHvduLXJCZwlzkhiC/fPrMGUlkmOoRaMhQfvZzsIOwg
         hrqID87opgIqcnoKXC7XGk7ysLCtu5m1ICowZx4dD5+EcQ0mCkIVGwbAbQqoOipWPQY8
         V5uA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 34si9275900oti.296.2019.06.12.00.25.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 00:25:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x5C7PHtx003180
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 12 Jun 2019 16:25:17 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x5C7PG92019680;
	Wed, 12 Jun 2019 16:25:17 +0900
Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x5C7PGFv022790;
	Wed, 12 Jun 2019 16:25:16 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.148] [10.38.151.148]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-5900495; Wed, 12 Jun 2019 16:24:18 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC20GP.gisp.nec.co.jp ([10.38.151.148]) with mapi id 14.03.0319.002; Wed,
 12 Jun 2019 16:24:17 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>,
        "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
        "Chen, Jerry T" <jerry.t.chen@intel.com>,
        "Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 2/2] mm: hugetlb: soft-offline:
 dissolve_free_huge_page() return zero on !PageHuge
Thread-Topic: [PATCH v2 2/2] mm: hugetlb: soft-offline:
 dissolve_free_huge_page() return zero on !PageHuge
Thread-Index: AQHVH2UOI3n3iV7mFEufJF8BQjmdkqaWHQeAgADtBAA=
Date: Wed, 12 Jun 2019 07:24:16 +0000
Message-ID: <20190612072422.GA28614@hori.linux.bs1.fc.nec.co.jp>
References: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560154686-18497-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <039dd97d-83f5-f71a-e78f-a451b0064903@oracle.com>
In-Reply-To: <039dd97d-83f5-f71a-e78f-a451b0064903@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <BCCB33A416C92644BE29C96ADEA07518@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 10:16:03AM -0700, Mike Kravetz wrote:
> On 6/10/19 1:18 AM, Naoya Horiguchi wrote:
> > madvise(MADV_SOFT_OFFLINE) often returns -EBUSY when calling soft offli=
ne
> > for hugepages with overcommitting enabled. That was caused by the subop=
timal
> > code in current soft-offline code. See the following part:
> >=20
> >     ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
> >                             MIGRATE_SYNC, MR_MEMORY_FAILURE);
> >     if (ret) {
> >             ...
> >     } else {
> >             /*
> >              * We set PG_hwpoison only when the migration source hugepa=
ge
> >              * was successfully dissolved, because otherwise hwpoisoned
> >              * hugepage remains on free hugepage list, then userspace w=
ill
> >              * find it as SIGBUS by allocation failure. That's not expe=
cted
> >              * in soft-offlining.
> >              */
> >             ret =3D dissolve_free_huge_page(page);
> >             if (!ret) {
> >                     if (set_hwpoison_free_buddy_page(page))
> >                             num_poisoned_pages_inc();
> >             }
> >     }
> >     return ret;
> >=20
> > Here dissolve_free_huge_page() returns -EBUSY if the migration source p=
age
> > was freed into buddy in migrate_pages(), but even in that case we actua=
lly
> > has a chance that set_hwpoison_free_buddy_page() succeeds. So that mean=
s
> > current code gives up offlining too early now.
> >=20
> > dissolve_free_huge_page() checks that a given hugepage is suitable for
> > dissolving, where we should return success for !PageHuge() case because
> > the given hugepage is considered as already dissolved.
> >=20
> > This change also affects other callers of dissolve_free_huge_page(),
> > which are cleaned up together.
> >=20
> > Reported-by: Chen, Jerry T <jerry.t.chen@intel.com>
> > Tested-by: Chen, Jerry T <jerry.t.chen@intel.com>
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
> > Cc: <stable@vger.kernel.org> # v4.19+
> > ---
> >  mm/hugetlb.c        | 15 +++++++++------
> >  mm/memory-failure.c |  5 +----
> >  2 files changed, 10 insertions(+), 10 deletions(-)
> >=20
> > diff --git v5.2-rc3/mm/hugetlb.c v5.2-rc3_patched/mm/hugetlb.c
> > index ac843d3..048d071 100644
> > --- v5.2-rc3/mm/hugetlb.c
> > +++ v5.2-rc3_patched/mm/hugetlb.c
> > @@ -1519,7 +1519,12 @@ int dissolve_free_huge_page(struct page *page)
>=20
> Please update the function description for dissolve_free_huge_page() as
> well.  It currently says, "Returns -EBUSY if the dissolution fails becaus=
e
> a give page is not a free hugepage" which is no longer true as a result o=
f
> this change.

Thanks for pointing out, I completely missed that.

>=20
> >  	int rc =3D -EBUSY;
> > =20
> >  	spin_lock(&hugetlb_lock);
> > -	if (PageHuge(page) && !page_count(page)) {
> > +	if (!PageHuge(page)) {
> > +		rc =3D 0;
> > +		goto out;
> > +	}
> > +
> > +	if (!page_count(page)) {
> >  		struct page *head =3D compound_head(page);
> >  		struct hstate *h =3D page_hstate(head);
> >  		int nid =3D page_to_nid(head);
> > @@ -1564,11 +1569,9 @@ int dissolve_free_huge_pages(unsigned long start=
_pfn, unsigned long end_pfn)
> > =20
> >  	for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1 << minimum_order) {
> >  		page =3D pfn_to_page(pfn);
> > -		if (PageHuge(page) && !page_count(page)) {
> > -			rc =3D dissolve_free_huge_page(page);
> > -			if (rc)
> > -				break;
> > -		}
>=20
> We may want to consider keeping at least the PageHuge(page) check before
> calling dissolve_free_huge_page().  dissolve_free_huge_pages is called as
> part of memory offline processing.  We do not know if the memory to be of=
flined
> contains huge pages or not.  With your changes, we are taking hugetlb_loc=
k
> on each call to dissolve_free_huge_page just to discover that the page is
> not a huge page.
>=20
> You 'could' add a PageHuge(page) check to dissolve_free_huge_page before
> taking the lock.  However, you would need to check again after taking the
> lock.

Right, I'll do this.

What was in my mind when writing this was that I actually don't like
PageHuge because it's slow (not inlined) and called anywhere in mm code,
so I like to reduce it if possible.
But I now see that dissolve_free_huge_page() are relatively rare event
rather than hugepage allocation/free, so dissolve_free_huge_page should tak=
e
burden to precheck PageHuge instead of speculatively taking hugetlb_lock
and disrupting the hot path.

Thanks,
- Naoya=

