Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59251C76191
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 02:34:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F27A321926
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 02:34:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="axyva0Yh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F27A321926
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 997E26B0003; Sun, 21 Jul 2019 22:34:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 949AE8E0001; Sun, 21 Jul 2019 22:34:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 837566B0007; Sun, 21 Jul 2019 22:34:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 641DB6B0003
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 22:34:30 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id q196so29863939ybg.8
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 19:34:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=lO0pl2D/N0Wte9jFVwYyoxzkAS8kJOiDf/u2pevzBOk=;
        b=Vp2MbFVEg3BDcxLEsXk8abL8aOJQJ+GzhQ1PeYRq8CyMOpJLq+eqdzr/if/UhQN78N
         dMMNpFBsxXwRJwdAJPE9slOH5jhcnTGzikX5qreopIYU47n0UN7lkKcr8Rt/cNt6AwfG
         uANFLb6O7YdGPi890VMVN3E3pTxKtbRBP1IknCwtFdbVx76PBpDQDNGzrF22MR17apD1
         jCt/Tu39aEHzxXofSUm+jgylT8YPhs+IVVz4qJ7zm1CWNffohBqHvI9XSxmLE2qFFvHN
         zUHanEaeGdZ8BmgoohBh+H5XW5pm7l9gVwkiP86JD0Q1MyS9xoJmbe2+2D6MR5+x25J0
         7uIQ==
X-Gm-Message-State: APjAAAXhHXR7Bsi27WNiqVRFZI+UwQXJhxtSOwPiSThYbo/mFvchoo27
	32jsBIZ6fJdQm/5jJnCvDE2a0O9Z9kwuX6oVnU25nYNUwiHpooptCvwFjXSK+ZjfjlyscrLcmxB
	S3SGK+5LoXvotrud4khXjFy3FA20artDnEs2jJWLntdV8PQ9OftgMMlauvMW+QjFjVw==
X-Received: by 2002:a25:d196:: with SMTP id i144mr41148204ybg.514.1563762870196;
        Sun, 21 Jul 2019 19:34:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhLkvlL+im2diVkWgunaJUUFExF/3wqSduUqptI2jiDrkMNzFIpORu7LQfoP7stucqeuyu
X-Received: by 2002:a25:d196:: with SMTP id i144mr41148196ybg.514.1563762869718;
        Sun, 21 Jul 2019 19:34:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563762869; cv=none;
        d=google.com; s=arc-20160816;
        b=cuTmV8HrgdxFOMG91NUD2UV62aexzTzCfnHN5Dww/grprM85bRthV4zzSdq/FCJyXQ
         sq9YBacPwMXOHpYLFcLuuBQetToQ6TRMp/3kUUNWhM+OZjSffsKR1Szyvh/LR+3DQ62/
         MpY9RDr1KPDlz+4Ddqzs9+4P1pFvf1OwOFblmE9TCtOQxXgYq99iA5Mi4Q/yHTICVN4T
         C2ecuKCPUc5ERe2lxyFXjwC22xmJ4B89pU0eXP3ZYU8wQEKAQrffgiLWvZch056XudF3
         8qheihbxjOE2Wy77SOGyvX3GeqxBcVxzVUfDOpjAyBGgwYqOrUKG55bxeTa3PS8kOjrS
         abcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=lO0pl2D/N0Wte9jFVwYyoxzkAS8kJOiDf/u2pevzBOk=;
        b=UOy/hlkxbt0RuDhz8MbQgNQOwiMnHQaa1YMwSW0rGo0+j9Eh4iGyFtOqMXCAz6a3bZ
         p+VmHxqyXDgPw8zp+K//XTEVY59Yr2DdCD1h+zCix49TW17lj9TrmBhZyzZCkQCOGF2L
         1fuWtyLIPwj2wdh9vbnUfXy5+lJ0rZwOLAsdglocVcA6iOHWi3aYJXacWhi3jd3pKZ1U
         yPDbLDlXTvF3vMwZj9gZDGmIl2Sz8UIwqYPq/f8/MEmLWqokX67qZ3pCcoUkKLApjSe3
         4sl6tFRFPvjAFGhk2rk379y3gLYXgVUGc/VSD/xebVkml1s68GSuvwJjHs47xXGida/0
         dymQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=axyva0Yh;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id p12si14955110ywm.128.2019.07.21.19.34.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 19:34:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=axyva0Yh;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3520b50000>; Sun, 21 Jul 2019 19:34:29 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Sun, 21 Jul 2019 19:34:28 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Sun, 21 Jul 2019 19:34:28 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 22 Jul
 2019 02:34:28 +0000
Subject: Re: [PATCH 2/3] sgi-gru: Remove CONFIG_HUGETLB_PAGE ifdef
To: Bharath Vedartham <linux.bhar@gmail.com>, <arnd@arndb.de>,
	<sivanich@sgi.com>, <gregkh@linuxfoundation.org>
CC: <ira.weiny@intel.com>, <jglisse@redhat.com>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
References: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
 <1563724685-6540-3-git-send-email-linux.bhar@gmail.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9b510a41-7ce1-b2b7-d3c6-f6f0305e10ea@nvidia.com>
Date: Sun, 21 Jul 2019 19:34:28 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1563724685-6540-3-git-send-email-linux.bhar@gmail.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563762869; bh=lO0pl2D/N0Wte9jFVwYyoxzkAS8kJOiDf/u2pevzBOk=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=axyva0YhbvZrjjd+JQOH6Y0DYU+XPMlPGwyWbICHjIn8nCWjKrAIQ3Nsr0hDTUvze
	 lpL0V66Z84aNd2j7r2POhsMZ2g1W48+3rACb7u5lKicDUcPiBANzVgq5NAtRPyyvQZ
	 BUkmZyF21/eHaBhRt68KP6CCGVB1uS8F6y+BDQXas50Y73RFVq3LG1sx58q//56cNy
	 Sc2nC9ndcjjoGO8WCMjjlXZg/qvs7+EtBUus/bAhoTTUC+tCeqTcrzFWd7g1xnM56+
	 VjK+Xo1XkfdYYKTryKiB7/hKeqOf8OxmNB0YT2qWjZy/AptRLILXHHj1tibyEoXiC+
	 5igf5moViBH9g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/21/19 8:58 AM, Bharath Vedartham wrote:
> is_vm_hugetlb_page has checks for whether CONFIG_HUGETLB_PAGE is defined
> or not. If CONFIG_HUGETLB_PAGE is not defined is_vm_hugetlb_page will
> always return false. There is no need to have an uneccessary
> CONFIG_HUGETLB_PAGE check in the code.
>=20
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Dimitri Sivanich <sivanich@sgi.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
>  drivers/misc/sgi-gru/grufault.c | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
>=20
> diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufa=
ult.c
> index 61b3447..75108d2 100644
> --- a/drivers/misc/sgi-gru/grufault.c
> +++ b/drivers/misc/sgi-gru/grufault.c
> @@ -180,11 +180,8 @@ static int non_atomic_pte_lookup(struct vm_area_stru=
ct *vma,
>  {
>  	struct page *page;
> =20
> -#ifdef CONFIG_HUGETLB_PAGE
>  	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> -#else
> -	*pageshift =3D PAGE_SHIFT;
> -#endif
> +
>  	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <=3D =
0)
>  		return -EFAULT;
>  	*paddr =3D page_to_phys(page);
> @@ -238,11 +235,9 @@ static int atomic_pte_lookup(struct vm_area_struct *=
vma, unsigned long vaddr,
>  		return 1;
> =20
>  	*paddr =3D pte_pfn(pte) << PAGE_SHIFT;
> -#ifdef CONFIG_HUGETLB_PAGE
> +
>  	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> -#else
> -	*pageshift =3D PAGE_SHIFT;
> -#endif
> +
>  	return 0;
> =20
>  err:
>=20

Looks like an accurate cleanup to me.

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

