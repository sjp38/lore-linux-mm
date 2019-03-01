Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F5AAC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 00:03:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B992F2085A
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 00:03:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Pd7l+hcv";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="kZ3gpSiL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B992F2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59A568E0003; Thu, 28 Feb 2019 19:03:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 520FC8E0001; Thu, 28 Feb 2019 19:03:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C2808E0003; Thu, 28 Feb 2019 19:03:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1DA8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 19:03:26 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id z22so16941780iog.5
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 16:03:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=MCWn9st21+H4Wm1qn+nfXI52WnHcROTMb4DEd5uE1Ow=;
        b=NzH0RjfthIIBWv+McxbpltuPa1oD/3Nl/RdhFW6/B5X422Mxdh/IaD1M/a8MVaT7tx
         iCb/Q0eMF/QNB1oSlgCPdoH9Km0WzfN2hjOn5LGFzpPz2GMFDD8P+1zXS0fqHrAdGF/b
         7WvGwYDK2bZj6+XZ033S9FQ4JW/dnC4BP8ABnbkQuCk6b1F1uRWQyp7pu3lCO6ecqnWK
         73jxXoTMFC0beGh4HQTdy8g5m2RtJxyULHLuDR+MG7aZidHzcF+Q4RCl2uXbyeHcaDEW
         ap/rSNAPId5UQso6H/sfAAJpADUbzHi1RPj5ZJDvVyTV80d3uKr3vNe0nZvM37zrth9V
         fJzQ==
X-Gm-Message-State: APjAAAXZQJIXMQlkvNs9eoZOfEG3egCdql87hkLUUrKdexT6iBdqGzaC
	7LzFpCr3FCYyKKkix+EuXpuPJZmDsWC1kkjM/rvh1E9EO5VLLSgafjJB5BWAy0fIDmfuSa++/vU
	KKB8DOemUi6Jg/+C5ZTMOxfK0W+0i1ysg3IWIFxOkcw+JUXk4cJ3uSHy6lojCs91jRg==
X-Received: by 2002:a24:7294:: with SMTP id x142mr1555502itc.26.1551398605792;
        Thu, 28 Feb 2019 16:03:25 -0800 (PST)
X-Google-Smtp-Source: APXvYqxxSZIxidjB8lsmK4NPCdTaFWP8N44tn062d80F7MYNuPJmXjcD1hj/z2+CGljuLigoG2Fp
X-Received: by 2002:a24:7294:: with SMTP id x142mr1555468itc.26.1551398605016;
        Thu, 28 Feb 2019 16:03:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551398605; cv=none;
        d=google.com; s=arc-20160816;
        b=qsYlrp6569/aT0USO2j8c3xKpxCfihbpI4JK8QUP7RZp27gmTKrZFD68ZsJucItYcy
         B+MB2GPKNp6g5XTCkQtyQruLjrke5Geyc6K29IkGNkOCHhTqCkz8DTDhufpxy/YzoLh5
         WSJM5ybIc61R4YxSXNghTXPe86Kn7imzCm1qby5/gc5XZIWMlgMtMWW1ac8nT7Km5iqt
         Q1ImtbclwVwwBntg7QSNavtLzULsi9qsHIBlojXBCVx9ykaTL8u0wt1yt9AsmPG9Vu0F
         WQrtmRyNRHUa801Zm+0d9G4SJ1VxKyj4ck4Di3zfTzdBPrqyuJpmOsU/Wc5F4i5FSLAv
         YyIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=MCWn9st21+H4Wm1qn+nfXI52WnHcROTMb4DEd5uE1Ow=;
        b=DeawfgNJsujXgZrOJG6vCj2xqi1CKZoj53anekCtpRtcFh32bojm5orZkiKV2LP3DX
         AwzSXMRLM3LgnqUH77hfksAnrx3FZs22bSmB7+0FhwwCy5f+/YIQzqkZFT4TDjbUdeRu
         hPvk3ziLAf1xV8PEh82Up4yPW1BDw9ppwrFTwSrFkZY0tDmP9jYm+IlT4pvQ6KYaX2Sd
         BOERR5q6pyqoMElfJT2T7qMQQf5u5LYRrEc12N5iNBJ1K9bKdRzh9v2stcTzIknPLi9L
         hEd4ZGwRPO8cAVb7FH9hibO61L5wsxKguY8FSTaKtkKmQZBQWrWruFHFkfi6Ivyza4Oz
         hUdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Pd7l+hcv;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=kZ3gpSiL;
       spf=pass (google.com: domain of prvs=8963d4cd73=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=8963d4cd73=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q63si3779666itg.91.2019.02.28.16.03.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 16:03:24 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=8963d4cd73=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Pd7l+hcv;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=kZ3gpSiL;
       spf=pass (google.com: domain of prvs=8963d4cd73=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=8963d4cd73=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2100uVe024756;
	Thu, 28 Feb 2019 16:03:20 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=MCWn9st21+H4Wm1qn+nfXI52WnHcROTMb4DEd5uE1Ow=;
 b=Pd7l+hcvu2pm0F9fBCNVMkhl1hxam/Cs9QBsW8cKvJ3mZSWaVxwLEEsg3EnyiAR6hKHk
 3vNEGlZ8lJbiyREU66gVfKGCTBjOjkMxbIat6PQutflwzaioYbJiXaljfUYOezuSlyRL
 gu0lCpjRIC4shPIFzX8XzZFDYS6vPlzrqZA= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qxqw2gd66-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 28 Feb 2019 16:03:20 -0800
Received: from frc-mbx07.TheFacebook.com (2620:10d:c0a1:f82::31) by
 frc-hub04.TheFacebook.com (2620:10d:c021:18::174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Thu, 28 Feb 2019 16:03:19 -0800
Received: from frc-hub01.TheFacebook.com (2620:10d:c021:18::171) by
 frc-mbx07.TheFacebook.com (2620:10d:c0a1:f82::31) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 28 Feb 2019 16:03:19 -0800
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.71) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 28 Feb 2019 16:03:19 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=MCWn9st21+H4Wm1qn+nfXI52WnHcROTMb4DEd5uE1Ow=;
 b=kZ3gpSiLDm9x0L8/nEJpVIbWp9hyiXQDFOaEzLLX7ADEcn9+NSDlHA42+rd5PtizayxlFrVV62okNalc+oJ5kd+uV/jxorIs4aV05XHk4hESgKqpDiIW5BhRCa3wSgPGzumPZef8qdstcVjgCUzIgtupMqWH/2AD70KBed/b6QY=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2584.namprd15.prod.outlook.com (20.179.155.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.15; Fri, 1 Mar 2019 00:03:06 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1665.015; Fri, 1 Mar 2019
 00:03:06 +0000
From: Roman Gushchin <guro@fb.com>
To: Chris Down <chris@chrisdown.name>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Johannes Weiner
	<hannes@cmpxchg.org>,
        Michal Hocko <mhocko@kernel.org>, Tejun Heo
	<tj@kernel.org>,
        Dennis Zhou <dennis@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH] mm, memcg: Make scan aggression always exclude protection
Thread-Topic: [PATCH] mm, memcg: Make scan aggression always exclude
 protection
Thread-Index: AQHUz6zyEvTIEZLQgk63CbTpyClKSKX15O2A
Date: Fri, 1 Mar 2019 00:03:06 +0000
Message-ID: <20190301000300.GA16802@tower.DHCP.thefacebook.com>
References: <20190228213050.GA28211@chrisdown.name>
In-Reply-To: <20190228213050.GA28211@chrisdown.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR11CA0075.namprd11.prod.outlook.com
 (2603:10b6:a03:f4::16) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:4bc]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7a37ad00-d6bd-4685-d02e-08d69dd947c5
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2584;
x-ms-traffictypediagnostic: BYAPR15MB2584:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2584;20:IFnFIIf9f5wxDWg0OsCRLkWF68pzxwDpe3F1r+rgwX82wAZqyZEr27VXPEt27bMA/j7GrTa2f8m+HHoaLb9+c+j/T0nZO/Z4O/lLWUgzs14fMmueJbvXCB0eN2GO5s/TzuvvzI10WhMm2YSB8AHti2gkDmSdczEODmvyjcvUQ7c=
x-microsoft-antispam-prvs: <BYAPR15MB2584EC94B7D72E584DA5B28BBE760@BYAPR15MB2584.namprd15.prod.outlook.com>
x-forefront-prvs: 09634B1196
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(346002)(396003)(366004)(376002)(136003)(189003)(199004)(4326008)(2906002)(86362001)(229853002)(25786009)(6116002)(33656002)(6436002)(71190400001)(71200400001)(6916009)(6246003)(6512007)(9686003)(8936002)(53936002)(386003)(99286004)(97736004)(52116002)(14454004)(81156014)(7736002)(102836004)(6506007)(446003)(81166006)(11346002)(1076003)(76176011)(486006)(8676002)(105586002)(54906003)(186003)(46003)(6486002)(5660300002)(256004)(316002)(106356001)(68736007)(305945005)(476003)(478600001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2584;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: irCdxR1ppChLlsoV1Mu+PgBjGMEklxkE5727cz8fZJRSSebd9HywFySieTi4N9PDrpyhamSARGsGc7613hmdDoPvMN8fuv6MrfMjW/zvaSgxIn1tnmBYcTN7XkvkFvs3W+p8xwW8KwdFNlUPypopBhhMcb71ylJwA3l8HsMQBaNE4Bg0B41uN/lryIRqEpK8fMg5BnP6zala9hn0xnzxnQtJn80s+6ZxuPNzUBwj28K7kOpiZfdOq7I4uv/d0ipHUEvi4YYONWOTQ3uvhGaHUCbpGllKkDZvWJzWmuQHQNIeEiYao2GPp8fUwSs2LsqS41KZ6H2zAapcQXkY4w414K+lNyLX0JSvPQ4HgL4W1Gekz0u9sMa6YDe6dtTZbW9LMGSaI+EgUwEfA9n0iBv7aVJiIWAKC4pWW4MWCkfqpkA=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E321688B1AD6AA47BB869EFB072F8E3F@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 7a37ad00-d6bd-4685-d02e-08d69dd947c5
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Mar 2019 00:03:06.0476
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2584
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-28_15:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 09:30:50PM +0000, Chris Down wrote:
> This patch is an incremental improvement on the existing
> memory.{low,min} relative reclaim work to base its scan pressure
> calculations on how much protection is available compared to the current
> usage, rather than how much the current usage is over some protection
> threshold.
>=20
> Previously the way that memory.low protection works is that if you are
> 50% over a certain baseline, you get 50% of your normal scan pressure.
> This is certainly better than the previous cliff-edge behaviour, but it
> can be improved even further by always considering memory under the
> currently enforced protection threshold to be out of bounds. This means
> that we can set relatively low memory.low thresholds for variable or
> bursty workloads while still getting a reasonable level of protection,
> whereas with the previous version we may still trivially hit the 100%
> clamp. The previous 100% clamp is also somewhat arbitrary, whereas this
> one is more concretely based on the currently enforced protection
> threshold, which is likely easier to reason about.
>=20
> There is also a subtle issue with the way that proportional reclaim
> worked previously -- it promotes having no memory.low, since it makes
> pressure higher during low reclaim. This happens because we base our
> scan pressure modulation on how far memory.current is between memory.min
> and memory.low, but if memory.low is unset, we only use the overage
> method. In most cromulent configurations, this then means that we end up
> with *more* pressure than with no memory.low at all when we're in low
> reclaim, which is not really very usable or expected.
>=20
> With this patch, memory.low and memory.min affect reclaim pressure in a
> more understandable and composable way. For example, from a user
> standpoint, "protected" memory now remains untouchable from a reclaim
> aggression standpoint, and users can also have more confidence that
> bursty workloads will still receive some amount of guaranteed
> protection.

Looks good to me: the overall logic is fine, and codewise it's so much
cleaner than the previous version.

Reviewed-by: Roman Gushchin <guro@fb.com>

Thanks, Chris!

