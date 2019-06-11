Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01812C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:36:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC9FE2086A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:36:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="z2zysy0T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC9FE2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C53B6B0008; Tue, 11 Jun 2019 15:36:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 575F66B000A; Tue, 11 Jun 2019 15:36:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 467DD6B000C; Tue, 11 Jun 2019 15:36:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1234F6B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 15:36:15 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z15so1243789pgk.10
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:36:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=XR1k9/hTeFVGViPolkZIUh6rCPEU/P3ZeUnAtKG13/o=;
        b=W63/VUKogCrlLATksmZiZnVCmXYDKahrlLYF2spZdKqn8kCdWDqbsCcgDcj+xIRG6x
         Br3gG9fOS5El32ZnUZArtAXXOic/Hu7sNMW+e6o2G5/p843oXsbvarg0eoY9FgvmhOgO
         qWUYOg8bm22Up6o+CCA9RM+GjABd2lbFB2ucpwVEmAKXF0myzEwuAHy67Q+O7Aq2FgyE
         hQW7llYdHbPKPGCa2M8r/u/fZOw+gzb6iMphMv3cgg7EN8wGX5zrdvIuQIxoI++5a8Cq
         BLr4OyRtXPs5CYoC4Vh7Yn4Q7HnbhoLDmow0k32h9rxWfspe3syqyO8TobX0/5UIg9tW
         WRqA==
X-Gm-Message-State: APjAAAUDiZrJKSagJM2w6SnYiVPpwBQ6dhT4SGZpcDB1MbC3xkQVG16M
	lS82Do7hDeZP07Dr/W0GFzONflhQG6h7mvTFbvwChMULGu8P/bvn8evvHzCpiCo3lhec/I0QelW
	o0DG0+BELiWmNzmNzygwU7ubqJUrkXyQZwdfFaFHXmMfGapBEAca7K56RZRFYsjbmxw==
X-Received: by 2002:a17:902:d695:: with SMTP id v21mr61870238ply.342.1560281774742;
        Tue, 11 Jun 2019 12:36:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp76j8uPh/LfarCUXOkRyQbc0vpYj23kTzhc/fZLGRjvaZNVBZZXrfro7zLthbTz/7eyDe
X-Received: by 2002:a17:902:d695:: with SMTP id v21mr61870199ply.342.1560281774090;
        Tue, 11 Jun 2019 12:36:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560281774; cv=none;
        d=google.com; s=arc-20160816;
        b=F7Vjb/rL3XXU5PBfEnd69TEAo4bteMgbo8VFXh0E5Iu6atHL2Kgnclr5QFmIGQf6bV
         +/IYvYMRq/ji7xlze/RjMwV74RhGRnJqO661Enphdi+wEz+Wsqhoxr7H6/M+wMOENStC
         l+b/lMR0aVIWBrMWgxkbbfnpaP4BAeWMg05uytSxq7gfeQi8QxgmyiDArE1Kd3301/v+
         YqrhMG6i94KizKHtBL+2HHnIqndHGobtZrTzAJFPLXHrjXcJfAlqyXkBGP2cTpTyqZaU
         Hgc3ueSE4K5tNpDDJf1zA0J0wKWrDvDQaepVsshIO8jm9JG03VFXR2el6d+EMNpvQ0mY
         wxfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=XR1k9/hTeFVGViPolkZIUh6rCPEU/P3ZeUnAtKG13/o=;
        b=mgC4tvVLV8WZal+WgvkU0IgAkePfqYb2mE6fI1J2hV/kiAgvN6bHIeiW4UVIO8BF6m
         g6OUJTkUM8FlAtStkRExBFLtVh4KUwOKhY+jOyAehaszm+iBRPcTsTaEWcI5hSxD/DHo
         k7f1jZgmRhRjRrMTINE28o+F/v4DMJm1UKHW0RT//UEK0TVdh2AAP/OSRYcuBnGopF21
         ZP0zyo7zauxn602ErfGhIvjHleUN2tBbHtaj1NHl5mbrDqSmBweqwLPbCbxO6pxaiWVN
         j3On9MRkXQo2YnmyXkA8HvwRQAjJl2XWLA1WQwEksds608eJjWVN5QjLGQ28/K2pFYr8
         KggQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=z2zysy0T;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f16si13503874plr.340.2019.06.11.12.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 12:36:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=z2zysy0T;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BJZPgx146908;
	Tue, 11 Jun 2019 19:36:03 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=XR1k9/hTeFVGViPolkZIUh6rCPEU/P3ZeUnAtKG13/o=;
 b=z2zysy0TfCRFWv/zp3KooZKViDyYjCldDHO+HJRgr+UAo5HIbqpSKTBhD/M2QMVNFSLb
 PtSUW9Ul/yqC7srLx1ziPrf8qNvqdcHM7dHLCOAB0gu5M5XQ9CLeP41fpZdpVCacLdDd
 95fQd3fPeoFlC3Yk93XaxE68TBMKZ6E9Zq/2M1fzpHLF8OuvAoRqYua1cgWVyQ0Mc7Da
 fDlt7/N57QY718wHpPzl7C+c4cy8ox13bsfKh1ne99YEJfbCf3RKy3v9dKqViIL6PlJX
 Eus+jkJzPhx0V0DpELovHgQ6h8ghK5PPWC8OKSWAeD/H2lJMfuzoQchkurcLsKW8DDCI YQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2t04etqb59-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 19:36:03 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5BJYvmT077059;
	Tue, 11 Jun 2019 19:36:02 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2t04hyhkj0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 19:36:02 +0000
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5BJa0YV031560;
	Tue, 11 Jun 2019 19:36:00 GMT
Received: from [10.154.187.61] (/10.154.187.61)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 11 Jun 2019 12:36:00 -0700
Subject: Re: [PATCH 10/16] mm: rename CONFIG_HAVE_GENERIC_GUP to
 CONFIG_HAVE_FAST_GUP
To: Christoph Hellwig <hch@lst.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
        linux-kernel@vger.kernel.org
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-11-hch@lst.de>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <98e75b14-89f4-91b4-e836-2fdff188535b@oracle.com>
Date: Tue, 11 Jun 2019 13:35:57 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190611144102.8848-11-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906110125
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110125
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/11/19 8:40 AM, Christoph Hellwig wrote:
> We only support the generic GUP now, so rename the config option to
> be more clear, and always use the mm/Kconfig definition of the
> symbol and select it from the arch Kconfigs.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/arm/Kconfig     | 5 +----
>  arch/arm64/Kconfig   | 4 +---
>  arch/mips/Kconfig    | 2 +-
>  arch/powerpc/Kconfig | 2 +-
>  arch/s390/Kconfig    | 2 +-
>  arch/sh/Kconfig      | 2 +-
>  arch/sparc/Kconfig   | 2 +-
>  arch/x86/Kconfig     | 4 +---
>  mm/Kconfig           | 2 +-
>  mm/gup.c             | 4 ++--
>  10 files changed, 11 insertions(+), 18 deletions(-)
>=20

Looks good.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>


