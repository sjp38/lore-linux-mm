Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B8BBC742B2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:56:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D82322084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:56:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=os.amperecomputing.com header.i=@os.amperecomputing.com header.b="RLzxHkxs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D82322084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 748DE8E013A; Fri, 12 Jul 2019 06:56:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D2B08E00DB; Fri, 12 Jul 2019 06:56:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54D088E013A; Fri, 12 Jul 2019 06:56:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3078C8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:56:53 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id e20so10137873ioe.12
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:56:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=WAcDhTCCszW+EvtBveUDZM7yH6cPZubOi2R9jyvB+p8=;
        b=cfJIT5H8hO5KAn4ZgxjT5R4U3xgoFyzF1w/gpslVd1Lhdu2Z6hFnTNFw7HQwYapaNm
         mATO66/N+IUA+SwFD2el17FOetJ0W3dwC58qVkl4rvMd32E/YSv0pS5CxWY2IHtHEGnv
         STAqOLpP2xq5Dt9Oj3jPA2+tsF9caCnIUlNYqa24dadlNWUozj1/FCv+zsX9xEYQ3Gkm
         htO+esmnD02gY0quKv4o7NMEX18RqKOP6jpQiYFGz7b0LqJxvFS3ksLl8IaAtWT0N103
         BIh32Fxdpz7ujTlME4w3ZA01LQVcYnjqm+SZNAodCEY5bjKVoj2r/WWS010tRFJzo7fn
         pa0Q==
X-Gm-Message-State: APjAAAUhI2SgTukcrARiREjexfpoT69vS43ox3Rv8e4CICXhwv3raHyS
	vHFeNtRK7FCLQWGa66Es/Hb+KWEeF+c7FhZKauBdQ+9iwFpuk1i9XdKjUjV2FfyuyFgT8kSltYV
	CRAZyVkBpoxFS6yKiPFkO3GfIgB7ziwHgKud5EAG4z/YQtO7W+s1G/2XXs+56yvHggw==
X-Received: by 2002:a02:cb96:: with SMTP id u22mr10692881jap.118.1562929012849;
        Fri, 12 Jul 2019 03:56:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUJ0IDCT7ZrwjCA5HfNRvRUa3l7kj7iHOH8teljKwLT5djlyhbWFFvaQpjX7MICRiyUqVl
X-Received: by 2002:a02:cb96:: with SMTP id u22mr10692827jap.118.1562929012129;
        Fri, 12 Jul 2019 03:56:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562929012; cv=none;
        d=google.com; s=arc-20160816;
        b=DPUjvgcafIPRhApJq1JIPHkIQqYwHu3ueJ+Ig4V+yxQKs0VItalxLqy/haibmRjmIH
         Gj00/fqk1nIjb3+Z9RcD3DyVkl96uk32Qwawf2YrchsWEYJhkwfQ+mYBUwCMbm3Rd29w
         /oOTDgt0c1IGZOmjWgtR53xn/3AD9gBvzXWj96b13pMZf0/JTsvVQERgeG3WFZRs+A6F
         J8RlJGDEexQeC15PHsab2oxKAaJkHA0os9gvdxo8GJtJMPZJmSMjmH3O6VO6GtwjXr6l
         UcOtCZqhVYeARRsDXwOUyWa1ogc8KYsJ2YLygfbFefFngge5dxtVARXxSMmA+DQu+4FP
         ybDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=WAcDhTCCszW+EvtBveUDZM7yH6cPZubOi2R9jyvB+p8=;
        b=la+09ng/LyTlvFCflM5vByMvxLiXauUColSTt2n7fow2ctzl6MdbTVtZokqi4zUxF9
         8viO9+9Dktfo9i+KjJKkq/VNRKXUN4AepSG08HVQFiVfFeI69+/PohIo6lF+e1QJAcyG
         UAns/Vqn6hErOJ0DTuKv/Jc5ZPqLzCP9wJxYUGAotfZR2Y6w4dJb3MtU2YScpu/YlmAp
         NKh6x6KO7GNiHAZYIWGPFgsLO+NbKaAEYa6TErgPeeFQ6cGKQPGhf0j6pRDMyFfjBgfe
         wYb6JF0p7eYVSoAm4msl96MceLvF3oHxVEqwTm0muEK6mfOSPp1MjdhQPb5BxbF3oGna
         99UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=RLzxHkxs;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.80.125 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800125.outbound.protection.outlook.com. [40.107.80.125])
        by mx.google.com with ESMTPS id c3si12292798ioq.99.2019.07.12.03.56.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 03:56:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.80.125 as permitted sender) client-ip=40.107.80.125;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=RLzxHkxs;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.80.125 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=os.amperecomputing.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=WAcDhTCCszW+EvtBveUDZM7yH6cPZubOi2R9jyvB+p8=;
 b=RLzxHkxsAekTYM3YvJ169/tJGHBAUyq2BDSjAskAP8r/+tWetDCFu5V+kRlclXCdFEyMm3YwY5Q4SYor9m9ABtXmyTsaN1asQV8WILPOfomLFfdIsGw3M7OFVBvTSNU7TVI0+quFRrZ+ssyj0Yus9rC869dhYQWcxRxjYqw/ZR0=
Received: from BYAPR01MB4085.prod.exchangelabs.com (52.135.237.22) by
 BYAPR01MB4024.prod.exchangelabs.com (52.135.236.209) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Fri, 12 Jul 2019 10:56:47 +0000
Received: from BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80]) by BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80%7]) with mapi id 15.20.2052.020; Fri, 12 Jul 2019
 10:56:47 +0000
From: Hoan Tran OS <hoan@os.amperecomputing.com>
To: Michal Hocko <mhocko@kernel.org>
CC: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
	<will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil
 Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>, Pavel Tatashin
	<pavel.tatashin@microsoft.com>, Mike Rapoport <rppt@linux.ibm.com>, Alexander
 Duyck <alexander.h.duyck@linux.intel.com>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael
 Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin"
	<hpa@zytor.com>, "David S . Miller" <davem@davemloft.net>, Heiko Carstens
	<heiko.carstens@de.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian
 Borntraeger <borntraeger@de.ibm.com>, "open list:MEMORY MANAGEMENT"
	<linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-s390@vger.kernel.org"
	<linux-s390@vger.kernel.org>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Open Source
 Submission <patches@amperecomputing.com>
Subject: Re: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Thread-Topic: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Thread-Index: AQHVOD/24o0J5njgPEqkosNO5sbs8abGjx+AgABBUoA=
Date: Fri, 12 Jul 2019 10:56:47 +0000
Message-ID: <586ae736-a429-cf94-1520-1a94ffadad88@os.amperecomputing.com>
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
 <20190712070247.GM29483@dhcp22.suse.cz>
In-Reply-To: <20190712070247.GM29483@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: HK0P153CA0027.APCP153.PROD.OUTLOOK.COM
 (2603:1096:203:17::15) To BYAPR01MB4085.prod.exchangelabs.com
 (2603:10b6:a03:56::22)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=hoan@os.amperecomputing.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [14.161.176.39]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 807a3fd4-bfd6-442a-a336-08d706b7a280
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR01MB4024;
x-ms-traffictypediagnostic: BYAPR01MB4024:
x-microsoft-antispam-prvs:
 <BYAPR01MB40241C259D44AE3593493E10F1F20@BYAPR01MB4024.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 00963989E5
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(376002)(346002)(396003)(136003)(39850400004)(366004)(199004)(189003)(86362001)(102836004)(54906003)(7736002)(52116002)(68736007)(53936002)(66066001)(76176011)(3846002)(6246003)(8936002)(99286004)(386003)(107886003)(81156014)(81166006)(8676002)(6116002)(305945005)(6506007)(53546011)(31696002)(186003)(26005)(14454004)(71200400001)(71190400001)(5660300002)(31686004)(6512007)(66946007)(2906002)(4326008)(446003)(316002)(14444005)(476003)(229853002)(6486002)(6916009)(25786009)(6436002)(256004)(11346002)(66556008)(64756008)(7416002)(66476007)(486006)(66446008)(2616005)(478600001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR01MB4024;H:BYAPR01MB4085.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:0;MX:1;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 clhGm3T4TfgYriMEPdp+Yc+KHXC4dtGOA1DU0V7WJc5Mna/izBjYCUx9ZdOUovfNYZKJ2iOqefoJbRlfGAgRulkZjR1B2eeMA1M2ERswnTyWQLcnuMV0nU03EPFFjLMuvUXDkZao3WZA5CPxjpsCvlX9hLVSKzHiiVLbwmVLmjv4vz0o7SQNDOZBPQAQNEuMyNM4K1UskC/5cbrC9Q90eMcmP7BXfJKW4YY4asD/ucxsllVoDzKVNI0KIMbCSdDOLeFEZQHzHvH0yaW1jVn4c/PNOK7vHHFURpMEFHNsw7UXciQ2G7EObLLLAY4pRTaigJsWiU936lcHSOoDxgR9RsWiabBh1Eg9nF6LjFofTIKeWenTKlpWUcfNN9fJ1/dzekRUE71jberJ6szigN0RYRtGt3C3V+K3CJOTzYk/jpM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <25482F5148BFF740873F45BB6828D5BF@prod.exchangelabs.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 807a3fd4-bfd6-442a-a336-08d706b7a280
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Jul 2019 10:56:47.5823
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3bc2b170-fd94-476d-b0ce-4229bdc904a7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Hoan@os.amperecomputing.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR01MB4024
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGksDQoNCk9uIDcvMTIvMTkgMjowMiBQTSwgTWljaGFsIEhvY2tvIHdyb3RlOg0KPiBPbiBUaHUg
MTEtMDctMTkgMjM6MjU6NDQsIEhvYW4gVHJhbiBPUyB3cm90ZToNCj4+IEluIE5VTUEgbGF5b3V0
IHdoaWNoIG5vZGVzIGhhdmUgbWVtb3J5IHJhbmdlcyB0aGF0IHNwYW4gYWNyb3NzIG90aGVyIG5v
ZGVzLA0KPj4gdGhlIG1tIGRyaXZlciBjYW4gZGV0ZWN0IHRoZSBtZW1vcnkgbm9kZSBpZCBpbmNv
cnJlY3RseS4NCj4+DQo+PiBGb3IgZXhhbXBsZSwgd2l0aCBsYXlvdXQgYmVsb3cNCj4+IE5vZGUg
MCBhZGRyZXNzOiAwMDAwIHh4eHggMDAwMCB4eHh4DQo+PiBOb2RlIDEgYWRkcmVzczogeHh4eCAx
MTExIHh4eHggMTExMQ0KPj4NCj4+IE5vdGU6DQo+PiAgIC0gTWVtb3J5IGZyb20gbG93IHRvIGhp
Z2gNCj4+ICAgLSAwLzE6IE5vZGUgaWQNCj4+ICAgLSB4OiBJbnZhbGlkIG1lbW9yeSBvZiBhIG5v
ZGUNCj4+DQo+PiBXaGVuIG1tIHByb2JlcyB0aGUgbWVtb3J5IG1hcCwgd2l0aG91dCBDT05GSUdf
Tk9ERVNfU1BBTl9PVEhFUl9OT0RFUw0KPj4gY29uZmlnLCBtbSBvbmx5IGNoZWNrcyB0aGUgbWVt
b3J5IHZhbGlkaXR5IGJ1dCBub3QgdGhlIG5vZGUgaWQuDQo+PiBCZWNhdXNlIG9mIHRoYXQsIE5v
ZGUgMSBhbHNvIGRldGVjdHMgdGhlIG1lbW9yeSBmcm9tIG5vZGUgMCBhcyBiZWxvdw0KPj4gd2hl
biBpdCBzY2FucyBmcm9tIHRoZSBzdGFydCBhZGRyZXNzIHRvIHRoZSBlbmQgYWRkcmVzcyBvZiBu
b2RlIDEuDQo+Pg0KPj4gTm9kZSAwIGFkZHJlc3M6IDAwMDAgeHh4eCB4eHh4IHh4eHgNCj4+IE5v
ZGUgMSBhZGRyZXNzOiB4eHh4IDExMTEgMTExMSAxMTExDQo+Pg0KPj4gVGhpcyBsYXlvdXQgY291
bGQgb2NjdXIgb24gYW55IGFyY2hpdGVjdHVyZS4gVGhpcyBwYXRjaCBlbmFibGVzDQo+PiBDT05G
SUdfTk9ERVNfU1BBTl9PVEhFUl9OT0RFUyBieSBkZWZhdWx0IGZvciBOVU1BIHRvIGZpeCB0aGlz
IGlzc3VlLg0KPiANCj4gWWVzIGl0IGNhbiBvY2N1ciBvbiBhbnkgYXJjaCBidXQgbW9zdCBzYW5l
IHBsYXRmb3JtcyBzaW1wbHkgZG8gbm90DQo+IG92ZXJsYXAgcGh5c2ljYWwgcmFuZ2VzLiBTbyBJ
IGRvIG5vdCByZWFsbHkgc2VlIGFueSByZWFzb24gdG8NCj4gdW5jb25kaXRpb25hbGx5IGVuYWJs
ZSB0aGUgY29uZmlnIGZvciBldmVyeWJvZHkuIFdoYXQgaXMgYW4gYWR2YW50YWdlPw0KPiANCg0K
QXMgSSBvYnNlcnZlZCBmcm9tIGFyY2ggZm9sZGVyLCB0aGVyZSBhcmUgOSBhcmNoIHN1cHBvcnQg
TlVNQSBjb25maWcuDQoNCi4vYXJjaC9pYTY0L0tjb25maWc6Mzg3OmNvbmZpZyBOVU1BDQouL2Fy
Y2gvcG93ZXJwYy9LY29uZmlnOjU4Mjpjb25maWcgTlVNQQ0KLi9hcmNoL3NwYXJjL0tjb25maWc6
MjgxOmNvbmZpZyBOVU1BDQouL2FyY2gvYWxwaGEvS2NvbmZpZzo1NTc6Y29uZmlnIE5VTUENCi4v
YXJjaC9zaC9tbS9LY29uZmlnOjExMjpjb25maWcgTlVNQQ0KLi9hcmNoL2FybTY0L0tjb25maWc6
ODQxOmNvbmZpZyBOVU1BDQouL2FyY2gveDg2L0tjb25maWc6MTUzMTpjb25maWcgTlVNQQ0KLi9h
cmNoL21pcHMvS2NvbmZpZzoyNjQ2OmNvbmZpZyBOVU1BDQouL2FyY2gvczM5MC9LY29uZmlnOjQ0
MTpjb25maWcgTlVNQQ0KDQpBbmQgdGhlcmUgYXJlIDUgYXJjaCBlbmFibGVzIENPTkZJR19OT0RF
U19TUEFOX09USEVSX05PREVTIHdpdGggTlVNQQ0KDQphcmNoL3Bvd2VycGMvS2NvbmZpZzo2Mzc6
Y29uZmlnIE5PREVTX1NQQU5fT1RIRVJfTk9ERVMNCmFyY2gvc3BhcmMvS2NvbmZpZzoyOTk6Y29u
ZmlnIE5PREVTX1NQQU5fT1RIRVJfTk9ERVMNCmFyY2gveDg2L0tjb25maWc6MTU3NTpjb25maWcg
Tk9ERVNfU1BBTl9PVEhFUl9OT0RFUw0KYXJjaC9zMzkwL0tjb25maWc6NDQ2OmNvbmZpZyBOT0RF
U19TUEFOX09USEVSX05PREVTDQphcmNoL2FybTY0ICh3aGljaCBJIGludGVuZGVkIHRvIGVuYWJs
ZSBpbiB0aGUgb3JpZ2luYWwgcGF0Y2gpDQoNCkl0IHdvdWxkIGJlIGdvb2QgaWYgd2UgY2FuIGVu
YWJsZSBpdCBieS1kZWZhdWx0LiBPdGhlcndpc2UsIGxldCBhcmNoIA0KZW5hYmxlcyBpdCBieSB0
aGVtLXNlbGYuIERvIHlvdSBoYXZlIGFueSBzdWdnZXN0aW9ucz8NCg0KVGhhbmtzDQpIb2FuDQoN
Cg0K

