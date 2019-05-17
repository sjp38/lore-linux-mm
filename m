Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7630C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:57:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A83E216FD
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:57:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="q5wK0QaL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A83E216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30A6F6B0006; Fri, 17 May 2019 13:57:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 295306B0008; Fri, 17 May 2019 13:57:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EAC56B000A; Fri, 17 May 2019 13:57:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B10186B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 13:57:36 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h2so11760813edi.13
        for <linux-mm@kvack.org>; Fri, 17 May 2019 10:57:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=zfJ1f1qCesyo9VZPoLq6eXOwun65crUZfvfXFlEfK+E=;
        b=i2FDecMlvYdOK9cyYr4ZzeoeTciVzUUkROb4YiwhT0fBD7sEtmhnWpz8TwyS/6Vy44
         NeqFKTqAiXzB8QLqeqJl6DsHV7yT96dT+H1xE3IqYRBeownZ87OUdHEzx1CElncRh2LI
         4o/JMgr9y2bXQqhA0irht0JtlbVAnRNYi8UNr05lvQHw8QNcvrcRfRIdr1w5Gflk2Q28
         aMLn/svfZktAImI8+UVPWnDfe3MXOZMgJ8CEdRVyPO8EWespOu1+rsJqMlxPjt4Erep2
         xVjCBZQjf/0z80xFhdFsIDoHPopSU4KY3UCj/vgb8byNPIWgf5bGsvCZGXGUD4rVmYIP
         DiXA==
X-Gm-Message-State: APjAAAUVmzFDAf0oFn++f+bT6nqGj4oR/eubK5phEqcEZw+QGJZFcyp+
	dKDE9QW4g3ws6y29R5cj7bw1hDkQ0tRzmU8UOR8qKiLdkmrOLmhGi7/cwqjof5ySHApoxRVezlQ
	P5oFbFQhoZxeAUzt3MqbJpwMHTIDHpUZav8eRU2dyU528rKVIiaNfguSS4An6g7vzgw==
X-Received: by 2002:a17:906:90c6:: with SMTP id v6mr22503638ejw.111.1558115855903;
        Fri, 17 May 2019 10:57:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+SeLdSwZklT5ObFWsvFFGAby20Ra0kzzAbW97lQQEf9XDRDakgfg/0fC4iyoxrr35V40E
X-Received: by 2002:a17:906:90c6:: with SMTP id v6mr22503578ejw.111.1558115854996;
        Fri, 17 May 2019 10:57:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558115854; cv=none;
        d=google.com; s=arc-20160816;
        b=hxcYZZMNx6EddJuL3sGvFJvlVpAXk2gfIgy/RfoCYgEGuTXf1pGTS4WYSfoNQFcIJF
         qqz4o+jLcaBNXKsSWSIfRB4YrI15wGry5Cc6BSOXPHSnq/uoI0WxY35F0g2qMMfX5B6n
         EqcWZhtzCXr9JgIKy3jwslWVHX1qtFI/cLj4WodS7vIkoFCa0StoqXfkCfKisFpyeETS
         ux976c1Oo0N2CHIbla2auFwszxhwM2qxwQPSXhahyQa5PbNcBZa1d5bNIxElYfql6NFw
         l3JR/Jl1V+ID4IzJfL6Qp4rLWeSwQEYWs3tO674385l5g0PAOTbBbbawPe3lfSlW8M9N
         Ca6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=zfJ1f1qCesyo9VZPoLq6eXOwun65crUZfvfXFlEfK+E=;
        b=zXaJWd5YX94ocE6qVQcp9TsJqRqpd+SOwN6QOYwCz/bO5QPRZxjIDW1alOtZlDy+fS
         tWCuIXMjK+/Xv7gwFpeuPObNRvcSnbei9SL1rQZp/Zev53XMib70iJcH3xx6ByWqS9fO
         wV5lCy5s8TAGJqNZQBF0KvF+9W/DYY/ZNCoWy8lWsCB4duIX0dd1cNj2TKLL/S9h8rtw
         rHmToC7bxpYfXHlVs3d+As+o49K2WmSO0rjdhu8xMbqS/JxBTE/GE11KNNXpxq+Itxzw
         fxO60m9vLVRuJB9ynzDJmEJ5XTYdZXc4pypvUpkeCif+mKCeJDNxsnvgb5+cT7HoSy89
         kz0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=q5wK0QaL;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.80.59 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800059.outbound.protection.outlook.com. [40.107.80.59])
        by mx.google.com with ESMTPS id i12si957625ejd.28.2019.05.17.10.57.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 17 May 2019 10:57:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.80.59 as permitted sender) client-ip=40.107.80.59;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=q5wK0QaL;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.80.59 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=zfJ1f1qCesyo9VZPoLq6eXOwun65crUZfvfXFlEfK+E=;
 b=q5wK0QaLh/+XKglRd4RCI0j59oYBmyIfUoXz+DE8MxojSsAAV7ghfNxrH1m0DX/EZ4kv3fJ4dp9HiX5K4AAewPNIBegON6nfvKBK6YDDcLU0OEkYz5TYWoQZ/FjwKjLU4oJk2YoMm4D6/x2/LAw2yOKPiwxeDjZHqkQ+ZjTbrAA=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB6007.namprd05.prod.outlook.com (20.178.53.92) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.7; Fri, 17 May 2019 17:57:22 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098%7]) with mapi id 15.20.1922.002; Fri, 17 May 2019
 17:57:22 +0000
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: Arnd Bergmann <arnd@arndb.de>, Julien Freche <jfreche@vmware.com>,
	Pv-drivers <Pv-drivers@vmware.com>, Jason Wang <jasowang@redhat.com>, lkml
	<linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 0/4] vmw_balloon: Compaction and shrinker support
Thread-Topic: [PATCH v4 0/4] vmw_balloon: Compaction and shrinker support
Thread-Index: AQHU+5sfw4lXp6MJj0Ov0LaKSU1Rk6ZaOUgAgBV2VACAAAPxgIAACS+A
Date: Fri, 17 May 2019 17:57:22 +0000
Message-ID: <26FEBE86-AF49-428F-9C9F-1FA435ADCB54@vmware.com>
References: <20190425115445.20815-1-namit@vmware.com>
 <8A2D1D43-759A-4B09-B781-31E9002AE3DA@vmware.com>
 <9AD9FE33-1825-4D1A-914F-9C29DF93DC8D@vmware.com>
 <20190517172429.GA21509@kroah.com>
In-Reply-To: <20190517172429.GA21509@kroah.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6e0dc56b-e90b-47e3-15c6-08d6daf11cd2
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB6007;
x-ms-traffictypediagnostic: BYAPR05MB6007:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <BYAPR05MB600747377EAE958A3202486DD00B0@BYAPR05MB6007.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3826;
x-forefront-prvs: 0040126723
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(376002)(366004)(136003)(396003)(39860400002)(199004)(189003)(33656002)(8936002)(8676002)(81166006)(81156014)(6916009)(316002)(229853002)(71190400001)(71200400001)(6436002)(6512007)(7736002)(478600001)(305945005)(83716004)(476003)(6246003)(11346002)(4326008)(2616005)(86362001)(2906002)(66066001)(486006)(3846002)(6116002)(186003)(26005)(446003)(36756003)(53936002)(68736007)(25786009)(66476007)(54906003)(14444005)(66556008)(64756008)(66446008)(6486002)(256004)(76176011)(53546011)(102836004)(6506007)(5660300002)(76116006)(73956011)(66946007)(14454004)(82746002)(99286004);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB6007;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 dNN6XgPo5hvx1UB+NfT0AYgtRI9+ZVm3HoykNJEQ7cRftnheN13qTPZxALoNjsPKdDa9ClcPTh96z9lch6BLh/cvPZWNNFWHy6kAEL7BQffUhqdtiBMARSJrxFcXB1aa8lwTxeX8ycBI8QqP/9JeWuGbo0J0cxLWDP9kJRdso5a6dVUQRxDEfi2BrFChmzqO3mHLUYAc1KT0j3RY3ZYvqovjuTAv5Rm5ivuOmqCQBA+ZmPX1I6qODYXrM0syTZat+oCco9qpFHx1/fOiUqkhZ7GvQH3ojWSyeTHr1KgPA9UfITObZDF9Mkrq/2mFZTJyArNbq4CZo3gZYmZPnGuF0Bg7LnJJie7aWlI4c8i7zPNZfFUTVZfQcJubwxw2euTlg5g72r3+rjBE/lSQdzxBoJDh9TalPGqp6POOHkT3bC0=
Content-Type: text/plain; charset="utf-8"
Content-ID: <BF90EFC62CAD0944AB47C0512DCC17F0@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6e0dc56b-e90b-47e3-15c6-08d6daf11cd2
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 May 2019 17:57:22.3448
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB6007
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBNYXkgMTcsIDIwMTksIGF0IDEwOjI0IEFNLCBHcmVnIEtyb2FoLUhhcnRtYW4gPGdyZWdr
aEBsaW51eGZvdW5kYXRpb24ub3JnPiB3cm90ZToNCj4gDQo+IE9uIEZyaSwgTWF5IDE3LCAyMDE5
IGF0IDA1OjEwOjIzUE0gKzAwMDAsIE5hZGF2IEFtaXQgd3JvdGU6DQo+Pj4gT24gTWF5IDMsIDIw
MTksIGF0IDY6MjUgUE0sIE5hZGF2IEFtaXQgPG5hbWl0QHZtd2FyZS5jb20+IHdyb3RlOg0KPj4+
IA0KPj4+PiBPbiBBcHIgMjUsIDIwMTksIGF0IDQ6NTQgQU0sIE5hZGF2IEFtaXQgPG5hbWl0QHZt
d2FyZS5jb20+IHdyb3RlOg0KPj4+PiANCj4+Pj4gVk13YXJlIGJhbGxvb24gZW5oYW5jZW1lbnRz
OiBhZGRpbmcgc3VwcG9ydCBmb3IgbWVtb3J5IGNvbXBhY3Rpb24sDQo+Pj4+IG1lbW9yeSBzaHJp
bmtlciAodG8gcHJldmVudCBPT00pIGFuZCBzcGxpdHRpbmcgb2YgcmVmdXNlZCBwYWdlcyB0bw0K
Pj4+PiBwcmV2ZW50IHJlY3VycmluZyBpbmZsYXRpb25zLg0KPj4+PiANCj4+Pj4gUGF0Y2hlcyAx
LTI6IFN1cHBvcnQgZm9yIGNvbXBhY3Rpb24NCj4+Pj4gUGF0Y2ggMzogU3VwcG9ydCBmb3IgbWVt
b3J5IHNocmlua2VyIC0gZGlzYWJsZWQgYnkgZGVmYXVsdA0KPj4+PiBQYXRjaCA0OiBTcGxpdCBy
ZWZ1c2VkIHBhZ2VzIHRvIGltcHJvdmUgcGVyZm9ybWFuY2UNCj4+Pj4gDQo+Pj4+IHYzLT52NDoN
Cj4+Pj4gKiAiZ2V0IGFyb3VuZCB0byIgY29tbWVudCBbTWljaGFlbF0NCj4+Pj4gKiBQdXQgbGlz
dF9hZGQgdW5kZXIgcGFnZSBsb2NrIFtNaWNoYWVsXQ0KPj4+PiANCj4+Pj4gdjItPnYzOg0KPj4+
PiAqIEZpeGluZyB3cm9uZyBhcmd1bWVudCB0eXBlIChpbnQtPnNpemVfdCkgW01pY2hhZWxdDQo+
Pj4+ICogRml4aW5nIGEgY29tbWVudCAoaXQpIFtNaWNoYWVsXQ0KPj4+PiAqIFJlaW5zdGF0aW5n
IHRoZSBCVUdfT04oKSB3aGVuIHBhZ2UgaXMgbG9ja2VkIFtNaWNoYWVsXSANCj4+Pj4gDQo+Pj4+
IHYxLT52MjoNCj4+Pj4gKiBSZXR1cm4gbnVtYmVyIG9mIHBhZ2VzIGluIGxpc3QgZW5xdWV1ZS9k
ZXF1ZXVlIGludGVyZmFjZXMgW01pY2hhZWxdDQo+Pj4+ICogUmVtb3ZlZCBmaXJzdCB0d28gcGF0
Y2hlcyB3aGljaCB3ZXJlIGFscmVhZHkgbWVyZ2VkDQo+Pj4+IA0KPj4+PiBOYWRhdiBBbWl0ICg0
KToNCj4+Pj4gbW0vYmFsbG9vbl9jb21wYWN0aW9uOiBMaXN0IGludGVyZmFjZXMNCj4+Pj4gdm13
X2JhbGxvb246IENvbXBhY3Rpb24gc3VwcG9ydA0KPj4+PiB2bXdfYmFsbG9vbjogQWRkIG1lbW9y
eSBzaHJpbmtlcg0KPj4+PiB2bXdfYmFsbG9vbjogU3BsaXQgcmVmdXNlZCBwYWdlcw0KPj4+PiAN
Cj4+Pj4gZHJpdmVycy9taXNjL0tjb25maWcgICAgICAgICAgICAgICB8ICAgMSArDQo+Pj4+IGRy
aXZlcnMvbWlzYy92bXdfYmFsbG9vbi5jICAgICAgICAgfCA0ODkgKysrKysrKysrKysrKysrKysr
KysrKysrKystLS0NCj4+Pj4gaW5jbHVkZS9saW51eC9iYWxsb29uX2NvbXBhY3Rpb24uaCB8ICAg
NCArDQo+Pj4+IG1tL2JhbGxvb25fY29tcGFjdGlvbi5jICAgICAgICAgICAgfCAxNDQgKysrKysr
LS0tDQo+Pj4+IDQgZmlsZXMgY2hhbmdlZCwgNTUzIGluc2VydGlvbnMoKyksIDg1IGRlbGV0aW9u
cygtKQ0KPj4+PiANCj4+Pj4gLS0gDQo+Pj4+IDIuMTkuMQ0KPj4+IA0KPj4+IFBpbmcuDQo+PiAN
Cj4+IFBpbmcuDQo+PiANCj4+IEdyZWcsIGRpZCBpdCBnb3QgbG9zdCBhZ2Fpbj8NCj4gDQo+IA0K
PiBJIHRob3VnaHQgeW91IG5lZWRlZCB0aGUgbW0gZGV2ZWxvcGVycyB0byBhY2sgdGhlIGZpcnN0
IHBhdGNoLCBkaWQgdGhhdA0KPiBldmVyIGhhcHBlbj8NCg0KWWVzLiBZb3Ugd2lsbCBzZWUgTWlj
aGFlbCBUc2lya2lu4oCZcyDigJxBY2tlZC1ieSIgb24gaXQuDQoNCg==

