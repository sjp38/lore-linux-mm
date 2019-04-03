Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71137C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 18:45:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1445D2084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 18:45:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="aLYNkfV0";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="PK87nXx9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1445D2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4EA56B000E; Wed,  3 Apr 2019 14:45:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A28D06B0010; Wed,  3 Apr 2019 14:45:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F0626B0269; Wed,  3 Apr 2019 14:45:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63E8E6B000E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 14:45:24 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id v73so9645433ybb.8
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 11:45:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=i+GnCgx99leNZnPXeDWo95hjH3kzCBuware3EhkuWLU=;
        b=Bvn+17wH8B6itWcnXnEkAstpPKQVXAXGq1qfeDCVDKuZujYeoH1BNZ+jp74D/ZVupS
         Yjsr62fz+0xxTe9SYow8WaMVatxy0pY1V5d3LyzjoFgePTPaBnrD7sKbS9OaeaX2NIT+
         7mVwX+5rm67auZCIXdUTKvYktSyjWIwFN38ThrHKiyuu0OPAmfQLwYzD7KYu/B33Ihdi
         ec0RJMs21f9Y4Q4m3xGxruBny+Xuorc6081cpYBk23iyrp9IDXpYcPyqNzvTHPljD5xq
         IMK6E75xbHdPBOYDNgBQsmbOviZ7V+BgQfT4OedXeHMf6QobYZWDtecSuZTKzPMs0IJq
         iw3A==
X-Gm-Message-State: APjAAAViILR5HfoSuIE49LThGyQA1sur45PiNFv8B0xyXLBsCRnLJdSI
	JVgb5omYN/vapOY0UyC4ahMmS2KyigwL3x99ypaOZNVQQlTK/xETkBxEIOyv8lwLNlS4xcQJaDH
	TFJnPKPfmMniM1lA1Vz84WnzZFh7v17E64hPwhkUw2hz6kZMysJlAgnh3PVGW8shCSA==
X-Received: by 2002:a25:6307:: with SMTP id x7mr1460306ybb.105.1554317124202;
        Wed, 03 Apr 2019 11:45:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwp466ta3r7aNElXpf7TF2lwpShQAcg8woZzaBBLXy79cjed1l31fjeW9gAqCBvdrYaaUJI
X-Received: by 2002:a25:6307:: with SMTP id x7mr1460261ybb.105.1554317123741;
        Wed, 03 Apr 2019 11:45:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554317123; cv=none;
        d=google.com; s=arc-20160816;
        b=dIg9i6ulFP0IInf1S01vO7h46teijNrQ1xFvzwEodKfbe9mopI+r+DoBmSku2s1/Rn
         2GLAg82SY1AgrlJ163fvkACIc7a7NA6Sh6gI9N7bqx+wYTpgwPvHl1X7i+IbVbXvOMZU
         6paq9YiWcSxJsAAz6af11BgB+V4m/+aJq6Pvp12QtRpD32D2flXsyit+cZUMv8iqBNP8
         iXDvwLd2YKquGm+cKXL0AyVV1cInmFHnKlrwv0jw506+4aTFyQJkpJkNMfJ8YTPigZAX
         XMS4GAebKl7Q6VszLM90M5mEcARKalZlM3jgzxeIkfd1pBfgvhTyn/QBX5rxThfxSZF/
         YXOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=i+GnCgx99leNZnPXeDWo95hjH3kzCBuware3EhkuWLU=;
        b=AcFQc46gXESsGwf8H6XYjN7VH1rtHwMhYpvNBR2+uHBJUMMGmEYLT6bBDzAJnHWpRv
         cIrNTa71Bl/nZVJrC2cQp6ZUqJeaZ2RWSF6FW15RtJQsnYKmsVEbO2iRXye4na2inWwK
         RQbWe8BIjEPPr6OcWqHxLpPJI2Nt8jkKMe9hCOxQRU4sDEuflKMrTLjNzKeeFMr7NM4a
         vSgnHTOdAkRbE/qzaBNA5qWsJH6uidrOKeUm1BjPPGIO8GKuafoktyDkGwWypdo+nHj/
         +FFKguPrygdpSU5KU40duJpUfiTJ/AwSQ1nt4JmlvXgLpg4ngqHFULvrOau0+l3EF1gE
         o0TQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=aLYNkfV0;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=PK87nXx9;
       spf=pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=99962c6dea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id d63si9817242ybf.382.2019.04.03.11.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 11:45:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=aLYNkfV0;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=PK87nXx9;
       spf=pass (google.com: domain of prvs=99962c6dea=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=99962c6dea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x33IX2mh012647;
	Wed, 3 Apr 2019 11:45:16 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=i+GnCgx99leNZnPXeDWo95hjH3kzCBuware3EhkuWLU=;
 b=aLYNkfV0EPUBTxqxe9GsXY9HmIxjPa0Y6oxG36KlxTN92og/OI3AWHvGtIkeosB2+aoD
 EAoTfJJyumPrsGl8ZPZdlX0IJeKmLcyFjHPN4qR8o3ZUSuGRXTBHMXAleQCDg8Eod7T+
 LqI6zzwG6M31qigssqdXDGtcYz3DFT8CJ7M= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rn1tf05en-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 03 Apr 2019 11:45:16 -0700
Received: from prn-mbx08.TheFacebook.com (2620:10d:c081:6::22) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 3 Apr 2019 11:44:36 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-mbx08.TheFacebook.com (2620:10d:c081:6::22) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 3 Apr 2019 11:44:35 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 3 Apr 2019 11:44:35 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=i+GnCgx99leNZnPXeDWo95hjH3kzCBuware3EhkuWLU=;
 b=PK87nXx9K+O8ySEcndsmccGSopBtvQaPvYluU03ZbBtkRKGlFNKCwK6AeOGv79I7M1MDxgZURlLJfEr6l7dCj860VdDbAuNQllLlr667tew6A/ZW0W5u+yuUpIcC6v6TLAXGUaZR2Og0MESigBeZMJpBXutpqoBX5SqXBgOgQTc=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3335.namprd15.prod.outlook.com (20.179.58.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.15; Wed, 3 Apr 2019 18:44:18 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%3]) with mapi id 15.20.1750.017; Wed, 3 Apr 2019
 18:44:19 +0000
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
Subject: Re: [PATCH v5 6/7] slab: Use slab_list instead of lru
Thread-Topic: [PATCH v5 6/7] slab: Use slab_list instead of lru
Thread-Index: AQHU6ajFJNY85SdJxkGxd4eRBwv3baYqxyeA
Date: Wed, 3 Apr 2019 18:44:18 +0000
Message-ID: <20190403184415.GF6778@tower.DHCP.thefacebook.com>
References: <20190402230545.2929-1-tobin@kernel.org>
 <20190402230545.2929-7-tobin@kernel.org>
In-Reply-To: <20190402230545.2929-7-tobin@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO2PR07CA0061.namprd07.prod.outlook.com (2603:10b6:100::29)
 To BYAPR15MB2631.namprd15.prod.outlook.com (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:9220]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 462f810e-2fbb-4e58-44f2-08d6b864612b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3335;
x-ms-traffictypediagnostic: BYAPR15MB3335:
x-microsoft-antispam-prvs: <BYAPR15MB3335C1478F9942D79F831CCDBE570@BYAPR15MB3335.namprd15.prod.outlook.com>
x-forefront-prvs: 0996D1900D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(39860400002)(136003)(366004)(376002)(199004)(189003)(186003)(6486002)(11346002)(33656002)(6436002)(476003)(6116002)(46003)(6916009)(229853002)(446003)(2906002)(105586002)(68736007)(106356001)(316002)(53936002)(25786009)(54906003)(97736004)(6246003)(7736002)(305945005)(4326008)(99286004)(256004)(486006)(14454004)(478600001)(5660300002)(52116002)(6512007)(9686003)(8676002)(76176011)(102836004)(71190400001)(86362001)(8936002)(6506007)(386003)(4744005)(1076003)(71200400001)(81156014)(81166006);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3335;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: jAItvlvsVbDQPM83ZEYSr1sw7qNTeAYZifS0G1iIaZWcszt9VgEIthIkPabR4oMHsI/LUXPEsRbJ1vzSAjCPYlyiplxA8yE7l9elyaGy6amN8Xtub/Ug4TrbPqQpVkdOfpote+1gaCITw9+othIUfNHOLyivxWmY9hwgGY9JYIOdxO0OOLCtlB50yadpwjFVeZOajoS6qnP8vmUApktVKymLZcog27/XQqmjXf2ZXrLl3ILjtI34SNsMbMNx5pGljZJUsoPhHZlBMh/mzRhbCDPYEe+GzzrJalkCl00rCmUXqRcnHU7jgVVBhWyJvHlgP3yWYlZX4ao8MLHsv37Lhax5BX4dsqW5mY1aTFr2LGROcPjjxgi763RTTWGGXL/mbwCXNyXHy3JPKHL+5pdNBqAMzeKQjGU7G2wJLR+hQ5E=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <149C5B8A63DAAD4F8CD636AD438EC86F@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 462f810e-2fbb-4e58-44f2-08d6b864612b
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Apr 2019 18:44:18.8551
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3335
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

On Wed, Apr 03, 2019 at 10:05:44AM +1100, Tobin C. Harding wrote:
> Currently we use the page->lru list for maintaining lists of slabs.  We
> have a list in the page structure (slab_list) that can be used for this
> purpose.  Doing so makes the code cleaner since we are not overloading
> the lru list.
>=20
> Use the slab_list instead of the lru list for maintaining lists of
> slabs.
>=20
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>

Reviewed-by: Roman Gushchin <guro@fb.com>

