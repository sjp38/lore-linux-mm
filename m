Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E669C43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 08:38:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D80620836
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 08:38:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="srV9Zt5h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D80620836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D6F38E000A; Sun,  3 Mar 2019 03:38:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2849D8E0001; Sun,  3 Mar 2019 03:38:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FF2F8E000A; Sun,  3 Mar 2019 03:38:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7A728E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 03:38:25 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id h37so1155306eda.7
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 00:38:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=rERBFT+rlroi6KUzgJZ0u6Le1VEI4lkf8mwpT+DLLBU=;
        b=tdNJ5wJybjslWc7KAKKXQEH4QLF3fDqH8z5VRQYmw8YOBpEq/cIgosvMtoDMqGscvS
         JUW61UX3i4w9QnMRbxyIRLCP9DUDXvJcYOHPEtS7YXavFajsl7U8QZcxhtcuFtYaRcrn
         EIV3Qkk+a9lyfkiqb8j7wZzk29TZJX4KXmM6a1RDlOALyJaEIGcemYUgHAXn0zhA5rfn
         K7Ge23Ub33N4Szca54tkrMF+d9xyp/9xtB3u4/pCEX6mBunwfimwOhlwAXGAkmc1rxzM
         Z6GCNzqVC62IJk/iTEVpAfkP7bfxEHO87MjQ7lMO1ctenqCKJbfxGoeqM9xXZ0SJOSSL
         QlKQ==
X-Gm-Message-State: APjAAAW2KTwfh4lUvvTDUpTm7PqhZqrux8pO2MVC+NaKdoMhchOzE6Fa
	39bZASi/3Bcrm/UbsS3Wq3GD1mxfKQzJextC0BR984JnefdUdjWOZkZbHavjcEhekA2EH8ohd0N
	tJk6dsg7h0fuGGF7kGQRQ3ST19pj6nRxOh4My+/lD1T7tmlTq5TernUE2HTyTvODUkA==
X-Received: by 2002:a50:89f3:: with SMTP id h48mr10903383edh.273.1551602305163;
        Sun, 03 Mar 2019 00:38:25 -0800 (PST)
X-Google-Smtp-Source: APXvYqyYukng7LUaAm9+8XWC3lH6YgwYKkunz75G3Y8k/cQMG5ARFXcqOuATdbaBB6ncl3rgThv8
X-Received: by 2002:a50:89f3:: with SMTP id h48mr10903348edh.273.1551602304343;
        Sun, 03 Mar 2019 00:38:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551602304; cv=none;
        d=google.com; s=arc-20160816;
        b=b8EDMOKiff6bbcNdexI7dTXjcaf6GLLZmcOJEx4ePVQyexT7R3k0CJKS+BCFlpzH8V
         JAONbgt6oxBT3wegxgST1glR8eJ1rhRQBWiXwfeG4Uajcc9L8XJ0Yh1RjcVzGkIDJJAC
         DfcL6kPBHE+E08OrZ+20Kn1Y0ZODem+D5RlzpQreiGZka/SAJuNma7aJdK5UYNk9wgV6
         VTle/EixYXirDkgKhlYFw4CjQMLf21ayoszjlSL6sCmP4VvU2C5jcoRX7Zl63+MG5VCy
         SHhhjbWF4ONFBsl52Un+70CHg18gdL4Uqq5D5HXCNP1CWq1UhUCjTLutPK//cKSjHh27
         9SdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=rERBFT+rlroi6KUzgJZ0u6Le1VEI4lkf8mwpT+DLLBU=;
        b=XM0dORLiytGufMFJMfXZfyEe/NCKg8YlZgal9FsKVFL9xtFqf19loHkPuW6LdDdI16
         G805euiE2bY0pNX4DyWbadMPR0qnU6ttu/d9x4QvlG3VACv7V7IPsSeJkikZI0XteyZh
         TrmSt6jnx/IiWqU876AcB7HKZdm1XnoU8CmmpBXj2vxRFK2qBIzL5JIK+sFhxWG86B22
         uhpVZjzEF3k7TFqJHxvqHRjTasOPe6SBTRybMAMGd0bINUT0kwQgwzdZ0yFzCf57jaCq
         XbWwMe0UZGb2Li5yqdzp0N8bs6KaQrp7emUzzHS2DCR+nWkSfYr7Y5rJVUjH0aobA6xV
         Vx7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=srV9Zt5h;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.8.48 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80048.outbound.protection.outlook.com. [40.107.8.48])
        by mx.google.com with ESMTPS id r33si1208324eda.202.2019.03.03.00.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 03 Mar 2019 00:38:24 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.8.48 as permitted sender) client-ip=40.107.8.48;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=srV9Zt5h;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.8.48 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=rERBFT+rlroi6KUzgJZ0u6Le1VEI4lkf8mwpT+DLLBU=;
 b=srV9Zt5hxd04febN3g2YzbYjZano/40+oQfWbGS1ytL4sdzQI0Svw0MczjeBBWpSi9Zr8gfbDS4tTDKBUJQHugps+5eS2B8dKtCUNomOESRH/mzmO7XEqSy7jOjGxtu50d9RLIga7n/MpojNB5y1C+fLMqtNzKoMPDqS8Xdugj0=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB5988.eurprd04.prod.outlook.com (20.178.115.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.17; Sun, 3 Mar 2019 08:38:22 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.019; Sun, 3 Mar 2019
 08:38:22 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>, Christoph
 Lameter <cl@linux.com>
CC: Vlad Buslov <vladbu@mellanox.com>, "kernel-team@fb.com"
	<kernel-team@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 12/12] percpu: use chunk scan_hint to skip some scanning
Thread-Topic: [PATCH 12/12] percpu: use chunk scan_hint to skip some scanning
Thread-Index: AQHUzwwDNbhSvpuMSEiQ9tPcWjkXuaX5mr2g
Date: Sun, 3 Mar 2019 08:38:22 +0000
Message-ID:
 <AM0PR04MB4481EA4F39764CD4E6D4D43788700@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-13-dennis@kernel.org>
In-Reply-To: <20190228021839.55779-13-dennis@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 734f63d0-ff3d-486c-f472-08d69fb39866
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB5988;
x-ms-traffictypediagnostic: AM0PR04MB5988:
x-microsoft-exchange-diagnostics:
 =?gb2312?B?MTtBTTBQUjA0TUI1OTg4OzIzOmJ5T1UxSUM5alRMd3huN0p5UkMwKzFaVzZL?=
 =?gb2312?B?SkNmdk9JbXJLYkE1bEQwNFI0ak5aZ1hQZDRmRWF6ZnRRN3E4b3RFVldoNTJ4?=
 =?gb2312?B?Y0xkdXZ3MWdhbU4xOXdTR04rNVFOMVJzaE1PaFBkTFJPZHAyU2Fhb1ZKd0JQ?=
 =?gb2312?B?eGxFUDZuWjFscFhWaU9BSzFuZWlVbkQvck1JRFcrM2trbm5OREtob0JaWnNU?=
 =?gb2312?B?djk3VDRDaExCdTNCTnEvVzl4eDFDb2pYaWV5aGx4dGF1ZTYyNUVTL2NXcE93?=
 =?gb2312?B?TkNTZ0VnME4yUXBsUkJNNW1YYXFvN3JpSkxNTmFMRkZLejU2ZHJZbk1LT1Ju?=
 =?gb2312?B?NlVTYzVqbS9XYld0VXFENUE2RlViYllWb1phMGE0VEgzSzVpNGkrU0JBTE4x?=
 =?gb2312?B?ME5FNjF1OXZqYVo4cExMYmV6ZWdhVnJ4RnlQUHdIQ3dHV1hQVmsvOE9mUkhK?=
 =?gb2312?B?bmxBenA0VGt1RTIxaENHd25mL283d2F6ZE55TGZVam4rd0MrRlNDcnFrNXVU?=
 =?gb2312?B?WTBvYkRNa3UxQzFWdkNLY2p0OUp0ZmZjY1U2NjlaendLVmovQWhBOTRUY1ZP?=
 =?gb2312?B?UUlibGR6Zks2aVhiRGk3R01UR0tJaFk4RVVDeDJXV09IMy9iWGZ1RnVoMU8x?=
 =?gb2312?B?YytONFhYTkU5ZTM4Qkx6a1VQTE9PSTNTQmRMNGpRMWdqUm00NCtObWNlaTdp?=
 =?gb2312?B?Mi9kRnZPUWczajFFeFhXL045amQ3eW91cTRSU0N6ZDdPcklGQ3ZSdG5TbFlq?=
 =?gb2312?B?aDNxOS9nR1hVVWtzUkcrTjJnZGpLWTBmZFozUjBoQmVkSHpsOUZxY2R4cFVJ?=
 =?gb2312?B?UnFZTXBLeUF1V2N2dU4yQ3pMWW5mY1BuK215dW9FSGRxdXFkelJYckdPYmZN?=
 =?gb2312?B?NFRGd1JLQjhnalBQSExwbXhyU25JYVo5cUQvb210dWZJTkIvWnd6eW9tSC9S?=
 =?gb2312?B?OHUvQ3g0QzdzNXJzdENSczlPWjlJRHRab01WQVFMb2FRanJKb1g2d3RRNzdO?=
 =?gb2312?B?WGIyZndqaThmU3ZGZHBkcVZDSlNzaGJMRXhpdzZzNmg4YzlUakovQSs2WlVL?=
 =?gb2312?B?b0hnZG1MWWRUeVVUWUM0MHM0cnVNRmdwU2x1K1VudWdSL2t3blA5QmlzSjhN?=
 =?gb2312?B?RE5iM010UEFIemRyUVhDbVdha1czdHdFT01kYnI3bzc5UHk4aCsyV2dLUGNV?=
 =?gb2312?B?bTl0UjlXUkpONFdPZzN0VEpTREY1bkhjUVZTYko1ektNNWtCUERXekhta01X?=
 =?gb2312?B?QWFCd0s0SmNQQnZEVkpURXJDMXIyclIzTnhQYmhON2Q5LzdDNE10RklIaW9L?=
 =?gb2312?B?TWRlN3pmd2Z0bFlURnRnUG5QQnUzRGROTmxZL0lOZWJZMWtRTE9JdWNEZlNt?=
 =?gb2312?B?bEgvbjdMR2pDYy9zTENQVFozTG5KeTF3SnlYQ1hjVGJ5YWppZUhkN3dhUXky?=
 =?gb2312?B?T0MzM3I1UEpqdEd4M0o2ODEyTVZsOW1pTlRaNFBINE5GLzRxbWpKWjUwN3Q3?=
 =?gb2312?B?dVJCU21PUG8xeUpvcnZaeENFSFRQWC9qNVRQT043L0doNDJqVU5tdzNaQTkz?=
 =?gb2312?B?ZXRLWGxQK0pOMlBnSlRId1U5ZFplRFFENXZBYjlMa0UrMTN1eHE5OWtHUU5i?=
 =?gb2312?B?Q3MzdmhzRCt1MnJTck8vdVJyc3ZvdWl4SWxkOWM5d0VOL3dpQVZxUFpnWUYx?=
 =?gb2312?B?UERQeWs4Y0JxSGdROFRPS3J3MFRJUkwzN0pTNXRqdnN6MExmcGg1T21JMzg3?=
 =?gb2312?B?RjFEc2w2RmNFOVhZeWxqZz09?=
x-microsoft-antispam-prvs:
 <AM0PR04MB59889F188CB721EF7F8C034A88700@AM0PR04MB5988.eurprd04.prod.outlook.com>
x-forefront-prvs: 096507C068
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(39860400002)(136003)(376002)(396003)(346002)(13464003)(189003)(199004)(14454004)(446003)(11346002)(33656002)(68736007)(102836004)(76176011)(53546011)(6506007)(476003)(7696005)(6246003)(486006)(2906002)(7736002)(81156014)(305945005)(74316002)(8676002)(81166006)(8936002)(71200400001)(71190400001)(99286004)(44832011)(186003)(26005)(52536013)(478600001)(105586002)(106356001)(66066001)(97736004)(5660300002)(3846002)(9686003)(6116002)(229853002)(6436002)(256004)(53936002)(25786009)(14444005)(86362001)(55016002)(4326008)(54906003)(316002)(110136005);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB5988;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 wxhIp8zfUREucqRpU7ZEhCEm6Yw8R8QoulFY+I2/tUOg96Ts7/H1OH0uMT69ERAoFFuXylaEr1x5nIYzojszysePchJp55TPYYJ/OkIbdjDq9aeL6EuRCRs/hp7lK8T7wJzcMQJpNX2uXRDj3Tz2xwx8M50xGRXiIizCbaXxjRB1GzhiLbnrxgzXWU8LwtICykVJru2Gm78LPX+bbmYg3okh4pfDzzSOw4yDtaqVJqtQAfvyc2Hk8ERRGdg1LYMTIy8mUV/eYcXvJ2b36RGPW/MAtMrUJW4SeuhmL9E1m+66bSGNnM1I5LPms8+6vHoikc4RXeFR5WZX1+b9YRhqx2E7P63HzgKd6LuOh4yy8GTNUo6M1gJwq27ipKp9cBR+zVJcVOPfuZoKQevTUX+1CvvfMpcZ+Auy/YuUl/JzQpY=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 734f63d0-ff3d-486c-f472-08d69fb39866
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Mar 2019 08:38:22.3519
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB5988
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogb3duZXItbGludXgtbW1A
a3ZhY2sub3JnIFttYWlsdG86b3duZXItbGludXgtbW1Aa3ZhY2sub3JnXSBPbg0KPiBCZWhhbGYg
T2YgRGVubmlzIFpob3UNCj4gU2VudDogMjAxOcTqMtTCMjjI1SAxMDoxOQ0KPiBUbzogRGVubmlz
IFpob3UgPGRlbm5pc0BrZXJuZWwub3JnPjsgVGVqdW4gSGVvIDx0akBrZXJuZWwub3JnPjsgQ2hy
aXN0b3BoDQo+IExhbWV0ZXIgPGNsQGxpbnV4LmNvbT4NCj4gQ2M6IFZsYWQgQnVzbG92IDx2bGFk
YnVAbWVsbGFub3guY29tPjsga2VybmVsLXRlYW1AZmIuY29tOw0KPiBsaW51eC1tbUBrdmFjay5v
cmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogW1BBVENIIDEyLzEy
XSBwZXJjcHU6IHVzZSBjaHVuayBzY2FuX2hpbnQgdG8gc2tpcCBzb21lIHNjYW5uaW5nDQo+IA0K
PiBKdXN0IGxpa2UgYmxvY2tzLCBjaHVua3Mgbm93IG1haW50YWluIGEgc2Nhbl9oaW50LiBUaGlz
IGNhbiBiZSB1c2VkIHRvIHNraXANCj4gc29tZSBzY2FubmluZyBieSBwcm9tb3RpbmcgdGhlIHNj
YW5faGludCB0byBiZSB0aGUgY29udGlnX2hpbnQuDQo+IFRoZSBjaHVuaydzIHNjYW5faGludCBp
cyBwcmltYXJpbHkgdXBkYXRlZCBvbiB0aGUgYmFja3NpZGUgYW5kIHJlbGllcyBvbiBmdWxsDQo+
IHNjYW5uaW5nIHdoZW4gYSBibG9jayBiZWNvbWVzIGZyZWUgb3IgdGhlIGZyZWUgcmVnaW9uIHNw
YW5zIGFjcm9zcyBibG9ja3MuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBEZW5uaXMgWmhvdSA8ZGVu
bmlzQGtlcm5lbC5vcmc+DQo+IC0tLQ0KPiAgbW0vcGVyY3B1LmMgfCAzNiArKysrKysrKysrKysr
KysrKysrKysrKysrKystLS0tLS0tLS0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAyNyBpbnNlcnRpb25z
KCspLCA5IGRlbGV0aW9ucygtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL21tL3BlcmNwdS5jIGIvbW0v
cGVyY3B1LmMNCj4gaW5kZXggMTk3NDc5ZjJjNDg5Li40MGQ0OWQ3ZmIyODYgMTAwNjQ0DQo+IC0t
LSBhL21tL3BlcmNwdS5jDQo+ICsrKyBiL21tL3BlcmNwdS5jDQo+IEBAIC03MTEsMjAgKzcxMSwz
MSBAQCBzdGF0aWMgdm9pZCBwY3B1X2Jsb2NrX3VwZGF0ZV9zY2FuKHN0cnVjdA0KPiBwY3B1X2No
dW5rICpjaHVuaywgaW50IGJpdF9vZmYsDQo+ICAvKioNCj4gICAqIHBjcHVfY2h1bmtfcmVmcmVz
aF9oaW50IC0gdXBkYXRlcyBtZXRhZGF0YSBhYm91dCBhIGNodW5rDQo+ICAgKiBAY2h1bms6IGNo
dW5rIG9mIGludGVyZXN0DQo+ICsgKiBAZnVsbF9zY2FuOiBpZiB3ZSBzaG91bGQgc2NhbiBmcm9t
IHRoZSBiZWdpbm5pbmcNCj4gICAqDQo+ICAgKiBJdGVyYXRlcyBvdmVyIHRoZSBtZXRhZGF0YSBi
bG9ja3MgdG8gZmluZCB0aGUgbGFyZ2VzdCBjb250aWcgYXJlYS4NCj4gLSAqIEl0IGFsc28gY291
bnRzIHRoZSBwb3B1bGF0ZWQgcGFnZXMgYW5kIHVzZXMgdGhlIGRlbHRhIHRvIHVwZGF0ZSB0aGUN
Cj4gLSAqIGdsb2JhbCBjb3VudC4NCj4gKyAqIEEgZnVsbCBzY2FuIGNhbiBiZSBhdm9pZGVkIG9u
IHRoZSBhbGxvY2F0aW9uIHBhdGggYXMgdGhpcyBpcw0KPiArIHRyaWdnZXJlZA0KPiArICogaWYg
d2UgYnJva2UgdGhlIGNvbnRpZ19oaW50LiAgSW4gZG9pbmcgc28sIHRoZSBzY2FuX2hpbnQgd2ls
bCBiZQ0KPiArIGJlZm9yZQ0KPiArICogdGhlIGNvbnRpZ19oaW50IG9yIGFmdGVyIGlmIHRoZSBz
Y2FuX2hpbnQgPT0gY29udGlnX2hpbnQuICBUaGlzDQo+ICsgY2Fubm90DQo+ICsgKiBiZSBwcmV2
ZW50ZWQgb24gZnJlZWluZyBhcyB3ZSB3YW50IHRvIGZpbmQgdGhlIGxhcmdlc3QgYXJlYSBwb3Nz
aWJseQ0KPiArICogc3Bhbm5pbmcgYmxvY2tzLg0KPiAgICovDQo+IC1zdGF0aWMgdm9pZCBwY3B1
X2NodW5rX3JlZnJlc2hfaGludChzdHJ1Y3QgcGNwdV9jaHVuayAqY2h1bmspDQo+ICtzdGF0aWMg
dm9pZCBwY3B1X2NodW5rX3JlZnJlc2hfaGludChzdHJ1Y3QgcGNwdV9jaHVuayAqY2h1bmssIGJv
b2wNCj4gK2Z1bGxfc2NhbikNCj4gIHsNCj4gIAlzdHJ1Y3QgcGNwdV9ibG9ja19tZCAqY2h1bmtf
bWQgPSAmY2h1bmstPmNodW5rX21kOw0KPiAgCWludCBiaXRfb2ZmLCBiaXRzOw0KPiANCj4gLQkv
KiBjbGVhciBtZXRhZGF0YSAqLw0KPiAtCWNodW5rX21kLT5jb250aWdfaGludCA9IDA7DQo+ICsJ
LyogcHJvbW90ZSBzY2FuX2hpbnQgdG8gY29udGlnX2hpbnQgKi8NCj4gKwlpZiAoIWZ1bGxfc2Nh
biAmJiBjaHVua19tZC0+c2Nhbl9oaW50KSB7DQo+ICsJCWJpdF9vZmYgPSBjaHVua19tZC0+c2Nh
bl9oaW50X3N0YXJ0ICsgY2h1bmtfbWQtPnNjYW5faGludDsNCj4gKwkJY2h1bmtfbWQtPmNvbnRp
Z19oaW50X3N0YXJ0ID0gY2h1bmtfbWQtPnNjYW5faGludF9zdGFydDsNCj4gKwkJY2h1bmtfbWQt
PmNvbnRpZ19oaW50ID0gY2h1bmtfbWQtPnNjYW5faGludDsNCj4gKwkJY2h1bmtfbWQtPnNjYW5f
aGludCA9IDA7DQo+ICsJfSBlbHNlIHsNCj4gKwkJYml0X29mZiA9IGNodW5rX21kLT5maXJzdF9m
cmVlOw0KPiArCQljaHVua19tZC0+Y29udGlnX2hpbnQgPSAwOw0KPiArCX0NCj4gDQo+IC0JYml0
X29mZiA9IGNodW5rX21kLT5maXJzdF9mcmVlOw0KPiAgCWJpdHMgPSAwOw0KPiAgCXBjcHVfZm9y
X2VhY2hfbWRfZnJlZV9yZWdpb24oY2h1bmssIGJpdF9vZmYsIGJpdHMpIHsNCj4gIAkJcGNwdV9i
bG9ja191cGRhdGUoY2h1bmtfbWQsIGJpdF9vZmYsIGJpdF9vZmYgKyBiaXRzKTsgQEAgLTg4NCw2
DQo+ICs4OTUsMTMgQEAgc3RhdGljIHZvaWQgcGNwdV9ibG9ja191cGRhdGVfaGludF9hbGxvYyhz
dHJ1Y3QgcGNwdV9jaHVuaw0KPiAqY2h1bmssIGludCBiaXRfb2ZmLA0KPiAgCWlmIChucl9lbXB0
eV9wYWdlcykNCj4gIAkJcGNwdV91cGRhdGVfZW1wdHlfcGFnZXMoY2h1bmssIC0xICogbnJfZW1w
dHlfcGFnZXMpOw0KPiANCj4gKwlpZiAocGNwdV9yZWdpb25fb3ZlcmxhcChjaHVua19tZC0+c2Nh
bl9oaW50X3N0YXJ0LA0KPiArCQkJCWNodW5rX21kLT5zY2FuX2hpbnRfc3RhcnQgKw0KPiArCQkJ
CWNodW5rX21kLT5zY2FuX2hpbnQsDQo+ICsJCQkJYml0X29mZiwNCj4gKwkJCQliaXRfb2ZmICsg
Yml0cykpDQo+ICsJCWNodW5rX21kLT5zY2FuX2hpbnQgPSAwOw0KPiArDQo+ICAJLyoNCj4gIAkg
KiBUaGUgb25seSB0aW1lIGEgZnVsbCBjaHVuayBzY2FuIGlzIHJlcXVpcmVkIGlzIGlmIHRoZSBj
aHVuaw0KPiAgCSAqIGNvbnRpZyBoaW50IGlzIGJyb2tlbi4gIE90aGVyd2lzZSwgaXQgbWVhbnMg
YSBzbWFsbGVyIHNwYWNlIEBADQo+IC04OTQsNyArOTEyLDcgQEAgc3RhdGljIHZvaWQgcGNwdV9i
bG9ja191cGRhdGVfaGludF9hbGxvYyhzdHJ1Y3QNCj4gcGNwdV9jaHVuayAqY2h1bmssIGludCBi
aXRfb2ZmLA0KPiAgCQkJCWNodW5rX21kLT5jb250aWdfaGludCwNCj4gIAkJCQliaXRfb2ZmLA0K
PiAgCQkJCWJpdF9vZmYgKyBiaXRzKSkNCj4gLQkJcGNwdV9jaHVua19yZWZyZXNoX2hpbnQoY2h1
bmspOw0KPiArCQlwY3B1X2NodW5rX3JlZnJlc2hfaGludChjaHVuaywgZmFsc2UpOw0KPiAgfQ0K
PiANCj4gIC8qKg0KPiBAQCAtMTAwNSw3ICsxMDIzLDcgQEAgc3RhdGljIHZvaWQgcGNwdV9ibG9j
a191cGRhdGVfaGludF9mcmVlKHN0cnVjdA0KPiBwY3B1X2NodW5rICpjaHVuaywgaW50IGJpdF9v
ZmYsDQo+ICAJICogdGhlIGVsc2UgY29uZGl0aW9uIGJlbG93Lg0KPiAgCSAqLw0KPiAgCWlmICgo
KGVuZCAtIHN0YXJ0KSA+PSBQQ1BVX0JJVE1BUF9CTE9DS19CSVRTKSB8fCBzX2luZGV4ICE9IGVf
aW5kZXgpDQo+IC0JCXBjcHVfY2h1bmtfcmVmcmVzaF9oaW50KGNodW5rKTsNCj4gKwkJcGNwdV9j
aHVua19yZWZyZXNoX2hpbnQoY2h1bmssIHRydWUpOw0KPiAgCWVsc2UNCj4gIAkJcGNwdV9ibG9j
a191cGRhdGUoJmNodW5rLT5jaHVua19tZCwNCj4gIAkJCQkgIHBjcHVfYmxvY2tfb2ZmX3RvX29m
ZihzX2luZGV4LCBzdGFydCksIEBAIC0xMDc4LDcNCj4gKzEwOTYsNyBAQCBzdGF0aWMgaW50IHBj
cHVfZmluZF9ibG9ja19maXQoc3RydWN0IHBjcHVfY2h1bmsgKmNodW5rLCBpbnQNCj4gYWxsb2Nf
Yml0cywNCj4gIAlpZiAoYml0X29mZiArIGFsbG9jX2JpdHMgPiBjaHVua19tZC0+Y29udGlnX2hp
bnQpDQo+ICAJCXJldHVybiAtMTsNCj4gDQo+IC0JYml0X29mZiA9IGNodW5rX21kLT5maXJzdF9m
cmVlOw0KPiArCWJpdF9vZmYgPSBwY3B1X25leHRfaGludChjaHVua19tZCwgYWxsb2NfYml0cyk7
DQo+ICAJYml0cyA9IDA7DQo+ICAJcGNwdV9mb3JfZWFjaF9maXRfcmVnaW9uKGNodW5rLCBhbGxv
Y19iaXRzLCBhbGlnbiwgYml0X29mZiwgYml0cykgew0KPiAgCQlpZiAoIXBvcF9vbmx5IHx8IHBj
cHVfaXNfcG9wdWxhdGVkKGNodW5rLCBiaXRfb2ZmLCBiaXRzLA0KDQpSZXZpZXdlZC1ieTogUGVu
ZyBGYW4gPHBlbmcuZmFuQG54cC5jb20+DQoNCj4gLS0NCj4gMi4xNy4xDQoNCg==

