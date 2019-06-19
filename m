Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61837C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:41:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15C0221783
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:41:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="iM3Ngn2x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15C0221783
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD6098E0002; Wed, 19 Jun 2019 12:41:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5EE38E0001; Wed, 19 Jun 2019 12:41:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D96B8E0002; Wed, 19 Jun 2019 12:41:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67F1E8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:41:36 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p34so16566737qtp.1
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:41:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=4T5a0glbRa2aBSKkc/pjnTjMsTPHECFT1E9bbL1l2HM=;
        b=kXogA/LbDAEUma/n43iS2c676V303Wi1V48eCQih/FEERzOsA1+3cRp/v9+keyn5na
         57gn4aOYBtLmdj20KJ+puLqNO9IEbBZLqwDvMVJNPK8sS3fPBw671V67OBQMolvNVmxo
         OfEStPLZrmI5wiT/NzbpzfnrmE4Zapkh4dQSz9eiqqEHFICeYzqVWxzwZmZhGdD02ccc
         VYx0/+MDbh1nK1OnGTUFiVzDhp4KVu5tltmsbc07T4a9i71PhbQ9pQj3RYbLWxc16IPG
         OjXo9586GpvpcSBOhI0CE8vWsE+LlDFRp40a6DkJL7kOY5+L9aZTgKGlY5H2Rg4umit3
         g7jg==
X-Gm-Message-State: APjAAAUSAM0KgSH6xTRIT5M2/1Ad5T68Ars/iiJwjlv0NI8I4aXZaUjl
	CSFRBXGm4U+OBRSwqeFtfl0cq7oAwSHpYL0c/H4iULFB7RIm4tjGERKCHln/eyhI0vPNRZKXelV
	LjL5eifJsXrtldnlnIc/0Uu4v1Ijn2PEJ6oWGlECXLfCkDkJYlobJdVQAC3YVMBjQkg==
X-Received: by 2002:ac8:34f4:: with SMTP id x49mr96725870qtb.95.1560962496127;
        Wed, 19 Jun 2019 09:41:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1GxSNxv6+2mmVPVcc3bN0iDBPYLM9EsSxXYHQJUPb9hLbPAlWZKS6clPBl8qhizUfc01V
X-Received: by 2002:ac8:34f4:: with SMTP id x49mr96725815qtb.95.1560962495474;
        Wed, 19 Jun 2019 09:41:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560962495; cv=none;
        d=google.com; s=arc-20160816;
        b=OjogQrFqhUQsAklNEtsUFvOWB8id4s7k3mnG6rFMMoDJN/SFIzbKoscAIUph3QElZM
         tkUGBz0NQGnq3KiC44R7hpgZAq+JdcXgSZNnAy+phztrsvBo5OvfIS24chw5AsOTsyzr
         vkmLIp9JaQZC5kre7UkKfQFGY1mEz0e5000vOXeN+JqBYxYr1WZrg9tn3qPplFZsm4xP
         TK2hsg0QsyHACLaeylXZVWRmmT42NSB1iAYGfizyHI9wLwslYu6rMARYShdTC0YvNJ89
         vIHj9hh8YMcOlxYLxTw41sW+xvQiAshfOQ1ibnZlkwpmazCtiZwi/FqWIUiwrG+r3/cp
         VIRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=4T5a0glbRa2aBSKkc/pjnTjMsTPHECFT1E9bbL1l2HM=;
        b=PIWJ39MrO7tQHCnry1j8kB+3rKz1wOCQ6w6CZt06ChYSo0je1O9awsFCSFUb0Hbygb
         QLE0CRfxpsN0RhXDztxFFD60at3oFz1HqVXSW+SYRbxw2w4PDfWk9sKd42nayUwrF+tL
         SLIclrWS17vvI4ByVx3oWr8fLtGArv44gUjXslT/ed3+43Y5qhZ46D3q3/MbuXp+SIku
         hrohCQgbn3bm7l3ek5fPG5bmy6w1DJ8df4Uy8Ql3BqTfPY1N7fHE687fmvrYUnjh7+v+
         AfNS2OOkYr0c6J/kzcSXM+/0vqoLg0uv2919JrK5NfHD0LCCv78RtC3hWNRuQw9+RgsG
         S/2w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iM3Ngn2x;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id y1si2777476qto.202.2019.06.19.09.41.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 09:41:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iM3Ngn2x;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5JGZ3BA139193;
	Wed, 19 Jun 2019 16:41:19 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=4T5a0glbRa2aBSKkc/pjnTjMsTPHECFT1E9bbL1l2HM=;
 b=iM3Ngn2x6aaNg+8wMaz2TYv3kwfBr7esbrJ8PsegJPNksN4Z/YjPTI3TmHcIUAH5xIxd
 gAnjdNn//nUURYK/24P/Mz+8CWzLw/ldkJ0Ah8cTKTN8TsQstYz7Wc1JokBHslvlpojt
 t58Ckn54FcLS6JnUQMgNT/8sCvOqKf+qXUPK2SC5pwHYaAG2DxzZEfDTOmnxSxjRlk17
 81k1k3JZIHS9isv6MaXvl6eghbedIhy09UL0UJZ7M5tLa9EvLThKgTnTshAaPgND2Tmz
 VORmseouIshgIQ+DfXX2+2Cq67n27+huaukcohM59RMNDmLVIT4WZNeTT5o/4WBjQ22r Kg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2t7809ckb0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 16:41:19 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5JGeTfm168992;
	Wed, 19 Jun 2019 16:41:18 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2t77ynxysy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 19 Jun 2019 16:41:18 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5JGfFiP008310;
	Wed, 19 Jun 2019 16:41:16 GMT
Received: from [10.65.164.174] (/10.65.164.174)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 19 Jun 2019 09:41:15 -0700
Subject: Re: [PATCH v17 05/15] mm, arm64: untag user pointers in mm/gup.c
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
 <8f65548bef8544d49980a92d221b74440d544c1e.1560339705.git.andreyknvl@google.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <dbf2dd46-0240-f8a9-203c-4f1234c16825@oracle.com>
Date: Wed, 19 Jun 2019 10:41:12 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <8f65548bef8544d49980a92d221b74440d544c1e.1560339705.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906190134
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9293 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906190134
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
> mm/gup.c provides a kernel interface that accepts user addresses and
> manipulates user pages directly (for example get_user_pages, that is us=
ed
> by the futex syscall). Since a user can provided tagged addresses, we n=
eed
> to handle this case.
>=20
> Add untagging to gup.c functions that use user addresses for vma lookup=
s.
>=20
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>


>  mm/gup.c | 4 ++++
>  1 file changed, 4 insertions(+)
>=20
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097cf9e4..c37df3d455a2 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -802,6 +802,8 @@ static long __get_user_pages(struct task_struct *ts=
k, struct mm_struct *mm,
>  	if (!nr_pages)
>  		return 0;
> =20
> +	start =3D untagged_addr(start);
> +
>  	VM_BUG_ON(!!pages !=3D !!(gup_flags & FOLL_GET));
> =20
>  	/*
> @@ -964,6 +966,8 @@ int fixup_user_fault(struct task_struct *tsk, struc=
t mm_struct *mm,
>  	struct vm_area_struct *vma;
>  	vm_fault_t ret, major =3D 0;
> =20
> +	address =3D untagged_addr(address);
> +
>  	if (unlocked)
>  		fault_flags |=3D FAULT_FLAG_ALLOW_RETRY;
> =20
>=20


