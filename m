Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A31DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:43:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB1F72184A
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:43:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="PdTYtuKz";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="DlU9Iw75"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB1F72184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72F818E000B; Thu, 28 Feb 2019 11:43:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70F768E0001; Thu, 28 Feb 2019 11:43:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F5048E000B; Thu, 28 Feb 2019 11:43:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38C808E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:43:30 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id v12so8797540itv.9
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 08:43:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=J3TkBkbgJLidYXQwndc5Y9K0JpBhnEgIwXZ3Hj0Jilw=;
        b=XJCWQYaoScmgtAWdnFfQ4HN/TTihXJ8HHrkxcZ7iHowRO2RZkEnYAdz9lMNv43pCX1
         Ks0KpBt8XjTL8PJ8bEdPgc48JUPZbpAts78POGe8ov+iUDENSIPzTDCS/348FAPr5xHG
         QS0+y4Y7fgd7AQ0vlUGl9zIjcsJFyvWp3P24b14+hH3P5JD1O+vS9qHuaauBEcUlA3EK
         ekpl6S3UAtvj0hgdEGupcx/GFdM/KTnjZSYVRI4s4kXq1b4dRnMydMRMRk0izpjErSoC
         TP8cM3ElSxkuVJL/vtYqqT/81dyCKyj6dhxqX5BAWvVESOlChiNv+g2pFM5jJnYWTFQ7
         6DQg==
X-Gm-Message-State: APjAAAV7xBW6Nn4U3XSKH6Lcf1db5mAYbb3bY+p78DZbiy9gbxfv3srC
	tvlQzcJj64+9PJXtEiB/np7T/U/JCevqrPuSylRxDHDzm9sgd0kom3EH2vFbtJvb+9opyrriqHk
	MN8qQBUMfyC1klXOPte5p93eHtoCATk0aGb+nqMtY7PHM1NG1YftTLAz5ezQWC3md6w==
X-Received: by 2002:a24:dd1:: with SMTP id 200mr430986itx.65.1551372209923;
        Thu, 28 Feb 2019 08:43:29 -0800 (PST)
X-Google-Smtp-Source: APXvYqzsT3Funxd0sOBSwy4AOT5nbEQTRpqaauAalEjB+urvjPWYZYZPh4uRnHbKr7+ubdZu1+M6
X-Received: by 2002:a24:dd1:: with SMTP id 200mr430951itx.65.1551372209169;
        Thu, 28 Feb 2019 08:43:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551372209; cv=none;
        d=google.com; s=arc-20160816;
        b=Pp06HcW0WEjjbwEvt96Vg26uhI2Jjvcqaihn6j6JKskutgDNz7kr9EIPVWWrfxdxPR
         Q+wW/ncYt5IL/vAPLSQ2rzlfpxQSpkRpn486t6MnrJInxLoCQzi04GudHkeOvLVykcMy
         QLDGiW4r4pq4sHHiuKHTG99M+RPjJLKFH68bWb+ChAfN0beo4QfpfI14DuMs4TfmIOci
         d1E1koJ3EgJ2Dopuo4N10zxNTTLpymZuHPVhXsymd2p3GCN22lVLosSNdHjLpGjHfIeQ
         kSKTxwvjfCE4ZwwPK4ccpGAgWI0cOnfKfrjs4ycu6KrjsT9yUwyZGZeaH5/8kLeq2nJa
         OV7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=J3TkBkbgJLidYXQwndc5Y9K0JpBhnEgIwXZ3Hj0Jilw=;
        b=P+7jvOI8RiXVu4qXJyqeONHF3oHIsfbG+ZjiSBZEp83E5RVXfwkZX3NLIXh/BjTPo5
         jLM+fDDSTkHLSuaQwt0m5hafIFx5v6ktRFXXQiiTBuiWEAmgighlwNID2TAHFE7LEFhZ
         UmNHN2BbpRPKK7Svc0z4Tlw2qL/hTrA6qVFQSiaJCAbEVNi7IfEebdb/VGkvnTF84ISH
         crw/YaXAYk3xJxXIbvDA/nz7WwoJehjBu/ZP19X8ktFiDZXEBGMnOQ9rBqfJ9iDTRmv6
         gLLzjILUeVRIe7AqPloDbnLnHYNV7OKBEHKJXU7CdS3cLZOsBpCfshM3dRdn+kLz/lmI
         /MMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PdTYtuKz;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=DlU9Iw75;
       spf=pass (google.com: domain of prvs=896249f319=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=896249f319=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l192si3285070itc.102.2019.02.28.08.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 08:43:29 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=896249f319=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PdTYtuKz;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=DlU9Iw75;
       spf=pass (google.com: domain of prvs=896249f319=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=896249f319=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1SGTPLR012708;
	Thu, 28 Feb 2019 08:43:26 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=J3TkBkbgJLidYXQwndc5Y9K0JpBhnEgIwXZ3Hj0Jilw=;
 b=PdTYtuKzCtdu7/AkoHQwy8yoDgjX1G/aw3pkyoiTqNFyEWF+/zR6DaMpw8OUFJSrjwnC
 LNKwDRfDZHucZiqMsJDhYbp1wZHCU1eVmFwh3MhJclXcmAor1cud5lW4HGPiwfS0sAyn
 4Tx/s2xkUHRXkbngn+PUUnwuydZo4Ux+y00= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qxjqt869r-10
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 28 Feb 2019 08:43:25 -0800
Received: from frc-hub03.TheFacebook.com (2620:10d:c021:18::173) by
 frc-hub02.TheFacebook.com (2620:10d:c021:18::172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Thu, 28 Feb 2019 08:42:43 -0800
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.73) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Thu, 28 Feb 2019 08:42:43 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=J3TkBkbgJLidYXQwndc5Y9K0JpBhnEgIwXZ3Hj0Jilw=;
 b=DlU9Iw75/ITd5HVG3W+TNbiB0rOudfHNMirVPZkbVWrNczFMHfCvYMQOumu9bVKPc85t+CnEOcuapGCVsN7y+hiTOJtvXKlUNwauA3z3ywqEGHMud5FmO1CdaBPZG+lVkvysPwjFR8A2C2r/ig9UmRgRUyuPKj2vyaZX8s3PnTU=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2613.namprd15.prod.outlook.com (20.179.155.218) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.16; Thu, 28 Feb 2019 16:42:41 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1665.015; Thu, 28 Feb 2019
 16:42:41 +0000
From: Roman Gushchin <guro@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
CC: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "cgroups@vger.kernel.org"
	<cgroups@vger.kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH 0/6] mm: memcontrol: clean up the LRU counts tracking
Thread-Topic: [PATCH 0/6] mm: memcontrol: clean up the LRU counts tracking
Thread-Index: AQHUz4L9n1k+P/DTd06CcNJjAIxXeaX1ajQA
Date: Thu, 28 Feb 2019 16:42:41 +0000
Message-ID: <20190228164236.GA26032@tower.DHCP.thefacebook.com>
References: <20190228163020.24100-1-hannes@cmpxchg.org>
In-Reply-To: <20190228163020.24100-1-hannes@cmpxchg.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR01CA0020.prod.exchangelabs.com (2603:10b6:a02:80::33)
 To BYAPR15MB2631.namprd15.prod.outlook.com (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:d847]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ca868cf1-04d0-4662-6835-08d69d9bc189
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2613;
x-ms-traffictypediagnostic: BYAPR15MB2613:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2613;20:CdH1bil/aSwZNUcLnnmHBIMrTZMVhFjvsRJOenhOSIThgn6Qi340uxG5duQk0dVXjq7DairCWLiQnmE06ho6DuprQgHSR6Mg9DYocYuT8kwpRbbCyFbhOFSlHu+tG2r/8aycZX1TMsxzuJNHDU4gv07uVlW+tgskuy2Xno4KUpE=
x-microsoft-antispam-prvs: <BYAPR15MB26137AC1C9C32EEB2C0E92B1BE750@BYAPR15MB2613.namprd15.prod.outlook.com>
x-forefront-prvs: 0962D394D2
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(396003)(376002)(346002)(366004)(136003)(199004)(189003)(54906003)(81166006)(81156014)(6246003)(25786009)(71200400001)(71190400001)(8676002)(68736007)(8936002)(4326008)(7736002)(6916009)(305945005)(478600001)(97736004)(316002)(2906002)(6512007)(9686003)(256004)(86362001)(14454004)(46003)(1076003)(33656002)(229853002)(6486002)(52116002)(106356001)(53936002)(446003)(105586002)(11346002)(6436002)(76176011)(102836004)(6116002)(5660300002)(6506007)(486006)(99286004)(186003)(476003)(386003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2613;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: JEeQyWXCJK2lSNNhTR5JCD9AwZv/MglfP9Hxw1zi5G7NNrSaLsEXsTUAAGF1kfDRspiPJdeGsJasnUXNFZCHVufNsM1/CPoyHMoUY3yEN2m6jIZT4e++apvZXsnJEfloEmuGkUsJOpRhSr66ewbXeqLES5kL6Qj5AeHNbLMDlvhd5FKMhvm2vY6ylZvcP2dCslq4xEaXBxhgz5kSSm2UhIogMwJj+503l++ByYbo45e5ovOQ+y4KeCgugRHBsF7hhxfeOV6o/cN+EdxuwXX5G/UD5keGnWvIed5OIVexlBm/bUO0Tn8OnR/I1Lum8nlq1Dju6ST8KiFeir8E2E5sIE8+ulj4Y4ro9iRMM4CoPPvuF8fzCIEP8g2VQTodNh9Tqv89GmRMn4ceNVesfnX6C8/il+Iwv2F7Do2yZyBLit0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <FF49BB458586CF448F1935237336EB36@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: ca868cf1-04d0-4662-6835-08d69d9bc189
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Feb 2019 16:42:41.4955
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2613
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-28_08:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 11:30:14AM -0500, Johannes Weiner wrote:
> [ Resend #2: Sorry about the spam, I mixed up the header fields in
>   git-send-email and I don't know who did and didn't receive the
>   garbled previous attempt.
>=20
>   Resend #1: Rebased on top of the latest mmots. ]
>=20
> The memcg LRU stats usage is currently a bit messy. Memcg has private
> per-zone counters because reclaim needs zone granularity sometimes,
> but we also have plenty of users that need to awkwardly sum them up to
> node or memcg granularity. Meanwhile the canonical per-memcg vmstats
> do not track the LRU counts (NR_INACTIVE_ANON etc.) as you'd expect.
>=20
> This series enables LRU count tracking in the per-memcg vmstats array
> such that lruvec_page_state() and memcg_page_state() work on the enum
> node_stat_item items for the LRU counters. Then it converts all the
> callers that don't specifically need per-zone numbers over to that.
>=20
>  include/linux/memcontrol.h | 28 ---------------
>  include/linux/mm_inline.h  |  2 +-
>  include/linux/mmzone.h     |  5 ---
>  mm/memcontrol.c            | 85 +++++++++++++++++++++++++---------------=
----
>  mm/vmscan.c                |  2 +-
>  mm/workingset.c            |  5 +--
>  6 files changed, 54 insertions(+), 73 deletions(-)
>=20
>=20


The patchset looks very good to me!

Reviewed-by: Roman Gushchin <guro@fb.com>

Thanks!

