Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30539C00319
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 01:15:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3C772080F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 01:15:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="gPoN6WDc";
	dkim=pass (1024-bit key) header.d=sharedspace.onmicrosoft.com header.i=@sharedspace.onmicrosoft.com header.b="n2pJejbT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3C772080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 614668E00DF; Thu, 21 Feb 2019 20:15:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C3318E00D4; Thu, 21 Feb 2019 20:15:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 418238E00DF; Thu, 21 Feb 2019 20:15:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F20268E00D4
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 20:15:22 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b8so522600pfe.10
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 17:15:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:wdcipoutbound:content-id
         :content-transfer-encoding:mime-version;
        bh=OF46phLfakSA2l5jO+kRBLy0YxIbAz9PGbWxe0r/3vo=;
        b=uA4V3zZqA2DphohTNc5N9AEs2xiItPwVeFhH5belD8GoSsHQlS02hSOS4AsGQWB7aZ
         g1RwagfhZyZgP9xr7YwSa7+KMG1JPtdN/0jAFBIIaMOqxLjO8hAP0z536u04vdXY8b9I
         ljpgItjJn9Yjz5pcjawWqZCsbD8Efo7v9Q/sCCoE4u2GxY0ytxNc7OijxA9ad71UHEzZ
         JiwcK3KACkZNioUmPnCpQ0MvTZ5THVJw5oBPS1HAAJWfiud5fX53PARIRdbny6tL0B+I
         w7R0HSilg4l3mFXtYUjMyhPCVtUt3fflwFe/U0E4IqdhJsCaZG+nnuvXEa1M5p/90K8+
         H22A==
X-Gm-Message-State: AHQUAuanVVnS8KmH1RwsXc0YuHzE1qRdfI6fpe5ASQMN7Ef8l26rtAzq
	pO38zbSRp2x4RnedARX8MZ9nAOyJh0zrmGGdfww7mAAa9fPGoLEOjObetWMNnGnVB+7m4wcFJWq
	JflsLut25zD3xz3nQs4PIOlJaCjMDhIcn4Fv3+81XO6iuNG8h4B94m6v2TzU/EBo9LQ==
X-Received: by 2002:a17:902:c5:: with SMTP id a63mr1487633pla.267.1550798122509;
        Thu, 21 Feb 2019 17:15:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iby6D+8zNEKPLy7C9Pflrcl6WgjkIv9loyyOno3DUGxUMdpiWEtbnNeRNblgx2msUtJ9Qn2
X-Received: by 2002:a17:902:c5:: with SMTP id a63mr1487556pla.267.1550798121618;
        Thu, 21 Feb 2019 17:15:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550798121; cv=none;
        d=google.com; s=arc-20160816;
        b=aBigG/9mtA1NTe/Vd6lUHkHAjyspVNluiQe16x2+WUB2cCiLbgLBPdWrvcECE2Sb5d
         kmCKfcTltshKZuxwU9PQPPfD/Se4IayJchlQ3c7btSdtjXIVOlSfvtvuWn0vrHGdFeTk
         Up/YQ31iyo0hYMWlX4XKPOJzybSR+qLdnwfTMD5Q9lylCwt4ZrcqPQVOlND22NTckHF1
         LuGI8UqcuX/Q6rYVP0i5Ns0dO30yEdTtfDSotuJG3uOKCPoWEizfAKfoXJpTX3DQ4trW
         XjtrjnU60a+7jMRVyG6nKTUqWyljF22drI4v6I2ZkP1PYdt0KfATzdodNBqUns0qerHA
         KsIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:wdcipoutbound
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=OF46phLfakSA2l5jO+kRBLy0YxIbAz9PGbWxe0r/3vo=;
        b=lcKwD+HL2h1kLon4pPwi2aqBXt2rZzG+jsSDA0TAfqCMfid+/Ur5T/AGuYx+WlVw4n
         0+JpLxwiGNCME1WbNXj+/9oayrG/Ge8mKC6NGKnaYOVosbnM8mEz7lme0Sd3vUGZYGYZ
         29kn27I7NAg+IOG1h3MvKAnjxCKXtljdAfrYlDkxDgGw1rIJTk/vZwCOyuL8YUjdafFX
         3EQ5FVCmYhonU6cPiP/GzJHvyjkKh71Bx6j6wR9YRHs3GaEr0B8mw0nX6DjX3aG1gsmO
         Bg0d6uDZU11tbGCnX+cBLbHw4zwQiJTM35mF60ZwRemPp07n4rCDSsK3XxBY/igE4mXt
         j47A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=gPoN6WDc;
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector1-wdc-com header.b=n2pJejbT;
       spf=pass (google.com: domain of prvs=94944f6ee=adam.manzanares@wdc.com designates 216.71.154.42 as permitted sender) smtp.mailfrom="prvs=94944f6ee=Adam.Manzanares@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa4.hgst.iphmx.com (esa4.hgst.iphmx.com. [216.71.154.42])
        by mx.google.com with ESMTPS id x14si54358pgq.185.2019.02.21.17.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 17:15:21 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=94944f6ee=adam.manzanares@wdc.com designates 216.71.154.42 as permitted sender) client-ip=216.71.154.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=gPoN6WDc;
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector1-wdc-com header.b=n2pJejbT;
       spf=pass (google.com: domain of prvs=94944f6ee=adam.manzanares@wdc.com designates 216.71.154.42 as permitted sender) smtp.mailfrom="prvs=94944f6ee=Adam.Manzanares@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1550798122; x=1582334122;
  h=from:to:cc:subject:date:message-id:references:
   in-reply-to:content-id:content-transfer-encoding:
   mime-version;
  bh=OF46phLfakSA2l5jO+kRBLy0YxIbAz9PGbWxe0r/3vo=;
  b=gPoN6WDcj//Vf26BJ71Psf6+0/AAYbVkemoYfb1mdsqVVAipcdVMXrpQ
   xFNXTa/UAGARrDdyWhYa6r5BnnTUraLU8EFQeIrR001RRcJOjDhud0gZ5
   uzc4MvO6/OHylL8Mf7Dzk70LMH4AzxQ81T/uHHpxz1dthkzx+yIP1CtEx
   9Iz6rpkQ1nEPdasv1GCc04MjiEr+vmPuupfcEkBQ7fSFwX0pk1lSrYsvP
   LaiQEb3RKFLAOD0s0myJOhmVQdvAm4aygJhkDb+9E6nE2DRFsckoS1v9j
   elJTpZ5Og4aIBmB1EaJ3ZVV7jgFRherhOGYgzB/wT+s3N4rGLAkgrfr2F
   Q==;
X-IronPort-AV: E=Sophos;i="5.58,397,1544457600"; 
   d="scan'208";a="101894178"
Received: from mail-bn3nam04lp2057.outbound.protection.outlook.com (HELO NAM04-BN3-obe.outbound.protection.outlook.com) ([104.47.46.57])
  by ob1.hgst.iphmx.com with ESMTP; 22 Feb 2019 09:15:20 +0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=sharedspace.onmicrosoft.com; s=selector1-wdc-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=OF46phLfakSA2l5jO+kRBLy0YxIbAz9PGbWxe0r/3vo=;
 b=n2pJejbTur4A7BUcEuhedpn2KSjKFGvQeIM027efcXed506HWIhgiaXHMJ7d0vBJDva3jZP4x6vKDffuNbVL8gQWo/ijuSnwpzILjXoJQ2VPCQjLr533BRxej78W/pOc6t/VcaXxWU5mG9ipUBDUwGFpM3DXUtTfZ+97dlRDL+g=
Received: from BYAPR04MB4357.namprd04.prod.outlook.com (20.176.251.147) by
 BYAPR04MB4053.namprd04.prod.outlook.com (52.135.215.148) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.15; Fri, 22 Feb 2019 01:15:17 +0000
Received: from BYAPR04MB4357.namprd04.prod.outlook.com
 ([fe80::91f1:a2af:8793:94a2]) by BYAPR04MB4357.namprd04.prod.outlook.com
 ([fe80::91f1:a2af:8793:94a2%7]) with mapi id 15.20.1622.020; Fri, 22 Feb 2019
 01:15:17 +0000
From: Adam Manzanares <Adam.Manzanares@wdc.com>
To: "jglisse@redhat.com" <jglisse@redhat.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"willy@infradead.org" <willy@infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "yang.shi@linux.alibaba.com"
	<yang.shi@linux.alibaba.com>, "dan.j.williams@intel.com"
	<dan.j.williams@intel.com>, "cl@linux.com" <cl@linux.com>, "mhocko@suse.com"
	<mhocko@suse.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>,
	"jack@suse.cz" <jack@suse.cz>
Subject: Re: [LSF/MM TOPIC] Page Cache Flexibility for NVM
Thread-Topic: [LSF/MM TOPIC] Page Cache Flexibility for NVM
Thread-Index: AQHUyjrUW2lvg3E88ESemij+/GgUJKXq9nKAgAANOAA=
Date: Fri, 22 Feb 2019 01:15:17 +0000
Message-ID: <0e9cb385c77427d7713cfe939161e56633a4e4de.camel@wdc.com>
References: <85ddda85755bf15ed2e56bce21f711ae8154d304.camel@wdc.com>
	 <20190222002754.GA10607@redhat.com>
In-Reply-To: <20190222002754.GA10607@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Adam.Manzanares@wdc.com; 
x-originating-ip: [73.71.222.205]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f0e2259a-5ddc-46d8-504c-08d6986334db
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BYAPR04MB4053;
x-ms-traffictypediagnostic: BYAPR04MB4053:
wdcipoutbound: EOP-TRUE
x-microsoft-exchange-diagnostics:
 =?utf-8?B?MTtCWUFQUjA0TUI0MDUzOzIzOlZ1NDN2cFBHZ3ZKR29uTVUxcUxUeWw2VU5r?=
 =?utf-8?B?SEtZcVZ4aXZCQVhGSWs1U1E2SDdzRDUzc3lpdGdocGZqZzE0UDNSalcvMVRQ?=
 =?utf-8?B?Sk9KNzhKSlVtZmNuRmtjU1NWTlBpUjNHWE9tZGo2ajVsc2pBMUdRTFFudjdT?=
 =?utf-8?B?RDBwRW5HdTRNbFh2OWNpV2ZaVkI4R3JPWkh6L25GQ0RpZU8yR3VlWWtnRXVL?=
 =?utf-8?B?U1RpZmJhMGRvMEFDYXlSWDZpS0NQVU00TDZGWm04MTFSeW83WEw1SjdUVmsw?=
 =?utf-8?B?TjVVaWhHUnJMZmF2MllBOXhta1N1L2ttays5Zjk2Znd3QUQ4MmRibFhKTFRp?=
 =?utf-8?B?NGxoSkJudDQ0WUxGSjJGbitLdWRDYWlrcm9uQmRMalRud1lUYkFnYnJMemlJ?=
 =?utf-8?B?b2w5b1c0OTRKR2E1c0hVSytPYnRBVFBCVmFuejVURERTYTlONm9FNHZ5RzBJ?=
 =?utf-8?B?dGhYd0c3SS96WTVSdkVjNUhzOUV4c0I0dWpxWmZadjVwQmlSanVrVE1wYlJi?=
 =?utf-8?B?WkhuVmE0RmJoNE8rcDRLQUIxY3pYYzRVV2pmZm9HSS9sNVlZcXRhR2xTei9I?=
 =?utf-8?B?aGNDWTdxSDNqSmoydldPMTdqKzBBcThtRU92c210Z2JWMEIvSzhxU3BnSklE?=
 =?utf-8?B?Y1dCcEVzejB3SHYwYnB5OFZHTUVwY3NabGExZWkwZzJ6UTAvZkJNZjFTQWJF?=
 =?utf-8?B?cmIyNG01SVFNZ0lFbVZtUHlaZGIvWVl6anRYK2Z0eFBWZG5RR3IzZkVUcFZp?=
 =?utf-8?B?TjJzd3FBVkROREVyR1YxdHJXTk9aTEQ5N3RUKzJ2NzI1M3cveDVRR1YzSk5V?=
 =?utf-8?B?dVozZDQ3WXBUQTU4UWcvd1JEMU92NEg0Ty9pT01zY3hrT0NKMkYrb1hQYS9r?=
 =?utf-8?B?K3cweDQ1OTBzZWkxejZJd2dHM3RQRTlzeVdMN3lNTFIzM1ZTS250VlVvVG53?=
 =?utf-8?B?Vnp1a21LRkpOMFdudGp6aDQrcW9RZ0c2VnNKVTREZlAveTlmZWFRSkF4OGdS?=
 =?utf-8?B?dVdkTEtRTHpoMTNGb3N5d3BRZ0tMdC9USUZpNWxlQU5FVlZVRTh4M1ZZb0JS?=
 =?utf-8?B?R2VENENoSjdaOFVpVnp6Tm81aW4rd1FUYjFBV3dRbXM3TXd4NFhRUnp2TnlH?=
 =?utf-8?B?VnlDZXE4NHBCZVUxVjVQTEd3MFpmTk5aenZ4REhRam82OTFvVGZyajFxa2Zk?=
 =?utf-8?B?cUFkYnNIWHFDSjFDQU5OL1F6eGJKb2VTV21XU0FJakpreDBPZHV1eVhMNFVs?=
 =?utf-8?B?WnZzVVhpRHNWS3JQQ2RSSXltWWRqWWk4dWlNNTd1Rm9lbHhoV2ltMDJ6MHVm?=
 =?utf-8?B?V2E0Y1MwbmpXcXFqdEhBQjZ5MVlCcU15cnJYOE1PZkVCWnFiemVEWHZaWXYv?=
 =?utf-8?B?bnFqZkNLRVkyOTR6NzNTdW0vUUhLeFhudEp4VlZERVpEZStFRWd1cFRSR3BR?=
 =?utf-8?B?aWthaWk5SmJSM3dkRjk5VnAvUjUvNGlDL2hrSGxNVUwrVmNQM0lyalN6eW16?=
 =?utf-8?B?eHpQZjlaSWZCMjdZMkFHSTJybElZYVlRWkVUSXJuZS9lM1RvbytKSWxmRGo0?=
 =?utf-8?B?MjV3RFdQZzdBWm1FOFNuazV6SzhySVo5R3E2N1MvZGh2ckxDN3g5Ukl4eTdq?=
 =?utf-8?B?ekFmVmRQcit2eGxNVTZiR0FWQW1mK0x6U05lYVN0Ni9zaEE3SEFTNHcyZTl0?=
 =?utf-8?B?ajNVd3pRaXQram0yM2VkYTl6ZzZOZ1ZDVHBYTmZ2SjB4Y2VtVldRRU91MEQz?=
 =?utf-8?B?NWw4amdQUXk5YWdpSEtYWnVzVW54ZmhTeUg4a2lUNlhsQVJhTWgvamxvb1Iy?=
 =?utf-8?B?aEppb3p3aUc4bUllbG5IY1hmVS9paFJhRy95RE1jalFuaGc9PQ==?=
x-microsoft-antispam-prvs:
 <BYAPR04MB40535482EE8F2536D0DA8461F07F0@BYAPR04MB4053.namprd04.prod.outlook.com>
x-forefront-prvs: 09565527D6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(346002)(396003)(366004)(136003)(376002)(39860400002)(189003)(199004)(14454004)(6506007)(256004)(54906003)(6436002)(5640700003)(71200400001)(86362001)(105586002)(2351001)(11346002)(316002)(5660300002)(66066001)(72206003)(71190400001)(99286004)(106356001)(305945005)(2906002)(6486002)(14444005)(7736002)(7416002)(76176011)(6916009)(6512007)(102836004)(66574012)(1730700003)(81156014)(36756003)(68736007)(118296001)(81166006)(8676002)(53936002)(486006)(97736004)(8936002)(229853002)(2616005)(476003)(3846002)(25786009)(6116002)(478600001)(4326008)(2501003)(446003)(6246003)(26005)(186003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR04MB4053;H:BYAPR04MB4357.namprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 j02W0CAEcFtdkpRvIz2Afk+XK6WL+kUKJjBZnSlvIpWeZWAccMaIL6aE1/55/eiRhRn2SstMgpcICO2BGoX0T8rbiZMy+xXqKUPXKDbTmO7krGslQtahgdFqxw35mWHckeNEP3dBW4Y4pxy8vsorH5ZeUPhWUF2PYsRzoTxzoCTyMTUfIyDgtKP8bUa7Q9iDt5T97esSbEgDT7iL5s1/jloOgIWUZ4PZK55O12GJfNqH5ESXyyQBw1K8NswCFffR2ZJsyfBaNgVZPTbOFLcXooqzyYvsAjYw0Fv7k0zIIZfUTlrrUy35RkECAPAKQY0iEkfRRwNUjF35u4CgPEFNP0ZHf0L0FOpsW3pAYTCMfq2NByL+ueqC2nDexHeDo5FtrDOgYCuQvmxHCXmi/HHVaS5ggSJ/7a4fr06iAzx6cJs=
Content-Type: text/plain; charset="utf-8"
Content-ID: <0C42B077B337A44B997941234961B319@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: wdc.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f0e2259a-5ddc-46d8-504c-08d6986334db
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Feb 2019 01:15:17.3755
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b61c8803-16f3-4c35-9b17-6f65f441df86
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR04MB4053
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCAyMDE5LTAyLTIxIGF0IDE5OjI3IC0wNTAwLCBKZXJvbWUgR2xpc3NlIHdyb3RlOg0K
PiBPbiBUaHUsIEZlYiAyMSwgMjAxOSBhdCAxMToxMTo1MVBNICswMDAwLCBBZGFtIE1hbnphbmFy
ZXMgd3JvdGU6DQo+ID4gSGVsbG8sDQo+ID4gDQo+ID4gSSB3b3VsZCBsaWtlIHRvIGF0dGVuZCB0
aGUgTFNGL01NIFN1bW1pdCAyMDE5LiBJJ20gaW50ZXJlc3RlZCBpbg0KPiA+IHNldmVyYWwgTU0g
dG9waWNzIHRoYXQgYXJlIG1lbnRpb25lZCBiZWxvdyBhcyB3ZWxsIGFzIFpvbmVkIEJsb2NrDQo+
ID4gRGV2aWNlcyBhbmQgYW55IGlvIGRldGVybWluaXNtIHRvcGljcyB0aGF0IGNvbWUgdXAgaW4g
dGhlIHN0b3JhZ2UNCj4gPiB0cmFjay4gDQo+ID4gDQo+ID4gSSBoYXZlIGJlZW4gd29ya2luZyBv
biBhIGNhY2hpbmcgbGF5ZXIsIGhtbWFwIChoZXRlcm9nZW5lb3VzIG1lbW9yeQ0KPiA+IG1hcCkg
WzFdLCBmb3IgZW1lcmdpbmcgTlZNIGFuZCBpdCBpcyBpbiBzcGlyaXQgY2xvc2UgdG8gdGhlIHBh
Z2UNCj4gPiBjYWNoZS4gVGhlIGtleSBkaWZmZXJlbmNlIGJlaW5nIHRoYXQgdGhlIGJhY2tlbmQg
ZGV2aWNlIGFuZCBjYWNoaW5nDQo+ID4gbGF5ZXIgb2YgaG1tYXAgaXMgcGx1Z2dhYmxlLiBJbiBh
ZGRpdGlvbiwgaG1tYXAgc3VwcG9ydHMgREFYIGFuZA0KPiA+IHdyaXRlDQo+ID4gcHJvdGVjdGlv
biwgd2hpY2ggSSBiZWxpZXZlIGFyZSBrZXkgZmVhdHVyZXMgZm9yIGVtZXJnaW5nIE5WTXMgdGhh
dA0KPiA+IG1heQ0KPiA+IGhhdmUgd3JpdGUvcmVhZCBhc3ltbWV0cnkgYXMgd2VsbCBhcyB3cml0
ZSBlbmR1cmFuY2UgY29uc3RyYWludHMuDQo+ID4gTGFzdGx5IHdlIGNhbiBsZXZlcmFnZSBoYXJk
d2FyZSwgc3VjaCBhcyBhIERNQSBlbmdpbmUsIHdoZW4gbW92aW5nDQo+ID4gcGFnZXMgYmV0d2Vl
biB0aGUgY2FjaGUgd2hpbGUgYWxzbyBhbGxvd2luZyBkaXJlY3QgYWNjZXNzIGlmIHRoZQ0KPiA+
IGRldmljZQ0KPiA+IGlzIGNhcGFibGUuDQo+ID4gDQo+ID4gSSBhbSBwcm9wb3NpbmcgdGhhdCBh
cyBhbiBhbHRlcm5hdGl2ZSB0byB1c2luZyBOVk1zIGFzIGEgTlVNQSBub2RlDQo+ID4gd2UgZXhw
b3NlIHRoZSBOVk0gdGhyb3VnaCB0aGUgcGFnZSBjYWNoZSBvciBhIHZpYWJsZSBhbHRlcm5hdGl2
ZQ0KPiA+IGFuZA0KPiA+IGhhdmUgdXNlcnNwYWNlIGFwcGxpY2F0aW9ucyBtbWFwIHRoZSBOVk0g
YW5kIGhhbmQgb3V0IG1lbW9yeSB3aXRoDQo+ID4gdGhlaXIgZmF2b3JpdGUgdXNlcnNwYWNlIG1l
bW9yeSBhbGxvY2F0b3IuDQo+ID4gDQo+ID4gVGhpcyB3b3VsZCBpc29sYXRlIHRoZSBOVk1zIHRv
IG9ubHkgYXBwbGljYXRpb25zIHRoYXQgYXJlIHdlbGwNCj4gPiBhd2FyZQ0KPiA+IG9mIHRoZSBw
ZXJmb3JtYW5jZSBpbXBsaWNhdGlvbnMgb2YgYWNjZXNzaW5nIE5WTS4gSSBiZWxpZXZlIHRoYXQN
Cj4gPiBhbGwNCj4gPiBvZiB0aGlzIHdvcmsgY291bGQgYmUgc29sdmVkIHdpdGggdGhlIE5VTUEg
bm9kZSBhcHByb2FjaCwgYnV0IHRoZQ0KPiA+IHR3bw0KPiA+IGFwcHJvYWNoZXMgYXJlIHNlZW1p
bmcgdG8gYmx1ciB0b2dldGhlci4NCj4gPiANCj4gPiBUaGUgbWFpbiBwb2ludHMgSSB3b3VsZCBs
aWtlIHRvIGRpc2N1c3MgYXJlOg0KPiA+IA0KPiA+ICogSXMgdGhlIHBhZ2UgY2FjaGUgbW9kZWwg
YSB2aWFibGUgYWx0ZXJuYXRpdmUgdG8gTlZNIGFzIGEgTlVNQQ0KPiA+IE5PREU/DQo+ID4gKiBD
YW4gd2UgYWRkIG1vcmUgZmxleGliaWxpdHkgdG8gdGhlIHBhZ2UgY2FjaGU/DQo+ID4gKiBTaG91
bGQgd2UgZm9yY2Ugc2VwYXJhdGlvbiBvZiBOVk0gdGhyb3VnaCBhbiBleHBsaWNpdCBtbWFwPw0K
PiA+IA0KPiA+IEkgYmVsaWV2ZSB0aGlzIGRpc2N1c3Npb24gY291bGQgYmUgbWVyZ2VkIHdpdGgg
TlVNQSwgbWVtb3J5DQo+ID4gaGllcmFyY2h5DQo+ID4gYW5kIGRldmljZSBtZW1vcnksIFVzZSBO
VkRJTU0gYXMgTlVNQSBub2RlIGFuZCBOVU1BIEFQSSwgb3IgbWVtb3J5DQo+ID4gcmVjbGFpbSB3
aXRoIE5VTUEgYmFsYW5jaW5nLg0KPiANCj4gV2hhdCBhYm91dCBjYWNoZSBjb2hlcmVuY3kgYW5k
IGF0b21pYyA/IElmIGRldmljZSBibG9jayBhcmUgZXhwb3NlDQo+IHRocm91Z2ggUENJRSB0aGVu
IHRoZXJlIGlzIG5vIGNhY2hlIGNvaGVyZW5jeSBvciBhdG9taWMgYW5kIHRodXMNCj4gZGlyZWN0
IG1tYXAgd2lsbCBub3QgaGF2ZSB0aGUgZXhwZWN0ZWQgbWVtb3J5IG1vZGVsIHdoaWNoIHdvdWxk
DQo+IGJyZWFrIHByb2dyYW0gZXhwZWN0YXRpb24gb2YgYSBtbWFwLg0KDQpGb3IgdGhlIFBDSUUg
Y2FjaGUgY29oZXJlbmN5IGNhc2UgSSB3b3VsZCBlbnZpc2lvbiB0aGF0IHlvdSB3b3VsZCBtYXAN
CnRoZSBtZW1vcnkgYXMgcmVhZCBvbmx5IGludG8gdGhlIHByb2Nlc3MgYWRkcmVzcyBzcGFjZS4g
T25jZSBhIHdyaXRlDQpvY2N1cnMgSSB3b3VsZCB0aGVuIHJlbWFwIHRoZSBQQ0lFIG1lbW9yeSB0
byBhIHBhZ2UgaW4gdGhlIHByb3Bvc2VkDQpjYWNoaW5nIG1lY2hhbmlzbS4NCg0KSSBoYXZlIHRv
IHRoaW5rIG1vcmUgYWJvdXQgd2hhdCB0aGlzIG1lYW5zIGZvciBhdG9taWMgb3BlcmF0aW9ucy4N
Cg0KPiANCj4gVGhpcyBpcyBhbHNvIG9uZSBvZiB0aGUgcmVhc29ucyBpIGRvIG5vdCBzZWUgYSB3
YXkgZm9yd2FyZCB3aXRoIE5VTUENCj4gYW5kIGRldmljZSBtZW1vcnkuIEl0IGNhbiBkZXBhcnQg
ZnJvbSB0aGUgdXN1YWwgbWVtb3J5IHRvbyBtdWNoIHRvDQo+IGJlIGRyb3AgaW4gbGlrZSB0aGF0
IHRvIHVuYXdhcmUgYXBwbGljYXRpb24uDQoNCkkgaGF2ZSBzaW1pbGFyIGNvbmNlcm5zIGFuZCBh
bSB0cnlpbmcgdG8gc2VncmVnYXRlIHRoZSBkZXZpY2UgbWVtb3J5IHRvDQphd2FyZSBhcHBsaWNh
dGlvbnMuDQoNCj4gDQo+IEluIGFueSBjYXNlIHllcyB0aGlzIGtpbmQgb2YgbWVtb3J5IGZhbGxz
IGludG8gdGhlIGRldmljZSBtZW1vcnkgaQ0KPiB3aXNoIHRvIGRpc2N1c3MgZHVyaW5nIExTRi9N
TS4NCj4gDQo+IENoZWVycywNCj4gSsOpcsO0bWUNCj4gDQo=

