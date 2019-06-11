Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F1B0C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 20:18:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF4E22080A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 20:18:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="aNfZmQbN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF4E22080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50B2E6B0007; Tue, 11 Jun 2019 16:18:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B96D6B0008; Tue, 11 Jun 2019 16:18:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 382996B000A; Tue, 11 Jun 2019 16:18:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 17D716B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:47 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id d135so7762902ywd.0
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 13:18:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=pbmzGiYbk5X7Ese6X3ZnPOdFp3xt858d68MV4hL41o8=;
        b=IqvricfmiA3Pt0sAw+mqpLLkZkvlQ4rEtXslo5jzxx9I8ZAr1oBPbSHznTud34zNgU
         PnSsmmcpe+ILRPvMZMXfMjKA4Cmw1JArIHE2rb7du0HHRxNomkGYd/IqrD0sGkgWmTWX
         G00b9ODeDlTJrRh5nhlDNwYbaXkHpKJoqGDuYS71TZO0kyypDuanuV5/GGVVufCdd7cR
         cf06RH3B/naYrka2nePIPHISAnWqSol/iWDg1sPWDd2WI+BMYeg1a7nDFQymr10SUqX7
         HeXKkepYU5100fvT4GQ/wtOkZRreVyNWGPd1zEk0BYPoFZpgBtz5xkJvpv3SuoPVVrO3
         0Y3w==
X-Gm-Message-State: APjAAAWEBkpitEZA++P4tNXVJ/d85DYJceZM1Chsckomp6sZR5xYRZYG
	tCBmt9ERonRngFmdPKYecLB+pE7EQZdOqUAS+32YXOylIiuvfAK5fc3TInGPd/AIJxKp5XNcOiA
	bRcbfx6upyJYXRUjgZ9SPBU+2nr6Fg8vvrDImVM3jov6yAsrK32A9VqlhwbL47140OQ==
X-Received: by 2002:a25:35c2:: with SMTP id c185mr26165503yba.332.1560284326845;
        Tue, 11 Jun 2019 13:18:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrYs/AYH9v1wZMbTvfm80RPLcJ9OKvOumlCDmIjDFAk1tqvOLTAOgA5sXKHLy61Kz/8HBl
X-Received: by 2002:a25:35c2:: with SMTP id c185mr26165462yba.332.1560284326092;
        Tue, 11 Jun 2019 13:18:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560284326; cv=none;
        d=google.com; s=arc-20160816;
        b=OG2wMVuomshiOHxG0uTF3SleRavmeFZF6bTSzZRKM98mewcjoObSiv1C9rJOrSizv9
         RVNCqiJhOJ9OGtRMEYlngNR9xbtOdMPRXyTbxnFBUtZ8bEdij/l5JvjeOROJTEFl0DPY
         Z7ucw5pTzhqp8TDAYK5oYkCaHrxha71v5+9A2XzQZZZsshCxCDMx1HkR/Dd4t9xS3Xj9
         jkfrSUqeeR5neUXzjitXUzBkeC1CMeyRhyoDeWvLMngHXH2uVme2G1PjIK8sOW9ja9fb
         moUgysTp6mX9p/smjGUgPS7vS/249q9e7ZnUCSWg8C1UwtGJKEgIiXNii2F8bDRFrRLH
         pxJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=pbmzGiYbk5X7Ese6X3ZnPOdFp3xt858d68MV4hL41o8=;
        b=d4upUVS1ZNu9aoOyGN2vpYIvu1dksVsCjX0dPFp7nGz7XQ6NEl4nAef1VEn4lcI3Z+
         OSIaQ2517PvZ6qDUawjwexyd0yhTzGYBm9yFkuiP3eDs7AEYX4R8YggzAMfZ5TRJIoQL
         Mdo+c6sAXYoGHoDwX9wQB6/qU3dc5vFbzz1nXmLyVjy+XuXHNiz8pGUc+I7bv+PbDJir
         grHxuCMwx0VxwUtEo7fywH7hl7IzzXvdarchPbAuC5q2LRojj2gTPp3dyRhqC7Vejej3
         yeVcNIv6r0hZ+EMGTtbCd/0TOP+jjPwrdHZinv0CrLxqR/Ff5ev4XnVZDGaEfn7Fc+eT
         bcHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=aNfZmQbN;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 125si2398151ywl.456.2019.06.11.13.18.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 13:18:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=aNfZmQbN;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BKIG4j188569;
	Tue, 11 Jun 2019 20:18:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=pbmzGiYbk5X7Ese6X3ZnPOdFp3xt858d68MV4hL41o8=;
 b=aNfZmQbNP69ST1fFgutdWgNsoHsdTrxkUj7frUiu18XSvo5ty/Pn14NuvBXeongSeXs5
 W+/X6Zg80mFm1wMWd+zVCPCrQRP9QFtEH+cG0F7+uHlQwGnz+OWpR52bZNKpwSlJXUqv
 nMKBQhJ5HrsIVS6xiQg2bgHXLgu1p42NoCzZ/6Z08/cyHiS+fbUmTJNnXs/64PEUCVDy
 LuWVBuquORM9Cl3ljZsvAUUgUitqLMYyHC0GQkhfk1XGzvDOaXFduSfm+GFL8dwtAmDt
 oSfpqPsaE2SKGUeznCaVKxrCypUl2tuyIAul53FQXJZOqETR2JQgxWtw699nf/W05RQb Uw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2t04etqhfn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 20:18:29 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BKIAf4177892;
	Tue, 11 Jun 2019 20:18:28 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2t04hyj648-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 20:18:28 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5BKIMpX015673;
	Tue, 11 Jun 2019 20:18:23 GMT
Received: from [10.154.187.61] (/10.154.187.61)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 11 Jun 2019 13:18:22 -0700
Subject: Re: [PATCH v16 04/16] mm: untag user pointers in do_pages_move
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
 <e410843d00a4ecd7e525a7a949e605ffc6c394c4.1559580831.git.andreyknvl@google.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <d0dffcf8-d7bf-a7b4-5766-3a6f87437851@oracle.com>
Date: Tue, 11 Jun 2019 14:18:18 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <e410843d00a4ecd7e525a7a949e605ffc6c394c4.1559580831.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906110131
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110130
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
> do_pages_move() is used in the implementation of the move_pages syscall=
=2E
>=20
> Untag user pointers in this function.
>=20
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  mm/migrate.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f2ecc2855a12..3930bb6fa656 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1617,6 +1617,7 @@ static int do_pages_move(struct mm_struct *mm, no=
demask_t task_nodes,
>  		if (get_user(node, nodes + i))
>  			goto out_flush;
>  		addr =3D (unsigned long)p;
> +		addr =3D untagged_addr(addr);

Why not just "addr =3D (unsigned long)untagged_addr(p);"

--
Khalid

