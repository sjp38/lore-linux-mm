Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAA28C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 11:38:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E28B2084D
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 11:38:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=samsung.com header.i=@samsung.com header.b="F4jCspHo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E28B2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=samsung.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28E616B0005; Fri,  9 Aug 2019 07:38:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 241456B0006; Fri,  9 Aug 2019 07:38:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E0426B0007; Fri,  9 Aug 2019 07:38:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id B2F4A6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 07:38:37 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id i6so46388869wre.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 04:38:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:subject:to:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:cms-type:references;
        bh=ciOb6spUFxEopuASAxMYr4OicRDjbbeUQNl3/3W2RC0=;
        b=QOXpeBTA1+QLnfsfeiapzcmlqo8rQ8T359KpjIiGnWGEVk4tFRA04ozCpVJQdcj/C3
         kiAb/bAR+Q3Qex2L12Ky1ZyoGBmoXGKBeBamKy2trDDijAwefDAhnIFqoDCUkPSJSfWY
         /f0kdwKdZrPfA1oLpWjmaVzjnDjtA7WKm1fx4ZX+Zkm63LL5N4V9U3ZnzM6I/7UAOyyK
         H9eRBdu48WzyKjJ+br5uU9yzCNKlvbfHFz2v9ePVmnjTmbe62ApA1pPeuLTZibiJbPll
         HK6ZNUZnWSIUqHfusaiXiFsGf/Bk43uZXYb4KhYirNCe9f4tOmYzm0KWChk1Yg9OCaQZ
         n6Fg==
X-Gm-Message-State: APjAAAUqIS7ihji3zbRKfObsU7kNVwmAlXqmUz7LdH86PJo/O7DMCNJ9
	4da5wcDEw8d0MzJlarxTlWF+Yez+/I9vyaBScR2Avtha9cgmgAXpuP66mxYBoxZZPa6WryDBA02
	yQzz+Gz99gmdAlCqeVmBxP8Sx5beRbyf8dL3g9rJYDXeTjPSXjViFcWRmmC25d/m1EQ==
X-Received: by 2002:adf:ec8e:: with SMTP id z14mr24416082wrn.269.1565350717209;
        Fri, 09 Aug 2019 04:38:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygp455VwN8rmce1JdExgR7+LWancVkA8Lk8Ascn+nQXrtxgMkhs8Uvk7nhuAWXyTnCu4Xo
X-Received: by 2002:adf:ec8e:: with SMTP id z14mr24416017wrn.269.1565350716475;
        Fri, 09 Aug 2019 04:38:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565350716; cv=none;
        d=google.com; s=arc-20160816;
        b=Xt9LpYmCmY/BrqnBlAbey4m/18Qq7rNj5Y3naVnk3ASwhr2T7WCHr1y+4cMHLlJHXz
         0uve8hZUkt+Y5RlsqZPoXy+Kp5YX7ZzSIdvwz8/v6+aDfI/91e53/gJgUZX1Ug78n+yZ
         40G2++qeDKoyoXkQfXqyV0TlHA2+rmzLUCjll/Mj3MZeemZL5H/U0CzXNlfyoF7UE6sm
         LsFArohOK+aGjp1/Gshe1lHjaqxZv8pi6EzWjxzwnfvDT2gHAUs6uSbGU789X9JWkjHT
         8mARzH8MDEArkoNmfDNHZmBzeayZu/p1ZW317NgS3KuekklRcZxLLXxSxthwFunqOBi1
         F3Pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:cms-type:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:cc:to
         :subject:dkim-signature:dkim-filter;
        bh=ciOb6spUFxEopuASAxMYr4OicRDjbbeUQNl3/3W2RC0=;
        b=AgEusF3xI7GZxpTm7acZyqcH0SJ3y2Azgi4AMVF545xhKrALUtIBcAlmFk+CNhTToJ
         EHKAQtSKevOzwYJK2t9JBalxqzLH6azl5dLB40xaKMhYPD2Vlp2d3A+x/hgcimnz9BLk
         6SEM2ENfh8BWx+u9/iufS/uXd4HIKWqbM2/VC3vQDSEqsZKGKAbscz8vzy7Ew4aPokKk
         oXm8azT448e0yONrcQoIO0F8LGFPjYZ3sj6+QS2ZZFGs9ZVTCCapGmVy07qrq8xkbq9o
         H1lt3GxT0mBU0aUvlO1FJLOt0MR6lyrluJtSK8cMEtwagRDMj9RCy9tm6hne3VvRbh6H
         rsAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@samsung.com header.s=mail20170921 header.b=F4jCspHo;
       spf=pass (google.com: domain of b.zolnierkie@samsung.com designates 210.118.77.12 as permitted sender) smtp.mailfrom=b.zolnierkie@samsung.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=samsung.com
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id 9si3612452wmx.68.2019.08.09.04.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 04:38:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of b.zolnierkie@samsung.com designates 210.118.77.12 as permitted sender) client-ip=210.118.77.12;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@samsung.com header.s=mail20170921 header.b=F4jCspHo;
       spf=pass (google.com: domain of b.zolnierkie@samsung.com designates 210.118.77.12 as permitted sender) smtp.mailfrom=b.zolnierkie@samsung.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=samsung.com
Received: from eucas1p1.samsung.com (unknown [182.198.249.206])
	by mailout2.w1.samsung.com (KnoxPortal) with ESMTP id 20190809113835euoutp0203cf6a40c6ba20e7419068b4b083de35~5Pi6zKulA2402024020euoutp02V;
	Fri,  9 Aug 2019 11:38:35 +0000 (GMT)
DKIM-Filter: OpenDKIM Filter v2.11.0 mailout2.w1.samsung.com 20190809113835euoutp0203cf6a40c6ba20e7419068b4b083de35~5Pi6zKulA2402024020euoutp02V
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=samsung.com;
	s=mail20170921; t=1565350715;
	bh=ciOb6spUFxEopuASAxMYr4OicRDjbbeUQNl3/3W2RC0=;
	h=Subject:To:Cc:From:Date:In-Reply-To:References:From;
	b=F4jCspHo1ZNymcum0RJ4SAewCj16GaDlAVZIDT2iz4G3oLIcVNFv7QZq1tB9+Mno+
	 zjxkidwYaZ/byaK+48GmSjpyd4EP3CVVtb2hsnlR4r3Xd9Txb3fjCp02LLNQjfvbhA
	 LfZtr2jIlfH7OXIPbRApNOZfFUcXc5fICbOu4WY0=
Received: from eusmges3new.samsung.com (unknown [203.254.199.245]) by
	eucas1p1.samsung.com (KnoxPortal) with ESMTP id
	20190809113835eucas1p164d330c27bd3a49537b7450fadf60f2f~5Pi6eb4BE0165101651eucas1p1R;
	Fri,  9 Aug 2019 11:38:35 +0000 (GMT)
Received: from eucas1p2.samsung.com ( [182.198.249.207]) by
	eusmges3new.samsung.com (EUCPMTA) with SMTP id 1E.84.04374.B3B5D4D5; Fri,  9
	Aug 2019 12:38:35 +0100 (BST)
Received: from eusmtrp1.samsung.com (unknown [182.198.249.138]) by
	eucas1p1.samsung.com (KnoxPortal) with ESMTPA id
	20190809113834eucas1p1ff05719f819b28ade78ac677ea76b915~5Pi5VNrUE2548825488eucas1p1t;
	Fri,  9 Aug 2019 11:38:34 +0000 (GMT)
Received: from eusmgms1.samsung.com (unknown [182.198.249.179]) by
	eusmtrp1.samsung.com (KnoxPortal) with ESMTP id
	20190809113833eusmtrp1d0d26c18325a624784804f5dcd2b3a9f~5Pi5F7Mcq0891408914eusmtrp1l;
	Fri,  9 Aug 2019 11:38:33 +0000 (GMT)
X-AuditID: cbfec7f5-4f7ff70000001116-2d-5d4d5b3beff2
Received: from eusmtip2.samsung.com ( [203.254.199.222]) by
	eusmgms1.samsung.com (EUCPMTA) with SMTP id A2.7E.04166.93B5D4D5; Fri,  9
	Aug 2019 12:38:33 +0100 (BST)
Received: from [106.120.51.71] (unknown [106.120.51.71]) by
	eusmtip2.samsung.com (KnoxPortal) with ESMTPA id
	20190809113832eusmtip25484f3be8e362eb8076e0844f903c912~5Pi3tqsfV0444004440eusmtip2N;
	Fri,  9 Aug 2019 11:38:32 +0000 (GMT)
Subject: Re: [PATCH v3 20/41] fbdev/pvr2fb: convert put_page() to
 put_user_page*()
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ira Weiny
	<ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
	devel@lists.orangefs.org, dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org, linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org, x86@kernel.org, xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>, Kees Cook <keescook@chromium.org>, Al
	Viro <viro@zeniv.linux.org.uk>, Bhumika Goyal <bhumirks@gmail.com>, Arvind
	Yadav <arvind.yadav.cs@gmail.com>
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Message-ID: <1f1656b4-3411-3237-726f-8fb7b73ae363@samsung.com>
Date: Fri, 9 Aug 2019 13:38:31 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
	Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190807013340.9706-21-jhubbard@nvidia.com>
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Brightmail-Tracker: H4sIAAAAAAAAA02TfUxTVxjGd+53O8uuBcYJui02fs1F3aLLXsfGXObiNY6o0UQzZbOTm2JG
	q7ZW5wxZWZOpIBsFG6RtHOsmXyrUtlPsUExJWqBYcRKiTMsyBBmIVhwiCDrKHRn//c7zPs/7
	8cfhSOUIk8zt1O0V9Tp1loqRU+cCI1cXp2xNS3+zzyIDR81pBk7W5LDQnv8TCYORHxiI3iwk
	oNjaiqDXdQiBNxBBUNcyykK95xgBbUMPGAgVOAmwF3gIqO++S4G92ExAyfFGNEG9BJztdrLQ
	fFkHLXlacFj3gLurnYaLHW9AZ2SEgMbvozTUXWyi4LrPwcBR1680RE4/p6H1coiGHn8+BZY/
	XCz4xmpZCJS+DGHPIxpMTRU0XB0P0vDE1UXDsLeIWLlAsJuuUULkUgMlNDuxcMF2mxU8FYuE
	n+v+JgR31RFGcA8WskLj8aeUcKJpg9CZFyQEzy/fCCZrByM0RNsoId98nxFay+4x6xM/lb+X
	IWbt3Cfql6Zul2eOdRcTu6+8+JWzb5wxoVuyXCTjML8cO6usZIyVfAXCd/uTcpF8gv9BuLrQ
	S0mPRwhHwy30VOL5/QYkJcoRPjO0XDINIHyqpXLSFM9vwnn1FirGCXwyDpcN0zETyffJcDRU
	ysYKDP8uthyqmuyk4FNxyeMTRC7iOIqfi3uc62JyIr8FdwZctGSZiZtK7kz2lPEr8M171ZNt
	SD4Jd9z5kZD4NXx+wEHGZmE+IsOu3zyktPUq7HNXIInjcV/Qy0o8G4eKjlJSoBrh8cO9/6XP
	I1xe9IyRXCm4IXiNjm1H8q/jGt9SSf4Qh59GmJiM+Th8Y2CmtEQcLjxXTEqyAh/+Tim552NX
	mYuZGpt7oZIsQCrbtNNs086xTTvH9v/cUkRVoSTRaNBqRMMynbh/iUGtNRh1miU7dmndaOJD
	hJ4Fh2rRpbEv/IjnkGqGwjTnk3Qlrd5nOKD1I8yRqgRFG5eWrlRkqA98Lep3fa43ZokGP5rF
	UaokxcEX/tyq5DXqveKXorhb1E9VCU6WbELV9tTrlg17nJqxUILm4w/Mt0rtgXcs+7dZj/Q/
	nKU522zNijNnZx6rNG/b/urgbbsiSHw2I/vBvJyXcjr/ypFTa953Zhu9K1albmE3r155I1C+
	8Qno1ywMP/xo+Hds9H27cV1oYXuGvz/Fspbumfv26OgrJ1cv6xnkuhy1O9amxc9OVFGGTPVb
	i0i9Qf0vm535fAwEAAA=
X-Brightmail-Tracker: H4sIAAAAAAAAA02SbUxTVxiAc+53mTV3BfTIpmCHmvhRVxD71rhu2X54YzTbMmOm2GiHN1Cl
	LfYWNrfEdUGDgGzg+JC2YawOwgiT0ooioUPLpCBMwTEScas/ED+ZNuhkOhxrbUz495zzPk9O
	TvJypOIYk8QZzTbRajbkKpk4auC/YGiNNnOr/s3Dfg24WlsYaGj9ioXRsu9JmAp9w0D42nEC
	aqqGENzxFCE43RtC0DX4jIVuXyUBI38/ZGCg3E2As9xHQPfEbQqcNYUE1J7oQxG6Q0DbhJuF
	S+fNMFhqAlfVAfCOj9LgH1sFN0JPCej7OkxDl7+fgt86XQwc87TTEGqZpWHo/AANtwJlFFRc
	97DQOdPBQm/9Arjse0SDvb+JhivPgzT84xmnYfr0t8Q7KwSnfZgSQj/3UMIlNxbOOf5kBV/T
	SuFk111C8DYXM4J36jgr9J34lxLq+j8UbpQGCcH3w5eCvWqMEXrCI5RQVviAEYYaJ5kPEneq
	Nlot+TYxJcci2d5SZqohTaXWgiptnValTtfoN6RlKNfqNu4Vc40FonWtbo8qZ2aihsj79ZXP
	3PeeM3b0h6wEyTjMr8OzD3pQCYrjFHwDws8aGyIHLjJ4HQdbC2JOPJ4ZLWFizn2Ep6uDKDqI
	57fh0u4KKsoJfBK+3DhNRyWSn5Th6qFfiFjRifBU+2MmajH8BlxR1PyilvM6XPukjoi+RvGp
	+Jb7/eh1Iv8xHnzYRMWUV3F/7c0XLOO1+NrkKTbKJL8Cz9RdJWO8EI/d/I6IcTI++5eLLEcK
	x5zcMSdxzEkcc5J6RDWjBDFfMmWbJLVKMpikfHO2Ksti8qLIJp7pferrQFfbPgognkPKeXL7
	0i16BW0okA6aAghzpDJBPsJt1Svkew0HPxetlt3W/FxRCqCMyN8qyKTELEtkr8223eoMtQa0
	ak26Jn09KBfKj/IXdin4bINN3C+KeaL1ZUdwsiQ7emPe2K5FR+zJhf7h5mUp21sWHyKu3C20
	fjJ5XTPwZHP8uympgUypM1y5+bWWYuUXxpx9QclZbKz/Pfnx4cXoovHkGo/ZoF++I8Fl0507
	ui1U+XaKM7y+J7XL/ukZuiHrYkfm8I8/+TctKaredKBt/nurb5/Sld6LGz+U184umPV6HjFK
	SsoxqFeSVsnwP1w/tA+fAwAA
X-CMS-MailID: 20190809113834eucas1p1ff05719f819b28ade78ac677ea76b915
X-Msg-Generator: CA
Content-Type: text/plain; charset="utf-8"
X-RootMTR: 20190807013420epcas1p1a38f499e39127e66501040b7e9e788ba
X-EPHeader: CA
CMS-TYPE: 201P
X-CMS-RootMailID: 20190807013420epcas1p1a38f499e39127e66501040b7e9e788ba
References: <20190807013340.9706-1-jhubbard@nvidia.com>
	<CGME20190807013420epcas1p1a38f499e39127e66501040b7e9e788ba@epcas1p1.samsung.com>
	<20190807013340.9706-21-jhubbard@nvidia.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 8/7/19 3:33 AM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: Bhumika Goyal <bhumirks@gmail.com>
> Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-fbdev@vger.kernel.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

Acked-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung R&D Institute Poland
Samsung Electronics

> ---
>  drivers/video/fbdev/pvr2fb.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/video/fbdev/pvr2fb.c b/drivers/video/fbdev/pvr2fb.c
> index 7ff4b6b84282..0e4f9aa6444d 100644
> --- a/drivers/video/fbdev/pvr2fb.c
> +++ b/drivers/video/fbdev/pvr2fb.c
> @@ -700,8 +700,7 @@ static ssize_t pvr2fb_write(struct fb_info *info, const char *buf,
>  	ret = count;
>  
>  out_unmap:
> -	for (i = 0; i < nr_pages; i++)
> -		put_page(pages[i]);
> +	put_user_pages(pages, nr_pages);
>  
>  	kfree(pages);

