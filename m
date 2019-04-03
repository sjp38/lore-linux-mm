Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CBEDC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 18:42:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECBE72147C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 18:42:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="EnIyRq++";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="ZfcinuEq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECBE72147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CF4D6B000A; Wed,  3 Apr 2019 14:42:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67DB06B000C; Wed,  3 Apr 2019 14:42:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F7AE6B000D; Wed,  3 Apr 2019 14:42:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F32916B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 14:42:41 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n24so16911edd.21
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 11:42:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Rjb3llispwfKjVXMXSX6JILU/ScWO8TCCwCZlyFQtOo=;
        b=teyyXw/iFlCvu8vvwaZcdwtPTxegsIUKXc+wJx6edWbhyG5FCg/krTo5xLwyiLT/4G
         5SisaL+9cvPjFQvfs9wxsR/htFwu8kEuShb2rhlMVgBW3/tu31q28hufQjqHCMzDEOrl
         xrMkGgagJQQo3pqlswPmUnTg1cAMGnc8APyZkB11YJAdJMoz9hesvKOXW+WbWTFUUlLH
         ukk7OZucBjsIjGhxFg47XqMus8c7Sv8LGfH9gomjGlsYjdwHoMJX5eV9JRZ60kkqxcGs
         k1Ia08xUxffAJTxP9yDQmxMoBz+xK/dh5hDXLyF9j9h7vaV56BlSlM3sJkMWPFUlV649
         HERA==
X-Gm-Message-State: APjAAAXvMREex7OHw15wkMQi6OcannFmgEbl+SoCpLptlg/4zr/MH0RB
	RiOtMslqizV23HVwF8a3dgBa2UkmSJzxBoASE+ImPm1AR93yufpW5j4ZTEFxtqMHn0p9pFym9XE
	fCsuNx45PXcWOmO5YEwQLPKMHNKXS6aNM7T9WcrudSE1zfzi+leRaQAjzrc9Ar79pMg==
X-Received: by 2002:a50:90e4:: with SMTP id d33mr740505eda.265.1554316961385;
        Wed, 03 Apr 2019 11:42:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYaiSPUW/xSM4afCe8RtWf+/tbrlXMnjv8XiNTCTWD0IyOna8qsVAYiu50GE1xom1PwVV2
X-Received: by 2002:a50:90e4:: with SMTP id d33mr740478eda.265.1554316960577;
        Wed, 03 Apr 2019 11:42:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554316960; cv=none;
        d=google.com; s=arc-20160816;
        b=wAG5f/5D4UKmqNDuDpmSBddmQH6TYUa1EsoAO/89gUxoKeTkTVsSSedlDpTrV8jPnF
         E0zhPfD1FKjjgLOj1j2g931S0McIlDIwsmRwZkcTZxFpa8Z+w3W1Le2Yc+uT0BOvkNMn
         SgJBsUbQAxEYX8i02GNRi++l5gElbQ1So6Pp/RUJWkgkGXM4sVsYz3riZMkJuZlJpj3x
         KMrh1hkH7OnMWSrmEaTiKnVhdhIMXQCoMV7uwNUD5wogjjCNWCOHUD6qDG3rm3rnVHxa
         17UBuhTSS39t9gcplxPi1f/4tFXaMkBu94vlGmkX/N5vxxl2Mz2OSd2yYz8Fh1Nklrj3
         I8PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Rjb3llispwfKjVXMXSX6JILU/ScWO8TCCwCZlyFQtOo=;
        b=G2VK/TwTDAb0ZEci0Id/HCEtYu4KxrUkCi3xS4NgYDHR5L4mjiy6kHyWh8ArILvvYO
         D6iJ0bivacnKKvLp4Mkx6qsfRY1YLT//6QY0F3vvdM8Ho+NMFyucNPCNYz0ggIuUx/Qa
         o5nxkAAIdydtARRli9N2GeoyZ3S3mqmkEiCAh4H1jd8lwjvcGibFZwKuNRvBh3xiILw7
         1S/md+gfIq7SUjDybe6ib83UwHyNvDaQkDyqV4wS0ye4x/6+7wGaroDgOO8dTRi3u6vR
         hJ/+GJUw9gwj4UMbzN+Fq+ICx+e2Rq3/V/9WvloUqQ4HYXzBT6yzhqcyMyMWHSykJomE
         QUrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=EnIyRq++;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=ZfcinuEq;
       spf=pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=99962c6dea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id w20si452887ejb.188.2019.04.03.11.42.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 11:42:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=EnIyRq++;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=ZfcinuEq;
       spf=pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=99962c6dea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x33IXmKd008705;
	Wed, 3 Apr 2019 11:42:31 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=Rjb3llispwfKjVXMXSX6JILU/ScWO8TCCwCZlyFQtOo=;
 b=EnIyRq++iRHDlGLOxSzawXoYP9/DSq07sd/xXeKHaSYbQ+iiK8fefDpZOfa+ElZrRtAl
 KtvDWmNDNfgqrojELdLqYfh47PGh9vn9SZfZrSr5z0O5+19tCSN8tOUUoEMh9RjXue0Y
 Kz6S77fgUBrsacm4YMbw2jwgIPhz/KzUQEU= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by m0089730.ppops.net with ESMTP id 2rn0cb8kag-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 03 Apr 2019 11:42:31 -0700
Received: from frc-hub04.TheFacebook.com (2620:10d:c021:18::174) by
 frc-hub03.TheFacebook.com (2620:10d:c021:18::173) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 3 Apr 2019 11:42:30 -0700
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.74) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 3 Apr 2019 11:42:30 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Rjb3llispwfKjVXMXSX6JILU/ScWO8TCCwCZlyFQtOo=;
 b=ZfcinuEqq//v8nEMm8pzY6kCP1kfmiaXZu+/+crTwh1XBFLt6OFXYGX3rHbT3mUIU3qc5ljqZ7KEOkIpMRKjeBU9z6SgLUr6ykcZMGqqfx2MBidLMgufNX8JpVNu8EBqlVKMPg9uso26D5s26d12QVu0JMt+KuDpI/xwnu3Kwrw=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3480.namprd15.prod.outlook.com (20.179.60.20) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.13; Wed, 3 Apr 2019 18:42:27 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%3]) with mapi id 15.20.1750.017; Wed, 3 Apr 2019
 18:42:27 +0000
From: Roman Gushchin <guro@fb.com>
To: "Tobin C. Harding" <tobin@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Christoph Lameter
	<cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
        David Rientjes
	<rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Matthew Wilcox
	<willy@infradead.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v5 4/7] slub: Add comments to endif pre-processor macros
Thread-Topic: [PATCH v5 4/7] slub: Add comments to endif pre-processor macros
Thread-Index: AQHU6ajBwVxIgIrx7ESbIcbajaDpPaYqxqMA
Date: Wed, 3 Apr 2019 18:42:27 +0000
Message-ID: <20190403184223.GD6778@tower.DHCP.thefacebook.com>
References: <20190402230545.2929-1-tobin@kernel.org>
 <20190402230545.2929-5-tobin@kernel.org>
In-Reply-To: <20190402230545.2929-5-tobin@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR15CA0041.namprd15.prod.outlook.com
 (2603:10b6:300:ad::27) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:9220]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1a100f5a-df1e-43fa-e835-08d6b8641ecd
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3480;
x-ms-traffictypediagnostic: BYAPR15MB3480:
x-microsoft-antispam-prvs: <BYAPR15MB348011715D3D81339A93C43DBE570@BYAPR15MB3480.namprd15.prod.outlook.com>
x-forefront-prvs: 0996D1900D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(39860400002)(376002)(366004)(346002)(199004)(189003)(6486002)(33656002)(46003)(14454004)(478600001)(76176011)(6916009)(97736004)(2906002)(186003)(102836004)(25786009)(256004)(6506007)(386003)(229853002)(105586002)(106356001)(53936002)(305945005)(6246003)(7736002)(6512007)(9686003)(476003)(446003)(68736007)(11346002)(86362001)(486006)(99286004)(5660300002)(8676002)(54906003)(81166006)(316002)(4326008)(81156014)(4744005)(6436002)(52116002)(71190400001)(71200400001)(1076003)(6116002)(8936002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3480;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: +Nc1/yugvQ/RfQ3Wk+HlCrw7Yhm0yP41l1gCFADH+ygKID9uz1HcX3gKdMhod1QDcWH9SZQZjhmRTiBpHu/ajPcPGGb4zTn2pb9SNXZiNg+eRo8U5dCEbgPITFJVIDmSa/38QkuZ/FFvXtjxJSYkW6IOjLKocOrIG0WZMPVQ3NZMUnm/6SRRsnljIATBlF783i7feCQtCTNmJHeNCpvdkc0qdWYxH35jrh59Lqvdof2Q+OROTsaqPr7JTvY6CL4lqH/BE4WoID8sFsqsd635tybIY/inolCIkbRb2q7KLk2Ql/5aFowJywAIyo0M6NSelov8QX/8hyYepQMLN59aPZPLeEscNU53Ebf3vuxXRVlMrH6hL84Y1gDr9UYj8iMo/K4wdeB+HKC5YQ0B9VmqV+XepTywJVwEcQD7bdkj334=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F86A4325CD5BD1448246DE117FA34B55@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 1a100f5a-df1e-43fa-e835-08d6b8641ecd
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Apr 2019 18:42:27.5577
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3480
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-03_10:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 10:05:42AM +1100, Tobin C. Harding wrote:
> SLUB allocator makes heavy use of ifdef/endif pre-processor macros.
> The pairing of these statements is at times hard to follow e.g. if the
> pair are further than a screen apart or if there are nested pairs.  We
> can reduce cognitive load by adding a comment to the endif statement of
> form
>=20
>        #ifdef CONFIG_FOO
>        ...
>        #endif /* CONFIG_FOO */
>=20
> Add comments to endif pre-processor macros if ifdef/endif pair is not
> immediately apparent.
>=20
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>

Reviewed-by: Roman Gushchin <guro@fb.com>

