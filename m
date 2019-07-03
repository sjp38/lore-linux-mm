Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3DCBC4646D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 02:24:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 719C1206E0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 02:24:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="PPjOvIhr";
	dkim=pass (1024-bit key) header.d=sharedspace.onmicrosoft.com header.i=@sharedspace.onmicrosoft.com header.b="dOzrR3/5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 719C1206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 149056B0003; Tue,  2 Jul 2019 22:24:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D1D38E0003; Tue,  2 Jul 2019 22:24:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E65598E0001; Tue,  2 Jul 2019 22:24:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7D2C6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 22:24:47 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x10so497978pfa.23
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 19:24:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:dkim-signature:from
         :to:cc:subject:thread-topic:thread-index:date:message-id:references
         :accept-language:content-language:wdcipoutbound
         :content-transfer-encoding:mime-version;
        bh=vFc8XnmtnNLYmpPO90zqeHzC1DZEXLIy0xWmcAv1o4M=;
        b=E62dXHIM3VNoM8aiabmL4Mwn1TGfjQ44yUkeevq7bblYzGRsNSof285VldU8BJaO3q
         aAPSq+WAgD6f1Lg0EPrmWRrQEhYK5BwvPV7wNfOfkFBPJhEGbUbK5KeX0iLMQ5tf9uO+
         gT+J7JebRoFxelaAPi0qW1QjUupTCxz30+MmJOPEScf0u/TulQjQgoKA8wXzsLPod1C6
         f8G/bAcsGiwlofhizWzafXzYB7v5K+cplkJkfRiqRkyj18c64fMBSLGdggEAy2BtqMs5
         BXtUmhRgW5wLVhmkPhwubg3NodYRFYXbe3EXVyy8kC74XvswPyFOeLqS+4sMY0AglOJg
         IYWw==
X-Gm-Message-State: APjAAAX/Ad8a1BwQQQgSWWtVKhx/IvXV0/122eYJe1fV/Rf900e6a0wT
	mGMHbiGdQC7zLelqxGBwFZ+Hkpd7/lQ92GC8xUscYKKfCp14Vb9oxSfpOhREugQBGrOkFjl0Cch
	rqCDNqkWxjDozZYhcCwnjFMWg9NxsfnWZZRzNGqlOsZnDMJfFOZWrv+O0kybU+b+sqQ==
X-Received: by 2002:a17:90a:fa12:: with SMTP id cm18mr9189647pjb.137.1562120687337;
        Tue, 02 Jul 2019 19:24:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwp9jNwrzyjdqLvMsQOOjQU4cbbgE5g6gU33tXRHWaHuQWmTCQZZiMMJgLXA9pIT2I00Ql2
X-Received: by 2002:a17:90a:fa12:: with SMTP id cm18mr9189558pjb.137.1562120686489;
        Tue, 02 Jul 2019 19:24:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562120686; cv=none;
        d=google.com; s=arc-20160816;
        b=BjS+utFAko9Yxe8lDSeKQGBATuWoaBd0iUqJxKG+yRqiEff/Dz89j7agFCwFpnP9BM
         YZuaYb5a+UatMgc5Q46aXg4SU1Kf1CYkqYO2pQ3GL+MgaJ/MgubkFVmNTWlhsV2bjM2u
         NAsiejY7hkxQx+YWz20fbeAqXRfnVaCpd5sGa2zI4CMX2GHonfYFEEuL9UWatJTNL1Py
         NUuqy85HK3oyAwHELPmCxMZT8U9OPT9Civa7VoH7mfH0vFQmu2kqd3f3iBPW+qzNDJpI
         GpvslAV5fjNFhN1uZ6hXvCE7W7Ob0DSz9alqT0R4cSrsHoOznpqa1fVM4EJCEr8HLAE7
         Qjew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:wdcipoutbound
         :content-language:accept-language:references:message-id:date
         :thread-index:thread-topic:subject:cc:to:from:dkim-signature
         :ironport-sdr:dkim-signature;
        bh=vFc8XnmtnNLYmpPO90zqeHzC1DZEXLIy0xWmcAv1o4M=;
        b=jczMeH2iLJ87ITQP3jgNZaEPiiT6Umyj70oJ90QU2Q3+2NZg6l67/Nq7tSBVyVBoD+
         RZrnkEYUPewb+Lnp5FiGga9jFvBLri9vg0I40FyqX0I7XF3ekOIAGbX/s1uwfZB2HQH8
         8Ir1u1n7RvuJwoVAv4Njg+tCsmWVBbqBH7c/EDHqeRrNBZAfKw6sZMPfCVBYItp/ixVT
         U0fbzrLrZs59r8+ptIKzogrqbGPGCqSzDdUm2h5rSSmSTpPYPLZOPvPYOgxt5PUr7YkO
         7H4B2JW+RbExNhxvaU6+0JOWH4kFydNmex1yxS06gTTRc/SMNKi1oa/GCF0z9GpB9hR4
         u/iQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=PPjOvIhr;
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector2-sharedspace-onmicrosoft-com header.b="dOzrR3/5";
       spf=pass (google.com: domain of prvs=08019a6bf=chaitanya.kulkarni@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=08019a6bf=Chaitanya.Kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa3.hgst.iphmx.com (esa3.hgst.iphmx.com. [216.71.153.141])
        by mx.google.com with ESMTPS id u1si622414plb.234.2019.07.02.19.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 19:24:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=08019a6bf=chaitanya.kulkarni@wdc.com designates 216.71.153.141 as permitted sender) client-ip=216.71.153.141;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=PPjOvIhr;
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector2-sharedspace-onmicrosoft-com header.b="dOzrR3/5";
       spf=pass (google.com: domain of prvs=08019a6bf=chaitanya.kulkarni@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=08019a6bf=Chaitanya.Kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1562120686; x=1593656686;
  h=from:to:cc:subject:date:message-id:references:
   content-transfer-encoding:mime-version;
  bh=eLqr3YGEcjwRsvSxL9Oa93imwBHSulTZR/nx7qCHdL8=;
  b=PPjOvIhrqOtCEkCzK+QMur/6wYpyddn/qNQHNZXl62cUp14dy5eCzX4/
   FLllxcMXJ0Y8vEEntJSkPMwt7dWq+YrhyGI2oN+5hvAwq/lHO6fsxrn0a
   rfN8+uh9L+0zzxDd1SXakbOm0he8MoeWr4EtvQxNo20nUeTnluFuTqOf1
   bYbo7UGHW4XFl7FeSEIkxmENWIvkTMmqyIyihcAPYnPebN0e5+Jce90tu
   lHXDW2RKh47IHjsD/tnV/j1ptsSskeh7kzxGtc8ImTWv9IeMbQRB95gPT
   afOofaHajcQN9Q8aZ+fW951vkQQBH+PY5a22Vg4lln/QMv3mcz4/TBNT+
   w==;
IronPort-SDR: Tf1fgAkKZTAnewuShaYCGV31+NcIKmTeWIHABLSwwtY1PDFaGmqBYUnkrBjPslxfs7XNfaJT6w
 ltoJtw8Q2bWI6LsBrjJ1rN169BnPyUieFPvojKy5p7y6Lq5Ujn9btmO4sjsYK3UeI33Ik8i/QD
 /DjHUe86u4cvCcciA7YumMsmDw/mS2JnJVzkOso/JROM3tvf3QyDK2qWYSDjnv7rvWRI+VrYEW
 FaRHc0IZp+ezx3RwZZqUC8UkermtsH6g+H0nKX0Qvhb5Qm/iB+9EzHryn/UROhk2ElVsjIwH+z
 cPU=
X-IronPort-AV: E=Sophos;i="5.63,445,1557158400"; 
   d="scan'208";a="116945250"
Received: from mail-co1nam05lp2058.outbound.protection.outlook.com (HELO NAM05-CO1-obe.outbound.protection.outlook.com) ([104.47.48.58])
  by ob1.hgst.iphmx.com with ESMTP; 03 Jul 2019 10:24:38 +0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=sharedspace.onmicrosoft.com; s=selector2-sharedspace-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=vFc8XnmtnNLYmpPO90zqeHzC1DZEXLIy0xWmcAv1o4M=;
 b=dOzrR3/5pEkjR68Xu4QGqcdez+1vPntulg8/lRGFOzejTepkwCedgSEukwaNp22s0w1YZcRSNFKURJhEhFfgEqV0Prqw3ka46eNmMYIKl1+QjtIsieLHZtaZme+q+uSNbunDbKCgyLLocgfgL86z9BVT+JHbiVYl5ryXrgM+yvU=
Received: from DM6PR04MB5754.namprd04.prod.outlook.com (20.179.52.22) by
 DM6PR04MB4666.namprd04.prod.outlook.com (20.176.107.139) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Wed, 3 Jul 2019 02:24:36 +0000
Received: from DM6PR04MB5754.namprd04.prod.outlook.com
 ([fe80::a07d:d226:c10f:7211]) by DM6PR04MB5754.namprd04.prod.outlook.com
 ([fe80::a07d:d226:c10f:7211%6]) with mapi id 15.20.2052.010; Wed, 3 Jul 2019
 02:24:36 +0000
From: Chaitanya Kulkarni <Chaitanya.Kulkarni@wdc.com>
To: Minwoo Im <minwoo.im.dev@gmail.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org"
	<linux-block@vger.kernel.org>, "bvanassche@acm.org" <bvanassche@acm.org>,
	"axboe@kernel.dk" <axboe@kernel.dk>
Subject: Re: [PATCH 1/5] block: update error message for bio_check_ro()
Thread-Topic: [PATCH 1/5] block: update error message for bio_check_ro()
Thread-Index: AQHVMFgDV4oewrYTVUu2VG2j0GA+dg==
Date: Wed, 3 Jul 2019 02:24:36 +0000
Message-ID:
 <DM6PR04MB57548A80980931468D63D61386FB0@DM6PR04MB5754.namprd04.prod.outlook.com>
References: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
 <20190701215726.27601-2-chaitanya.kulkarni@wdc.com>
 <20190703004240.GA19081@minwoo-desktop>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Chaitanya.Kulkarni@wdc.com; 
x-originating-ip: [2605:e000:3e45:f500:c10e:84d:47cf:30ea]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4fa2ebc2-b46c-4f05-c9c4-08d6ff5d9819
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DM6PR04MB4666;
x-ms-traffictypediagnostic: DM6PR04MB4666:
x-microsoft-antispam-prvs:
 <DM6PR04MB4666D8F8EA0BB56FEE5BF8E886FB0@DM6PR04MB4666.namprd04.prod.outlook.com>
wdcipoutbound: EOP-TRUE
x-ms-oob-tlc-oobclassifiers: OLM:2958;
x-forefront-prvs: 00872B689F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(136003)(366004)(39860400002)(376002)(396003)(346002)(189003)(199004)(33656002)(25786009)(316002)(71190400001)(71200400001)(7736002)(53936002)(8936002)(81166006)(81156014)(99286004)(102836004)(53546011)(74316002)(6506007)(6436002)(486006)(15650500001)(305945005)(54906003)(6246003)(8676002)(14444005)(68736007)(476003)(446003)(256004)(478600001)(229853002)(55016002)(91956017)(14454004)(9686003)(52536014)(66946007)(66476007)(86362001)(66446008)(64756008)(76116006)(66556008)(73956011)(2906002)(6916009)(186003)(4326008)(46003)(5660300002)(7696005)(6116002)(76176011)(72206003)(21314003);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR04MB4666;H:DM6PR04MB5754.namprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 tq1JtujoYHdq2gSFBwElLTkuTd8YFpypCrIkVdSJNAxK0OsvHYMgEaX1rJbcNgPOyTYAeyFkwJsz6RK/+QOf6hBRXUzPShR8tMzofUud3fZFNuZLfG/Rlbs9COx2IcRjkHwyMHm2jJIRI/XGQ2+lq+X0N2meOAlzktDkEshRmV/sEpDwsnRTkFWvtPUZhqtk98amTh8NeO/fUbOxnsjtyCwhu6udP3shojuIUeu5NHZVmb4Hskq8k6zabMqzD8GLzhaNbbeUZ/wp+y7TRxfYAGjFn2xUy/IHex6koMB40pZjuzz66XPJ0jTLKjuu6x9rakJtLuSnvv6QH2FDa9bAWUg+i+PW5+3yqbJgtYCuOMMpdws+jFazAq2Fzd/AG+E1reo6y62/xyvlMCn7Q8RMkDhaKoTqcmxhUFdQPOznZ+Y=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: wdc.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4fa2ebc2-b46c-4f05-c9c4-08d6ff5d9819
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jul 2019 02:24:36.6533
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b61c8803-16f3-4c35-9b17-6f65f441df86
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Chaitanya.Kulkarni@wdc.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR04MB4666
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/2/19 5:42 PM, Minwoo Im wrote:=0A=
> On 19-07-01 14:57:22, Chaitanya Kulkarni wrote:=0A=
>> The existing code in the bio_check_ro() relies on the op_is_write().=0A=
>> op_is_write() checks for the last bit in the bio_op(). Now that we have=
=0A=
>> multiple REQ_OP_XXX with last bit set to 1 such as, (from blk_types.h):=
=0A=
>>=0A=
>> 	/* write sectors to the device */=0A=
>> 	REQ_OP_WRITE		=3D 1,=0A=
>> 	/* flush the volatile write cache */=0A=
>> 	REQ_OP_DISCARD		=3D 3,=0A=
>> 	/* securely erase sectors */=0A=
>> 	REQ_OP_SECURE_ERASE	=3D 5,=0A=
>> 	/* write the same sector many times */=0A=
>> 	REQ_OP_WRITE_SAME	=3D 7,=0A=
>> 	/* write the zero filled sector many times */=0A=
>> 	REQ_OP_WRITE_ZEROES	=3D 9,=0A=
>>=0A=
>> it is hard to understand which bio op failed in the bio_check_ro().=0A=
>>=0A=
>> Modify the error message in bio_check_ro() to print correct REQ_OP_XXX=
=0A=
>> with the help of blk_op_str().=0A=
>>=0A=
>> Signed-off-by: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>=0A=
>> ---=0A=
>>  block/blk-core.c | 6 +++---=0A=
>>  1 file changed, 3 insertions(+), 3 deletions(-)=0A=
>>=0A=
>> diff --git a/block/blk-core.c b/block/blk-core.c=0A=
>> index 5d1fc8e17dd1..47c8b9c48a57 100644=0A=
>> --- a/block/blk-core.c=0A=
>> +++ b/block/blk-core.c=0A=
>> @@ -786,9 +786,9 @@ static inline bool bio_check_ro(struct bio *bio, str=
uct hd_struct *part)=0A=
>>  			return false;=0A=
>>  =0A=
>>  		WARN_ONCE(1,=0A=
>> -		       "generic_make_request: Trying to write "=0A=
>> -			"to read-only block-device %s (partno %d)\n",=0A=
>> -			bio_devname(bio, b), part->partno);=0A=
>> +			"generic_make_request: Trying op %s on the "=0A=
>> +			"read-only block-device %s (partno %d)\n",=0A=
>> +			blk_op_str(op), bio_devname(bio, b), part->partno);=0A=
> Maybe "s/Trying op %s on/Tyring op %s to" just like the previous one?=0A=
> Not a native speaker, though ;)=0A=
=0A=
Yeah, can be done at the time of applying patch if Jens is okay with it.=0A=
=0A=
Otherwise I'll send V2.=0A=
=0A=
>=0A=
> I think it would be better to see the log which holds the exact request=
=0A=
> operation type in a string.=0A=
>=0A=
> Reviewed-by: Minwoo Im <minwoo.im.dev@gmail.com>=0A=
>=0A=
=0A=

