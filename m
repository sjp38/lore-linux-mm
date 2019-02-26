Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9130C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:45:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91F302173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:45:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91F302173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 415938E0005; Tue, 26 Feb 2019 02:45:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39BCE8E0002; Tue, 26 Feb 2019 02:45:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 264B28E0005; Tue, 26 Feb 2019 02:45:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id F01418E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:45:55 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id i63so1381844itb.0
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 23:45:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=ZWNJSDMRI9Fcfp0pUzI8LunQaHKMjQ4ESGPK1xATbt0=;
        b=Ko/x4thIZvMlL2AvBmozhy1RkktdLr35d6Rukoj8grkcA3VNBBmSfpq6hseLG3ejUh
         HAX4glTH06Nv3Mnb8Jy/8AVy3n4mo8vbJC5V8R3lZErZnYFQ0es+MFZh21CJMr4CLRmf
         4K4cFxjoFaMnEQAegPhXOHYJ0N5oD6Ydm2FvqWcykgQg1mATneE30IZVWKmQItM38vDx
         EDNdLS2ALgPwoThn563c8W024Zb2fUOBFwVRx7nWWhE1UZK9Rq4lGACPX9ljP71lDRjb
         V1mA0Rkp21o7s6b5Uuu6pFw5sGPy8T/9PFo93QwUjqgr6ZjYTrOUFYTt/ynPEM4yRvgs
         IubQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: AHQUAuZS6wxmtuBvx7XYc0i/J1EcGa5shF9Axp2bVBsMC1Iriiy3zApY
	NksoxLGmldT9uRHaEIlWCuW1A+NROGxMR6FT0cmL+mY/hQH/usnPIxvSki9Z+1Mp08g6lLoRWqO
	0ddN7NMDledcdhRD+cJw/JfiyThZX8O5SpqHoZH9Tq/zVLJJUtS1+ldk6MHsybviQWg==
X-Received: by 2002:a6b:ee02:: with SMTP id i2mr11292635ioh.294.1551167155595;
        Mon, 25 Feb 2019 23:45:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia1vt7c4QOAh1Q3cRno8R8aWU3ukGxGyxiZi9YZMmZWu+DTW3qyAF+Nm389wbNwy886B+8h
X-Received: by 2002:a6b:ee02:: with SMTP id i2mr11292611ioh.294.1551167154634;
        Mon, 25 Feb 2019 23:45:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551167154; cv=none;
        d=google.com; s=arc-20160816;
        b=waNb4TbeG580RBSAakHWmtfezjF8ICi6rAqPYLDTY5G+skqe3NSmCD4+4pO83pBPuT
         cjspoblCeChRnnfkik+umm9Jod2B9wrZW5Q/qCHXbrgSogxomVqOZ6XzArVHTA13UkdQ
         jGxHuEFVtDE4KL5rzyzhh5+qqC/re0K8tTN9p5uOxM0O9H/bCdqaAzVFiucxm73g+jzP
         qD37m2V9FRR+VKEM86qkgiaQ176mj63tjKC3e+GZhDVHIihBdeZoE1bwSYS61hK3h9of
         Xc1eUlYef536qhHyDSudkkUVnXcCc4SEz3qTxVDLaBlZ9LDYJNGwvIB7dRcuLd+6Hu1p
         C7og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=ZWNJSDMRI9Fcfp0pUzI8LunQaHKMjQ4ESGPK1xATbt0=;
        b=0A7PTJ0bEsT0SF8fuIyS408eumtSD0U9TQTX8ZQcZsrfAkYms7mWfAkRAqMQ8Lqccg
         ts9bK+60oyTOw6blnxevcSaO67kRY+H9ue1FWYbjImOMGc/Bmx/Yn+wneebgsxXtUqT5
         Sp3qAaug6mm7FW3vs6FMzEv+30ikV3BFH3F/j95oKbYXfjXap16N8EMLr7ZDM1olb7Vh
         gDPkokf/+1b3pldTSO3Msi+3/QShGetPnS//uv6dscThvv89W1f9U23ry+yLrVDSp9E3
         I6mJI6gYhpijTe34FwO0/64/j3LpND/sWeNa4JQnA05Ehc2onKr8w4TMxz65Lu27lxWW
         ewWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id m1si5598607iob.66.2019.02.25.23.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 23:45:54 -0800 (PST)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x1Q7jmwV005697
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 26 Feb 2019 16:45:48 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x1Q7jmtT029610;
	Tue, 26 Feb 2019 16:45:48 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x1Q7ih5j000771;
	Tue, 26 Feb 2019 16:45:48 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.149] [10.38.151.149]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-2803189; Tue, 26 Feb 2019 16:44:33 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC21GP.gisp.nec.co.jp ([10.38.151.149]) with mapi id 14.03.0319.002; Tue,
 26 Feb 2019 16:44:32 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        "Andrea Arcangeli" <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Davidlohr Bueso <dave@stgolabs.net>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH] huegtlbfs: fix races and page leaks during migration
Thread-Topic: [PATCH] huegtlbfs: fix races and page leaks during migration
Thread-Index: AQHUwyBJmVUOEJ5O6kyjIcjA4cDr6qXpOssAgADaeACABxvTAA==
Date: Tue, 26 Feb 2019 07:44:30 +0000
Message-ID: <20190226074430.GA17606@hori.linux.bs1.fc.nec.co.jp>
References: <803d2349-8911-0b47-bc5b-4f2c6cc3f928@oracle.com>
 <20190212221400.3512-1-mike.kravetz@oracle.com>
 <20190220220910.265bff9a7695540ee4121b80@linux-foundation.org>
 <7534d322-d782-8ac6-1c8d-a8dc380eb3ab@oracle.com>
In-Reply-To: <7534d322-d782-8ac6-1c8d-a8dc380eb3ab@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.96]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <65A50E881456134CB6F21FD9C68E3C32@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

On Thu, Feb 21, 2019 at 11:11:06AM -0800, Mike Kravetz wrote:
> On 2/20/19 10:09 PM, Andrew Morton wrote:
> > On Tue, 12 Feb 2019 14:14:00 -0800 Mike Kravetz <mike.kravetz@oracle.co=
m> wrote:
> >> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> >> index a80832487981..f859e319e3eb 100644
> >> --- a/mm/hugetlb.c
> >> +++ b/mm/hugetlb.c

...

> >> @@ -3863,6 +3862,10 @@ static vm_fault_t hugetlb_no_page(struct mm_str=
uct *mm,
> >>  	}
> >> =20
> >>  	spin_unlock(ptl);
> >> +
> >> +	/* May already be set if not newly allocated page */
> >> +	set_page_huge_active(page);
> >> +
>=20
> This is wrong.  We need to only set_page_huge_active() for newly allocate=
d
> pages.  Why?  We could have got the page from the pagecache, and it could
> be that the page is !page_huge_active() because it has been isolated for
> migration.  Therefore, we do not want to set it active here.
>=20
> I have also found another race with migration when removing a page from
> a file.  When a huge page is removed from the pagecache, the page_mapping=
()
> field is cleared yet page_private continues to point to the subpool until
> the page is actually freed by free_huge_page().  free_huge_page is what
> adjusts the counts for the subpool.  A page could be migrated while in th=
is
> state.  However, since page_mapping() is not set the hugetlbfs specific
> routine to transfer page_private is not called and we leak the page count
> in the filesystem.  To fix, check for this condition before migrating a h=
uge
> page.  If the condition is detected, return EBUSY for the page.
>=20
> Both issues are addressed in the updated patch below.
>=20
> Sorry for the churn.  As I find and fix one issue I seem to discover anot=
her.
> There is still at least one more issue with private pages when COW comes =
into
> play.  I continue to work that.  I wanted to send this patch earlier as i=
t
> is pretty easy to hit the bugs if you try.  If you would prefer another
> approach, let me know.
>=20
> From: Mike Kravetz <mike.kravetz@oracle.com>
> Date: Thu, 21 Feb 2019 11:01:04 -0800
> Subject: [PATCH] huegtlbfs: fix races and page leaks during migration

Subject still contains a typo.

>=20
> hugetlb pages should only be migrated if they are 'active'.  The routines
> set/clear_page_huge_active() modify the active state of hugetlb pages.
> When a new hugetlb page is allocated at fault time, set_page_huge_active
> is called before the page is locked.  Therefore, another thread could
> race and migrate the page while it is being added to page table by the
> fault code.  This race is somewhat hard to trigger, but can be seen by
> strategically adding udelay to simulate worst case scheduling behavior.
> Depending on 'how' the code races, various BUG()s could be triggered.
>=20
> To address this issue, simply delay the set_page_huge_active call until
> after the page is successfully added to the page table.
>=20
> Hugetlb pages can also be leaked at migration time if the pages are
> associated with a file in an explicitly mounted hugetlbfs filesystem.
> For example, consider a two node system with 4GB worth of huge pages
> available.  A program mmaps a 2G file in a hugetlbfs filesystem.  It
> then migrates the pages associated with the file from one node to
> another.  When the program exits, huge page counts are as follows:
>=20
> node0
> 1024    free_hugepages
> 1024    nr_hugepages
>=20
> node1
> 0       free_hugepages
> 1024    nr_hugepages
>=20
> Filesystem                         Size  Used Avail Use% Mounted on
> nodev                              4.0G  2.0G  2.0G  50% /var/opt/hugepoo=
l
>=20
> That is as expected.  2G of huge pages are taken from the free_hugepages
> counts, and 2G is the size of the file in the explicitly mounted filesyst=
em.
> If the file is then removed, the counts become:
>=20
> node0
> 1024    free_hugepages
> 1024    nr_hugepages
>=20
> node1
> 1024    free_hugepages
> 1024    nr_hugepages
>=20
> Filesystem                         Size  Used Avail Use% Mounted on
> nodev                              4.0G  2.0G  2.0G  50% /var/opt/hugepoo=
l
>=20
> Note that the filesystem still shows 2G of pages used, while there
> actually are no huge pages in use.  The only way to 'fix' the
> filesystem accounting is to unmount the filesystem
>=20
> If a hugetlb page is associated with an explicitly mounted filesystem,
> this information in contained in the page_private field.  At migration
> time, this information is not preserved.  To fix, simply transfer
> page_private from old to new page at migration time if necessary.
>=20
> There is a related race with removing a huge page from a file migration.
> When a huge page is removed from the pagecache, the page_mapping() field
> is cleared yet page_private remains set until the page is actually freed
> by free_huge_page().  A page could be migrated while in this state.
> However, since page_mapping() is not set the hugetlbfs specific routine
> to transfer page_private is not called and we leak the page count in the
> filesystem.  To fix, check for this condition before migrating a huge
> page.  If the condition is detected, return EBUSY for the page.
>=20
> Cc: <stable@vger.kernel.org>
> Fixes: bcc54222309c ("mm: hugetlb: introduce page_huge_active")
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  fs/hugetlbfs/inode.c | 12 ++++++++++++
>  mm/hugetlb.c         | 12 +++++++++---
>  mm/migrate.c         | 11 +++++++++++
>  3 files changed, 32 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 32920a10100e..a7fa037b876b 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -859,6 +859,18 @@ static int hugetlbfs_migrate_page(struct address_spa=
ce
> *mapping,
>  	rc =3D migrate_huge_page_move_mapping(mapping, newpage, page);
>  	if (rc !=3D MIGRATEPAGE_SUCCESS)
>  		return rc;
> +
> +	/*
> +	 * page_private is subpool pointer in hugetlb pages.  Transfer to
> +	 * new page.  PagePrivate is not associated with page_private for
> +	 * hugetlb pages and can not be set here as only page_huge_active
> +	 * pages can be migrated.
> +	 */
> +	if (page_private(page)) {
> +		set_page_private(newpage, page_private(page));
> +		set_page_private(page, 0);
> +	}
> +
>  	if (mode !=3D MIGRATE_SYNC_NO_COPY)
>  		migrate_page_copy(newpage, page);
>  	else
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a80832487981..e9c92e925b7e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
...
> @@ -3863,6 +3864,11 @@ static vm_fault_t hugetlb_no_page(struct mm_struct=
 *mm,
>  	}
>=20
>  	spin_unlock(ptl);
> +
> +	/* Make newly allocated pages active */

You already have a perfect explanation about why we need this "if",

  > ... We could have got the page from the pagecache, and it could
  > be that the page is !page_huge_active() because it has been isolated fo=
r
  > migration.

so you could improve this comment with it.

Anyway, I agree to what/how you try to fix.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi=

