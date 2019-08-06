Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A223BC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:47:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F5B3208C3
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:47:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=os.amperecomputing.com header.i=@os.amperecomputing.com header.b="TC7OSRko"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F5B3208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85CE76B026C; Tue,  6 Aug 2019 12:47:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80BFA6B026F; Tue,  6 Aug 2019 12:47:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 686D46B0270; Tue,  6 Aug 2019 12:47:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 183F86B026C
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:47:23 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so54282154edr.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:47:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=1q4pi+o5btussKVzkefj+dnCarsO1mLnz4hoIdPDodU=;
        b=G6Vta5vPdo0PH6+ozy0oYvzHtEexqTxvbTVrgTkUxQlWs/k9Qg8Pp86V8S1Zj9e+JC
         KhLnU6CpfgQn+dyUftzDR1B2ZRUSZgqdDkDSCU/YO13JBkgzRJD5WmT3qi3TmQ/7obH2
         PPJkQqDg8JN+k+KFzYOzB14xkaOh96XI5LAYyuLeTNvS8JUVTwCy1wPdGxbRE3jno2t+
         A1wLuc41d8K9bisHjGcC5a/hmaPxfZqu0riyjVqfrVY4gl9tjobd7wfDIRLQPAZPTnqs
         FRx9nj+hy8oZ3jjeeEPqb6nywgfEPkkKZqqzVYpp/8gLj74fPjDVL/LjlpSJKxUD0mrq
         UrZw==
X-Gm-Message-State: APjAAAXjh6eEp0qDtXWGu82iVP9Y27XBL1b1DO8ouBNPB2Pqe+I6p4CG
	muY+GfrC9GLzWOBnGi0ZYTDxjXC9V3gKDip2tRU2S2pRkzPYDkTQgpUjZ1V4JfBmKuYpRB+WI+J
	Wxf2XrP2XAaRmBbtaC6NqsLjnW/V6XecopoYjUIQenkiGptzHUjzK9gyOHnUJ0ysONw==
X-Received: by 2002:a17:906:9410:: with SMTP id q16mr4219980ejx.90.1565110042456;
        Tue, 06 Aug 2019 09:47:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybQSerbpk/pqawuVY673aYzPHrr2zfKSzxSNYNE+SNQQ1hgCh2BkbjgAwg04Jhc7WsKaCH
X-Received: by 2002:a17:906:9410:: with SMTP id q16mr4219922ejx.90.1565110041571;
        Tue, 06 Aug 2019 09:47:21 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565110041; cv=pass;
        d=google.com; s=arc-20160816;
        b=KXBQQiwHB6kfxZ1f87H1sInfIEoFYXJSvGeAuYbftpFfo8yPByP91gpWlaWYZmPxLV
         6CydYuSUV/u/UVC8kjoxoFtpi7Rq9NfSY01xs9NhMzqBNqYDfgzpBHxrWFXT/8O7JKsE
         jF53RWf5ggIMRd+PORbTKhfisfXuia0rIssZzY3U9pp/c6mIqLUsx6/efQnXM522/LT2
         N5o+xZAUZBpsMuI2InfnQVorj9Cjzu2FPymmwwZaZiMZUyoja+jy2mCOApR52AeoIn6I
         tFNeuqIO8cL1z2jm8Vh9GASmjLHQ4wvcEBgGsdg7tow7ng/V6rVTw75cvbyEogOStXn0
         1mmQ==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=1q4pi+o5btussKVzkefj+dnCarsO1mLnz4hoIdPDodU=;
        b=drw99Etlt5Qtn81OhK/ZDimy93lrFlMj/YFurFiGF8atxyCDhb/nNX1Z/gwwlAK6jE
         YZcfceAfuUrWyEgMA4R89H3oMlrNFotQZoJV6VAwb/Ds3lPrif3AEUFataTBKUDYV48c
         yqZbD5f6P7ax0h8X8fs7yPfhn3mz1alQtr4GjTb2pgmMED5LH8Ts4o0xbE0wNzjWEPqh
         FmYUtTj8I9Wn+7od+kTda1lPA2bj+btcSBmTghctAIvlOjM7Kgft5YhFU6ucjRAT6Tgb
         r59xVLP6C7Pt5CKk79ct1xw9ip7lNOKga904mLONbbg41R5h59xoEpZyQqS5HQIovxhR
         Knew==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=TC7OSRko;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.73.123 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (mail-eopbgr730123.outbound.protection.outlook.com. [40.107.73.123])
        by mx.google.com with ESMTPS id t21si30086667edw.253.2019.08.06.09.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 09:47:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.73.123 as permitted sender) client-ip=40.107.73.123;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=TC7OSRko;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.73.123 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=WAAQZ5U9VK0nfqnww9K6q3aXKU5H2jEtvHmZBhATJUQo7r1cwj2XZiQ6wpMCsRtWbbklKHomDc3b7+piseMzuoHl1qaVLX7lbG8/dNg1Nhf/bGeZ7z2UXGvZ4kACizEMsvgROQ1zjwxBChtE9awrQLQkaXKhRLHwuHSw20jj1pfUQJdaIROZMa/VlRAY71dHI/jlZQqg2kzcsEPvnEK00YYkrobq+HsexkcDhI5q1ce+5SQ6ZEWc2Rjrj8xQKeKf2f8flcc6GuIWVh27Afs04XuthPhYDvWHOxvED3WcC+bQFjG4Wgot4AIu9BwV9InpnnsljTF/T/j1iw96X0/Qow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1q4pi+o5btussKVzkefj+dnCarsO1mLnz4hoIdPDodU=;
 b=IxSukqaw9/jYzlehclZ3kPJlr49jQXuqDhSv2MIh0+Sy6uEDWEIia/igYSIFIo+ImI2S3afB/pwYG36GO/AANadKN2+G234qmPydOFXZ71SK4IU2hxYIrMeMtaLHvnCohrnKaPUtejLCREFpJwmE2ryN9NrZ2/rAcRHWFGZ3+f/gPgSa4Sq+iN3S+ddwvOLn6GmxsXPdLar2lkhTq/2KNPTPNXE5hXP0Uy4DeZKgQ90ZIXtRZ8xyHwI8EH4tJOJXGCBNnqXAtDlz/WSxeboqBW0d7fZ8nhgv47MsxEZfMNBqrmCA09KrcC9sGRCxuY3Rcz2tHPymzKzQwIJNz3mB3w==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=os.amperecomputing.com; dmarc=pass action=none
 header.from=os.amperecomputing.com; dkim=pass
 header.d=os.amperecomputing.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=os.amperecomputing.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1q4pi+o5btussKVzkefj+dnCarsO1mLnz4hoIdPDodU=;
 b=TC7OSRkoTwLBAfNE+1PMd8V1wo35CPIfx6smg0BqvOCvElobRUYcbkMZU6cN9vZUYo+unKDBr6G+2BW+InX3roFjvN2mJcSC+Adn9kI1A5HU0tbrNCyfb1LufSTvr4WC2ugW+1mv1OJOkkcgYHUek0mZV2AxmerRs6ZyiyvM/1s=
Received: from DM6PR01MB4090.prod.exchangelabs.com (20.176.105.203) by
 DM6PR01MB5433.prod.exchangelabs.com (20.179.55.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.13; Tue, 6 Aug 2019 16:47:12 +0000
Received: from DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::612a:862d:745e:ba9a]) by DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::612a:862d:745e:ba9a%3]) with mapi id 15.20.2136.018; Tue, 6 Aug 2019
 16:47:12 +0000
From: Hoan Tran OS <hoan@os.amperecomputing.com>
To: Thomas Gleixner <tglx@linutronix.de>, Catalin Marinas
	<catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>, Pavel
 Tatashin <pavel.tatashin@microsoft.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, Benjamin Herrenschmidt
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
Subject: Re: [PATCH v2 3/5] x86: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Topic: [PATCH v2 3/5] x86: Kconfig: Remove
 CONFIG_NODES_SPAN_OTHER_NODES
Thread-Index: AQHVOD/6mMbG4b3xtkKwY5B+a64PmqbMCfcAgCJyqYA=
Date: Tue, 6 Aug 2019 16:47:12 +0000
Message-ID: <910accd6-c491-acfd-237a-97edec7c0b42@os.amperecomputing.com>
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
 <1562887528-5896-4-git-send-email-Hoan@os.amperecomputing.com>
 <alpine.DEB.2.21.1907152042110.1767@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1907152042110.1767@nanos.tec.linutronix.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CY4PR1101CA0013.namprd11.prod.outlook.com
 (2603:10b6:910:15::23) To DM6PR01MB4090.prod.exchangelabs.com
 (2603:10b6:5:27::11)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=hoan@os.amperecomputing.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [4.28.12.214]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c93d5fa5-ac1f-49fd-a8ac-08d71a8dbab7
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR01MB5433;
x-ms-traffictypediagnostic: DM6PR01MB5433:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs:
 <DM6PR01MB5433497C54778940D6030A34F1D50@DM6PR01MB5433.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0121F24F22
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(346002)(376002)(396003)(136003)(39840400004)(366004)(189003)(199004)(6486002)(476003)(2616005)(305945005)(25786009)(31696002)(102836004)(7736002)(229853002)(86362001)(446003)(8936002)(6246003)(4326008)(107886003)(81156014)(14454004)(81166006)(2906002)(256004)(6512007)(186003)(68736007)(53936002)(8676002)(11346002)(26005)(478600001)(31686004)(52116002)(99286004)(110136005)(54906003)(6116002)(76176011)(3846002)(5660300002)(6436002)(66066001)(316002)(66446008)(7416002)(386003)(6506007)(71190400001)(71200400001)(53546011)(486006)(64756008)(66476007)(66556008)(66946007);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR01MB5433;H:DM6PR01MB4090.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:0;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 3TNs1b7ZsCFx1KxEXxgLO/GCjIDmgIU/jlKbs0U+kgzd9i6WRN6dNfv4Gf3J3G0MZSYUE7dA+M3jjAWnvRUJ0RZQQWkN886BBHkiSeOAzCI4jjOvaxwfp5w/v/NkdgdbLHnSFHCW6WUBS1tFEZfkLwOrtdnQvfDfHYmO04FVUGfTzFQCiA27szJBnvOxCq1/poAnprv++8NnMrI06RFlRJh0mf9opefB1QedOZqqroxlAjaX33JXsxqTzX9ClLWqCo/FCTx9hDgCMXxHV28K6SVbDltdJj+xxjpqg3Jmc4+b6S9g6Nwx9SDFTgCtgYL9mmg5dtj+aY3L76q32j+gCi/AwETvA4FarogJcurviSS56JG8TS8Oy5NhzNcK9B28yk1IkcXJVFlPpVnZMjBZr9Lpwz+STX1tQbG68YienVM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <56E2A1BBE7566D44917A8A23D9C7B097@prod.exchangelabs.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c93d5fa5-ac1f-49fd-a8ac-08d71a8dbab7
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Aug 2019 16:47:12.6231
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3bc2b170-fd94-476d-b0ce-4229bdc904a7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Hoan@os.amperecomputing.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR01MB5433
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgVGhvbWFzLA0KDQoNCk9uIDcvMTUvMTkgMTE6NDMgQU0sIFRob21hcyBHbGVpeG5lciB3cm90
ZToNCj4gT24gVGh1LCAxMSBKdWwgMjAxOSwgSG9hbiBUcmFuIE9TIHdyb3RlOg0KPiANCj4+IFJl
bW92ZSBDT05GSUdfTk9ERVNfU1BBTl9PVEhFUl9OT0RFUyBhcyBpdCdzIGVuYWJsZWQNCj4+IGJ5
IGRlZmF1bHQgd2l0aCBOVU1BLg0KPiANCj4gQXMgSSB0b2xkIHlvdSBiZWZvcmUgdGhpcyBkb2Vz
IG5vdCBtZW50aW9uIHRoYXQgdGhlIG9wdGlvbiBpcyBub3cgZW5hYmxlZA0KPiBldmVuIGZvciB4
ODYoMzJiaXQpIGNvbmZpZ3VyYXRpb25zIHdoaWNoIGRpZCBub3QgZW5hYmxlIGl0IGJlZm9yZSBh
bmQgZG9lcw0KPiBub3QgbG9uZ2VyIGRlcGVuZCBvbiBYODZfNjRfQUNQSV9OVU1BLg0KDQpBZ3Jl
ZWQsIGxldCBtZSBhZGQgaXQgaW50byB0aGlzIHBhdGNoIGRlc2NyaXB0aW9uLg0KDQo+IA0KPiBB
bmQgdGhlcmUgaXMgc3RpbGwgbm8gcmF0aW9uYWxlIHdoeSB0aGlzIG1ha2VzIHNlbnNlLg0KPiAN
Cg0KQXMgd2Uga25vdyBhYm91dCB0aGUgbWVtbWFwX2luaXRfem9uZSgpIGZ1bmN0aW9uLCBpdCBp
cyB1c2VkIHRvIA0KaW5pdGlhbGl6ZSBhbGwgcGFnZXMuIER1cmluZyBpbml0aWFsaXppbmcsIGVh
cmx5X3Bmbl9pbl9uaWQoKSBmdW5jdGlvbiANCm1ha2VzIHN1cmUgdGhlIHBhZ2UgaXMgaW4gdGhl
IHNhbWUgbm9kZSBpZC4gT3RoZXJ3aXNlLCANCm1lbW1hcF9pbml0X3pvbmUoKSBvbmx5IGNoZWNr
cyB0aGUgcGFnZSB2YWxpZGl0eS4gSXQgd29uJ3Qgd29yayB3aXRoIA0Kbm9kZSBtZW1vcnkgc3Bh
bnMgYWNyb3NzIHRoZSBvdGhlcnMuDQoNClRoZSBvcHRpb24gQ09ORklHX05PREVTX1NQQU5fT1RI
RVJfTk9ERVMgaXMgb25seSB1c2VkIHRvIGVuYWJsZSANCmVhcmx5X3Bmbl9pbl9uaWQoKSBmdW5j
dGlvbi4NCg0KSXQgb2NjdXJzIGR1cmluZyBib290LXRpbWUgYW5kIHdvbid0IGFmZmVjdCB0aGUg
cnVuLXRpbWUgcGVyZm9ybWFuY2UuDQpBbmQgSSBzYXcgdGhlIG1ham9yaXR5IE5VTUEgYXJjaGl0
ZWN0dXJlcyBlbmFibGUgdGhpcyBvcHRpb24gYnkgZGVmYXVsdCANCndpdGggTlVNQS4NCg0KVGhh
bmtzIGFuZCBSZWdhcmRzDQpIb2FuDQoNCg0KPiBUaGFua3MsDQo+IA0KPiAJdGdseA0KPiANCg==

