Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00729C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:25:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A73DF2075C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:25:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="EFvJS0ay";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="iiNPnQaF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A73DF2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BA098E0003; Wed, 13 Mar 2019 14:25:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 369518E0001; Wed, 13 Mar 2019 14:25:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 231A78E0003; Wed, 13 Mar 2019 14:25:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D50C08E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:25:04 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w4so3105476pgl.19
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:25:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=aikG9yz0lcCeANUDQoaSydrOSD48pgBFE7UyJ3qbhh4=;
        b=pxTITsSWt2Zcglgl95dbwqd5MxrwR0wKOwEtjcFnljhxEEfD5v8cuI8t4+d+05tY+J
         3jzsbPFbku/WOjuDRGBfoP6BIVx706E07UI4+I2BcsimdFM5t21oi/10PH4Vlb+1XIS8
         rh1jOxKGaHC+n/IasOhTwG1AlXqpWkS0PREGToZU7t8fsEeabG47vwsn9c36nGYpN7Z3
         S+NdvfLpx8I9oo2+fUPJnpPmZua8z5nhDxO0PJpEWNzavXAqyx+A7Gc2ST95uT1VJQdR
         NQg+Remt+l2IOBkcqlkfO68Lx3N2ofxYjRy2z4+W6qtCUFW6AYScQse/yM1vMVCHBEE2
         l3jA==
X-Gm-Message-State: APjAAAVVK7x+bJwPNrT6SYfyIr+OBVtrZEt9Pm6BHVN04o7hueRII1FS
	91MAhwHfS+PY8Ku8gkqexgbFyILJAmFgzDOlbfn7uSv4p/F5J/w6/v5/LHmYse4glpIu8nXy3JT
	UKBAjTaV7qb8zuzfF4DMIVcQB+mpNtQXKdVRX3K2wVLrU12CB1joDFXJbmBGKCgWjhA==
X-Received: by 2002:a63:160d:: with SMTP id w13mr40836518pgl.85.1552501504438;
        Wed, 13 Mar 2019 11:25:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwShRdlOG0mJJyaF7AW2i8khnIHjtYO3YLow0DQG6MEjnCp2cW8TIylNIlUnxRftMrPTJb/
X-Received: by 2002:a63:160d:: with SMTP id w13mr40836467pgl.85.1552501503371;
        Wed, 13 Mar 2019 11:25:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552501503; cv=none;
        d=google.com; s=arc-20160816;
        b=mthOfOPIE1ppNqPS+kIrnWSoR1NJ6jr9WRIxok92gXwl3s11fA3+epgnA2HFVDvB68
         diityuPGXLFDWn1iUpYh3g4ndCaQo7u7ysS+XBEd8O+o5RW5i5YMmNhkyk8DwV46K7tB
         jWB9zZ4lzSER7s0bnMYZpm/z7tkGTNKlxsevvSkQFsGyqP/yOxfZE+V19StGv6UfPyw2
         3udCAVDJu4mLyMW2Q3mx6cH0AkD7A2pz1yoPpIi2UPa3v01Klhv4xca+k9SKGDsn4HIQ
         SrSpWEaoBiiL4m/maQGMyaCRfRvK5RnT8OtNxTRo+AlYn6uEbrh+sk9SKUfH/608RXIs
         /png==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=aikG9yz0lcCeANUDQoaSydrOSD48pgBFE7UyJ3qbhh4=;
        b=cMZf4ZRWcHYanDFsn5Jg7Zsx6qLcwW9p2JKh6HFt6oLXCMAfrC2BB4pMJ2htN6xG1Y
         2i2l22LY8xQpHiV0kj2ocGa8MiZhEIgJxwovuEIyz5LzJRnveNcK+SijFAvPO4P+jsFT
         eMW+wGj/4O5PIlQS9U4Sh35U/HDwkmykEk469Al4vAiqL9reb7vmAedo+3+4iSSGzB6I
         q5G0vSB2D1knCkJg1roWcYdFB+59drJWwh0NGjxv+aooaSdxoyv3rqSjGIe2VG2SJdJN
         HQXC2KrvgMNLtBYqSylY6vAWjpr+lY/LiyEhcWegKUWQxhM4ZXuyaNeSN8LCxkMbVRfj
         3MBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=EFvJS0ay;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=iiNPnQaF;
       spf=pass (google.com: domain of prvs=8975a33d68=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=8975a33d68=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w20si1340448pfn.93.2019.03.13.11.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 11:25:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=8975a33d68=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=EFvJS0ay;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=iiNPnQaF;
       spf=pass (google.com: domain of prvs=8975a33d68=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=8975a33d68=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2DIIdbO003908;
	Wed, 13 Mar 2019 11:25:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=aikG9yz0lcCeANUDQoaSydrOSD48pgBFE7UyJ3qbhh4=;
 b=EFvJS0ayLUliwdpHarD7XqwO3TuwLTzzJz/ooI70TeJxS3TutTyBJxBycV7/foSpndlD
 Wb/rPlX/RLtVLC5Lu4FK5SVl4rT16cErRt1S4nJDjfntgqF4VNgHYHFTmnYWt96z1n9T
 Z9J90gkIFWKzcvhkqX73ilNistfag4d3nnQ= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2r76fur7ru-17
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 13 Mar 2019 11:25:00 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 13 Mar 2019 11:23:12 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 13 Mar 2019 11:23:12 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aikG9yz0lcCeANUDQoaSydrOSD48pgBFE7UyJ3qbhh4=;
 b=iiNPnQaF3nJfclDdowMVP+eDNrMDAE1LvcFRwnLqbpRTUyFhkz471Oj7GlDWgwuqX29lsiSkAp/QOgQewecjEHG/sA6KePKPifBPiva0emzjADjgMFoif5WcDu9ybnSiU7HE8GqoXbeq/e2THx1vcq2swfrkaARMZg/+zUu9ee0=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3192.namprd15.prod.outlook.com (20.179.56.94) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.13; Wed, 13 Mar 2019 18:23:09 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%2]) with mapi id 15.20.1686.021; Wed, 13 Mar 2019
 18:23:09 +0000
From: Roman Gushchin <guro@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
CC: Roman Gushchin <guroan@gmail.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Kernel Team <Kernel-team@fb.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Tejun Heo
	<tj@kernel.org>, Rik van Riel <riel@surriel.com>,
        Michal Hocko
	<mhocko@kernel.org>
Subject: Re: [PATCH v2 5/6] mm: flush memcg percpu stats and events before
 releasing
Thread-Topic: [PATCH v2 5/6] mm: flush memcg percpu stats and events before
 releasing
Thread-Index: AQHU2SPIEdyFRN8G5UOFWOBkO8hY8aYJuWyAgAAn5QA=
Date: Wed, 13 Mar 2019 18:23:09 +0000
Message-ID: <20190313182301.GA7336@castle.DHCP.thefacebook.com>
References: <20190312223404.28665-1-guro@fb.com>
 <20190312223404.28665-6-guro@fb.com> <20190313160017.GA31891@cmpxchg.org>
In-Reply-To: <20190313160017.GA31891@cmpxchg.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR21CA0041.namprd21.prod.outlook.com
 (2603:10b6:300:129::27) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::f5e6]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 41ecc687-2bbb-4fb6-7ac9-08d6a7e0f1f0
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3192;
x-ms-traffictypediagnostic: BYAPR15MB3192:
x-microsoft-antispam-prvs: <BYAPR15MB31926B4BD8449EEA55C2E948BE4A0@BYAPR15MB3192.namprd15.prod.outlook.com>
x-forefront-prvs: 09752BC779
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(39860400002)(366004)(136003)(396003)(346002)(189003)(199004)(1076003)(6116002)(6486002)(256004)(86362001)(316002)(14444005)(6246003)(7736002)(305945005)(5660300002)(186003)(25786009)(229853002)(52116002)(4326008)(386003)(9686003)(6506007)(76176011)(6916009)(102836004)(81156014)(6436002)(71190400001)(478600001)(53936002)(8676002)(99286004)(97736004)(8936002)(446003)(46003)(14454004)(105586002)(106356001)(476003)(33656002)(11346002)(486006)(6512007)(81166006)(68736007)(2906002)(54906003)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3192;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: +7PeFCMLvN9IdE+TWAxqLlkLNg6kxDnNavxXpJVIxUHTzOs0Xph1jCxGT/12gQXDC1+CsbnQHVdfRzdPUlIIp1wWSnf08TcQpkYRw7pUOtNumlOLSUv8907C8Ron+gXL465kcvlHCOvoY3mYcdd7I1zxslykLrL5b/gNEnJEGowO+0rOX+1AUCodvyAQBHW5EEngFVMMjqHtHvi9M6SE89/GZ2zX7RgUrcLjkNOkfU7c6+5mVI9uLXedjqtPhL9tc8U8hTG5Q0dIJRcfwS317VeGzIOESE/yuVB+knyiSQGpH/rOQU6j0Fna6QWKfCRowvprBKC5Wa/G0aDooMCG4l9bI824EXq+nNdZJHNxewwgUhUEH81g+i8GId2vpvKTmK1oG381KiIq7y3Z3lr0mPPxGbfJmvH3tlLP0X7+4Rg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3F987864893FA84898C6B92CCEE1853F@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 41ecc687-2bbb-4fb6-7ac9-08d6a7e0f1f0
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Mar 2019 18:23:09.6178
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3192
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-13_11:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 12:00:17PM -0400, Johannes Weiner wrote:
> On Tue, Mar 12, 2019 at 03:34:02PM -0700, Roman Gushchin wrote:
> > Flush percpu stats and events data to corresponding before releasing
> > percpu memory.
> >=20
> > Although per-cpu stats are never exactly precise, dropping them on
> > floor regularly may lead to an accumulation of an error. So, it's
> > safer to flush them before releasing.
> >=20
> > To minimize the number of atomic updates, let's sum all stats/events
> > on all cpus locally, and then make a single update per entry.
> >=20
> > Signed-off-by: Roman Gushchin <guro@fb.com>
>=20
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>=20
> Do you mind merging 6/6 into this one? That would make it easier to
> verify that the code added in this patch and the code removed in 6/6
> are indeed functionally equivalent.
>=20

I did try, but the result is the mess of added and removed lines,
which are *almost* the same, but are slightly different (e.g. tabs).
So it's much easier to review it as two separate patches.

Thanks!

