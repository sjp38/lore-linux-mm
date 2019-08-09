Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B1F5C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:39:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B41C92171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:39:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=virtuozzo.com header.i=@virtuozzo.com header.b="DqRtl3j+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B41C92171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D4D46B0008; Fri,  9 Aug 2019 04:39:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5863C6B000D; Fri,  9 Aug 2019 04:39:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 427E66B000E; Fri,  9 Aug 2019 04:39:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E259D6B0008
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:39:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z2so892380ede.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:39:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-id:content-transfer-encoding:mime-version;
        bh=jGFKczGLGY0IDl1wy/gVgXZBXb09Ufx5CxdWE6Y8koE=;
        b=BGHHhjHYJSJAOBJjmnoY/MST21+014l8xjVg1nbzB+6kbVvRRtJNZNSwP3ytG2DdHC
         cwmBOu1lZV9BYHECY6aMwxsx/w4eUmfqExdepeePsdQPAy0pyeLNUvHmkiePJKyAQCsG
         IqPRnlSNkjMGeG1Uf3iPERiVYlsEzcgHtrnrtwnMHrT1lCym0ac3QaWZxBpiLV6m44co
         T4NDw1w/CrjUI7tpVWkXx0seaD/wzORlYTwwd93SzS15ci8q6yUkE50eDH3C/UumX3mX
         nA/cLwjyZTRRw743W/akYJyXi3f5OvduTAUagLjmi1HBUh+e3sBtMOYEVrTYwyjPspiE
         L6tg==
X-Gm-Message-State: APjAAAUgd0VykZ+K2wGbfBq1auyQuD0RbbanUFtntUAmJye2KQoutvxw
	3q6nTv7zlwwpBMovOhPy5wmQ2B9uoAz+zoAv1RN+/Ii6mJGObaI9QgZNHsbhThC1M+kT0IEn+jr
	jcCmDE+5jyo2BrIgofrzxsibpfR7h7r/Wy03TNDD7qKviFSzaIvwRlTMzZCJhV1f7yw==
X-Received: by 2002:a50:ae8f:: with SMTP id e15mr20462787edd.74.1565339961379;
        Fri, 09 Aug 2019 01:39:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxU0uW26jmgBuJ550wESf//KUlfvHflsjpdAL2aJJHB5SUpZvjzBD0KdUjkSonQ0fxEon7c
X-Received: by 2002:a50:ae8f:: with SMTP id e15mr20462701edd.74.1565339960063;
        Fri, 09 Aug 2019 01:39:20 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565339960; cv=pass;
        d=google.com; s=arc-20160816;
        b=tR2yL7Fe3ENrZDjIpHiu3soPucLSw2+gUd7bPrJ6Vu3BD2UkhP+5gXxoHgTXuDN7MG
         SzCdeoAV7C7KtyHPBrkpTFAGD3TLplCHJLOqZlVo9zKv36aF53rFbk/1voW7biS+d/2U
         2oc9NNZ8jV8YXGvGdJArZDNdwRWIAh4Qyi7aWq9teYgkFb05bpyt7ZeeaOPfUU0RHRXM
         jRs872WA8Z/lOs6wqIH4dtD0FC3bdaHmclE2wsQPy2e2cTelGD6apkGBOYP5GbLkYanA
         CSA1DZLcJVgi0kPmyaXDcca/3SC38A24k82dNKGEYd2nP7VQorsh8OyTNeNqRhHmN07/
         Va4Q==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=jGFKczGLGY0IDl1wy/gVgXZBXb09Ufx5CxdWE6Y8koE=;
        b=V11ieiBny42fIg1hHwVijbPE6IBP8ABfVdGFs+1MCnSm9IbbCQDpMK/I5qYtrP54h8
         Q9gsUcMIhP+lAShq4LtyN4McHS1nZ4c2AMcaoi/N+i72tIXERRSewi/bSut5+aWmSdZg
         ioQY7yAt7KxNLOisxZkD+3tfyR/ybnRvGJ04TpvGvzsGRb6fqbGMPalamz0A77DCcQ5x
         uZl8gcd+Egtz/fQf++uOdVxrXjv8h051UdhLxjrRX31w7eSSqkiIk/KVDxhbMNNct/1Q
         kOcZ3pLOPBR69KB3M01hNlYMAtCJFp2a6VtWj0H+mPXPEetNTbzj0GNZ+LM1fLHP5TgB
         SE0Q==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@virtuozzo.com header.s=selector1 header.b=DqRtl3j+;
       arc=pass (i=1 spf=pass spfdomain=virtuozzo.com dkim=pass dkdomain=virtuozzo.com dmarc=pass fromdomain=virtuozzo.com);
       spf=pass (google.com: domain of ptikhomirov@virtuozzo.com designates 40.107.6.99 as permitted sender) smtp.mailfrom=ptikhomirov@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60099.outbound.protection.outlook.com. [40.107.6.99])
        by mx.google.com with ESMTPS id jp14si33319011ejb.398.2019.08.09.01.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:39:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of ptikhomirov@virtuozzo.com designates 40.107.6.99 as permitted sender) client-ip=40.107.6.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@virtuozzo.com header.s=selector1 header.b=DqRtl3j+;
       arc=pass (i=1 spf=pass spfdomain=virtuozzo.com dkim=pass dkdomain=virtuozzo.com dmarc=pass fromdomain=virtuozzo.com);
       spf=pass (google.com: domain of ptikhomirov@virtuozzo.com designates 40.107.6.99 as permitted sender) smtp.mailfrom=ptikhomirov@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=aLtg67X9fO+9jeDRABesnok959ztUvvA+jIYDPY+AC0vnJkaiL/OeakBMvr4qKg4/EXBQsrgbkdwoOt63Fc8hTQk7BB9R5fwbqS9+jkKl81kIzrhZ/ZtJmwIye8VcXhhE3C6TcIOnNXtOgfOCdhOxc5La4/LXiIrtTzjmf7S9KtiV7XQaXjHEskfuI6y2UfXYPjCFQAoWgQuOGCwEKunjwpFi3HUznRlo4XyOhyKtHO5ycVrCcsx3e1Mxtfg7udG6fhl6pLlR7lTW2OMZMKlXGKMIAKt7ojGygIkJPjocZPxL2OWJvL4+S8mlQxRA06Xjh+uT1knIpvSrvKlXh4i0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jGFKczGLGY0IDl1wy/gVgXZBXb09Ufx5CxdWE6Y8koE=;
 b=HBaYfE9dphNXZOFSFkqHo0oEtq/kO4PbdY1+bPsJFCVvTi1ZWyU5HdPHUZKedsybnUgIfVgLd+iS5AblTwQHpvGKIgJelyiyuKuoXMtQ/r9oOuwS1oPGi/xsn8BMgESBuEhFDDZ72qkqN88todD7yExkxNLtDr+XSrkfT6QuvKIgmGjdg1Lqec25+tNGZYnlRxs8WA3aZ16ldnApw5RAJANdEjyxtHQHjMCoeGysySWb/EG4FZPxaXJxTJQYTp4qKNFWZSDcbgvZoNaSqXRO1EtXfYaN4w6FYy9frWrJAShNB6QAeeu5vZkEiX9wy+tnebmGAM6EoGNk5j9zakwPIQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=virtuozzo.com; dmarc=pass action=none
 header.from=virtuozzo.com; dkim=pass header.d=virtuozzo.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=virtuozzo.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jGFKczGLGY0IDl1wy/gVgXZBXb09Ufx5CxdWE6Y8koE=;
 b=DqRtl3j+G53Dow1R3Ux2+pDmfaQlI90TFHDVwLhe4D83JxjplYkUEdu79eRj3Rhuv3Dr8u/oT9jLJFZG5G51oO4B4voUAQqbFGpJPWlbN3XlxAyUsjO5FyLDFFhIUaKNuV6aZap8+mwNrUgDlhejM1AEVSxpAKh7nUBRqTI/CvI=
Received: from AM4PR08MB2788.eurprd08.prod.outlook.com (10.170.126.27) by
 AM4PR08MB2883.eurprd08.prod.outlook.com (10.171.189.30) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.14; Fri, 9 Aug 2019 08:39:18 +0000
Received: from AM4PR08MB2788.eurprd08.prod.outlook.com
 ([fe80::c957:d45:7c68:8f0a]) by AM4PR08MB2788.eurprd08.prod.outlook.com
 ([fe80::c957:d45:7c68:8f0a%3]) with mapi id 15.20.2157.015; Fri, 9 Aug 2019
 08:39:17 +0000
From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
CC: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, Andrew
 Morton <akpm@linux-foundation.org>, Dennis Zhou <dennis@kernel.org>, Josef
 Bacik <josef@toxicpanda.com>, Tejun Heo <tj@kernel.org>, Huang Ying
	<ying.huang@intel.com>, Oleg Nesterov <oleg@redhat.com>, Omar Sandoval
	<osandov@fb.com>, Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: mm/swap: possible problem introduced when replacing REQ_NOIDLE with
 REQ_IDLE
Thread-Topic: mm/swap: possible problem introduced when replacing REQ_NOIDLE
 with REQ_IDLE
Thread-Index: AQHVTo3ukbTH214ZGEeZtMz4hCHI7Q==
Date: Fri, 9 Aug 2019 08:39:17 +0000
Message-ID: <d5faac47-8a8c-90ff-877d-b793b715ac4d@virtuozzo.com>
Accept-Language: ru-RU, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: HE1PR07CA0043.eurprd07.prod.outlook.com
 (2603:10a6:7:66::29) To AM4PR08MB2788.eurprd08.prod.outlook.com
 (2603:10a6:205:10::27)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=ptikhomirov@virtuozzo.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [185.231.240.5]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e81ff02c-666d-44fc-9bf7-08d71ca51102
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:AM4PR08MB2883;
x-ms-traffictypediagnostic: AM4PR08MB2883:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs:
 <AM4PR08MB2883CFDDD3682256491BB7CEB7D60@AM4PR08MB2883.eurprd08.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:949;
x-forefront-prvs: 01244308DF
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(346002)(396003)(136003)(376002)(39850400004)(366004)(51874003)(189003)(199004)(6436002)(186003)(26005)(99286004)(4326008)(54906003)(107886003)(6512007)(386003)(110136005)(6506007)(102836004)(71190400001)(36756003)(8936002)(53936002)(81166006)(71200400001)(81156014)(66066001)(31686004)(2616005)(486006)(316002)(256004)(476003)(52116002)(6486002)(2906002)(66556008)(66946007)(66476007)(5660300002)(478600001)(66446008)(6116002)(7736002)(86362001)(3846002)(31696002)(25786009)(8676002)(305945005)(7416002)(64756008)(2501003)(14454004);DIR:OUT;SFP:1102;SCL:1;SRVR:AM4PR08MB2883;H:AM4PR08MB2788.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: virtuozzo.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 tRPRHqfxo9BPUknZTLzDMeE1VYN/ZexcuyHXFq4ThJ8vodHiAjZGgKak4zJQ6YHatOj0eXKIP9z2rBpCZWEJgTO2jqodyPJOHWR+V+DxiKt5eU4J2hbT1RW+WA8YfBVJx4qBHkA6uTqkQN/ldjxbH+mXJo54vB0xgJm3hWTvlwgtTIPydp34nTVMBAflj115eFcAF5iA2K6Ubg5cylnNQvzk/W+cHWvUH4bjMqcsA15vme1EJpR+e+TtyzkgtyFRexzefjD+NKbqMdn4iFcjE7Lzpo5V2GfOhtTwxEj6FmOQHmGQhNxUSMlzocL3nN/VjM1aDOr+ZaCEKM/zDx2YIgv5sXxetcRtqbQLvL4bhmB7Dl1pTxZlfB/WBNU+lKNjftQT+lF/UCZFtt9cW1zW+o/dd0SKXshrGRuQHrKj9ig=
Content-Type: text/plain; charset="utf-8"
Content-ID: <767ABA55F07BCC4B946088BB3D58F95B@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: virtuozzo.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e81ff02c-666d-44fc-9bf7-08d71ca51102
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Aug 2019 08:39:17.8618
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0bc7f26d-0264-416e-a6fc-8352af79c58f
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 8rVDEv/wprmCjHlJW9zMhUxwzhmRXw07d1V87bgDghxdlPH+y03lJxgepPd/gKl2sONNAosy6+GK7jK5T6+0lnRuMHikPUlJfBPOevzigQQ=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM4PR08MB2883
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGksIGFsbC4NCg0KVGhlbiBwb3J0aW5nIHBhdGNoZXMgZnJvbSBtYWluc3RyZWFtIEkndmUgZm91
bmQgc29tZSBzdHJhbmdlIGNvZGU6DQoNCiA+IGNvbW1pdCBhMmI4MDk2NzJlZTZmY2I0ZDU3NTZl
YTgxNTcyNWIzZGJhZWE2NTRlDQogPiBBdXRob3I6IENocmlzdG9waCBIZWxsd2lnIDxoY2hAbHN0
LmRlPg0KID4gRGF0ZTogICBUdWUgTm92IDEgMDc6NDA6MDkgMjAxNiAtMDYwMA0KID4NCiA+ICAg
ICBibG9jazogcmVwbGFjZSBSRVFfTk9JRExFIHdpdGggUkVRX0lETEUNCiA+DQogPiAgICAgTm9p
ZGxlIHNob3VsZCBiZSB0aGUgZGVmYXVsdCBmb3Igd3JpdGVzIGFzIHNlZW4gYnkgYWxsIHRoZSBj
b21wb3VuZHMNCiA+ICAgICBkZWZpbml0aW9ucyBpbiBmcy5oIHVzaW5nIGl0LiAgSW4gZmFjdCBv
bmx5IGRpcmVjdCBJL08gcmVhbGx5IHNob3VsZA0KID4gICAgIGJlIHVzaW5nIE5PRElMRSwgc28g
dHVybiB0aGUgd2hvbGUgZmxhZyBhcm91bmQgdG8gZ2V0IHRoZSBkZWZhdWx0cw0KID4gICAgIHJp
Z2h0LCB3aGljaCB3aWxsIG1ha2Ugb3VyIGxpZmUgbXVjaCBlYXNpZXIgZXNwZWNpYWxseSBvbmNl
cyB0aGUNCiA+ICAgICBXUklURV8qIGRlZmluZXMgZ28gYXdheS4NCiA+DQogPiAgICAgVGhpcyBh
c3N1bWVzIGFsbCB0aGUgZXhpc3RpbmcgInJhdyIgdXNlcnMgb2YgUkVRX1NZTkMgZm9yIHdyaXRl
cw0KID4gICAgIHdhbnQgbm9pZGxlIGJlaGF2aW9yLCB3aGljaCBzZWVtcyB0byBiZSBzcG90IG9u
IGZyb20gYSBxdWljayBhdWRpdC4NCiA+DQogPiAgICAgU2lnbmVkLW9mZi1ieTogQ2hyaXN0b3Bo
IEhlbGx3aWcgPGhjaEBsc3QuZGU+DQogPiAgICAgU2lnbmVkLW9mZi1ieTogSmVucyBBeGJvZSA8
YXhib2VAZmIuY29tPg0KID4NCiA+IGRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L2ZzLmggYi9p
bmNsdWRlL2xpbnV4L2ZzLmgNCiA+IGluZGV4IGNjZWRjY2IyOGVjOC4uNDZhNzQyMDk5MTdmIDEw
MDY0NA0KID4gLS0tIGEvaW5jbHVkZS9saW51eC9mcy5oDQogPiArKysgYi9pbmNsdWRlL2xpbnV4
L2ZzLmgNCiA+IEBAIC0xOTcsMTEgKzE5NywxMSBAQCB0eXBlZGVmIGludCAoZGlvX2lvZG9uZV90
KShzdHJ1Y3Qga2lvY2IgKmlvY2IsIA0KbG9mZl90IG9mZnNldCwNCiA+ICAjZGVmaW5lIFdSSVRF
ICAgICAgICAgICAgICAgICAgUkVRX09QX1dSSVRFDQogPg0KID4gICNkZWZpbmUgUkVBRF9TWU5D
ICAgICAgICAgICAgICAwDQogPiAtI2RlZmluZSBXUklURV9TWU5DICAgICAgICAgICAgIChSRVFf
U1lOQyB8IFJFUV9OT0lETEUpDQogPiAtI2RlZmluZSBXUklURV9PRElSRUNUICAgICAgICAgIFJF
UV9TWU5DDQogPiAtI2RlZmluZSBXUklURV9GTFVTSCAgICAgICAgICAgIChSRVFfTk9JRExFIHwg
UkVRX1BSRUZMVVNIKQ0KID4gLSNkZWZpbmUgV1JJVEVfRlVBICAgICAgICAgICAgICAoUkVRX05P
SURMRSB8IFJFUV9GVUEpDQogPiAtI2RlZmluZSBXUklURV9GTFVTSF9GVUEgICAgICAgICAgICAg
ICAgKFJFUV9OT0lETEUgfCBSRVFfUFJFRkxVU0ggfCANClJFUV9GVUEpDQogPiArI2RlZmluZSBX
UklURV9TWU5DICAgICAgICAgICAgIFJFUV9TWU5DDQogPiArI2RlZmluZSBXUklURV9PRElSRUNU
ICAgICAgICAgIChSRVFfU1lOQyB8IFJFUV9JRExFKQ0KID4gKyNkZWZpbmUgV1JJVEVfRkxVU0gg
ICAgICAgICAgICBSRVFfUFJFRkxVU0gNCiA+ICsjZGVmaW5lIFdSSVRFX0ZVQSAgICAgICAgICAg
ICAgUkVRX0ZVQQ0KID4gKyNkZWZpbmUgV1JJVEVfRkxVU0hfRlVBICAgICAgICAgICAgICAgIChS
RVFfUFJFRkxVU0ggfCBSRVFfRlVBKQ0KID4NCiA+ICAvKg0KID4gICAqIEF0dHJpYnV0ZSBmbGFn
cy4gIFRoZXNlIHNob3VsZCBiZSBvci1lZCB0b2dldGhlciB0byBmaWd1cmUgb3V0IHdoYXQNCg0K
VGhlIGFib3ZlIGNvbW1pdCBjaGFuZ2VzIHRoZSBtZWFuaW5nIG9mIHRoZSBSRVFfU1lOQyBmbGFn
LCBiZWZvcmUgdGhlIA0KcGF0Y2ggaXQgd2FzIGVxdWFsIHRvIFdSSVRFX09ESVJFQ1QgYW5kIGFm
dGVyIHRoZSBwYXRjaCBpdCBpcyBlcXVhbCB0byANCldSSVRFX1NZTkMuIEFuZCB0aHVzIEkgdGhp
bmsgaXQgYmVjYW1lIHRyZWF0ZWQgZGlmZmVyZW50bHkgKEkgc2VlIG9ubHkgDQpvbmUgcGxhY2Ug
bGVmdCBpbiB3YnRfc2hvdWxkX3Rocm90dGxlLikuDQoNCkJ1dCBpbiBfX3N3YXBfd3JpdGVwYWdl
KCkgYm90aCBiZWZvcmUgYW5kIGFmdGVyIHRoZSBtZW50aW9uZWQgcGF0Y2ggd2UgDQpzdGlsbCBw
YXNzIGEgc2luZ2xlIFJFUV9TWU5DIHdpdGhvdXQgYW55IFJFUV9JRExFL1JFUV9VTklETEU6DQoN
CiA+IFtzbm9yY2hAc25vcmNoIGxpbnV4XSQgZ2l0IGJsYW1lIA0KYTJiODA5NjcyZWU2ZmNiNGQ1
NzU2ZWE4MTU3MjViM2RiYWVhNjU0ZV4gbW0vcGFnZV9pby5jIHwgZ3JlcCAtYTUgUkVRX1NZTkMN
CiA+IF4xZGExNzdlNGMzZjQgKExpbnVzIFRvcnZhbGRzICAgICAgICAyMDA1LTA0LTE2IDE1OjIw
OjM2IC0wNzAwIDMxOSkgDQogICAgICAgICB1bmxvY2tfcGFnZShwYWdlKTsNCiA+IF4xZGExNzdl
NGMzZjQgKExpbnVzIFRvcnZhbGRzICAgICAgICAyMDA1LTA0LTE2IDE1OjIwOjM2IC0wNzAwIDMy
MCkgDQogICAgICAgICByZXQgPSAtRU5PTUVNOw0KID4gXjFkYTE3N2U0YzNmNCAoTGludXMgVG9y
dmFsZHMgICAgICAgIDIwMDUtMDQtMTYgMTU6MjA6MzYgLTA3MDAgMzIxKSANCiAgICAgICAgIGdv
dG8gb3V0Ow0KID4gXjFkYTE3N2U0YzNmNCAoTGludXMgVG9ydmFsZHMgICAgICAgIDIwMDUtMDQt
MTYgMTU6MjA6MzYgLTA3MDAgMzIyKSAgIH0NCiA+IF4xZGExNzdlNGMzZjQgKExpbnVzIFRvcnZh
bGRzICAgICAgICAyMDA1LTA0LTE2IDE1OjIwOjM2IC0wNzAwIDMyMykgDQppZiAod2JjLT5zeW5j
X21vZGUgPT0gV0JfU1lOQ19BTEwpDQogPiBiYTEzZTgzZWMzMzRjIChKZW5zIEF4Ym9lICAgICAg
ICAgICAgMjAxNi0wOC0wMSAwOTozODo0NCAtMDYwMCAzMjQpIA0KICAgICAgICAgYmlvX3NldF9v
cF9hdHRycyhiaW8sIFJFUV9PUF9XUklURSwgUkVRX1NZTkMpOw0KID4gYmExM2U4M2VjMzM0YyAo
SmVucyBBeGJvZSAgICAgICAgICAgIDIwMTYtMDgtMDEgMDk6Mzg6NDQgLTA2MDAgMzI1KSANCmVs
c2UNCiA+IGJhMTNlODNlYzMzNGMgKEplbnMgQXhib2UgICAgICAgICAgICAyMDE2LTA4LTAxIDA5
OjM4OjQ0IC0wNjAwIDMyNikgDQogICAgICAgICBiaW9fc2V0X29wX2F0dHJzKGJpbywgUkVRX09Q
X1dSSVRFLCAwKTsNCiA+IGY4ODkxZTVlMWY5M2EgKENocmlzdG9waCBMYW1ldGVyICAgICAyMDA2
LTA2LTMwIDAxOjU1OjQ1IC0wNzAwIDMyNykgDQpjb3VudF92bV9ldmVudChQU1dQT1VUKTsNCiA+
IF4xZGExNzdlNGMzZjQgKExpbnVzIFRvcnZhbGRzICAgICAgICAyMDA1LTA0LTE2IDE1OjIwOjM2
IC0wNzAwIDMyOCkgDQpzZXRfcGFnZV93cml0ZWJhY2socGFnZSk7DQogPiBeMWRhMTc3ZTRjM2Y0
IChMaW51cyBUb3J2YWxkcyAgICAgICAgMjAwNS0wNC0xNiAxNToyMDozNiAtMDcwMCAzMjkpIA0K
dW5sb2NrX3BhZ2UocGFnZSk7DQogPiBbc25vcmNoQHNub3JjaCBsaW51eF0kIGdpdCBibGFtZSAN
CmEyYjgwOTY3MmVlNmZjYjRkNTc1NmVhODE1NzI1YjNkYmFlYTY1NGUgbW0vcGFnZV9pby5jIHwg
Z3JlcCAtYTUgUkVRX1NZTkMNCiA+IF4xZGExNzdlNGMzZjQgKExpbnVzIFRvcnZhbGRzICAgICAg
ICAyMDA1LTA0LTE2IDE1OjIwOjM2IC0wNzAwIDMxOSkgDQogICAgICAgICB1bmxvY2tfcGFnZShw
YWdlKTsNCiA+IF4xZGExNzdlNGMzZjQgKExpbnVzIFRvcnZhbGRzICAgICAgICAyMDA1LTA0LTE2
IDE1OjIwOjM2IC0wNzAwIDMyMCkgDQogICAgICAgICByZXQgPSAtRU5PTUVNOw0KID4gXjFkYTE3
N2U0YzNmNCAoTGludXMgVG9ydmFsZHMgICAgICAgIDIwMDUtMDQtMTYgMTU6MjA6MzYgLTA3MDAg
MzIxKSANCiAgICAgICAgIGdvdG8gb3V0Ow0KID4gXjFkYTE3N2U0YzNmNCAoTGludXMgVG9ydmFs
ZHMgICAgICAgIDIwMDUtMDQtMTYgMTU6MjA6MzYgLTA3MDAgMzIyKSAgIH0NCiA+IF4xZGExNzdl
NGMzZjQgKExpbnVzIFRvcnZhbGRzICAgICAgICAyMDA1LTA0LTE2IDE1OjIwOjM2IC0wNzAwIDMy
MykgDQppZiAod2JjLT5zeW5jX21vZGUgPT0gV0JfU1lOQ19BTEwpDQogPiBiYTEzZTgzZWMzMzRj
IChKZW5zIEF4Ym9lICAgICAgICAgICAgMjAxNi0wOC0wMSAwOTozODo0NCAtMDYwMCAzMjQpIA0K
ICAgICAgICAgYmlvX3NldF9vcF9hdHRycyhiaW8sIFJFUV9PUF9XUklURSwgUkVRX1NZTkMpOw0K
ID4gYmExM2U4M2VjMzM0YyAoSmVucyBBeGJvZSAgICAgICAgICAgIDIwMTYtMDgtMDEgMDk6Mzg6
NDQgLTA2MDAgMzI1KSANCmVsc2UNCiA+IGJhMTNlODNlYzMzNGMgKEplbnMgQXhib2UgICAgICAg
ICAgICAyMDE2LTA4LTAxIDA5OjM4OjQ0IC0wNjAwIDMyNikgDQogICAgICAgICBiaW9fc2V0X29w
X2F0dHJzKGJpbywgUkVRX09QX1dSSVRFLCAwKTsNCiA+IGY4ODkxZTVlMWY5M2EgKENocmlzdG9w
aCBMYW1ldGVyICAgICAyMDA2LTA2LTMwIDAxOjU1OjQ1IC0wNzAwIDMyNykgDQpjb3VudF92bV9l
dmVudChQU1dQT1VUKTsNCiA+IF4xZGExNzdlNGMzZjQgKExpbnVzIFRvcnZhbGRzICAgICAgICAy
MDA1LTA0LTE2IDE1OjIwOjM2IC0wNzAwIDMyOCkgDQpzZXRfcGFnZV93cml0ZWJhY2socGFnZSk7
DQogPiBeMWRhMTc3ZTRjM2Y0IChMaW51cyBUb3J2YWxkcyAgICAgICAgMjAwNS0wNC0xNiAxNToy
MDozNiAtMDcwMCAzMjkpIA0KdW5sb2NrX3BhZ2UocGFnZSk7DQoNCkl0IGxvb2tzIGxpa2Ugd2Un
dmUgY2hhbmdlZCB0aGUgd2F5IGhvdyB3ZSBoYW5kbGUgc3dhcCBwYWdlIHdyaXRlcyBmcm9tIA0K
Im9kaXJlY3QiIHdheSB0byAicmVndWxhciIgc3luYyB3cml0ZSB3YXksIHRoZXNlIGNhbiBiZSB3
cm9uZy4gVGhpcyBtYXkgDQphbHNvIGFmZmVjdCBkZXByZWNhdGVkIGNmcSBpby1zY2hlZHVsZXIg
b24gb2xkZXIga2VybmVscy4NCg0KVGhhbmtzIGluIGFkdmFuY2UgZm9yIGFueSBhZHZpY2Ugb24g
d2hhdCB0byBkbyB3aXRoIHRoZXNlLCBtYXkgYmUgSSBtaXNzIA0Kc29tZXRoaW5nLg0KDQotLSAN
CkJlc3QgcmVnYXJkcywgVGlraG9taXJvdiBQYXZlbA0KU29mdHdhcmUgRGV2ZWxvcGVyLCBWaXJ0
dW96em8uDQo=

