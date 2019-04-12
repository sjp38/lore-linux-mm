Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05562C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:42:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9F6120818
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:42:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="kF+cMgRr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9F6120818
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 460176B000C; Fri, 12 Apr 2019 15:42:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E81A6B000D; Fri, 12 Apr 2019 15:42:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 262076B0010; Fri, 12 Apr 2019 15:42:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3C536B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 15:42:42 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 23so8886215qkl.16
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:42:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=I5+CUGpLOtOwV98jZ9lE/Cs0LjrA+X4NvVJ7fongJ7Y=;
        b=JVBqGbJOonI5ftmyPRD37bvUlgW0mb3PhuRYBgC1Tm84bNsS5UD9K/qWWZ5B4sukqM
         qDnwmQFfOWQsLnTs78NA3sILSwJmsslQGDju+BGJE8yvXg9iQB8ZZBBha7zFRbM0BgVk
         LtN4GR+Vo7Hbp4TmdlgcW1ZGSt55bm5iQyboudVafdLB+DRTT1+6XN04KX8CzEkTaYM6
         3cChIah0lcPqSAMW+VMsveW6ERQUqgdGmq+fVWDfhR1C6R856Sffwv1XJIckojmNL1st
         YwDWAGh73LFHahPRVXOxcmF7CrkeSaBp34d+2m+oVNmLrS/0IAyMF4YU5CmGwHNPIBMI
         jS6Q==
X-Gm-Message-State: APjAAAWrWkCZt3Xfnh2FWgFU9JHfCxqfseflcraneeJUPqV1Wfkx34Vg
	SyQ7ud85PHwDKLN+YOBgYZHSlcXMBpsYTVc4oXynmZyqqEs/Qn6isfd398wL4rPIwDEMdbIkOnr
	43obCP30YxnhTQSizVMaaSTZ5c7ngju998iRXm9lr4PMPTqY+l42dYI20WMNNL+N7oQ==
X-Received: by 2002:a37:4c85:: with SMTP id z127mr44557443qka.180.1555098162636;
        Fri, 12 Apr 2019 12:42:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBtwWYEylsm1TMPJ0huX3hcYagpepr9ox0iQpW45sNHg7xQr5iuzyXoe4cn8xDRvNVQcc/
X-Received: by 2002:a37:4c85:: with SMTP id z127mr44557390qka.180.1555098161919;
        Fri, 12 Apr 2019 12:42:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555098161; cv=none;
        d=google.com; s=arc-20160816;
        b=N9wmd8BhTAmbwY/lHuwnB1F8CmOFcpPgI3rwkzQrJ2/0S3cFXBrBBjcVEspitWGSI7
         W7CBNTN1A/BhxkgYNtB7dewA9Bcm9FYmFi3GxvHnyfLkGJZrpf4tipA1ueNCY30JyML7
         Md4c+162Llssxokck/kVAe9W3WEdagzqWEcY/syisdxt7jYTGZplv1k8ufXpV1LL4ot0
         4HGjrKgDOnx0dtis+Yucl4EuAkeKGdswzXLG1YbBOsNa3BOL5+ZwQciudHzg0KULcu6A
         U5p4xwWK/fLZCW4PbZfXVebTIV4MiA0gDYoAqMmd9cHRZvK7xODYVriT1HCxa9mSTf/N
         5d6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=I5+CUGpLOtOwV98jZ9lE/Cs0LjrA+X4NvVJ7fongJ7Y=;
        b=z7o3CrZys69qbQgDc4DopMH31/76CTi6X11qoG19IK1pEpDdLof1aqS+GqN85G5BPV
         tKXlbJKb6klYB041gC0dEk3hWCklj5ymtbJXPoeYmcLP55BrP5Ar1bt3BpsYUF6aOU0i
         hFRivUWGFQZrdwlGC4TvUMq9bkOOkpIgo1PUfuLhfqz9RzVK1366scaXfWjhsNpCGleC
         xaLixcV5zImgJr03qMAoSAHqu668Ji0tIGTd/hsU9m068ZG1NtJ/IMiMdtyEh1VO+74d
         j4jP+ANhyQCr7ogCK7cJB6bLS11uQ9GhvRCwwj8WKpSvmwzrSpkW5INpXEMVIOS2w6hn
         D7wQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=kF+cMgRr;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.75.80 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-eopbgr750080.outbound.protection.outlook.com. [40.107.75.80])
        by mx.google.com with ESMTPS id c20si488929qtb.35.2019.04.12.12.42.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 12 Apr 2019 12:42:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.75.80 as permitted sender) client-ip=40.107.75.80;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=kF+cMgRr;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.75.80 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=I5+CUGpLOtOwV98jZ9lE/Cs0LjrA+X4NvVJ7fongJ7Y=;
 b=kF+cMgRrYAcQTuVxKKEc8sOOYDVx64XtM7qNI1WKGFYEa9Exa1aOo68O01bna3S1ces0lzCAsc6C3z9yui2rG07YsmN6YRlcsml6cOGdVwwVBPlCJkr0bAgJSKicr7oYRBEWQwq3irHKrr1biR+Oe1yum7uh2JGlsE67D9wF80Y=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB5765.namprd05.prod.outlook.com (20.178.48.202) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.9; Fri, 12 Apr 2019 19:42:38 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::4140:b8f2:8e3:f5fd]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::4140:b8f2:8e3:f5fd%4]) with mapi id 15.20.1792.009; Fri, 12 Apr 2019
 19:42:38 +0000
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>
CC: kernel test robot <lkp@intel.com>, LKP <lkp@01.org>, Linux List Kernel
 Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>, Andy
 Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"):  BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
Thread-Topic: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"):  BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
Thread-Index: AQHU8R5sUhi0mJ9uO0aA/EiVew3tvaY4YIQAgABBN4CAADSSAIAAFzgA
Date: Fri, 12 Apr 2019 19:42:37 +0000
Message-ID: <721948C9-0E56-4E70-B9C5-58F0A4A5C126@vmware.com>
References: <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com>
 <20190411193906.GA12232@hirez.programming.kicks-ass.net>
 <20190411195424.GL14281@hirez.programming.kicks-ass.net>
 <20190411211348.GA8451@worktop.programming.kicks-ass.net>
 <20190412105633.GM14281@hirez.programming.kicks-ass.net>
 <20190412111756.GO14281@hirez.programming.kicks-ass.net>
 <F18AF0D5-D8B4-4F4B-8469-F9DEC49683C7@vmware.com>
 <20190412181930.GD12232@hirez.programming.kicks-ass.net>
In-Reply-To: <20190412181930.GD12232@hirez.programming.kicks-ass.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 24ec8546-22a2-4769-3dbd-08d6bf7f04cd
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB5765;
x-ms-traffictypediagnostic: BYAPR05MB5765:
x-microsoft-antispam-prvs:
 <BYAPR05MB5765D9F6E536811F1A69173ED0280@BYAPR05MB5765.namprd05.prod.outlook.com>
x-forefront-prvs: 0005B05917
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(136003)(366004)(39860400002)(376002)(346002)(189003)(199004)(4744005)(446003)(68736007)(6486002)(11346002)(6512007)(256004)(476003)(53936002)(2616005)(66066001)(486006)(82746002)(229853002)(6436002)(6246003)(14454004)(105586002)(106356001)(478600001)(93886005)(33656002)(97736004)(26005)(5660300002)(8676002)(81166006)(81156014)(6916009)(8936002)(86362001)(54906003)(305945005)(186003)(316002)(7736002)(53546011)(6506007)(99286004)(83716004)(7416002)(71190400001)(3846002)(71200400001)(4326008)(2906002)(76176011)(6116002)(25786009)(36756003)(102836004)(41533002);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB5765;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 I3DKf6ZNQHpWpNko/9CpXNTY+ePYLL6q0Lx1VEafuNb+HUtVcnt4wm/gMElG0mi+/ag7WJhl0zUllkuE+5hoTof2h33LOecqkqykFuzf16qaGlbHHjP2r6UOrTj8ckpl/ERNwJ+8d1ZZl6mRxubnkFISVgbjgwZ7goKPeMQvsVOrw7YEBA3vDM/HNsMW8IkdPRNCXduN0olY9g7Nhkt5Qvvtc6DMU3pZKH/IvfzGY5IEZY5t1IeNDHehERbY+7bnn6ATY25I82//Ypxl+Xz2rMrooSYpI08iPHTXwF9TnNBl20GVLwONl2SPmtUQwpEV1nSZtrON81aN/pQAEOLjXFo9e8hHUcFClYiKMpAfb3thQBByOKXu6Loz6CppTRYRQUMKK/1AxabadXQOWmdHnCZpHJYn2s3d25PPQWGpzkk=
Content-Type: text/plain; charset="utf-8"
Content-ID: <B2CC06664A851F43A6C8D26D535F1709@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 24ec8546-22a2-4769-3dbd-08d6bf7f04cd
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Apr 2019 19:42:37.9793
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB5765
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBBcHIgMTIsIDIwMTksIGF0IDExOjE5IEFNLCBQZXRlciBaaWpsc3RyYSA8cGV0ZXJ6QGlu
ZnJhZGVhZC5vcmc+IHdyb3RlOg0KPiANCj4gT24gRnJpLCBBcHIgMTIsIDIwMTkgYXQgMDM6MTE6
MjJQTSArMDAwMCwgTmFkYXYgQW1pdCB3cm90ZToNCj4+PiBPbiBBcHIgMTIsIDIwMTksIGF0IDQ6
MTcgQU0sIFBldGVyIFppamxzdHJhIDxwZXRlcnpAaW5mcmFkZWFkLm9yZz4gd3JvdGU6DQo+IA0K
Pj4+IFRvIGNsYXJpZnksICd0aGF0JyBpcyBOYWRhdidzIHBhdGNoOg0KPj4+IA0KPj4+IDUxNWFi
N2M0MTMwNiAoIng4Ni9tbTogQWxpZ24gVExCIGludmFsaWRhdGlvbiBpbmZvIikNCj4+PiANCj4+
PiB3aGljaCB0dXJucyBvdXQgdG8gYmUgdGhlIHJlYWwgcHJvYmxlbS4NCj4+IA0KPj4gU29ycnkg
Zm9yIHRoYXQuIEkgc3RpbGwgdGhpbmsgaXQgc2hvdWxkIGJlIGFsaWduZWQsIGVzcGVjaWFsbHkg
d2l0aCBhbGwgdGhlDQo+PiBlZmZvcnQgdGhlIEludGVsIHB1dHMgYXJvdW5kIHRvIGF2b2lkIGJ1
cy1sb2NraW5nIG9uIHVuYWxpZ25lZCBhdG9taWMNCj4+IG9wZXJhdGlvbnMuDQo+IA0KPiBObyBh
dG9taWNzIGFueXdoZXJlIGluIHNpZ2h0LCBzbyB0aGF0J3Mgbm90IGEgY29uY2Vybi4NCg0KWW91
IGFyZSByaWdodC4gSSBzdGlsbCB0aGluayB0aGF0IGF0IGxlYXN0IFRMQi13aXNlIGl0IHNob3Vs
ZCBiZSBiZXR0ZXIgdG8NCmhhdmUgdGhlIGFyZ3VtZW50IG9mZi1zdGFjay4gSeKAmWxsIHRyeSB0
byBydW4gc29tZSBleHBlcmltZW50cywgYmFzZWQgb24NCnlvdXIgZmVlZGJhY2ssIGFuZCBzZW5k
IGEgcGF0Y2ggb24gdG9wIG9mIHlvdXIgcmV2ZXJ0Lg0KDQpTb3JyeSBmb3IgdGhlIG1lc3MsIGFn
YWluLg0KDQoNCg==

