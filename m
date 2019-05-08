Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A0F5C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 15:44:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA926214AF
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 15:44:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=microsoft.com header.i=@microsoft.com header.b="ALdj58xo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA926214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=microsoft.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 935976B02BC; Wed,  8 May 2019 11:44:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90C266B02BD; Wed,  8 May 2019 11:44:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 785B66B02C0; Wed,  8 May 2019 11:44:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F3156B02BC
	for <linux-mm@kvack.org>; Wed,  8 May 2019 11:44:48 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d10so11714798plo.12
        for <linux-mm@kvack.org>; Wed, 08 May 2019 08:44:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:msip_labels:content-transfer-encoding:mime-version;
        bh=4eXY5P85hlEDTJFdXrQveLSTJ/6Sb1Qq1PynUTp7UQg=;
        b=sq1eASWvTGFHKghRzV8Opx1jjZRf6IjDf0yg+YOcFZ+PzCL8eI4b8cCqV0BAkKDszw
         Eqoo04SLr352eOSg94+Ar2V8U/2c0hVPUUEBhJX6U8w1DDwoCVXkGFMuKuzm+QovtIQE
         zGXC5vYCxTM+otPmoOF9Sk5E+ePToxnfOryOF+u+B0GHwdYxH0T6ESvsd+bh7S0J0w8+
         YlXBmIHvOA4JCNxFtvR2W+GB8eFBK5vsZWnDpyqET1l/0boo2J8yiDTvlu93HFgaF6G+
         Bc3waYd+mDchVBuGxzueLX/xnrxPDLY7ylT1roB69av1iENNDc5kZBdU+oVwYXXISoJ1
         RUWw==
X-Gm-Message-State: APjAAAVbdhSSq3h856r4V89edtRwnBtocA5XVw4SZccVEzTljcGAcc0B
	/n6VckLuo4fIq9eyMJiLcXfKKK8qLb2HHI2lFDZdSjkegcwpRjvgMaLlN+lQwgcDqxdwDmnRVsg
	6/qrJZ1pfCiB+OgPyVt46KAKoJl0rtD7EQRshhFQH2mDMVLZXz99x/DI/h9UoSbC1RQ==
X-Received: by 2002:aa7:92d5:: with SMTP id k21mr49591129pfa.223.1557330287469;
        Wed, 08 May 2019 08:44:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlhbuqcopKsm9pFKjjCTOYQdJmNNnShXcTNB/OpyxufwOuRPhG9C6si1xVczh/h2y3kedJ
X-Received: by 2002:aa7:92d5:: with SMTP id k21mr49591007pfa.223.1557330286665;
        Wed, 08 May 2019 08:44:46 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1557330286; cv=pass;
        d=google.com; s=arc-20160816;
        b=nnMs3vifrRuGdX4RPdpIYmsgdDzKQz6CzVXi3pT7moiJ3/+cbsC2qXzutNG9DpAlHJ
         0wePAveJoxt9dHhQPxPRwrxsQHrClH0hjNptwvlwcOQLMoPk6znn/FlITL/xt1lCmolJ
         +qLBg2SeV19zgOZKY7yoI8v+b0lGJsv2ZK7EBl7mvnZ5GUGTahQeuEV7UOW++eKVKZne
         wry6sOuJzowKRxxl4PrEVkBq01uJkO4XsxnUbBbDSNIu2MXyH2L2aDGaBIeemQVMcVHS
         quD/grTqSH1nMlNCoPfb/35Cpn2xxT3oJiJ9p0UxWsNZt+eeFT/8/7goEtiAYhhdjpmb
         a9cg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:msip_labels:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=4eXY5P85hlEDTJFdXrQveLSTJ/6Sb1Qq1PynUTp7UQg=;
        b=eamWX8I0kYXKTonqW48xBsY+m75BdbLnhlmJhFiIUU9B7PnIrTTtKJDI1xXdvBQH8V
         Ac1XZW/qsY8tiZam1NyNhO5HlL2i9xYE7pGLWciP/C7mYWDiPgNYwoBz+ogUIh1m628F
         T86ypM0jEoECqfaGdKFrnSM9S5nXsu7D1xo9Fnbw85vqQDpdApbiPj9274HGwnPk8PBe
         RwlcsRfmSQRe2s06RXg9gvilg+717j2/aK35vTUvvUsImhM6YjqaALr4rKucvhnelrXQ
         ie2gpR5qOzEWukM8OhPFkfEhJK2s5Cm31LKIxNFT0wVgJHDanNm6xF+ITlkRsssVnL2t
         12iA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@microsoft.com header.s=selector1 header.b=ALdj58xo;
       arc=pass (i=1);
       spf=pass (google.com: domain of decui@microsoft.com designates 40.107.132.139 as permitted sender) smtp.mailfrom=decui@microsoft.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=microsoft.com
Received: from APC01-PU1-obe.outbound.protection.outlook.com (mail-eopbgr1320139.outbound.protection.outlook.com. [40.107.132.139])
        by mx.google.com with ESMTPS id 3si23040924pft.22.2019.05.08.08.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 08:44:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of decui@microsoft.com designates 40.107.132.139 as permitted sender) client-ip=40.107.132.139;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@microsoft.com header.s=selector1 header.b=ALdj58xo;
       arc=pass (i=1);
       spf=pass (google.com: domain of decui@microsoft.com designates 40.107.132.139 as permitted sender) smtp.mailfrom=decui@microsoft.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=microsoft.com
ARC-Seal: i=1; a=rsa-sha256; s=testarcselector01; d=microsoft.com; cv=none;
 b=ofRA4xA5RhYmPwbyQH+JhObxDQaeE3HsBhZImbUxg5aHsRwq26rZejQmKZf9S9sWjGrG+Kp5qZYg8pvLueuprPZxOY4I5wGZu75w0vqi+q1RR6IiB051NFV64JHNLvCKme8LVfEWcrByvGz08zAS8zdUy2hIlhtj9JfHswGmSkQ=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=testarcselector01;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4eXY5P85hlEDTJFdXrQveLSTJ/6Sb1Qq1PynUTp7UQg=;
 b=CgQHYA7AgZabGoH6Wb1eWHFOSE8fn9cEryoOeEN8V+4oPKbJa6sJ5hvzHzwkKcS8N3Wlfyc2T7Qlfeukou97Z6UX89N956KCh2JGfNWmdzKP9IiInfglr4roEQhvIE9V04Fba0uzDYN1DhXnYQmlNUm6Iv9K7SB9nYUmIcs2Ymo=
ARC-Authentication-Results: i=1; test.office365.com
 1;spf=none;dmarc=none;dkim=none;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4eXY5P85hlEDTJFdXrQveLSTJ/6Sb1Qq1PynUTp7UQg=;
 b=ALdj58xomoJXaW1XfxQbfvM0DMac/w00BTR9MuaP/Wgn1UwFaOl4ludseokqi1vn2aqlp6aJkQmq9xnW+0RQ2W85rkzXdvkbz5AYrV4PKhgMr9fMrqkskgQMCurOUDQX8vAMQNWB93Y+8jSxqxoll8SinRZV9a5s4H9x68ic6Qg=
Received: from PU1P153MB0169.APCP153.PROD.OUTLOOK.COM (10.170.189.13) by
 PU1P153MB0204.APCP153.PROD.OUTLOOK.COM (52.133.194.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.4; Wed, 8 May 2019 15:44:42 +0000
Received: from PU1P153MB0169.APCP153.PROD.OUTLOOK.COM
 ([fe80::dc7e:e62f:efc9:8564]) by PU1P153MB0169.APCP153.PROD.OUTLOOK.COM
 ([fe80::dc7e:e62f:efc9:8564%4]) with mapi id 15.20.1900.002; Wed, 8 May 2019
 15:44:42 +0000
From: Dexuan Cui <decui@microsoft.com>
To: Mel Gorman <mgorman@techsingularity.net>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, Michal
 Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir
 Davydov <vdavydov.dev@gmail.com>, Roman Gushchin <guro@fb.com>, Hugh Dickins
	<hughd@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
	"dchinner@redhat.com" <dchinner@redhat.com>, Greg Thelen
	<gthelen@google.com>, Kuo-Hsin Yang <vovoy@chromium.org>
Subject: RE: isolate_lru_pages(): kernel BUG at mm/vmscan.c:1689!
Thread-Topic: isolate_lru_pages(): kernel BUG at mm/vmscan.c:1689!
Thread-Index: AdUAdyzy8F3SUITdRv6SToKOnShIegFEkBcAAArOBmA=
Date: Wed, 8 May 2019 15:44:41 +0000
Message-ID:
 <PU1P153MB01696DAD3BD2DBA8B3E85C93BF320@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
References:
 <PU1P153MB01693FF5EF3419ACA9A8E1FDBF3B0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20190508103308.GF18914@techsingularity.net>
In-Reply-To: <20190508103308.GF18914@techsingularity.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels: MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Enabled=True;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SiteId=72f988bf-86f1-41af-91ab-2d7cd011db47;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Owner=decui@microsoft.com;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SetDate=2019-05-08T15:44:37.1932174Z;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Name=General;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Application=Microsoft Azure
 Information Protection;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_ActionId=ecd28f9b-8cb0-4437-a11e-f169ca5af7bf;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Extended_MSFT_Method=Automatic
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=decui@microsoft.com; 
x-originating-ip: [2601:600:a280:1760:f121:4a59:260c:3caa]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bf335360-1096-45c0-02f5-08d6d3cc166c
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:PU1P153MB0204;
x-ms-traffictypediagnostic: PU1P153MB0204:
x-ld-processed: 72f988bf-86f1-41af-91ab-2d7cd011db47,ExtAddr
x-microsoft-antispam-prvs:
 <PU1P153MB0204C50E9CCFF06ACFBC8187BF320@PU1P153MB0204.APCP153.PROD.OUTLOOK.COM>
x-ms-oob-tlc-oobclassifiers: OLM:580;
x-forefront-prvs: 0031A0FFAF
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(376002)(136003)(366004)(39860400002)(396003)(346002)(199004)(189003)(9686003)(8936002)(4744005)(316002)(14454004)(446003)(7416002)(8676002)(81166006)(81156014)(54906003)(22452003)(478600001)(99286004)(10290500003)(6506007)(229853002)(76176011)(7696005)(6436002)(7736002)(305945005)(5660300002)(86612001)(86362001)(256004)(76116006)(2906002)(476003)(66446008)(8990500004)(71200400001)(71190400001)(25786009)(66556008)(66476007)(66946007)(73956011)(52536014)(64756008)(186003)(102836004)(55016002)(46003)(4326008)(10090500001)(53936002)(6116002)(6246003)(11346002)(74316002)(33656002)(6916009)(486006)(68736007);DIR:OUT;SFP:1102;SCL:1;SRVR:PU1P153MB0204;H:PU1P153MB0169.APCP153.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: microsoft.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 BH5SLtFh+rlV8Fi8KTC6jjrCPEP6u9FAKJGieMMUsW4W7RXF8iGRlY8pAoSPH8B6WmmRzHZ/NEpaRIWUaW6MCMl8qRSnLOkbg1R3V+GlT3oCnl2EyQQGauNV1E9qUO4LBsLwD7mzUCvSG4IavKkWiqhDGFpBNQ0XVR3uvzBg1s/lXPthrRHHTqoa8EF3rgWawHfc6h63H2P6volkyl5DkMrzBWTintvw3c5/ZIkrV96SACaoDH4fkQ6U2PsVFxKYdF/rv6sX4BGt1Z4S2BV+UrX6p1u+MHVd0sEe5jfO5/ZQhFHSFLlsHqsqYIgiHIauxyy2cpfIYl50rt0tqlVs1Xr3xMOYHnSXB/m4o9UyfXVjFLJoPoG0obod4NBIOnCWrscLJJ7141g5ymJmwmqEh09PQPeqrqJZw8108RvIUvI=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: microsoft.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bf335360-1096-45c0-02f5-08d6d3cc166c
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 May 2019 15:44:41.8402
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 72f988bf-86f1-41af-91ab-2d7cd011db47
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PU1P153MB0204
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> From: Mel Gorman <mgorman@techsingularity.net>
> Sent: Wednesday, May 8, 2019 3:33 AM
> On Wed, May 01, 2019 at 11:49:10PM +0000, Dexuan Cui wrote:
> > Hi,
> > Today I got the below BUG in isolate_lru_pages() when building the kern=
el.
> >
> > My current running kernel, which exhibits the BUG, is based on the main=
line
> kernel's commit
> > 262d6a9a63a3 ("Merge branch 'x86-urgent-for-linus' of
> git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip").
> >
> > Looks nobody else reported the issue recently.
> >
> That is missing some fixes that were merged for 5.1, particularly
> 6b0868c820ff ("mm/compaction.c: correct zone boundary handling when
> resetting pageblock skip hints"). Can you try reproducing this under 5.1
> at least?
>=20
> --
> Mel Gorman
> SUSE Labs

So far I only reproduced the issue once, and I don't know how to repro it a=
gain.

If I repro it again, I'll move to v5.1 with the "dump_page(page);" change.

Thanks,
-- Dexuan

