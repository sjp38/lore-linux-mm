Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D08AFC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:58:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A5162087B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:58:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="dmqbfBMw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A5162087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 246098E0049; Wed, 20 Feb 2019 18:58:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F5548E0002; Wed, 20 Feb 2019 18:58:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E4FA8E0049; Wed, 20 Feb 2019 18:58:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBCDA8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 18:58:53 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id d9so13563195ybn.18
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 15:58:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=jP+wiat2XSsdStfjMflPAPZ0y6VSuTquKiZkpsPA0wk=;
        b=l/l+PMkBmVr/ZAscHm3Pg5bk2pN9+cTrkQCzp6RZ7xGlKXMMi28OZN7re2VfiWs+7/
         zr6o10T2X1pWvj2/Pz+WEiDVsjZFTWuN35c/1VeKQXsTfu1wzm4wbQH/GLQbZud9M6FV
         dQxrJtzGc6lsFOvMNnf6rLoF9tWnr1Kt8ybXdFI6Cwnkaoq9TTUUJYaie650lcuyhqje
         ED2Jyl6DSpPh1YqLf3agqFdTCA+LjwFX3BhUYrjBZXJ/07RAafk5NaCuu8A1iOEfZxzK
         YlZVurKKqF29aSxDbMUmolL6f0fVp/GJHZiG9OGF7b37wIx3NsM3qcdH5i467AgiZSz0
         Ju5A==
X-Gm-Message-State: AHQUAuYaDqPtQzKVKyYF3h1C37mb1iCdyDep/QzDkQRqYgQEcvIxRie6
	Q7HT0B41IE+BgrJy2qO1b/3ZzXvJF82QQoUJjq9t+bkvUinCJDVYiMK3fJxpcjnxRtizZxDtsE3
	t1oF/lG82kQlmQXg1bsTBlhN7Cd+tfIQLlKZuSo7KVsMAgZqbLlbOZgrslyH8T6xupw==
X-Received: by 2002:a25:73cc:: with SMTP id o195mr29751196ybc.310.1550707133635;
        Wed, 20 Feb 2019 15:58:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYWAHqeEToaeg7blZRZEQEWf0KQ+Ru94VJX3ZhO4Yy8ulBPr8UNoJKjCYFO2UYlJICpt9ei
X-Received: by 2002:a25:73cc:: with SMTP id o195mr29751172ybc.310.1550707133077;
        Wed, 20 Feb 2019 15:58:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550707133; cv=none;
        d=google.com; s=arc-20160816;
        b=FyPpBYFWjxnTPHm71NQO89cShzDnDm7Bv8w+4QrpLOzDbPfUbpAayn679GmVc6F/0E
         M607r+gnCJj8CYHeRKzLewrEVyJc/pYfdyUaUNs96xulOESFdweCoYDwVpjaMlY+21Ta
         OkPsloSMPIU2BtsbUihe1t80S3rVxWHjoHGy0ac3SvNLGSaARUF8nzN8BI+OOmQyPw5R
         0wiP+0zpwGRAa1znmTnnKjlxP+xGD3YkcJPPSzz47iFYcQBMWGvDnSMO4ZmUx5cuIph4
         SJ8DnDCwECRcJ1dNJruwKncl8Vh6qcYoyYCDC69I6nEVeysmcl4VX6tUWNyM34DVMQmm
         ohQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=jP+wiat2XSsdStfjMflPAPZ0y6VSuTquKiZkpsPA0wk=;
        b=RbfgWWvVlbTjyi8GC6b9QQAM/21lQz4cKJ16SbbqKpHL+XxNwqlM0B7V3mftaWXU5J
         7F7j+XEURslZMkX8eRipm6UhMk/BHaSBAbiwqdMCovukVgRthCW95Y2M/11x5JfLrmNR
         I3w543alsS7N0ci+IB+Nddhub69Ebv/k0wkJ0B5P6xyko4LGsK6pUmyjRgGSbJtLdo5N
         eJqQ4C8cFiSpntLtDpVg7JrRMtf7h0TyNavXur2oBIRI/PUgqg2ahY5vbMTGs5Ef2+rU
         XOx9UtVvViQ3o/viH8UT4sVQ/QBRGUDA9kkKJH2Gl/giz2K4GDW+Oi6rPZ+XYm9mmFI8
         8dSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=dmqbfBMw;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id x76si6541891ybg.490.2019.02.20.15.58.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 15:58:53 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=dmqbfBMw;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6de9c20000>; Wed, 20 Feb 2019 15:58:58 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 20 Feb 2019 15:58:52 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 20 Feb 2019 15:58:52 -0800
Received: from [10.2.169.124] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Wed, 20 Feb
 2019 23:58:51 +0000
Subject: Re: [PATCH 02/10] mm/hmm: do not erase snapshot when a range is
 invalidated
To: <jglisse@redhat.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-3-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <ca5e182d-6b99-0e5d-91ab-175ddc6acd45@nvidia.com>
Date: Wed, 20 Feb 2019 15:58:40 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190129165428.3931-3-jglisse@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550707138; bh=jP+wiat2XSsdStfjMflPAPZ0y6VSuTquKiZkpsPA0wk=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=dmqbfBMwvjaiDm4+ShTJ/pUB6RmCQ/z4LdRkHsxmLjQ13SeSj75L5H16XUZNvEgI5
	 KEuJ9clung0YkN8Juhf52xYrG7rcjUYdiVcxmOWAgxJXFACrSuhAy3Dh+RZRJAWjGl
	 v5f2fKZFcdS75UivGyHgoA0Agrlufs+52Go8uJmzob84TdtuO7FpQIoizsu33g8cET
	 EAAQoIID1RfvmJ6mYYiR/7gFk0CgqV+Ytoxt5dYrpbJtgk1CTKd68Z6eSYBuHR0DzG
	 5+b6jYldNox+246RO7rJN2dpYw6rxa07YhZVJ0rWzaR8cMYihE2hggXo2yOumsXtc2
	 QhGMT+ce258jA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> Users of HMM might be using the snapshot information to do
> preparatory step like dma mapping pages to a device before
> checking for invalidation through hmm_vma_range_done() so
> do not erase that information and assume users will do the
> right thing.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>   mm/hmm.c | 6 ------
>   1 file changed, 6 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index b9f384ea15e9..74d69812d6be 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -170,16 +170,10 @@ static int hmm_invalidate_range(struct hmm *hmm, bo=
ol device,
>  =20
>   	spin_lock(&hmm->lock);
>   	list_for_each_entry(range, &hmm->ranges, list) {
> -		unsigned long addr, idx, npages;
> -
>   		if (update->end < range->start || update->start >=3D range->end)
>   			continue;
>  =20
>   		range->valid =3D false;
> -		addr =3D max(update->start, range->start);
> -		idx =3D (addr - range->start) >> PAGE_SHIFT;
> -		npages =3D (min(range->end, update->end) - addr) >> PAGE_SHIFT;
> -		memset(&range->pfns[idx], 0, sizeof(*range->pfns) * npages);
>   	}
>   	spin_unlock(&hmm->lock);
>  =20
>=20

Seems harmless to me. I really cannot see how this could cause a problem,
so you can add:

	Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

