Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55992C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:22:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E128321874
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:22:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="jq9Q7Asb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E128321874
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89BC86B0007; Thu, 21 Mar 2019 09:22:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 820536B0008; Thu, 21 Mar 2019 09:22:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69BB16B000A; Thu, 21 Mar 2019 09:22:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB736B0007
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 09:22:44 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id i5so3022446otl.12
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 06:22:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=aHxe+E/Z0s1p4D8dULNFBtqHBTq0rFqXyAKCJilD0UA=;
        b=E6CYHx2ypHq3d4C924drkuoYwukKAX9DDgUr5TxfXknt2ueJDjM1sKzrTt/kEWCeJP
         WACbwszwI9SVBnRGldiJrAM+b/ihyBzIRO4BBqacFyi4fZX0HgQhg7yWXeBBdTto0tzE
         52oRu1DRHqQ3gJSjp6Bi1hjthTgO/Oxgvsief1OCWTW7UhvehSm+31TiK6KSDi1oSbkY
         S/Jyvfn5PknenRbFqV1cQzrrIYJwVYQOa0FKds+HdyM4Wgp/LxD/vS/yxamWw278tXM3
         5Lo1b9x8+sDX75ROZKpCVJfMcTiCFcC3cAr9YEn4T30cbn9JpTQygPr4EFxwmzMMkLDP
         ftQQ==
X-Gm-Message-State: APjAAAWOWoGwuRcvheiHOKoY+NFsVPPKQSba/V+OQ7Hn5nCskb4S/oU9
	P+7pa5vL98QQYawSokFA/1bM2rgKAM3ip2ElvSbJAgJ33vIvtLHVSinRNojwv15JLovd+pBKQYW
	0nnvzGdAZl5QuDZ+jbcyy8pp8UH8l8FtfZMpKJWgJ+qCpjjrEKgFDgqPywzgxW/jV1A==
X-Received: by 2002:a9d:70c3:: with SMTP id w3mr2576848otj.226.1553174563747;
        Thu, 21 Mar 2019 06:22:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjLyO9HSBt+dFXw8jicPyDVQZ2xQILKY7BxPWTlWfMlvSw0mKxaZiNv/ZJk266tXhOQhve
X-Received: by 2002:a9d:70c3:: with SMTP id w3mr2576793otj.226.1553174562953;
        Thu, 21 Mar 2019 06:22:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553174562; cv=none;
        d=google.com; s=arc-20160816;
        b=mDbU+UmtiPlnYbjNgylXci75jgEqJ7fO1bdVoVYFeYnjImXG9n1UDvDnNZhOFPXHJg
         ToRGari9CHa0sxnDslPzQ0a4Cw5F7xJs2c0uNiYnKSKD6FVlYtspDhB5qa2SrNlr10qe
         If7hUH7oBCAG2iECwMJbLdNlF/60r85BOc/0Jc5uGms4HsZCZauVRv7JWPfI7Ykt5mF9
         UmnzygGODKYuCFnBCtCl/Mi5YDBlh0RGmuMrXy9FKNZQ5C2zEnT5kkV0e4MchtNRPeyf
         lSZK97TzEt6w0MB1TIr6kdmecifatYJ3Ku5m/CqalLfv4CkxnAqH7gbp4RCM9Qdot0kc
         P4dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=aHxe+E/Z0s1p4D8dULNFBtqHBTq0rFqXyAKCJilD0UA=;
        b=jpmen/i/ImLO+lu+3ZuWvMY8RYJX4bM9FYBYT4cZzSC6Pjb7l5MJ1V6sadDgDj5xYX
         oP3dSO+/ys+Ku1J+F1Wr0hzbNY6vw+FZfZRrIBSvEbEXTtuFzJ3cjRCBj88u408tiC/D
         7eR0NvucRz5+TIlPiPNrP/MJM894teWnukrcFY4CfbyplXH1rqzcBJxhCEv5WCE8Iui6
         lzWGkZKFUWb5v7QLhOSeGnugbTrk1S4bQDZTNivuBNJylr8qml0Wj6mgIYypQ8OX3pyx
         nYwjAM6njO9+zM3C4psCZzwOkV1PPhf+BeJBOIgmvh4IqIW33B8Xz7yWelNj4taDUWLA
         ynRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=jq9Q7Asb;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.78.44 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780044.outbound.protection.outlook.com. [40.107.78.44])
        by mx.google.com with ESMTPS id g11si2179243otr.138.2019.03.21.06.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Mar 2019 06:22:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 40.107.78.44 as permitted sender) client-ip=40.107.78.44;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=jq9Q7Asb;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.78.44 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aHxe+E/Z0s1p4D8dULNFBtqHBTq0rFqXyAKCJilD0UA=;
 b=jq9Q7Asb4huOMOaI9xN/atlS4MLA5f2UKllUdAUIQlHhZ4X8oCmEDYHeWHZ0Jdm69vdxSRJCFupd491OIJ2q/aVWCYN/o9vb76V2WCtuq5NfyC8E1HaIhhEwW+QOiRuBmNcsNKKShGLiFIQtnfTUR74SbNdIwdHc8JlU1hyPsUM=
Received: from MN2PR05MB6141.namprd05.prod.outlook.com (20.178.241.217) by
 MN2PR05MB6621.namprd05.prod.outlook.com (20.178.247.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.15; Thu, 21 Mar 2019 13:22:35 +0000
Received: from MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad]) by MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad%6]) with mapi id 15.20.1750.010; Thu, 21 Mar 2019
 13:22:35 +0000
From: Thomas Hellstrom <thellstrom@vmware.com>
To: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>
CC: Thomas Hellstrom <thellstrom@vmware.com>, Andrew Morton
	<akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Will
 Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, Rik van
 Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko
	<mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Souptick Joarder
	<jrdr.linux@gmail.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: [RFC PATCH RESEND 2/3] mm: Add an apply_to_pfn_range interface
Thread-Topic: [RFC PATCH RESEND 2/3] mm: Add an apply_to_pfn_range interface
Thread-Index: AQHU3+kl9xNhc0w2DU+KAotZ5mJTVw==
Date: Thu, 21 Mar 2019 13:22:35 +0000
Message-ID: <20190321132140.114878-3-thellstrom@vmware.com>
References: <20190321132140.114878-1-thellstrom@vmware.com>
In-Reply-To: <20190321132140.114878-1-thellstrom@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR01CA0039.prod.exchangelabs.com (2603:10b6:a03:94::16)
 To MN2PR05MB6141.namprd05.prod.outlook.com (2603:10b6:208:c7::25)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=thellstrom@vmware.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.19.0.rc1
x-originating-ip: [208.91.2.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 77a15709-cc6e-436d-4e32-08d6ae0047cb
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:MN2PR05MB6621;
x-ms-traffictypediagnostic: MN2PR05MB6621:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB6621EF54469898B235B80A9EA1420@MN2PR05MB6621.namprd05.prod.outlook.com>
x-forefront-prvs: 0983EAD6B2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(136003)(39860400002)(346002)(376002)(396003)(189003)(199004)(6636002)(105586002)(316002)(110136005)(36756003)(54906003)(2501003)(66066001)(11346002)(446003)(478600001)(486006)(14454004)(2616005)(476003)(102836004)(76176011)(386003)(6506007)(68736007)(186003)(52116002)(26005)(106356001)(25786009)(81156014)(53936002)(8676002)(7416002)(97736004)(5660300002)(6512007)(6116002)(3846002)(8936002)(2906002)(66574012)(1076003)(86362001)(256004)(99286004)(14444005)(6486002)(50226002)(305945005)(81166006)(7736002)(71200400001)(4326008)(71190400001)(6436002);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6621;H:MN2PR05MB6141.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 /1gnCwNc6RWrD+n+G/RQODsiTRzHVjEsw5dcQuuPB4GPBzdFcpqbh4ZrA2V7uA/i/YHwPog1saCIJJFrI/KoLyPAsz1jotD1z8t+whpTnKdFsrUcOoKwU1LkLgqWdsqf/A9uup/AQ+xUUZ8v9Tk8O5ReXuNMniJj/aGseptQdIaTU1cjYdRT2tXpIueFkAJ7jTHKxM1IIEXtRO/uzKga+irUpxgIbqJ+8BV8sBkN2E+bbzeqPAjjt0B325x3CkTUkSzVO9PBsweHly2OGZpT1dOe0EVnmPna9JJ0AQK0uqttahKoEsEHt3P4gVgHVhGB+bW3qLAJfQNnfXScqWLp503irtvx2LBB7/rV2ceW9/6tDix6NmchZBTH/SZAKwuUTCtZaa10utXam+q6JQlx7jW+4jFeik38wz1E9IasJqE=
Content-Type: text/plain; charset="utf-8"
Content-ID: <33383462AE9B364691F45CF7AF35D031@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 77a15709-cc6e-436d-4e32-08d6ae0047cb
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Mar 2019 13:22:35.5339
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6621
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

VGhpcyBpcyBiYXNpY2FsbHkgYXBwbHlfdG9fcGFnZV9yYW5nZSB3aXRoIGFkZGVkIGZ1bmN0aW9u
YWxpdHk6DQpBbGxvY2F0aW5nIG1pc3NpbmcgcGFydHMgb2YgdGhlIHBhZ2UgdGFibGUgYmVjb21l
cyBvcHRpb25hbCwgd2hpY2gNCm1lYW5zIHRoYXQgdGhlIGZ1bmN0aW9uIGNhbiBiZSBndWFyYW50
ZWVkIG5vdCB0byBlcnJvciBpZiBhbGxvY2F0aW9uDQppcyBkaXNhYmxlZC4gQWxzbyBwYXNzaW5n
IG9mIHRoZSBjbG9zdXJlIHN0cnVjdCBhbmQgY2FsbGJhY2sgZnVuY3Rpb24NCmJlY29tZXMgZGlm
ZmVyZW50IGFuZCBtb3JlIGluIGxpbmUgd2l0aCBob3cgdGhpbmdzIGFyZSBkb25lIGVsc2V3aGVy
ZS4NCg0KRmluYWxseSB3ZSBrZWVwIGFwcGx5X3RvX3BhZ2VfcmFuZ2UgYXMgYSB3cmFwcGVyIGFy
b3VuZCBhcHBseV90b19wZm5fcmFuZ2UNCg0KQ2M6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgt
Zm91bmRhdGlvbi5vcmc+DQpDYzogTWF0dGhldyBXaWxjb3ggPHdpbGx5QGluZnJhZGVhZC5vcmc+
DQpDYzogV2lsbCBEZWFjb24gPHdpbGwuZGVhY29uQGFybS5jb20+DQpDYzogUGV0ZXIgWmlqbHN0
cmEgPHBldGVyekBpbmZyYWRlYWQub3JnPg0KQ2M6IFJpayB2YW4gUmllbCA8cmllbEBzdXJyaWVs
LmNvbT4NCkNjOiBNaW5jaGFuIEtpbSA8bWluY2hhbkBrZXJuZWwub3JnPg0KQ2M6IE1pY2hhbCBI
b2NrbyA8bWhvY2tvQHN1c2UuY29tPg0KQ2M6IEh1YW5nIFlpbmcgPHlpbmcuaHVhbmdAaW50ZWwu
Y29tPg0KQ2M6IFNvdXB0aWNrIEpvYXJkZXIgPGpyZHIubGludXhAZ21haWwuY29tPg0KQ2M6ICJK
w6lyw7RtZSBHbGlzc2UiIDxqZ2xpc3NlQHJlZGhhdC5jb20+DQpDYzogbGludXgtbW1Aa3ZhY2su
b3JnDQpDYzogbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZw0KU2lnbmVkLW9mZi1ieTogVGhv
bWFzIEhlbGxzdHJvbSA8dGhlbGxzdHJvbUB2bXdhcmUuY29tPg0KLS0tDQogaW5jbHVkZS9saW51
eC9tbS5oIHwgIDEwICsrKysNCiBtbS9tZW1vcnkuYyAgICAgICAgfCAxMjEgKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrLS0tLS0tLS0tLS0tDQogMiBmaWxlcyBjaGFuZ2VkLCA5OSBp
bnNlcnRpb25zKCspLCAzMiBkZWxldGlvbnMoLSkNCg0KZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGlu
dXgvbW0uaCBiL2luY2x1ZGUvbGludXgvbW0uaA0KaW5kZXggODBiYjY0MDhmZTczLi5iN2RkNGRk
ZDZlZmIgMTAwNjQ0DQotLS0gYS9pbmNsdWRlL2xpbnV4L21tLmgNCisrKyBiL2luY2x1ZGUvbGlu
dXgvbW0uaA0KQEAgLTI2MzIsNiArMjYzMiwxNiBAQCB0eXBlZGVmIGludCAoKnB0ZV9mbl90KShw
dGVfdCAqcHRlLCBwZ3RhYmxlX3QgdG9rZW4sIHVuc2lnbmVkIGxvbmcgYWRkciwNCiBleHRlcm4g
aW50IGFwcGx5X3RvX3BhZ2VfcmFuZ2Uoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHVuc2lnbmVkIGxv
bmcgYWRkcmVzcywNCiAJCQkgICAgICAgdW5zaWduZWQgbG9uZyBzaXplLCBwdGVfZm5fdCBmbiwg
dm9pZCAqZGF0YSk7DQogDQorc3RydWN0IHBmbl9yYW5nZV9hcHBseTsNCit0eXBlZGVmIGludCAo
KnB0ZXJfZm5fdCkocHRlX3QgKnB0ZSwgcGd0YWJsZV90IHRva2VuLCB1bnNpZ25lZCBsb25nIGFk
ZHIsDQorCQkJIHN0cnVjdCBwZm5fcmFuZ2VfYXBwbHkgKmNsb3N1cmUpOw0KK3N0cnVjdCBwZm5f
cmFuZ2VfYXBwbHkgew0KKwlzdHJ1Y3QgbW1fc3RydWN0ICptbTsNCisJcHRlcl9mbl90IHB0ZWZu
Ow0KKwl1bnNpZ25lZCBpbnQgYWxsb2M7DQorfTsNCitleHRlcm4gaW50IGFwcGx5X3RvX3Bmbl9y
YW5nZShzdHJ1Y3QgcGZuX3JhbmdlX2FwcGx5ICpjbG9zdXJlLA0KKwkJCSAgICAgIHVuc2lnbmVk
IGxvbmcgYWRkcmVzcywgdW5zaWduZWQgbG9uZyBzaXplKTsNCiANCiAjaWZkZWYgQ09ORklHX1BB
R0VfUE9JU09OSU5HDQogZXh0ZXJuIGJvb2wgcGFnZV9wb2lzb25pbmdfZW5hYmxlZCh2b2lkKTsN
CmRpZmYgLS1naXQgYS9tbS9tZW1vcnkuYyBiL21tL21lbW9yeS5jDQppbmRleCBkY2Q4MDMxM2Nm
MTAuLjBmZWI3MTkxYzJkMiAxMDA2NDQNCi0tLSBhL21tL21lbW9yeS5jDQorKysgYi9tbS9tZW1v
cnkuYw0KQEAgLTE5MzgsMTggKzE5MzgsMTcgQEAgaW50IHZtX2lvbWFwX21lbW9yeShzdHJ1Y3Qg
dm1fYXJlYV9zdHJ1Y3QgKnZtYSwgcGh5c19hZGRyX3Qgc3RhcnQsIHVuc2lnbmVkIGxvbmcNCiB9
DQogRVhQT1JUX1NZTUJPTCh2bV9pb21hcF9tZW1vcnkpOw0KIA0KLXN0YXRpYyBpbnQgYXBwbHlf
dG9fcHRlX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCBwbWRfdCAqcG1kLA0KLQkJCQkgICAg
IHVuc2lnbmVkIGxvbmcgYWRkciwgdW5zaWduZWQgbG9uZyBlbmQsDQotCQkJCSAgICAgcHRlX2Zu
X3QgZm4sIHZvaWQgKmRhdGEpDQorc3RhdGljIGludCBhcHBseV90b19wdGVfcmFuZ2Uoc3RydWN0
IHBmbl9yYW5nZV9hcHBseSAqY2xvc3VyZSwgcG1kX3QgKnBtZCwNCisJCQkgICAgICB1bnNpZ25l
ZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxvbmcgZW5kKQ0KIHsNCiAJcHRlX3QgKnB0ZTsNCiAJaW50
IGVycjsNCiAJcGd0YWJsZV90IHRva2VuOw0KIAlzcGlubG9ja190ICp1bmluaXRpYWxpemVkX3Zh
cihwdGwpOw0KIA0KLQlwdGUgPSAobW0gPT0gJmluaXRfbW0pID8NCisJcHRlID0gKGNsb3N1cmUt
Pm1tID09ICZpbml0X21tKSA/DQogCQlwdGVfYWxsb2Nfa2VybmVsKHBtZCwgYWRkcikgOg0KLQkJ
cHRlX2FsbG9jX21hcF9sb2NrKG1tLCBwbWQsIGFkZHIsICZwdGwpOw0KKwkJcHRlX2FsbG9jX21h
cF9sb2NrKGNsb3N1cmUtPm1tLCBwbWQsIGFkZHIsICZwdGwpOw0KIAlpZiAoIXB0ZSkNCiAJCXJl
dHVybiAtRU5PTUVNOw0KIA0KQEAgLTE5NjAsODYgKzE5NTksMTAzIEBAIHN0YXRpYyBpbnQgYXBw
bHlfdG9fcHRlX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3QgKm1tLCBwbWRfdCAqcG1kLA0KIAl0b2tl
biA9IHBtZF9wZ3RhYmxlKCpwbWQpOw0KIA0KIAlkbyB7DQotCQllcnIgPSBmbihwdGUrKywgdG9r
ZW4sIGFkZHIsIGRhdGEpOw0KKwkJZXJyID0gY2xvc3VyZS0+cHRlZm4ocHRlKyssIHRva2VuLCBh
ZGRyLCBjbG9zdXJlKTsNCiAJCWlmIChlcnIpDQogCQkJYnJlYWs7DQogCX0gd2hpbGUgKGFkZHIg
Kz0gUEFHRV9TSVpFLCBhZGRyICE9IGVuZCk7DQogDQogCWFyY2hfbGVhdmVfbGF6eV9tbXVfbW9k
ZSgpOw0KIA0KLQlpZiAobW0gIT0gJmluaXRfbW0pDQorCWlmIChjbG9zdXJlLT5tbSAhPSAmaW5p
dF9tbSkNCiAJCXB0ZV91bm1hcF91bmxvY2socHRlLTEsIHB0bCk7DQogCXJldHVybiBlcnI7DQog
fQ0KIA0KLXN0YXRpYyBpbnQgYXBwbHlfdG9fcG1kX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3QgKm1t
LCBwdWRfdCAqcHVkLA0KLQkJCQkgICAgIHVuc2lnbmVkIGxvbmcgYWRkciwgdW5zaWduZWQgbG9u
ZyBlbmQsDQotCQkJCSAgICAgcHRlX2ZuX3QgZm4sIHZvaWQgKmRhdGEpDQorc3RhdGljIGludCBh
cHBseV90b19wbWRfcmFuZ2Uoc3RydWN0IHBmbl9yYW5nZV9hcHBseSAqY2xvc3VyZSwgcHVkX3Qg
KnB1ZCwNCisJCQkgICAgICB1bnNpZ25lZCBsb25nIGFkZHIsIHVuc2lnbmVkIGxvbmcgZW5kKQ0K
IHsNCiAJcG1kX3QgKnBtZDsNCiAJdW5zaWduZWQgbG9uZyBuZXh0Ow0KLQlpbnQgZXJyOw0KKwlp
bnQgZXJyID0gMDsNCiANCiAJQlVHX09OKHB1ZF9odWdlKCpwdWQpKTsNCiANCi0JcG1kID0gcG1k
X2FsbG9jKG1tLCBwdWQsIGFkZHIpOw0KKwlwbWQgPSBwbWRfYWxsb2MoY2xvc3VyZS0+bW0sIHB1
ZCwgYWRkcik7DQogCWlmICghcG1kKQ0KIAkJcmV0dXJuIC1FTk9NRU07DQorDQogCWRvIHsNCiAJ
CW5leHQgPSBwbWRfYWRkcl9lbmQoYWRkciwgZW5kKTsNCi0JCWVyciA9IGFwcGx5X3RvX3B0ZV9y
YW5nZShtbSwgcG1kLCBhZGRyLCBuZXh0LCBmbiwgZGF0YSk7DQorCQlpZiAoIWNsb3N1cmUtPmFs
bG9jICYmIHBtZF9ub25lX29yX2NsZWFyX2JhZChwbWQpKQ0KKwkJCWNvbnRpbnVlOw0KKwkJZXJy
ID0gYXBwbHlfdG9fcHRlX3JhbmdlKGNsb3N1cmUsIHBtZCwgYWRkciwgbmV4dCk7DQogCQlpZiAo
ZXJyKQ0KIAkJCWJyZWFrOw0KIAl9IHdoaWxlIChwbWQrKywgYWRkciA9IG5leHQsIGFkZHIgIT0g
ZW5kKTsNCiAJcmV0dXJuIGVycjsNCiB9DQogDQotc3RhdGljIGludCBhcHBseV90b19wdWRfcmFu
Z2Uoc3RydWN0IG1tX3N0cnVjdCAqbW0sIHA0ZF90ICpwNGQsDQotCQkJCSAgICAgdW5zaWduZWQg
bG9uZyBhZGRyLCB1bnNpZ25lZCBsb25nIGVuZCwNCi0JCQkJICAgICBwdGVfZm5fdCBmbiwgdm9p
ZCAqZGF0YSkNCitzdGF0aWMgaW50IGFwcGx5X3RvX3B1ZF9yYW5nZShzdHJ1Y3QgcGZuX3Jhbmdl
X2FwcGx5ICpjbG9zdXJlLCBwNGRfdCAqcDRkLA0KKwkJCSAgICAgIHVuc2lnbmVkIGxvbmcgYWRk
ciwgdW5zaWduZWQgbG9uZyBlbmQpDQogew0KIAlwdWRfdCAqcHVkOw0KIAl1bnNpZ25lZCBsb25n
IG5leHQ7DQotCWludCBlcnI7DQorCWludCBlcnIgPSAwOw0KIA0KLQlwdWQgPSBwdWRfYWxsb2Mo
bW0sIHA0ZCwgYWRkcik7DQorCXB1ZCA9IHB1ZF9hbGxvYyhjbG9zdXJlLT5tbSwgcDRkLCBhZGRy
KTsNCiAJaWYgKCFwdWQpDQogCQlyZXR1cm4gLUVOT01FTTsNCisNCiAJZG8gew0KIAkJbmV4dCA9
IHB1ZF9hZGRyX2VuZChhZGRyLCBlbmQpOw0KLQkJZXJyID0gYXBwbHlfdG9fcG1kX3JhbmdlKG1t
LCBwdWQsIGFkZHIsIG5leHQsIGZuLCBkYXRhKTsNCisJCWlmICghY2xvc3VyZS0+YWxsb2MgJiYg
cHVkX25vbmVfb3JfY2xlYXJfYmFkKHB1ZCkpDQorCQkJY29udGludWU7DQorCQllcnIgPSBhcHBs
eV90b19wbWRfcmFuZ2UoY2xvc3VyZSwgcHVkLCBhZGRyLCBuZXh0KTsNCiAJCWlmIChlcnIpDQog
CQkJYnJlYWs7DQogCX0gd2hpbGUgKHB1ZCsrLCBhZGRyID0gbmV4dCwgYWRkciAhPSBlbmQpOw0K
IAlyZXR1cm4gZXJyOw0KIH0NCiANCi1zdGF0aWMgaW50IGFwcGx5X3RvX3A0ZF9yYW5nZShzdHJ1
Y3QgbW1fc3RydWN0ICptbSwgcGdkX3QgKnBnZCwNCi0JCQkJICAgICB1bnNpZ25lZCBsb25nIGFk
ZHIsIHVuc2lnbmVkIGxvbmcgZW5kLA0KLQkJCQkgICAgIHB0ZV9mbl90IGZuLCB2b2lkICpkYXRh
KQ0KK3N0YXRpYyBpbnQgYXBwbHlfdG9fcDRkX3JhbmdlKHN0cnVjdCBwZm5fcmFuZ2VfYXBwbHkg
KmNsb3N1cmUsIHBnZF90ICpwZ2QsDQorCQkJICAgICAgdW5zaWduZWQgbG9uZyBhZGRyLCB1bnNp
Z25lZCBsb25nIGVuZCkNCiB7DQogCXA0ZF90ICpwNGQ7DQogCXVuc2lnbmVkIGxvbmcgbmV4dDsN
Ci0JaW50IGVycjsNCisJaW50IGVyciA9IDA7DQogDQotCXA0ZCA9IHA0ZF9hbGxvYyhtbSwgcGdk
LCBhZGRyKTsNCisJcDRkID0gcDRkX2FsbG9jKGNsb3N1cmUtPm1tLCBwZ2QsIGFkZHIpOw0KIAlp
ZiAoIXA0ZCkNCiAJCXJldHVybiAtRU5PTUVNOw0KKw0KIAlkbyB7DQogCQluZXh0ID0gcDRkX2Fk
ZHJfZW5kKGFkZHIsIGVuZCk7DQotCQllcnIgPSBhcHBseV90b19wdWRfcmFuZ2UobW0sIHA0ZCwg
YWRkciwgbmV4dCwgZm4sIGRhdGEpOw0KKwkJaWYgKCFjbG9zdXJlLT5hbGxvYyAmJiBwNGRfbm9u
ZV9vcl9jbGVhcl9iYWQocDRkKSkNCisJCQljb250aW51ZTsNCisJCWVyciA9IGFwcGx5X3RvX3B1
ZF9yYW5nZShjbG9zdXJlLCBwNGQsIGFkZHIsIG5leHQpOw0KIAkJaWYgKGVycikNCiAJCQlicmVh
azsNCiAJfSB3aGlsZSAocDRkKyssIGFkZHIgPSBuZXh0LCBhZGRyICE9IGVuZCk7DQogCXJldHVy
biBlcnI7DQogfQ0KIA0KLS8qDQotICogU2NhbiBhIHJlZ2lvbiBvZiB2aXJ0dWFsIG1lbW9yeSwg
ZmlsbGluZyBpbiBwYWdlIHRhYmxlcyBhcyBuZWNlc3NhcnkNCi0gKiBhbmQgY2FsbGluZyBhIHBy
b3ZpZGVkIGZ1bmN0aW9uIG9uIGVhY2ggbGVhZiBwYWdlIHRhYmxlLg0KKy8qKg0KKyAqIGFwcGx5
X3RvX3Bmbl9yYW5nZSAtIFNjYW4gYSByZWdpb24gb2YgdmlydHVhbCBtZW1vcnksIGNhbGxpbmcg
YSBwcm92aWRlZA0KKyAqIGZ1bmN0aW9uIG9uIGVhY2ggbGVhZiBwYWdlIHRhYmxlIGVudHJ5DQor
ICogQGNsb3N1cmU6IERldGFpbHMgYWJvdXQgaG93IHRvIHNjYW4gYW5kIHdoYXQgZnVuY3Rpb24g
dG8gYXBwbHkNCisgKiBAYWRkcjogU3RhcnQgdmlydHVhbCBhZGRyZXNzDQorICogQHNpemU6IFNp
emUgb2YgdGhlIHJlZ2lvbg0KKyAqDQorICogSWYgQGNsb3N1cmUtPmFsbG9jIGlzIHNldCB0byAx
LCB0aGUgZnVuY3Rpb24gd2lsbCBmaWxsIGluIHRoZSBwYWdlIHRhYmxlDQorICogYXMgbmVjZXNz
YXJ5LiBPdGhlcndpc2UgaXQgd2lsbCBza2lwIG5vbi1wcmVzZW50IHBhcnRzLg0KKyAqDQorICog
UmV0dXJuczogWmVybyBvbiBzdWNjZXNzLiBJZiB0aGUgcHJvdmlkZWQgZnVuY3Rpb24gcmV0dXJu
cyBhIG5vbi16ZXJvIHN0YXR1cywNCisgKiB0aGUgcGFnZSB0YWJsZSB3YWxrIHdpbGwgdGVybWlu
YXRlIGFuZCB0aGF0IHN0YXR1cyB3aWxsIGJlIHJldHVybmVkLg0KKyAqIElmIEBjbG9zdXJlLT5h
bGxvYyBpcyBzZXQgdG8gMSwgdGhlbiB0aGlzIGZ1bmN0aW9uIG1heSBhbHNvIHJldHVybiBtZW1v
cnkNCisgKiBhbGxvY2F0aW9uIGVycm9ycyBhcmlzaW5nIGZyb20gYWxsb2NhdGluZyBwYWdlIHRh
YmxlIG1lbW9yeS4NCiAgKi8NCi1pbnQgYXBwbHlfdG9fcGFnZV9yYW5nZShzdHJ1Y3QgbW1fc3Ry
dWN0ICptbSwgdW5zaWduZWQgbG9uZyBhZGRyLA0KLQkJCXVuc2lnbmVkIGxvbmcgc2l6ZSwgcHRl
X2ZuX3QgZm4sIHZvaWQgKmRhdGEpDQoraW50IGFwcGx5X3RvX3Bmbl9yYW5nZShzdHJ1Y3QgcGZu
X3JhbmdlX2FwcGx5ICpjbG9zdXJlLA0KKwkJICAgICAgIHVuc2lnbmVkIGxvbmcgYWRkciwgdW5z
aWduZWQgbG9uZyBzaXplKQ0KIHsNCiAJcGdkX3QgKnBnZDsNCiAJdW5zaWduZWQgbG9uZyBuZXh0
Ow0KQEAgLTIwNDksMTYgKzIwNjUsNTcgQEAgaW50IGFwcGx5X3RvX3BhZ2VfcmFuZ2Uoc3RydWN0
IG1tX3N0cnVjdCAqbW0sIHVuc2lnbmVkIGxvbmcgYWRkciwNCiAJaWYgKFdBUk5fT04oYWRkciA+
PSBlbmQpKQ0KIAkJcmV0dXJuIC1FSU5WQUw7DQogDQotCXBnZCA9IHBnZF9vZmZzZXQobW0sIGFk
ZHIpOw0KKwlwZ2QgPSBwZ2Rfb2Zmc2V0KGNsb3N1cmUtPm1tLCBhZGRyKTsNCiAJZG8gew0KIAkJ
bmV4dCA9IHBnZF9hZGRyX2VuZChhZGRyLCBlbmQpOw0KLQkJZXJyID0gYXBwbHlfdG9fcDRkX3Jh
bmdlKG1tLCBwZ2QsIGFkZHIsIG5leHQsIGZuLCBkYXRhKTsNCisJCWlmICghY2xvc3VyZS0+YWxs
b2MgJiYgcGdkX25vbmVfb3JfY2xlYXJfYmFkKHBnZCkpDQorCQkJY29udGludWU7DQorCQllcnIg
PSBhcHBseV90b19wNGRfcmFuZ2UoY2xvc3VyZSwgcGdkLCBhZGRyLCBuZXh0KTsNCiAJCWlmIChl
cnIpDQogCQkJYnJlYWs7DQogCX0gd2hpbGUgKHBnZCsrLCBhZGRyID0gbmV4dCwgYWRkciAhPSBl
bmQpOw0KIA0KIAlyZXR1cm4gZXJyOw0KIH0NCitFWFBPUlRfU1lNQk9MX0dQTChhcHBseV90b19w
Zm5fcmFuZ2UpOw0KKw0KK3N0cnVjdCBwYWdlX3JhbmdlX2FwcGx5IHsNCisJc3RydWN0IHBmbl9y
YW5nZV9hcHBseSBwdGVyOw0KKwlwdGVfZm5fdCBmbjsNCisJdm9pZCAqZGF0YTsNCit9Ow0KKw0K
Ky8qDQorICogQ2FsbGJhY2sgd3JhcHBlciB0byBlbmFibGUgdXNlIG9mIGFwcGx5X3RvX3Bmbl9y
YW5nZSBmb3INCisgKiB0aGUgYXBwbHlfdG9fcGFnZV9yYW5nZSBpbnRlcmZhY2UNCisgKi8NCitz
dGF0aWMgaW50IGFwcGx5X3RvX3BhZ2VfcmFuZ2Vfd3JhcHBlcihwdGVfdCAqcHRlLCBwZ3RhYmxl
X3QgdG9rZW4sDQorCQkJCSAgICAgICB1bnNpZ25lZCBsb25nIGFkZHIsDQorCQkJCSAgICAgICBz
dHJ1Y3QgcGZuX3JhbmdlX2FwcGx5ICpwdGVyKQ0KK3sNCisJc3RydWN0IHBhZ2VfcmFuZ2VfYXBw
bHkgKnByYSA9DQorCQljb250YWluZXJfb2YocHRlciwgdHlwZW9mKCpwcmEpLCBwdGVyKTsNCisN
CisJcmV0dXJuIHByYS0+Zm4ocHRlLCB0b2tlbiwgYWRkciwgcHJhLT5kYXRhKTsNCit9DQorDQor
LyoNCisgKiBTY2FuIGEgcmVnaW9uIG9mIHZpcnR1YWwgbWVtb3J5LCBmaWxsaW5nIGluIHBhZ2Ug
dGFibGVzIGFzIG5lY2Vzc2FyeQ0KKyAqIGFuZCBjYWxsaW5nIGEgcHJvdmlkZWQgZnVuY3Rpb24g
b24gZWFjaCBsZWFmIHBhZ2UgdGFibGUuDQorICovDQoraW50IGFwcGx5X3RvX3BhZ2VfcmFuZ2Uo
c3RydWN0IG1tX3N0cnVjdCAqbW0sIHVuc2lnbmVkIGxvbmcgYWRkciwNCisJCQl1bnNpZ25lZCBs
b25nIHNpemUsIHB0ZV9mbl90IGZuLCB2b2lkICpkYXRhKQ0KK3sNCisJc3RydWN0IHBhZ2VfcmFu
Z2VfYXBwbHkgcHJhID0gew0KKwkJLnB0ZXIgPSB7Lm1tID0gbW0sDQorCQkJIC5hbGxvYyA9IDEs
DQorCQkJIC5wdGVmbiA9IGFwcGx5X3RvX3BhZ2VfcmFuZ2Vfd3JhcHBlciB9LA0KKwkJLmZuID0g
Zm4sDQorCQkuZGF0YSA9IGRhdGENCisJfTsNCisNCisJcmV0dXJuIGFwcGx5X3RvX3Bmbl9yYW5n
ZSgmcHJhLnB0ZXIsIGFkZHIsIHNpemUpOw0KK30NCiBFWFBPUlRfU1lNQk9MX0dQTChhcHBseV90
b19wYWdlX3JhbmdlKTsNCiANCiAvKg0KLS0gDQoyLjE5LjAucmMxDQoNCg==

