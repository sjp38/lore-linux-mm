Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B082C606C7
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 18:50:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CFE7E216FD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 18:50:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="jvgbYhc5";
	dkim=pass (1024-bit key) header.d=sharedspace.onmicrosoft.com header.i=@sharedspace.onmicrosoft.com header.b="sWN/5kc9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CFE7E216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 734248E0027; Mon,  8 Jul 2019 14:50:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BDB78E0032; Mon,  8 Jul 2019 14:50:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 566078E0027; Mon,  8 Jul 2019 14:50:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18A078E0027
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 14:50:06 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e95so9226550plb.9
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 11:50:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:dkim-signature:from
         :to:cc:subject:thread-topic:thread-index:date:message-id:references
         :accept-language:content-language:wdcipoutbound
         :content-transfer-encoding:mime-version;
        bh=DYrAhknFJrfgVH7tUTas/304tMGKs0DIRpYx1FvCIZo=;
        b=cUYD5alvO4DLmnL6pkDCuiBx9yco1n0ZCLj7cC0tGM40JuYb6U3UpJxvWIi37xFQVx
         VaeB28aBlPLGietal8zjTVUIl0zZGjDaxBpAXXldv74Hi8kiq+ixZwbwVZeH52bCFhK2
         70+fcJ6rNwtmCQdOGnJzSyWMBdKtdNkH42Ti3jHsoDlOQXydossfBIHO5HJNa8Ob2gsw
         laXaCYK18ebaHO0Rb7n2GxHeRhVCb+yYuTddGdD8+suZ3xZD8ZWvdvhwDXaeHF0H28tr
         UxjPCGes3ZJmf5nn2WSvDUJpNJaH49kvKQgW4jmuXFhrRZumBiEJNAs+27z7pXLwnrr1
         mKRg==
X-Gm-Message-State: APjAAAUKa7qKfBi2Y/FdFceAkRs80SlXXPXryn+lskIrmuLN0jS5ElkT
	khNa+MhE5Bn5MZqYlmO1Q+jMi+/OiZzxtb6J/X6j7/OQFXD2nVdxSGryhoP6fuedGWCIwlMarnw
	dUExdKtIIoAG9LRkQxk8rcD2OYATRvk3CASyfwxE+06svmhOMsj7cmfuaPUMgGbTNLw==
X-Received: by 2002:a17:90a:d791:: with SMTP id z17mr26373262pju.40.1562611805659;
        Mon, 08 Jul 2019 11:50:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynLHHpHIeJU4vUUKrKC/4bbmE2gKBm/9tpHFhr8jN0ETWhHSzjPO/wfJJVxHJLvQIKlPpE
X-Received: by 2002:a17:90a:d791:: with SMTP id z17mr26373212pju.40.1562611804983;
        Mon, 08 Jul 2019 11:50:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562611804; cv=none;
        d=google.com; s=arc-20160816;
        b=zZAFjC1sHEqHZExSVKVU1tijPh9EGxODWECW5AEuJLE2WTjtUoV4QPHmu1qvBojpeo
         Vufr/AEZcX7ZevibzSeil6BUmdjH5hJFTUQz+GvMZDASgSckkQoCQTDLxKW1fG7oPMwP
         0tcnzJHCMRmvhXctNR448aoLI47xKoA5cOHZC5qx5K1AndRKnQLGYWEnZdKSYH9WYdLx
         ySbvsLpx1uCjjun87jVOuPyIwn4MiqRCYCV3f3ukJjLP/bzbJ5opu7aHFiQqACD8gsHT
         kspcf4NdwS3kLb3gt5wnt6A8PoC7JRjz+8oI8gwHAqEaef1UaJ+uoweuHiLAFuQqcbb4
         Quuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:wdcipoutbound
         :content-language:accept-language:references:message-id:date
         :thread-index:thread-topic:subject:cc:to:from:dkim-signature
         :ironport-sdr:dkim-signature;
        bh=DYrAhknFJrfgVH7tUTas/304tMGKs0DIRpYx1FvCIZo=;
        b=nlh9Jg/4GxvA1CnKxEgEXBzt+qxvKPjjc3KiLuxgSaVtWsEGdSWFjuq4g78e7/Dou1
         vmJa7gy/nbL32MB5zJmFrkL5wb2i+4GuoNuqRNtjwgoYUvHEkl1H8B+OFr8FfZFHHFKg
         zz0N2hReFKJm4yBYAgBd95O1m/hNO7ag1HELARWzoQytwJ1ZkiTVE6eMDoe7sag6P7zG
         5yH8ei2kMu26+zKyD/H9bBU2RcAn4+mml6ORAvM/pkXXuuhMKz48TNXSleznZGcrNSlD
         m7LUReFoHNeCAeBzSgdr4ANGKLfT945v+JNH5I0UVYW8pyUv18yyHBVECzDqcAz5RZIM
         WvoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=jvgbYhc5;
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector2-sharedspace-onmicrosoft-com header.b="sWN/5kc9";
       spf=pass (google.com: domain of prvs=0852429f4=chaitanya.kulkarni@wdc.com designates 216.71.153.144 as permitted sender) smtp.mailfrom="prvs=0852429f4=Chaitanya.Kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa5.hgst.iphmx.com (esa5.hgst.iphmx.com. [216.71.153.144])
        by mx.google.com with ESMTPS id d5si19364354pgk.346.2019.07.08.11.50.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 11:50:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0852429f4=chaitanya.kulkarni@wdc.com designates 216.71.153.144 as permitted sender) client-ip=216.71.153.144;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=jvgbYhc5;
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector2-sharedspace-onmicrosoft-com header.b="sWN/5kc9";
       spf=pass (google.com: domain of prvs=0852429f4=chaitanya.kulkarni@wdc.com designates 216.71.153.144 as permitted sender) smtp.mailfrom="prvs=0852429f4=Chaitanya.Kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1562611805; x=1594147805;
  h=from:to:cc:subject:date:message-id:references:
   content-transfer-encoding:mime-version;
  bh=rST5XtYYzjECxnkKVAqUnjUvKpHGltzEEbbJcGj31cM=;
  b=jvgbYhc5TOnGTegvLA5PkRFR9K0SkEyRdJ3GCvAWm3yMFRwiZiTSFnEC
   z6zPq3R9GvCaJ43RJi1h0KXVTihGlNd/x8j3PuBN/9ksOY2nZvUr69CbA
   Jv9LU1UgmxOO9i4RuVfzx0S2MGtZLhLjmojzQucDYWxKcmbUWSe9x6s5M
   U5g5r4k6i5Mg4ghX2soLPwgRF4KiAZq/rKKSyd9J6KPE0c0jfRgOF3ccQ
   vFTdbVD2iV6aa+aOfI4KeUhB5JbDwwd21fOztJW0q6cgXhepdwVVXV1EW
   BqN56a7QkL4N1w+cAilA5QZq1uo28hw+2t1IfubR3wqapS20OzgXyGBF8
   g==;
IronPort-SDR: 3zMbtjeW7EbLH58MixpHqp17AFZq1Xu1MBh6oOxYa+RdoUuvnmPfjIsbIF3Tn5wFtqtWc3Puz7
 18BOfo+XQhiqC5MiFqHrcbcxdJb2SnFZw/maDHSRNxxrbB2lL9QSqP6OQ/eZTrQFN363GU6H0l
 Im0X7UwSAEfLhxCMPcXfW5RNsQgQw6tZmZSb3Uv+TW0Nl0VXGcY2YdxhPrkNBWJ3zuigY3hhVY
 APLHUET5W1vERQP5jLs6T95XWLGkUJArlg1tVtrGh2F55sH/zXtQPsh/e2fNECe7tnS5av4ioF
 7Ag=
X-IronPort-AV: E=Sophos;i="5.63,466,1557158400"; 
   d="scan'208";a="113649593"
Received: from mail-co1nam03lp2050.outbound.protection.outlook.com (HELO NAM03-CO1-obe.outbound.protection.outlook.com) ([104.47.40.50])
  by ob1.hgst.iphmx.com with ESMTP; 09 Jul 2019 02:49:55 +0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=sharedspace.onmicrosoft.com; s=selector2-sharedspace-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=DYrAhknFJrfgVH7tUTas/304tMGKs0DIRpYx1FvCIZo=;
 b=sWN/5kc9MS4fu+k3ou+ky2rZAayjroNZXvg+/zB2dZkpSK0P3lfBQGgmGL7C3yMDr18c19aHYhaLlPcNSJSvbA9pYLIV4EInTAv2q5c2MgqlWWeH0OkJvuWCFCeCqkS7QwjGo8aprEsaMuz1KbSULKnpPWIuGMTMiC6rWCGROGg=
Received: from BYAPR04MB5749.namprd04.prod.outlook.com (20.179.58.26) by
 BYAPR04MB5079.namprd04.prod.outlook.com (52.135.235.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2052.17; Mon, 8 Jul 2019 18:49:54 +0000
Received: from BYAPR04MB5749.namprd04.prod.outlook.com
 ([fe80::8025:ccea:a0e6:9078]) by BYAPR04MB5749.namprd04.prod.outlook.com
 ([fe80::8025:ccea:a0e6:9078%5]) with mapi id 15.20.2052.010; Mon, 8 Jul 2019
 18:49:54 +0000
From: Chaitanya Kulkarni <Chaitanya.Kulkarni@wdc.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org"
	<linux-block@vger.kernel.org>
CC: "bvanassche@acm.org" <bvanassche@acm.org>, "axboe@kernel.dk"
	<axboe@kernel.dk>
Subject: Re: [PATCH 5/5] Documentation/laptop: add block_dump documentation
Thread-Topic: [PATCH 5/5] Documentation/laptop: add block_dump documentation
Thread-Index: AQHVMFgWWE5bmQUoIUGPWjB0oh8vEw==
Date: Mon, 8 Jul 2019 18:49:54 +0000
Message-ID:
 <BYAPR04MB57493225F93F43B6271DCFDA86F60@BYAPR04MB5749.namprd04.prod.outlook.com>
References: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
 <20190701215726.27601-6-chaitanya.kulkarni@wdc.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Chaitanya.Kulkarni@wdc.com; 
x-originating-ip: [199.255.45.63]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f3a41eb6-a965-45c8-72b9-08d703d51133
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:BYAPR04MB5079;
x-ms-traffictypediagnostic: BYAPR04MB5079:
x-microsoft-antispam-prvs:
 <BYAPR04MB507971BCC432BD0F4E190C0286F60@BYAPR04MB5079.namprd04.prod.outlook.com>
wdcipoutbound: EOP-TRUE
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 00922518D8
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(396003)(366004)(346002)(376002)(136003)(39860400002)(199004)(189003)(9686003)(55016002)(66556008)(64756008)(2906002)(66446008)(66476007)(8936002)(76116006)(73956011)(66946007)(71200400001)(53936002)(71190400001)(33656002)(229853002)(81156014)(8676002)(81166006)(6246003)(6436002)(446003)(256004)(68736007)(25786009)(52536014)(316002)(72206003)(54906003)(110136005)(478600001)(99286004)(486006)(14454004)(26005)(2501003)(476003)(7696005)(7736002)(186003)(5660300002)(305945005)(6116002)(74316002)(102836004)(6506007)(53546011)(86362001)(66066001)(76176011)(4326008)(3846002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR04MB5079;H:BYAPR04MB5749.namprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 e3+Yd+M84TMfEYFpT7yT9FhDWjqLr+RGRnANBARTrU91cIC+3/t+ECJQweVwJal3MlpClKy4iAkhYhMoy9+ojqROuBeZHGtDuxquGR3XTYnuuvEFxuyrdiLifGQWhe9efKP2Sj6r2DefXQW5dPiAB6eLr9WEplxS7Jt/HXq/BxG8CbgGfrS4OOY12S+M5zWnxiO4+MAhikg9BV7SYCFsc3EurC1ZQAbGwcnwELqZHTKiJfIwG4PyC7s+XM+U3O0xFI6Sz8nDWctDplinjBFy7t/HdzQt6n0XsM6m1bwbYYWSNIhpCMXIVQXOE9eJEDDWif4nBTp6peMZ2h7PZsjpQ2W6+FNfW+zW9WfXXqQSrlZTpsZ4fHTAeT5IhmlTxd8Vyn+wLA7qUn2dNRvF2bNnqY2zEhX+ioLhJWN8pXm/9Sc=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: wdc.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f3a41eb6-a965-45c8-72b9-08d703d51133
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Jul 2019 18:49:54.7376
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b61c8803-16f3-4c35-9b17-6f65f441df86
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Chaitanya.Kulkarni@wdc.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR04MB5079
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Can someone from linux-mm list please provide a feedback on this ?=0A=
=0A=
On 07/01/2019 02:58 PM, Chaitanya Kulkarni wrote:=0A=
> This patch updates the block_dump documentation with respect to the=0A=
> changes from the earlier patch for submit_bio(). Also we adjust rest of=
=0A=
> the lines to fit with standaed format.=0A=
>=0A=
> Signed-off-by: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>=0A=
> ---=0A=
>   Documentation/laptops/laptop-mode.txt | 16 ++++++++--------=0A=
>   1 file changed, 8 insertions(+), 8 deletions(-)=0A=
>=0A=
> diff --git a/Documentation/laptops/laptop-mode.txt b/Documentation/laptop=
s/laptop-mode.txt=0A=
> index 1c707fc9b141..d4d72ed677c4 100644=0A=
> --- a/Documentation/laptops/laptop-mode.txt=0A=
> +++ b/Documentation/laptops/laptop-mode.txt=0A=
> @@ -101,14 +101,14 @@ a cache miss. The disk can then be spun down in the=
 periods of inactivity.=0A=
>=0A=
>   If you want to find out which process caused the disk to spin up, you c=
an=0A=
>   gather information by setting the flag /proc/sys/vm/block_dump. When th=
is flag=0A=
> -is set, Linux reports all disk read and write operations that take place=
, and=0A=
> -all block dirtyings done to files. This makes it possible to debug why a=
 disk=0A=
> -needs to spin up, and to increase battery life even more. The output of=
=0A=
> -block_dump is written to the kernel output, and it can be retrieved usin=
g=0A=
> -"dmesg". When you use block_dump and your kernel logging level also incl=
udes=0A=
> -kernel debugging messages, you probably want to turn off klogd, otherwis=
e=0A=
> -the output of block_dump will be logged, causing disk activity that is n=
ot=0A=
> -normally there.=0A=
> +is set, Linux reports all disk I/O operations along with read and write=
=0A=
> +operations that take place, and all block dirtyings done to files. This =
makes=0A=
> +it possible to debug why a disk needs to spin up, and to increase batter=
y life=0A=
> +even more. The output of block_dump is written to the kernel output, and=
 it can=0A=
> +be retrieved using "dmesg". When you use block_dump and your kernel logg=
ing=0A=
> +level also includes kernel debugging messages, you probably want to turn=
 off=0A=
> +klogd, otherwise the output of block_dump will be logged, causing disk a=
ctivity=0A=
> +that is not normally there.=0A=
>=0A=
>=0A=
>   Configuration=0A=
>=0A=
=0A=

