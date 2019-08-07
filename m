Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 360AAC32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 16:59:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5221222FC
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 16:59:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="OjQfnav/";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="iMZeJU8p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5221222FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63E766B0003; Wed,  7 Aug 2019 12:59:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C9B86B0006; Wed,  7 Aug 2019 12:59:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41C306B0007; Wed,  7 Aug 2019 12:59:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4176B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 12:59:41 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id p18so6121050qke.9
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 09:59:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=4j5K2HWRx8Bh6Oju13KR7IhFUpgfEB1OrwxwTgXeUU8=;
        b=D8DqoQChcDg28AwXKr474EkLLwS3NjETpQ1bT7vJQTgt6N9KJ09kK3WY7GGIW78Dfe
         ca50xb8kNMspVr6kij47McnauHX1mU2u5A0+RXU3BnNXknS5Hq2yZaM1zfarNUyr21mg
         zRSCqSqqzF2Q7WMECLLrbrgRjmYZwR0FbiTlc6Uqceb+gGsp4F+UDL7dEnBGe852jPdl
         nT9NazDoh7z4HDRtD8jJx14/S1QZKWRFwl1ZV3TbINMuLYdiBCBd0EViU/kidte0N2YF
         tuRrKMxYXPGMkS8fqRaDF05vJVe1Mf9F0s8Zz/yM5NXyFFZnkQO6lTxL+dmVSzbJ/gpj
         K++Q==
X-Gm-Message-State: APjAAAUfax21TEW+hiLFRiEcnDzTqB7H+46UPWr8RTBLOkJZERKl20MB
	+Weu1DCIfzaC+Da+t+YoXkdbtY6QlEgOF+MiXhKcs4qyRCF6ghBfVpYAexLX+kEdizWxZUTBgmy
	e5oqhzG7cXAU/PtVxKQUgvXMfEaTyOUiuUutFIujNGtoET+p+HgvhFNg65jYNeuTatw==
X-Received: by 2002:a37:f511:: with SMTP id l17mr8434495qkk.99.1565197180854;
        Wed, 07 Aug 2019 09:59:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8/ULOANwge5x8/c1s7imoD8/63HQ5+OFZYDaL9APngzf1qrZP3laQADipY1QEyiE/74zF
X-Received: by 2002:a37:f511:: with SMTP id l17mr8434463qkk.99.1565197180225;
        Wed, 07 Aug 2019 09:59:40 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565197180; cv=pass;
        d=google.com; s=arc-20160816;
        b=gtEhHDJPjFhw3CWc8fnIksKIY/0ToSbU0A/7Vi3CP2Wk92beVr81lpS75eZptVWY5T
         FO1rAKdYZ47nxbLTn2TGKiAFZJr54vUKUDQgMBvGjmp5WoKGB0DSK7fZtuDDPzWGn9yo
         sHxDxKZggJY/Wk/R7HJznXhc/wQaxwkoaLLmbqqC1gsgzfJVmJSRc3Kdtm5Qf+pNpw+W
         CRp2i1ui4+fg0T9Id+tN1k2jSCy2nTV/ony58M3/gX5bQ/uKpYERKlFaIvBOOjH52UrS
         yfS8azq7gdUM5QdqdpUuIMM81YmQBmsjaWNWM8gLEdi7ICE3FznJnA9P/x+WuvM5+3SH
         LOyg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=4j5K2HWRx8Bh6Oju13KR7IhFUpgfEB1OrwxwTgXeUU8=;
        b=jUxBgJOoJ+4XAvifMSSiECp9i/3RT6bOLt2UNgrnIkrv+DQ0xsRi4QDso3p1/sofuh
         Rga5BduC0/wwlFyHvrlN6yUIyifyYrGxMfbLyJC4yf9G2VtHkESOCxReuM+ereQcQCPZ
         /Rc5kQZ86W2s89jHbjCc26p/yQLHoruDx1U74vWZzZiFcOR2SwIVC8vYyjlVrgvie/rQ
         OnCW8y2f6X/2K+tQCK57d0WjsPamSOV3cFyIBw4VixnFvRi2ureELQXbxySvdJ7AsLXo
         Ps/vR26EKjqf19+EZtaezsmbpj2qXobCwDUYqg1sSxui1LTgcU6PSkU/x8/Dr8f40Rek
         5XBg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="OjQfnav/";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=iMZeJU8p;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q187si49821429qkb.241.2019.08.07.09.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 09:59:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="OjQfnav/";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=iMZeJU8p;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x77GxCm9022590;
	Wed, 7 Aug 2019 09:59:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=4j5K2HWRx8Bh6Oju13KR7IhFUpgfEB1OrwxwTgXeUU8=;
 b=OjQfnav/+GRyyP9ws0OQfNWyOClMK95fNTr2CHbug2dyBTtZXJ+O8naA7a6fDD60uWRo
 +YgjIpQ+HaTnkG6+sfeBxX0m4zicZYRufYHmrFdzHmnKeeRenB3he2bSZzReS14hLlcE
 6eKrW2Ao8fY59t+MZtsF6Bl8oZhYtN4r+Wg= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u7vjs9crw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Wed, 07 Aug 2019 09:59:16 -0700
Received: from ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) by
 ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 7 Aug 2019 09:59:15 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.103) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Wed, 7 Aug 2019 09:59:15 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=KuHJs1VYhXs3L3YTY5/U7xq4Yd/P4glFqNHJ08oAdD9gDQQ1bxf8K/La8I1JUgmepz/w0s3augeTPmnV9KD1KRgp4lxo7XHm2cQIRI+zoAbtnuaz0KbCUzL+SwO3E+VNbALnxOQAXzaXZhFv2T6Sf57h3tTS72lFIbOO8PeKon7liDMRuUU2e8T3BipVLKj9RQbAa0OdBnZv8LAb2thYetpKLYG+zAnzwKho3eea4vo6/AVK8DWj32ju39dZUSwIyfD7zPB5S3jH3BJD0zAKF+H4qTUXHicCiPs30iFrhBo0MxXFKKLv8rGcGrVZRO6K3wai8UzVHBzoDSTo0b6Alw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4j5K2HWRx8Bh6Oju13KR7IhFUpgfEB1OrwxwTgXeUU8=;
 b=YasDCOoaCMG1WroKLyAhCq24TXpg+5UmG7S4Ky9Qh3aafgLpNiIHoUua7d+VpLzSG9hpIOzquW00Bx+FGLFKURJXACk+Gm00VJPYMSsikZ/d9m4y+SsbhnN30agL01xYvJu87p5qk+YQCJ+CvKZJK8A4WZwHeKHygO6QeE6D1g7RjNdVET4xBTAYvBeC6pMAKcnUndk3vzcTCq80IUm4oNtfGbAHnKDkW6U0njp04rvh/XbCEH7CgPcLUNLlT4uKgaN2u5GsUmuURDyVYIJ/V3DUGR23GqT0P5anoDKsfZJR9udTapfdqlhz1pYT7CeBvIEJN5i3GzliIxF7UiOx1g==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4j5K2HWRx8Bh6Oju13KR7IhFUpgfEB1OrwxwTgXeUU8=;
 b=iMZeJU8pvkdV57/BoIbOhMyV1+zafNJmr2wetxXUP1iDU0P+GVD2ZpnOpg0NFC/GHl3GgxtgTNodKqPMExaEN1snlWia+SkkCQzid5wQ4h+LvmHEuJn7D9OhlRa8UUbLZU7Xz+SpK59E1PS7U4wmD+RDA++Tr36BdrbE6EVehEk=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1326.namprd15.prod.outlook.com (10.175.4.135) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.16; Wed, 7 Aug 2019 16:59:14 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d%9]) with mapi id 15.20.2136.018; Wed, 7 Aug 2019
 16:59:14 +0000
From: Song Liu <songliubraving@fb.com>
To: Randy Dunlap <rdunlap@infradead.org>
CC: Stephen Rothwell <sfr@canb.auug.org.au>,
        Linux Next Mailing List
	<linux-next@vger.kernel.org>,
        Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>,
        Andrew Morton
	<akpm@linux-foundation.org>
Subject: Re: linux-next: Tree for Aug 7 (mm/khugepaged.c)
Thread-Topic: linux-next: Tree for Aug 7 (mm/khugepaged.c)
Thread-Index: AQHVTTJXJMBKk+9UcEyVbeuM3CTH0abv6HuA
Date: Wed, 7 Aug 2019 16:59:14 +0000
Message-ID: <DCC6982B-17EF-4143-8CE8-9D0EC28FA06B@fb.com>
References: <20190807183606.372ca1a4@canb.auug.org.au>
 <c18b2828-cdf3-5248-609f-d89a24f558d1@infradead.org>
In-Reply-To: <c18b2828-cdf3-5248-609f-d89a24f558d1@infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:1a00]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3314d6ed-f0b2-43b2-03b1-08d71b5893c8
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1326;
x-ms-traffictypediagnostic: MWHPR15MB1326:
x-microsoft-antispam-prvs: <MWHPR15MB1326B5F8FB2FA5A4468B95D3B3D40@MWHPR15MB1326.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2887;
x-forefront-prvs: 01221E3973
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(346002)(39860400002)(136003)(376002)(51914003)(189003)(199004)(53754006)(46003)(53936002)(66946007)(8676002)(102836004)(86362001)(476003)(33656002)(66446008)(57306001)(478600001)(50226002)(8936002)(6436002)(66556008)(66476007)(81156014)(81166006)(53546011)(76116006)(14454004)(256004)(64756008)(76176011)(68736007)(6916009)(6506007)(6116002)(316002)(2906002)(4326008)(7736002)(446003)(486006)(305945005)(25786009)(36756003)(229853002)(6246003)(54906003)(4744005)(71190400001)(71200400001)(6486002)(2616005)(5660300002)(99286004)(11346002)(6512007)(186003);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1326;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: bpSc9KJPogcX4Xp5xpzav9nvkaYAB25bazC5aCIBXBGAf15/cQhBwvJS+ayhbWQH7DacdfeBiorHWkE06yHzZaI3Gpl2z+xveehvLDkZQppT8aJ+9cp9JFYJETdSrhoG/T8fg4ihH4PNU2vj3uZ6+ZLkrS0Jf9h8kdDrRFGeOwW4HuqpA9ONpbdIK7kpd1IDIh2+Y5uDMZI2wrWFKwjXVwlqrT3wNIrY36koyb2exdFonaz9dW+XY1vGhaOi2uQZ6a7vjX7i/0Mo/TRV9IK6KZmUjBMzjPKPEAy6ZHOAAKk7s+xRIthw6g6sVT4Nw1fBOkMnsN+msCTXx6EuntslPeh5mAWqqZ9y2qLNBQ7OiGn9qcMErVCIbBL+MNee1I3VLrkvPdH0SkiFG2d8ZZHo6X0j11ihrD0Zc7lPR5fCdOs=
Content-Type: text/plain; charset="utf-8"
Content-ID: <EF0D9557DC1D95428B318AB2E57338AE@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 3314d6ed-f0b2-43b2-03b1-08d71b5893c8
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Aug 2019 16:59:14.5056
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1326
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-07_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=870 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908070166
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgUmFuZHksDQoNCj4gT24gQXVnIDcsIDIwMTksIGF0IDg6MTEgQU0sIFJhbmR5IER1bmxhcCA8
cmR1bmxhcEBpbmZyYWRlYWQub3JnPiB3cm90ZToNCj4gDQo+IE9uIDgvNy8xOSAxOjM2IEFNLCBT
dGVwaGVuIFJvdGh3ZWxsIHdyb3RlOg0KPj4gSGkgYWxsLA0KPj4gDQo+PiBDaGFuZ2VzIHNpbmNl
IDIwMTkwODA2Og0KPj4gDQo+IA0KPiBvbiBpMzg2Og0KPiANCj4gd2hlbiBDT05GSUdfU0hNRU0g
aXMgbm90IHNldC9lbmFibGVkOg0KPiANCj4gLi4vbW0va2h1Z2VwYWdlZC5jOiBJbiBmdW5jdGlv
biDigJhraHVnZXBhZ2VkX3NjYW5fbW1fc2xvdOKAmToNCj4gLi4vbW0va2h1Z2VwYWdlZC5jOjE4
NzQ6MjogZXJyb3I6IGltcGxpY2l0IGRlY2xhcmF0aW9uIG9mIGZ1bmN0aW9uIOKAmGtodWdlcGFn
ZWRfY29sbGFwc2VfcHRlX21hcHBlZF90aHBz4oCZOyBkaWQgeW91IG1lYW4g4oCYY29sbGFwc2Vf
cHRlX21hcHBlZF90aHDigJk/IFstV2Vycm9yPWltcGxpY2l0LWZ1bmN0aW9uLWRlY2xhcmF0aW9u
XQ0KPiAga2h1Z2VwYWdlZF9jb2xsYXBzZV9wdGVfbWFwcGVkX3RocHMobW1fc2xvdCk7DQo+ICBe
fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fg0KDQpUaGFua3MgZm9yIHRoZSByZXBv
cnQuIA0KDQpTaGFsbCBJIHJlc2VuZCB0aGUgcGF0Y2gsIG9yIHNoYWxsIEkgc2VuZCBmaXggb24g
dG9wIG9mIGN1cnJlbnQgcGF0Y2g/DQoNCkJlc3QsDQpTb25n

