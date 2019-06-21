Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E9E6C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:35:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24B532075E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:35:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="n7PC265D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24B532075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B70C88E0006; Fri, 21 Jun 2019 11:35:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B49818E0001; Fri, 21 Jun 2019 11:35:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0F8E8E0006; Fri, 21 Jun 2019 11:35:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 822198E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 11:35:41 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id i133so11119798ioa.11
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:35:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=6t/T0oCX3FYtWnSX59C7RPueclXGYaVh3ih9FejJyy8=;
        b=biY9Exs/WYLfHPNXOQZbwmGln+rljMKblFmZLtqgaAwjCntbf0Wbd4N8iaigGuWkS1
         usOXOBGlzL/KTegGNDLGhiJ8Vrr4QYsWFkaN1EJsxjJDp1adtpimqTeNMDo5WdiMQ6Tm
         SfPGFh58lWI8ujYdxwfj4+94P+gGA/hHOwm+gNfDVRRdLnOszPBI9qoUF57U7B0M7Xjd
         TEiMwMtIN1qb1DnrSMgSB6neAbL45Wg0PvNBVVdhgbGL6V9QMLmWzRCuVedDRUko8hkn
         yI9wj0jf42Xd+gITmy0W2B7NelZy4qxV+870gQeH75y6M1VPkQNjMSjgy/uB2F1XKcDU
         t/Fw==
X-Gm-Message-State: APjAAAUhNuO2epE40n/RvW7+k83WHKxhu5/If/Vlb6B8EeI84UGo5sIc
	WLrO2CzZJoZH5EeS7sMk6Q1y745hvtloelHJ64LHcGXn36GM3mbe8XRnEFsM8iESRYiNe+6E6bA
	3+Do9x5tfOWhPX82wcFE3Esq5rPdJKauTdWz+cHBrMNm1F126XaKo1d8CG+q9Uiq2AQ==
X-Received: by 2002:a02:7420:: with SMTP id o32mr26039827jac.117.1561131339787;
        Fri, 21 Jun 2019 08:35:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNBes9CBJT0U1OdW8LVvqCuAwwo00RJVoCmxs/lHQyB9IDK7jXqnSklWcUIqqf1cP1onGl
X-Received: by 2002:a02:7420:: with SMTP id o32mr26039612jac.117.1561131337482;
        Fri, 21 Jun 2019 08:35:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561131337; cv=none;
        d=google.com; s=arc-20160816;
        b=elm/D5oFpZ651tOgbdnrKMxXDfvc12+1DEv37L0MxCOFlHhJqiEec/Qp/jI7922TIo
         fWiHPQs4nTM/VNjVbIi7CYZb48YAwPfhMd6NG1BXj/T5DkbIdWhyBiulg/2P82ct3Lhp
         oR4z0IhkZsEi9LHvUFXHS5evmG8dG0nWhZlNOFvhfVH5MflRgh4wUbWNO0jGGcGCH3dj
         PxzU86nHJARoPedRlDn8H+lb7MME3TabahbLoWOLx3cmsKW+JBA/7C1caUtEt4QDSl94
         XV32Qa4iqJ/EQHvNP2xEcYUFDAM7Zc/M4eTtnIg0rqrmYXB/6fPBwl8XxRPiBJzZ+lOY
         j3AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=6t/T0oCX3FYtWnSX59C7RPueclXGYaVh3ih9FejJyy8=;
        b=kh5WNdZuhWvJV8MCjejRCWrrumqibEbfvki6wDRwtzeeHD/VVOOx7Ks9Cc0d/Lamlo
         SMzdE0nDESyipUu4+ceadoN03niUSSOoGnUtm9+W4mYcPgQ+rhHGfCRDYvOXPMrUmpF2
         /XyaBvF5kZbuMAr+ov0N1cl4u5T6Os0fiUbJ+AEm5p6BprBd44d0duqMkNYST4Z67W1j
         ehaCGYa4tZ5NkMF0oabft65gwUDJhefVasrc7guX+S6HOtoQuYWyNNuUjdFnxJpmJ9bI
         +tNs87ZnChp8uBWLWgnPXENIRdbqSqhkc13zvD4pT/HR1luLu+k4C8eSNfu7ZN/nf756
         l+pA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=n7PC265D;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t132si4175827jaa.53.2019.06.21.08.35.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 08:35:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=n7PC265D;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LFOCdN084301;
	Fri, 21 Jun 2019 15:35:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=6t/T0oCX3FYtWnSX59C7RPueclXGYaVh3ih9FejJyy8=;
 b=n7PC265Dn1bw/BeVQsMjARhjLsH2Q5nXXw5HrQQxZRruJV3Pk3wuDJoJppdU8WjTwsE5
 IFOO4VQ1ALO3Tkqca1A1aKFr2myITmN65QxfOid1gg19CyyUUp5tW5p0gcveHhrEOhRp
 bccPzjsBjxJ37TIq0DEoxTFJ3GSerzNRpyQgmcNIrgRZcWIJi6frNAUKxJQrh1B7Domg
 h+0kFLkrc++e4VL6uWl+SqEVobF25+Aly2yk1RoVooheayqd01ChzxdKKr3O9if86pf1
 0CuQzsjTBC6fhX2gfPmrldWHTXgV8F98JdJPt1DFwiWomTWPOxESNbF+r+mTo403B7Bo dw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2t7809q6yq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 15:35:20 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LFZJQK100494;
	Fri, 21 Jun 2019 15:35:19 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2t7rdxtbm7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 15:35:19 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5LFZDpA005218;
	Fri, 21 Jun 2019 15:35:13 GMT
Received: from [10.154.105.108] (/10.154.105.108)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 21 Jun 2019 08:35:13 -0700
Subject: Re: [PATCH 01/16] mm: use untagged_addr() for get_user_pages_fast
 addresses
To: Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>,
        Nicholas Piggin
 <npiggin@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
        linux-kernel@vger.kernel.org
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-2-hch@lst.de> <20190621133911.GL19891@ziepe.ca>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <9a4e1485-4683-92b0-3d26-73f26896d646@oracle.com>
Date: Fri, 21 Jun 2019 09:35:11 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190621133911.GL19891@ziepe.ca>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9295 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=857
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906210125
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9295 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=897 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906210125
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/21/19 7:39 AM, Jason Gunthorpe wrote:
> On Tue, Jun 11, 2019 at 04:40:47PM +0200, Christoph Hellwig wrote:
>> This will allow sparc64 to override its ADI tags for
>> get_user_pages and get_user_pages_fast.
>>
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>>  mm/gup.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/gup.c b/mm/gup.c
>> index ddde097cf9e4..6bb521db67ec 100644
>> +++ b/mm/gup.c
>> @@ -2146,7 +2146,7 @@ int __get_user_pages_fast(unsigned long start, i=
nt nr_pages, int write,
>>  	unsigned long flags;
>>  	int nr =3D 0;
>> =20
>> -	start &=3D PAGE_MASK;
>> +	start =3D untagged_addr(start) & PAGE_MASK;
>>  	len =3D (unsigned long) nr_pages << PAGE_SHIFT;
>>  	end =3D start + len;
>=20
> Hmm, this function, and the other, goes on to do:
>=20
>         if (unlikely(!access_ok((void __user *)start, len)))
>                 return 0;
>=20
> and I thought that access_ok takes in the tagged pointer?
>=20
> How about re-order it a bit?

access_ok() can handle tagged or untagged pointers. It just strips the
tag bits from the top bits. Current order doesn't really matter from
functionality point of view. There might be minor gain in delaying
untagging in __get_user_pages_fast() but I could go either way.

--
Khalid

>=20
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097cf9e410..f48747ced4723b 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2148,11 +2148,12 @@ int __get_user_pages_fast(unsigned long start, =
int nr_pages, int write,
> =20
>  	start &=3D PAGE_MASK;
>  	len =3D (unsigned long) nr_pages << PAGE_SHIFT;
> -	end =3D start + len;
> -
>  	if (unlikely(!access_ok((void __user *)start, len)))
>  		return 0;
> =20
> +	start =3D untagged_ptr(start);
> +	end =3D start + len;
> +
>  	/*
>  	 * Disable interrupts.  We use the nested form as we can already have=

>  	 * interrupts disabled by get_futex_key.
>=20


