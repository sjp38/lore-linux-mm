Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF8ADC31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:49:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76B50206E0
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:49:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="FFTbHZpN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76B50206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10C418E0002; Wed, 19 Jun 2019 12:49:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BC8A8E0001; Wed, 19 Jun 2019 12:49:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC69B8E0002; Wed, 19 Jun 2019 12:48:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD2558E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:48:59 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id 75so107529ywb.3
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:48:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LsU3zeuc/mQbMeWhWbxSsUGJ/a+JywecUJTpLD/kSKk=;
        b=Emjf/VUAIbyBY4yS7nh62kVEYSFf3MMiULVT/OQQSP4jt2v0mUubqn/5OmNSF9IDYU
         MM1t1d5UyE5/Woh/cxX1+jrHXYKuU7X81t6q4AW8lYUBNfgTjMZmmihhZb++CcTN+uKz
         XYg4Ho/o4Xhd3ynIw/daJY+Iv/Uv2DCz2OIdii3Uj89d/sCe09anIG9WVQgQ52LmZ8S2
         wNefBkcOuqJggZ1gTJjT/DX25xITDZhyXAhez4yKCSe/4pBT3WNUuVWvYwWyuQrPspw9
         Hwf9Ndc9hyrPwY3+YTFcXyItY0qJ+80guUEpxFhgOlrVxJzYAprcg1yfvipkWeFoS/gO
         az5g==
X-Gm-Message-State: APjAAAU82Sv5o4VDIVkt1MiyGfHcixvYhwfg07NFR8DMV2Xpsi4rnZ6N
	Ei9HRnsEbaiZ6iEoJWSWDWdw6NnuM5FAObTiTe4UDNyZwoZ5SgZDLZ3ShRTGKATMVheAfS4JMEw
	svcah7KPzdO8x05PkbF/7KDEqzryZhSYeUD63UjaOLIpqppLu5F3FVu3YXpRpoe8meg==
X-Received: by 2002:a25:cf44:: with SMTP id f65mr62732119ybg.66.1560962939552;
        Wed, 19 Jun 2019 09:48:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWIjmW31HQ6DLF9XL2wJtA0p1a6f2BhKMN3dlvIi66zp01b+neU0PkQnE5Rtz2qXShYFZo
X-Received: by 2002:a25:cf44:: with SMTP id f65mr62732090ybg.66.1560962939058;
        Wed, 19 Jun 2019 09:48:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560962939; cv=none;
        d=google.com; s=arc-20160816;
        b=SNHiWwAa+Z5H29wRPkG+mb9Kz5WovrjunWfOx0RektnOKbfpqlcPPoIIHot1Y3kn2N
         3m11ZIG64gh8hY4xw/NC1/XEUr8h3IHIYMWSF+QYRXBXSg/2lUUMujggL7Q45tgtAybK
         2/GKZP5usItsK5VpZRX1wWVKypD1FPm5N0o2LcH3sWqcGWnsVRNE3hz8Q0C2BK4An4Pn
         BI7WWPAejaBIY6Beei5oI2pz+fTXeUJV9OlmVCrY4KL4WfoS9mo1faOa6dstyLoxQ2aT
         s3cUOQNbI9CschzNDkplRbqDkdMbcwO76ZR/myHF7Br4ISnvm2WMhzXU8t9bl7iRiN9I
         yDnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=LsU3zeuc/mQbMeWhWbxSsUGJ/a+JywecUJTpLD/kSKk=;
        b=rqUpqv+0B4BVbLJ2x/iJADolq53ozeSvlkzYR4dBzliJIK2XV3VB7OlZnja01H5sLo
         DbaqR1d9jNvt058OXgE6kLiNeoiPeBGtkG7hLopTQPDcrkiZ2JnV0Qgih2xwYlmtsco5
         OwAx/O9hiMgnEg9E3obPwYVHhuWw4zsXpl/vA0hJsN0YmkJVwIycD/BJKgCatvjTc2fV
         EMpA6AbiwxyS+TKBmI2TnQHfC66sVgL5eUH8mbXnyis1nXjHbBDH/ude+5hXWrE+/Fay
         Kd9c/ST6k6SAojndkdy1QcMV25l1BBoN1vhaTnj1jjSQIkxV79X4zkxuORE9Y1hJDvMN
         hjwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=FFTbHZpN;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id h207si6513900ywa.133.2019.06.19.09.48.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 09:48:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=FFTbHZpN;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5JGmaMG059359;
	Wed, 19 Jun 2019 16:48:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=LsU3zeuc/mQbMeWhWbxSsUGJ/a+JywecUJTpLD/kSKk=;
 b=FFTbHZpNpzyDwT0Eazo9mrp8/3iEXjHoS/+pgViSDegRiIT56LXTiOpOiVuZY+ZQJp61
 m4sxzqaSIXQJ/SNqXXdUE75HtjKtsGvWt+m0angb4oDvjsPt3ChVFepvLTUMeYu2AmQA
 KOIThCjgEPdAHaZQr8fjpYFx6RuSpFV664Ojvx7dJzjFYaZgZ8v+ut+4wPEKrogGjNl+
 i1EU20jY+j7nwoouOiJoyAdRJ+fRlBREi0LRdxAlvFYskldgAWupL25hV8oWKRFcveIM
 gaA0dcncPMEcbPFyAma5BHgtCt0ok39bxE3HWcxWo0yWTh+lwriwAD1pX2NKsRtjZpiB xg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2t7809cjn6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 16:48:44 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5JGlKWG054029;
	Wed, 19 Jun 2019 16:48:44 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2t77yn71um-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 16:48:43 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5JGmfkY007697;
	Wed, 19 Jun 2019 16:48:41 GMT
Received: from [10.65.164.174] (/10.65.164.174)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 19 Jun 2019 09:48:41 -0700
Subject: Re: [PATCH v17 06/15] mm, arm64: untag user pointers in
 get_vaddr_frames
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
 <4c0b9a258e794437a1c6cec97585b4b5bd2d3bba.1560339705.git.andreyknvl@google.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <39b03c1b-d09c-4b29-0f62-337bf2382eb5@oracle.com>
Date: Wed, 19 Jun 2019 10:48:38 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <4c0b9a258e794437a1c6cec97585b4b5bd2d3bba.1560339705.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906190135
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906190136
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
> get_vaddr_frames uses provided user pointers for vma lookups, which can=

> only by done with untagged pointers. Instead of locating and changing
> all callers of this function, perform untagging in it.
>=20
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

With the suggested change to commit log in my previous email:

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>

>  mm/frame_vector.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/mm/frame_vector.c b/mm/frame_vector.c
> index c64dca6e27c2..c431ca81dad5 100644
> --- a/mm/frame_vector.c
> +++ b/mm/frame_vector.c
> @@ -46,6 +46,8 @@ int get_vaddr_frames(unsigned long start, unsigned in=
t nr_frames,
>  	if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
>  		nr_frames =3D vec->nr_allocated;
> =20
> +	start =3D untagged_addr(start);
> +
>  	down_read(&mm->mmap_sem);
>  	locked =3D 1;
>  	vma =3D find_vma_intersection(mm, start, start + 1);
>=20


