Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D59C4ECDE27
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 08:35:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 774E521479
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 08:35:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 774E521479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10D276B0005; Wed, 11 Sep 2019 04:35:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 097386B0006; Wed, 11 Sep 2019 04:35:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEDA16B0007; Wed, 11 Sep 2019 04:35:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id C747A6B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 04:35:48 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 82631A2CA
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 08:35:48 +0000 (UTC)
X-FDA: 75921981576.26.dog10_89d0eda5dde5d
X-HE-Tag: dog10_89d0eda5dde5d
X-Filterd-Recvd-Size: 2215
Received: from r3-20.sinamail.sina.com.cn (r3-20.sinamail.sina.com.cn [202.108.3.20])
	by imf16.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 08:35:46 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([222.130.247.213])
	by sina.com with ESMTP
	id 5D78B1DD00018DC4; Wed, 11 Sep 2019 16:35:44 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 22318315075704
From: Hillf Danton <hdanton@sina.com>
To: Mina Almasry <almasrymina@google.com>
Cc: mike.kravetz@oracle.com,
	shuah@kernel.org,
	rientjes@google.com,
	shakeelb@google.com,
	gthelen@google.com,
	akpm@linux-foundation.org,
	khalid.aziz@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kselftest@vger.kernel.org,
	cgroups@vger.kernel.org,
	aneesh.kumar@linux.vnet.ibm.com,
	mkoutny@suse.com,
	Hillf Danton <hdanton@sina.com>
Subject: Re: [PATCH v4 3/9] hugetlb_cgroup: add reservation accounting for private mappings
Date: Wed, 11 Sep 2019 16:35:31 +0800
Message-Id: <20190911083531.12272-1-hdanton@sina.com>
In-Reply-To: <20190910233146.206080-1-almasrymina@google.com>
References: <20190910233146.206080-1-almasrymina@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.033697, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 10 Sep 2019 16:31:40 -0700 From:   Mina Almasry <almasrymina@goog=
le.com>
>=20
> @@ -3203,6 +3225,8 @@ static void hugetlb_vm_op_close(struct vm_area_st=
ruct *vma)
>  		gbl_reserve =3D hugepage_subpool_put_pages(spool, reserve);
>  		hugetlb_acct_memory(h, -gbl_reserve);
>  	}

Double thanks for cleaning up the gbl typo.

> +
> +	kref_put(&resv->refs, resv_map_release);
>  }
>=20
>=20
> @@ -4569,11 +4594,29 @@ int hugetlb_reserve_pages(struct inode *inode,
>  		chg =3D region_chg(resv_map, from, to);
>=20
>  	} else {
> +		/* Private mapping. */
> +		chg =3D to - from;
> +
> +		if (hugetlb_cgroup_charge_cgroup(
> +					hstate_index(h),
> +					chg * pages_per_huge_page(h),
> +					&h_cg, true)) {
> +			return -ENOMEM;
> +		}
> +
>  		resv_map =3D resv_map_alloc();
>  		if (!resv_map)
>  			return -ENOMEM;

Put charge after allocating resv_map.

Other than that
Acked-by: Hillf Danton <hdanton@sina.com>


