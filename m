Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF8FBC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 20:06:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B58F20883
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 20:06:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="i+ihcJfD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B58F20883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B53C76B0007; Tue, 11 Jun 2019 16:06:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B04806B0008; Tue, 11 Jun 2019 16:06:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97EB76B000A; Tue, 11 Jun 2019 16:06:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77A8C6B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:06:47 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id j10so3227261itb.0
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 13:06:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=chD9BHu2Q8n/vFf6CCiBN6lp1HXxmyrKtdEjtx98SfY=;
        b=PQm9k4kFEz+B2KR/SCHyPwbrfjdGytV/dQqYqPs27FuzIzXLrwvnL3N0TM/C3Pglj9
         wyyh3+Z32+1yazLfETmoqS/mP04N/qd8rDZ/11U91l4ev4w9hKx8+7kc1roMydz9+xpe
         6eE/IPT7Msy3i98I/JsyomT0R9TnrJkpbA8W4z0HWInJDujDQX6kCbQcSPhvdGAMFfrl
         xtgqgp+O65mGoZyfVz+NlcneS9WWpGTJiYjPE/3Bm4I+0fXNP9i+8Ux9yCWxaAGZs8Qv
         J1DTrrOyRMfLd0MZNIktThUuxacXSdD3x5sLv+IZXPsSBI+Ppg641G8j2JCqDav/uf7L
         ZXCQ==
X-Gm-Message-State: APjAAAXf78ucPQWJ0jeWDscRvtY+y+eaGNEVY3KG2Wjw8Zyj6128/SuU
	jRj94olXiaIfGUhni9nbQaJOvNLtKyMTHb0uwhDuk9DvOAl1uIVuIC3/cSkm5+OmoajHfZJ+8RE
	dxUEbeVcna8fRWyTIArC52kktxqBH9i/xz8906MUUMRLhUfw9hjBqa/w2qwNFg/fj7w==
X-Received: by 2002:a24:f443:: with SMTP id u3mr15474990iti.29.1560283607206;
        Tue, 11 Jun 2019 13:06:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqwOj68ojONt5I7lZaS7nR6olM6gAnyhfORUFpXjAemreyv3KNqH2vsZLBYi1NTGOEVLZx
X-Received: by 2002:a24:f443:: with SMTP id u3mr15474941iti.29.1560283606285;
        Tue, 11 Jun 2019 13:06:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560283606; cv=none;
        d=google.com; s=arc-20160816;
        b=vdBFgJLemmhL+gstp8bERndq7G/os7HHZQw25rd68AuUWxrza7rljQTbuEl8kbvfQi
         cPQMmpsdLy7TPopRHXZnNRDLUsYXfuHrMU3D9YqLt5a1zWWmh9DuohZtcV/akpK/2k8R
         HiwZH+SWX0jpcAwUwIzWiXnxcwkc1/La9emNQaCclXfkYqk/386y6vOhHRpGFLHyWGF9
         VMhmCTT+9KQ4N+CdJ7JdpgFu3B6qnBhw25JXOfsL1Bz+yPfFlZYeBNjvm6WVtnYFG6p/
         nqDE2BDJGoHFI0MoVzGdECGcSuXMtb5N2q5QQfp/p/T9EGOuSTcazgh0gB+En4oA512s
         BhmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=chD9BHu2Q8n/vFf6CCiBN6lp1HXxmyrKtdEjtx98SfY=;
        b=ibZpxL2QjVrIzyHkp7PE09zV9g9oguCS1hLX+ZUJGyRRCRXKRn/HDB7Rzoj4Kuvclr
         MyOTR5bSE4l6T8U9JOIYYwhH0AR2ASafjxVjxUat9AQKq96RWoNR/Sb0T30b5hKKYL3r
         WKWwfR5Et+FlgnGURdbRkzZOY2rNkmjT4xThfvy9seZ5Lb0Lyj7FjbAAhxROAhUs5ZTM
         f7RZJWGFJAv704Df4K4y5Zq3lj2gc/GIUXACdMnC+B7Tqhkh3jg76fkIyBPtOlb2hNW4
         8Uldqama6Zf+mnI00mR8efNo7HX/CM1RNse3bkjgY7HWp1mljdZD/U3SGF7VR4PPvg99
         gswQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=i+ihcJfD;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id i20si9849067jaf.72.2019.06.11.13.06.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 13:06:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=i+ihcJfD;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BK5X7D176393;
	Tue, 11 Jun 2019 20:06:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=chD9BHu2Q8n/vFf6CCiBN6lp1HXxmyrKtdEjtx98SfY=;
 b=i+ihcJfD+r++tCN09DcxE+9SdhIRXslpbsen1Ly2b/r82XpfipS+cg5oxIFDHr5z/GAU
 VrRdu7NdT1KOdFyjMhexY6IfvMPY77FUH+FKxtIUXO8d1C0e0tDTPRmvp1FdzV8V7pYX
 U4IzADiDszYzTuo1y6F4qZFiT2b9u6Cz8QDPrN+6Sqlg39FglRjDj2+y+RKoGD/iKR6m
 uDqlrJDwwIbHmVtlRXKy/zbwpgKr8Ch3G7MbdDDHDEU1fdVCH38z0MVPNm3oNSiK0LeC
 adAcFZjzJlLyTbihfu+4rXpoW5PNw7BgFZdrw7mehFHTf2SW6/39ZzEaisuCtPm7xaov 9A== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2t04etqfpk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 20:06:20 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BK52LA147470;
	Tue, 11 Jun 2019 20:06:20 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2t04hyj0wv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 20:06:19 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5BK6Df4017807;
	Tue, 11 Jun 2019 20:06:13 GMT
Received: from [10.154.187.61] (/10.154.187.61)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 11 Jun 2019 13:06:13 -0700
Subject: Re: [PATCH v16 03/16] lib, arm64: untag user pointers in strn*_user
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
References: <cover.1559580831.git.andreyknvl@google.com>
 <14f17ef1902aa4f07a39f96879394e718a1f5dc1.1559580831.git.andreyknvl@google.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <dd2de772-bd55-86e3-0812-2e01ae97f8fa@oracle.com>
Date: Tue, 11 Jun 2019 14:06:09 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <14f17ef1902aa4f07a39f96879394e718a1f5dc1.1559580831.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906110129
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110129
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/3/19 10:55 AM, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow=
 to
> pass tagged user pointers (with the top byte set to something else othe=
r
> than 0x00) as syscall arguments.
>=20
> strncpy_from_user and strnlen_user accept user addresses as arguments, =
and
> do not go through the same path as copy_from_user and others, so here w=
e
> need to handle the case of tagged user addresses separately.
>=20
> Untag user pointers passed to these functions.
>=20
> Note, that this patch only temporarily untags the pointers to perform
> validity checks, but then uses them as is to perform user memory access=
es.
>=20
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  lib/strncpy_from_user.c | 3 ++-
>  lib/strnlen_user.c      | 3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)

Looks good.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>

>=20
> diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
> index 023ba9f3b99f..dccb95af6003 100644
> --- a/lib/strncpy_from_user.c
> +++ b/lib/strncpy_from_user.c
> @@ -6,6 +6,7 @@
>  #include <linux/uaccess.h>
>  #include <linux/kernel.h>
>  #include <linux/errno.h>
> +#include <linux/mm.h>
> =20
>  #include <asm/byteorder.h>
>  #include <asm/word-at-a-time.h>
> @@ -108,7 +109,7 @@ long strncpy_from_user(char *dst, const char __user=
 *src, long count)
>  		return 0;
> =20
>  	max_addr =3D user_addr_max();
> -	src_addr =3D (unsigned long)src;
> +	src_addr =3D (unsigned long)untagged_addr(src);
>  	if (likely(src_addr < max_addr)) {
>  		unsigned long max =3D max_addr - src_addr;
>  		long retval;
> diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
> index 7f2db3fe311f..28ff554a1be8 100644
> --- a/lib/strnlen_user.c
> +++ b/lib/strnlen_user.c
> @@ -2,6 +2,7 @@
>  #include <linux/kernel.h>
>  #include <linux/export.h>
>  #include <linux/uaccess.h>
> +#include <linux/mm.h>
> =20
>  #include <asm/word-at-a-time.h>
> =20
> @@ -109,7 +110,7 @@ long strnlen_user(const char __user *str, long coun=
t)
>  		return 0;
> =20
>  	max_addr =3D user_addr_max();
> -	src_addr =3D (unsigned long)str;
> +	src_addr =3D (unsigned long)untagged_addr(str);
>  	if (likely(src_addr < max_addr)) {
>  		unsigned long max =3D max_addr - src_addr;
>  		long retval;
>=20


