Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73C5CC73C6D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 06:14:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1204F2064A
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 06:14:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=os.amperecomputing.com header.i=@os.amperecomputing.com header.b="gZgPJvbE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1204F2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4AA48E0069; Wed, 10 Jul 2019 02:14:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FA538E0032; Wed, 10 Jul 2019 02:14:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C2E68E0069; Wed, 10 Jul 2019 02:14:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6848E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 02:14:27 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id j81so1058092qke.23
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 23:14:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=9g1lBb0bDtADPgbIBk0VMonLJceDG+gkmXYT0LxGevY=;
        b=dWi7DhDnNZNNjfzfwI+bASt/nMK+WCzSK230C+eMtgv1KNDTIW7BaLp/jnkEVg6YFC
         clT4eBrcjDBuUoxJqQdMahAsLIBCVxRZVQ+bkukUJJn7TOJtFvy/iiJaMs93f4uX7wh8
         PF6oTHmeGR7eDhwwCBYfpTb+n1koATaw03jsZmWBfS3TwjiEOl8EAUc5DK4MFfBJ6QpL
         GMKWuBwj0cwlKSDqgqGVxi03QrVdlIB9pDE3Djc4wy3222hcbp0GCgiRrnDO3Wcw7+wm
         Rgwpy4E5RJYEr072PmFfXbhn+LbtTzEt1sl7I8mqwERdANQvNL9AWEAmMUethAYSVB7H
         NKmg==
X-Gm-Message-State: APjAAAVFv7wQ3LSzDm9PJFu8xSKG6JIWBq6DkCAmlaA2T/2YM2e2l099
	x2SqjYrHvxsXbV6DgGgPt7H5QicSyXEaWx85HJzQGn43muhAzc/OD5zId6uuvriMN0/Ah1Z6kNc
	Flax2qBUryCdRKqRxhqRRKW4zW93YT337hdzsjLSKOFZHCXLqNBSZKjK2mVFt2JGG5Q==
X-Received: by 2002:a0c:aede:: with SMTP id n30mr5629584qvd.152.1562739267168;
        Tue, 09 Jul 2019 23:14:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+HBNKdEVyGa4Ud6QMMlmK3quUaP7YaO3Dpd8tdyPEDT08fExtDIoc7OIiQCDT2kMTOLVp
X-Received: by 2002:a0c:aede:: with SMTP id n30mr5629568qvd.152.1562739266638;
        Tue, 09 Jul 2019 23:14:26 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1562739266; cv=pass;
        d=google.com; s=arc-20160816;
        b=HX+jqZe9J+qNTywghSmNqsr2xUFyiANjHL7pkfua8KJjSeWz94eYupDZ7n3bWHRUOl
         alNhNXIfZHzBpxO0dZS7H0GhYTDVabuLewtuqptzrzvqaAHMdTf9fF7qIfpqOT8Gxy4D
         yvF2HQOhhwa2keTzEE5wn589zGToSvd3uDerktdtXfDTnhS4YtroDerMRYCtz/DpuOrS
         8U95YNOBYJC1TUWmUGnXH/uRuNeswjdPHUuBbNt2889IlKwU38Cx9ZwlcIOZWLIvD+oC
         uBKbQb0tfHkfvyTnv1ykaaocOo8hCrHfaeIv8Oha+kDhkADrQKnpkNk1KVPCEeBuIkOt
         bYmw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=9g1lBb0bDtADPgbIBk0VMonLJceDG+gkmXYT0LxGevY=;
        b=bqsWAwCX1FNOKcYEynwqGyDyh16veFAn7GwYiGM+UmujskhjgdACe/HaSyM8Uk4Vze
         Mm/GzLILlwWiX9XstPs6pJDo05G1xbP56fwM0mXvQ/uH7CrP1eexDs7nG82Egq6UdUxE
         lDzjhziiUgpgiKKxTKgR+BEUKBDSZv3WTmV/liFqzuNjbt504JnA/5TCsvgY1zh3sNPb
         r5pDB/CHgwZjG4DtDo4dxjuAnwMkXHjpPNLVXd5bqcS1/eHSQCpfHzWW69S7raY3QQ8A
         V2YaOhx3FlQWbnNDTBVSsoXTMUzfH0u3PZDNLO7IfDvOobaXEf4WtP4KxYgmoUfxwKi9
         do3g==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=gZgPJvbE;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.74.90 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740090.outbound.protection.outlook.com. [40.107.74.90])
        by mx.google.com with ESMTPS id z15si1095833qtz.185.2019.07.09.23.14.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Jul 2019 23:14:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.74.90 as permitted sender) client-ip=40.107.74.90;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=gZgPJvbE;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.74.90 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=CB59O9DSuXg8zohOMHP+9hfqBpWgnXWURBlZvVfxfSSENk6u5KFXMtJaOm7EKMDC6bY5ivoQ3LcJMUK1+lQ541pNns5oAdTp2ACweIPEUpVGVu52Q9CvGbPFCo822uU7VLJnYsRZ/T4rOFKomwAmbyJjnvOGuvff6MxmdSsaDQtsU0Be8jYkdqTK9uJe+VRjOYV3TRiA70Wgd0VWKYOnVtQHlTqVFLQkR5iVWnb4Nw9zpDy4OU+2NIjF37ZS13jP1aoRLhkJJA4lNoCWDHe7CXWgFEUqbGJWtHCdkb5AaDi0ZI6AmnjqIFQWtBB71zrqeXVuLDuGNDxOWOioehVy/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9g1lBb0bDtADPgbIBk0VMonLJceDG+gkmXYT0LxGevY=;
 b=gaQzI5CR1wJGPrvh3fWKtgNA1lUnD+gH4q3jUIGJcKVz/GDY5dlkAujstiAsdftGFhu6mQ+RDshZOTXSjXo4uTVXIoUtGWSsHPLfa/tLYDGVY/mzcBiQbsN+3SrA857DI/D2UPIjAj3mmiVMKHoPE0HsyEvtNvdGmdg1dLdfY92XZb5NgLxWWNSWlLifcmOhYmZzx6cedyRTV6bkZopahExrdOYHj9oRSIR8r2hMupnGigHBUZMbsRtXb7MVLNFCCtJcrgzAjDwhHr6LTvqF4+sXD4gsw5CZ4Jb8oqVqGjrScNP6WQ8YkaqeeBCMR26TvaE2HgCTjjmEU2oQjWujfw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=os.amperecomputing.com;dmarc=pass action=none
 header.from=os.amperecomputing.com;dkim=pass
 header.d=os.amperecomputing.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=os.amperecomputing.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9g1lBb0bDtADPgbIBk0VMonLJceDG+gkmXYT0LxGevY=;
 b=gZgPJvbEWGgJt54AhIa/SjeQf/Drki9xhBLAU+FZmFlxmqVmr1gFHEoySgFEyHS6kp+0POFrSwNhj0AuzyQKu/BmkeQ5I+vXrsOmjfz+2WNVVoPThu3E5zOU00hEcIgxIQeXryaVHGskcGl+9nPsLNoOOfkUC/Ay22jZHQaEeHw=
Received: from BYAPR01MB4085.prod.exchangelabs.com (52.135.237.22) by
 BYAPR01MB3927.prod.exchangelabs.com (52.135.195.17) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2073.10; Wed, 10 Jul 2019 06:14:24 +0000
Received: from BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80]) by BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80%7]) with mapi id 15.20.2052.020; Wed, 10 Jul 2019
 06:14:23 +0000
From: Hoan Tran OS <hoan@os.amperecomputing.com>
To: Thomas Gleixner <tglx@linutronix.de>
CC: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
	<will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal
 Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador
	<osalvador@suse.de>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Mike
 Rapoport <rppt@linux.ibm.com>, Alexander Duyck
	<alexander.h.duyck@linux.intel.com>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael
 Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@redhat.com>, Borislav
 Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, "David S . Miller"
	<davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily
 Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-s390@vger.kernel.org"
	<linux-s390@vger.kernel.org>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Open Source
 Submission <patches@amperecomputing.com>
Subject: Re: [PATCH 3/5] x86: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Topic: [PATCH 3/5] x86: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Index: AQHVK6WX71HRsQts10W3HaW79T6UP6as+COAgBWploCAAM/wgIAABGyA
Date: Wed, 10 Jul 2019 06:14:23 +0000
Message-ID: <50032a84-9453-8ab3-8d42-5bd8c1504640@os.amperecomputing.com>
References: <1561501810-25163-1-git-send-email-Hoan@os.amperecomputing.com>
 <1561501810-25163-4-git-send-email-Hoan@os.amperecomputing.com>
 <alpine.DEB.2.21.1906260032250.32342@nanos.tec.linutronix.de>
 <1c5bc3a8-0c6f-dce3-95a2-8aec765408a2@os.amperecomputing.com>
 <alpine.DEB.2.21.1907100755010.1758@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1907100755010.1758@nanos.tec.linutronix.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CY4PR06CA0028.namprd06.prod.outlook.com
 (2603:10b6:903:77::14) To BYAPR01MB4085.prod.exchangelabs.com
 (2603:10b6:a03:56::22)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=hoan@os.amperecomputing.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [27.68.67.201]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1d28e77e-328a-4b52-10e8-08d704fdda51
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR01MB3927;
x-ms-traffictypediagnostic: BYAPR01MB3927:
x-microsoft-antispam-prvs:
 <BYAPR01MB39270A08E415E78ED4090157F1F00@BYAPR01MB3927.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0094E3478A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(346002)(376002)(136003)(396003)(366004)(39840400004)(199004)(189003)(54534003)(305945005)(476003)(486006)(446003)(11346002)(2616005)(6512007)(6486002)(71200400001)(6246003)(107886003)(71190400001)(53936002)(6436002)(229853002)(31686004)(81166006)(25786009)(81156014)(8676002)(478600001)(8936002)(7736002)(256004)(6916009)(4326008)(68736007)(14454004)(3846002)(31696002)(99286004)(66476007)(76176011)(64756008)(66556008)(66946007)(52116002)(66446008)(26005)(186003)(316002)(102836004)(7416002)(53546011)(6116002)(386003)(6506007)(86362001)(54906003)(5660300002)(66066001)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR01MB3927;H:BYAPR01MB4085.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:0;MX:1;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 ukd5q2O0kG1P7Fa8HN5gD4Wne0noqQrCX22aDCdhndEtGDAnPvruESK/Fva9oBjMrk1XackbtuG0mTunHgv8CyIa/UZHkgTXqwSMmTFVnZdg2ZFr7cbFnCGD7W9fTnUdbyiVBehrWWaXBn2LEmO8GuSkOMSzB7yIlMEc3y80CYsStJoCs7f0b8tsB+sCC2ArGeDbYgcd8yGLNeDsWkkzY01U2mTfklP4v7i67kjMZKOWucYepAzDUGQJE9oRSS9y+wSyZB94qY+/1IBfLf4N2VzjdVdrX0Bb4cAVAqeqoEj+TPFYAH+te/ZUL2eBW5NBiH4lEzVquDIr1kWgdIpOYG8NQIrjGmfc7yqEMXiXFHQSkfx1cJWUFW/eOnfxnYvMMWnhJH7JfBw7JTTRsqvV+0kDGcAdPHSqmcd3lR4Hjk4=
Content-Type: text/plain; charset="utf-8"
Content-ID: <8083A5B2C8C78E4686C4EDE0FC38BDB0@prod.exchangelabs.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1d28e77e-328a-4b52-10e8-08d704fdda51
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 Jul 2019 06:14:23.6394
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3bc2b170-fd94-476d-b0ce-4229bdc904a7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Hoan@os.amperecomputing.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR01MB3927
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgVGhvbWFzLA0KDQoNCk9uIDcvMTAvMTkgMTI6NTggUE0sIFRob21hcyBHbGVpeG5lciB3cm90
ZToNCj4gSG9hbiwNCj4gDQo+IE9uIFdlZCwgMTAgSnVsIDIwMTksIEhvYW4gVHJhbiBPUyB3cm90
ZToNCj4+IE9uIDYvMjUvMTkgMzo0NSBQTSwgVGhvbWFzIEdsZWl4bmVyIHdyb3RlOg0KPj4+IE9u
IFR1ZSwgMjUgSnVuIDIwMTksIEhvYW4gVHJhbiBPUyB3cm90ZToNCj4+Pj4gQEAgLTE1NjcsMTUg
KzE1NjcsNiBAQCBjb25maWcgWDg2XzY0X0FDUElfTlVNQQ0KPj4+PiAgICAJLS0taGVscC0tLQ0K
Pj4+PiAgICAJICBFbmFibGUgQUNQSSBTUkFUIGJhc2VkIG5vZGUgdG9wb2xvZ3kgZGV0ZWN0aW9u
Lg0KPj4+PiAgICANCj4+Pj4gLSMgU29tZSBOVU1BIG5vZGVzIGhhdmUgbWVtb3J5IHJhbmdlcyB0
aGF0IHNwYW4NCj4+Pj4gLSMgb3RoZXIgbm9kZXMuICBFdmVuIHRob3VnaCBhIHBmbiBpcyB2YWxp
ZCBhbmQNCj4+Pj4gLSMgYmV0d2VlbiBhIG5vZGUncyBzdGFydCBhbmQgZW5kIHBmbnMsIGl0IG1h
eSBub3QNCj4+Pj4gLSMgcmVzaWRlIG9uIHRoYXQgbm9kZS4gIFNlZSBtZW1tYXBfaW5pdF96b25l
KCkNCj4+Pj4gLSMgZm9yIGRldGFpbHMuDQo+Pj4+IC1jb25maWcgTk9ERVNfU1BBTl9PVEhFUl9O
T0RFUw0KPj4+PiAtCWRlZl9ib29sIHkNCj4+Pj4gLQlkZXBlbmRzIG9uIFg4Nl82NF9BQ1BJX05V
TUENCj4+Pg0KPj4+IHRoZSBjaGFuZ2Vsb2cgZG9lcyBub3QgbWVudGlvbiB0aGF0IHRoaXMgbGlm
dHMgdGhlIGRlcGVuZGVuY3kgb24NCj4+PiBYODZfNjRfQUNQSV9OVU1BIGFuZCB0aGVyZWZvcmUg
ZW5hYmxlcyB0aGF0IGZ1bmN0aW9uYWxpdHkgZm9yIGFueXRoaW5nDQo+Pj4gd2hpY2ggaGFzIE5V
TUEgZW5hYmxlZCBpbmNsdWRpbmcgMzJiaXQuDQo+Pj4NCj4+DQo+PiBJIHRoaW5rIHRoaXMgY29u
ZmlnIGlzIHVzZWQgZm9yIGEgTlVNQSBsYXlvdXQgd2hpY2ggTlVNQSBub2RlcyBhZGRyZXNzZXMN
Cj4+IGFyZSBzcGFubmVkIHRvIG90aGVyIG5vZGVzLiBJIHRoaW5rIDMyYml0IE5VTUEgYWxzbyBo
YXZlIHRoZSBzYW1lIGlzc3VlDQo+PiB3aXRoIHRoYXQgbGF5b3V0LiBQbGVhc2UgY29ycmVjdCBt
ZSBpZiBJJ20gd3JvbmcuDQo+IA0KPiBJJ20gbm90IHNheWluZyB5b3UncmUgd3JvbmcsIGJ1dCBp
dCdzIHlvdXIgZHV0eSB0byBwcm92aWRlIHRoZSBhbmFseXNpcyB3aHkNCj4gdGhpcyBpcyBjb3Jy
ZWN0IGZvciBldmVyeXRoaW5nIHdoaWNoIGhhcyBOVU1BIGVuYWJsZWQuDQo+IA0KPj4+IFRoZSBj
b3JlIG1tIGNoYW5nZSBnaXZlcyBubyBoZWxwZnVsIGluZm9ybWF0aW9uIGVpdGhlci4gWW91IGp1
c3QgY29waWVkIHRoZQ0KPj4+IGFib3ZlIGNvbW1lbnQgdGV4dCBmcm9tIHNvbWUgcmFuZG9tIEtj
b25maWcuDQo+Pg0KPj4gWWVzLCBhcyBpdCdzIGEgY29ycmVjdCBjb21tZW50IGFuZCBpcyB1c2Vk
IGF0IG11bHRpcGxlIHBsYWNlcy4NCj4gDQo+IFdlbGwgaXQgbWF5YmUgY29ycmVjdCBpbiB0ZXJt
cyBvZiBleHBsYWluaW5nIHdoYXQgdGhpcyBpcyBhYm91dCwgaXQgc3RpbGwNCj4gZG9lcyBub3Qg
ZXhwbGFpbiB3aHkgdGhpcyBpcyBuZWVkZWQgYnkgZGVmYXVsdCBvbiBldmVyeXRoaW5nIHdoaWNo
IGhhcyBOVU1BDQo+IGVuYWJsZWQuDQoNCkxldCBtZSBzZW5kIGFub3RoZXIgcGF0Y2ggd2l0aCB0
aGUgZGV0YWlsIGV4cGxhbmF0aW9uLg0KDQpUaGFua3MNCkhvYW4NCg0KPiANCj4gVGhhbmtzLA0K
PiANCj4gCXRnbHgNCj4gDQo=

