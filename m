Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70C45C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 07:25:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33B8F208CB
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 07:25:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33B8F208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E13036B0005; Wed, 12 Jun 2019 03:25:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9C266B0008; Wed, 12 Jun 2019 03:25:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8E6F6B0005; Wed, 12 Jun 2019 03:25:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 701186B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 03:25:37 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id x18so5880458otp.9
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 00:25:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=ANKqKlaoqjDCl5qahcXh0RE6F0ULJtUJ05QLKLU1OZM=;
        b=BiMd204a1HWEGZIQQiLQpNLevAT649kVOUm4nrI0Y+Q32XijakEXx2RNI59Zxe00pU
         ToiRI6csstMLAD7GwanYBWg4unRu/wZb8lgkcBTNVkBfYu/McgR6xwARGqPDN7pqfu/P
         DDe1w/1bsvdBre2zJjuT6VjtvrDSo3W6+oS+TQdpH+fCUslclAM69Kd48PD2rN8+dO7v
         +bU00geWz3H9SC2qcTPa+5bcViHyfcoJ+y/LobLB76NaJ7Uv/Pd27RNMaGW6QSpM5Nzy
         iUF77d1V5eJEpkD95KwjHzUhBmlqFOnzrB3upUKIxFj3Nly/UPV0IoyoT+p5GWjpBKd0
         smvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAV+2NMPIq3g0/7H+UbbMDr5WBmvgdLpQDWCB98q4zpRI81jbDEJ
	8luTW9ySEv7vWFpN4jD6ZsjpPDRjjRIXMy6C8Y/x4KiDG21VdMDdik0D6C7pztYOqW9cZatHj6U
	14vJF7sGn8wuvLLct9/jmHT8qhIwCa1pmXAjXfSFh7D/tEZUBgmOSv+BS+uQFyTa91A==
X-Received: by 2002:a05:6830:144e:: with SMTP id w14mr25490551otp.10.1560324337138;
        Wed, 12 Jun 2019 00:25:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQMul1q8ycJZy7YMrWmUl4sXXG785rXiqAKUCNJD0MRWeGUhZOiBVLm52gK0JFRkcocp8Q
X-Received: by 2002:a05:6830:144e:: with SMTP id w14mr25490527otp.10.1560324336514;
        Wed, 12 Jun 2019 00:25:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560324336; cv=none;
        d=google.com; s=arc-20160816;
        b=jmjmb/0diyUdlYzUbEG019+HBNhLrf74dhMk5kHJnYPJbq+zmz2hpfgAtYouK/OtWz
         4oKlogtg8ednihVwVEkaTv4E8Pym+IkkKaUjUfhLKnjeGdzwtejHc2eqIbsTVIYzUfkI
         6J9fddzUnOv8xdD/B6ICncUyj9BcGb0OXikzxq2AH0RiBE8tcj0AcBmuruxecRZooS4r
         EvCRaejD0kSn5ogH/KK7KinboSrh3NqJOM1CR3HmrQZS1aA+jbyastt/DADRx4SbhwWm
         yldiRuqrNhdY9TCsf2qaL9UBdqzR/N1G/k41Tu7SmslZdSCJv58UFR1jQAnWR8OFaxfi
         N7gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=ANKqKlaoqjDCl5qahcXh0RE6F0ULJtUJ05QLKLU1OZM=;
        b=tsp/FR1IjQtrERCVJ6lVbchKvXNJC5wi3k8anpY76129SEi5q8GhdahFDClUVwqKnG
         0pYCYyzAT8UFrksCF9eD3ythfsBMISPk2eD5LeTY/B+t0UJs0D1OtsIeF0BLmsOz3CsG
         picsqVzD9qvTMQxm8NBB9S2SJX3P9oufNwmAjIH/I3yakqTjgUGLHngowHTy2ZsUG+Aq
         qFB1GK1DbX2nDT/9Kag1Yq4vvvt+MT32ElhRNWfU7Tjmo5uF31OphdUgWWJfeh4fEG+i
         7tY5b7t9uNEMBv44d0kdDCAzWYh2hY65QgLOwAAAO0kobknkauXMfLE4qWfdd3vriabE
         2DSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id 62si9621120ota.263.2019.06.12.00.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 00:25:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x5C7PHkF003196
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 12 Jun 2019 16:25:17 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x5C7PHli001893;
	Wed, 12 Jun 2019 16:25:17 +0900
Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x5C7N0Oo021490;
	Wed, 12 Jun 2019 16:25:17 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.150] [10.38.151.150]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-1234399; Wed, 12 Jun 2019 16:09:34 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC22GP.gisp.nec.co.jp ([10.38.151.150]) with mapi id 14.03.0319.002; Wed,
 12 Jun 2019 16:09:34 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
        "Chen, Jerry T" <jerry.t.chen@intel.com>,
        "Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 2/2] mm: hugetlb: soft-offline:
 dissolve_free_huge_page() return zero on !PageHuge
Thread-Topic: [PATCH v2 2/2] mm: hugetlb: soft-offline:
 dissolve_free_huge_page() return zero on !PageHuge
Thread-Index: AQHVH2UOI3n3iV7mFEufJF8BQjmdkqaVoIYAgAFlaYA=
Date: Wed, 12 Jun 2019 07:09:32 +0000
Message-ID: <20190612070939.GA25452@hori.linux.bs1.fc.nec.co.jp>
References: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560154686-18497-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <4a1ea5f4-d35d-f3a6-920c-c35520234aa3@arm.com>
In-Reply-To: <4a1ea5f4-d35d-f3a6-920c-c35520234aa3@arm.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <1DD66F49A3CF854696A42373F9F2F2E2@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 03:20:26PM +0530, Anshuman Khandual wrote:
>=20
> On 06/10/2019 01:48 PM, Naoya Horiguchi wrote:
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
>=20
> Over committed source pages will be released into buddy and the normal on=
es
> will not be ? dissolve_free_huge_page() returns -EBUSY because PageHuge()
> return negative on already released pages ?=20

The answers for both questions here are yes.

> How dissolve_free_huge_page()
> will behave differently with over committed pages. I might be missing som=
e
> recent developments here.

This dissolve_free_huge_page() should see a (free or reused) 4kB page when
overcommitting, and should see a (free or reused) huge page for non
overcommitting case.

>=20
> > has a chance that set_hwpoison_free_buddy_page() succeeds. So that mean=
s
> > current code gives up offlining too early now.
>=20
> Hmm. It gives up early as the return value from dissolve_free_huge_page(E=
BUSY)
> gets back as the return code for soft_offline_huge_page() without attempt=
ing
> set_hwpoison_free_buddy_page() which still has a chance to succeed for fr=
eed
> normal buddy pages.

Exactly.

>=20
> >=20
> > dissolve_free_huge_page() checks that a given hugepage is suitable for
> > dissolving, where we should return success for !PageHuge() case because
> > the given hugepage is considered as already dissolved.
>=20
> Right. It should return 0 (as a success) for freed normal buddy pages. Sh=
ould
> not it then check explicitly for PageBuddy() as well ?

in new semantics, dissolve_free_huge_page() returns:

  0: successfully dissolved free hugepages or the page is already dissolved
  EBUSY: failed to dissolved free hugepages or the hugepage is in-use.

so for any types of non hugepages, the return value is 0.

Thanks,
- Naoya=20

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
> >  	int rc =3D -EBUSY;
> > =20
> >  	spin_lock(&hugetlb_lock);
> > -	if (PageHuge(page) && !page_count(page)) {
> > +	if (!PageHuge(page)) {
> > +		rc =3D 0;
> > +		goto out;
> > +	}
>=20
> With this early bail out it maintains the functionality when called from
> soft_offline_free_page() for normal pages. For huge page, it continues
> on the previous path.
>=20
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
>=20
> Right. These checks are now redundant.
> =

