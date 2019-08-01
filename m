Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0170C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 13:39:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F8DF20838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 13:39:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="SiQKz7Ly";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="BOZy/LL8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F8DF20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76C408E0015; Thu,  1 Aug 2019 09:39:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F6D58E0001; Thu,  1 Aug 2019 09:39:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 548E38E0015; Thu,  1 Aug 2019 09:39:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 14DAC8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 09:39:48 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i27so45741949pfk.12
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 06:39:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-transfer-encoding
         :mime-version;
        bh=daTicNml4+qNGGZTCJm9uI+41O81uJc/GgzwyZfREk4=;
        b=K7TCzUrFXm0JFskxOWgliAmlhHii0FZdBv0u8yTKbZVOG2zd5gnBBe3dKsWDJ38Zjf
         BUT0OcvLQYlI2QrtRU90Et5D4MFbcygP/14gNZYpQ1ZbM8sCrIMBz6U4hDZaQT413Rap
         CAr6dApgFA083m4Yl4IoSFpZgYiNSZyQ7ZxbVASGsOo57yT7LTSEqrh57P0l977RgSGo
         E1nxFthlIMzLcxoSZOH9daLEMmp/IwoC1ww1Iqutb7cG5Z5v7GXWutiwzQlw0jXSTgZq
         /bx4T2iaW87+W0KBGqw6DWiGkK0ybqU7nMHXkNj41PdKGt9U/Va6oyNFLJN65F9erbzC
         o9jQ==
X-Gm-Message-State: APjAAAVPbAQ9JOlQ2Inumb74NnwRQyZDzGJ0pbFGiSlt3PODjSVEFZp6
	42lhP27wHfdPyVkU/b81gf+ce+1YnnuxN/ZrtY1Yq2TA74hl821RWpBOel3rK1x6r/yO81xMA70
	GPl1UJp6BIrEKw1Cn0+PG31ie6CEMv5eic6jyIf0T9IFH6sXwuFHAAlZUMGOs8bTz6Q==
X-Received: by 2002:aa7:9dc7:: with SMTP id g7mr51492417pfq.170.1564666787645;
        Thu, 01 Aug 2019 06:39:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzshRyCK4OukKlNOF5wzPLLOQDkOCQ+E5YB2X7VuJ/TpRf7C4JeORIdsUVQ/GbgH3FKVQdR
X-Received: by 2002:aa7:9dc7:: with SMTP id g7mr51492343pfq.170.1564666786664;
        Thu, 01 Aug 2019 06:39:46 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564666786; cv=pass;
        d=google.com; s=arc-20160816;
        b=nuGMDrb1pCIRM0rJRUCzJOGV6OHrtNldBs7UkdGs8QMkf6j5hCRj2Q2CGtQiErgRcH
         6Vqdch2rsvF4CQEOhc/Y4K6E6wiOq3T/1pv+LAE43obC8WByDU5FOwt2SpsvLVmO0AxV
         OsBnaPNIJrS8Rj3XaKS5Uy+M1wzArYYx5BDexCBg7RR/mlLVhBdZbuNLwBFRZOm0QdAG
         8U3WxqUa2wi0xSH1gH0ybbJeR2sKRQ8nIz7OY9q5vfJgEqyeThRbohSiHEQY4dMCYdeD
         AN7fGOK+J8QB4kAMGsL3hG4Q5hzex5cdSyYiqJih8uTSbo3sfiWptbeKn7hiWPVuukpx
         Gp1A==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=daTicNml4+qNGGZTCJm9uI+41O81uJc/GgzwyZfREk4=;
        b=q+C1o/4eTqG0wrNIRofZxdTxEYYCQqj62UaVFcl7BF1DejhpGZDa1Ap/06i3PJKzSQ
         OOguGGh2EjCQak/m4fEKWGxOGDYW+AcbNy0rJQ1WhQMTcI5dAk99dSUVO+6lZJnGwyBh
         uRhLOhSToEIWGLtHnBwL4CxLjacDgv1qyQLSkq8gfNsZk06UCAi4ydS2HDiKG8npHKdW
         WnZRQ6Lw8TaXVBTCTipG9BOePriETSmOZE1s9W/fxvfoyU8SqyPStx5vgPvRluZ9U4d0
         Yd/gWJoJJrKiRndh7kbwA9Ikvu+3LFZwm4yLfHHcvNz9ucJPmvjdneAhcyr/2fe8v4P3
         1xBQ==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=SiQKz7Ly;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b="BOZy/LL8";
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31164e87aa=clm@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31164e87aa=clm@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id j18si36363124pfe.235.2019.08.01.06.39.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 06:39:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31164e87aa=clm@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=SiQKz7Ly;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b="BOZy/LL8";
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31164e87aa=clm@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31164e87aa=clm@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x71Dc2Zd029380;
	Thu, 1 Aug 2019 06:39:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type :
 content-transfer-encoding : mime-version; s=facebook;
 bh=daTicNml4+qNGGZTCJm9uI+41O81uJc/GgzwyZfREk4=;
 b=SiQKz7LyPRQkTpSG+3jWs4z0k32IFbSFdXI6yuyUrJFQn9OoJuFrZmR4f92v+i2v6hzZ
 AkB4NLgJZYNsNyJmPi6Jl1dnl9zBZ3qvwo8FjakNJFexGrxBNALYJcL4q9mZLzcPYjqx
 LclGL3lJiDlcGGD0Jg0hQkzNz6x3/6rZ4HQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u3n9xjgkj-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 01 Aug 2019 06:39:43 -0700
Received: from ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) by
 ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 1 Aug 2019 06:39:35 -0700
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 1 Aug 2019 06:39:35 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=YPA+fWxxpT2YaKHqQH9miFAqTNA/8BkU2yBoSqjCwoLtlroNDPCdfCkXi3/U9ioeBaTy9DzqsBaA+2UYlRIbKQmUjTYlkqFSD8jYuDfhrkcRF6fI1uSKp5672kuuL11l7iNlIsGwOGCsiSZIlUSWEh5qZy7og4CgDKdHE6aWPUqUq6nSPP39LDJ/ocnenqOP/t91+lfMqRTeF2a/5jcOHmgiyp0+Q/HFv/Ani0b58bxa2k5gPjjh1/4iVgYR+Gc+qfHn9EkigxltWzrh5vQMhgWUUSR8+3WvCiK/S9CLz04tj9LFF0QgRh8PS7Rk7DqywcZ0Yj7L9lw+VW06cs/q5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=daTicNml4+qNGGZTCJm9uI+41O81uJc/GgzwyZfREk4=;
 b=L7Q414dJ1mL7rkfwFmBoSFx0VedMaTmKCvUsFCoiwxiaLfsgPG1I6hTPMMJmn/htd2Znd98CP7JsBgMjp4Svx8ceA26NxJj6Q2yY6UbdcPQ3yEdLwIs/5txaQokv8B8gcKzAhAiv3xQSnzQ17VSvBKCglpSrudtFj6Ee1UuRfwFidVcP6slPHudQihj6j6Mhg29Fy38TcftpunmporSaSZOvtUC1ctc6KxZ1mnogyFdHI82dvPo6e5ooaL4wHNiPwA2ZjNOE+BsBjQhhnfhhZaGDpMVa6BzdkjqaOFysLRfrC/nJ5VVyGRCOXEjm1bItMX/AfpjzgIhLglTc6XMQjw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=daTicNml4+qNGGZTCJm9uI+41O81uJc/GgzwyZfREk4=;
 b=BOZy/LL80Krx4XZTE6qvqxeYv+lP18mPOhli3PUXIcD+Tw8+AFlz7iQfSASKegI6j7v0ITeO0++QLF3TOQeIqqUbgGIUMQ2EJZ2YlIHi0QY9zwClsUtG1bFq9aL2M5u6Z6kV3iBEVP3DoTZuDUs2BMKBNHIQ4W5OLeMNAx5264M=
Received: from BN6PR15MB1282.namprd15.prod.outlook.com (10.172.208.142) by
 BN6PR15MB1444.namprd15.prod.outlook.com (10.172.151.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.15; Thu, 1 Aug 2019 13:39:34 +0000
Received: from BN6PR15MB1282.namprd15.prod.outlook.com
 ([fe80::c47a:8d15:afbc:debd]) by BN6PR15MB1282.namprd15.prod.outlook.com
 ([fe80::c47a:8d15:afbc:debd%10]) with mapi id 15.20.2136.010; Thu, 1 Aug 2019
 13:39:34 +0000
From: Chris Mason <clm@fb.com>
To: Dave Chinner <david@fromorbit.com>
CC: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH 09/24] xfs: don't allow log IO to be throttled
Thread-Topic: [PATCH 09/24] xfs: don't allow log IO to be throttled
Thread-Index: AQHVSA9fnWuPStnf6EeOPJMMPtRTUqbmTPoA
Date: Thu, 1 Aug 2019 13:39:34 +0000
Message-ID: <F1E7CC65-D2CB-4078-9AA3-9D172ECDE17B@fb.com>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-10-david@fromorbit.com>
In-Reply-To: <20190801021752.4986-10-david@fromorbit.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: MailMate (1.12.5r5635)
x-clientproxiedby: BN6PR03CA0055.namprd03.prod.outlook.com
 (2603:10b6:404:4c::17) To BN6PR15MB1282.namprd15.prod.outlook.com
 (2603:10b6:404:ed::14)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c091:480::bfbd]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 54982839-4942-4c64-fc02-08d71685b05e
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BN6PR15MB1444;
x-ms-traffictypediagnostic: BN6PR15MB1444:
x-microsoft-antispam-prvs: <BN6PR15MB1444A23509E44B67AB37CEA8D3DE0@BN6PR15MB1444.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 01165471DB
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(346002)(39860400002)(136003)(376002)(199004)(189003)(71200400001)(476003)(14454004)(53546011)(14444005)(36756003)(46003)(486006)(6436002)(76176011)(7736002)(6916009)(8676002)(186003)(478600001)(11346002)(8936002)(52116002)(229853002)(50226002)(81166006)(386003)(68736007)(6506007)(2906002)(102836004)(316002)(81156014)(2616005)(6486002)(446003)(33656002)(54906003)(5660300002)(305945005)(66946007)(6512007)(256004)(6116002)(64756008)(66476007)(66556008)(53936002)(6246003)(71190400001)(86362001)(99286004)(66446008)(25786009)(4326008);DIR:OUT;SFP:1102;SCL:1;SRVR:BN6PR15MB1444;H:BN6PR15MB1282.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: jCPNsrsYj2CPdrlAHs0/1GprP43MiqLSQapmRtNZddNVOaSkj4QWt2JH1IlQzpNLvixoMhBf1HU5o+VP9eefatWphr6ZmctKgJKjQVe+5cL9shBt1XjeijE9Te6GLfxpiqcGNXluTOzWrjyHEjE7UnSEKlD0SkoI0k9I7L3cRF6fiuqVgDNKekRTn8VawI+O0Mc2iTpHXIAUETBNGRkXIaMUGVBTsAWZziRHSVR5rYK77cKhiZg9VfGccPEg5o2n5xcwVrVnWTkmFhFlW/FU1ppupmfMGKhWc5a7+4keADsNTLmobaFPlNYozfGP27nfrTOJwH0bvWgcciApEBk5GB7S4v2STnTygQQRrMGP6tjvvLqGI3B60+vf1Pb1wg7AhdFSTf98gDYDiAi55M2IpEGAaOEAqJr0Q+TzqafQMyQ=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 54982839-4942-4c64-fc02-08d71685b05e
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Aug 2019 13:39:34.4309
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: clm@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR15MB1444
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=745 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010145
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 31 Jul 2019, at 22:17, Dave Chinner wrote:

> From: Dave Chinner <dchinner@redhat.com>
>
> Running metadata intensive workloads, I've been seeing the AIL
> pushing getting stuck on pinned buffers and triggering log forces.
> The log force is taking a long time to run because the log IO is
> getting throttled by wbt_wait() - the block layer writeback
> throttle. It's being throttled because there is a huge amount of
> metadata writeback going on which is filling the request queue.
>
> IOWs, we have a priority inversion problem here.
>
> Mark the log IO bios with REQ_IDLE so they don't get throttled
> by the block layer writeback throttle. When we are forcing the CIL,
> we are likely to need to to tens of log IOs, and they are issued as
> fast as they can be build and IO completed. Hence REQ_IDLE is
> appropriate - it's an indication that more IO will follow shortly.
>
> And because we also set REQ_SYNC, the writeback throttle will no
> treat log IO the same way it treats direct IO writes - it will not
> throttle them at all. Hence we solve the priority inversion problem
> caused by the writeback throttle being unable to distinguish between
> high priority log IO and background metadata writeback.
>
  [ cc Jens ]

We spent a lot of time getting rid of these inversions in io.latency=20
(and the new io.cost), where REQ_META just blows through the throttling=20
and goes into back charging instead.

It feels awkward to have one set of prio inversion workarounds for io.*=20
and another for wbt.  Jens, should we make an explicit one that doesn't=20
rely on magic side effects, or just decide that metadata is meta enough=20
to break all the rules?

-chris

