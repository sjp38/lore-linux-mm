Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28ED6C4646C
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 22:34:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D320E20674
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 22:34:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Xn1zg9ac";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="fvm9/RRZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D320E20674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C7D56B0005; Mon, 24 Jun 2019 18:34:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 779598E0003; Mon, 24 Jun 2019 18:34:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 666838E0002; Mon, 24 Jun 2019 18:34:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 471BD6B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 18:34:34 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id q62so9347549qkb.12
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:34:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=yWBoxyxrfYTIir4UEH96celI9RYHLQtE4HQNhnZk66U=;
        b=B2KEa/kLRpzfrxLDk3PYHW23/MKVfpx8OOmI74sresVIeVSFqyNu5LgD8Ks0V4heGw
         wVaIafbLksA0VBeScfULj7kwpoAtxE1OjEEzjsyYRJ14ec98AOMaPCt+v7gSoGuuYqdH
         9dGchEaO3qGYZvmEpnPSIbYn9wCO/p7TeihXDuuTkkEvyefp/AhdxAMCBpQZiidk6bE/
         6qN0tnU5CRAwT0ledGvfhbUTjMGck+axUrLX70Jw8ca1MVS8HyfM514gOB6RYSHRWruy
         ohi+W6QPjAvkvdVLhWuhu6ZyJ8+opF5smODdDdcSjqDQvfkgOEayDb+zewL/G1YIxSKK
         UJBg==
X-Gm-Message-State: APjAAAXK2xI4McHVsLPS9nIrMaL/KF5nv8ydGjZBSYZNa9rrms8Ir2qy
	0fU/FkT5qbHHFNjstR7oRebtnklm68lIkBG5f6jAtmv3uSRVk8Fb97ZgNphgiYavQOwM3tfIJjx
	knJibPo/EfR7kW0qbNNqalLuwHKdAHdIjTDxfpQJfnMzdzpo4G5FJn5/Pif4TF1tXbg==
X-Received: by 2002:a05:620a:1411:: with SMTP id d17mr80771956qkj.137.1561415674037;
        Mon, 24 Jun 2019 15:34:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGF8nKG9CSOddwshHQg/UihB4SNV/2RDJwsyoxf2KvKEqiVdX5/RhM5EFkg9yhde4Tn+/U
X-Received: by 2002:a05:620a:1411:: with SMTP id d17mr80771937qkj.137.1561415673608;
        Mon, 24 Jun 2019 15:34:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561415673; cv=none;
        d=google.com; s=arc-20160816;
        b=KH5MR4vsa9nCXBp5dtuyG+EmukTIUvt9qXh1CP0CQzhFABddvw0ALc4tVfwo5oeXSh
         3+g60DrBmPEB4odMVd4rTIXsFhJbxCooZiJSMcwaoIwpECP+A3Y+OvyBj46HgBiUBCPq
         NkQMG9aDBG045OEZtuHNDflShK4Q0Kgx7bIjOOrR8TJGcmVSkOzxK3KkzzJ4HXdPThz/
         ljYQOUQEG+KfaYTGGu7jc8lQuqzG1vk8vad5iqIxYH//iyPhmgkbYOj4dqeMZVpjr6ow
         mXMawe3OpUbqmzZ6V/K/25kdLZXsrKA3P4pm1AS50ovaOQM67Odu4z6YdLZywlY6N51P
         MZZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=yWBoxyxrfYTIir4UEH96celI9RYHLQtE4HQNhnZk66U=;
        b=t8oaJ2P3c0m/1wJMqkEKi939oYOmK3RLWfI4E6l4HHLizFAyWlqDTz9cp81GEehDak
         pxLWB0NnQobjJ72PCQp/YcrENl7zwopo3nfWWtUbeUT2QThpD10ubSi50LVTP3uPuwSC
         2h4II0pPP83cMUfF4uTc638buFKDLlO9mBs27D0W2X8VRnjNmbmDNIRXmrMwqWRsJkaQ
         OS9bD8ZW83GCsq6UDIo/YYuSS8erS+SiggPeidkX/+CLR8TMyVD8Gb6HW0hszRpPliTY
         C+SWgcIEsSwIBfPC+yPjThUyI8Qp+jVzXxIxlZ0N4XrIPnYOIB+k9VjYi2DxlRNsQjqc
         25GA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Xn1zg9ac;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="fvm9/RRZ";
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id c25si7641535qkm.20.2019.06.24.15.34.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 15:34:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Xn1zg9ac;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="fvm9/RRZ";
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5OMWGaE031494;
	Mon, 24 Jun 2019 15:34:31 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=yWBoxyxrfYTIir4UEH96celI9RYHLQtE4HQNhnZk66U=;
 b=Xn1zg9acwhVMIggUjNpahKyM/FblpDg4/syrSWuJzXKdSsWnL1sswR0yJmxQLWcNwblp
 v8QpMWy/oDMQI/sYICcvrfnM+EQJwSDijUKIBddbubJqAhqStH0XvAd30W93iO8Bwcgd
 nMamMzw52ZMmpD+BLcEfd1/jFfAKdSpy0ZQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2t9g0ag9yu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Mon, 24 Jun 2019 15:34:30 -0700
Received: from ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) by
 ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 24 Jun 2019 15:34:30 -0700
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.101) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Mon, 24 Jun 2019 15:34:30 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yWBoxyxrfYTIir4UEH96celI9RYHLQtE4HQNhnZk66U=;
 b=fvm9/RRZAZTgW5ZivadEoUQ3Btkup/9riISQFC4TWBorfwIRs4+KTk3ZLJkJqlpGfZ2fCrmWuku6Ye52quoPOQFHwZE0VEFcuDU7fiWEX0+dxRG29ifdopyzLrVFaNuiifxHbTJD1XFexC9ILZGVN8TjmiBA7mU2sSNMtRynliQ=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1278.namprd15.prod.outlook.com (10.175.3.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Mon, 24 Jun 2019 22:34:29 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.014; Mon, 24 Jun 2019
 22:34:29 +0000
From: Song Liu <songliubraving@fb.com>
To: Linux-MM <linux-mm@kvack.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
CC: "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "Kernel
 Team" <Kernel-team@fb.com>,
        "william.kucharski@oracle.com"
	<william.kucharski@oracle.com>,
        "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>,
        "hdanton@sina.com" <hdanton@sina.com>
Subject: Re: [PATCH v8 0/6] Enable THP for text section of non-shmem files
Thread-Topic: [PATCH v8 0/6] Enable THP for text section of non-shmem files
Thread-Index: AQHVKtxbf9M9JYvZyE29Ijo3qgVrlqarZD2A
Date: Mon, 24 Jun 2019 22:34:29 +0000
Message-ID: <D1AFAFC0-56BC-4865-A6B7-4AAF30315BE5@fb.com>
References: <20190624222951.37076-1-songliubraving@fb.com>
In-Reply-To: <20190624222951.37076-1-songliubraving@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::2:78ae]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 385f32fd-e573-4d74-e130-08d6f8f41edd
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1278;
x-ms-traffictypediagnostic: MWHPR15MB1278:
x-microsoft-antispam-prvs: <MWHPR15MB1278173CE9FA972BD8B1538DB3E00@MWHPR15MB1278.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2803;
x-forefront-prvs: 007814487B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(346002)(376002)(39860400002)(396003)(136003)(189003)(199004)(446003)(64756008)(66556008)(66946007)(46003)(66446008)(66476007)(6246003)(25786009)(6486002)(71200400001)(73956011)(5660300002)(2501003)(486006)(71190400001)(6436002)(53936002)(86362001)(229853002)(4326008)(6116002)(11346002)(99286004)(476003)(57306001)(68736007)(6512007)(76176011)(81166006)(558084003)(50226002)(8936002)(76116006)(53546011)(102836004)(81156014)(6506007)(8676002)(305945005)(2906002)(2616005)(186003)(7736002)(36756003)(33656002)(14454004)(256004)(316002)(110136005)(54906003)(478600001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1278;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: ke8NFVkdEP/tsZAnqXnuLclSzNDtD23piJr2iRkbefFSxMAmDXPSsil5+/0MVlw7UoLD4PVIndjvDQtwGCriJFKkUteNAIOPIiIuyg+5Hh7DlVxcxKlQNtWfEC3iDZXNFctDynzd0ux/JFBuZk6BlLKo72sZOf7IhmqBADrGrhBgqcEX2yAIc/moEA5MXXdy+bsUQ8uXZlOVD31ayIyfBx/FTSzs4RRdvrAO6/l46AbtIIocfP36iU5Jfxw0VVUbCLHhXY7ELh/pNxy5WrOx7DR67f4CjeU6oTjsB+qWEPWTTf0xs7JBFSZTbbLbBhNad+1SDCvtpcNLR3MVdm24d4gUuL7TzFMjnPfgdHjsAA1ScqXuWTEWxqIjakmrB6UZz49xdrM/ZvMO9tJGmjiyufgh8efhEan+k3kIXWaYwpk=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2B3F7FBF4FEA4741B1BFDE92301624E8@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 385f32fd-e573-4d74-e130-08d6f8f41edd
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jun 2019 22:34:29.0497
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1278
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_15:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=923 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906240177
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 24, 2019, at 3:29 PM, Song Liu <songliubraving@fb.com> wrote:
>=20
> Changes v7 =3D> v8:
> 1. Use IS_ENABLED wherever possible (Kirill A. Shutemov);

I messed up with IS_ENABLED. Please ignore this version. v9 coming soon.

Sorry for the noise.=20

Song

