Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30010C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:47:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C43C8208C3
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 23:47:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="NtZD+Crn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C43C8208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BFDC6B0003; Tue,  6 Aug 2019 19:47:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 571B06B0006; Tue,  6 Aug 2019 19:47:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4106C6B0007; Tue,  6 Aug 2019 19:47:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4496B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 19:47:50 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 5so77476083qki.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 16:47:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=9uYXs8TLn9yp6zgpySJyd2NtzBnPT/uQMkDb83lZ4/g=;
        b=ZkIB4WYD52621NMQfAp7G7yWKC6O/AOPZqPegL/OO47R3HCrPi958CjD92I2rZCE2p
         k/9acgqGNEZ3O7I9VhLuzhrn7FJdl1h8/aWlZmYNUDeB+Kcc7aB1P9qmR6VTrSDVCCpK
         nuzRBr9kzvQzaZbCZnUYh/iZcTCePhoiOJYhywEvo47czcwHhWq6OaWI53KPXTSJlG1p
         wiAXjL5wJSEqufhRMoHtLME2uQsqZwPW9hum6aONRdqPzK+2LIFOlUEs4lyEptBzs/dT
         cU1YW8wSkMlQOoQSXp1kQCBq/jwAyuRrti5yb6vGI5lz6eBUw38VocOdD/ihRKYti1eD
         QjaA==
X-Gm-Message-State: APjAAAXHmtVShRcuWVZJZVO0xYQBu1z4+D7c7sKkemervhn6HhAdHuQY
	7oPhcgKrUXgT+rNzXJ7tqIHXgXKexgJJLm5E2k30rrPXFEngy+c2Zy63gfH15SHZtCB+q/8nqpK
	0YuyaRX4CLtgBzPH+rrB+p3Wvsc6Eu1zgIcQFaMoSzlQ1fiVepV6FdUqVdTNonss=
X-Received: by 2002:a37:dcc7:: with SMTP id v190mr5896066qki.169.1565135269859;
        Tue, 06 Aug 2019 16:47:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+8bjY1+0TYCJ8C8uSB8y4JFEO71rVfaPM5csQGtozIosvFOoBakfrX2ZY6jsn2YJcefAf
X-Received: by 2002:a37:dcc7:: with SMTP id v190mr5896023qki.169.1565135269162;
        Tue, 06 Aug 2019 16:47:49 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565135269; cv=pass;
        d=google.com; s=arc-20160816;
        b=D02fndmd24mZeCCV9jlZ8bUtMO2zbZ4KFKeGUrLGi2Ep1cCjOQkyXgbQfNlbjdQl5H
         HH0iWTHO6cBYtHedhDR5xc4Emx9QMG9cPlT7ZOk6lDBZCS5N99uNoviewgJAvW66+SSC
         g5sqH0R5VLGIjkMtdbuC8NBfiZ2eZ0DzyhAQlS3MsjoK6T38ALNX5OLUVOedIxGFzHgA
         am7IzBz368fORqeOlzaZvaoOykaZu+ZYwkx7XZoTyeElmOaWgbFt8CWgrqbLMI7w+0zF
         1UrCBQ1dw7FYQjmZ7/mLa5yk6CFYhKn1UbNlCmsPRsP6X/Z5QKiFjrYhJ5G/oQr8+lMV
         q9tA==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=9uYXs8TLn9yp6zgpySJyd2NtzBnPT/uQMkDb83lZ4/g=;
        b=PfBnhadldKmp5Q1H/gL6T5Q4doF3zu6jhto+kUpoV0weqfnfMcHlA6wl7pXLaecGOn
         UHlOGJYSdZdZDgu2WZl5J1I9OpvlfK+VLWhhijZzmSjcS4vAjQI1O8liO03MAML2HnXn
         HN1FtZCzK9cA1WLocp7avmWqFzktOn63g0zrkvma2oCtdeFGSZhyI/bW+Ib657A7CsTQ
         WrGp5bu8ZI2ExwEMVEgbPAVFSM8CWZraUsO5nWsbJK5In3EZrYeu7pawN0gn6y0ZiTxt
         0Gz8DLP2ZFS+zuQnS7o2GBFK1f5XjoL/b0xR02xV+u56Z5xWstnovRK9reBOgGU68dC2
         hfog==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=NtZD+Crn;
       arc=pass (i=1 spf=pass spfdomain=amd.com dkim=pass dkdomain=amd.com dmarc=pass fromdomain=amd.com);
       spf=neutral (google.com: 40.107.78.41 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780041.outbound.protection.outlook.com. [40.107.78.41])
        by mx.google.com with ESMTPS id g18si37709929qtb.207.2019.08.06.16.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 16:47:49 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.78.41 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.78.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=NtZD+Crn;
       arc=pass (i=1 spf=pass spfdomain=amd.com dkim=pass dkdomain=amd.com dmarc=pass fromdomain=amd.com);
       spf=neutral (google.com: 40.107.78.41 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=cCXjRe643R7Zgf1czXYGDn2TvRcGXBn4fb/QK4SO/FkB09FCCQoXVrrRKZZZXzdsqMJ32OADLIDjx8Oqj54uHf3KSIroXIJy2bVEIYFmjPbKei3VNPJvB3hulL9Fu/HNdguCyfiL3X5ott3lqC3cgienAuWPWXqI+rnV5abK27uMSBOLcfVyFeJTKeP4AUKNE96Uyz7OpxyAJfmJwzv2T85LvHADWKK6EZpSUOaXCsJ1nln00gB584UCpGd1BtHsHvWvqdfAcOFeo6Zc+GPKovE70kgSfmXdQKEIAfpCZml/qoZnMwKzCBaViVF8XmdXvoDWdrVhKulHcOfZxqRf/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9uYXs8TLn9yp6zgpySJyd2NtzBnPT/uQMkDb83lZ4/g=;
 b=ndjHN3eXVleLgSM8SfPeaWzHESwW7D6KehO0pl0kncZL0AxPkEWb295m7vzXyYObj9pC/dYMDvt1Va+MwqF91nhRaDZ95Bklh+HWp3QorLp7Ne7+QvAPaifDzfF+iF0EyDowEPlsImlQFpnVMUQ05y656pNlEZko6JG042CuVvBUWuf2utf9feUFSWae9f6nvvZRSf419ObiznzfaVMXyRwopguySyev/MLHezpzjMCbHZ7zgu2RyCEO0sfVvA2RBb2mJuY/tEsDG0wonrRv6g1oGf+JgU4ei+2pc+PodaylSpJOgbj13soOpkqcOkaUAucUGF07QDWIOywAZDxlYA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=amd.com;dmarc=pass action=none header.from=amd.com;dkim=pass
 header.d=amd.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9uYXs8TLn9yp6zgpySJyd2NtzBnPT/uQMkDb83lZ4/g=;
 b=NtZD+CrnutT7QoX/NN+5+MBdbO/1Cgvo6copl7F3OStBi5QjeCtpM5G+bzCzyBkqtI9oltan5WgCLRAoSsQxceTeNpqG3h0iFEq4LXvnYyuohSubVxdlADZezIrGu6T4ds9Qpkofd5uTrJJQOYPJAPpX1Kf4Tp9VE/RB4+K82Gk=
Received: from DM6PR12MB3947.namprd12.prod.outlook.com (10.255.174.156) by
 DM6PR12MB3034.namprd12.prod.outlook.com (20.178.30.31) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.17; Tue, 6 Aug 2019 23:47:45 +0000
Received: from DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::1c82:54e7:589b:539c]) by DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::1c82:54e7:589b:539c%5]) with mapi id 15.20.2157.011; Tue, 6 Aug 2019
 23:47:45 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Jason Gunthorpe <jgg@ziepe.ca>, "linux-mm@kvack.org" <linux-mm@kvack.org>
CC: Andrea Arcangeli <aarcange@redhat.com>, Christoph Hellwig <hch@lst.de>,
	John Hubbard <jhubbard@nvidia.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, "Deucher,
 Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian"
	<Christian.Koenig@amd.com>, "Zhou, David(ChunMing)" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "iommu@lists.linux-foundation.org"
	<iommu@lists.linux-foundation.org>, "intel-gfx@lists.freedesktop.org"
	<intel-gfx@lists.freedesktop.org>, Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>, Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v3 hmm 10/11] drm/amdkfd: use mmu_notifier_put
Thread-Topic: [PATCH v3 hmm 10/11] drm/amdkfd: use mmu_notifier_put
Thread-Index: AQHVTKz1DOmv7threke3/c3LGGrUwabuyVIA
Date: Tue, 6 Aug 2019 23:47:44 +0000
Message-ID: <d58a1a8f-f80c-edfe-4b57-6fde9c0ca180@amd.com>
References: <20190806231548.25242-1-jgg@ziepe.ca>
 <20190806231548.25242-11-jgg@ziepe.ca>
In-Reply-To: <20190806231548.25242-11-jgg@ziepe.ca>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.54.211]
user-agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
x-clientproxiedby: YTBPR01CA0034.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b01:14::47) To DM6PR12MB3947.namprd12.prod.outlook.com
 (2603:10b6:5:1cb::28)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 26db0519-254a-49cf-877c-08d71ac87a84
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DM6PR12MB3034;
x-ms-traffictypediagnostic: DM6PR12MB3034:
x-microsoft-antispam-prvs:
 <DM6PR12MB303409776EC953633553292892D50@DM6PR12MB3034.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:5516;
x-forefront-prvs: 0121F24F22
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(376002)(396003)(39860400002)(346002)(136003)(189003)(199004)(26005)(53546011)(14444005)(256004)(66946007)(66476007)(66556008)(64756008)(6506007)(386003)(102836004)(25786009)(14454004)(6246003)(54906003)(6512007)(186003)(64126003)(65826007)(65956001)(99286004)(68736007)(110136005)(6436002)(305945005)(65806001)(66066001)(66446008)(478600001)(6486002)(7736002)(5660300002)(36756003)(316002)(58126008)(7416002)(52116002)(53936002)(81166006)(3846002)(6116002)(8936002)(31686004)(31696002)(4326008)(2616005)(86362001)(71190400001)(8676002)(11346002)(229853002)(486006)(2906002)(446003)(76176011)(476003)(71200400001)(2501003)(81156014);DIR:OUT;SFP:1101;SCL:1;SRVR:DM6PR12MB3034;H:DM6PR12MB3947.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 v2blSuD7K48EtfDiHnDhA5Z7bGNZG2u+PM8wAuasCzIWgI7LUavNujnsB30Db9XpvzrCpGhubEEXaMTxMQz4ziBKpQmmyJdROx5a3Wo5hEgfVUX0znfq0UXXC8yaAB/c/WLstG+d4eB3afA21frj4dXjkKn3vTvHAEJMPfSBlourYE9Sf4w9JPcKHJgvP2bWO7HJZh77B6zbga3XrvACBWFgwWCaCUjIjM1hjUqjplVKPFau+OYz/nTDlrwYQVT4oyPm3ga75hmdMIglrCewCT5QrvI0AB61gZ6rmSWzHU23yEu9arjvez2KJTwET1elX4CkpRHlXy1ZYMRFwuOnE5AEw9R4uSVgdrdU6M1X3JphhbYWBtjg9tfumnobwWqgw/EgY+B5erxdnYyecBj9CXhnH+Ol3ZLJ9SZMYtVFJmE=
Content-Type: text/plain; charset="utf-8"
Content-ID: <08AA45544D5F4047B8BE6878E1D59AF9@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 26db0519-254a-49cf-877c-08d71ac87a84
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Aug 2019 23:47:44.9450
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: fHlZiATcYSQj0+WSGSvy8ZAicH/M7tNXVlQryTfouYsJ287scDy/Lph82E+Jx7fCO7Tic+2WuNmcLFjUTVkvvA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB3034
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAxOS0wOC0wNiAxOToxNSwgSmFzb24gR3VudGhvcnBlIHdyb3RlOg0KPiBGcm9tOiBKYXNv
biBHdW50aG9ycGUgPGpnZ0BtZWxsYW5veC5jb20+DQo+DQo+IFRoZSBzZXF1ZW5jZSBvZiBtbXVf
bm90aWZpZXJfdW5yZWdpc3Rlcl9ub19yZWxlYXNlKCksDQo+IG1tdV9ub3RpZmllcl9jYWxsX3Ny
Y3UoKSBpcyBpZGVudGljYWwgdG8gbW11X25vdGlmaWVyX3B1dCgpIHdpdGggdGhlDQo+IGZyZWVf
bm90aWZpZXIgY2FsbGJhY2suDQo+DQo+IEFzIHRoaXMgaXMgdGhlIGxhc3QgdXNlciBvZiB0aG9z
ZSBBUElzLCBjb252ZXJ0aW5nIGl0IG1lYW5zIHdlIGNhbiBkcm9wDQo+IHRoZW0uDQo+DQo+IFNp
Z25lZC1vZmYtYnk6IEphc29uIEd1bnRob3JwZSA8amdnQG1lbGxhbm94LmNvbT4NCg0KUmV2aWV3
ZWQtYnk6IEZlbGl4IEt1ZWhsaW5nIDxGZWxpeC5LdWVobGluZ0BhbWQuY29tPg0KDQo+IC0tLQ0K
PiAgIGRyaXZlcnMvZ3B1L2RybS9hbWQvYW1ka2ZkL2tmZF9wcml2LmggICAgfCAgMyAtLS0NCj4g
ICBkcml2ZXJzL2dwdS9kcm0vYW1kL2FtZGtmZC9rZmRfcHJvY2Vzcy5jIHwgMTAgKysrKy0tLS0t
LQ0KPiAgIDIgZmlsZXMgY2hhbmdlZCwgNCBpbnNlcnRpb25zKCspLCA5IGRlbGV0aW9ucygtKQ0K
Pg0KPiBJJ20gcmVhbGx5IG5vdCBzdXJlIHdoYXQgdGhpcyBpcyBkb2luZywgYnV0IGl0IGlzIHZl
cnkgc3RyYW5nZSB0byBoYXZlIGENCj4gcmVsZWFzZSB3aXRoIG5vIG90aGVyIGNhbGxiYWNrLiBJ
dCB3b3VsZCBiZSBnb29kIGlmIHRoaXMgd291bGQgY2hhbmdlIHRvIHVzZQ0KPiBnZXQgYXMgd2Vs
bC4NCktGRCB1c2VzIHRoZSBNTVUgbm90aWZpZXIgdG8gZGV0ZWN0IHByb2Nlc3MgdGVybWluYXRp
b24gYW5kIGZyZWUgYWxsIHRoZSANCnJlc291cmNlcyBhc3NvY2lhdGVkIHdpdGggdGhlIHByb2Nl
c3MuIFRoaXMgd2FzIGZpcnN0IGFkZGVkIGZvciBBUFVzIA0Kd2hlcmUgdGhlIElPTU1VdjIgaXMg
c2V0IHVwIHRvIHBlcmZvcm0gYWRkcmVzcyB0cmFuc2xhdGlvbnMgdXNpbmcgdGhlIA0KQ1BVIHBh
Z2UgdGFibGUgZm9yIGRldmljZSBtZW1vcnkgYWNjZXNzLiBUaGF0J3Mgd2hlcmUgdGhlIGFzc29j
aWF0aW9uIG9mIA0KS0ZEIHByb2Nlc3MgcmVzb3VyY2VzIHdpdGggdGhlIGxpZmV0aW1lIG9mIHRo
ZSBtbV9zdHJ1Y3QgY29tZXMgZnJvbS4NCg0KUmVnYXJkcywNCiDCoCBGZWxpeA0KDQoNCj4NCj4g
ZGlmZiAtLWdpdCBhL2RyaXZlcnMvZ3B1L2RybS9hbWQvYW1ka2ZkL2tmZF9wcml2LmggYi9kcml2
ZXJzL2dwdS9kcm0vYW1kL2FtZGtmZC9rZmRfcHJpdi5oDQo+IGluZGV4IDM5MzNmYjZhMzcxZWZi
Li45NDUwZTIwZDE3MDkzYiAxMDA2NDQNCj4gLS0tIGEvZHJpdmVycy9ncHUvZHJtL2FtZC9hbWRr
ZmQva2ZkX3ByaXYuaA0KPiArKysgYi9kcml2ZXJzL2dwdS9kcm0vYW1kL2FtZGtmZC9rZmRfcHJp
di5oDQo+IEBAIC02ODYsOSArNjg2LDYgQEAgc3RydWN0IGtmZF9wcm9jZXNzIHsNCj4gICAJLyog
V2Ugd2FudCB0byByZWNlaXZlIGEgbm90aWZpY2F0aW9uIHdoZW4gdGhlIG1tX3N0cnVjdCBpcyBk
ZXN0cm95ZWQgKi8NCj4gICAJc3RydWN0IG1tdV9ub3RpZmllciBtbXVfbm90aWZpZXI7DQo+ICAg
DQo+IC0JLyogVXNlIGZvciBkZWxheWVkIGZyZWVpbmcgb2Yga2ZkX3Byb2Nlc3Mgc3RydWN0dXJl
ICovDQo+IC0Jc3RydWN0IHJjdV9oZWFkCXJjdTsNCj4gLQ0KPiAgIAl1bnNpZ25lZCBpbnQgcGFz
aWQ7DQo+ICAgCXVuc2lnbmVkIGludCBkb29yYmVsbF9pbmRleDsNCj4gICANCj4gZGlmZiAtLWdp
dCBhL2RyaXZlcnMvZ3B1L2RybS9hbWQvYW1ka2ZkL2tmZF9wcm9jZXNzLmMgYi9kcml2ZXJzL2dw
dS9kcm0vYW1kL2FtZGtmZC9rZmRfcHJvY2Vzcy5jDQo+IGluZGV4IGMwNmU2MTkwZjIxZmZhLi5l
NWUzMjZmMmYyNjc1ZSAxMDA2NDQNCj4gLS0tIGEvZHJpdmVycy9ncHUvZHJtL2FtZC9hbWRrZmQv
a2ZkX3Byb2Nlc3MuYw0KPiArKysgYi9kcml2ZXJzL2dwdS9kcm0vYW1kL2FtZGtmZC9rZmRfcHJv
Y2Vzcy5jDQo+IEBAIC00ODYsMTEgKzQ4Niw5IEBAIHN0YXRpYyB2b2lkIGtmZF9wcm9jZXNzX3Jl
Zl9yZWxlYXNlKHN0cnVjdCBrcmVmICpyZWYpDQo+ICAgCXF1ZXVlX3dvcmsoa2ZkX3Byb2Nlc3Nf
d3EsICZwLT5yZWxlYXNlX3dvcmspOw0KPiAgIH0NCj4gICANCj4gLXN0YXRpYyB2b2lkIGtmZF9w
cm9jZXNzX2Rlc3Ryb3lfZGVsYXllZChzdHJ1Y3QgcmN1X2hlYWQgKnJjdSkNCj4gK3N0YXRpYyB2
b2lkIGtmZF9wcm9jZXNzX2ZyZWVfbm90aWZpZXIoc3RydWN0IG1tdV9ub3RpZmllciAqbW4pDQo+
ICAgew0KPiAtCXN0cnVjdCBrZmRfcHJvY2VzcyAqcCA9IGNvbnRhaW5lcl9vZihyY3UsIHN0cnVj
dCBrZmRfcHJvY2VzcywgcmN1KTsNCj4gLQ0KPiAtCWtmZF91bnJlZl9wcm9jZXNzKHApOw0KPiAr
CWtmZF91bnJlZl9wcm9jZXNzKGNvbnRhaW5lcl9vZihtbiwgc3RydWN0IGtmZF9wcm9jZXNzLCBt
bXVfbm90aWZpZXIpKTsNCj4gICB9DQo+ICAgDQo+ICAgc3RhdGljIHZvaWQga2ZkX3Byb2Nlc3Nf
bm90aWZpZXJfcmVsZWFzZShzdHJ1Y3QgbW11X25vdGlmaWVyICptbiwNCj4gQEAgLTU0MiwxMiAr
NTQwLDEyIEBAIHN0YXRpYyB2b2lkIGtmZF9wcm9jZXNzX25vdGlmaWVyX3JlbGVhc2Uoc3RydWN0
IG1tdV9ub3RpZmllciAqbW4sDQo+ICAgDQo+ICAgCW11dGV4X3VubG9jaygmcC0+bXV0ZXgpOw0K
PiAgIA0KPiAtCW1tdV9ub3RpZmllcl91bnJlZ2lzdGVyX25vX3JlbGVhc2UoJnAtPm1tdV9ub3Rp
ZmllciwgbW0pOw0KPiAtCW1tdV9ub3RpZmllcl9jYWxsX3NyY3UoJnAtPnJjdSwgJmtmZF9wcm9j
ZXNzX2Rlc3Ryb3lfZGVsYXllZCk7DQo+ICsJbW11X25vdGlmaWVyX3B1dCgmcC0+bW11X25vdGlm
aWVyKTsNCj4gICB9DQo+ICAgDQo+ICAgc3RhdGljIGNvbnN0IHN0cnVjdCBtbXVfbm90aWZpZXJf
b3BzIGtmZF9wcm9jZXNzX21tdV9ub3RpZmllcl9vcHMgPSB7DQo+ICAgCS5yZWxlYXNlID0ga2Zk
X3Byb2Nlc3Nfbm90aWZpZXJfcmVsZWFzZSwNCj4gKwkuZnJlZV9ub3RpZmllciA9IGtmZF9wcm9j
ZXNzX2ZyZWVfbm90aWZpZXIsDQo+ICAgfTsNCj4gICANCj4gICBzdGF0aWMgaW50IGtmZF9wcm9j
ZXNzX2luaXRfY3dzcl9hcHUoc3RydWN0IGtmZF9wcm9jZXNzICpwLCBzdHJ1Y3QgZmlsZSAqZmls
ZXApDQo=

