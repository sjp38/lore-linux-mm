Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1C90C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:01:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD6502084A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:01:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="tQKRrCMR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD6502084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 499746B0003; Wed, 19 Jun 2019 16:01:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44AA38E0003; Wed, 19 Jun 2019 16:01:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EA9F8E0001; Wed, 19 Jun 2019 16:01:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 132C06B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 16:01:55 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id w127so608939ywe.6
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:01:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Vroyiiy2apNH9g1WQULlt3tAhqXh3qFzkC0thjbI/tY=;
        b=O5t7w5PthBctN+eLKy6zctdTxh2xQuiYThCRmSGA5zXhXNr/YR4kHI0xB6bLCzYxLs
         Sa8qHJnnrCJray6tEBBAmfxYpRU5gs8fPoQGA4tfM0HbFsxOW1VERAY4bai9kKPMMhWt
         LV87KrtkW2xEi5vLlIapki3/vEwxUd6zyyK2oECgqCYMu5g1u2bZcWu3m1BlP6rzLc38
         1CIERIogL7yDvggK0WvotmESwzU3teygWZTzrKgGrujHsre+fOd0ntIdKTBftJfdHg1L
         YdstMoAdgSZEBvL+FRDf78T3hgKgeYyXl8vTASU155VpfRKzuOl4u9UOflHJEg1wd0DI
         agPA==
X-Gm-Message-State: APjAAAV0/lrGZ0FWXvSLl9InCY3xZUcXNfLmv1ZXs8gg9h+J/pD5YXn7
	FqGiGjxnNtcfocKZPAqyOPT1yjKUAWNWC5T6mtbVfnk06PHxpTYWY6OXp+dsf3ZMqUmUquruvON
	OmtzV/oeGH0LKsgw7dKlk8xRIT0JUKm5zbc5qR0vSbcEiYFRsAAmSAVkG1hBqXxTZKg==
X-Received: by 2002:a25:acd8:: with SMTP id x24mr6291518ybd.461.1560974514770;
        Wed, 19 Jun 2019 13:01:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrdggkKwUjisHwjoLWntJ8mz45XFxwtccA4AlFBF60Jg3Hz1U0vihgbOP5qK/VjryW43md
X-Received: by 2002:a25:acd8:: with SMTP id x24mr6291477ybd.461.1560974514117;
        Wed, 19 Jun 2019 13:01:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560974514; cv=none;
        d=google.com; s=arc-20160816;
        b=SEp2hLU7PAXPUIJ81traLfdPgNsoh6oO+M2ERvIoqnZTnms0SonQElLhwkMaXBQktc
         wIc51RrYv4ukktwvSR69m4PMYdBg1rWxu0i28aSVzrAV4uOwLg9Cwydo33VqV5A49eWO
         vSajv8tCIjZbbf4BdpfOTxh/IMgOOH+IRF1tvKKVrOfv3qaAICBuJAxn0OsL6I/BIBLc
         1RYB6h5s+O15ayX7lbko1cFgr8UG+B3tXrVSZOB7gqWyi63+P4iXIc+fRtv0wDyDKLEm
         9lJR0DgfGRvAqDk8ONeZkZ/PWJApROKcAf2lGOphd715QTKSrfk/HCIpe4F5LFvi62gG
         N24w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=Vroyiiy2apNH9g1WQULlt3tAhqXh3qFzkC0thjbI/tY=;
        b=ObLh7xlkJc47QnXvQYlfGdGKY2hviuDPeurL+EmN9g/Btp7axmWZjvsoNyLPOuTQ+l
         dlJWKj+tGNGAIBiURxwVdQLqCtMPYy+Cl9gm+0xv3vx91fkIzD6SG2RAT/1/8r6+tTO8
         fFLJ10lWglITrrK1dti/LGT4LDpNCPgHP54O6dCCdyCrrN8yoH//EMJuWd1llsW5i2rs
         FNQj6bYMH7223ZBIsd13fGeT05jJmjSc1RZH911AaI+ea4D16PCC6vFQP07AqHswJQXJ
         f2CrGzglT1WtRn3gY3D0nc7Ctaqmkq6AG24GB4sD3YYWEluiJDiUwZqFO7VKgT3YAK4d
         uxEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tQKRrCMR;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id f125si7386223ywh.340.2019.06.19.13.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 13:01:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=tQKRrCMR;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5JJxCMh013084;
	Wed, 19 Jun 2019 20:01:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=Vroyiiy2apNH9g1WQULlt3tAhqXh3qFzkC0thjbI/tY=;
 b=tQKRrCMRIZFf76xHdG+OcQRJVCixkQdbl3HfJkhqJ6zQ5Fq71mORMALE81hvlqMU5cq2
 K4F8SUycLHKVrHTiluUHLfebVsFtIV4u7NZst1BEEOGeJtKDYGfPNuGNBzsiq/6/sG1m
 oHmWEWnqBcx8EHxc8VsLy1BXGGOzd4qHtZgUM3+RorIGLB7LeM8SEKQOzG7hpzi3tUIX
 cBqz1T+7bPFIBDeruJWhgHUJUNTS7jmoeogb9Jt64Fnvc0VzloFKzLKS2q+3tVxVQSnx
 bLlYN2Mg5EBeENllw30HSTJNHEAnYlsgKqvHUrkE60SZa/hI/hGzXCuuUFok8MhRdXuP yg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2t7809ddd7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 20:01:33 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5JK0U82055051;
	Wed, 19 Jun 2019 20:01:32 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2t77yp1s13-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 20:01:32 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5JK1P5e025354;
	Wed, 19 Jun 2019 20:01:25 GMT
Received: from [10.65.164.174] (/10.65.164.174)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 19 Jun 2019 13:01:25 -0700
Subject: Re: [PATCH v17 07/15] fs, arm64: untag user pointers in
 copy_mount_options
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
References: <cover.1560339705.git.andreyknvl@google.com>
 <4ed871e14cc265a519c6ba8660a1827844371791.1560339705.git.andreyknvl@google.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <14e49054-01dc-dab5-40cc-71434ea3852a@oracle.com>
Date: Wed, 19 Jun 2019 14:01:22 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <4ed871e14cc265a519c6ba8660a1827844371791.1560339705.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906190164
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906190164
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/12/19 5:43 AM, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow=
 to
> pass tagged user pointers (with the top byte set to something else othe=
r
> than 0x00) as syscall arguments.
>=20
> In copy_mount_options a user address is being subtracted from TASK_SIZE=
=2E
> If the address is lower than TASK_SIZE, the size is calculated to not
> allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
> However if the address is tagged, then the size will be calculated
> incorrectly.
>=20
> Untag the address before subtracting.
>=20
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

Please update commit log to make it not arm64 specific since this change
affects other architectures as well. Other than that,

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>


>  fs/namespace.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/fs/namespace.c b/fs/namespace.c
> index b26778bdc236..2e85712a19ed 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -2993,7 +2993,7 @@ void *copy_mount_options(const void __user * data=
)
>  	 * the remainder of the page.
>  	 */
>  	/* copy_from_user cannot cross TASK_SIZE ! */
> -	size =3D TASK_SIZE - (unsigned long)data;
> +	size =3D TASK_SIZE - (unsigned long)untagged_addr(data);
>  	if (size > PAGE_SIZE)
>  		size =3D PAGE_SIZE;
> =20
>=20


