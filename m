Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2964AC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 07:34:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8DA021924
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 07:34:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8DA021924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E45F8E007F; Fri,  8 Feb 2019 02:34:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 593778E0002; Fri,  8 Feb 2019 02:34:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4813A8E007F; Fri,  8 Feb 2019 02:34:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA698E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 02:34:23 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id i12so4660041ita.3
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 23:34:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=TP/ZdWLV3uHTpeHGe8L0Vs/n5Fc4dXBmETwsOGZFyeI=;
        b=dnt4EqJpu65/uEOi12AFm59u0kEkixZqrqqe78r3VAZffXwKqKVCHGhJeK4fGOKGKc
         ZjDGwp6fq+/lMXrA/+FERTFOh9C7BIPcQHsD79Rrw9sMcj6T5xNj6Xo6xJxyioqyOScp
         B0XAoCFXJC45vLiE9Rm8RZtsXOok/VP818HDuOuMcYztQe4zmPKnBZCTpKiQJo6kpOut
         W6qtrP1LLWhP0IJVgfoS4IJEqQKQpAhT/WI1E2VsCYTvhDVPoSxkUq+A2Kz8LnxyY16Z
         FM+sXrU0lXIEOq89fJYMC+oWQAUP8DElRto7jxp5ILFHpjQh+sMsbrHF8yApysFckyoj
         czcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: AHQUAubExhbzjpGcmVzNx9yGFyE1LmSY0Gdz3rYdTkAFgLAySsBFIbGH
	1dXb81YnMs6tc+YqOSeqmUx7ajVv1fO8JHmklGjZnbtnRTk740f2dQAMz0vO5dAeJ1lap0INOWc
	og+oA8bvN15NfNBy6HLJmGuN/Bw24pFISSCXdYKIfQOJpjS6m6/W0bVs2G7v5Del6/A==
X-Received: by 2002:a24:3dca:: with SMTP id n193mr8433598itn.48.1549611262830;
        Thu, 07 Feb 2019 23:34:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYdkJWGudLWP+6PBSQ9dtcjdqrpX2StXbDQgl4nDowhnYN6bdvjqnw0PgKxoixVU0FHSveX
X-Received: by 2002:a24:3dca:: with SMTP id n193mr8433575itn.48.1549611262003;
        Thu, 07 Feb 2019 23:34:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549611261; cv=none;
        d=google.com; s=arc-20160816;
        b=ZOMPDWfZaTlmim7m1UjxMo5RxM1UDus/DxNHpCaIMI/Cn/lV58/o6ypprb49FY2zv3
         RLWv5PC9X4YJDH7zYDJKPG39v40pU2akCrgn5orz0WB6bR/O+FnBtENxVvAo39M+uUU8
         q94+ZDNhxihLXgpOTEPzAdtFgL3HxioONfzGDh695jAxZZaM4s3PHV+hPpLj0N5h7wHn
         oTOQZXL3+YJ7iDd7stdxe/tG1Y714vl+NYLwiRZv7N/MOTfkzQoPYWAnUJDjecCH7+Vd
         9FxpbmSdmksjLcn8hdI5f8CBKCMSBW2aVMXUcw3qhCq2m1B6+BqOgHkC0kOCs23WGLq1
         OozA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=TP/ZdWLV3uHTpeHGe8L0Vs/n5Fc4dXBmETwsOGZFyeI=;
        b=f5HarbbhqylNG1SsbO5C5lmOOWG2/iuQCv9dv7RdHQKkviJHc59NutEbvVWcAqAZSK
         zCWyhx/TEamnGVR91mG0m/uEEONoHVMoKQOF5LtJ6hFyb4Jq/mDI+3Lc66Y8/keyvCIZ
         wi8+y374vxMuEdjg8wSFEDyH0BQ1obzSWY7oVvihGTlXSvISKqaJmVJ2FZFE32LNgsmK
         vsN6lMsdZ3xpYy0hJomwfuNvabLpu4IJrNc8YHTby2epTVqOllPKqqjv3kNGqrhcLDt8
         jfA2UyZqGZUUYJUjJXjNGeHmNXZWIFVLcoudmd1cSk85xe3wVeBAgV4cQK4Nu/aWo9mv
         BcOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id l62si1102991itl.108.2019.02.07.23.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 23:34:21 -0800 (PST)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x187YEIQ004889
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Fri, 8 Feb 2019 16:34:14 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x187YEHs004312;
	Fri, 8 Feb 2019 16:34:14 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x187Wdv1024689;
	Fri, 8 Feb 2019 16:34:14 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.148] [10.38.151.148]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-2250485; Fri, 8 Feb 2019 16:31:51 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC20GP.gisp.nec.co.jp ([10.38.151.148]) with mapi id 14.03.0319.002; Fri, 8
 Feb 2019 16:31:50 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        "Andrea Arcangeli" <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH] huegtlbfs: fix page leak during migration of file pages
Thread-Topic: [PATCH] huegtlbfs: fix page leak during migration of file pages
Thread-Index: AQHUuODePgsnC0Y0+kCvHMlE24frN6XUI3qAgACAsgCAADeYAIAAHE6A
Date: Fri, 8 Feb 2019 07:31:49 +0000
Message-ID: <20190208073149.GA14423@hori1.linux.bs1.fc.nec.co.jp>
References: <20190130211443.16678-1-mike.kravetz@oracle.com>
 <917e7673-051b-e475-8711-ed012cff4c44@oracle.com>
 <20190208023132.GA25778@hori1.linux.bs1.fc.nec.co.jp>
 <07ce373a-d9ea-f3d3-35cc-5bc181901caf@oracle.com>
In-Reply-To: <07ce373a-d9ea-f3d3-35cc-5bc181901caf@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.51.8.80]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B452139787547842A7CC02450396F598@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07, 2019 at 09:50:30PM -0800, Mike Kravetz wrote:
> On 2/7/19 6:31 PM, Naoya Horiguchi wrote:
> > On Thu, Feb 07, 2019 at 10:50:55AM -0800, Mike Kravetz wrote:
> >> On 1/30/19 1:14 PM, Mike Kravetz wrote:
> >>> +++ b/fs/hugetlbfs/inode.c
> >>> @@ -859,6 +859,16 @@ static int hugetlbfs_migrate_page(struct address=
_space *mapping,
> >>>  	rc =3D migrate_huge_page_move_mapping(mapping, newpage, page);
> >>>  	if (rc !=3D MIGRATEPAGE_SUCCESS)
> >>>  		return rc;
> >>> +
> >>> +	/*
> >>> +	 * page_private is subpool pointer in hugetlb pages, transfer
> >>> +	 * if needed.
> >>> +	 */
> >>> +	if (page_private(page) && !page_private(newpage)) {
> >>> +		set_page_private(newpage, page_private(page));
> >>> +		set_page_private(page, 0);
> >=20
> > You don't have to copy PagePrivate flag?
> >=20
>=20
> Well my original thought was no.  For hugetlb pages, PagePrivate is not
> associated with page_private.  It indicates a reservation was consumed.
> It is set  when a hugetlb page is newly allocated and the allocation is
> associated with a reservation and the global reservation count is
> decremented.  When the page is added to the page cache or rmap,
> PagePrivate is cleared.  If the page is free'ed before being added to pag=
e
> cache or rmap, PagePrivate tells free_huge_page to restore (increment) th=
e
> reserve count as we did not 'instantiate' the page.
>=20
> So, PagePrivate is only set from the time a huge page is allocated until
> it is added to page cache or rmap.  My original thought was that the page
> could not be migrated during this time.  However, I am not sure if that
> reasoning is correct.  The page is not locked, so it would appear that it
> could be migrated?  But, if it can be migrated at this time then perhaps
> there are bigger issues for the (hugetlb) page fault code?

In my understanding, free hugetlb pages are not expected to be passed to
migrate_pages(), and currently that's ensured by each migration caller
which checks and avoids free hugetlb pages on its own.
migrate_pages() and its internal code are probably not aware of handling
free hugetlb pages, so if they are accidentally passed to migration code,
that's a big problem as you are concerned.
So the above reasoning should work at least this assumption is correct.

Most of migration callers are not intersted in moving free hugepages.
The one I'm not sure of is the code path from alloc_contig_range().
If someone think it's worthwhile to migrate free hugepage to get bigger
contiguous memory, he/she tries to enable that code path and the assumption
will be broken.

Thanks,
Naoya Horiguchi

>=20
> >>> +
> >>> +	}
> >>> +
> >>>  	if (mode !=3D MIGRATE_SYNC_NO_COPY)
> >>>  		migrate_page_copy(newpage, page);
> >>>  	else
> >>> diff --git a/mm/migrate.c b/mm/migrate.c
> >>> index f7e4bfdc13b7..0d9708803553 100644
> >>> --- a/mm/migrate.c
> >>> +++ b/mm/migrate.c
> >>> @@ -703,8 +703,14 @@ void migrate_page_states(struct page *newpage, s=
truct page *page)
> >>>  	 */
> >>>  	if (PageSwapCache(page))
> >>>  		ClearPageSwapCache(page);
> >>> -	ClearPagePrivate(page);
> >>> -	set_page_private(page, 0);
> >>> +	/*
> >>> +	 * Unlikely, but PagePrivate and page_private could potentially
> >>> +	 * contain information needed at hugetlb free page time.
> >>> +	 */
> >>> +	if (!PageHuge(page)) {
> >>> +		ClearPagePrivate(page);
> >>> +		set_page_private(page, 0);
> >>> +	}
> >=20
> > # This argument is mainly for existing code...
> >=20
> > According to the comment on migrate_page():
> >=20
> >     /*
> >      * Common logic to directly migrate a single LRU page suitable for
> >      * pages that do not use PagePrivate/PagePrivate2.
> >      *
> >      * Pages are locked upon entry and exit.
> >      */
> >     int migrate_page(struct address_space *mapping, ...
> >=20
> > So this common logic assumes that page_private is not used, so why do
> > we explicitly clear page_private in migrate_page_states()?
>=20
> Perhaps someone else knows.  If not, I can do some git research and
> try to find out why.
>=20
> > buffer_migrate_page(), which is commonly used for the case when
> > page_private is used, does that clearing outside migrate_page_states().
> > So I thought that hugetlbfs_migrate_page() could do in the similar mann=
er.
> > IOW, migrate_page_states() should not do anything on PagePrivate.
> > But there're a few other .migratepage callbacks, and I'm not sure all o=
f
> > them are safe for the change, so this approach might not fit for a smal=
l fix.
>=20
> I will look at those as well unless someone knows without researching.
>=20
> >=20
> > # BTW, there seems a typo in $SUBJECT.
>=20
> Thanks!
>=20
> --=20
> Mike Kravetz
> =

