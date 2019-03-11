Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF66DC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 21:55:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 697162147C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 21:55:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="bOj9klGS";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Brqapsrb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 697162147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2CAE8E0003; Mon, 11 Mar 2019 17:55:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDBDB8E0002; Mon, 11 Mar 2019 17:55:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA3748E0003; Mon, 11 Mar 2019 17:55:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5B98E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 17:55:30 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b6so686319ywd.23
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 14:55:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=5WpMukIKjceil3SpIAngqgCoYJv6uUf8iK+7I+cfzkA=;
        b=TmxnjuiKbd6JuF3utORyW6kzmVVXBF0OP9WfVmspeHpeHOLNY+y2/10BbLY1W1w7Yj
         mYASk+tofTbftmEvSFFh5baiRvbNGSZxqKkYxJldLy289zEYBEN7G34YeJq9RfNBSpRB
         j+w82IIPXi953UwtlOdO+0TDv7B7wGZDLIxvzg2oxDeNXM50j0DQo7AKRPfXOpURVkYO
         o58YmgEHVJwIWohV7uuU8W0yPGOsFhRK8b6EPjR+38LEVlUc6jTT4ZF1J4m+4B9qqLLw
         9lZlQ8+hj8301suvxdLbPGXc6bdSYbppQhV0qMH91T71LmJOWvrwsn44F/jo2K3E+htr
         wtIw==
X-Gm-Message-State: APjAAAWs1zP8olWJ0YsL38fRbPmDyKMJCJKkbwef2SB/MP7Q/NXL5oij
	pDIO6vIgL1vvdyH4zU2PjemANxftlGp5oGat5RkGZS1oIQ5d6k4vvm8cO23nIux67PaxcOs/Ul4
	w8/XoENO4VJdz84jYLCE7cL3nHCSTDQumA6hYrPEokgYvaLME8Wc4FuwLpxBDsshntg==
X-Received: by 2002:a0d:edc3:: with SMTP id w186mr27294404ywe.301.1552341330403;
        Mon, 11 Mar 2019 14:55:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1+hfzvmNQKfKis2z05T4aNdQCxWpRG/+XIYwDhD/J5nSftYkRwsTxJsYo+TAoe4LwfyOz
X-Received: by 2002:a0d:edc3:: with SMTP id w186mr27294393ywe.301.1552341329936;
        Mon, 11 Mar 2019 14:55:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552341329; cv=none;
        d=google.com; s=arc-20160816;
        b=rooUdccMTxpaTo1ofxCdMwogiS4/rYzKDeQf/lxORpbsgdE15fJTtyB7AvmsDNyhw7
         Fox85ordWPPra8iXyOtDYVTjiCg9jACn2CIKAKKlf6y7B7osIF46qBbK8oipzoQKYsLD
         MfdN5GJtc/EIQoCqnpS+/cCvm7mdrcRTDe+3OvTT5hbP9FSY+YO97wMuiCar+kaL6skE
         fJU/DVsWe2qGarUTwaosBvK1W2M77wIZ7Uaq51nLo+XpwXS6wyyr2pVOwpPd2yo8POFP
         4GhErj3q6n3a2TtORhU9j6ajMWoj7ll2zGo5rT2wh3Gm7UBU3D3pubE5UZYyyq8H16Om
         e3bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=5WpMukIKjceil3SpIAngqgCoYJv6uUf8iK+7I+cfzkA=;
        b=itUFrqzo4cZIuvIAcXHhJutUyG/R1FF7wnVyxq4tOMqsnRhi+EzEMvsjgFIrFTxcRy
         Q4BpT1SsDYEB30Qd7A0AvXC+j/0DuPpfHW0MZHZmAarxcz+d0S9+YqXK11Nx2V0pFSqj
         Tw7G7GTZEx5vpyygeFEOanaqbHZYIAlzh6sxDuX1iwrITTv9LPAId8hVtp4a1wT7evRk
         NZYDHbwvJjevNo5O3OnCURpcH1nIbVttfXu7yhO7mKCzA6awmn/VdgD+EE3MHXHLv+pT
         5rJW+yVcjokF/GDEbY4LMTWzJt57DzekIIxSHbdl35gryJYwNsNiqt5oez/Ie/TqdY0I
         7DgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bOj9klGS;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Brqapsrb;
       spf=pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=897363b8f0=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w66si4214023ybg.222.2019.03.11.14.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 14:55:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bOj9klGS;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Brqapsrb;
       spf=pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=897363b8f0=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2BLkFTj016244;
	Mon, 11 Mar 2019 14:55:20 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=5WpMukIKjceil3SpIAngqgCoYJv6uUf8iK+7I+cfzkA=;
 b=bOj9klGSQ91vAxDIFYyo3BVCqMYyAS1Y6230xl+Hu2cKPIyaLgJeoQxAmg6gQ96uBmc2
 BbG5R7OP2aD/5m5IE+oXo2HaQAhXSp+tTZd3VcvHNjcMfjY5wSbJRwDG7QD0lkg+IsFN
 elk2mNJd5Zh1aVHaUlHNrOYOCDF5wCniLhA= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2r5w3srmff-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 11 Mar 2019 14:55:20 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 11 Mar 2019 14:54:18 -0700
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 11 Mar 2019 14:54:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5WpMukIKjceil3SpIAngqgCoYJv6uUf8iK+7I+cfzkA=;
 b=BrqapsrbN0Y2HSsETtFKz1p0Y/QXvDcVRmhasiQa9q4fXYyY8vcMa+NHKgz2hvxQ4JV2YZ9DCCXvc+oyfiV0UDUVfxSW1Uu7jRq/Apyo22bu5+pidCA24TpF1BcjmbJH0YcvPqAIRMmCXQ2z4qDuAB21QW+j6pr3m1tB+cF9VPs=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2262.namprd15.prod.outlook.com (52.135.197.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.19; Mon, 11 Mar 2019 21:54:17 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%2]) with mapi id 15.20.1686.021; Mon, 11 Mar 2019
 21:54:17 +0000
From: Roman Gushchin <guro@fb.com>
To: "Tobin C. Harding" <tobin@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Christopher Lameter
	<cl@linux.com>,
        Pekka Enberg <penberg@cs.helsinki.fi>,
        Matthew Wilcox
	<willy@infradead.org>, Tycho Andersen <tycho@tycho.ws>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [RFC 03/15] tools/vm/slabinfo: Add support for -C and -F options
Thread-Topic: [RFC 03/15] tools/vm/slabinfo: Add support for -C and -F options
Thread-Index: AQHU1WW9Q5dc3ffqEUmrnDIqAHiCmKYG/yKA
Date: Mon, 11 Mar 2019 21:54:17 +0000
Message-ID: <20190311215413.GB7915@tower.DHCP.thefacebook.com>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-4-tobin@kernel.org>
In-Reply-To: <20190308041426.16654-4-tobin@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR22CA0038.namprd22.prod.outlook.com
 (2603:10b6:300:69::24) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:b487]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5f8a58a6-10e4-4e7c-61b3-08d6a66c1bb5
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2262;
x-ms-traffictypediagnostic: BYAPR15MB2262:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2262;20:xk69ZlJcxUOgdCxxHWbjcFMj0bKl4x8tv4Mes8xEx8VLaL+hWoPRqc30FsGXzQ1vYriXxJWzx78I509yUmLliRjCoipBfgxzEW9BmkfJAmbxANW7fYzNozwbxRzFu51MTTU0No1KP+RzFTGBVzYXkJ1fWytGmZYuga5oUpuB7AU=
x-microsoft-antispam-prvs: <BYAPR15MB226231FA91450427DE6FD9BABE480@BYAPR15MB2262.namprd15.prod.outlook.com>
x-forefront-prvs: 09730BD177
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(396003)(366004)(136003)(346002)(376002)(199004)(189003)(5660300002)(6116002)(53936002)(316002)(6486002)(54906003)(81166006)(478600001)(68736007)(305945005)(386003)(4744005)(6512007)(99286004)(81156014)(76176011)(1076003)(52116002)(6436002)(6506007)(8936002)(9686003)(7736002)(25786009)(105586002)(229853002)(6246003)(2906002)(8676002)(97736004)(186003)(4326008)(106356001)(6916009)(14454004)(71190400001)(446003)(71200400001)(11346002)(486006)(476003)(33656002)(46003)(256004)(102836004)(86362001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2262;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: kX7YyUhaqp6Z8wmqVaKmlj+IhGwDxFPc3GCC5Pj4fWR1uipGO9TK3NQZhxlV6kjef8fONRhx/KkrIk2qWN0qsyk2/y3f2SmjAKSwaK33+zMtFxyat4xOS6e9qtwu8VGcHsGLVdijbFiyTodjUVdspdLhQYA1qHkkL2uSWQwjEpsqfm6hTpwAUR5RY/QlpavAZBXDigrdl6UrlqE1+DDyq1wtbFXgXCS0i3Lq5HZ0fiRLA6/H+vh+7WuoVfD14ZkXM1nlSaT/feWcnU1E/0NiBoFhRmGLY5oy4bQukHYoagQEeE7mY/W5wnh3GVnRTe/NO+ba8wtiGJT7QDWqZpsO3J0tnieAaggw8lTJ1ozU7s9M4P7OiDZ2fn+78JPticfDjHQ67D4LEUKUmaOgCl5bKiDymwPXVX1vK4hYhc88wOM=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A029BE8C00B34E46921E29BCC8B15777@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 5f8a58a6-10e4-4e7c-61b3-08d6a66c1bb5
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Mar 2019 21:54:17.3656
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2262
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-11_16:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 03:14:14PM +1100, Tobin C. Harding wrote:
> -F lists caches that support object migration.

Maybe -M?

>=20
> -C lists caches that use a ctor.
>=20
> Add command line options to show caches with a constructor and caches
> with that are migratable (i.e. have isolate and migrate functions).
>=20
> Co-developed-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> ---
>  tools/vm/slabinfo.c | 40 ++++++++++++++++++++++++++++++++++++----
>  1 file changed, 36 insertions(+), 4 deletions(-)

Thanks!

