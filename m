Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61BBCC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 06:10:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E92D220652
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 06:10:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="tfBA3FWo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E92D220652
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 896596B0003; Tue, 25 Jun 2019 02:10:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86C748E0003; Tue, 25 Jun 2019 02:10:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70CC08E0002; Tue, 25 Jun 2019 02:10:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB356B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 02:10:44 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id k31so19723160qte.13
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 23:10:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=lo2788zc3ba6AQPBvrY7/wbULJd9YzLO/MZXNIg1XA0=;
        b=GK3kY0aVWtx7LU44/AqRvBPHsXikXT6nUqauonMh4ncXjncQj8CphtfzQXU7iQOH6d
         +BBt4r865vOkFlpd4OPt/IBSisyeX3EE9eIXgMIuRj872/uDxZP+qTJoLZv5d6jXE114
         oSTmTBoRL+Jn6QSSb9JTA3Im1jiCGkMRIzEZbY2G/xmSrhLLNOCIunrYxXp0M/9pkicZ
         wCCwOoqFMZb625YGwjkWq37PFN/867YF55qMK8qBc8oxzkZoxeBf8zw9FeXb1EFy3M0a
         L/L4oWhzXmhgWGjlHGsSgqgrZPc72HuJdBsvlUrg5rveyHMXOGSX0M7PRj9xvsF3KXFL
         vhJA==
X-Gm-Message-State: APjAAAVZx44m86FZ5ZIrc20J6BnUbdZAgvf9EO25qI82Ev61btLBx802
	N3cfN4h2wDs+YTE6Yy+ch9GHm+dkwF5PvL9jAhH9NPaph1i83HNKpjgXHK1vf674pxPaZbcw1Ku
	VsDK+iBWcYA1BOq8UTYweRMeHUDHnPMHzSe5WDVXsdU5Sf+3KyY9TB4pztYwwV4gzUQ==
X-Received: by 2002:a37:a6d3:: with SMTP id p202mr20677354qke.440.1561443043966;
        Mon, 24 Jun 2019 23:10:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUYbGJ1OHL4ONfbIpHso5iDcNtbWTiUMsOLSJngDny+qthD6IiH1Br0IGcBSbZxaoXxy2s
X-Received: by 2002:a37:a6d3:: with SMTP id p202mr20677328qke.440.1561443043340;
        Mon, 24 Jun 2019 23:10:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561443043; cv=none;
        d=google.com; s=arc-20160816;
        b=xP5kwjqQJvwFkfXo3JzvgpWSmG29HIx20sGV4l4rkz3gpo73bThzeBfWWa3YlOArWp
         Op3SNgYnsYHxj7FzhHoqM7mV+EeGAhI2YRJFcOAqIBsh2sWpESZB4ZoC5IpIZA8YK8Fn
         3wrIW65hCHLFjt/Zl/LftHbs8M9qD/FoPpk73Jd/wS5oMpyXGskI3XX1EV8fM3fpaEaK
         D0Gbu+RhXi447P3Mqt0AJ+a+wu/puKlDSDePxVZW/rjkGOLVZhTvRidbMo8jDu5Fs6tX
         yNS8phtk1Wt9zX/7lOT6WmpjAKsgcZcG+RY8PEN914yZtZQAVRoWb67oxML/5PoOrgkX
         a/lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=lo2788zc3ba6AQPBvrY7/wbULJd9YzLO/MZXNIg1XA0=;
        b=dHI+bMI4DFz63sGKqyEGCSRKn09EjfhOlMnKiAlvI3PkHAckMe4gdvqusW4E+m6vHm
         iyAZahNMiXDyf0Yln/lcYBhiJ7TJVgRh7wx0Vzs09quIZsih2zmdYCbVnYaivtWxqrFD
         ia/BN0Jr7zs4wxqX46nxsZovgJmQvBEX1fAFNSKYuGhVabRBkeBzNusSelmwERkMMVky
         T7ccPigVvloK4iNxvKi81eLtwWcF1moXNoGsmeksParMyiQuIUQkuT0Dl1pHv0HLgqLv
         V9uIRR09hTSM+liN6f4LVK5Fi1hPmdGzGMvps6SGuqDRt087VDK0iVoUyELxnSo8rkK2
         EvVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=tfBA3FWo;
       spf=pass (google.com: domain of akaher@vmware.com designates 40.107.71.55 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710055.outbound.protection.outlook.com. [40.107.71.55])
        by mx.google.com with ESMTPS id y18si7885134qtn.379.2019.06.24.23.10.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Jun 2019 23:10:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 40.107.71.55 as permitted sender) client-ip=40.107.71.55;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=tfBA3FWo;
       spf=pass (google.com: domain of akaher@vmware.com designates 40.107.71.55 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lo2788zc3ba6AQPBvrY7/wbULJd9YzLO/MZXNIg1XA0=;
 b=tfBA3FWovYHivYtV4EX+AXUXUnM4v76HXCZ6eQxjvsbsRO62V5Rb+B82TScsuAkje+AoR7ba6ufdCPfmUBSffhtPczF8CBp2XodhrCpLG0fsYB7H6DqGp4AU/4eYpr562Ld3OCw5tM+7GTaCMPRI5nBRiwjBb5bqu71Q9VvR3xo=
Received: from MN2PR05MB6208.namprd05.prod.outlook.com (20.178.241.91) by
 MN2PR05MB6432.namprd05.prod.outlook.com (20.178.249.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.12; Tue, 25 Jun 2019 06:10:40 +0000
Received: from MN2PR05MB6208.namprd05.prod.outlook.com
 ([fe80::f4b2:4f83:7076:ffbf]) by MN2PR05MB6208.namprd05.prod.outlook.com
 ([fe80::f4b2:4f83:7076:ffbf%6]) with mapi id 15.20.2008.007; Tue, 25 Jun 2019
 06:10:40 +0000
From: Ajay Kaher <akaher@vmware.com>
To: Sasha Levin <sashal@kernel.org>
CC: "aarcange@redhat.com" <aarcange@redhat.com>, "jannh@google.com"
	<jannh@google.com>, "oleg@redhat.com" <oleg@redhat.com>, "peterx@redhat.com"
	<peterx@redhat.com>, "rppt@linux.ibm.com" <rppt@linux.ibm.com>,
	"jgg@mellanox.com" <jgg@mellanox.com>, "mhocko@suse.com" <mhocko@suse.com>,
	"jglisse@redhat.com" <jglisse@redhat.com>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "mike.kravetz@oracle.com"
	<mike.kravetz@oracle.com>, "viro@zeniv.linux.org.uk"
	<viro@zeniv.linux.org.uk>, "riandrews@android.com" <riandrews@android.com>,
	"arve@android.com" <arve@android.com>, "yishaih@mellanox.com"
	<yishaih@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>,
	"sean.hefty@intel.com" <sean.hefty@intel.com>, "hal.rosenstock@gmail.com"
	<hal.rosenstock@gmail.com>, "matanb@mellanox.com" <matanb@mellanox.com>,
	"leonro@mellanox.com" <leonro@mellanox.com>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, Srivatsa Bhat
	<srivatsab@vmware.com>, Alexey Makhalov <amakhalov@vmware.com>,
	"srivatsa@csail.mit.edu" <srivatsa@csail.mit.edu>
Subject: Re: [PATCH v4 0/3] [v4.9.y] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Thread-Topic: [PATCH v4 0/3] [v4.9.y] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Thread-Index: AQHVKo1iIUbk16XbJ0SDrOziR/ss8aarP80AgAEAroA=
Date: Tue, 25 Jun 2019 06:10:40 +0000
Message-ID: <0EA7BFD6-ABA6-4008-B30F-20653114F34F@vmware.com>
References: <1561410186-3919-1-git-send-email-akaher@vmware.com>
 <1561410186-3919-4-git-send-email-akaher@vmware.com>
 <20190624202150.GC3881@sasha-vm>
In-Reply-To: <20190624202150.GC3881@sasha-vm>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=akaher@vmware.com; 
x-originating-ip: [103.19.212.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 36e99abf-899a-4967-2e08-08d6f933d93c
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MN2PR05MB6432;
x-ms-traffictypediagnostic: MN2PR05MB6432:
x-ms-exchange-purlcount: 1
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB643293A8AB84F8A7C3859EB4BBE30@MN2PR05MB6432.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0079056367
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(366004)(136003)(39860400002)(346002)(376002)(51344004)(199004)(189003)(66476007)(5660300002)(76116006)(6916009)(91956017)(966005)(73956011)(33656002)(66946007)(14454004)(66446008)(66556008)(36756003)(64756008)(7416002)(76176011)(256004)(99286004)(26005)(102836004)(6506007)(486006)(11346002)(478600001)(2616005)(476003)(446003)(6436002)(6116002)(3846002)(86362001)(8936002)(8676002)(229853002)(81166006)(81156014)(6486002)(186003)(66066001)(71200400001)(2906002)(4326008)(316002)(25786009)(6246003)(53936002)(305945005)(6306002)(7736002)(71190400001)(68736007)(54906003)(6512007);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6432;H:MN2PR05MB6208.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 7C0X+nm7Rleca1jNZbcgVC5+kiFYKWHjJvaBFQWOTfBE8Uh5S2deK1ou1WjOhFcfLGxXDknePIo1gqzhNlqGhOtgbOaZI+jgRm/6xURpCTa+ONdh4xV91+svDCPtqnI1BQRDAn1QgV5kPvFVe0vs5ZkcddEBNt6hnWF3xM7u2G9INuoOdpL7hbS/qMYhMVbDvUuTPEam+gSM8X71/DevULJtTl0jikPt+MUiGh/B+DT0gB/qjmVlTbRjSPOl3IQrBh39vLZEdDh6iQP44bxM0jEm0VRuP50Vl8vns5g6XbAhl2mnxwsiWXguv7R7gWcPvq4NfCbZ170lvK+y7bgyy+OBKPWLk8cHPqyr8nvTMnQeksj8HwF3U1zEqTcdWyTcupcgwmCErTDQXWUTPkY5aj79zsgvz4JAWhwyBfzf9zM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <FAB09C25F4BC4C40B101E9C6E4EFD2C4@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 36e99abf-899a-4967-2e08-08d6f933d93c
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jun 2019 06:10:40.0723
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: akaher@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6432
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQrvu79PbiAyNS8wNi8xOSwgMTo1MSBBTSwgIlNhc2hhIExldmluIiA8c2FzaGFsQGtlcm5lbC5v
cmc+IHdyb3RlOg0KICAgIA0KPiBPbiBUdWUsIEp1biAyNSwgMjAxOSBhdCAwMjozMzowNkFNICsw
NTMwLCBBamF5IEthaGVyIHdyb3RlOg0KPiA+IGNvcmVkdW1wOiBmaXggcmFjZSBjb25kaXRpb24g
YmV0d2VlbiBtbWdldF9ub3RfemVybygpL2dldF90YXNrX21tKCkNCj4gPiBhbmQgY29yZSBkdW1w
aW5nDQo+ID4NCj4gPiBbUEFUQ0ggdjQgMS8zXToNCj4gPiBCYWNrcG9ydGluZyBvZiBjb21taXQg
MDRmNTg2NmU0MWZiNzA2OTBlMjgzOTc0ODdkOGJkOGVlYTdkNzEyYSB1cHN0cmVhbS4NCj4gPg0K
PiA+IFtQQVRDSCB2NCAyLzNdOg0KPiA+IEV4dGVuc2lvbiBvZiBjb21taXQgMDRmNTg2NmU0MWZi
IHRvIGZpeCB0aGUgcmFjZSBjb25kaXRpb24gYmV0d2Vlbg0KPiA+IGdldF90YXNrX21tKCkgYW5k
IGNvcmUgZHVtcGluZyBmb3IgSUItPm1seDQgYW5kIElCLT5tbHg1IGRyaXZlcnMuDQo+ID4NCj4g
PiBbUEFUQ0ggdjQgMy8zXQ0KPiA+IEJhY2twb3J0aW5nIG9mIGNvbW1pdCA1OWVhNmQwNmNmYTky
NDdiNTg2YTY5NWMyMWY5NGFmYTcxODNhZjc0IHVwc3RyZWFtLg0KPiA+DQo+ID4gW2RpZmYgZnJv
bSB2M106DQo+ID4gLSBhZGRlZCBbUEFUQ0ggdjQgMy8zXQ0KICAgICAgICANCj4gV2h5IGRvIGFs
bCB0aGUgcGF0Y2hlcyBoYXZlIHRoZSBzYW1lIHN1YmplY3QgbGluZT8NClRoYW5rcyBmb3IgY2F0
Y2hpbmcgdGhpcy4gSSB3aWxsIGNvcnJlY3QgaW4gbmV4dCB2ZXJzaW9uIG9mIHRoZXNlIHBhdGNo
ZXMsDQphbG9uZyB3aXRoIHJldmlldyBjb21tZW50cyBpZiBhbnkuDQogICAgDQogICAgICAgIA0K
PiBJIGd1ZXNzIGl0J3MgY29ycmVjdCBmb3IgdGhlIGZpcnN0IG9uZSwgYnV0IGNhbiB5b3UgZXhw
bGFpbiB3aGF0J3MgdXANCj4gd2l0aCAjMiBhbmQgIzM/DQo+DQo+IElmIHRoZSBzZWNvbmQgb25l
IGlzbid0IHVwc3RyZWFtLCBwbGVhc2UgZXhwbGFpbiBpbiBkZXRhaWwgd2h5IG5vdCBhbmQNCj4g
aG93IDQuOSBkaWZmZXJzIGZyb20gdXBzdHJlYW0gc28gdGhhdCBpdCByZXF1aXJlcyBhIGN1c3Rv
bSBiYWNrcG9ydC4NCg0KIzIgYXBwbGllZCB0byA0LjE0Lnk6DQpodHRwczovL2dpdC5rZXJuZWwu
b3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC9zdGFibGUvc3RhYmxlLXF1ZXVlLmdpdC90cmVl
L3F1ZXVlLTQuMTQvaW5maW5pYmFuZC1maXgtcmFjZS1jb25kaXRpb24tYmV0d2Vlbi1pbmZpbmli
YW5kLW1seDQtbWx4NS1kcml2ZXItYW5kLWNvcmUtZHVtcGluZy5wYXRjaD9pZD1lNDA0MWEzZjZi
NTY5MTQwNTQ5ZmU3YjQxZWQ1MjdjNWMxZTM4ZWM5DQoNCkFuZCB0aGVuIHRvIDQuOS55IChzb21l
IHBhcnQgYXMgcmVxdWlyZXMpLiANCjQuMTggYW5kIG9ud2FyZHMgZG9lc24ndCBoYXZlICBtbWFw
X3NlbSBsb2NraW5nIGluIG1seDQgYW5kIG1seDUsIA0Kc28gbm8gbmVlZCBvZiAjMiBpbiA0LjE4
IGFuZCBvbndhcmRzLg0KDQo+IFRoZSB0aGlyZCBvbmUganVzdCBsb29rcyBsaWtlIGEgZGlmZmVy
ZW50IHBhdGNoIGFsdG9nZXRoZXIgd2l0aCBhIHdyb25nDQo+IHN1YmplY3QgbGluZT8NCiMzIHdh
cyBpbiBkaXNjdXNzaW9uIGhlcmUgKGR1cmluZyB2MSksIHNvIGFkZGVkIGhlcmUuIA0KICANCj4g
LS0NCj4gVGhhbmtzLA0KPiBTYXNoYQ0KIA0KDQo=

