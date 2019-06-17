Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68036C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 18:02:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15589208CB
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 18:02:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="0VHjZjnB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15589208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91DD58E0004; Mon, 17 Jun 2019 14:02:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CD448E0001; Mon, 17 Jun 2019 14:02:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BBB98E0004; Mon, 17 Jun 2019 14:02:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 29A238E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 14:02:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a5so17371218edx.12
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:02:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=MqaJrCrgxnuP9FTTiF6b+cE/nLHB0A2RzP/qo3U1IHg=;
        b=ihgznVohvMzcP6p6PI7A1CdxvuyhISBo8RwlIx78zC7hyATYg6aaYntdFg41EDVqR+
         E6It5OswbY6Pbs8Gma8/l3HSHVKF9oD6KshWHFZiikfEDLu1vhaYwGMp2FYDb5p+EbQm
         NX67hGPKa4XIDX8iqJRU6hcLWJQ249KjWcBQDv/ALcdjmV3RGgrXP3ddxdh85cb3LQSz
         7q193KN0WXLVnyjdTlwVn5l4D+2nFpOjn82YfuB3F2lec66b+sbIWWtOXalpu/ANDyDi
         +u3Sg8gRR6KVNiBM0x6cg0a2QGFY6zTj0UB6nPmRB2mJ09lXq8Xbyet42FAv4bQ07iBI
         UWmg==
X-Gm-Message-State: APjAAAU7UrdPl1UnLqwgLs7xSX79zfOwZkPG2jZqDvoWFB1Q5umAE2j9
	2Gwo+ijf98XoiPcfyd6lBba7Y4ea44xa2b5OEJXuXb7Ei9KWWYr8KOKcXNFg82E/DduwCTr5PBe
	fFFcFLlPPUJsQzI6SFJ/CZlkljZXBVJrHWBQh5VF63oJ97yOTJ90558xVTwcH7NyQNw==
X-Received: by 2002:a50:b1e1:: with SMTP id n30mr59301929edd.177.1560794576759;
        Mon, 17 Jun 2019 11:02:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7i9BRAObd64H8tSP72PISP8UIId2XYWqlCI6P2agGartJBZhheAP3OxvOYgf8275rV5xJ
X-Received: by 2002:a50:b1e1:: with SMTP id n30mr59138815edd.177.1560792052175;
        Mon, 17 Jun 2019 10:20:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560792052; cv=none;
        d=google.com; s=arc-20160816;
        b=x68dQlH7y8iVtVoRASw0eTZpYMNCSCmf35vNb+0zUtBSM6eN1iirgxIpxFJQSVbaOR
         3kYWN8awEEzFCxdRv0vOWA3vwOo4L4SG7Mx61ndrn2MohJ2Z/zYNCu+ve7aRoi1gII4C
         G5G6co2nkjA99V4A/NXbZGyyOIIYmuGy3D1pjUQ7Wf9UMABrYq+x+3887ld3bJLkMmEe
         AzecqR9kF9w+Aui0MRI+w3r6afZBmVF2e0DabPYcBAUgKOj+VeBpsQknTCfaeo3f4U7k
         oSICw+U0cNqeuTtKQ5uv4ej2wwUQIprwlilBNmHJInf8CiktQ1jHs1RQOV0L9OoCf7mh
         sqrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=MqaJrCrgxnuP9FTTiF6b+cE/nLHB0A2RzP/qo3U1IHg=;
        b=VL0sMDnOK84I6novUvwlexMdpJaowozhF4NOjguUBxGl5ObyLBgTRxQJk/LMxrLH5t
         7/0/Qr8fkrvDOJQksQfSctEMQivHCmocFLMvIClrNUg/MwhyG3/EnmMT2yaWCOqlFbpj
         13G47RqMEMI6/49C8TH/SFtaYSosuXi4L5rHKQgt2lPHnwCw8ZK028E28Coop0DReS/w
         levIsgzyzUMpJz3X4dqrOpMCL/YdiLNDk2ZiUyZ2Rws0KUtVYW/rwirx/7kMFRQCp9Do
         Fnx8Fr/+UYZzo92ykI1VzBq6sCcKGDXokuEk7e7/BwyFw41e+UXTpdibEUVTwyXymlvy
         teog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=0VHjZjnB;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.82.72 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-eopbgr820072.outbound.protection.outlook.com. [40.107.82.72])
        by mx.google.com with ESMTPS id d12si7321207ejp.165.2019.06.17.10.20.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jun 2019 10:20:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.82.72 as permitted sender) client-ip=40.107.82.72;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=0VHjZjnB;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.82.72 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=MqaJrCrgxnuP9FTTiF6b+cE/nLHB0A2RzP/qo3U1IHg=;
 b=0VHjZjnBANeb/w95G5I4u/F8mI6XdaGx/ooExrQjTuq5TDk9eK2kRkRbh9BZ7t8YHjyQmhrX8NAXGHQI0mRRKJjGHJyAuswraNyFY2FS/9k5AtfLwEpZQoHRQ78TC72BVMskpE3K8tMLzWL2WpGln3VVVObFrpJhsUTk15mjPUk=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB5303.namprd05.prod.outlook.com (20.177.127.20) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.12; Mon, 17 Jun 2019 17:20:48 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58%7]) with mapi id 15.20.2008.007; Mon, 17 Jun 2019
 17:20:48 +0000
From: Nadav Amit <namit@vmware.com>
To: Sasha Levin <sashal@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>, LKML
	<linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Borislav
 Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra
	<peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
	Ingo Molnar <mingo@kernel.org>, "stable@vger.kernel.org"
	<stable@vger.kernel.org>
Subject: Re: [PATCH 3/3] resource: Introduce resource cache
Thread-Topic: [PATCH 3/3] resource: Introduce resource cache
Thread-Index: AQHVJTEB4XE0tBkHtk2lJa7fZ26NHA==
Date: Mon, 17 Jun 2019 17:20:48 +0000
Message-ID: <11F97160-C769-461F-ADE8-70D4A2A7A071@vmware.com>
References: <20190613045903.4922-4-namit@vmware.com>
 <20190615221607.4B44521841@mail.kernel.org>
In-Reply-To: <20190615221607.4B44521841@mail.kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a704e7df-9b53-4be6-fcbf-08d6f34823de
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR05MB5303;
x-ms-traffictypediagnostic: BYAPR05MB5303:
x-microsoft-antispam-prvs:
 <BYAPR05MB5303E3EBAE721E55CCF845B3D0EB0@BYAPR05MB5303.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0071BFA85B
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(396003)(39860400002)(136003)(376002)(346002)(189003)(199004)(6512007)(8676002)(11346002)(3846002)(86362001)(81156014)(76176011)(2616005)(446003)(486006)(2906002)(186003)(26005)(476003)(6116002)(54906003)(256004)(53546011)(6506007)(25786009)(53936002)(7416002)(6246003)(4326008)(76116006)(73956011)(66946007)(7736002)(66446008)(305945005)(71190400001)(71200400001)(36756003)(64756008)(66476007)(66556008)(66066001)(6916009)(316002)(6486002)(5660300002)(99286004)(102836004)(81166006)(478600001)(8936002)(33656002)(14454004)(6436002)(229853002)(68736007);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB5303;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 c0xtzHxGc//Ba5vScAd1vLJiGHgeZNx61W7wQFdC6Oe/dkp3xjgMkZ6Be2KqYy1N/9V38F16z/p/D5JnQZRA7Q72YSPn4qxqwjkHa9Yhllr01Qf+UILx7nhRBD3NJ7nZhdAE+MbWL6OV6w/wShoCe8sJ28cjStnx7OEEAnU41ckqdS+qiAThcJl501Lfy3Xw4bmeZUDs/X7IFb0Ea7Bi5vWvb55vD7xY8xQCitgoeNZ+0M9Czp34mdbVHZHNbAHggmeVQ6mNhTXneDtno0neH5gr3/7NvUaGE1YvWJBSvbsPFUOInstFjrTQNZEnZEzbvl9YDpJhuvUqEFbRxenIPvOny4yaxQuJ1AIpXvPO5p2ZGXZZv4b2WGH9ZD5EYzPZoYmKkfhxt0uXpjtdwh3uIgy6B/V/2ztFy5mVKB+C6CA=
Content-Type: text/plain; charset="utf-8"
Content-ID: <7FDAAD65E28C72469E1292356FAF4612@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a704e7df-9b53-4be6-fcbf-08d6f34823de
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Jun 2019 17:20:48.3625
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB5303
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBKdW4gMTUsIDIwMTksIGF0IDM6MTYgUE0sIFNhc2hhIExldmluIDxzYXNoYWxAa2VybmVs
Lm9yZz4gd3JvdGU6DQo+IA0KPiBIaSwNCj4gDQo+IFtUaGlzIGlzIGFuIGF1dG9tYXRlZCBlbWFp
bF0NCj4gDQo+IFRoaXMgY29tbWl0IGhhcyBiZWVuIHByb2Nlc3NlZCBiZWNhdXNlIGl0IGNvbnRh
aW5zIGEgIkZpeGVzOiIgdGFnLA0KPiBmaXhpbmcgY29tbWl0OiBmZjNjYzk1MmQzZjAgcmVzb3Vy
Y2U6IEFkZCByZW1vdmVfcmVzb3VyY2UgaW50ZXJmYWNlLg0KDQpUaGlzIGNvbW1pdCAoUGF0Y2gg
My8zKSBkb2VzIG5vdCBoYXZlIHRoZSDigJxGaXhlczrigJ0gdGFnIChhbmQgaXQgaXMgYQ0KcGVy
Zm9ybWFuY2UgZW5oYW5jZW1lbnQpLCBzbyBJIGRvbuKAmXQga25vdyB3aHkgaXQgd2FzIHByb2Nl
c3NlZC4NCg0KSU9XOiBwbGVhc2UgZG8gbm90IGJhY2twb3J0IGl0Lg0KDQo+IFRoZSBib3QgaGFz
IHRlc3RlZCB0aGUgZm9sbG93aW5nIHRyZWVzOiB2NS4xLjksIHY0LjE5LjUwLCB2NC4xNC4xMjUs
IHY0LjkuMTgxLg0KPiANCj4gdjUuMS45OiBCdWlsZCBPSyENCj4gdjQuMTkuNTA6IEZhaWxlZCB0
byBhcHBseSEgUG9zc2libGUgZGVwZW5kZW5jaWVzOg0KPiAgICAwMTBhOTNiZjk3YzcgKCJyZXNv
dXJjZTogRml4IGZpbmRfbmV4dF9pb21lbV9yZXMoKSBpdGVyYXRpb24gaXNzdWUiKQ0KPiAgICA3
YTUzYmIzMDllYjMgKCJyZXNvdXJjZTogRml4IGxvY2tpbmcgaW4gZmluZF9uZXh0X2lvbWVtX3Jl
cygpIikNCj4gICAgYTk4OTU5ZmRiZGExICgicmVzb3VyY2U6IEluY2x1ZGUgcmVzb3VyY2UgZW5k
IGluIHdhbGtfKigpIGludGVyZmFjZXMiKQ0KPiANCj4gdjQuMTQuMTI1OiBGYWlsZWQgdG8gYXBw
bHkhIFBvc3NpYmxlIGRlcGVuZGVuY2llczoNCj4gICAgMDEwYTkzYmY5N2M3ICgicmVzb3VyY2U6
IEZpeCBmaW5kX25leHRfaW9tZW1fcmVzKCkgaXRlcmF0aW9uIGlzc3VlIikNCj4gICAgMGU0YzEy
YjQ1YWE4ICgieDg2L21tLCByZXNvdXJjZTogVXNlIFBBR0VfS0VSTkVMIHByb3RlY3Rpb24gZm9y
IGlvcmVtYXAgb2YgbWVtb3J5IHBhZ2VzIikNCj4gICAgMWQyZTczM2IxM2I0ICgicmVzb3VyY2U6
IFByb3ZpZGUgcmVzb3VyY2Ugc3RydWN0IGluIHJlc291cmNlIHdhbGsgY2FsbGJhY2siKQ0KPiAg
ICA0YWMyYWVkODM3Y2IgKCJyZXNvdXJjZTogQ29uc29saWRhdGUgcmVzb3VyY2Ugd2Fsa2luZyBj
b2RlIikNCj4gICAgN2E1M2JiMzA5ZWIzICgicmVzb3VyY2U6IEZpeCBsb2NraW5nIGluIGZpbmRf
bmV4dF9pb21lbV9yZXMoKSIpDQo+ICAgIGE5ODk1OWZkYmRhMSAoInJlc291cmNlOiBJbmNsdWRl
IHJlc291cmNlIGVuZCBpbiB3YWxrXyooKSBpbnRlcmZhY2VzIikNCj4gDQo+IHY0LjkuMTgxOiBG
YWlsZWQgdG8gYXBwbHkhIFBvc3NpYmxlIGRlcGVuZGVuY2llczoNCj4gICAgMDEwYTkzYmY5N2M3
ICgicmVzb3VyY2U6IEZpeCBmaW5kX25leHRfaW9tZW1fcmVzKCkgaXRlcmF0aW9uIGlzc3VlIikN
Cj4gICAgMGU0YzEyYjQ1YWE4ICgieDg2L21tLCByZXNvdXJjZTogVXNlIFBBR0VfS0VSTkVMIHBy
b3RlY3Rpb24gZm9yIGlvcmVtYXAgb2YgbWVtb3J5IHBhZ2VzIikNCj4gICAgMWQyZTczM2IxM2I0
ICgicmVzb3VyY2U6IFByb3ZpZGUgcmVzb3VyY2Ugc3RydWN0IGluIHJlc291cmNlIHdhbGsgY2Fs
bGJhY2siKQ0KPiAgICA0YWMyYWVkODM3Y2IgKCJyZXNvdXJjZTogQ29uc29saWRhdGUgcmVzb3Vy
Y2Ugd2Fsa2luZyBjb2RlIikNCj4gICAgNjBmZTM5MTBiYjAyICgia2V4ZWNfZmlsZTogQWxsb3cg
YXJjaC1zcGVjaWZpYyBtZW1vcnkgd2Fsa2luZyBmb3Iga2V4ZWNfYWRkX2J1ZmZlciIpDQo+ICAg
IDdhNTNiYjMwOWViMyAoInJlc291cmNlOiBGaXggbG9ja2luZyBpbiBmaW5kX25leHRfaW9tZW1f
cmVzKCkiKQ0KPiAgICBhMDQ1ODI4NGYwNjIgKCJwb3dlcnBjOiBBZGQgc3VwcG9ydCBjb2RlIGZv
ciBrZXhlY19maWxlX2xvYWQoKSIpDQo+ICAgIGE5ODk1OWZkYmRhMSAoInJlc291cmNlOiBJbmNs
dWRlIHJlc291cmNlIGVuZCBpbiB3YWxrXyooKSBpbnRlcmZhY2VzIikNCj4gICAgZGE2NjU4ODU5
YjljICgicG93ZXJwYzogQ2hhbmdlIHBsYWNlcyB1c2luZyBDT05GSUdfS0VYRUMgdG8gdXNlIENP
TkZJR19LRVhFQ19DT1JFIGluc3RlYWQuIikNCj4gICAgZWMyYjliZmFhYzQ0ICgia2V4ZWNfZmls
ZTogQ2hhbmdlIGtleGVjX2FkZF9idWZmZXIgdG8gdGFrZSBrZXhlY19idWYgYXMgYXJndW1lbnQu
IikNCj4gDQo+IA0KPiBIb3cgc2hvdWxkIHdlIHByb2NlZWQgd2l0aCB0aGlzIHBhdGNoPw0KPiAN
Cj4gLS0NCj4gVGhhbmtzLA0KPiBTYXNoYQ0KDQoNCg==

