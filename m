Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B54DC468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:31:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6692212F5
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:31:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="K1TI+oiu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6692212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7ADE66B026E; Fri,  7 Jun 2019 16:31:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7374D6B026F; Fri,  7 Jun 2019 16:31:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B1206B0270; Fri,  7 Jun 2019 16:31:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 317BD6B026E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:31:10 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id y205so3131743ywy.19
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:31:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=DJEgcc7UNUR1jWUy9v9yyTysVpXwgehmZtsnaBcLiV0=;
        b=ZBOY+jMBcjuoAUqint3BhqguzvVseixWQa6dH0jOlHwrbo+/jJOMZAncB8odw4ZgOq
         UtMS8hKRJrrSaSPtFuKqutzI7yOYfg6I8INEADUnXtsW526p4wS1melqspYxd96bq7wu
         IeS4R+aXjqvRC6aRM/klUrOIitejuaamQi6s5PxXJbnjriSQm8WiTVddMRIYvWNKtpHN
         lsCtylHO4IWAiyjTJQjdt7OBaqOPu/Yb8wfNB1G72AdW4hPCx1Ovo66Cgl0/iPWHkFVE
         tUhUJ0PbHia4CXAiB/XqGEgp/v0eFidR/gAACR+SRlat2GRRiwFa7AwIndFsCNio5gu/
         whaw==
X-Gm-Message-State: APjAAAVzs4LikPtQv3DLMdCNq7SE7HTG7C4OqHcfBpxWkN278WLrghSD
	N/PODcibfXFEW7+QOKklcvgVWCSV5ERckq5tyVWZ3fUPWUqalOHR4DlqcnZHmKTTuAjJvLxKPwj
	X0k7I3t8NJe2cnYEsg8lWO8fpB7FgBv3aBbnmEt3pYHFC9nLI+yWENIvek5CtXKjFJw==
X-Received: by 2002:a81:8c2:: with SMTP id 185mr28157783ywi.157.1559939469981;
        Fri, 07 Jun 2019 13:31:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXTv9HXcJgTWiU5HzSqiI9aULICbDa2uJ3l9w2N1zq+qTCcpfg+rxtyIguP9fQPahd2MHd
X-Received: by 2002:a81:8c2:: with SMTP id 185mr28157745ywi.157.1559939469198;
        Fri, 07 Jun 2019 13:31:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559939469; cv=none;
        d=google.com; s=arc-20160816;
        b=unMLVKnhdM8G9FW2qUc+k5ViFemJYSPz+UOcglTWxtcRiIJhyIPnKkExM2CI7He754
         JR2inTRqOI6Ep+TaNKVTgsC5rSJb7cAP1MsjFKyqd5pNucNalxBAUdbVjKW38pqqmpku
         pyHV6rs0IfklKbc5L45u14XI0RWr1Ygh9IICnwDS01YqO+PvLJw44KOutMmbr3mD/hwG
         TRJZVTbQNJV1ImPTi5N+Wz/Go9xqDT9+Jb12pWFGNfUylRtyEE9G+ru+S5zeJE3X5c1h
         KkP/+ubV1cMiJjb+QMofKdSQPDaGf4fL12htqovmZrfuTSlhj78OBvDpeUPZ6urtGJ6S
         /0Bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=DJEgcc7UNUR1jWUy9v9yyTysVpXwgehmZtsnaBcLiV0=;
        b=brZBVYrEd3HZxDTmOdu5Si7LLpmof8BzN+Hc+7nWOXuR33JzYi7mrzMKM60j36fF49
         0BLZVB1zFwiLKFmh5+fZNJ5PASOj217YgekNIw/4t+tXrE9zKzYb5ZBqUUkOEyip83dF
         bjXOiUeUSmAZeSNjLEkWjQlbT+eZoGGmnbXz6QSUzkuKg770RV5ecr1Nif9MNAc2Kyjs
         Q58xTouj2q852MnEIAUolfPhLkIHDKbWGmgLBbYSZi8hlwsBoE5IDte3SQJtRZAsHFNr
         2fFsqZEK+nmTCSLNSuMBvZhOGRQlfUEFvXNF5KqvP2Pa58U81OrNztX2/e7nppkDzN3B
         cMPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=K1TI+oiu;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id o4si1074298ywm.74.2019.06.07.13.31.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 13:31:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=K1TI+oiu;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfac98c0000>; Fri, 07 Jun 2019 13:31:08 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 07 Jun 2019 13:31:08 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 07 Jun 2019 13:31:08 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 20:31:05 +0000
Subject: Re: [PATCH v2 hmm 07/11] mm/hmm: Use lockdep instead of comments
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "John
 Hubbard" <jhubbard@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-8-jgg@ziepe.ca>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <a5c8ffcb-8fa7-3335-ed62-2bb56ddbdf65@nvidia.com>
Date: Fri, 7 Jun 2019 13:31:04 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-8-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559939468; bh=DJEgcc7UNUR1jWUy9v9yyTysVpXwgehmZtsnaBcLiV0=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=K1TI+oiuxer43MXruxn4aD6k38M1KgmLi/kNbIuGzmeeoT0eYPnPFzEvoKNL+bsga
	 u5ORczu2FZ9nHhPCXpcwW8B2+X+xs/86E+K7GJt0nn0cUrJLjE9powkVwlMfgPsgbo
	 RlRKemcVRsq2lMZhwvnnjgAsQnoLqVgASmOoiFwdjsiazBd8Emfwo13BUrJbwc1vh5
	 zHolieE1lXx1gOo+FydkJqvrCK508ZMX+yo3gxl+xD8typ2aCzbLMBVKIsWpH7Rb0p
	 +VyG/635Ox5E8uhpJ04SfqevaDaSIuNM708XWF+vU5ykOZliZ9S9HBBt7QILdCIPqv
	 UiwXc/oGqPCMw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
>=20
> So we can check locking at runtime.
>=20
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
> v2
> - Fix missing & in lockdeps (Jason)
> ---
>   mm/hmm.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index f67ba32983d9f1..c702cd72651b53 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -254,11 +254,11 @@ static const struct mmu_notifier_ops hmm_mmu_notifi=
er_ops =3D {
>    *
>    * To start mirroring a process address space, the device driver must r=
egister
>    * an HMM mirror struct.
> - *
> - * THE mm->mmap_sem MUST BE HELD IN WRITE MODE !
>    */
>   int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm=
)
>   {
> +	lockdep_assert_held_exclusive(&mm->mmap_sem);
> +
>   	/* Sanity check */
>   	if (!mm || !mirror || !mirror->ops)
>   		return -EINVAL;
>=20

