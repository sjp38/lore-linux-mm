Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4E61C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 03:40:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66E17217F5
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 03:40:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66E17217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9B6B6B0003; Wed,  7 Aug 2019 23:40:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4A376B0006; Wed,  7 Aug 2019 23:40:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B11D96B0007; Wed,  7 Aug 2019 23:40:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 87E296B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 23:40:52 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id a8so59013508oti.8
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 20:40:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=sfLGK+8AqjcEx/3VgqQYXDe2RtXC0zOP3T5YInCraig=;
        b=NkhlcmYG6vpk23YaupxaOdUMbZwI9liih43TpgFbZawXYbYlzAWqHc6rZpo56E660z
         SWGaTebWqG3ezlmeea/siXtNqAvI2iis5pqCp5p3iORW7Ar8X8C8ZK6Plr752GonrbsL
         cQVSMG8Ld7OaUp+rEMZJmV6Os2wblbmlHrazWiMVKvFl5o/9G4Vdl78jc9Bq0GgtYqoQ
         ODRtkwYALjvjzyww3/jVTV3bWCOpcNjJ/GCdwhUttWYpBT5eM4auafl2LI8on0UnSSMd
         rcK4cylVfgi/UQbSEFU8uIsRtMLOfejyZ8GOmjOFqY5ba6i5K6eGHbeA1xyWZIjC1s7x
         yKHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAV/fcTAWfh/xWajjfddFbyLa+NW0fFB1MXfJP2CmUNZHWqxvjcO
	TmQ7dG/oMBzz3v7T0R9Ex/9gyHjKBjn99ljRQwn7ceNyquYV96OGEZ+zXlKG7Oqun7kHXjO0r2h
	5MYH1K3EXe3K9PRvDtB0vjpI/SZAFy2v01RT2sLA0b27peCWNwry746+BoLyb3O+i7w==
X-Received: by 2002:a5e:c744:: with SMTP id g4mr12604584iop.187.1565235652250;
        Wed, 07 Aug 2019 20:40:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaK8amTyLON7VfkQxvzgsw0lmJVYVJJwjocEaGV/nC4shirtDGdR15cV9qilL7oLXoWOMC
X-Received: by 2002:a5e:c744:: with SMTP id g4mr12604546iop.187.1565235651389;
        Wed, 07 Aug 2019 20:40:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565235651; cv=none;
        d=google.com; s=arc-20160816;
        b=U0q5noEqZLY/8QO539db1G3KA9VYzM6HFGNsCvYzHScAYE+IVLHH0oC5ZlyU/sOegt
         Q2gyELBfK0IMcKQZffMITDjF7nrEgwsAJrj5s3sJWlLw2W4v7hqHdA49vjI5mi6cl02u
         G04aSmSGqN/f0J4KIOHFk/BqFXanGCH8mZj23KZn2kivXROnx2hc6IvpxTvE14Ht5Rkw
         r0i5/LzCNVTh+BRl+lNeecSEEB5m8sq9HvHXzNNGbqc279EHMh4bh7CfMGf63zCDwqvt
         PhF0cGxUzDxkhOwQnWirwbnq60ZQPRmSrVckoUVY84fNYLzQTUv0DFWbDk74QarTxZYY
         9l8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=sfLGK+8AqjcEx/3VgqQYXDe2RtXC0zOP3T5YInCraig=;
        b=UnSSl+NCmn8/6ZKNdIRin/eCv4PZts/42/f8qgul1pBFmyoti3LoEZznn80WZAcAFA
         I/O3nby/LBp6cW6zAXxykJpdpSBG5Mnlsb6K1AwPj3jKhxVSbg4hpOWt1eRKmSTL56e6
         c2q030T0WxtDh5g+jsNMK0Vck7cTS6Ec1aTE8gGqW6Uw08zEjiLkHgeXjQnUqTJBpLU9
         At4wNbDyjdw0LUeNcNf+IKhilAGj+UygytznD5RYjQSi6Nw+5dtStx8wmjGf5WoX7/+z
         8LygibTEFm9NLhxOicWc4cw8Bcq5QVucBXaN7mp9ywxIv0PAOZAC7nv0yfbnLByVu35G
         ZAqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id u24si2433720iog.3.2019.08.07.20.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 20:40:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x783efIu030575
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 8 Aug 2019 12:40:41 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x783efAY003936;
	Thu, 8 Aug 2019 12:40:41 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x783eeEd020078;
	Thu, 8 Aug 2019 12:40:41 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.148] [10.38.151.148]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-7505107; Thu, 8 Aug 2019 12:36:24 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC20GP.gisp.nec.co.jp ([10.38.151.148]) with mapi id 14.03.0439.000; Thu, 8
 Aug 2019 12:36:23 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ltp@lists.linux.it" <ltp@lists.linux.it>,
        "Li Wang" <liwang@redhat.com>, Michal Hocko <mhocko@kernel.org>,
        Cyril Hrubis <chrubis@suse.cz>,
        "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlbfs: fix hugetlb page migration/fault race
 causing SIGBUS
Thread-Topic: [PATCH] hugetlbfs: fix hugetlb page migration/fault race
 causing SIGBUS
Thread-Index: AQHVTX0N0YwnRs9J50WW+DT6/gmNh6bwAwsA
Date: Thu, 8 Aug 2019 03:36:22 +0000
Message-ID: <20190808033622.GA28751@hori.linux.bs1.fc.nec.co.jp>
References: <20190808000533.7701-1-mike.kravetz@oracle.com>
In-Reply-To: <20190808000533.7701-1-mike.kravetz@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <BB43671309A3D0478266CADD63E511C9@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 05:05:33PM -0700, Mike Kravetz wrote:
> Li Wang discovered that LTP/move_page12 V2 sometimes triggers SIGBUS
> in the kernel-v5.2.3 testing.  This is caused by a race between hugetlb
> page migration and page fault.
>=20
> If a hugetlb page can not be allocated to satisfy a page fault, the task
> is sent SIGBUS.  This is normal hugetlbfs behavior.  A hugetlb fault
> mutex exists to prevent two tasks from trying to instantiate the same
> page.  This protects against the situation where there is only one
> hugetlb page, and both tasks would try to allocate.  Without the mutex,
> one would fail and SIGBUS even though the other fault would be successful=
.
>=20
> There is a similar race between hugetlb page migration and fault.
> Migration code will allocate a page for the target of the migration.
> It will then unmap the original page from all page tables.  It does
> this unmap by first clearing the pte and then writing a migration
> entry.  The page table lock is held for the duration of this clear and
> write operation.  However, the beginnings of the hugetlb page fault
> code optimistically checks the pte without taking the page table lock.
> If clear (as it can be during the migration unmap operation), a hugetlb
> page allocation is attempted to satisfy the fault.  Note that the page
> which will eventually satisfy this fault was already allocated by the
> migration code.  However, the allocation within the fault path could
> fail which would result in the task incorrectly being sent SIGBUS.
>=20
> Ideally, we could take the hugetlb fault mutex in the migration code
> when modifying the page tables.  However, locks must be taken in the
> order of hugetlb fault mutex, page lock, page table lock.  This would
> require significant rework of the migration code.  Instead, the issue
> is addressed in the hugetlb fault code.  After failing to allocate a
> huge page, take the page table lock and check for huge_pte_none before
> returning an error.  This is the same check that must be made further
> in the code even if page allocation is successful.
>=20
> Reported-by: Li Wang <liwang@redhat.com>
> Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> Tested-by: Li Wang <liwang@redhat.com>

Thanks for the work and nice description.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/hugetlb.c | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ede7e7f5d1ab..6d7296dd11b8 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3856,6 +3856,25 @@ static vm_fault_t hugetlb_no_page(struct mm_struct=
 *mm,
> =20
>  		page =3D alloc_huge_page(vma, haddr, 0);
>  		if (IS_ERR(page)) {
> +			/*
> +			 * Returning error will result in faulting task being
> +			 * sent SIGBUS.  The hugetlb fault mutex prevents two
> +			 * tasks from racing to fault in the same page which
> +			 * could result in false unable to allocate errors.
> +			 * Page migration does not take the fault mutex, but
> +			 * does a clear then write of pte's under page table
> +			 * lock.  Page fault code could race with migration,
> +			 * notice the clear pte and try to allocate a page
> +			 * here.  Before returning error, get ptl and make
> +			 * sure there really is no pte entry.
> +			 */
> +			ptl =3D huge_pte_lock(h, mm, ptep);
> +			if (!huge_pte_none(huge_ptep_get(ptep))) {
> +				ret =3D 0;
> +				spin_unlock(ptl);
> +				goto out;
> +			}
> +			spin_unlock(ptl);
>  			ret =3D vmf_error(PTR_ERR(page));
>  			goto out;
>  		}
> --=20
> 2.20.1
>=20
> =

