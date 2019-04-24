Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63171C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 12:00:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06F99218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 12:00:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="NcpECmww"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06F99218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15C346B0006; Wed, 24 Apr 2019 08:00:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 106336B0008; Wed, 24 Apr 2019 08:00:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4B9E6B000A; Wed, 24 Apr 2019 08:00:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id BBDC16B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 08:00:31 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id q23so10663165otk.10
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 05:00:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=SoHkp5gsl9DN4Hd13XTXMAdh4moT6hIRFvzZcADO0t8=;
        b=Y6kWSETcw7DUgqCdDEtBg+AG1JjDH9EJwswsJjrUGlBNij/XlD8XAgUE2MUqgVroSb
         /65xZWvkrEJIyRwKq3FKOZuu3iUlpUj4aqjgU+nOj1sOoc0vLDCKNMAcuqu25k4/Zmxu
         6pjOxzLHmpUta1+CPsjw6XS4FOuNid6mBxSNeCRAzvcKUK2AHBDeClXMMQr//oT/DU7E
         0GkWKp0EUoRY9sGQ042wpEgN76AwPYiRwxRPdCPZWom7OfM09i1/Lg3iC2CR3poi3Kfr
         BOuuwK2Zaa4nWnzJDDu9ZaCSNGjgtulhLPeoT/mJvrkOcwtGdn903OjRslp4njDcweWg
         /FwA==
X-Gm-Message-State: APjAAAU1fhyhzMJqERtpt6vGF0BFDVLG0WlfVrFyUK1iNuRVVIV5/6IO
	i2E/NA6dStfvrevO1sIKUx7V+sbTJbx+HNOoQ88yKUznhhNUtqbdChdcwKEuoRYnNGioRiz76Px
	7Tv5FFLaJ2c3Y8KcRdfc0vbeTHgz29JJ8dLBZST84wmo8SWlJSk+ee9tIo7SHjXOjiA==
X-Received: by 2002:aca:da43:: with SMTP id r64mr5135481oig.11.1556107231198;
        Wed, 24 Apr 2019 05:00:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFLP5qbHp6YBHdVhPf/R7ozSceg+oiwPNfQcXYI0m4h+Yj/YZ4rhJQ/TSZT4DkMHF252sY
X-Received: by 2002:aca:da43:: with SMTP id r64mr5135428oig.11.1556107230259;
        Wed, 24 Apr 2019 05:00:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556107230; cv=none;
        d=google.com; s=arc-20160816;
        b=g8ZoCkPRHubVKD3QVITqMr3qgT7kFHytyhL+aBlngDnkloSQkJ6nSCI+3jO3G5Fpkq
         s6MEBlnM6zswmd7NmJXv9A87o5aVEcvxJPOb8FTKxXbFNwyWF2PyN51WuoB7zumDnnck
         QpvOaesLMHv47leo2SmsP62MTwyWhwwwbj4qHb2XRDaS7CwLwZ0A52mYhvciAVIzaEyg
         KpXQninaCwfTeWDtDnf6zjzEwELESOeT30ZOq8a7VktsZPdewjBTpJ1wX1QP2c0Qo676
         hOEk2xdColSBnT9ARNUyULETT4jeR1jQKr+zcLw0TMAueze8ZJA0bPLONOE4RQQkmHMC
         1grA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=SoHkp5gsl9DN4Hd13XTXMAdh4moT6hIRFvzZcADO0t8=;
        b=NPKLdyuFAYE4ESkZk8TYtSK0RWuTxQ6DTzU8oKiDbKPB33G8IXlFjt5jF2CzaHMwjK
         MwURKoHhfLd6v4624MOJq2hGeWVagNWNVKlB5rhDzPZyeDlrpV7F8A69pZRANSZGC/xJ
         Mq0D52jHCB5AKeZQllq5xv/tD1wDlmxBAYBCLpMYNlLtfJmJaxLFINvlIwL3/+O1pPKJ
         VKJ4WPZz/Ip+Rxj80GTi05c6JLn7WqzHTkuVaEVgu9qnDO8ROn2ABHS1+fmXyH9a3bzK
         VtVgUjF3k0kBzKGiW+pToIIKzFBoKoUtrcK6gGPpGknphsHqSc+ZtC0hJVs9zmkTBsdn
         tJ3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=NcpECmww;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.81.48 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-eopbgr810048.outbound.protection.outlook.com. [40.107.81.48])
        by mx.google.com with ESMTPS id k204si416748oib.181.2019.04.24.05.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Apr 2019 05:00:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 40.107.81.48 as permitted sender) client-ip=40.107.81.48;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=NcpECmww;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.81.48 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=SoHkp5gsl9DN4Hd13XTXMAdh4moT6hIRFvzZcADO0t8=;
 b=NcpECmwwletj95HiTJ9bpikBF3RMuaK9UNscgw/COHFUzfO92YZzZon+MKrJs4QekJQIkagEHzjiskH4GZPBH5BK+UUkAYuV+91/dceaHIUkG36dd/R2YdVNS+TvMbbTyXhbiQzOP5qQqf9xuW/zmJnPTifmdtIrRSw7DGB+CXI=
Received: from MN2PR05MB6141.namprd05.prod.outlook.com (20.178.241.217) by
 MN2PR05MB6272.namprd05.prod.outlook.com (20.178.240.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1835.6; Wed, 24 Apr 2019 12:00:12 +0000
Received: from MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::441b:ef64:e316:b294]) by MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::441b:ef64:e316:b294%5]) with mapi id 15.20.1835.010; Wed, 24 Apr 2019
 12:00:12 +0000
From: Thomas Hellstrom <thellstrom@vmware.com>
To: Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>
CC: Pv-drivers <Pv-drivers@vmware.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox
	<willy@infradead.org>, Will Deacon <will.deacon@arm.com>, Peter Zijlstra
	<peterz@infradead.org>, Rik van Riel <riel@surriel.com>, Minchan Kim
	<minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Huang Ying
	<ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 1/9] mm: Allow the [page|pfn]_mkwrite callbacks to drop the
 mmap_sem v2
Thread-Topic: [PATCH 1/9] mm: Allow the [page|pfn]_mkwrite callbacks to drop
 the mmap_sem v2
Thread-Index: AQHU+pVFpIoNyabDrUq+mablu5W5Jw==
Date: Wed, 24 Apr 2019 12:00:12 +0000
Message-ID: <20190424115918.3380-2-thellstrom@vmware.com>
References: <20190424115918.3380-1-thellstrom@vmware.com>
In-Reply-To: <20190424115918.3380-1-thellstrom@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: VI1PR07CA0208.eurprd07.prod.outlook.com
 (2603:10a6:802:3f::32) To MN2PR05MB6141.namprd05.prod.outlook.com
 (2603:10b6:208:c7::25)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=thellstrom@vmware.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.20.1
x-originating-ip: [155.4.205.35]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3e7e466c-4a1d-4825-7ce5-08d6c8ac67b4
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:MN2PR05MB6272;
x-ms-traffictypediagnostic: MN2PR05MB6272:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB62729F513332F3557236F8ECA13C0@MN2PR05MB6272.namprd05.prod.outlook.com>
x-forefront-prvs: 00179089FD
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(376002)(136003)(396003)(366004)(39860400002)(199004)(189003)(64756008)(66476007)(71200400001)(66446008)(86362001)(66556008)(305945005)(7416002)(14444005)(50226002)(478600001)(256004)(8936002)(81156014)(7736002)(81166006)(2906002)(66066001)(66946007)(71190400001)(8676002)(4326008)(25786009)(1076003)(66574012)(73956011)(186003)(26005)(6116002)(6512007)(486006)(6486002)(53936002)(110136005)(102836004)(6506007)(386003)(316002)(99286004)(54906003)(5660300002)(11346002)(2616005)(68736007)(14454004)(36756003)(6436002)(446003)(476003)(76176011)(3846002)(52116002)(97736004)(2501003);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6272;H:MN2PR05MB6141.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 P55ZQkkMq+fvDR7dqCGUOJwKa5c9q48YjNeF4zlf41jt3c1ucZgc0uSnPKCnyioyaRLhKeOVoHNuQzqdxubXDb+9LMWDV3NZEw2fKIrd6Bg6uqxRTMIi/wLVhZ/S6STpBl716Qu9K0Vx47WB8on/UZewJUvOWPP0m+38Ua/sDzEsl3GKl478kd56gJwS5r0KAoluiFQ2fKeXsNBmw3QzSuMgjowzoZCuqyn747saO8jgLHBNo7uvWWpYKPJRkYZGUo3CpkMJe3t/MuRFf2t9W/OXlrhIzMBCVNrpcocUyK3zvPfiXCpnpziwt300Q8PgOQrRG7ZJWvXbrC0Bk8J7nsSHMBniIYi7SM2ToDwMlFTr1Q05FGQaBDlaM2zmkH6DDS8ADkpcbtYTQlLXHVL6mJ6kNf91dpuj1LpePYie2Jc=
Content-Type: text/plain; charset="utf-8"
Content-ID: <85C7C1DA7782054E8800582057FBFE3C@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3e7e466c-4a1d-4825-7ce5-08d6c8ac67b4
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Apr 2019 12:00:12.7251
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6272
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

RHJpdmVyIGZhdWx0IGNhbGxiYWNrcyBhcmUgYWxsb3dlZCB0byBkcm9wIHRoZSBtbWFwX3NlbSB3
aGVuIGV4cGVjdGluZw0KbG9uZyBoYXJkd2FyZSB3YWl0cyB0byBhdm9pZCBibG9ja2luZyBvdGhl
ciBtbSB1c2Vycy4gQWxsb3cgdGhlIG1rd3JpdGUNCmNhbGxiYWNrcyB0byBkbyB0aGUgc2FtZSBi
eSByZXR1cm5pbmcgZWFybHkgb24gVk1fRkFVTFRfUkVUUlkuDQoNCkluIHBhcnRpY3VsYXIgd2Ug
d2FudCB0byBiZSBhYmxlIHRvIGRyb3AgdGhlIG1tYXBfc2VtIHdoZW4gd2FpdGluZyBmb3INCmEg
cmVzZXJ2YXRpb24gb2JqZWN0IGxvY2sgb24gYSBHUFUgYnVmZmVyIG9iamVjdC4gVGhlc2UgbG9j
a3MgbWF5IGJlDQpoZWxkIHdoaWxlIHdhaXRpbmcgZm9yIHRoZSBHUFUuDQoNCkNjOiBBbmRyZXcg
TW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPg0KQ2M6IE1hdHRoZXcgV2lsY294IDx3
aWxseUBpbmZyYWRlYWQub3JnPg0KQ2M6IFdpbGwgRGVhY29uIDx3aWxsLmRlYWNvbkBhcm0uY29t
Pg0KQ2M6IFBldGVyIFppamxzdHJhIDxwZXRlcnpAaW5mcmFkZWFkLm9yZz4NCkNjOiBSaWsgdmFu
IFJpZWwgPHJpZWxAc3VycmllbC5jb20+DQpDYzogTWluY2hhbiBLaW0gPG1pbmNoYW5Aa2VybmVs
Lm9yZz4NCkNjOiBNaWNoYWwgSG9ja28gPG1ob2Nrb0BzdXNlLmNvbT4NCkNjOiBIdWFuZyBZaW5n
IDx5aW5nLmh1YW5nQGludGVsLmNvbT4NCkNjOiBTb3VwdGljayBKb2FyZGVyIDxqcmRyLmxpbnV4
QGdtYWlsLmNvbT4NCkNjOiAiSsOpcsO0bWUgR2xpc3NlIiA8amdsaXNzZUByZWRoYXQuY29tPg0K
Q2M6IGxpbnV4LW1tQGt2YWNrLm9yZw0KQ2M6IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcN
Cg0KU2lnbmVkLW9mZi1ieTogVGhvbWFzIEhlbGxzdHJvbSA8dGhlbGxzdHJvbUB2bXdhcmUuY29t
Pg0KUmV2aWV3ZWQtYnk6IFJhbHBoIENhbXBiZWxsIDxyY2FtcGJlbGxAbnZpZGlhLmNvbT4NCi0t
LQ0KdjI6IE1ha2UgdGhlIG9yZGVyIGVycm9yIGNvZGVzIHdlIGNoZWNrIGZvciBjb25zaXN0ZW50
IHdpdGgNCiAgICB0aGUgb3JkZXIgdXNlZCBpbiB0aGUgcmVzdCBvZiB0aGUgZmlsZS4NCi0tLQ0K
IG1tL21lbW9yeS5jIHwgMTAgKysrKysrLS0tLQ0KIDEgZmlsZSBjaGFuZ2VkLCA2IGluc2VydGlv
bnMoKyksIDQgZGVsZXRpb25zKC0pDQoNCmRpZmYgLS1naXQgYS9tbS9tZW1vcnkuYyBiL21tL21l
bW9yeS5jDQppbmRleCBlMTFjYTlkZDgyM2YuLjk1ODBkODk0Zjk2MyAxMDA2NDQNCi0tLSBhL21t
L21lbW9yeS5jDQorKysgYi9tbS9tZW1vcnkuYw0KQEAgLTIxNDQsNyArMjE0NCw3IEBAIHN0YXRp
YyB2bV9mYXVsdF90IGRvX3BhZ2VfbWt3cml0ZShzdHJ1Y3Qgdm1fZmF1bHQgKnZtZikNCiAJcmV0
ID0gdm1mLT52bWEtPnZtX29wcy0+cGFnZV9ta3dyaXRlKHZtZik7DQogCS8qIFJlc3RvcmUgb3Jp
Z2luYWwgZmxhZ3Mgc28gdGhhdCBjYWxsZXIgaXMgbm90IHN1cnByaXNlZCAqLw0KIAl2bWYtPmZs
YWdzID0gb2xkX2ZsYWdzOw0KLQlpZiAodW5saWtlbHkocmV0ICYgKFZNX0ZBVUxUX0VSUk9SIHwg
Vk1fRkFVTFRfTk9QQUdFKSkpDQorCWlmICh1bmxpa2VseShyZXQgJiAoVk1fRkFVTFRfRVJST1Ig
fCBWTV9GQVVMVF9OT1BBR0UgfCBWTV9GQVVMVF9SRVRSWSkpKQ0KIAkJcmV0dXJuIHJldDsNCiAJ
aWYgKHVubGlrZWx5KCEocmV0ICYgVk1fRkFVTFRfTE9DS0VEKSkpIHsNCiAJCWxvY2tfcGFnZShw
YWdlKTsNCkBAIC0yNDE5LDcgKzI0MTksNyBAQCBzdGF0aWMgdm1fZmF1bHRfdCB3cF9wZm5fc2hh
cmVkKHN0cnVjdCB2bV9mYXVsdCAqdm1mKQ0KIAkJcHRlX3VubWFwX3VubG9jayh2bWYtPnB0ZSwg
dm1mLT5wdGwpOw0KIAkJdm1mLT5mbGFncyB8PSBGQVVMVF9GTEFHX01LV1JJVEU7DQogCQlyZXQg
PSB2bWEtPnZtX29wcy0+cGZuX21rd3JpdGUodm1mKTsNCi0JCWlmIChyZXQgJiAoVk1fRkFVTFRf
RVJST1IgfCBWTV9GQVVMVF9OT1BBR0UpKQ0KKwkJaWYgKHJldCAmIChWTV9GQVVMVF9FUlJPUiB8
IFZNX0ZBVUxUX05PUEFHRSB8IFZNX0ZBVUxUX1JFVFJZKSkNCiAJCQlyZXR1cm4gcmV0Ow0KIAkJ
cmV0dXJuIGZpbmlzaF9ta3dyaXRlX2ZhdWx0KHZtZik7DQogCX0NCkBAIC0yNDQwLDcgKzI0NDAs
OCBAQCBzdGF0aWMgdm1fZmF1bHRfdCB3cF9wYWdlX3NoYXJlZChzdHJ1Y3Qgdm1fZmF1bHQgKnZt
ZikNCiAJCXB0ZV91bm1hcF91bmxvY2sodm1mLT5wdGUsIHZtZi0+cHRsKTsNCiAJCXRtcCA9IGRv
X3BhZ2VfbWt3cml0ZSh2bWYpOw0KIAkJaWYgKHVubGlrZWx5KCF0bXAgfHwgKHRtcCAmDQotCQkJ
CSAgICAgIChWTV9GQVVMVF9FUlJPUiB8IFZNX0ZBVUxUX05PUEFHRSkpKSkgew0KKwkJCQkgICAg
ICAoVk1fRkFVTFRfRVJST1IgfCBWTV9GQVVMVF9OT1BBR0UgfA0KKwkJCQkgICAgICAgVk1fRkFV
TFRfUkVUUlkpKSkpIHsNCiAJCQlwdXRfcGFnZSh2bWYtPnBhZ2UpOw0KIAkJCXJldHVybiB0bXA7
DQogCQl9DQpAQCAtMzQ5NCw3ICszNDk1LDggQEAgc3RhdGljIHZtX2ZhdWx0X3QgZG9fc2hhcmVk
X2ZhdWx0KHN0cnVjdCB2bV9mYXVsdCAqdm1mKQ0KIAkJdW5sb2NrX3BhZ2Uodm1mLT5wYWdlKTsN
CiAJCXRtcCA9IGRvX3BhZ2VfbWt3cml0ZSh2bWYpOw0KIAkJaWYgKHVubGlrZWx5KCF0bXAgfHwN
Ci0JCQkJKHRtcCAmIChWTV9GQVVMVF9FUlJPUiB8IFZNX0ZBVUxUX05PUEFHRSkpKSkgew0KKwkJ
CQkodG1wICYgKFZNX0ZBVUxUX0VSUk9SIHwgVk1fRkFVTFRfTk9QQUdFIHwNCisJCQkJCVZNX0ZB
VUxUX1JFVFJZKSkpKSB7DQogCQkJcHV0X3BhZ2Uodm1mLT5wYWdlKTsNCiAJCQlyZXR1cm4gdG1w
Ow0KIAkJfQ0KLS0gDQoyLjIwLjENCg0K

