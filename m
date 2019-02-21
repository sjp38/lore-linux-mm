Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAAABC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:49:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68A5320836
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:49:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="LyBJMubE";
	dkim=pass (1024-bit key) header.d=sharedspace.onmicrosoft.com header.i=@sharedspace.onmicrosoft.com header.b="PkvJIpDo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68A5320836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 087658E00C2; Thu, 21 Feb 2019 18:49:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 035358E00B5; Thu, 21 Feb 2019 18:49:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3EC48E00C2; Thu, 21 Feb 2019 18:49:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8968E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:49:52 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w18so312186plq.10
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:49:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:wdcipoutbound:content-id
         :content-transfer-encoding:mime-version;
        bh=H9pkJp7FuNrCMADhIM3b76/cTUTbtqeTaMY0s3WNqvs=;
        b=YD7dkRhsW/S0gwlMjzVvvQTheaSunDoa56cqOUGNPyvd/oTfnTZfyabIhe/qpcNW2f
         MTzVoSTu7Nzu/z5AKFowToFV//lD7AxWXxPHRk4OWo3AhzI0YdzTfz8rPslOcXBWWSzk
         fvhHrJneSnNHhow0TlbOcPBQJWobbT57bpzVSVqOy4dTApIq3QyiIc6RbaemcttJdZqX
         bMTxoyON+WJnP0pwpfoWcc1KQvZ/baNC6DVuFpUH4fHxBYxV9iI7/nE+fnL/8h/p4EFf
         l+uU8N8jEqpp6G5e3ZHzbYSuaSDOVWqueoVRnbKAWd0YBu6WCYq/FPASi0mtgc9rlQAv
         RxwA==
X-Gm-Message-State: AHQUAuZ02VO6gmKh+tgyXVMfT1W3ZbUoUa/DQn0cIxF6y8U5MR2O+15H
	BRzjzG6KWB51/au+PpZJnp3IP4XJGe/b3I7LBhl1APcL/UkV1vgRQS4vyH39tCqbymg9BJMO8UV
	1M50oFeQo5F0RIa/nex54z7Etwv+V7OhwUmDun9uwBQ4Y+DfhYrdSlBeOcADE1L2H7g==
X-Received: by 2002:a17:902:b01:: with SMTP id 1mr1152161plq.331.1550792992080;
        Thu, 21 Feb 2019 15:49:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibws29yWEitPfEE/9+J1iBc6xi+KE+KYP9aBEC/JoyA/nr3kvoQUlmCB4QzFALM2yj0N7o9
X-Received: by 2002:a17:902:b01:: with SMTP id 1mr1152049plq.331.1550792989619;
        Thu, 21 Feb 2019 15:49:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550792989; cv=none;
        d=google.com; s=arc-20160816;
        b=clqHxvXjLU7lZ7Ib7E3Mle1FTin75iFioESttkTCPczcA8dXCGX8jElnpdOkmvPcOU
         mUbdAKhw+fEUKzyVDfiLKo+aEQ65AMonvZWX3G3JBnoNgpMnnqlUodHQMDnHRVlFTkEW
         GZwUgjEBoKS1QSw9FscSMcV2To6F6X9UCnE8qJ3PQBxUutWAg01dVhJL9a25Y1EdX4ma
         tmZEMiufUdawLoWR4ISVV4LQ5FV04BKFEDi7fpO/OAST5+F62+o9zDyJD5fPkNIgjsfQ
         EwUY4IvJhhC6jdJTpcQvOIMVYMhgzpXrDFi08t8bv/2kv3Y/kcdIV3BoUq+44OlvT7Le
         vvMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:wdcipoutbound
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=H9pkJp7FuNrCMADhIM3b76/cTUTbtqeTaMY0s3WNqvs=;
        b=c4iHht01zW+y74U4sk2lv6+Qa0P0z48mZ3SvO66AVvHBTWzuAS87lNHcRRRyAMw8Uq
         bRLWEPUcY0aUtXU0iAa/JXQBv5m183pqUQ4cP7z2iV/imCmStt5RBV/Na1+9MTBOcTN7
         IwT46CYojn0indwchjy5ja82tRHevv9nA671j/I6FbAvc2Ds0tnzACj1eD7SnpVMr0Qa
         xQfwDQjI6fbb8pB7vNilJSb8n5dkNKbEJNZUooa0GpHHQARHfQap4LGsajrrWaR3Qkkt
         3dQFVdgMG4qIr31q4qvQVvxrt6rGVhaFjljKE79uIcVA2CRgHsD6bc3Gkvx3N4EqrTiI
         y5dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=LyBJMubE;
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector1-wdc-com header.b=PkvJIpDo;
       spf=pass (google.com: domain of prvs=948d93489=adam.manzanares@wdc.com designates 216.71.153.144 as permitted sender) smtp.mailfrom="prvs=948d93489=Adam.Manzanares@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa5.hgst.iphmx.com (esa5.hgst.iphmx.com. [216.71.153.144])
        by mx.google.com with ESMTPS id i3si221711plt.120.2019.02.21.15.49.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:49:49 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=948d93489=adam.manzanares@wdc.com designates 216.71.153.144 as permitted sender) client-ip=216.71.153.144;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=LyBJMubE;
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector1-wdc-com header.b=PkvJIpDo;
       spf=pass (google.com: domain of prvs=948d93489=adam.manzanares@wdc.com designates 216.71.153.144 as permitted sender) smtp.mailfrom="prvs=948d93489=Adam.Manzanares@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1550792989; x=1582328989;
  h=from:to:cc:subject:date:message-id:references:
   in-reply-to:content-id:content-transfer-encoding:
   mime-version;
  bh=H9pkJp7FuNrCMADhIM3b76/cTUTbtqeTaMY0s3WNqvs=;
  b=LyBJMubET6G/aq2sPhfQzShxB0FxjCHkrKa2374IAJ2OcbpU6iWYSS3x
   AR6EHeeJFrjfgkmG/vevx+k2bVz0rtVakt9oBULisaglwwwzOLBmyO2gx
   u+af8//xVaU1ItIUuT1WfAbTJb2v7Rtl11yorv1GqmIcDoLEgfltpbwvY
   Ddn0gEawPaxTQIEfHvg1FjTk75o5AX3eab3hS1wNUyEn8gQNHlwSOxoqb
   h2+wCFXYoqBJIXP8od3pur48ihABWuZjFiIfLmgloZnCPvMN9vvTWyBea
   RUmQ4cDutGA7t2aofkMAfE45S4lZZ3gHZf23s63UGEL4aH4GIFcfSkACU
   w==;
X-IronPort-AV: E=Sophos;i="5.58,397,1544457600"; 
   d="scan'208";a="103167403"
Received: from mail-bl2nam02lp2053.outbound.protection.outlook.com (HELO NAM02-BL2-obe.outbound.protection.outlook.com) ([104.47.38.53])
  by ob1.hgst.iphmx.com with ESMTP; 22 Feb 2019 07:49:47 +0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=sharedspace.onmicrosoft.com; s=selector1-wdc-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=H9pkJp7FuNrCMADhIM3b76/cTUTbtqeTaMY0s3WNqvs=;
 b=PkvJIpDo6pYbwcFR9Q5gP57p+NvwSkGHEee/4R7tD7062+qTqMUvYvvMZPnfWyqeTXMVfdyI308n/f0HzmAdSXFGlZrbkVv7CAGKnIESmsPbJZADuAC/gtkA8bt/c+D3MeM0SBuK5LQ0fy4N4Tcm/RqVdPINp14JsCjL8d93K0c=
Received: from BYAPR04MB4357.namprd04.prod.outlook.com (20.176.251.147) by
 BYAPR04MB5126.namprd04.prod.outlook.com (52.135.235.76) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.15; Thu, 21 Feb 2019 23:49:45 +0000
Received: from BYAPR04MB4357.namprd04.prod.outlook.com
 ([fe80::91f1:a2af:8793:94a2]) by BYAPR04MB4357.namprd04.prod.outlook.com
 ([fe80::91f1:a2af:8793:94a2%7]) with mapi id 15.20.1622.020; Thu, 21 Feb 2019
 23:49:45 +0000
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
Subject: Re: [LSF/MM TOPIC] Page Cache Flexibility for NVM
Thread-Topic: [LSF/MM TOPIC] Page Cache Flexibility for NVM
Thread-Index: AQHUyjrUW2lvg3E88ESemij+/GgUJKXq68aA
Date: Thu, 21 Feb 2019 23:49:45 +0000
Message-ID: <18a9f8a3bda3d0c54a7e58eef03c75d8afc7c66d.camel@wdc.com>
References: <85ddda85755bf15ed2e56bce21f711ae8154d304.camel@wdc.com>
In-Reply-To: <85ddda85755bf15ed2e56bce21f711ae8154d304.camel@wdc.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Adam.Manzanares@wdc.com; 
x-originating-ip: [199.255.44.250]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b6e23f88-45f5-4f73-91d5-08d69857420c
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:BYAPR04MB5126;
x-ms-traffictypediagnostic: BYAPR04MB5126:
x-ms-exchange-purlcount: 1
wdcipoutbound: EOP-TRUE
x-microsoft-exchange-diagnostics:
 =?utf-8?B?MTtCWUFQUjA0TUI1MTI2OzIzOnk5UjU0dDdHS0J0aGNhZDdQbGs2UTVDRGlr?=
 =?utf-8?B?L0ZLU29BQ09KTlVGVEE2NC8wMXFKSExBVmZtaXNzWjR0Rm9HYWYwUm9HekJS?=
 =?utf-8?B?WklmMENXS0wxZ2ZzaDNkNWRqNFpOVmxYNEVWb3owQzRLcjJyYjk2cWkrUFVM?=
 =?utf-8?B?cklLMEVUNXlRc25VQW0ybzFKb1dvT2hMODJnWWVndSt1SnhPdXFoaWcyVk4r?=
 =?utf-8?B?bU92c3RhalpkK2VnTHhnU2lQSzJBUXZTQTJpS1pJMUR2Zks2cHhuMGJZeDZJ?=
 =?utf-8?B?Y2RYK2l0TGZ2Rm51SFJvNG5vNFBJTDZXeksrcHdJU3MyZlFBOWJIN2tqcXFT?=
 =?utf-8?B?OTNnd01lbFhVN0s5L0l6Qm5tNWMva0R6cWgxdHRkSTBLa1VoUXNwUktwb0pL?=
 =?utf-8?B?NHlWYVlOdnJqZlM5RER5NDhLOExuRGxRZ1lFTzBYNExtYlRxb0p3V3d6K3d6?=
 =?utf-8?B?WmtaNDRMNzB2aFNab3JvMkNHc1JjeEpkZHNkVGpWSXpSbHNlbkJRV2k1bEg4?=
 =?utf-8?B?azZNRDErd1hTRGpvMXJXbkNGVFBGcmREQWNkeXRhbWRhL1NLUkZUWVV0M1lP?=
 =?utf-8?B?OHNrZTRjZkRvQUE0endwVjlhMDlOQityeDUvRFNCTTVTSHNBSms4ME1EU1gz?=
 =?utf-8?B?bGNibE1mTkRvcGlUTVFxVkQ2ajA4YXprZ2dZamluRUcxY2dhZ1RZQzVnNDdT?=
 =?utf-8?B?ZHpIdFBjWjVoU2h6ejdVeU5yS3FLWHk5M0F0cTZmNndLcE5XTnBYNzhOYWYr?=
 =?utf-8?B?bkFjejBwdTZ3L0pXTjV3VEw1Y3NqdDUrSkFnejlyVy80QUxQbUxxMWN2ZDFp?=
 =?utf-8?B?cWcxUWc4OGNMdUlBd3JtMk9EeDQwQ3BZYWo5dDA1MkQwWEZzQXgrV1AwejZk?=
 =?utf-8?B?OXViTTFYVkppcTVOdTZQYm1pQVdIU0Z1QUM2OGhrUVdUTGdSZW81VW0vUDRG?=
 =?utf-8?B?aGFOSFdmVEo2MzNGenNINFNTZWkzUVF6U1JTek5qeTN2dFZWbFE1QjBQZ2k4?=
 =?utf-8?B?b3JXeDNOOHd4d3RZMWkyUTRNclV4ckw0ZloyYzcxOXJXWndCRXNqVkVwUVJM?=
 =?utf-8?B?eHZWTWN0Mis2VDRpSDRzaG9DcmEzN3BsaExqN09zZUVDS0k1L3Q4d0hMVFRt?=
 =?utf-8?B?TzJqL0c4TVBHanMyQ1o3cG1uS2REV3RvUnRBbmxra2ExZHVZbGhLMm9XVzFX?=
 =?utf-8?B?ZHN0RlBBYkpaTGZuUHQwYVRVby9jcG5TdVFyM0gyV2g1ZVVuamFzZW1vZjF1?=
 =?utf-8?B?YkJieTJuOVc1TCtJblo3T3lhZUMzcG1CVCt2ZjBTVFJva0tYSTRVdmpEbjdW?=
 =?utf-8?B?WVJYNmNteUMyMVFEQVlBdTdYN0pjTHNYQmlWc29VeDY3UjZoNXNSN2tlZ1l1?=
 =?utf-8?B?eEJBYk5QTldUZ1Myclg0SHdQcUFoTDVlV2pzUjdEbkd6NEVoc2NjZVBYWFVX?=
 =?utf-8?B?UVJaK3dQWTI1Ly81Vndad3FyV1ZxTGc3azhoSDVrNzFkUVJjUTVjbm92bHVp?=
 =?utf-8?B?VHVhT08vY0dWQjZxMEF4MnRScHdlcVllbndERTFzTUh4L2VPNzYzZ1p5dUc4?=
 =?utf-8?B?WkpmNEFCcmhvcFVFWkt5N0hRUmR0NmpscXBRckEvUUZxOVpHRmxRYUpUQ3B0?=
 =?utf-8?B?WkVtL3p0enRYUmxDeW5yZDNtQ1BpTWZpTXBlN0ZmLytBdXlienpndHJRd2ti?=
 =?utf-8?B?Y2ZYMXFHREUzTStsYXJHQ0lGSzM0RHZ1ME12Z0dPbDRZU1ROalUvdndZZWNT?=
 =?utf-8?B?ZjZTcmZqVUEvaWFpemx2MXphWVVqZHVCUWp5VnZyTDZJWjQ1cWlkSGIwWDNY?=
 =?utf-8?B?T1dKMk5XZlJWNFhzcTRqWERYckxBRzI2ZytkR3hKa0lEdXljUUNkbFo0RERn?=
 =?utf-8?Q?MjJ2YFXV10Y=3D?=
x-microsoft-antispam-prvs:
 <BYAPR04MB5126A4A369A060C164BF90E0F07E0@BYAPR04MB5126.namprd04.prod.outlook.com>
x-forefront-prvs: 09555FB1AD
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(376002)(396003)(136003)(346002)(39860400002)(366004)(199004)(189003)(43544003)(11346002)(76176011)(81156014)(118296001)(2501003)(966005)(14454004)(5660300002)(478600001)(316002)(54906003)(486006)(2351001)(106356001)(81166006)(6506007)(71200400001)(71190400001)(26005)(446003)(102836004)(99286004)(476003)(186003)(72206003)(2616005)(105586002)(8936002)(8676002)(14444005)(256004)(86362001)(6916009)(6512007)(5640700003)(4326008)(6306002)(6486002)(53936002)(6246003)(97736004)(68736007)(7736002)(305945005)(229853002)(3846002)(25786009)(36756003)(6116002)(2906002)(7416002)(66066001)(6436002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR04MB5126;H:BYAPR04MB4357.namprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 km7CRBydb/EYVbwsCk2YHuYS9q7OfnyJOdq0PPSPPLT6ndHY+18N4xbp/DKOed1hBoXTSsfS85+dSxlnD0QqDSlcuL7cqYGa1viluvp82lFpnZPh50hVUD52SJQZ9gmweuySP4PIAe7uHToMC2WHx8eS202yVUxAE+e0VDqjdLgUBpOUcqZ0MvNT6eDgtxuZYJ61A9gzW0668gLx6d7tAPcxX2USeRp2jpi4W+9Zf2X+capxlYgsILi1+k6VSswiFHyrfNZwaxgW3wLCWPb3TBoaASAqcGgwJtm1PSmtMZYFj5Iy6M2VxTaGLzGhd5GMc2nX/xa6Z+YoErJ14xRPMNK7soVR32bYv/LtEtZFlFMvqYVvLhSj+XXKEXPoIJmbag0+LcPYokHbl4BSLkipXRY/dxl+fKZn3eGRdeBBfqI=
Content-Type: text/plain; charset="utf-8"
Content-ID: <6AC3967611FF9C458D7D0CF2C0489BBA@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: wdc.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b6e23f88-45f5-4f73-91d5-08d69857420c
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Feb 2019 23:49:45.5349
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b61c8803-16f3-4c35-9b17-6f65f441df86
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR04MB5126
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Rm9yZ290IHRoZSBsaW5rLg0KDQpbMV0gaHR0cHM6Ly9naXRodWIuY29tL3dlc3Rlcm5kaWdpdGFs
Y29ycG9yYXRpb24vaG1tYXANCg0KVGFrZSBjYXJlLA0KQWRhbQ0KDQoNCk9uIFRodSwgMjAxOS0w
Mi0yMSBhdCAxNToxMSAtMDgwMCwgQWRhbSBNYW56YW5hcmVzIHdyb3RlOg0KPiBIZWxsbywNCj4g
DQo+IEkgd291bGQgbGlrZSB0byBhdHRlbmQgdGhlIExTRi9NTSBTdW1taXQgMjAxOS4gSSdtIGlu
dGVyZXN0ZWQgaW4NCj4gc2V2ZXJhbCBNTSB0b3BpY3MgdGhhdCBhcmUgbWVudGlvbmVkIGJlbG93
IGFzIHdlbGwgYXMgWm9uZWQgQmxvY2sNCj4gRGV2aWNlcyBhbmQgYW55IGlvIGRldGVybWluaXNt
IHRvcGljcyB0aGF0IGNvbWUgdXAgaW4gdGhlIHN0b3JhZ2UNCj4gdHJhY2suIA0KPiANCj4gSSBo
YXZlIGJlZW4gd29ya2luZyBvbiBhIGNhY2hpbmcgbGF5ZXIsIGhtbWFwIChoZXRlcm9nZW5lb3Vz
IG1lbW9yeQ0KPiBtYXApIFsxXSwgZm9yIGVtZXJnaW5nIE5WTSBhbmQgaXQgaXMgaW4gc3Bpcml0
IGNsb3NlIHRvIHRoZSBwYWdlDQo+IGNhY2hlLiBUaGUga2V5IGRpZmZlcmVuY2UgYmVpbmcgdGhh
dCB0aGUgYmFja2VuZCBkZXZpY2UgYW5kIGNhY2hpbmcNCj4gbGF5ZXIgb2YgaG1tYXAgaXMgcGx1
Z2dhYmxlLiBJbiBhZGRpdGlvbiwgaG1tYXAgc3VwcG9ydHMgREFYIGFuZA0KPiB3cml0ZQ0KPiBw
cm90ZWN0aW9uLCB3aGljaCBJIGJlbGlldmUgYXJlIGtleSBmZWF0dXJlcyBmb3IgZW1lcmdpbmcg
TlZNcyB0aGF0DQo+IG1heQ0KPiBoYXZlIHdyaXRlL3JlYWQgYXN5bW1ldHJ5IGFzIHdlbGwgYXMg
d3JpdGUgZW5kdXJhbmNlIGNvbnN0cmFpbnRzLg0KPiBMYXN0bHkgd2UgY2FuIGxldmVyYWdlIGhh
cmR3YXJlLCBzdWNoIGFzIGEgRE1BIGVuZ2luZSwgd2hlbiBtb3ZpbmcNCj4gcGFnZXMgYmV0d2Vl
biB0aGUgY2FjaGUgd2hpbGUgYWxzbyBhbGxvd2luZyBkaXJlY3QgYWNjZXNzIGlmIHRoZQ0KPiBk
ZXZpY2UNCj4gaXMgY2FwYWJsZS4NCj4gDQo+IEkgYW0gcHJvcG9zaW5nIHRoYXQgYXMgYW4gYWx0
ZXJuYXRpdmUgdG8gdXNpbmcgTlZNcyBhcyBhIE5VTUEgbm9kZQ0KPiB3ZSBleHBvc2UgdGhlIE5W
TSB0aHJvdWdoIHRoZSBwYWdlIGNhY2hlIG9yIGEgdmlhYmxlIGFsdGVybmF0aXZlIGFuZA0KPiBo
YXZlIHVzZXJzcGFjZSBhcHBsaWNhdGlvbnMgbW1hcCB0aGUgTlZNIGFuZCBoYW5kIG91dCBtZW1v
cnkgd2l0aA0KPiB0aGVpciBmYXZvcml0ZSB1c2Vyc3BhY2UgbWVtb3J5IGFsbG9jYXRvci4NCj4g
DQo+IFRoaXMgd291bGQgaXNvbGF0ZSB0aGUgTlZNcyB0byBvbmx5IGFwcGxpY2F0aW9ucyB0aGF0
IGFyZSB3ZWxsIGF3YXJlDQo+IG9mIHRoZSBwZXJmb3JtYW5jZSBpbXBsaWNhdGlvbnMgb2YgYWNj
ZXNzaW5nIE5WTS4gSSBiZWxpZXZlIHRoYXQgYWxsDQo+IG9mIHRoaXMgd29yayBjb3VsZCBiZSBz
b2x2ZWQgd2l0aCB0aGUgTlVNQSBub2RlIGFwcHJvYWNoLCBidXQgdGhlIHR3bw0KPiBhcHByb2Fj
aGVzIGFyZSBzZWVtaW5nIHRvIGJsdXIgdG9nZXRoZXIuDQo+IA0KPiBUaGUgbWFpbiBwb2ludHMg
SSB3b3VsZCBsaWtlIHRvIGRpc2N1c3MgYXJlOg0KPiANCj4gKiBJcyB0aGUgcGFnZSBjYWNoZSBt
b2RlbCBhIHZpYWJsZSBhbHRlcm5hdGl2ZSB0byBOVk0gYXMgYSBOVU1BIE5PREU/DQo+ICogQ2Fu
IHdlIGFkZCBtb3JlIGZsZXhpYmlsaXR5IHRvIHRoZSBwYWdlIGNhY2hlPw0KPiAqIFNob3VsZCB3
ZSBmb3JjZSBzZXBhcmF0aW9uIG9mIE5WTSB0aHJvdWdoIGFuIGV4cGxpY2l0IG1tYXA/DQo+IA0K
PiBJIGJlbGlldmUgdGhpcyBkaXNjdXNzaW9uIGNvdWxkIGJlIG1lcmdlZCB3aXRoIE5VTUEsIG1l
bW9yeSBoaWVyYXJjaHkNCj4gYW5kIGRldmljZSBtZW1vcnksIFVzZSBOVkRJTU0gYXMgTlVNQSBu
b2RlIGFuZCBOVU1BIEFQSSwgb3IgbWVtb3J5DQo+IHJlY2xhaW0gd2l0aCBOVU1BIGJhbGFuY2lu
Zy4NCj4gDQo+IEhlcmUgYXJlIHNvbWUgcGVyZm9ybWFuY2UgbnVtYmVycyBvZiBobW1hcCAoaW4g
ZGV2ZWxvcG1lbnQpOg0KPiANCj4gQWxsIG51bWJlcnMgYXJlIGNvbGxlY3RlZCBvbiBhIDRHaUIg
aG1tYXAgZGV2aWNlIHdpdGggYSAxMjhNaUIgY2FjaGUuDQo+IEZvciB0aGUgbW1hcCB0ZXN0cyBJ
IHVzZWQgY2dyb3VwcyB0byBsaW1pdCB0aGUgcGFnZSBjYWNoZSB1c2FnZSB0bw0KPiAxMjhNaUIu
IEFsbCByZXN1bHRzIGFyZSBhbiBhdmVyYWdlIG9mIDEwIHJ1bnMuIFcgYW5kIFIgYWNjZXNzIHRo
ZQ0KPiBlbnRpcmUgZGV2aWNlIHdpdGggYWxsIHRocmVhZHMgc2VncmVnYXRlZCBpbiB0aGUgYWRk
cmVzcyBzcGFjZS4gUlINCj4gcmVhZHMgdGhlIGVudGlyZSBkZXZpY2UgcmFuZG9tbHkgOCBieXRl
cyBhdCBhIHRpbWUgYW5kIGlzIGxpbWl0ZWQgdG8NCj4gOE1pQiBvZiBkYXRhIGFjY2Vzc2VkLg0K
PiANCj4gaG1tYXAgYnJkIHZzLiBtbWFwIG9mIGJyZA0KPiANCj4gCWhtbWFwCQkJbW1hcAkJCQ0K
PiANCj4gVGhyZWFkcyBXICAgICBSICAgICBSUiAJICBXIAlSICAgICBSUiANCj4gDQo+IDEgIAk3
LjIxICA1LjM5ICA1LjA0ICA2LjgwICA1LjYzICA1LjIzCQ0KPiAyCTUuMTkgIDMuODcgIDMuNzQg
IDQuNjYgIDMuMzMgIDMuMjANCj4gNAkzLjY1ICAyLjk1ICAzLjA3ICAzLjUzICAyLjI2ICAyLjE4
DQo+IDgJNC41MiAgMy40MyAgMy41OSAgNC4zMCAgMS45OCAgMS44OA0KPiAxNgk1LjAwICAzLjg1
ICAzLjk4ICA0LjkyICAyLjAwICAxLjk5DQo+IA0KPiANCj4gDQo+IE1lbW9yeSBCYWNrZW5kIFRl
c3QgKERheCBjYXBhYmxlKQ0KPiANCj4gCWhtbWFwICAgICAgICAgICAgIGhtbWFwLWRheCAgICAg
ICAgIGhtbWFwLXdycHJvdGVjdA0KPiANCj4gVGhyZWFkcwlXICAgICBSICAgICBSUiAgICBXICAg
ICBSICAgICBSUiAgICBXICAgICBSICAgICBSUiANCj4gDQo+IDEgICAgICAJNi4yOSAgNC45NCAg
NC4zNyAgMi41NCAgMS4zNiAgMC4xNiAgNy4xMiAgMi4xMyAgMC43MyANCj4gMgk0LjYyICAzLjYz
ICAzLjU3ICAxLjQxICAwLjY5ICAwLjA4ICA1LjA2ICAxLjE0ICAwLjQxDQo+IDQJMy40NSAgMi45
NyAgMy4xMSAgMC43NyAgMC4zNiAgMC4wNCAgMy42NiAgMC42MyAgMC4yNQ0KPiA4CTQuMTAgIDMu
NTMgIDMuNzEgIDAuNDQgIDAuMTkgIDAuMDIgIDQuMDMgIDAuMzUgIDAuMTcNCj4gMTYJNC42MCAg
My45OCAgNC4wNCAgMC4zNCAgMC4xNiAgMC4wMiAgNC41MiAgMC4yNyAgMC4xNA0KPiANCj4gDQo+
IFRoYW5rcywNCj4gQWRhbQ0KPiANCj4gDQo+IA0KPiANCg==

