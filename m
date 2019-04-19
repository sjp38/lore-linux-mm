Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C546C282E0
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 22:59:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E8FA21736
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 22:59:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="f0FSmr18"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E8FA21736
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42C046B0003; Fri, 19 Apr 2019 18:59:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DA926B0006; Fri, 19 Apr 2019 18:59:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A4DD6B0007; Fri, 19 Apr 2019 18:59:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CD2BC6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 18:59:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w5so2673572eda.16
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 15:59:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=VT8nZW5dos+3pCPX64wfw4xqA1GLqtfELwI5iKGog4Y=;
        b=UP0OA5SS0h2pZ8r3B7EUOpkD08fVS+lUS4mh23d9NEWa999Jf3qTWCNpN0lJMYRx4l
         5bYr0n38baCMPjpFCTTuV34su+tmmuBunZlKNYaxAWbi3YxyWiCQa9oHFCE8lYx5O3/+
         RelQnSyKTRxs0Tff5+0xgAGVVZKG/bWzChj6B1u46vzG2xpCKQ3+Y/7tZdlltvslkkru
         B8MTkcCQenxq2wJNtx8SG46cf86/c/IdEOKRV5coAECoOe6cDloPTpxk2bTmheHO33KD
         ovcC6DFrtQ/hxRPV6zInhzzWC5u8L3S42xjkixE8wIhjWAERUIlBfBEmnZ7EB6daz2t9
         52cQ==
X-Gm-Message-State: APjAAAXsfrY8UoJ4qX6Lgg+gPI9BlD/GRZDwzc7dAYjfzPf6+WHHB23b
	jxnKErAF3YgfkzYBg6T7kOD8cQsZMbOxBa/G1iJFCdgqTOmtDvFCdbdGZPIG9tlJIFa6rUcuFH0
	33gudlNC1tXxaU+1GHWOBezihKi2PhBx8NBdEF2QdBINFJRBI/roC5+KHnR+zVjSnKQ==
X-Received: by 2002:a50:ca88:: with SMTP id x8mr3886348edh.139.1555714742357;
        Fri, 19 Apr 2019 15:59:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyj4BLttHop+KKB64G5Crkt1+/jnQ00GaqHrgJJl42QbQGqs8fi6D2vBu87dz3w0ISVtZCt
X-Received: by 2002:a50:ca88:: with SMTP id x8mr3886323edh.139.1555714741587;
        Fri, 19 Apr 2019 15:59:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555714741; cv=none;
        d=google.com; s=arc-20160816;
        b=oty/I8Zv7L0jAslc/mqhmgxvfbHHSAXthijblKs1DsWssTjCaZ5BjWhYgl1dJnm9ww
         CHVScLQnLsTtGYhZsq7vajeBeHYnvoCYQZTmwkNZWC3Uu6yfoIhY0+Xdh1s4Mr65Pm2x
         v363GKkz20cVfwK6fTYjOHbU+GgnhmFFTQPJ2ANkrdu/Un/4Scj0M86Ki7VHf0fuNMnw
         JZgN9H4s4Vajxl4dk+h6/vO+4WlCsDnSkncL/hyPeANC6o3wYmpHjss2ER20oG7y76Ql
         MukdM0h8bRHafYLbyn6ROuLujHl1EjaMV1njoJ+zmfU9gsB1HiiCs+9CxW7fMY4+rb9t
         t2wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=VT8nZW5dos+3pCPX64wfw4xqA1GLqtfELwI5iKGog4Y=;
        b=M0jhBcuHwlIbiVWknlBfeuiM+ymKwQlcfp8fVAYQL3HtdYY4EbsVhmQGUlPU3QYkdR
         BG/iQhLfFaMSMs8xuPl1FgMGd7b/sduMDlTYFDjHIxdnv1AKvUXhfap0tQaYCay+NBub
         /ftWo+7cF0ZDpBCSvGLXwAfqQz9sZabvqpGWB6GbY97VhJMOmL6Hy+e8wo7icqCtN98u
         Uwwf3huvXVHULo4IrALsOW4tuwsr0s+dJa7GRSv6U00dQ+uHWx0BA3HXzl5ZnQLFFTPN
         t1sYEg7gVphzqXSlW+QHEfhYvZL++DEJ5k6sj4mBZFSVULoMDkIquiSF88j3Tf8jimJk
         MsdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=f0FSmr18;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.77.59 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-eopbgr770059.outbound.protection.outlook.com. [40.107.77.59])
        by mx.google.com with ESMTPS id l40si2381200edc.435.2019.04.19.15.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 Apr 2019 15:59:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.77.59 as permitted sender) client-ip=40.107.77.59;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=f0FSmr18;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.77.59 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=VT8nZW5dos+3pCPX64wfw4xqA1GLqtfELwI5iKGog4Y=;
 b=f0FSmr182U+9tM81YTdO4ODxXxcBaQSVDab1MXeesv0DmIjoPEZqHwN2hr1mwjdKJdt5WwioIvonZO3u7IDLdp4Ani05UOcq9JLfZ2NTcqS5eqzuqJgng6cgPa+H2TWCsi2tkmfXHZeFe23bNEEO/R1B/8Wxj1/skzrsvUuj/q8=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB4504.namprd05.prod.outlook.com (52.135.203.140) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1835.6; Fri, 19 Apr 2019 22:58:53 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::4140:b8f2:8e3:f5fd]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::4140:b8f2:8e3:f5fd%4]) with mapi id 15.20.1813.011; Fri, 19 Apr 2019
 22:58:53 +0000
From: Nadav Amit <namit@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann
	<arnd@arndb.de>, Jason Wang <jasowang@redhat.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Pv-drivers <Pv-drivers@vmware.com>, Julien
 Freche <jfreche@vmware.com>
Subject: Re: [PATCH v2 1/4] mm/balloon_compaction: list interfaces
Thread-Topic: [PATCH v2 1/4] mm/balloon_compaction: list interfaces
Thread-Index: AQHU5L/fQHqTTJNOzkOghmdzHIOs1aZELwsAgAAHcICAAAPQAIAAAx8A
Date: Fri, 19 Apr 2019 22:58:53 +0000
Message-ID: <8FA36729-9174-409D-ADA6-CD50331866E4@vmware.com>
References: <20190328010718.2248-1-namit@vmware.com>
 <20190328010718.2248-2-namit@vmware.com>
 <20190419174452-mutt-send-email-mst@kernel.org>
 <B2DD0CC3-DA8D-408C-986F-130B4B00A892@vmware.com>
 <20190419183802-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190419183802-mutt-send-email-mst@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 12a8f4fb-316f-4846-2202-08d6c51a9889
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB4504;
x-ms-traffictypediagnostic: BYAPR05MB4504:
x-ms-exchange-purlcount: 1
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <BYAPR05MB45044245C84FEC727C612787D0270@BYAPR05MB4504.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0012E6D357
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(136003)(376002)(366004)(39860400002)(346002)(189003)(199004)(66556008)(54906003)(6306002)(316002)(305945005)(966005)(2616005)(446003)(6512007)(186003)(11346002)(36756003)(14454004)(476003)(97736004)(8676002)(4326008)(64756008)(68736007)(66946007)(66446008)(478600001)(6436002)(6916009)(229853002)(486006)(6486002)(107886003)(14444005)(102836004)(7736002)(53546011)(66066001)(81166006)(3846002)(83716004)(6116002)(256004)(26005)(6246003)(73956011)(99286004)(8936002)(25786009)(86362001)(33656002)(6506007)(93886005)(76176011)(2906002)(53936002)(71200400001)(82746002)(5660300002)(81156014)(71190400001)(76116006)(66476007);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB4504;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 WS3k3+i3W44dfviJz3Zu5zIH8VGe39HQOka7r+8X2QdKjbHeIXB6LnwXWKA2XfgjzCmtMqKcii1LV35ifreX6VLmiBXbEdlCU6kS9rnSyM31l2ZQMvynY4SL/Yu0vYKwB4HlI9GsqM+z/F2ilZd8kCWxGLIaDSjMhrSXUvqSh1DfLUdVd9YAFyNlWNL+oArdwOaZhQNJHsqAJ5XfIoVNU2mrWEFbJUuWjZva5+UVo/xMbLEu7d+32XVTQAOECBMCyDNDfe7KeWnwyKm5v0cHjvE8Ww6Q1sUMjZjN4PysrvHrjUKMjFWRykCS2jC1esEXPLvGYYPaYlpqbqh4wYPlnZ96QDL9crZc513PXWDykIQHaGx2WNJmKgH52fmi1DGvZ1fwMO1c1ISqrIojcOpyMC8kQSPvK6Barl5rCuXMXDQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <53FB3F53A3B0FA418D5DE7D5E126D154@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 12a8f4fb-316f-4846-2202-08d6c51a9889
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Apr 2019 22:58:53.6267
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB4504
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBBcHIgMTksIDIwMTksIGF0IDM6NDcgUE0sIE1pY2hhZWwgUy4gVHNpcmtpbiA8bXN0QHJl
ZGhhdC5jb20+IHdyb3RlOg0KPiANCj4gT24gRnJpLCBBcHIgMTksIDIwMTkgYXQgMTA6MzQ6MDRQ
TSArMDAwMCwgTmFkYXYgQW1pdCB3cm90ZToNCj4+PiBPbiBBcHIgMTksIDIwMTksIGF0IDM6MDcg
UE0sIE1pY2hhZWwgUy4gVHNpcmtpbiA8bXN0QHJlZGhhdC5jb20+IHdyb3RlOg0KPj4+IA0KPj4+
IE9uIFRodSwgTWFyIDI4LCAyMDE5IGF0IDAxOjA3OjE1QU0gKzAwMDAsIE5hZGF2IEFtaXQgd3Jv
dGU6DQo+Pj4+IEludHJvZHVjZSBpbnRlcmZhY2VzIGZvciBiYWxsb29uaW5nIGVucXVldWVpbmcg
YW5kIGRlcXVldWVpbmcgb2YgYSBsaXN0DQo+Pj4+IG9mIHBhZ2VzLiBUaGVzZSBpbnRlcmZhY2Vz
IHJlZHVjZSB0aGUgb3ZlcmhlYWQgb2Ygc3RvcmluZyBhbmQgcmVzdG9yaW5nDQo+Pj4+IElSUXMg
YnkgYmF0Y2hpbmcgdGhlIG9wZXJhdGlvbnMuIEluIGFkZGl0aW9uIHRoZXkgZG8gbm90IHBhbmlj
IGlmIHRoZQ0KPj4+PiBsaXN0IG9mIHBhZ2VzIGlzIGVtcHR5Lg0KPj4+PiANCj4+Pj4gQ2M6ICJN
aWNoYWVsIFMuIFRzaXJraW4iIDxtc3RAcmVkaGF0LmNvbT4NCj4+Pj4gQ2M6IEphc29uIFdhbmcg
PGphc293YW5nQHJlZGhhdC5jb20+DQo+Pj4+IENjOiBsaW51eC1tbUBrdmFjay5vcmcNCj4+Pj4g
Q2M6IHZpcnR1YWxpemF0aW9uQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnDQo+Pj4+IFJldmll
d2VkLWJ5OiBYYXZpZXIgRGVndWlsbGFyZCA8eGRlZ3VpbGxhcmRAdm13YXJlLmNvbT4NCj4+Pj4g
U2lnbmVkLW9mZi1ieTogTmFkYXYgQW1pdCA8bmFtaXRAdm13YXJlLmNvbT4NCj4+Pj4gLS0tDQo+
Pj4+IGluY2x1ZGUvbGludXgvYmFsbG9vbl9jb21wYWN0aW9uLmggfCAgIDQgKw0KPj4+PiBtbS9i
YWxsb29uX2NvbXBhY3Rpb24uYyAgICAgICAgICAgIHwgMTQ1ICsrKysrKysrKysrKysrKysrKysr
Ky0tLS0tLS0tDQo+Pj4+IDIgZmlsZXMgY2hhbmdlZCwgMTExIGluc2VydGlvbnMoKyksIDM4IGRl
bGV0aW9ucygtKQ0KPj4+PiANCj4+Pj4gZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvYmFsbG9v
bl9jb21wYWN0aW9uLmggYi9pbmNsdWRlL2xpbnV4L2JhbGxvb25fY29tcGFjdGlvbi5oDQo+Pj4+
IGluZGV4IGYxMTFjNzgwZWYxZC4uMWRhNzllZGFkYjY5IDEwMDY0NA0KPj4+PiAtLS0gYS9pbmNs
dWRlL2xpbnV4L2JhbGxvb25fY29tcGFjdGlvbi5oDQo+Pj4+ICsrKyBiL2luY2x1ZGUvbGludXgv
YmFsbG9vbl9jb21wYWN0aW9uLmgNCj4+Pj4gQEAgLTY0LDYgKzY0LDEwIEBAIGV4dGVybiBzdHJ1
Y3QgcGFnZSAqYmFsbG9vbl9wYWdlX2FsbG9jKHZvaWQpOw0KPj4+PiBleHRlcm4gdm9pZCBiYWxs
b29uX3BhZ2VfZW5xdWV1ZShzdHJ1Y3QgYmFsbG9vbl9kZXZfaW5mbyAqYl9kZXZfaW5mbywNCj4+
Pj4gCQkJCSBzdHJ1Y3QgcGFnZSAqcGFnZSk7DQo+Pj4+IGV4dGVybiBzdHJ1Y3QgcGFnZSAqYmFs
bG9vbl9wYWdlX2RlcXVldWUoc3RydWN0IGJhbGxvb25fZGV2X2luZm8gKmJfZGV2X2luZm8pOw0K
Pj4+PiArZXh0ZXJuIHNpemVfdCBiYWxsb29uX3BhZ2VfbGlzdF9lbnF1ZXVlKHN0cnVjdCBiYWxs
b29uX2Rldl9pbmZvICpiX2Rldl9pbmZvLA0KPj4+PiArCQkJCSAgICAgIHN0cnVjdCBsaXN0X2hl
YWQgKnBhZ2VzKTsNCj4+Pj4gK2V4dGVybiBzaXplX3QgYmFsbG9vbl9wYWdlX2xpc3RfZGVxdWV1
ZShzdHJ1Y3QgYmFsbG9vbl9kZXZfaW5mbyAqYl9kZXZfaW5mbywNCj4+Pj4gKwkJCQkgICAgIHN0
cnVjdCBsaXN0X2hlYWQgKnBhZ2VzLCBpbnQgbl9yZXFfcGFnZXMpOw0KPj4+IA0KPj4+IFdoeSBz
aXplX3QgSSB3b25kZXI/IEl0IGNhbiBuZXZlciBiZSA+IG5fcmVxX3BhZ2VzIHdoaWNoIGlzIGlu
dC4NCj4+PiBDYWxsZXJzIGFsc28gc2VlbSB0byBhc3N1bWUgaW50Lg0KPj4gDQo+PiBPbmx5IGJl
Y2F1c2Ugb24gdGhlIHByZXZpb3VzIGl0ZXJhdGlvbg0KPj4gKCBodHRwczovL2xrbWwub3JnL2xr
bWwvMjAxOS8yLzYvOTEyICkgeW91IHNhaWQ6DQo+PiANCj4+PiBBcmUgd2Ugc3VyZSB0aGlzIGlu
dCBuZXZlciBvdmVyZmxvd3M/IFdoeSBub3QganVzdCB1c2UgdTY0DQo+Pj4gb3Igc2l6ZV90IHN0
cmFpZ2h0IGF3YXk/DQo+IA0KPiBBbmQgdGhlIGFuc3dlciBpcyBiZWNhdXNlIG5fcmVxX3BhZ2Vz
IGlzIGFuIGludCB0b28/DQo+IA0KPj4gSSBhbSBvayBlaXRoZXIgd2F5LCBidXQgcGxlYXNlIGJl
IGNvbnNpc3RlbnQuDQo+IA0KPiBJIGd1ZXNzIG5fcmVxX3BhZ2VzIHNob3VsZCBiZSBzaXplX3Qg
dG9vIHRoZW4/DQoNClllcy4gSSB3aWxsIGNoYW5nZSBpdC4NCg0KPiANCj4+Pj4gc3RhdGljIGlu
bGluZSB2b2lkIGJhbGxvb25fZGV2aW5mb19pbml0KHN0cnVjdCBiYWxsb29uX2Rldl9pbmZvICpi
YWxsb29uKQ0KPj4+PiB7DQo+Pj4gDQo+Pj4gDQo+Pj4+IGRpZmYgLS1naXQgYS9tbS9iYWxsb29u
X2NvbXBhY3Rpb24uYyBiL21tL2JhbGxvb25fY29tcGFjdGlvbi5jDQo+Pj4+IGluZGV4IGVmODU4
ZDU0N2UyZC4uODhkNWQ5YTAxMDcyIDEwMDY0NA0KPj4+PiAtLS0gYS9tbS9iYWxsb29uX2NvbXBh
Y3Rpb24uYw0KPj4+PiArKysgYi9tbS9iYWxsb29uX2NvbXBhY3Rpb24uYw0KPj4+PiBAQCAtMTAs
NiArMTAsMTA2IEBADQo+Pj4+ICNpbmNsdWRlIDxsaW51eC9leHBvcnQuaD4NCj4+Pj4gI2luY2x1
ZGUgPGxpbnV4L2JhbGxvb25fY29tcGFjdGlvbi5oPg0KPj4+PiANCj4+Pj4gK3N0YXRpYyBpbnQg
YmFsbG9vbl9wYWdlX2VucXVldWVfb25lKHN0cnVjdCBiYWxsb29uX2Rldl9pbmZvICpiX2Rldl9p
bmZvLA0KPj4+PiArCQkJCSAgICAgc3RydWN0IHBhZ2UgKnBhZ2UpDQo+Pj4+ICt7DQo+Pj4+ICsJ
LyoNCj4+Pj4gKwkgKiBCbG9jayBvdGhlcnMgZnJvbSBhY2Nlc3NpbmcgdGhlICdwYWdlJyB3aGVu
IHdlIGdldCBhcm91bmQgdG8NCj4+Pj4gKwkgKiBlc3RhYmxpc2hpbmcgYWRkaXRpb25hbCByZWZl
cmVuY2VzLiBXZSBzaG91bGQgYmUgdGhlIG9ubHkgb25lDQo+Pj4+ICsJICogaG9sZGluZyBhIHJl
ZmVyZW5jZSB0byB0aGUgJ3BhZ2UnIGF0IHRoaXMgcG9pbnQuDQo+Pj4+ICsJICovDQo+Pj4+ICsJ
aWYgKCF0cnlsb2NrX3BhZ2UocGFnZSkpIHsNCj4+Pj4gKwkJV0FSTl9PTkNFKDEsICJiYWxsb29u
IGluZmxhdGlvbiBmYWlsZWQgdG8gZW5xdWV1ZSBwYWdlXG4iKTsNCj4+Pj4gKwkJcmV0dXJuIC1F
RkFVTFQ7DQo+Pj4gDQo+Pj4gTG9va3MgbGlrZSBhbGwgY2FsbGVycyBidWcgb24gYSBmYWlsdXJl
LiBTbyBsZXQncyBqdXN0IGRvIGl0IGhlcmUsDQo+Pj4gYW5kIHRoZW4gbWFrZSB0aGlzIHZvaWQ/
DQo+PiANCj4+IEFzIHlvdSBub3RlZCBiZWxvdywgYWN0dWFsbHkgYmFsbG9vbl9wYWdlX2xpc3Rf
ZW5xdWV1ZSgpIGRvZXMgbm90IGRvDQo+PiBhbnl0aGluZyB3aGVuIGFuIGVycm9yIG9jY3Vycy4g
SSByZWFsbHkgcHJlZmVyIHRvIGF2b2lkIGFkZGluZyBCVUdfT04oKSAtIA0KPj4gSSBhbHdheXMg
Z2V0IHB1c2hlZCBiYWNrIG9uIHN1Y2ggdGhpbmdzLiBZZXMsIHRoaXMgbWlnaHQgbGVhZCB0byBt
ZW1vcnkNCj4+IGxlYWssIGJ1dCB0aGVyZSBpcyBubyByZWFzb24gdG8gY3Jhc2ggdGhlIHN5c3Rl
bS4NCj4gDQo+IE5lZWQgdG8gYXVkaXQgY2FsbGVycyB0byBtYWtlIHN1cmUgdGhleSBkb24ndCBt
aXNiZWhhdmUgaW4gd29yc2Ugd2F5cy4NCj4gDQo+IEkgdGhpbmsgaW4gdGhpcyBjYXNlIHRoaXMg
aW5kaWNhdGVzIHRoYXQgc29tZW9uZSBpcyB1c2luZyB0aGUgcGFnZSBzbyBpZg0KPiBvbmUga2Vl
cHMgZ29pbmcgYW5kIGFkZHMgaXQgaW50byBiYWxsb29uIHRoaXMgd2lsbCBsZWFkIHRvIGNvcnJ1
cHRpb24gZG93biB0aGUgcm9hZC4NCj4gDQo+IElmIHlvdSBjYW4gY2hhbmdlIHRoZSBjYWxsZXIg
Y29kZSBzdWNoIHRoYXQgaXQncyBqdXN0IGEgbGVhaywNCj4gdGhlbiBhIHdhcm5pbmcgaXMgbW9y
ZSBhcHByb3ByaWF0ZS4gT3IgZXZlbiBkbyBub3Qgd2FybiBhdCBhbGwuDQoNClllcywgeW91IGFy
ZSByaWdodCAoYW5kIEkgd2FzIHdyb25nKSAtIHRoaXMgaXMgaW5kZWVkIG11Y2ggbW9yZSB0aGFu
IGENCm1lbW9yeSBsZWFrLiBJ4oCZbGwgc2VlIGlmIGl0IGlzIGVhc3kgdG8gaGFuZGxlIHRoaXMg
Y2FzZSAoSSBhbSBub3Qgc3VyZSksIGJ1dA0KSSB0aGluayB0aGUgd2FybmluZyBzaG91bGQgc3Rh
eS4NCg0KPj4+PiArCX0NCj4+Pj4gKwlsaXN0X2RlbCgmcGFnZS0+bHJ1KTsNCj4+Pj4gKwliYWxs
b29uX3BhZ2VfaW5zZXJ0KGJfZGV2X2luZm8sIHBhZ2UpOw0KPj4+PiArCXVubG9ja19wYWdlKHBh
Z2UpOw0KPj4+PiArCV9fY291bnRfdm1fZXZlbnQoQkFMTE9PTl9JTkZMQVRFKTsNCj4+Pj4gKwly
ZXR1cm4gMDsNCj4+Pj4gK30NCj4+Pj4gKw0KPj4+PiArLyoqDQo+Pj4+ICsgKiBiYWxsb29uX3Bh
Z2VfbGlzdF9lbnF1ZXVlKCkgLSBpbnNlcnRzIGEgbGlzdCBvZiBwYWdlcyBpbnRvIHRoZSBiYWxs
b29uIHBhZ2UNCj4+Pj4gKyAqCQkJCSBsaXN0Lg0KPj4+PiArICogQGJfZGV2X2luZm86IGJhbGxv
b24gZGV2aWNlIGRlc2NyaXB0b3Igd2hlcmUgd2Ugd2lsbCBpbnNlcnQgYSBuZXcgcGFnZSB0bw0K
Pj4+PiArICogQHBhZ2VzOiBwYWdlcyB0byBlbnF1ZXVlIC0gYWxsb2NhdGVkIHVzaW5nIGJhbGxv
b25fcGFnZV9hbGxvYy4NCj4+Pj4gKyAqDQo+Pj4+ICsgKiBEcml2ZXIgbXVzdCBjYWxsIGl0IHRv
IHByb3Blcmx5IGVucXVldWUgYSBiYWxsb29uIHBhZ2VzIGJlZm9yZSBkZWZpbml0aXZlbHkNCj4+
Pj4gKyAqIHJlbW92aW5nIGl0IGZyb20gdGhlIGd1ZXN0IHN5c3RlbS4NCj4+PiANCj4+PiBBIGJ1
bmNoIG9mIGdyYW1tYXIgZXJyb3IgaGVyZS4gUGxzIGZpeCBmb3IgY2xhcmlmeS4NCj4+PiBBbHNv
IC0gZG9jdW1lbnQgdGhhdCBub3RoaW5nIG11c3QgbG9jayB0aGUgcGFnZXM/IE1vcmUgYXNzdW1w
dGlvbnM/DQo+Pj4gV2hhdCBpcyAiaXQiIGluIHRoaXMgY29udGV4dD8gQWxsIHBhZ2VzPyBBbmQg
d2hhdCBkb2VzIHJlbW92aW5nIGZyb20NCj4+PiBndWVzdCBtZWFuPyBSZWFsbHkgYWRkaW5nIHRv
IHRoZSBiYWxsb29uPw0KPj4gDQo+PiBJIHByZXR0eSBtdWNoIGNvcHktcGFzdGVkIHRoaXMgZGVz
Y3JpcHRpb24gZnJvbSBiYWxsb29uX3BhZ2VfZW5xdWV1ZSgpLiBJDQo+PiBzZWUgdGhhdCB5b3Ug
ZWRpdGVkIHRoaXMgbWVzc2FnZSBpbiB0aGUgcGFzdCBhdCBsZWFzdCBjb3VwbGUgb2YgdGltZXMg
KGUuZy4sDQo+PiBjN2NkZmYwZTg2NDcxIOKAnHZpcnRpb19iYWxsb29uOiBmaXggZGVhZGxvY2sg
b24gT09N4oCdKSBhbmQgbGVmdCBpdCBhcyBpcy4NCj4+IA0KPj4gU28gbWF5YmUgYWxsIG9mIHRo
ZSBjb21tZW50cyBpbiB0aGlzIGZpbGUgbmVlZCBhIHJld29yaywgYnV0IEkgZG9u4oCZdCB0aGlu
aw0KPj4gdGhpcyBwYXRjaC1zZXQgbmVlZHMgdG8gZG8gaXQuDQo+IA0KPiBJIHNlZS4NCj4gVGhh
dCBvbmUgZGVhbHQgd2l0aCBvbmUgcGFnZSBzbyAiaXQiIHdhcyB0aGUgcGFnZS4gVGhpcyBvbmUg
ZGVhbHMgd2l0aA0KPiBtYW55IHBhZ2VzIHNvIHlvdSBjYW4ndCBqdXN0IGNvcHkgaXQgb3ZlciB3
aXRob3V0IGNoYW5nZXMuDQo+IE1ha2VzIGl0IGxvb2sgbGlrZSAiaXQiIHJlZmVycyB0byBkcml2
ZXIgb3IgZ3Vlc3QuDQoNCkkgd2lsbCBmaXgg4oCcaXTigJ0uIDstKQ0KDQo+IA0KPj4+PiArICoN
Cj4+Pj4gKyAqIFJldHVybjogbnVtYmVyIG9mIHBhZ2VzIHRoYXQgd2VyZSBlbnF1ZXVlZC4NCj4+
Pj4gKyAqLw0KPj4+PiArc2l6ZV90IGJhbGxvb25fcGFnZV9saXN0X2VucXVldWUoc3RydWN0IGJh
bGxvb25fZGV2X2luZm8gKmJfZGV2X2luZm8sDQo+Pj4+ICsJCQkgICAgICAgc3RydWN0IGxpc3Rf
aGVhZCAqcGFnZXMpDQo+Pj4+ICt7DQo+Pj4+ICsJc3RydWN0IHBhZ2UgKnBhZ2UsICp0bXA7DQo+
Pj4+ICsJdW5zaWduZWQgbG9uZyBmbGFnczsNCj4+Pj4gKwlzaXplX3Qgbl9wYWdlcyA9IDA7DQo+
Pj4+ICsNCj4+Pj4gKwlzcGluX2xvY2tfaXJxc2F2ZSgmYl9kZXZfaW5mby0+cGFnZXNfbG9jaywg
ZmxhZ3MpOw0KPj4+PiArCWxpc3RfZm9yX2VhY2hfZW50cnlfc2FmZShwYWdlLCB0bXAsIHBhZ2Vz
LCBscnUpIHsNCj4+Pj4gKwkJYmFsbG9vbl9wYWdlX2VucXVldWVfb25lKGJfZGV2X2luZm8sIHBh
Z2UpOw0KPj4+IA0KPj4+IERvIHdlIHdhbnQgdG8gZG8gc29tZXRoaW5nIGFib3V0IGFuIGVycm9y
IGhlcmU/DQo+PiANCj4+IEhtbeKApiBUaGlzIGlzIHJlYWxseSBzb21ldGhpbmcgdGhhdCBzaG91
bGQgbmV2ZXIgaGFwcGVuLCBidXQgSSBzdGlsbCBwcmVmZXINCj4+IHRvIGF2b2lkIEJVR19PTigp
LCBhcyBJIHNhaWQgYmVmb3JlLiBJIHdpbGwganVzdCBub3QgY291bnQgdGhlIHBhZ2UuDQo+IA0K
PiBDYWxsZXJzIGNhbiBCVUcgdGhlbiBpZiB0aGV5IHdhbnQuIFRoYXQgaXMgZmluZSBidXQgeW91
IHRoZW4NCj4gbmVlZCB0byBjaGFuZ2UgdGhlIGNhbGxlcnMgdG8gZG8gaXQuDQoNCk9rLCBJ4oCZ
bGwgcGF5IG1vcmUgYXR0ZW50aW9uIHRoaXMgdGltZS4gVGhhbmtzIQ0KDQo=

