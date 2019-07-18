Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C56CC7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:04:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED69E21849
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:04:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED69E21849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C1B68E0001; Thu, 18 Jul 2019 12:04:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 974086B000C; Thu, 18 Jul 2019 12:04:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 860E28E0001; Thu, 18 Jul 2019 12:04:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5257C6B0007
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 12:04:14 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u1so16898171pgr.13
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 09:04:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version;
        bh=NkxStK6Ejgq6UOe28qo0AqADLr5RHlwFP0zeeq2xsB4=;
        b=myuxzQl1S0mq87tsfFiV78By7HMiPQMtCW/rYG7w1JxOHv6jALjluJrqEXj3dxmF4v
         rnOzRcS2p4EPpRDDuIJ2oqz33ZQ2KRtYPrqNhufzsvCSnM9ycYFj2FP2vJhpmTbiFIAo
         8pCXoMclqATDn/FyAb1l9FOOQD3OtdIwe4cfy1NDaUv5xsO9k6aLMe2z4eOl1NoX8h3H
         ET0sib87JQ5P/8fMcUZefp/jEQieesBT1unZlCnxg9GoYR/7cCZODuTIpKsd/iVxqrPb
         7Sw/WqsDuUhA7FxoopDU2kvDVuHDEJsuJqKbHz6KPxWhtfkyFZP3QPxy5MiFouCImukm
         b7CA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=leonardo@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXjLyws1FxI+LozL2uixsESi7DFgAkS1u9fUs/KCYf4mpUMR8WS
	N+egrdYn/2u9EATmuPB/RI24VO9pum/vQQuAnU6W/r98dUjflab9Ab6HpjD6kHIzuVv2SmZq6l0
	tp8X6oQscWw53MfLZ+7XPFvtt7+st6HXyQdKuB062mthFfCWooEGBLkFexlrk2CkCkg==
X-Received: by 2002:a17:90a:7148:: with SMTP id g8mr52410967pjs.51.1563465854016;
        Thu, 18 Jul 2019 09:04:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzx6NLKnfoZsG/BRtS9BBnwQBhLPn9wZDJtCoUcuaq7m/+2b1sy4OjU2i4rCLYqyalgWctk
X-Received: by 2002:a17:90a:7148:: with SMTP id g8mr52410902pjs.51.1563465853305;
        Thu, 18 Jul 2019 09:04:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563465853; cv=none;
        d=google.com; s=arc-20160816;
        b=u8ty2KMc2Ic0EnatTNd8k1o+JvZEn2rLz79TQWOWBRHgOERwF4BvKOD7GgLXrBB5fJ
         40ytriW19TC+y0AriWALeKTllaYqqDegoJGrV/0ngi/FSyKfEwBAgVQQ+GU9HqsaqdH3
         gZbMjSDZ8z122olYRZpaQyeTVz6Hmo8gPW9O3+TbZw2IhPWtamAOhPKJJVtw0aKC+jjt
         rtIRBNBIWMXe1HWyKTfjk4irNcefsv/LNFYPrYiHUCU/8ZhO990KtPaabKc2pDhaoALr
         iyaruFm4KGDQDeg2SndrG6wtLRoad2e/aFphvXLm5lsAMO5j+wHyq7G755WTjtAYYfF6
         fSdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:date:cc:to:from
         :subject:message-id;
        bh=NkxStK6Ejgq6UOe28qo0AqADLr5RHlwFP0zeeq2xsB4=;
        b=Nzz2Vr+93fNoXk2oD6R0SOWd6JR8nBW9XNgL9sVpOtblAkkzSDvPO1UjJ7jiwyPt0O
         eMwcn0ztYQfFIFs4OYeQ/clW3kbzzmJRp7uSV3XadwN3+8xhLQXHMyPKClmn5JhCs8kE
         g43IHRGneZJXIQ2RTjfISyNCwvmDwd6hhm34EAM4Z1s+A3HzAgtpOT5AJLNIY+qldmFv
         3d64CT7Tcb/7OYWSSLutUk6PUH1Y8A9N2QjgnxRQvhmPxenGpCiIOwkahSvJpQ2iFQMw
         ZJYGS/52X66S3JkibfrT2Wu0/xAHeaIbv9JUu7IgmtiIWIPf7J3MqyeBndSyM3E15XGQ
         9mkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=leonardo@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 130si57379pfb.117.2019.07.18.09.04.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 09:04:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of leonardo@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=leonardo@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6IG3goE141977;
	Thu, 18 Jul 2019 12:04:10 -0400
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ttum1gyec-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 18 Jul 2019 12:04:10 -0400
Received: from m0098404.ppops.net (m0098404.ppops.net [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x6IG3txi143659;
	Thu, 18 Jul 2019 12:04:06 -0400
Received: from ppma03dal.us.ibm.com (b.bd.3ea9.ip4.static.sl-reverse.com [169.62.189.11])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ttum1gy1x-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 18 Jul 2019 12:04:05 -0400
Received: from pps.filterd (ppma03dal.us.ibm.com [127.0.0.1])
	by ppma03dal.us.ibm.com (8.16.0.27/8.16.0.27) with SMTP id x6IFxlLf016144;
	Thu, 18 Jul 2019 16:03:47 GMT
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by ppma03dal.us.ibm.com with ESMTP id 2tq6x7rhnm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 18 Jul 2019 16:03:47 +0000
Received: from b01ledav006.gho.pok.ibm.com (b01ledav006.gho.pok.ibm.com [9.57.199.111])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6IG3ll847120804
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 18 Jul 2019 16:03:47 GMT
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E89D8AC05E;
	Thu, 18 Jul 2019 16:03:46 +0000 (GMT)
Received: from b01ledav006.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DB94EAC059;
	Thu, 18 Jul 2019 16:03:43 +0000 (GMT)
Received: from LeoBras (unknown [9.85.162.151])
	by b01ledav006.gho.pok.ibm.com (Postfix) with ESMTP;
	Thu, 18 Jul 2019 16:03:43 +0000 (GMT)
Message-ID: <6cd8f8f753881aa14d9dfec9a018326abc1e3847.camel@linux.ibm.com>
Subject: Re: [PATCH 1/1] mm/memory_hotplug: Adds option to hot-add memory in
 ZONE_MOVABLE
From: Leonardo Bras <leonardo@linux.ibm.com>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
        Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki"
 <rafael@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike
 Rapoport <rppt@linux.ibm.com>, Michal Hocko <mhocko@suse.com>,
        Pavel
 Tatashin <pasha.tatashin@oracle.com>,
        =?ISO-8859-1?Q?J=E9r=F4me?= Glisse
 <jglisse@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Pasha Tatashin
 <Pavel.Tatashin@microsoft.com>,
        Bartlomiej Zolnierkiewicz
 <b.zolnierkie@samsung.com>
Date: Thu, 18 Jul 2019 13:03:42 -0300
In-Reply-To: <CA+CK2bBu7DnG73SaBDwf9cBceNvKnZDEqA-gBJmKC9K_rqgO+A@mail.gmail.com>
References: <20190718024133.3873-1-leonardo@linux.ibm.com>
	 <CA+CK2bBu7DnG73SaBDwf9cBceNvKnZDEqA-gBJmKC9K_rqgO+A@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-Y7h9unj5YKv7mDCLzT7g"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-TM-AS-GCONF: 00
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-18_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907180167
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-Y7h9unj5YKv7mDCLzT7g
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2019-07-18 at 08:19 -0400, Pavel Tatashin wrote:
> On Wed, Jul 17, 2019 at 10:42 PM Leonardo Bras <leonardo@linux.ibm.com> w=
rote:
> > Adds an option on kernel config to make hot-added memory online in
> > ZONE_MOVABLE by default.
> >=20
> > This would be great in systems with MEMORY_HOTPLUG_DEFAULT_ONLINE=3Dy b=
y
> > allowing to choose which zone it will be auto-onlined
>=20
> This is a desired feature. From reading the code it looks to me that
> auto-selection of online method type should be done in
> memory_subsys_online().
>=20
> When it is called from device online, mem->online_type should be -1:
>=20
> if (mem->online_type < 0)
>      mem->online_type =3D MMOP_ONLINE_KEEP;
>=20
> Change it to:
> if (mem->online_type < 0)
>      mem->online_type =3D MMOP_DEFAULT_ONLINE_TYPE;
>=20
> And in "linux/memory_hotplug.h"
> #ifdef CONFIG_MEMORY_HOTPLUG_MOVABLE
> #define MMOP_DEFAULT_ONLINE_TYPE MMOP_ONLINE_MOVABLE
> #else
> #define MMOP_DEFAULT_ONLINE_TYPE MMOP_ONLINE_KEEP
> #endif
>=20
> Could be expanded to support MMOP_ONLINE_KERNEL as well.
>=20
> Pasha

Thanks for the suggestions Pasha,

I was made aware there is a kernel boot option "movable_node" that
already creates the behavior I was trying to reproduce.

I was thinking of changing my patch in order to add a config option
that makes this behavior default (i.e. not need to pass it as a boot
parameter.

Do you think that it would still be a desired feature?

Regards,

Leonardo Br=C3=A1s

--=-Y7h9unj5YKv7mDCLzT7g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEMdeUgIzgjf6YmUyOlQYWtz9SttQFAl0wmF4ACgkQlQYWtz9S
ttTsWg//UPkI4eNdk7scQR2PRPAkZjgxrWG7nyrz1Aialac0oPIjqMV5q78zbrs+
tb9kezvYw+fsseOUJqgPv/MpEG4HtnZUNIugIMT6+S0Xn/W834Dk2LEdEEk6pjS0
+mbeaJr+bABCtzx5GUw55ah/oIMBC3u/TVW/HlcPbQ5hwcRt4mZ9LPbDkrJo7EN1
RMY6Bx3PilG27MaQ8hm/S5aN0XZUl8E1STs78uU7Et6wAm6P2o5+4BhMXQedHNk1
bQkI87P+gzvaVFaEijc/Os41BNwlOLDLzm8eO6VamobF5DkTawp+M8ZppRpDQrI4
a4WWzP9zydkvzlJRVtzhhvA20SjGBg9cqghmSM9i/o0GDCMeccLdcKLYSy7MHRje
yqkaVp8pN1BJtVtbnpi8I6r+u57EDtexOg+ScMzl23b0gfmybpRnXk5DvKrtyWkZ
C+0Pi+ZMGVXSZHYO2hJhsbBiAXaGo1MhCic33e9hQYHhTA7gfoVfcejBOTGCDUpR
U1J9NikqQQo0aqQqonCmh9G3WMDnz0sqmklai+6WXEtuYBaGlVWmT5GqD5c3E4tA
wn6KoKd/tooZdRO8pQHtToLgrP+jUdb9ZwhfneCxSMKZPtN/AXxryQUeiTdnKufZ
JbnrUDxPwwlLYgsvVfoYW8BhJh7IA4b+akGjtEcw/BqHKNWlxG0=
=VsNx
-----END PGP SIGNATURE-----

--=-Y7h9unj5YKv7mDCLzT7g--

