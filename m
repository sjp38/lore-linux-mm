Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 134B3C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 20:26:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2E0620880
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 20:26:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="HRs67MTZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2E0620880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 399DB6B0003; Tue,  6 Aug 2019 16:26:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34C9F6B0006; Tue,  6 Aug 2019 16:26:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 212626B0007; Tue,  6 Aug 2019 16:26:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C681A6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 16:26:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o13so54740094edt.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 13:26:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=7IGkLjPpS/zSYDGWQ2cgLZHa/giqNj0So6XUn+tZCoA=;
        b=GT1ipttpb7ZTbO8ogG9CIonP7cSFJG2shI+e1TdYhgBhQC47VTmfAfEsW/C9wRQID0
         StvOncHrBzTG5/g5MNWGaFugHIiIQKzzxCjyKT6SrqeqMVwXDU3VrBJw3PsV6WQRqt09
         bFMyJzpXm5XFen+v8tyR1qEzVvO4TJg1aFiKvCLdHIkQMiYcajIj3QT5yPfldnphpQHw
         FauNdvV+uZ+fHRdOmlkkbJWLvcXOzUBvqRylFB8FVmh+zB+/52AW5HUsxgSryJ16N5a7
         9Pr+7QVVln+wZ+AEJDy0y2bFW76aGqtgtNOM15R7nVX9b+mvbKTgD79M8pdEibKznJ0W
         cAzQ==
X-Gm-Message-State: APjAAAUdh3SMVdI3JI8aKMRbNYKa+1HdCJoOgAxlLqIMe8h93X2YJXmz
	kjVv/SWbP4SBI2kG5LtWyukFLEjgnvRNmOBV4THTXPY0LSn9na1SqGaxY0mKk0oPE33RnjJQxpC
	rU8lFNanZCvmNlXcSQ+kXUqJNWSQUPJKJ4pBPrJjWsroV5jT+f3XViwhPEkxTOig=
X-Received: by 2002:aa7:d0c5:: with SMTP id u5mr5836323edo.299.1565123216136;
        Tue, 06 Aug 2019 13:26:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzK53NtFj04LurfK3AfzZAJ9to0eay9fuUTo/+FGs2Boqfip8Hr6c7k46JN045iS0eURwB2
X-Received: by 2002:aa7:d0c5:: with SMTP id u5mr5836264edo.299.1565123215256;
        Tue, 06 Aug 2019 13:26:55 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565123215; cv=pass;
        d=google.com; s=arc-20160816;
        b=fvomviCX6vknhpfuDU5iyrQzVrs+ThG1H8OQ2UAV4VHdHAVGbXjVUKyc81oTEvArs6
         /AaocYUMgWnlZVVTpsFu363wQWwMSX0XJWVLyBnP0ieSY7PZrd8XM0vKQU4x6t1xSko2
         6cJWjS+YFk1FpKg8KRqCkhACUAp4nlpnwk0XEVnO0DcxzalhVVPoPE67soKtfs1lfdHQ
         mePT3MKnYVi3TddvE+cslFejaUyvBc+GXt3YON3S/0HHaRCvDEDK0BIXCh/5IxZngL+g
         XSjIH8H0DuKHxINvxyET1gPZutibAfre1+hL+oMR6M8pnNSNRYCvVuRGbOh1QNLuej6X
         Dy8A==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=7IGkLjPpS/zSYDGWQ2cgLZHa/giqNj0So6XUn+tZCoA=;
        b=kcntPtdr038vF85My0BuCUCFbBKcjEKQaSqW7JMAFJUnLeTpnjBSLwU8fjdxsZd1f3
         1Y8PsyIMur2RcY+/t+7HAQHTAY8GbU6sctYz3h9b86RXanP4l/iCh8P8UKVncEhSHNYP
         TSbhH4AHknxjVlylq+JiZ9ShBaQQ5ho/u61EjAo/Z+wI9JYU+/k+nLmG1gqqlpsNjrlK
         XxrvDBfApRRMgtXlQlcICHl1gDv1KpdACzz4pLrlo7ymsMDDmlq45Qalng0RLmUxmDlP
         odekR7/DpOZiJbDiF9hIAVCG1/0YgyLfq5O76bSxJuEcfsNdwpNM31FXwTAwQbXd9TmZ
         hCSA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=HRs67MTZ;
       arc=pass (i=1 spf=pass spfdomain=amd.com dkim=pass dkdomain=amd.com dmarc=pass fromdomain=amd.com);
       spf=neutral (google.com: 40.107.70.57 is neither permitted nor denied by best guess record for domain of thomas.lendacky@amd.com) smtp.mailfrom=Thomas.Lendacky@amd.com
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700057.outbound.protection.outlook.com. [40.107.70.57])
        by mx.google.com with ESMTPS id h19si28747368ejx.36.2019.08.06.13.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 13:26:55 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.70.57 is neither permitted nor denied by best guess record for domain of thomas.lendacky@amd.com) client-ip=40.107.70.57;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=HRs67MTZ;
       arc=pass (i=1 spf=pass spfdomain=amd.com dkim=pass dkdomain=amd.com dmarc=pass fromdomain=amd.com);
       spf=neutral (google.com: 40.107.70.57 is neither permitted nor denied by best guess record for domain of thomas.lendacky@amd.com) smtp.mailfrom=Thomas.Lendacky@amd.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=kcMRE2cMBOic/dOHcC8cak6LjjwFN1A1qDBjXy8Owp9uG8b5dkc16mgvMr41z7fqzXl5NsDpbByUP7aPNf25VKU3H85gXKbYHGlioO3ALlpQU/OD/YNHl0u85SScDViFC3nhR2Zwpd6INuqsRsCzZZbNQIjwvc+I/PkmIKBSThBoaNeaO6L3RH6+xSC4r3/UkAovnsvz6/8Yc9LQt+9BKpP8YcM59Yn7vynVE4/89F0USS9aDpyhTpHrOKkIMs4D4uo8QQrYQB6UB5CoHl+x1bx8SzSIa0Zr7bI4UzkbIDM0mnFZLTc+P4LZCMpRNdBLYgKaBEMQQaMneo6FVKHwyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=7IGkLjPpS/zSYDGWQ2cgLZHa/giqNj0So6XUn+tZCoA=;
 b=UfTdwi4c0s2d6DTZAXRN9FfjwDTqLcA9s+IJ2L4TSj2h8ymroRTKRLFKUWA6i+HA/lwZ7XFpwzd/T4up9BviJOsCMg/zi8d7D7ZJyHWQVgmbFHkAcuahDl1JMqvXY0X7pYbyPVwV60SnevDfZ1Q7dZbrLPnUGN53p9hj2nt8Og8mIeywkpSwGCNX1ELwd1soSlInqaiO2QPg/6/TF3Xi9aaXozGpAq1a/SlcVSiv45VI4j+U1Vzw/jp7Glmcf6v2FzhpOtSftnWy5dpINW1Ms5MJJ9qdaFXKUU7X3iWeK4Nlo5ce9ZHe+U0E2gjmF2oN3FL2kHPmj8xz2Pei2s3lHw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=amd.com;dmarc=pass action=none header.from=amd.com;dkim=pass
 header.d=amd.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=7IGkLjPpS/zSYDGWQ2cgLZHa/giqNj0So6XUn+tZCoA=;
 b=HRs67MTZx9u4y4IQLCxmnUKPVamisFEDKxM9vNhOPNY4JdqbbCnk1fCeTJ+Q9Hv8hCzuuB8Oy8lzstB1lbGfJLjk9ZfFlfrmRj23vLaf47fP/fpPlOU8rjJljq02T1NBQDTJb9CuxH/8loLKQ5+/n6jwiROyFeHhKQuNYAwb5IE=
Received: from DM6PR12MB3163.namprd12.prod.outlook.com (20.179.104.150) by
 DM6PR12MB3529.namprd12.prod.outlook.com (20.179.106.160) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.13; Tue, 6 Aug 2019 20:26:52 +0000
Received: from DM6PR12MB3163.namprd12.prod.outlook.com
 ([fe80::9c3d:8593:906c:e4f7]) by DM6PR12MB3163.namprd12.prod.outlook.com
 ([fe80::9c3d:8593:906c:e4f7%6]) with mapi id 15.20.2136.018; Tue, 6 Aug 2019
 20:26:52 +0000
From: "Lendacky, Thomas" <Thomas.Lendacky@amd.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton
	<akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas
 Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra
	<peterz@infradead.org>, Andy Lutomirski <luto@amacapital.net>, David Howells
	<dhowells@redhat.com>
CC: Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>, Jacob Pan
	<jacob.jun.pan@linux.intel.com>, Alison Schofield
	<alison.schofield@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>, "keyrings@vger.kernel.org"
	<keyrings@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 47/59] kvm, x86, mmu: setup MKTME keyID to spte for
 given PFN
Thread-Topic: [PATCHv2 47/59] kvm, x86, mmu: setup MKTME keyID to spte for
 given PFN
Thread-Index: AQHVR7N50JZUMg30+0GwscyLbLRscqbumx6A
Date: Tue, 6 Aug 2019 20:26:52 +0000
Message-ID: <a3aee9ea-a3ce-1219-b7ff-5a1b291bffdd@amd.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
 <20190731150813.26289-48-kirill.shutemov@linux.intel.com>
In-Reply-To: <20190731150813.26289-48-kirill.shutemov@linux.intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: SN4PR0501CA0013.namprd05.prod.outlook.com
 (2603:10b6:803:40::26) To DM6PR12MB3163.namprd12.prod.outlook.com
 (2603:10b6:5:182::22)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Thomas.Lendacky@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [165.204.77.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7960527e-446d-46f2-db0a-08d71aac6ac5
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DM6PR12MB3529;
x-ms-traffictypediagnostic: DM6PR12MB3529:
x-microsoft-antispam-prvs:
 <DM6PR12MB3529625FBB8E66B94F41FAA9ECD50@DM6PR12MB3529.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1247;
x-forefront-prvs: 0121F24F22
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(376002)(396003)(39860400002)(136003)(346002)(189003)(199004)(36756003)(68736007)(7416002)(476003)(486006)(2616005)(71190400001)(71200400001)(11346002)(446003)(14454004)(4326008)(86362001)(316002)(478600001)(54906003)(31696002)(25786009)(6246003)(6436002)(305945005)(7736002)(26005)(66476007)(3846002)(64756008)(53546011)(66446008)(186003)(6116002)(110136005)(2906002)(6486002)(66556008)(229853002)(76176011)(102836004)(2501003)(66066001)(31686004)(66946007)(5660300002)(6512007)(53936002)(256004)(99286004)(81156014)(81166006)(386003)(52116002)(8676002)(6506007)(14444005)(8936002)(921003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:DM6PR12MB3529;H:DM6PR12MB3163.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 jPjow3QyH9EJwADFTNpzZbgFVaQpvj9QzYT8YMR8WojofdDX/GZWJCw5IFVGigJNfQaTmAtxdvyOQ00nkK/HiKBMIxIe/UO5jAAI12M2RH0HS0DsMcEBcU8F4cyW+RLkT7Ds+rr3lsoDYz3ktu1sY4/Zr7aXzKwq0e0qrT2uhWKxJ2zb+lfhYb2DXBNR7g7eqd1P4Iu5u84GN759SSe0Un4qgAEiiryqTxmUjwGLbt6yC7bwKmcCwvPlmzPFocof4/ejUB6CykkXchOmrkDlsIV0MBpVCiirLpAcmUS6eINz8UGqOxj0vO8KuEhhM8V2AJb15woKl5MPs2AZQzx1KEfusMqbnai73RUt2+l5SiCkp9OFT457XuvkFs3TTeSbuGxVwYsu8u0ZlMSz8AVogUHehKXCtfBpR8xUA5EbWKk=
Content-Type: text/plain; charset="utf-8"
Content-ID: <52FCCCB87C0C0148AD8C552201384C4E@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7960527e-446d-46f2-db0a-08d71aac6ac5
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Aug 2019 20:26:52.6811
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: tlendack@amd.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB3529
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gNy8zMS8xOSAxMDowOCBBTSwgS2lyaWxsIEEuIFNodXRlbW92IHdyb3RlOg0KPiBGcm9tOiBL
YWkgSHVhbmcgPGthaS5odWFuZ0BsaW51eC5pbnRlbC5jb20+DQo+IA0KPiBTZXR1cCBrZXlJRCB0
byBTUFRFLCB3aGljaCB3aWxsIGJlIGV2ZW50dWFsbHkgcHJvZ3JhbW1lZCB0byBzaGFkb3cgTU1V
DQo+IG9yIEVQVCB0YWJsZSwgYWNjb3JkaW5nIHRvIHBhZ2UncyBhc3NvY2lhdGVkIGtleUlELCBz
byB0aGF0IGd1ZXN0IGlzDQo+IGFibGUgdG8gdXNlIGNvcnJlY3Qga2V5SUQgdG8gYWNjZXNzIGd1
ZXN0IG1lbW9yeS4NCj4gDQo+IE5vdGUgY3VycmVudCBzaGFkb3dfbWVfbWFzayBkb2Vzbid0IHN1
aXQgTUtUTUUncyBuZWVkcywgc2luY2UgZm9yIE1LVE1FDQo+IHRoZXJlJ3Mgbm8gZml4ZWQgbWVt
b3J5IGVuY3J5cHRpb24gbWFzaywgYnV0IGNhbiB2YXJ5IGZyb20ga2V5SUQgMSB0bw0KPiBtYXhp
bXVtIGtleUlELCB0aGVyZWZvcmUgc2hhZG93X21lX21hc2sgcmVtYWlucyAwIGZvciBNS1RNRS4N
Cj4gDQo+IFNpZ25lZC1vZmYtYnk6IEthaSBIdWFuZyA8a2FpLmh1YW5nQGxpbnV4LmludGVsLmNv
bT4NCj4gU2lnbmVkLW9mZi1ieTogS2lyaWxsIEEuIFNodXRlbW92IDxraXJpbGwuc2h1dGVtb3ZA
bGludXguaW50ZWwuY29tPg0KPiAtLS0NCj4gIGFyY2gveDg2L2t2bS9tbXUuYyB8IDE4ICsrKysr
KysrKysrKysrKysrLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDE3IGluc2VydGlvbnMoKyksIDEgZGVs
ZXRpb24oLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9hcmNoL3g4Ni9rdm0vbW11LmMgYi9hcmNoL3g4
Ni9rdm0vbW11LmMNCj4gaW5kZXggOGY3MjUyNmUyZjY4Li5iODc0MmU2MjE5ZjYgMTAwNjQ0DQo+
IC0tLSBhL2FyY2gveDg2L2t2bS9tbXUuYw0KPiArKysgYi9hcmNoL3g4Ni9rdm0vbW11LmMNCj4g
QEAgLTI5MzYsNiArMjkzNiwyMiBAQCBzdGF0aWMgYm9vbCBrdm1faXNfbW1pb19wZm4oa3ZtX3Bm
bl90IHBmbikNCj4gICNkZWZpbmUgU0VUX1NQVEVfV1JJVEVfUFJPVEVDVEVEX1BUCUJJVCgwKQ0K
PiAgI2RlZmluZSBTRVRfU1BURV9ORUVEX1JFTU9URV9UTEJfRkxVU0gJQklUKDEpDQo+ICANCj4g
K3N0YXRpYyB1NjQgZ2V0X3BoeXNfZW5jcnlwdGlvbl9tYXNrKGt2bV9wZm5fdCBwZm4pDQo+ICt7
DQo+ICsjaWZkZWYgQ09ORklHX1g4Nl9JTlRFTF9NS1RNRQ0KPiArCXN0cnVjdCBwYWdlICpwYWdl
Ow0KPiArDQo+ICsJaWYgKCFwZm5fdmFsaWQocGZuKSkNCj4gKwkJcmV0dXJuIDA7DQo+ICsNCj4g
KwlwYWdlID0gcGZuX3RvX3BhZ2UocGZuKTsNCj4gKw0KPiArCXJldHVybiAoKHU2NClwYWdlX2tl
eWlkKHBhZ2UpKSA8PCBta3RtZV9rZXlpZF9zaGlmdCgpOw0KPiArI2Vsc2UNCj4gKwlyZXR1cm4g
c2hhZG93X21lX21hc2s7DQo+ICsjZW5kaWYNCj4gK30NCg0KVGhpcyBwYXRjaCBicmVha3MgQU1E
IHZpcnR1YWxpemF0aW9uIChTVk0pIGluIGdlbmVyYWwgKG5vbi1TRVYgYW5kIFNFVg0KZ3Vlc3Rz
KSB3aGVuIFNNRSBpcyBhY3RpdmUuIFNob3VsZG4ndCB0aGlzIGJlIGEgcnVuIHRpbWUsIHZzIGJ1
aWxkIHRpbWUsDQpjaGVjayBmb3IgTUtUTUUgYmVpbmcgYWN0aXZlPw0KDQpUaGFua3MsDQpUb20N
Cg0KPiArDQo+ICBzdGF0aWMgaW50IHNldF9zcHRlKHN0cnVjdCBrdm1fdmNwdSAqdmNwdSwgdTY0
ICpzcHRlcCwNCj4gIAkJICAgIHVuc2lnbmVkIHB0ZV9hY2Nlc3MsIGludCBsZXZlbCwNCj4gIAkJ
ICAgIGdmbl90IGdmbiwga3ZtX3Bmbl90IHBmbiwgYm9vbCBzcGVjdWxhdGl2ZSwNCj4gQEAgLTI5
ODIsNyArMjk5OCw3IEBAIHN0YXRpYyBpbnQgc2V0X3NwdGUoc3RydWN0IGt2bV92Y3B1ICp2Y3B1
LCB1NjQgKnNwdGVwLA0KPiAgCQlwdGVfYWNjZXNzICY9IH5BQ0NfV1JJVEVfTUFTSzsNCj4gIA0K
PiAgCWlmICgha3ZtX2lzX21taW9fcGZuKHBmbikpDQo+IC0JCXNwdGUgfD0gc2hhZG93X21lX21h
c2s7DQo+ICsJCXNwdGUgfD0gZ2V0X3BoeXNfZW5jcnlwdGlvbl9tYXNrKHBmbik7DQo+ICANCj4g
IAlzcHRlIHw9ICh1NjQpcGZuIDw8IFBBR0VfU0hJRlQ7DQo+ICANCj4gDQo=

