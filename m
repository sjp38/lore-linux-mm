Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09FF2C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:11:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DD8B2083B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:11:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="C0vftzKQ";
	dkim=pass (1024-bit key) header.d=sharedspace.onmicrosoft.com header.i=@sharedspace.onmicrosoft.com header.b="ZK2uIVMU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DD8B2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AEB58E00BE; Thu, 21 Feb 2019 18:11:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 337248E00B5; Thu, 21 Feb 2019 18:11:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B27C8E00BE; Thu, 21 Feb 2019 18:11:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C8CC88E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:11:57 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b8so270302pfe.10
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:11:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:accept-language
         :content-language:wdcipoutbound:content-id:content-transfer-encoding
         :mime-version;
        bh=78+z1grUE6qV0CcKonoGsjja7s41sLxiZgtK6h4zOfQ=;
        b=V5livx/7CAoOFpQqPZcy4OtT8sdk0LVS1hVlW2GM6nmf7oPgWCRelGULRhsvr09Wi2
         jXTnTYtBziuQa2Ip1tjSeCaBiUz9x3HoQ1/NFX1F/N4zogV9pWmIbJ+ww7OOuc6opF1G
         KJPNbZ/iklssmdptlf328fuxg0P81EqQjTKSU1M8u+z052/nweQs7P5JJfzEtggzsfts
         8nwDnUY+5+E8U/AUvQmXtZV6uJDbCsajW205aMgv1VOgfK0ZkeVmu4/tj4ZdwAoUANEV
         KLIxgLrQmfbKDOrS6ELqC49yyxXPz1NXEKkqd4FRKxxw+oSHDDGSMgDNvFCvZUrItFPD
         s5xQ==
X-Gm-Message-State: AHQUAuYAIuIDFWQXxYM0NJFJzpi4tXKVlIYw/9osCUTcMo8mqVVD2Xgb
	4OgPJRHlS4dIAwiHhcM49qWXZpJNCsz3gCZieTHcy6VeHdDlpeWSNRAG0GxYtqSx526AoJf3Eko
	k0Td+6891Aye2X+sf8lgXz86TeKvy4lXL2bihUCLk6wz2yoz/y4Vr6hObhOl2COz/CQ==
X-Received: by 2002:a63:2ad4:: with SMTP id q203mr952360pgq.43.1550790717360;
        Thu, 21 Feb 2019 15:11:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYr6e4MB4PbAB9r5yhX6wyzZPtQGaEHsXaV2vdABpT9H1Ibwq+C9V/T82EnNUYRWHmCe+4C
X-Received: by 2002:a63:2ad4:: with SMTP id q203mr952302pgq.43.1550790716360;
        Thu, 21 Feb 2019 15:11:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550790716; cv=none;
        d=google.com; s=arc-20160816;
        b=hohdP2E6smE8HOfIUp4xTLdG1qViGL13nJ0vkhtX8f5WSMDCPeLeNPZbMuTG56YbZq
         CJMcVdkLaUAWJb0eUVSwXItRy0iR20kFpxgfD/sNxov0N/1dT4E0piOvJ5XjkcTOsVk3
         T9LdvIL5kr/WRbUhjf+5mDy0D7EmUekpp5VDFgGsyerHhH9W2X7VUw3K5U3/fLORmiDE
         MLbBxQf20fhoiLunj7/ntGeuAPLG1PNTUhTk9KF9p6jFiKQZgyb1RKOrgtLD677g1zPG
         5reLhcqPv5gYRv4rfMdSjrnWuMzBmC99j0oBC1O5hHsJsNAdaDna3yQ2djK0Fc34HmcN
         AoyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:wdcipoutbound
         :content-language:accept-language:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=78+z1grUE6qV0CcKonoGsjja7s41sLxiZgtK6h4zOfQ=;
        b=U+SK88/w9Y9DHqrvvcX0qC53b+EL5QWgR/H6XIBi7jHw6KQX+mFSEIW0V8DCwbcGNX
         MCcmWXzrgW7nYs560cG+5OZMXzZhhg4I0xhoiEbF8U8rXO6b3X8D63khvJWTEg2llxMy
         JjzKfkOfPb0LFx+74JNwfkD1RnJdxVT9bJqhFbwJ1nXuPdd5Y/RFj3u92zUPCgyafh3W
         7dRzO/wAsnAzqOi6l9WSsOcu43E2GgOOyndIyfxNP90SVxBowi3kZMYWmgfTRA6zN0ZY
         CP5pm0O4gcPvqjAT7oofRTrjPEyH4H0ey9o8+pskBi5UaMwrNc+fY62Jug29CmqEMgdF
         UgDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=C0vftzKQ;
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector1-wdc-com header.b=ZK2uIVMU;
       spf=pass (google.com: domain of prvs=948d93489=adam.manzanares@wdc.com designates 216.71.154.42 as permitted sender) smtp.mailfrom="prvs=948d93489=Adam.Manzanares@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa4.hgst.iphmx.com (esa4.hgst.iphmx.com. [216.71.154.42])
        by mx.google.com with ESMTPS id t135si137597pgb.467.2019.02.21.15.11.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:11:56 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=948d93489=adam.manzanares@wdc.com designates 216.71.154.42 as permitted sender) client-ip=216.71.154.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=C0vftzKQ;
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector1-wdc-com header.b=ZK2uIVMU;
       spf=pass (google.com: domain of prvs=948d93489=adam.manzanares@wdc.com designates 216.71.154.42 as permitted sender) smtp.mailfrom="prvs=948d93489=Adam.Manzanares@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1550790717; x=1582326717;
  h=from:to:cc:subject:date:message-id:content-id:
   content-transfer-encoding:mime-version;
  bh=78+z1grUE6qV0CcKonoGsjja7s41sLxiZgtK6h4zOfQ=;
  b=C0vftzKQKhS8g1da52PWiaK0GLIJvReydgtjSpk/cJXN37JnRgOkDdgl
   UQAzNI22wl0nps8Y7eRDA/ltWTzF6qKxmeMHsP/VkwUlF9KPP8FhBMJ0u
   xybgjD4FVWVKVzViVytSWuQDrqnJ5H3ALtmWxR72lsJpNKL9WhwcMFqyv
   vFzHS6OrPilEXRjTQ/96pc7TLBa1Nely+xCRv5CtmJFG7qqURezAeqOj2
   hvSe6rdtlDlm3Y6wWNaiV9wUonVlaNCqNKbn8FP6O/FDfLVsocgGlsCGB
   njsCyrsgKmZscPQVrp33IznkNr9f71kVMarYDdId6JxoJL83MkRje/km6
   A==;
X-IronPort-AV: E=Sophos;i="5.58,397,1544457600"; 
   d="scan'208";a="101886597"
Received: from mail-dm3nam03lp2055.outbound.protection.outlook.com (HELO NAM03-DM3-obe.outbound.protection.outlook.com) ([104.47.41.55])
  by ob1.hgst.iphmx.com with ESMTP; 22 Feb 2019 07:11:55 +0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=sharedspace.onmicrosoft.com; s=selector1-wdc-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=78+z1grUE6qV0CcKonoGsjja7s41sLxiZgtK6h4zOfQ=;
 b=ZK2uIVMUuOwL8RBcICUXmjrYmTPG75qlT0pPoWh9meXyxifw/cszSNToei6TS/GrZ2UDBcFfgHWRU7g6N7dX//NEac1eXHNDq6y4KLFcyNXB2PRFrcNbtHdVI43lcHQhsPob7NZVRhf0zUC06G0zYuAM8ekH+ihJO8UqgHdCsKU=
Received: from BYAPR04MB4357.namprd04.prod.outlook.com (20.176.251.147) by
 BYAPR04MB4310.namprd04.prod.outlook.com (20.176.251.29) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.14; Thu, 21 Feb 2019 23:11:52 +0000
Received: from BYAPR04MB4357.namprd04.prod.outlook.com
 ([fe80::91f1:a2af:8793:94a2]) by BYAPR04MB4357.namprd04.prod.outlook.com
 ([fe80::91f1:a2af:8793:94a2%7]) with mapi id 15.20.1622.020; Thu, 21 Feb 2019
 23:11:52 +0000
From: Adam Manzanares <Adam.Manzanares@wdc.com>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"willy@infradead.org" <willy@infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "yang.shi@linux.alibaba.com"
	<yang.shi@linux.alibaba.com>, "dan.j.williams@intel.com"
	<dan.j.williams@intel.com>, "cl@linux.com" <cl@linux.com>,
	"jglisse@redhat.com" <jglisse@redhat.com>, "mhocko@suse.com"
	<mhocko@suse.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>,
	"jack@suse.cz" <jack@suse.cz>
Subject: [LSF/MM TOPIC] Page Cache Flexibility for NVM
Thread-Topic: [LSF/MM TOPIC] Page Cache Flexibility for NVM
Thread-Index: AQHUyjrUW2lvg3E88ESemij+/GgUJA==
Date: Thu, 21 Feb 2019 23:11:51 +0000
Message-ID: <85ddda85755bf15ed2e56bce21f711ae8154d304.camel@wdc.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Adam.Manzanares@wdc.com; 
x-originating-ip: [199.255.44.250]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c4827700-9f61-44ec-d63b-08d69851f6fa
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:BYAPR04MB4310;
x-ms-traffictypediagnostic: BYAPR04MB4310:
wdcipoutbound: EOP-TRUE
x-microsoft-exchange-diagnostics:
 =?utf-8?B?MTtCWUFQUjA0TUI0MzEwOzIzOnFPd2k2eGM3bGtSMDJ6bXpVRWxHWmVZSWs3?=
 =?utf-8?B?M29JcVZRTS8yZ1RXdG9yMmZZSU02YTh6WWlvdXQwRlFlcDFkMkNJSWY3M2kr?=
 =?utf-8?B?eGdoSGs0TFBiVEVPemZRWjZMMkhNR0owa2xTN3dLbkV4YXczS25RL3FlNnFx?=
 =?utf-8?B?YU9jSThGaTY3TmxxVFlxZWV4MlpXWnNhcDI2VVdmbEJuV3AraENLTFliK2Uv?=
 =?utf-8?B?clh3L0twblhWS203MGJDZ1R4Sm93SzUvRFN2Mi9jN2E1dmt4ZDBCY3E0enBJ?=
 =?utf-8?B?WUhNTmczcUsyRGEwcHR4NEM5SzhIRytLRkFIN0tCT3crLzUzcEV2Rk41cXFU?=
 =?utf-8?B?cUt2Tzg1UkVSU3lvSllHbmFKNjIzeGxXSFllR1dFS0ZvdEhHYlFxWm5wOXlW?=
 =?utf-8?B?dFNlZnZQNTNydEdIQU45UGd0akJ4RlN1RUhxWHBBZmkyc3ROWU5wMnFaTCt1?=
 =?utf-8?B?czR4MFBwc05xbWhvUjQwYW81bnU2SjVTOHFmZEMrQ3dFR2dBKytPa29vcko2?=
 =?utf-8?B?bnJmZFhuV2drS2MvbWRjM2FnZll2Nnk4Sk5iMnQ2bmFORnUxeWRuRHFhRHpY?=
 =?utf-8?B?ZGs0Y0hKMXZtbXFCWUVNZGZEK3ZLbXhKUXoxdVlQZXBpRklZMndaVEYzU2J0?=
 =?utf-8?B?NW5Ha0lPNnZiV0NvZEZSalY2UUlCUFZya0tpUi9sWWZYMWFIWm5NZkdPNFhh?=
 =?utf-8?B?elNVNHk5UnI0ajJKTlVIRERqWGphVU90NFBWZGViTmpRUkIwSmg2U0JQeTBD?=
 =?utf-8?B?ZTl2ZTFERldZblJrd3ZYdnVzUjIvbFdsZ1VJU2dwbDJjb2xQdWFBeXoxczdp?=
 =?utf-8?B?N056TnN4OU95dk1pQmh0QXVzeWJDNHRvMmFpYVF2UGZNYyt0OEE4TFVSNVJz?=
 =?utf-8?B?aDNFTXk3YjRtdFRIMGZRMGxOR2NqTzhkbCtWTE1yM052a3YrU2c3enRMYk5q?=
 =?utf-8?B?dHFwWnFtenJyVkUrWFpYYk9odmNpU3lsb1BEUFUrbUVxOElQL0lzbFNGQkt6?=
 =?utf-8?B?RXoxUFg1ZG5SR1VKejExa0FSR3ZmN1ZVdy9zcDlhTmMzSk9TZm9nQjQ3c2kr?=
 =?utf-8?B?bzJTV2lMWG91NnFkaXdUZitPanB0eGN0ZkYyZlFZdFQ4RXgrN2ZMek9heVk4?=
 =?utf-8?B?Rllxb0VPU0l6RGV0Y0RsRkh1ZGNzd1NxcnBtbytBb2FUeHEyeXFwQk5OcFBv?=
 =?utf-8?B?azNLUVVKQ0JUODNhM3RzbzRwUlQ0VzE1WTZOanJ1aEJPOTNObndrRmxFWGFj?=
 =?utf-8?B?L0pxcko1K1NqeEFmdXVTS08zWXVBSXA1TTc1bEVCS1NRdU9KYytNeVRnR0wv?=
 =?utf-8?B?QnI1QSt0NGJQb1pXNDFnNEI1WW9rZXBNWHBlcDVaZTNSVDMydUUxN2ZoaE5S?=
 =?utf-8?B?Mnh4MWV2ZmVuZERQNWROMWRaMFNscnEvdFI0aWJ2VUVBKzI5NzIyWEVZV1NM?=
 =?utf-8?B?UVBJbGYyZFBaRTBxMFVEQ1B6blpoN2V3RFZvSzJpbk96WStSWERyVnpEdWJJ?=
 =?utf-8?B?R3REYTBkVk41U0gxNENXTkhkeWFYaXBEclBmWjBYVGk5RzdxR2JYV21IU2Za?=
 =?utf-8?B?WXZUZGljNU5rOFc3SHJ6aHo0SWpZd28zRWlLM1FiUW9DcmIwaHpSdnE3MjZt?=
 =?utf-8?Q?dLMdnIW4DOhV4QeS7P8d?=
x-microsoft-antispam-prvs:
 <BYAPR04MB4310B43FDF9DA534150FD600F07E0@BYAPR04MB4310.namprd04.prod.outlook.com>
x-forefront-prvs: 09555FB1AD
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(136003)(396003)(366004)(39860400002)(376002)(346002)(199004)(189003)(72206003)(186003)(71200400001)(68736007)(2616005)(6512007)(26005)(99286004)(6486002)(86362001)(256004)(14444005)(316002)(8676002)(97736004)(4326008)(6116002)(478600001)(3846002)(81166006)(476003)(81156014)(66066001)(118296001)(8936002)(14454004)(5660300002)(7736002)(71190400001)(54906003)(106356001)(105586002)(2906002)(2351001)(305945005)(5640700003)(6506007)(6916009)(25786009)(486006)(6436002)(36756003)(2501003)(53936002)(102836004)(7416002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR04MB4310;H:BYAPR04MB4357.namprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 0xNkX344OsWfTq5qs3UaMB27td77WWTgeifpfuAeesWvtcyPqh8CefBgU+6XUzbE946D1cyS35LsuQvEw6zk1hA9xFrnaxOARvvcRW07hlhZLTCPU+J2sdcjlwfKl7n6qDBtvsrGlyovzrJ4jxyqzcEm65QJfjOJlzc0i8TrGLm68sk9zpMlcBux9J4xKCf6gqCbQI+wRVUw7xPfPnbcuHw/I6V+V2Mj+3SJjXs04r6oa/hb2VcUCsjlb18AKHN4eJswW6Kgf/kOA/BbiqjIDCNzqR4UiY6fWW4Vzng4duz/TxZOvXnImFBC4FKAGqOwzC7V7PglqcW8phSYTcqqHyjTQOMu7HGpo9tBs9IHMU0bBnDW5a25a4a0NAax8klSXZcK1ASmkiGq4WbdODFRUryGyXx9FrvX3MoV4pm4GIQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <C01446860AD7F04388BEAEFCCD6938BE@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: wdc.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c4827700-9f61-44ec-d63b-08d69851f6fa
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Feb 2019 23:11:52.0689
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b61c8803-16f3-4c35-9b17-6f65f441df86
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR04MB4310
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGVsbG8sDQoNCkkgd291bGQgbGlrZSB0byBhdHRlbmQgdGhlIExTRi9NTSBTdW1taXQgMjAxOS4g
SSdtIGludGVyZXN0ZWQgaW4NCnNldmVyYWwgTU0gdG9waWNzIHRoYXQgYXJlIG1lbnRpb25lZCBi
ZWxvdyBhcyB3ZWxsIGFzIFpvbmVkIEJsb2NrDQpEZXZpY2VzIGFuZCBhbnkgaW8gZGV0ZXJtaW5p
c20gdG9waWNzIHRoYXQgY29tZSB1cCBpbiB0aGUgc3RvcmFnZQ0KdHJhY2suIA0KDQpJIGhhdmUg
YmVlbiB3b3JraW5nIG9uIGEgY2FjaGluZyBsYXllciwgaG1tYXAgKGhldGVyb2dlbmVvdXMgbWVt
b3J5DQptYXApIFsxXSwgZm9yIGVtZXJnaW5nIE5WTSBhbmQgaXQgaXMgaW4gc3Bpcml0IGNsb3Nl
IHRvIHRoZSBwYWdlDQpjYWNoZS4gVGhlIGtleSBkaWZmZXJlbmNlIGJlaW5nIHRoYXQgdGhlIGJh
Y2tlbmQgZGV2aWNlIGFuZCBjYWNoaW5nDQpsYXllciBvZiBobW1hcCBpcyBwbHVnZ2FibGUuIElu
IGFkZGl0aW9uLCBobW1hcCBzdXBwb3J0cyBEQVggYW5kIHdyaXRlDQpwcm90ZWN0aW9uLCB3aGlj
aCBJIGJlbGlldmUgYXJlIGtleSBmZWF0dXJlcyBmb3IgZW1lcmdpbmcgTlZNcyB0aGF0IG1heQ0K
aGF2ZSB3cml0ZS9yZWFkIGFzeW1tZXRyeSBhcyB3ZWxsIGFzIHdyaXRlIGVuZHVyYW5jZSBjb25z
dHJhaW50cy4NCkxhc3RseSB3ZSBjYW4gbGV2ZXJhZ2UgaGFyZHdhcmUsIHN1Y2ggYXMgYSBETUEg
ZW5naW5lLCB3aGVuIG1vdmluZw0KcGFnZXMgYmV0d2VlbiB0aGUgY2FjaGUgd2hpbGUgYWxzbyBh
bGxvd2luZyBkaXJlY3QgYWNjZXNzIGlmIHRoZSBkZXZpY2UNCmlzIGNhcGFibGUuDQoNCkkgYW0g
cHJvcG9zaW5nIHRoYXQgYXMgYW4gYWx0ZXJuYXRpdmUgdG8gdXNpbmcgTlZNcyBhcyBhIE5VTUEg
bm9kZQ0Kd2UgZXhwb3NlIHRoZSBOVk0gdGhyb3VnaCB0aGUgcGFnZSBjYWNoZSBvciBhIHZpYWJs
ZSBhbHRlcm5hdGl2ZSBhbmQNCmhhdmUgdXNlcnNwYWNlIGFwcGxpY2F0aW9ucyBtbWFwIHRoZSBO
Vk0gYW5kIGhhbmQgb3V0IG1lbW9yeSB3aXRoDQp0aGVpciBmYXZvcml0ZSB1c2Vyc3BhY2UgbWVt
b3J5IGFsbG9jYXRvci4NCg0KVGhpcyB3b3VsZCBpc29sYXRlIHRoZSBOVk1zIHRvIG9ubHkgYXBw
bGljYXRpb25zIHRoYXQgYXJlIHdlbGwgYXdhcmUNCm9mIHRoZSBwZXJmb3JtYW5jZSBpbXBsaWNh
dGlvbnMgb2YgYWNjZXNzaW5nIE5WTS4gSSBiZWxpZXZlIHRoYXQgYWxsDQpvZiB0aGlzIHdvcmsg
Y291bGQgYmUgc29sdmVkIHdpdGggdGhlIE5VTUEgbm9kZSBhcHByb2FjaCwgYnV0IHRoZSB0d28N
CmFwcHJvYWNoZXMgYXJlIHNlZW1pbmcgdG8gYmx1ciB0b2dldGhlci4NCg0KVGhlIG1haW4gcG9p
bnRzIEkgd291bGQgbGlrZSB0byBkaXNjdXNzIGFyZToNCg0KKiBJcyB0aGUgcGFnZSBjYWNoZSBt
b2RlbCBhIHZpYWJsZSBhbHRlcm5hdGl2ZSB0byBOVk0gYXMgYSBOVU1BIE5PREU/DQoqIENhbiB3
ZSBhZGQgbW9yZSBmbGV4aWJpbGl0eSB0byB0aGUgcGFnZSBjYWNoZT8NCiogU2hvdWxkIHdlIGZv
cmNlIHNlcGFyYXRpb24gb2YgTlZNIHRocm91Z2ggYW4gZXhwbGljaXQgbW1hcD8NCg0KSSBiZWxp
ZXZlIHRoaXMgZGlzY3Vzc2lvbiBjb3VsZCBiZSBtZXJnZWQgd2l0aCBOVU1BLCBtZW1vcnkgaGll
cmFyY2h5DQphbmQgZGV2aWNlIG1lbW9yeSwgVXNlIE5WRElNTSBhcyBOVU1BIG5vZGUgYW5kIE5V
TUEgQVBJLCBvciBtZW1vcnkNCnJlY2xhaW0gd2l0aCBOVU1BIGJhbGFuY2luZy4NCg0KSGVyZSBh
cmUgc29tZSBwZXJmb3JtYW5jZSBudW1iZXJzIG9mIGhtbWFwIChpbiBkZXZlbG9wbWVudCk6DQoN
CkFsbCBudW1iZXJzIGFyZSBjb2xsZWN0ZWQgb24gYSA0R2lCIGhtbWFwIGRldmljZSB3aXRoIGEg
MTI4TWlCIGNhY2hlLg0KRm9yIHRoZSBtbWFwIHRlc3RzIEkgdXNlZCBjZ3JvdXBzIHRvIGxpbWl0
IHRoZSBwYWdlIGNhY2hlIHVzYWdlIHRvDQoxMjhNaUIuIEFsbCByZXN1bHRzIGFyZSBhbiBhdmVy
YWdlIG9mIDEwIHJ1bnMuIFcgYW5kIFIgYWNjZXNzIHRoZQ0KZW50aXJlIGRldmljZSB3aXRoIGFs
bCB0aHJlYWRzIHNlZ3JlZ2F0ZWQgaW4gdGhlIGFkZHJlc3Mgc3BhY2UuIFJSDQpyZWFkcyB0aGUg
ZW50aXJlIGRldmljZSByYW5kb21seSA4IGJ5dGVzIGF0IGEgdGltZSBhbmQgaXMgbGltaXRlZCB0
bw0KOE1pQiBvZiBkYXRhIGFjY2Vzc2VkLg0KDQpobW1hcCBicmQgdnMuIG1tYXAgb2YgYnJkDQoN
CglobW1hcAkJCW1tYXAJCQkNCg0KVGhyZWFkcyBXICAgICBSICAgICBSUiAJICBXIAlSICAgICBS
UiANCg0KMSAgCTcuMjEgIDUuMzkgIDUuMDQgIDYuODAgIDUuNjMgIDUuMjMJDQoyCTUuMTkgIDMu
ODcgIDMuNzQgIDQuNjYgIDMuMzMgIDMuMjANCjQJMy42NSAgMi45NSAgMy4wNyAgMy41MyAgMi4y
NiAgMi4xOA0KOAk0LjUyICAzLjQzICAzLjU5ICA0LjMwICAxLjk4ICAxLjg4DQoxNgk1LjAwICAz
Ljg1ICAzLjk4ICA0LjkyICAyLjAwICAxLjk5DQoNCg0KDQpNZW1vcnkgQmFja2VuZCBUZXN0IChE
YXggY2FwYWJsZSkNCg0KCWhtbWFwICAgICAgICAgICAgIGhtbWFwLWRheCAgICAgICAgIGhtbWFw
LXdycHJvdGVjdA0KDQpUaHJlYWRzCVcgICAgIFIgICAgIFJSICAgIFcgICAgIFIgICAgIFJSICAg
IFcgICAgIFIgICAgIFJSIA0KDQoxICAgICAgCTYuMjkgIDQuOTQgIDQuMzcgIDIuNTQgIDEuMzYg
IDAuMTYgIDcuMTIgIDIuMTMgIDAuNzMgDQoyCTQuNjIgIDMuNjMgIDMuNTcgIDEuNDEgIDAuNjkg
IDAuMDggIDUuMDYgIDEuMTQgIDAuNDENCjQJMy40NSAgMi45NyAgMy4xMSAgMC43NyAgMC4zNiAg
MC4wNCAgMy42NiAgMC42MyAgMC4yNQ0KOAk0LjEwICAzLjUzICAzLjcxICAwLjQ0ICAwLjE5ICAw
LjAyICA0LjAzICAwLjM1ICAwLjE3DQoxNgk0LjYwICAzLjk4ICA0LjA0ICAwLjM0ICAwLjE2ICAw
LjAyICA0LjUyICAwLjI3ICAwLjE0DQoNCg0KVGhhbmtzLA0KQWRhbQ0KDQoNCg0KDQo=

