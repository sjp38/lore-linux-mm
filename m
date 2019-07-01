Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9449BC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 18:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44CBF20663
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 18:53:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="ryh4E/vG";
	dkim=pass (1024-bit key) header.d=sharedspace.onmicrosoft.com header.i=@sharedspace.onmicrosoft.com header.b="PExM+9fk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44CBF20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D138D6B0007; Mon,  1 Jul 2019 14:53:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC3C78E0003; Mon,  1 Jul 2019 14:53:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB2BC8E0002; Mon,  1 Jul 2019 14:53:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f206.google.com (mail-pl1-f206.google.com [209.85.214.206])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB906B0007
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 14:53:25 -0400 (EDT)
Received: by mail-pl1-f206.google.com with SMTP id e95so7711063plb.9
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 11:53:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:wdcipoutbound:content-id
         :content-transfer-encoding:mime-version;
        bh=evVuCAwmXg1QqUkbarEdoN4jfzFm166bDjRUSetUjpg=;
        b=mGizAx4qK6du+JUhTrfX2aYYjvkIOA/g6bV4/ukOpU0J4boHvAE4m1lDbZfBOBRVEL
         Rt+0LRlQ8PuPfM4hqpTSYMxq3xOu9HhSEO2kD0XmUDCCrEbg0UdSunvefs/0lnBJXB3Q
         DrZII7moOFC5A9nvw8FQAgecfpE4SmiDfk8JQRAclU55HkZbDeqCMbYMu8Cv3uhBugmm
         NOYHVlB/4sGdx72DZW1sOei1dzc9if3jlp/vAhxB+QZ9XAdpy22Wv/8CiHJN0OQtJlAh
         G7cDOrgbHda5vK8MAuZdsL4h9m+37jRrZIvMvqVY7OEICd1WKrHHa2oDd44teH+0qYEL
         0gRw==
X-Gm-Message-State: APjAAAVkDs9CJ63aZT62nNTSiOZdEMp56P758EFzAJ/iWOTd+g2/FUZA
	tNFNsKZPHfcqoCWsBM+OjWP2NYwl8Im2kAV3QYNhAit8OnJpFEemhtzyWPHuZKz5NxgLGmkUWj+
	Hhr1k1Qy8bXIE0LPKxWVStjNnBhR5DYh1/AwYuq7DCAtUVmIfwWLP3uctqYNmw6jucQ==
X-Received: by 2002:a17:902:9a42:: with SMTP id x2mr30967285plv.106.1562007205095;
        Mon, 01 Jul 2019 11:53:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxU3vSFDzDgFCsaYXTTxRQbbwGRnGeOmS1lxlK7Rw+3KPHnArbNIrsSDdFhAntB9JzqY/V
X-Received: by 2002:a17:902:9a42:: with SMTP id x2mr30967239plv.106.1562007204505;
        Mon, 01 Jul 2019 11:53:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562007204; cv=none;
        d=google.com; s=arc-20160816;
        b=wNQ4HADcTZhZRYA62GLLpxO+YdILxYo/ZIxgoXnIyvQf8Qoqsci2+x7ZN2C+76AlbF
         vU3PlMDJCVvzOKHikIYwHyJ0KqfykEX6ss3/R3Zm3JiAXC3ne/IoFiwT5XRzlUVUU7jA
         +7EP61P2hFiZpqLjdl7x4V0SgKQEMqi+WxXGw2oD8NhBlz1cohmrhyo/rQeNxFh56u2a
         ptMFSre4MuWH4k2+duSJrCKlYAxQ1WBKgFadm4oyiCiBWGyiRgHxCH338mdZtvRj/Tsg
         q4DVCkH7jmEyYxKuvYwKx5r+XxgxiBXWwEOoRNTaof0PMzrYH2rfGbgFmE3JfZpKEH2R
         0O/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:wdcipoutbound
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=evVuCAwmXg1QqUkbarEdoN4jfzFm166bDjRUSetUjpg=;
        b=PqFoUi0/3eYg6OKF95hQjD3p31a3e2IeysxFVDc9jzEFFXYp2+i5HLVEUWznR8CJ9E
         L57T/rVJL7Xjf57ZkEc+320/3EmfTSl4rBKj4VGeFLUMVai+/zPcvANUttYtj6FJVanM
         zCaioVVLohrTdozk5krdTAKztjtLkacZ2OIt/CUzdzThbg/Bxc/7yXrbGkPj/TvmpdUz
         M0oZCw6sSJWtIsGwcmUT0tcWwL8FFWgiGJM3S6X5fXLeXidW2QXR7kzx90AlCROkuGOy
         L7p7LER3E/n1Gqg6Xf1JnVR4fCwoHQtEk+KkSIIAwQuZO15wsj+xg+2cTdZ1XJEegXsg
         XwxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b="ryh4E/vG";
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector2-sharedspace-onmicrosoft-com header.b=PExM+9fk;
       spf=pass (google.com: domain of prvs=0789d0bbf=atish.patra@wdc.com designates 216.71.154.42 as permitted sender) smtp.mailfrom="prvs=0789d0bbf=Atish.Patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa4.hgst.iphmx.com (esa4.hgst.iphmx.com. [216.71.154.42])
        by mx.google.com with ESMTPS id b13si11438181pfb.162.2019.07.01.11.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 11:53:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0789d0bbf=atish.patra@wdc.com designates 216.71.154.42 as permitted sender) client-ip=216.71.154.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b="ryh4E/vG";
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector2-sharedspace-onmicrosoft-com header.b=PExM+9fk;
       spf=pass (google.com: domain of prvs=0789d0bbf=atish.patra@wdc.com designates 216.71.154.42 as permitted sender) smtp.mailfrom="prvs=0789d0bbf=Atish.Patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1562007204; x=1593543204;
  h=from:to:cc:subject:date:message-id:references:
   in-reply-to:content-id:content-transfer-encoding:
   mime-version;
  bh=evVuCAwmXg1QqUkbarEdoN4jfzFm166bDjRUSetUjpg=;
  b=ryh4E/vGRe/ASy4lbJ9nxTpzKqpwnjwdodwgTMb5qdjY3tvHvwGpHNiO
   8msT1FWjhtuX/RIbWTU331Mx2AddXYLxD9VSiXZkD9N7/6OebcYfblYeT
   TsvF8lZ1wHTG44FxvO7RajBnUcrKSr2qI8e3t27lw6wLNZTmtIlO2lrna
   3V5c69punjtflEPZzfc9yzBKa2GjWQZZxtK/aNus0ON3TqUwX6guJNVDM
   /pZMSIFxnbhnV1Cp6cMkXcQ199ehtRSA4nupzwHPqJYjg8fnur9oLiGH8
   aMUnl4VK3tz+5x4ZgH74iE7jTRioXDhDwIxTSYVhbS/bmTNXBihYHBW0a
   Q==;
X-IronPort-AV: E=Sophos;i="5.63,440,1557158400"; 
   d="scan'208";a="111983828"
Received: from mail-bn3nam01lp2054.outbound.protection.outlook.com (HELO NAM01-BN3-obe.outbound.protection.outlook.com) ([104.47.33.54])
  by ob1.hgst.iphmx.com with ESMTP; 02 Jul 2019 02:53:22 +0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=sharedspace.onmicrosoft.com; s=selector2-sharedspace-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=evVuCAwmXg1QqUkbarEdoN4jfzFm166bDjRUSetUjpg=;
 b=PExM+9fkw1voOn+ON77ypgP02gM9oIeCA2yYU4UyKsJzlq7Uj+ssotRcFVqDdPKkBctKBqEGFIpZducMCWJXlavy6IZQRSkkTvOhFNI4LW2RuWVArm2d4qoZGvoJyoKuUs7BkFG4R7wfhLsUBevygTa7zCXSL13VVta2sYIIno8=
Received: from BYAPR04MB3782.namprd04.prod.outlook.com (52.135.214.142) by
 BYAPR04MB5573.namprd04.prod.outlook.com (20.178.232.160) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.18; Mon, 1 Jul 2019 18:53:21 +0000
Received: from BYAPR04MB3782.namprd04.prod.outlook.com
 ([fe80::65e3:6069:d7d5:90a2]) by BYAPR04MB3782.namprd04.prod.outlook.com
 ([fe80::65e3:6069:d7d5:90a2%5]) with mapi id 15.20.2032.019; Mon, 1 Jul 2019
 18:53:21 +0000
From: Atish Patra <Atish.Patra@wdc.com>
To: "hch@lst.de" <hch@lst.de>, "paul.walmsley@sifive.com"
	<paul.walmsley@sifive.com>, "palmer@sifive.com" <palmer@sifive.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, Damien Le Moal
	<Damien.LeMoal@wdc.com>, "linux-riscv@lists.infradead.org"
	<linux-riscv@lists.infradead.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 05/17] riscv: use CSR_SATP instead of the legacy sptbr
 name in switch_mm
Thread-Topic: [PATCH 05/17] riscv: use CSR_SATP instead of the legacy sptbr
 name in switch_mm
Thread-Index: AQHVKk/HYDuvVX0qL0ugJmd5Wg5v96a2J+AA
Date: Mon, 1 Jul 2019 18:53:21 +0000
Message-ID: <3cc7a8734991bbb3b7576b34b7038ca9bc67c0c0.camel@wdc.com>
References: <20190624054311.30256-1-hch@lst.de>
	 <20190624054311.30256-6-hch@lst.de>
In-Reply-To: <20190624054311.30256-6-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Atish.Patra@wdc.com; 
x-originating-ip: [199.255.44.250]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 502cacdf-aa01-4012-a6f6-08d6fe55637f
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:BYAPR04MB5573;
x-ms-traffictypediagnostic: BYAPR04MB5573:
wdcipoutbound: EOP-TRUE
x-microsoft-antispam-prvs:
 <BYAPR04MB5573E06A4306B18719AB0804FAF90@BYAPR04MB5573.namprd04.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 00851CA28B
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(376002)(39860400002)(396003)(136003)(346002)(366004)(189003)(199004)(73956011)(99286004)(53936002)(76116006)(476003)(229853002)(66066001)(486006)(316002)(71190400001)(256004)(71200400001)(14444005)(81156014)(66946007)(6512007)(4326008)(36756003)(6506007)(110136005)(446003)(66556008)(11346002)(66476007)(54906003)(14454004)(7736002)(26005)(2501003)(66446008)(118296001)(68736007)(2616005)(64756008)(478600001)(6246003)(72206003)(186003)(8936002)(2906002)(305945005)(2201001)(76176011)(102836004)(6436002)(6116002)(3846002)(6486002)(86362001)(81166006)(8676002)(25786009)(5660300002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR04MB5573;H:BYAPR04MB3782.namprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 C/evsz1NDFa2mXkBgH+HXTPqoIOES4+eFVrV7XBQftYME7zweKQwxZf8fVvwJF3pBiMAoFX2k0VABYboVKJvNB30TDRoAGMOgHCDKd1labC3X4BIH6eeByKIJcuQu+f7phhY/p6curGh5nS2BssK1Ef1zYyTXi9HIxgpr6QmivcH3RXpL9XJZZigpJrkeqLOO/wJNaxSs4BX2cUSXnUyvvm2e5xRih0oxBIijJ/1wAfhi8IrcGXxW1F7nP0MhHpzgOhORshZxu1TiR5xgwIYJmFkh/hM4woMl/RAjVoZIXFLvXxdFyY5IFlYTcuuU+T4/QzR+ECyVjdVFVOspIwvX0GEd1AqXExWnMOhT4AZkFb5K5mUT04Ttg4tB8X2MvKu/tTFgW8OCmcHxxHDD+blLzHb0gN8n6o9FNIA1fNC0EQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <F69301522B3BE54987C4AF4105C0689F@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: wdc.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 502cacdf-aa01-4012-a6f6-08d6fe55637f
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Jul 2019 18:53:21.3359
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b61c8803-16f3-4c35-9b17-6f65f441df86
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Atish.Patra@wdc.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR04MB5573
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCAyMDE5LTA2LTI0IGF0IDA3OjQyICswMjAwLCBDaHJpc3RvcGggSGVsbHdpZyB3cm90
ZToNCj4gU3dpdGNoIHRvIG91ciBvd24gY29uc3RhbnQgZm9yIHRoZSBzYXRwIHJlZ2lzdGVyIGlu
c3RlYWQgb2YgdXNpbmcNCj4gdGhlIG9sZCBuYW1lIGZyb20gYSBsZWdhY3kgdmVyc2lvbiBvZiB0
aGUgcHJpdmlsZWdlZCBzcGVjLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogQ2hyaXN0b3BoIEhlbGx3
aWcgPGhjaEBsc3QuZGU+DQo+IC0tLQ0KPiAgYXJjaC9yaXNjdi9tbS9jb250ZXh0LmMgfCA3ICst
LS0tLS0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgNiBkZWxldGlvbnMoLSkN
Cj4gDQo+IGRpZmYgLS1naXQgYS9hcmNoL3Jpc2N2L21tL2NvbnRleHQuYyBiL2FyY2gvcmlzY3Yv
bW0vY29udGV4dC5jDQo+IGluZGV4IDg5Y2ViM2NiZTIxOC4uYmVlYjVkN2Y5MmVhIDEwMDY0NA0K
PiAtLS0gYS9hcmNoL3Jpc2N2L21tL2NvbnRleHQuYw0KPiArKysgYi9hcmNoL3Jpc2N2L21tL2Nv
bnRleHQuYw0KPiBAQCAtNTcsMTIgKzU3LDcgQEAgdm9pZCBzd2l0Y2hfbW0oc3RydWN0IG1tX3N0
cnVjdCAqcHJldiwgc3RydWN0DQo+IG1tX3N0cnVjdCAqbmV4dCwNCj4gIAljcHVtYXNrX2NsZWFy
X2NwdShjcHUsIG1tX2NwdW1hc2socHJldikpOw0KPiAgCWNwdW1hc2tfc2V0X2NwdShjcHUsIG1t
X2NwdW1hc2sobmV4dCkpOw0KPiAgDQo+IC0JLyoNCj4gLQkgKiBVc2UgdGhlIG9sZCBzcGJ0ciBu
YW1lIGluc3RlYWQgb2YgdXNpbmcgdGhlIGN1cnJlbnQgc2F0cA0KPiAtCSAqIG5hbWUgdG8gc3Vw
cG9ydCBiaW51dGlscyAyLjI5IHdoaWNoIGRvZXNuJ3Qga25vdyBhYm91dCB0aGUNCj4gLQkgKiBw
cml2aWxlZ2VkIElTQSAxLjEwIHlldC4NCj4gLQkgKi8NCj4gLQljc3Jfd3JpdGUoc3B0YnIsIHZp
cnRfdG9fcGZuKG5leHQtPnBnZCkgfCBTQVRQX01PREUpOw0KPiArCWNzcl93cml0ZShDU1JfU0FU
UCwgdmlydF90b19wZm4obmV4dC0+cGdkKSB8IFNBVFBfTU9ERSk7DQo+ICAJbG9jYWxfZmx1c2hf
dGxiX2FsbCgpOw0KPiAgDQo+ICAJZmx1c2hfaWNhY2hlX2RlZmVycmVkKG5leHQpOw0KDQpSZXZp
ZXdlZC1ieTogQXRpc2ggUGF0cmEgPGF0aXNoLnBhdHJhQHdkYy5jb20+DQoNCi0tIA0KUmVnYXJk
cywNCkF0aXNoDQo=

