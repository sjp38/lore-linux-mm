Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 476CFC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:51:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0213F217D7
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:51:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="EcEEEMWg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0213F217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AC786B0003; Wed, 26 Jun 2019 13:51:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 534DE8E0003; Wed, 26 Jun 2019 13:51:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AE3B8E0002; Wed, 26 Jun 2019 13:51:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 164B96B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 13:51:16 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id t11so3763905qtc.9
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:51:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=pJtn37VVzLHGgxTNqg1ZlS6RKLrOq382izwrBCZb3DI=;
        b=HKSnNJLcDubq1FSQVNDWeW6/pTIi5Zx86TD2AUTV3Cg1PJoxXJqn5GWVSA70RGNFvt
         jBRycDJ1nhMrEtpBUJSqA5q1SFQG1U5tw/usntLrQwMsxO6Mt8eMs72mofbdTnU8IHd7
         p3vtfP/7XcWFGDCghnaeL+BNmFSQD7HQGle1Fh6lf3SgEZy4iiwDpZfrqreJrBfOyhvh
         91/64FY+QowFvMkXp/cEkHKscXfg9ity7dqNTjgNPuL19Crm5JTK6z2hqCnYgsEB98mv
         Gy8tdPI6x2l+TPhItN82cWhZOF2RlwAT6l35IUtAaFODW5uLcFcPSfRuzJcKZyXTTQi2
         fUbA==
X-Gm-Message-State: APjAAAXPtpucz3TazEQH8+jyPRaXFfRY6s18ZFXR2b9m7Dp7Kzh1CNOx
	m0ud8GM+UX6uXIzFb5iJEi7R8DWbQmwEhl64pE5XYEtdZPEJTTGLAiC65rMj8CH17Gd0o8LCn/l
	66Znewt4m+gn79ebM3ictWgsQvObFU34uJPsP4N6KCTt83oihkGRjzslLogqGYfH2qw==
X-Received: by 2002:a0c:b12b:: with SMTP id q40mr4792618qvc.0.1561571475823;
        Wed, 26 Jun 2019 10:51:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTFOBcphQ5z3i0EiNkgoC67hzrqdrRUyBI/HdYiJAlFyV3I+1DjjDAy/7TaRfvJENqW+/Q
X-Received: by 2002:a0c:b12b:: with SMTP id q40mr4792578qvc.0.1561571475256;
        Wed, 26 Jun 2019 10:51:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561571475; cv=none;
        d=google.com; s=arc-20160816;
        b=Oc90p0yDBIqv4shyELgc0Gbhk3cQ9dRUEwBRkaRhhqN7VduZNQnxxb8tAJrgUx3tpZ
         hZ+XRAhJLlVi5y2Lzvpu+TL7P8p8hCzwAVi7F2Zmiu7b610DDZCQQlEYQ2PhXlTvYY/E
         u3rbyL6VJ98ZNjdvpbkKP8RTsD4NbRGBZk+ggfdA2mzMoPPv2Te0YZMeK9OWILp4yaqL
         OswGTZ7F9wpzMQe4rlFYMqQATUmt118hpPPLDKJG1i2UdDwb/QiL26Sv6OWTmXlpsiiP
         tRY5Y+i4ef82LDLwu4pKLthvGbxipTOqJp6G4c9kE4tM5ZGNMAXG1ZMWnQKlinN07xJp
         xL9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=pJtn37VVzLHGgxTNqg1ZlS6RKLrOq382izwrBCZb3DI=;
        b=LXfHNtAqdq4/kRepqCIzT2KHrGYYo6EZQfGRmjescx2wCVSuq7WNdSYyp0lQt05z9m
         /zjANbUGMFVg2yLzS/I8DnSFxZ29d163mD56mU3Wx4WkF1so3lHpl3vOUHUBLN1yLJiz
         wp1mBtAVGJn5fNklE2DUiMUGQV2R+dvrWr+mtTY89D49c5lnQ7OtZEku3J2AnEIDY5sA
         iwLDAafif9OKm6Hz1MMwqizfm2mc068n/9FvEXGYs6mG+n1NwaWymNceSAMfkg1DGChA
         nFycqGqbGMrtenx8LF7DZfc/OgJUVBIZg10QoEDZwpslvyCZUTH5LabAe5BtqopuW5B2
         hYPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=EcEEEMWg;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a198si11971848qkg.342.2019.06.26.10.51.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 10:51:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=EcEEEMWg;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5QHd3BJ070052;
	Wed, 26 Jun 2019 17:50:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=pJtn37VVzLHGgxTNqg1ZlS6RKLrOq382izwrBCZb3DI=;
 b=EcEEEMWgDEbMDuMxTOR2oYeCSXUOQKHZ4+B/a0CiekDLmP8Z1U885QaSBhgXo+/oVJZ3
 SGbnV6cXs+U0YG4HT3njZ/iUUzFIuHHOFK70cZEOdOGApbgKUYX3eCJLdfQ3dKwGSNIl
 owHPVd1m79tjE2KLbk7nGdMWhkLr/F3ZBkkDI9hHrhy/y/e6IptZoUUgS8HTk7grA8Ud
 Bf4hJAICEUZKsbR/1JYmjjWhp4n+uI1QfmV/GKfsvqZ6rJZc12bBVgqeF5v8xkJ16pFz
 7wdP2Bakv0UvCbjPcmfUTGeqmf+Xk2K6+wWohnQ4b4rai+Y/+koOAVyMxoOJaa/ojH8K NA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2t9cyqks50-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 17:50:48 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5QHolV1005117;
	Wed, 26 Jun 2019 17:50:47 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2t9p6uwkss-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 26 Jun 2019 17:50:47 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5QHofTs013200;
	Wed, 26 Jun 2019 17:50:42 GMT
Received: from [10.65.138.107] (/10.65.138.107)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 26 Jun 2019 10:50:41 -0700
Subject: Re: [PATCH v18 10/15] drm/radeon: untag user pointers in
 radeon_gem_userptr_ioctl
To: Andrey Konovalov <andreyknvl@google.com>,
        linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
        dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
        linux-media@vger.kernel.org, kvm@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
        Vincenzo Frascino <vincenzo.frascino@arm.com>,
        Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>,
        Felix Kuehling <Felix.Kuehling@amd.com>,
        Alexander Deucher <Alexander.Deucher@amd.com>,
        Christian Koenig <Christian.Koenig@amd.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jens Wiklander <jens.wiklander@linaro.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Leon Romanovsky <leon@kernel.org>,
        Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
        Dave Martin <Dave.Martin@arm.com>, enh <enh@google.com>,
        Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>,
        Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
        Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
        Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
        Jacob Bramley <Jacob.Bramley@arm.com>,
        Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Kevin Brodsky <kevin.brodsky@arm.com>,
        Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1561386715.git.andreyknvl@google.com>
 <61d800c35a4f391218fbca6f05ec458557d8d097.1561386715.git.andreyknvl@google.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <28554e21-04b8-2461-e576-5abe0b53cd59@oracle.com>
Date: Wed, 26 Jun 2019 11:50:39 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <61d800c35a4f391218fbca6f05ec458557d8d097.1561386715.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9300 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906260208
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9300 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906260208
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/24/19 8:32 AM, Andrey Konovalov wrote:
> This patch is a part of a series that extends kernel ABI to allow to pa=
ss
> tagged user pointers (with the top byte set to something else other tha=
n
> 0x00) as syscall arguments.
>=20
> In radeon_gem_userptr_ioctl() an MMU notifier is set up with a (tagged)=

> userspace pointer. The untagged address should be used so that MMU
> notifiers for the untagged address get correctly matched up with the ri=
ght
> BO. This funcation also calls radeon_ttm_tt_pin_userptr(), which uses
> provided user pointers for vma lookups, which can only by done with
> untagged pointers.
>=20
> This patch untags user pointers in radeon_gem_userptr_ioctl().
>=20
> Suggested-by: Felix Kuehling <Felix.Kuehling@amd.com>
> Acked-by: Felix Kuehling <Felix.Kuehling@amd.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>


>  drivers/gpu/drm/radeon/radeon_gem.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/drivers/gpu/drm/radeon/radeon_gem.c b/drivers/gpu/drm/rade=
on/radeon_gem.c
> index 44617dec8183..90eb78fb5eb2 100644
> --- a/drivers/gpu/drm/radeon/radeon_gem.c
> +++ b/drivers/gpu/drm/radeon/radeon_gem.c
> @@ -291,6 +291,8 @@ int radeon_gem_userptr_ioctl(struct drm_device *dev=
, void *data,
>  	uint32_t handle;
>  	int r;
> =20
> +	args->addr =3D untagged_addr(args->addr);
> +
>  	if (offset_in_page(args->addr | args->size))
>  		return -EINVAL;
> =20
>=20


