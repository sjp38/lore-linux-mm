Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5962EC04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 18:39:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F25D7206A3
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 18:39:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F25D7206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hpe.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EC086B0005; Thu, 16 May 2019 14:39:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59C276B0006; Thu, 16 May 2019 14:39:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48AB26B0007; Thu, 16 May 2019 14:39:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 277516B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 14:39:01 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id x194so3690491ybg.12
        for <linux-mm@kvack.org>; Thu, 16 May 2019 11:39:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=SjaSbT4U7K6xcVgEMesuFD/TbNwBJX34ZW6MuoXxV8Y=;
        b=M3g/ZpxmeIxqSzWFPAgEqcZnqybrWNm/prYUjsLsWo/XPrQQsuMDYka9YfPJ5Iwo4B
         8H2PoaCpHvyLTUhF4YEsFEuH9mRBSHeR7fEHVnFr5pDBbnAfOhemQtYBusNZ3JBETcCH
         lIspIZBwQw1uqgBaJwRWB73EGaA6CAK1yKoFCN2q6umoySAJRW9L7bMCXJwhK5v4N1wP
         3I2K2HsDCAWI/TdAcU4ZLZBnykSNyW14r0YJH3hd0OUYusbo7pupm75ZGbJFeFLMWHAR
         6TRglN3lCXWqMW3H4A2VyxFLimqbsIDUNtcP55rbr+7CS9a99Ub8s6m3ta+lil9rwLjr
         nwmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of toshi.kani@hpe.com designates 148.163.143.35 as permitted sender) smtp.mailfrom=toshi.kani@hpe.com
X-Gm-Message-State: APjAAAVCAM0tbkg6oT9w03fhZ+9nNvQYMjxI/zIz5E/5LVsXwkzt+EJ3
	rpoef+UTU45kTUejAZAID4ROGkfLZTvcKkZxHM4VUJBmsFzWGNrVx637bnARJRJBLOtRh3+k5Yl
	CL1a+P5+XTIAPWRPjNc9BeuekMq+ZudPgVVHfwD3nULnx0oMS5MEP/0AXXRaFZfrsxg==
X-Received: by 2002:a81:ad6:: with SMTP id 205mr23159207ywk.187.1558031940867;
        Thu, 16 May 2019 11:39:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8GR7gZDmJSxHQ5nj1M1ylM4td6UJcdPPnrkytGi+LFVO/uAnJ0UwrUZUeGUjB2+K7LMqN
X-Received: by 2002:a81:ad6:: with SMTP id 205mr23159186ywk.187.1558031939984;
        Thu, 16 May 2019 11:38:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558031939; cv=none;
        d=google.com; s=arc-20160816;
        b=WzesWsP9grAl4guqYsBhwOSfir8Lzo9NwldPqTMHlEGI1/pVBoUU1A1ugyHLaS2HHs
         xAzdb/FT7WE+r7BMXybwLtFoDZo1BT1fuvYDne3+j6AfSm/PuQE0qQnQlXaRgsjBGK8f
         scPUI0p4OFOQkzGi1vVXSLahne6ArFZe7AhDbb8b/KeMPbNoMhSSq6G1R2MnfFzrpzmg
         OtGqga1/eqzuM3mFqsgSfwy4whvppqRpReM6miv+8MRzNvzATmv+O9dzOcsy3aXQhcV4
         BNZKA8JfbOxJ+ASHLHV9ojosVbG+xj9qoorjBv5GK0+XeKIsXW3FE3e9jLbXVshBVBg5
         h3Ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=SjaSbT4U7K6xcVgEMesuFD/TbNwBJX34ZW6MuoXxV8Y=;
        b=Q4fpKtkEzuxwBhEDVD68Ds1khJLxtoL3hWeFPyJ3II9aDPQhvos/c59bOY+u0ONoKV
         DsJq2rs20I+Y96neCLfuI9kArqHUtncdeTMy4JG108XEJU0iyAh2MffAlhxVW8EQkTpQ
         BqGCnk8h9Kan2Juc1o/ljYTFe8nYg7ob94V9Pb2X89MNkO95gBx1QP0+lVVvUxsWrmOa
         CZ1qQEKdyx7rfjpexCxIZf69oGhIU1egM78xuXQ1v92y0R8wLWsek2Etlk0XImC3Me5d
         HCeeYHiKzJHWmNSF7B/K+HB5iT3DTLqCbMRfWtYRZbG3KrMJAopiL6bWSPJMRWcZY1jQ
         0LXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of toshi.kani@hpe.com designates 148.163.143.35 as permitted sender) smtp.mailfrom=toshi.kani@hpe.com
Received: from mx0b-002e3701.pphosted.com (mx0b-002e3701.pphosted.com. [148.163.143.35])
        by mx.google.com with ESMTPS id f129si1726905ybg.84.2019.05.16.11.38.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 11:38:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of toshi.kani@hpe.com designates 148.163.143.35 as permitted sender) client-ip=148.163.143.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of toshi.kani@hpe.com designates 148.163.143.35 as permitted sender) smtp.mailfrom=toshi.kani@hpe.com
Received: from pps.filterd (m0150244.ppops.net [127.0.0.1])
	by mx0b-002e3701.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4GIWE41001842;
	Thu, 16 May 2019 18:38:56 GMT
Received: from g2t2354.austin.hpe.com (g2t2354.austin.hpe.com [15.233.44.27])
	by mx0b-002e3701.pphosted.com with ESMTP id 2sha5q9p2q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 16 May 2019 18:38:55 +0000
Received: from G2W6311.americas.hpqcorp.net (g2w6311.austin.hp.com [16.197.64.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t2354.austin.hpe.com (Postfix) with ESMTPS id C95A3C3;
	Thu, 16 May 2019 18:38:53 +0000 (UTC)
Received: from G9W8677.americas.hpqcorp.net (16.220.49.24) by
 G2W6311.americas.hpqcorp.net (16.197.64.53) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Thu, 16 May 2019 18:38:53 +0000
Received: from G9W9209.americas.hpqcorp.net (2002:10dc:429c::10dc:429c) by
 G9W8677.americas.hpqcorp.net (2002:10dc:3118::10dc:3118) with Microsoft SMTP
 Server (TLS) id 15.0.1367.3; Thu, 16 May 2019 18:38:53 +0000
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (15.241.52.13) by
 G9W9209.americas.hpqcorp.net (16.220.66.156) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3 via Frontend Transport; Thu, 16 May 2019 18:38:53 +0000
Received: from TU4PR8401MB0607.NAMPRD84.PROD.OUTLOOK.COM (10.169.44.19) by
 TU4PR8401MB1134.NAMPRD84.PROD.OUTLOOK.COM (10.169.48.140) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.17; Thu, 16 May 2019 18:38:51 +0000
Received: from TU4PR8401MB0607.NAMPRD84.PROD.OUTLOOK.COM
 ([fe80::e801:598b:4d87:7d6b]) by TU4PR8401MB0607.NAMPRD84.PROD.OUTLOOK.COM
 ([fe80::e801:598b:4d87:7d6b%6]) with mapi id 15.20.1900.010; Thu, 16 May 2019
 18:38:51 +0000
From: "Kani, Toshi" <toshi.kani@hpe.com>
To: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "anshuman.khandual@arm.com" <anshuman.khandual@arm.com>
CC: "tglx@linutronix.de" <tglx@linutronix.de>,
        "cpandya@codeaurora.org"
	<cpandya@codeaurora.org>,
        "catalin.marinas@arm.com"
	<catalin.marinas@arm.com>,
        "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>
Subject: Re: [PATCH V4] mm/ioremap: Check virtual address alignment while
 creating huge mappings
Thread-Topic: [PATCH V4] mm/ioremap: Check virtual address alignment while
 creating huge mappings
Thread-Index: AQHVCsb1po3qOFZtEEG+LlOmCwssnqZuFpkA
Date: Thu, 16 May 2019 18:38:51 +0000
Message-ID: <e796e434eef10fbade2597f69be63ceeac32b2cd.camel@hpe.com>
References: <a893db51-c89a-b061-d308-2a3a1f6cc0eb@arm.com>
	 <1557887716-17918-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1557887716-17918-1-git-send-email-anshuman.khandual@arm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [15.219.163.3]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4f3471c7-f213-4e41-adad-08d6da2dbdcb
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:TU4PR8401MB1134;
x-ms-traffictypediagnostic: TU4PR8401MB1134:
x-microsoft-antispam-prvs: <TU4PR8401MB113418AC8CDBBF0C131EA8AE820A0@TU4PR8401MB1134.NAMPRD84.PROD.OUTLOOK.COM>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 0039C6E5C5
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39860400002)(346002)(136003)(366004)(376002)(51914003)(199004)(189003)(446003)(11346002)(6486002)(8676002)(81156014)(81166006)(3846002)(6116002)(71190400001)(71200400001)(229853002)(4744005)(305945005)(73956011)(7736002)(2616005)(66946007)(66446008)(64756008)(66556008)(66476007)(99286004)(76116006)(476003)(8936002)(316002)(6436002)(54906003)(68736007)(110136005)(486006)(2906002)(6512007)(66066001)(25786009)(76176011)(6506007)(2501003)(5660300002)(256004)(36756003)(118296001)(14444005)(6246003)(478600001)(186003)(102836004)(53936002)(14454004)(86362001)(2201001)(4326008)(26005)(14583001);DIR:OUT;SFP:1102;SCL:1;SRVR:TU4PR8401MB1134;H:TU4PR8401MB0607.NAMPRD84.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hpe.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: qQk0BoaS+/Of/Tc5GPEqDaywQu7IIuMJcSk68Eot6CTdzl+jHTKCAdSgWIPMHkAWz3KxE8MQoSNpXUs3vWXenwzz1RdK3SSTcRfyfYWsnWkR0KHkpm6aO7PCQ2FCVmsSvvV4CK+n2tWioAtOegxtaCDnxO7bpvGx7bZ+AhBg9IngJsLBOb7xx65/+L9E/52/qUPi8cMK+t4yeSwOFoWMhIdPXpMbPikyQHOK11d1CqRyaXBJRgalJHsP6/b3PPab+taG3HI8NR0fiWSwF/Rz89vCmxyMhWwGCPomYrTDSupiAXdSsAWjU40aDSGoRv5auRSi28iAYEJZ6MgwzWY1bmp8XThup9IGF5/x54lIIu/pUtDeNte8Uz4ncupeJ6bfOoXtQxwYGqPGwA+La2WjVSyOHyJFRKqxIFcLbgnbgPg=
Content-Type: text/plain; charset="utf-8"
Content-ID: <B909AB302DB5BC46AAA96D9F1BC612BA@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 4f3471c7-f213-4e41-adad-08d6da2dbdcb
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 May 2019 18:38:51.0738
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 105b2061-b669-4b31-92ac-24d304d195dc
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: TU4PR8401MB1134
X-OriginatorOrg: hpe.com
X-HPE-SCL: -1
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-16_15:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905160116
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCAyMDE5LTA1LTE1IGF0IDA4OjA1ICswNTMwLCBBbnNodW1hbiBLaGFuZHVhbCB3cm90
ZToNCj4gVmlydHVhbCBhZGRyZXNzIGFsaWdubWVudCBpcyBlc3NlbnRpYWwgaW4gZW5zdXJpbmcg
Y29ycmVjdCBjbGVhcmluZyBmb3IgYWxsDQo+IGludGVybWVkaWF0ZSBsZXZlbCBwZ3RhYmxlIGVu
dHJpZXMgYW5kIGZyZWVpbmcgYXNzb2NpYXRlZCBwZ3RhYmxlIHBhZ2VzLiBBbg0KPiB1bmFsaWdu
ZWQgYWRkcmVzcyBjYW4gZW5kIHVwIHJhbmRvbWx5IGZyZWVpbmcgcGd0YWJsZSBwYWdlIHRoYXQg
cG90ZW50aWFsbHkNCj4gc3RpbGwgY29udGFpbnMgdmFsaWQgbWFwcGluZ3MuIEhlbmNlIGFsc28g
Y2hlY2sgaXQncyBhbGlnbm1lbnQgYWxvbmcgd2l0aA0KPiBleGlzdGluZyBwaHlzX2FkZHIgY2hl
Y2suDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBBbnNodW1hbiBLaGFuZHVhbCA8YW5zaHVtYW4ua2hh
bmR1YWxAYXJtLmNvbT4NCj4gQ2M6IFRvc2hpIEthbmkgPHRvc2hpLmthbmlAaHBlLmNvbT4NCj4g
Q2M6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+DQo+IENjOiBXaWxs
IERlYWNvbiA8d2lsbC5kZWFjb25AYXJtLmNvbT4NCj4gQ2M6IENoaW50YW4gUGFuZHlhIDxjcGFu
ZHlhQGNvZGVhdXJvcmEub3JnPg0KPiBDYzogVGhvbWFzIEdsZWl4bmVyIDx0Z2x4QGxpbnV0cm9u
aXguZGU+DQo+IENjOiBDYXRhbGluIE1hcmluYXMgPGNhdGFsaW4ubWFyaW5hc0Bhcm0uY29tPg0K
PiAtLS0NCj4gQ2hhbmdlcyBpbiBWNDoNCj4gDQo+IC0gQWRkZWQgc2ltaWxhciBjaGVjayBmb3Ig
aW9yZW1hcF90cnlfaHVnZV9wNGQoKSBhcyBwZXIgVG9zaGkgS2FuaQ0KDQpUaGFua3MgZm9yIHRo
ZSB1cGRhdGUuIEl0IGxvb2tzIGdvb2QgdG8gbWUuDQoNClJldmlld2VkLWJ5OiBUb3NoaSBLYW5p
IDx0b3NoaS5rYW5pQGhwZS5jb20+DQoNCi1Ub3NoaQ0K

