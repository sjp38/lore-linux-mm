Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B71EAC31E5C
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 02:02:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6256E2080C
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 02:02:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="mhAG8Elh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6256E2080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D7F06B0005; Mon, 17 Jun 2019 22:02:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 062088E0003; Mon, 17 Jun 2019 22:02:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E45048E0001; Mon, 17 Jun 2019 22:02:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 902A66B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 22:02:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r21so18925973edp.11
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 19:02:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=x2wpQ4AhiN7KRVspeIae1sst5lVNYjKBsjHdOpOWzvg=;
        b=onHWR+WKJb4KCX6Q+pPgT62G8WzNzYHL3rqljpOaYWHQFozdefWLlS9inqt3bPn5TY
         kVrj2e0h829Tg1KQJnZybM2kC/Y36h36S9tTQRXRKRCR1UeW55du7ORHTrZMpQG0cabT
         ZzMDx3EREfPrPydyd5KHOsnI8eHDMGBiV+Hs8OqP/UZz8aa8efMD/Onvo6+QIAQFPl8I
         W5QsG29IDtHRJbUJ3AQld2bAeglQE/HvhEC0XibD7FV5izcnnTjW3Gf5TDzxDH1cbd+D
         vYPDV19H56nmUd04e8zNK3+mUjsFEMGF/JgLpFvy+lJPGunKDuv6AR2fDCMvRNrolOVr
         0aqA==
X-Gm-Message-State: APjAAAXMDlEijsgsSoTt3G0ychcrTvXa4khVixNPi/N1/qdZy3wgbF89
	Q0aL1mYJLik8vJ7tbz37KO08Q2bbrUNyUktxL1UJoDY2ayIypSPQ5SFMelzzZroIMWvamYnSilK
	KXSbEXjkb/abupr2q6F/9v9DGxDYHCULY0SyqrrUFR2ywnw3DopS7Tf0GF3Qjl0M=
X-Received: by 2002:a50:c28a:: with SMTP id o10mr53593560edf.182.1560823323163;
        Mon, 17 Jun 2019 19:02:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfwcgP7SRbJHs6ISf6Hcgm7SHfiYkNsoL+e+2yrCol3ZbcEOVuTYrcM1UN0qCP45i1isSZ
X-Received: by 2002:a50:c28a:: with SMTP id o10mr53593516edf.182.1560823322494;
        Mon, 17 Jun 2019 19:02:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560823322; cv=none;
        d=google.com; s=arc-20160816;
        b=dOjoiO2MwtJbD9ITL+Td3iBLm3GUPE0CmCnCRiWCdN+ytovpDlXn0bwTpZqhNKzu6O
         09ppbquQ5F3/wvSRTK+XzH3ftwXwkdvXoKZrblEADtiSNdYIyROORO7ceG7015EWkGnn
         E2ERjZk/ucE+7e+yPMCA6jh7E2sXf7V5PLoDrB34uPXwsFyZ1c9S7r6MTtoBHtY5hOdQ
         FV2p7BnyuDYM3ZHuVXnwgrIoScxmv5U8M5bQll9uM3lvggx2fha0YVEGpRa1Z070y6Le
         HOx4yPyJnULZJFGx4Ko5qD+ImBR2PlO7F0RXf8PIsb9H56r6EsekMDxUCfv5r4YE+8RD
         Npdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=x2wpQ4AhiN7KRVspeIae1sst5lVNYjKBsjHdOpOWzvg=;
        b=FpDRdgwZG5eaAvyKvcac/dowJx4LYrk2QcXHbMqeA49iU5oDGwPm5rU33szYlE0COz
         wqL35olQg9UzPKji6B2tJOgDvPB4t0mq81oE7ZCiur2oTcnrvaQMB/YogtEeQzRnoavZ
         BkZuk+rEDYXPjDl6cLiJzbqYXRuFpOcS8hd47StLGVUXzYiVbzVtNZ/yiZu0ZIb1VV4t
         5/QfSNGjbdEiV8TcBxmmIk0APrl+Z00Rto+M6gO+0ZlqEHPJz0ehW60bExbRTOazlLSg
         b9surazoxB+HfZr5qjDtsaLbSRA33TUvwopEdTHl94tAVSwDTFf4R5ar5xIc81FJo0Ai
         QagA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=mhAG8Elh;
       spf=neutral (google.com: 40.107.70.71 is neither permitted nor denied by best guess record for domain of thomas.lendacky@amd.com) smtp.mailfrom=Thomas.Lendacky@amd.com
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700071.outbound.protection.outlook.com. [40.107.70.71])
        by mx.google.com with ESMTPS id s9si9888627edm.285.2019.06.17.19.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 19:02:02 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.70.71 is neither permitted nor denied by best guess record for domain of thomas.lendacky@amd.com) client-ip=40.107.70.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=mhAG8Elh;
       spf=neutral (google.com: 40.107.70.71 is neither permitted nor denied by best guess record for domain of thomas.lendacky@amd.com) smtp.mailfrom=Thomas.Lendacky@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=x2wpQ4AhiN7KRVspeIae1sst5lVNYjKBsjHdOpOWzvg=;
 b=mhAG8ElhryKzlq8NJLeAv6nMuRp+RegP0f6mCBYT0LkNCClPd9iHcauNq8qXzhmzU53O+C7fAfwv/ne/DRqViKQanL0HIiwhsZVOeU2sJRkIrvrYloq0ckm3XIsIJIecgyBogTr7bTdgFLgO2zaB044Q5Q9EtMHshiwCz2+5R2g=
Received: from DM6PR12MB3163.namprd12.prod.outlook.com (20.179.104.150) by
 DM6PR12MB3611.namprd12.prod.outlook.com (20.178.199.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Tue, 18 Jun 2019 02:02:00 +0000
Received: from DM6PR12MB3163.namprd12.prod.outlook.com
 ([fe80::bcaf:86d4:677f:9555]) by DM6PR12MB3163.namprd12.prod.outlook.com
 ([fe80::bcaf:86d4:677f:9555%6]) with mapi id 15.20.1987.014; Tue, 18 Jun 2019
 02:02:00 +0000
From: "Lendacky, Thomas" <Thomas.Lendacky@amd.com>
To: Andy Lutomirski <luto@kernel.org>
CC: Kai Huang <kai.huang@linux.intel.com>, Dave Hansen
	<dave.hansen@intel.com>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>,
	X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
	<mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov
	<bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, David Howells
	<dhowells@redhat.com>, Kees Cook <keescook@chromium.org>, Jacob Pan
	<jacob.jun.pan@linux.intel.com>, Alison Schofield
	<alison.schofield@intel.com>, Linux-MM <linux-mm@kvack.org>, kvm list
	<kvm@vger.kernel.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for
 MKTME
Thread-Topic: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
Thread-Index:
 AQHVBaytkz7iqCERRUG2Tf+Vvry8YKagMWmAgAAF3ICAAAT1AIAALTSAgABck4D//8anAIAAVZ+AgAAF/gA=
Date: Tue, 18 Jun 2019 02:02:00 +0000
Message-ID: <ac6c02da-5439-1f24-1975-7ba626599d14@amd.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
 <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
 <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
 <1560815959.5187.57.camel@linux.intel.com>
 <cbbc6af7-36f8-a81f-48b1-2ad4eefc2417@amd.com>
 <CALCETrWq98--AgXXj=h1R70CiCWNncCThN2fEdxj2ZkedMw6=A@mail.gmail.com>
In-Reply-To:
 <CALCETrWq98--AgXXj=h1R70CiCWNncCThN2fEdxj2ZkedMw6=A@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: DM3PR14CA0137.namprd14.prod.outlook.com
 (2603:10b6:0:53::21) To DM6PR12MB3163.namprd12.prod.outlook.com
 (2603:10b6:5:182::22)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Thomas.Lendacky@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [165.204.77.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 55b38e2f-3409-47ff-530a-08d6f390f307
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DM6PR12MB3611;
x-ms-traffictypediagnostic: DM6PR12MB3611:
x-microsoft-antispam-prvs:
 <DM6PR12MB3611ED2007AC594304E8E064ECEA0@DM6PR12MB3611.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 007271867D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(376002)(346002)(136003)(39860400002)(396003)(199004)(189003)(6512007)(5660300002)(73956011)(86362001)(186003)(25786009)(6116002)(102836004)(4326008)(3846002)(7736002)(53936002)(6916009)(26005)(2906002)(81166006)(81156014)(8676002)(8936002)(68736007)(305945005)(31686004)(54906003)(478600001)(72206003)(66066001)(14444005)(256004)(6486002)(6246003)(229853002)(316002)(36756003)(66946007)(66476007)(64756008)(66446008)(99286004)(52116002)(66556008)(71200400001)(446003)(7416002)(486006)(11346002)(71190400001)(6436002)(76176011)(476003)(2616005)(386003)(6506007)(53546011)(14454004)(31696002);DIR:OUT;SFP:1101;SCL:1;SRVR:DM6PR12MB3611;H:DM6PR12MB3163.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 mCBZSMfEJuqEOgcFctyscRO40vl/MLZeyxHm+2GZZFFXPLSA1UxLiosr/L8sEV1/698Fd2R/ln03dJuDH4Bt/lKUfH5BQ9tyZDEx5gWC3zJcpsaUkhLFBT/M1TluLanYYyQdeOqm99iBqgJqBK60Pyrxn/IcS7DhUhf5IF2mnoTCyNQ5S+Skkrl7Eb3fK0fAd498+FQliQUfDrO0li69D4lzgu2SDCChB2OdwaIdzX3hlNq6vQ7l35K4B24JXCwkUU40DpPOur39FhTULf/jU5gP5Ji6bRuD7EEHTUPNkCKb4Vmw+OFz8serShUPsya74C2dhuJT+XOoYPGCqYYrmsbJG3P/NBJOx+wz086b8Lv0xmY9MzL8DhQPZadzSyJ7SlxFM+qBpCobm8lxoDN4nxmV/UVuEQhjSSGaAjTBQn8=
Content-Type: text/plain; charset="utf-8"
Content-ID: <A758D81DF226754D84136CBF9C60D751@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 55b38e2f-3409-47ff-530a-08d6f390f307
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Jun 2019 02:02:00.0995
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: tlendack@amd.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB3611
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gNi8xNy8xOSA4OjQwIFBNLCBBbmR5IEx1dG9taXJza2kgd3JvdGU6DQo+IE9uIE1vbiwgSnVu
IDE3LCAyMDE5IGF0IDY6MzQgUE0gTGVuZGFja3ksIFRob21hcw0KPiA8VGhvbWFzLkxlbmRhY2t5
QGFtZC5jb20+IHdyb3RlOg0KPj4NCj4+IE9uIDYvMTcvMTkgNjo1OSBQTSwgS2FpIEh1YW5nIHdy
b3RlOg0KPj4+IE9uIE1vbiwgMjAxOS0wNi0xNyBhdCAxMToyNyAtMDcwMCwgRGF2ZSBIYW5zZW4g
d3JvdGU6DQo+IA0KPj4+DQo+Pj4gQW5kIHllcyBmcm9tIG15IHJlYWRpbmcgKGJldHRlciB0byBo
YXZlIEFNRCBndXlzIHRvIGNvbmZpcm0pIFNFViBndWVzdCB1c2VzIGFub255bW91cyBtZW1vcnks
IGJ1dCBpdA0KPj4+IGFsc28gcGlucyBhbGwgZ3Vlc3QgbWVtb3J5IChieSBjYWxsaW5nIEdVUCBm
cm9tIEtWTSAtLSBTRVYgc3BlY2lmaWNhbGx5IGludHJvZHVjZWQgMiBLVk0gaW9jdGxzIGZvcg0K
Pj4+IHRoaXMgcHVycG9zZSksIHNpbmNlIFNFViBhcmNoaXRlY3R1cmFsbHkgY2Fubm90IHN1cHBv
cnQgc3dhcHBpbmcsIG1pZ3JhaXRvbiBvZiBTRVYtZW5jcnlwdGVkIGd1ZXN0DQo+Pj4gbWVtb3J5
LCBiZWNhdXNlIFNNRS9TRVYgYWxzbyB1c2VzIHBoeXNpY2FsIGFkZHJlc3MgYXMgInR3ZWFrIiwg
YW5kIHRoZXJlJ3Mgbm8gd2F5IHRoYXQga2VybmVsIGNhbg0KPj4+IGdldCBvciB1c2UgU0VWLWd1
ZXN0J3MgbWVtb3J5IGVuY3J5cHRpb24ga2V5LiBJbiBvcmRlciB0byBzd2FwL21pZ3JhdGUgU0VW
LWd1ZXN0IG1lbW9yeSwgd2UgbmVlZCBTR1gNCj4+PiBFUEMgZXZpY3Rpb24vcmVsb2FkIHNpbWls
YXIgdGhpbmcsIHdoaWNoIFNFViBkb2Vzbid0IGhhdmUgdG9kYXkuDQo+Pg0KPj4gWWVzLCBhbGwg
dGhlIGd1ZXN0IG1lbW9yeSBpcyBjdXJyZW50bHkgcGlubmVkIGJ5IGNhbGxpbmcgR1VQIHdoZW4g
Y3JlYXRpbmcNCj4+IGFuIFNFViBndWVzdC4NCj4gDQo+IEljay4NCj4gDQo+IFdoYXQgaGFwcGVu
cyBpZiBRRU1VIHRyaWVzIHRvIHJlYWQgdGhlIG1lbW9yeT8gIERvZXMgaXQganVzdCBzZWUNCj4g
Y2lwaGVydGV4dD8gIElzIGNhY2hlIGNvaGVyZW5jeSBsb3N0IGlmIFFFTVUgd3JpdGVzIGl0Pw0K
DQpJZiBRRU1VIHRyaWVzIHRvIHJlYWQgdGhlIG1lbW9yeSBpcyB3b3VsZCBqdXN0IHNlZSBjaXBo
ZXJ0ZXh0LiBJJ2xsDQpkb3VibGUgY2hlY2sgb24gdGhlIHdyaXRlIHNpdHVhdGlvbiwgYnV0IEkg
dGhpbmsgeW91IHdvdWxkIGVuZCB1cCB3aXRoDQphIGNhY2hlIGNvaGVyZW5jeSBpc3N1ZSBiZWNh
dXNlIHRoZSB3cml0ZSBieSBRRU1VIHdvdWxkIGJlIHdpdGggdGhlDQpoeXBlcnZpc29yIGtleSBh
bmQgdGFnZ2VkIHNlcGFyYXRlbHkgaW4gdGhlIGNhY2hlIGZyb20gdGhlIGd1ZXN0IGNhY2hlDQpl
bnRyeS4gU0VWIHByb3ZpZGVzIGNvbmZpZGVudGlhbGl0eSBvZiBndWVzdCBtZW1vcnkgZnJvbSB0
aGUgaHlwZXJ2aXNvciwNCml0IGRvZXNuJ3QgcHJldmVudCB0aGUgaHlwZXJ2aXNvciBmcm9tIHRy
YXNoaW5nIHRoZSBndWVzdCBtZW1vcnkuDQoNCg0KVGhhbmtzLA0KVG9tDQoNCj4gDQo=

