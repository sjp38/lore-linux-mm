Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57740C49ED9
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 05:36:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D753720856
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 05:36:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D753720856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B44E6B0003; Thu, 12 Sep 2019 01:36:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2634D6B0005; Thu, 12 Sep 2019 01:36:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1798C6B0006; Thu, 12 Sep 2019 01:36:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0090.hostedemail.com [216.40.44.90])
	by kanga.kvack.org (Postfix) with ESMTP id EBB306B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 01:36:36 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8236D824376A
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 05:36:36 +0000 (UTC)
X-FDA: 75925158792.05.air96_56a280b43752b
X-HE-Tag: air96_56a280b43752b
X-Filterd-Recvd-Size: 2971
Received: from r3-23.sinamail.sina.com.cn (r3-23.sinamail.sina.com.cn [202.108.3.23])
	by imf08.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 05:36:34 +0000 (UTC)
Received: from unknown (HELO localhost.localdomain)([222.131.67.234])
	by sina.com with ESMTP
	id 5D79D95E0002026C; Thu, 12 Sep 2019 13:36:33 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 5287054923193
From: Hillf Danton <hdanton@sina.com>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Will Deacon <will.deacon@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge PMD
Date: Thu, 12 Sep 2019 13:36:21 +0800
Message-Id: <20190912053621.15456-1-hdanton@sina.com>
In-Reply-To: <20190911150537.19527-1-longman@redhat.com>
References: <20190911150537.19527-1-longman@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 11 Sep 2019 16:05:37 +0100
>=20
> +#define PMD_SHARE_DISABLE_THRESHOLD	(1 << 8)
> +
>  /*
>   * Search for a shareable pmd page for hugetlb. In any case calls pmd_=
alloc()
>   * and returns the corresponding pte. While this is not necessary for =
the
> @@ -4770,11 +4772,24 @@ pte_t *huge_pmd_share(struct mm_struct *mm, uns=
igned long addr, pud_t *pud)
>  	pte_t *spte =3D NULL;
>  	pte_t *pte;
>  	spinlock_t *ptl;
> +	static atomic_t timeout_cnt;
> =20
> -	if (!vma_shareable(vma, addr))
> -		return (pte_t *)pmd_alloc(mm, pud, addr);
> +	/*
> +	 * Don't share if it is not sharable or locking attempt timed out
> +	 * after 10ms. After 256 timeouts, PMD sharing will be permanently
> +	 * disabled as it is just too slow.
> +	 */
> +	if (!vma_shareable(vma, addr) ||
> +	   (atomic_read(&timeout_cnt) >=3D PMD_SHARE_DISABLE_THRESHOLD))
> +		goto out_no_share;
> +
> +	if (!i_mmap_timedlock_write(mapping, ms_to_ktime(10))) {
> +		if (atomic_inc_return(&timeout_cnt) =3D=3D
> +		    PMD_SHARE_DISABLE_THRESHOLD)
> +			pr_info("Hugetlbfs PMD sharing disabled because of timeouts!\n");
> +		goto out_no_share;
> +	}
	atomic_dec_if_positive(&timeout_cnt);

The logic to permanently disable pmd sharing does not make much sense
without anything like atomic_dec that would have been in their places,
with 256 timeouts put aside.

> =20
> -	i_mmap_lock_write(mapping);
>  	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
>  		if (svma =3D=3D vma)
>  			continue;
> @@ -4806,6 +4821,9 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsig=
ned long addr, pud_t *pud)
>  	pte =3D (pte_t *)pmd_alloc(mm, pud, addr);
>  	i_mmap_unlock_write(mapping);
>  	return pte;
> +
> +out_no_share:
> +	return (pte_t *)pmd_alloc(mm, pud, addr);
>  }


