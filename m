Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1DDCC43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 21:08:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69DAF215EA
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 21:08:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="fo5vhyV+";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="YVCeXN0F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69DAF215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0497E6B0006; Wed, 19 Jun 2019 17:08:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3AF88E0002; Wed, 19 Jun 2019 17:08:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E03178E0001; Wed, 19 Jun 2019 17:08:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id B8C806B0007
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 17:08:00 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id p76so791518ywg.5
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 14:08:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=+0Ssr7siWRhVnxDn9RsEjYEDaM6Ig98s/BHY67cXLC0=;
        b=hPNR0N9Xylvrx2S1cEnNtiZT6uhcnAIovjgpHYOFX2sUCUWvpPQ1vG5/Xxmb10LtpQ
         AMstL+H0Z+z1UI+d6d7M+n9FOpLm/RpuuASIPSQtJs3BCkaWLWQyzT1Ug//5SNXuykbY
         WA3j/clGBINeruiLChZ4TNjsjaVbd5vm7zMLDHTY2CsJncTJ0O1+wK8zKFLHs5m5GvM/
         BZH6LJRsB9lW+oQvbA8tUTQecnY+ljdPEPG8dGYNWJqgxQwb3dgOrqHjDYktJ/wW7i/d
         NfSBboOj2+VW85TCKbDD5LsufqEWfT4nUO0YHVlX4qyDFgNUGOdRyNMnRG27R7XudWD0
         Yjtw==
X-Gm-Message-State: APjAAAUUQ5BpHEwiERSMtf/ZTayi4lY+DozkzC6qP+RJCVlRe6AEW76J
	SuugsyRrEdzPrteZd58J9bGhupUfD4/sZh8HJQfxCXeQKVRv02jEkIF8O8NRYypKE2GoukuH52P
	KNbFWqmez4Xf7iZljUdG+D5/HdeBsEpsryaj2B7/GBimBP83rESP8tnFyPbnimewz3g==
X-Received: by 2002:a81:5cc:: with SMTP id 195mr70288584ywf.348.1560978480474;
        Wed, 19 Jun 2019 14:08:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxrvR46NsDd+PLBqfFmLHDMOw8aroHAWT/zifwMs7VBUv2/YsaCznTogM0jfIFC6ijxlNv
X-Received: by 2002:a81:5cc:: with SMTP id 195mr70288518ywf.348.1560978479461;
        Wed, 19 Jun 2019 14:07:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560978479; cv=none;
        d=google.com; s=arc-20160816;
        b=LGpXlabLgN2ORvo3Qtn3ZP4CccsvxrniOxLgk2+NlxRnoOoWLUYRtyZQyi9KDVYqR7
         qcLfXq4M4XGnM6KgpUNujbwGHRljK3LE6jTPykWZANiuKLo83E1mFn44HIIjLFA0jQRH
         qSbSuE2eVtJym7Jo6TY5XrJZ8QftmU8HIDutWJdZiDxMxxHKuTD9li6+Qoz/sqYEDfL5
         8Vxh9vHoz+xDoBDPkyf8qz9os7Eo2l704fhdbIuGvG0mKyOIqKXyVk8L+xVcYpsLzCUa
         rt+T7LiQNpJiCX1lZJu16v1C80BCvH2sp4a0fngqXWvPV53WMcX8S9hGVuKvoWgTp6Yt
         ne1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=+0Ssr7siWRhVnxDn9RsEjYEDaM6Ig98s/BHY67cXLC0=;
        b=rX44Ic2oyoTVQ8JAANLLRuTdq+0J/YxWxprHj0Y8WOCiehjJtdA4vD3jckdSI4p5U1
         oouZ0wxi31Qyz6cJEnRHnbhtDa6YYdZiiC5H5YbefB0uh6VkadCISCkPXJdbt9bimpRi
         qZWUZwUuszrvsbZGiodPMCAVVMdPhl+NFmQAuTeayMTJAdb5KA7rhJk4P5KCO4HALPJ1
         z+fmoaxXrz7nIoYLIKorWWr/ROHw5k+ryEhFCIBHPAsdaFtkPBlJbPgQQavRnD2PN1K9
         v857dmIERebjrdNqISBDt6Y+D4tRUsBk9BpDDbtxEVa8bdkOW/tcuPNHqvJ9/gfXlUU6
         Ed2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=fo5vhyV+;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=YVCeXN0F;
       spf=pass (google.com: domain of prvs=10734da445=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10734da445=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m1si6232080ybo.177.2019.06.19.14.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 14:07:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10734da445=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=fo5vhyV+;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=YVCeXN0F;
       spf=pass (google.com: domain of prvs=10734da445=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10734da445=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5JL56R4007697;
	Wed, 19 Jun 2019 14:07:55 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=+0Ssr7siWRhVnxDn9RsEjYEDaM6Ig98s/BHY67cXLC0=;
 b=fo5vhyV+VyTnYqioqRSnunPcU0AhE08snPAqjzI/tOCt8SDGMZKf5NIz2NiFtIS2n3lQ
 /b738GwSCAPoWwEEo0oep0sp4g95tBR0DH3+4+CaE3aJNmZlFF8oM7Aho0Max9+e1z5j
 mtXshhlS5NdBrvz7nVhIo3VbUZ6b1By9qT8= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t7nr5hpjt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Wed, 19 Jun 2019 14:07:55 -0700
Received: from ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) by
 ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 19 Jun 2019 14:07:53 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Wed, 19 Jun 2019 14:07:53 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+0Ssr7siWRhVnxDn9RsEjYEDaM6Ig98s/BHY67cXLC0=;
 b=YVCeXN0Fnr9yr2Qb0YoJqVWa8UPWEBZ6sBQfzFz6RBez+TfgR1Y6KKwAzYI83wi8zRWWAGHwABB0cwTLgNTU7rqhtyzdNM4aI4YeEb3+PzGgAuVfmIr1ZPJcmnjia3/CMdpntPOi2JYjzptSbhYmidWnX3P1MLucwjRofD/zEmc=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB3354.namprd15.prod.outlook.com (20.179.52.97) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.15; Wed, 19 Jun 2019 21:07:52 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::5022:93e0:dd8b:b1a1]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::5022:93e0:dd8b:b1a1%7]) with mapi id 15.20.1987.014; Wed, 19 Jun 2019
 21:07:52 +0000
From: Roman Gushchin <guro@fb.com>
To: Qian Cai <cai@lca.pw>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>,
        "hannes@cmpxchg.org"
	<hannes@cmpxchg.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH -next] mm/slab: fix an use-after-free in kmemcg_workfn()
Thread-Topic: [PATCH -next] mm/slab: fix an use-after-free in kmemcg_workfn()
Thread-Index: AQHVJuEXcoe79odJmU2xiisbFM7VSqajeFSA
Date: Wed, 19 Jun 2019 21:07:52 +0000
Message-ID: <20190619210744.GA20256@castle.dhcp.thefacebook.com>
References: <1560977573-10715-1-git-send-email-cai@lca.pw>
In-Reply-To: <1560977573-10715-1-git-send-email-cai@lca.pw>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MW2PR16CA0035.namprd16.prod.outlook.com (2603:10b6:907::48)
 To DM6PR15MB2635.namprd15.prod.outlook.com (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:3e17]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bea38161-70e6-45d9-8839-08d6f4fa30f0
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB3354;
x-ms-traffictypediagnostic: DM6PR15MB3354:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <DM6PR15MB3354247AF05B7AFA8BEE34CABEE50@DM6PR15MB3354.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:332;
x-forefront-prvs: 0073BFEF03
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(39860400002)(366004)(376002)(396003)(51234002)(189003)(199004)(478600001)(8936002)(305945005)(186003)(33656002)(1076003)(54906003)(6116002)(71190400001)(446003)(71200400001)(2906002)(6436002)(6486002)(11346002)(5660300002)(14444005)(68736007)(6246003)(81156014)(476003)(966005)(486006)(4326008)(7736002)(6306002)(8676002)(66946007)(46003)(66556008)(99286004)(66446008)(73956011)(386003)(64756008)(66476007)(256004)(102836004)(316002)(81166006)(6512007)(6506007)(52116002)(6916009)(14454004)(76176011)(25786009)(86362001)(229853002)(9686003)(53936002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB3354;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Hiz+vErV+lsP1o+08Tr0YjpSHdDW5EQSUXOWwgpph2P29HnOtr2H+Ypd/sJUcsNDNYqWrtc94h+IgpozsmQp9NSWyetw1KcYemtSaJ0FTn1+KoK0T1v8x7boPQYabMDiMzFMC8aJISQ80G1HTdplhRvRRhACcBIJvwtJQPYygmVgBAC2odHy/RB3qohxJ8ZtVbgPtB7L/DiRlLGRqWDLqKZ85k4DWYYXdDQS9CSAqv5TW5VcrZhDsfxcc17fYvewWgx/6zwm/I9bWI9meF3LfqK6eSfxmFff/01mIDrU5Y9ShKFXsibS4L9DBN9ttKWzja9/ZGn9tnXU/OMpHf/ZUpW6PvwYVZWxbhgKdVe8wbTNqnxgGkfOc9HxdL5yF86LXSA63WGR+4Y0jLw3D0OV6pRHQ3zaZ4WlrcfSU0n3AhI=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3BF7D0D93AD04C438A4924F834A5FD4B@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: bea38161-70e6-45d9-8839-08d6f4fa30f0
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Jun 2019 21:07:52.2353
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB3354
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-19_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906190173
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 04:52:53PM -0400, Qian Cai wrote:
> The linux-next commit "mm: rework non-root kmem_cache lifecycle
> management" [1] introduced an use-after-free below because
> kmemcg_workfn() may call slab_kmem_cache_release() which has already
> freed the whole kmem_cache. Fix it by removing the bogus NULL assignment
> and checkings that will not work with SLUB_DEBUG poisoning anyway.
>=20
> [1] https://lore.kernel.org/patchwork/patch/1087376/
>=20
> BUG kmem_cache (Tainted: G    B   W        ): Poison overwritten
> INFO: 0x(____ptrval____)-0x(____ptrval____). First byte 0x0 instead of
> 0x6b
> INFO: Allocated in create_cache+0x6c/0x1bc age=3D2653 cpu=3D154 pid=3D159=
9
> 	kmem_cache_alloc+0x514/0x568
> 	create_cache+0x6c/0x1bc
> 	memcg_create_kmem_cache+0xfc/0x11c
> 	memcg_kmem_cache_create_func+0x40/0x170
> 	process_one_work+0x4e0/0xa54
> 	worker_thread+0x498/0x650
> 	kthread+0x1b8/0x1d4
> 	ret_from_fork+0x10/0x18
> INFO: Freed in slab_kmem_cache_release+0x3c/0x48 age=3D255 cpu=3D7 pid=3D=
1505
> 	slab_kmem_cache_release+0x3c/0x48
> 	kmem_cache_release+0x1c/0x28
> 	kobject_cleanup+0x134/0x288
> 	kobject_put+0x5c/0x68
> 	sysfs_slab_release+0x2c/0x38
> 	shutdown_cache+0x190/0x234
> 	kmemcg_cache_shutdown_fn+0x1c/0x34
> 	kmemcg_workfn+0x44/0x68
> 	process_one_work+0x4e0/0xa54
> 	worker_thread+0x498/0x650
> 	kthread+0x1b8/0x1d4
> 	ret_from_fork+0x10/0x18
> INFO: Slab 0x(____ptrval____) objects=3D64 used=3D64 fp=3D0x(____ptrval__=
__)
> flags=3D0x17ffffffc000200
> INFO: Object 0x(____ptrval____) @offset=3D11601272640106456192
> fp=3D0x(____ptrval____)
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb  ................
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb  ................
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb  ................
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb  ................
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb  ................
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb  ................
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb  ................
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb
> bb  ................
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 00 00 00 00 00 00 00 00
> kkkkkkkk........
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
> kkkkkkkkkkkkkkkk
> Object (____ptrval____): 6b 6b 6b 6b 6b 6b 6b a5
> kkkkkkk.
> Redzone (____ptrval____): bb bb bb bb bb bb bb bb
> ........
> Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a  ZZZZZZZZZZZZZZZZ
> Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a  ZZZZZZZZZZZZZZZZ
> Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a  ZZZZZZZZZZZZZZZZ
> Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a
> 5a  ZZZZZZZZZZZZZZZZ
> Padding (____ptrval____): 5a 5a 5a 5a 5a 5a 5a 5a
> ZZZZZZZZ
> CPU: 193 PID: 1557 Comm: kworker/193:1 Tainted: G    B   W
> 5.2.0-rc5-next-20190619+ #8
> Hardware name: HPE Apollo 70             /C01_APACHE_MB         , BIOS
> L50_5.13_1.0.9 03/01/2019
> Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> Call trace:
>  dump_backtrace+0x0/0x268
>  show_stack+0x20/0x2c
>  dump_stack+0xb4/0x108
>  print_trailer+0x274/0x298
>  check_bytes_and_report+0xc4/0x118
>  check_object+0x2fc/0x36c
>  alloc_debug_processing+0x154/0x240
>  ___slab_alloc+0x710/0xa68
>  kmem_cache_alloc+0x514/0x568
>  create_cache+0x6c/0x1bc
>  memcg_create_kmem_cache+0xfc/0x11c
>  memcg_kmem_cache_create_func+0x40/0x170
>  process_one_work+0x4e0/0xa54
>  worker_thread+0x498/0x650
>  kthread+0x1b8/0x1d4
>  ret_from_fork+0x10/0x18
> FIX kmem_cache: Restoring 0x(____ptrval____)-0x(____ptrval____)=3D0x6b
>=20
> FIX kmem_cache: Marking all objects used
>=20
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  mm/slab_common.c | 5 -----
>  1 file changed, 5 deletions(-)
>=20
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 91e8c739dc97..bb8aec6d8744 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -714,10 +714,7 @@ static void kmemcg_workfn(struct work_struct *work)
>  	get_online_mems();
> =20
>  	mutex_lock(&slab_mutex);
> -
>  	s->memcg_params.work_fn(s);
> -	s->memcg_params.work_fn =3D NULL;
> -
>  	mutex_unlock(&slab_mutex);

Ah, perfect catch! Thank you, Qian!

Acked-by: Roman Gushchin <guro@fb.com>

