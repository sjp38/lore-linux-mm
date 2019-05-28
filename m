Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F401AC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 21:52:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8439F20B7C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 21:52:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="NNmN7x5e";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="XP/g4gO8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8439F20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D03056B028A; Tue, 28 May 2019 17:52:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB3806B028E; Tue, 28 May 2019 17:52:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2E326B028F; Tue, 28 May 2019 17:52:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90C536B028A
	for <linux-mm@kvack.org>; Tue, 28 May 2019 17:52:55 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id p19so31163itp.6
        for <linux-mm@kvack.org>; Tue, 28 May 2019 14:52:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=2csGm4rlE1Qqi8mXN7Sub2LV7EaIFkK5VMSLrb4jJfc=;
        b=h+hoO0kOkaWDL3n/o65q8+JCYArz0yMf3rqjCDRLjL05MR1QIGPlOTxyCd2QrX/qsG
         FQUft8lOtRoqZ9y8hWYMD9OsEVq6lkXGfd6JiA9L9ZtomoXvjH3/YM90kubHkF+2I43e
         SD/ahmq4LO7vADK/L25P/hoAHmGyyyo0ZvELDuhdL15pXDVYG7A85o8GEFGXTTdxVKO1
         f/l26tIf0PlTuvjHeje7UZhw1ujBN0ZZk2akPWcb2Q3iMu6sVNNM+VL1Sry20Iet3DNF
         2O0OlBEIxZ6qIH/Ha7iiEtFiPWyoWKp8nNzto/W77pRHEuDV3gBGPkGEesPugGcB9BNU
         5Buw==
X-Gm-Message-State: APjAAAVfGWdv1QyGOPMqMkrHleNJLZuxOLgjCiMs5sCHkFQLDw6TJT13
	XKcV/AHRR/Wp6WjECDo2X1adIV+LySsGHyxt71W1jk5Ls1pOGYub634wVxp0JyAMW0uAR2rYC5X
	P5XdVPe9uGMJKcez2LmySObBMDIKiSPlNYU0ugkduG/s82di2iP9xK6lrpk0tymCSpw==
X-Received: by 2002:a5d:8ccc:: with SMTP id k12mr12772996iot.141.1559080375345;
        Tue, 28 May 2019 14:52:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUkz/GYiCe+zkFxzxyf7BO0RFiNuMh+TnDQcLe0ctl9Ssxiz/4IwLjZx/yWGMX4z+U9snt
X-Received: by 2002:a5d:8ccc:: with SMTP id k12mr12772960iot.141.1559080374531;
        Tue, 28 May 2019 14:52:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559080374; cv=none;
        d=google.com; s=arc-20160816;
        b=zvR6eQgnGstlWToJx7J2f+eC3fa0HwFPK6Jyfr8P8EP0OnYTsPu7rk30LpryB6/OEN
         fAosGz94cw+thxzGROJDNSUituz+bkVaNOSkk8uHXu5V2GbOGiR1oqSEfbM/B2Ok8PO9
         IYqdBGXah2alNQ5oorv2ifLST8UN1L3D2pNPeZnizEtXjwGkhQ9tAnLRJHH0+3XAMW3G
         L8zBzK1W5sEohcf3Ls4ayYRhSAuZci5/qFzsGxER3ehM5NvkwJUDhi7y8Cv50WX1s/u2
         PuCoxPFNSG1hnsry4l0RYF6bjoR5MiUaKybvqTWYd2TLAa7DItMItKK7L+HznJRiL85E
         p+EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=2csGm4rlE1Qqi8mXN7Sub2LV7EaIFkK5VMSLrb4jJfc=;
        b=WVqfMsrayKm+KUiJg8JU6JfWjP0XLhbDu1KN6/p1Rv0w2UGXzVO/bol89uibI57spn
         dG8uhiSLxIyVadqbsWME/elcUQBCBhL+9b6sOE899myqWNIwzHNCX8SE7uHyRoAxFWnw
         /F7oNqbYWPnHI11jglLVPnENnTNIG/dLxF32ZaEafMg3bPXNuggEh1sn+jsV19U8eYIi
         nHRXvE0TuEh4nz6QUbqLp/crHkOjqcRcYdj7+9u6fs7C4cQgKRHXtqd+2ooJybN9Ia64
         o6I3g/FZBBerikWlKOiNAesRize6oFcvNBg7WnTqa2+3c0BvpnUgWoqVu27CxdlXS3ZX
         YXNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=NNmN7x5e;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="XP/g4gO8";
       spf=pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1051accb5e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t24si11116062jam.68.2019.05.28.14.52.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 14:52:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=NNmN7x5e;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="XP/g4gO8";
       spf=pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1051accb5e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4SLmQJs030310;
	Tue, 28 May 2019 14:52:46 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=2csGm4rlE1Qqi8mXN7Sub2LV7EaIFkK5VMSLrb4jJfc=;
 b=NNmN7x5ePH9+/3PEx9NOhAzPIONn2jMLy72MnqV3NMqQG2JCOFXP+LrtkJuaIZ06nOYA
 fiYdtDRgkV9lpDBsV786Vg6CF1k56vbOKfst9gVSUnhU5+4RDLyKzxLOPQSc1Rb7gMV3
 Ot9qtYNwLfSfsg4DcWfmaPS+3hIPzkZ3PmQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ssac0gprg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 28 May 2019 14:52:46 -0700
Received: from prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 28 May 2019 14:52:45 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 28 May 2019 14:52:45 -0700
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 28 May 2019 14:52:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2csGm4rlE1Qqi8mXN7Sub2LV7EaIFkK5VMSLrb4jJfc=;
 b=XP/g4gO8xI9CM1osd4/iJcff8D0lgbK1r468C0Ks1SQjacsbtWvenwrKEUMS9XuftI4d1DGlZa2NVcxnu9R+E0tVMEe6WsFZpUgsHKB+9A+INQFYRI3mCUzpD2GmA04kWPF8TmILV6JbJLarRrhMzhaF4K9Hr6iql8avcUa8Kzc=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2984.namprd15.prod.outlook.com (20.178.237.209) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1943.16; Tue, 28 May 2019 21:52:42 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1922.021; Tue, 28 May 2019
 21:52:42 +0000
From: Roman Gushchin <guro@fb.com>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        "Johannes
 Weiner" <hannes@cmpxchg.org>,
        Michal Hocko <mhocko@kernel.org>, Rik van Riel
	<riel@surriel.com>,
        Shakeel Butt <shakeelb@google.com>, Christoph Lameter
	<cl@linux.com>,
        "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
        "Waiman
 Long" <longman@redhat.com>
Subject: Re: [PATCH v5 6/7] mm: reparent slab memory on cgroup removal
Thread-Topic: [PATCH v5 6/7] mm: reparent slab memory on cgroup removal
Thread-Index: AQHVEBPW5GLT+zCswEKkIpLsH/n20qaA52gA//+icQCAAHjxAIAAHGSA
Date: Tue, 28 May 2019 21:52:42 +0000
Message-ID: <20190528215238.GD27847@tower.DHCP.thefacebook.com>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-7-guro@fb.com>
 <20190528183302.zv75bsxxblc6v4dt@esperanza>
 <20190528195808.GA27847@tower.DHCP.thefacebook.com>
 <20190528201102.63t6rtsrpq7yac44@esperanza>
In-Reply-To: <20190528201102.63t6rtsrpq7yac44@esperanza>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR04CA0044.namprd04.prod.outlook.com
 (2603:10b6:300:ee::30) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:3dca]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d6202f04-bd74-4df8-b3df-08d6e3b6cf92
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB2984;
x-ms-traffictypediagnostic: BYAPR15MB2984:
x-microsoft-antispam-prvs: <BYAPR15MB2984262F4AA2CD7361FC87C2BE1E0@BYAPR15MB2984.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 00514A2FE6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(376002)(366004)(39860400002)(346002)(396003)(51444003)(199004)(189003)(4326008)(478600001)(256004)(5660300002)(6486002)(81166006)(102836004)(71190400001)(8676002)(14454004)(33656002)(6436002)(1076003)(71200400001)(99286004)(53936002)(4744005)(7416002)(54906003)(8936002)(73956011)(305945005)(186003)(7736002)(52116002)(86362001)(81156014)(316002)(46003)(11346002)(446003)(6246003)(6506007)(386003)(476003)(486006)(6916009)(25786009)(9686003)(6512007)(66446008)(76176011)(64756008)(68736007)(66946007)(66476007)(66556008)(229853002)(6116002)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2984;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: gGHMnNEuXWxVn/RzxruLLfC4cx9UiOwNWZ0wD86SDoXjAdFFPqECBgz36oDqq0Tp0g448PYfaykzkP69pK/l0gXNDu1UyunBfNP2JbTfPo6A/sF9GeLq6Wv+EsTAv7DwRaFzJo/a53ltUe0HOvdmuf4FN9ukgOo034aC5hy087Nxg4xlJFOllAPusM12sk394fjgog3lizuzCgLsT3BoyFUvWR38mLhK1aeqBeqV5qLsFDlhpzpx18sYIPRZ3k7U7SxdREQX1keB5/HigNJJdOggTs1GXvGuHBFmI7zpVyvOB81mucuDjbPda4ROtw2vqGo0sEFv4f+5Ku0yfgQbJ6Lx/54NRtHHf0IiStu4Cu4jLLAcSXlka5QBeeKumgbEd9+9jgDMa9T0bW7BsG56hqya7oJMWBjLMPIYvUCitvc=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <79BD7F195AE57C48A44E1FC6FE044ED0@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: d6202f04-bd74-4df8-b3df-08d6e3b6cf92
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 May 2019 21:52:42.8043
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2984
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-28_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905280136
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 11:11:02PM +0300, Vladimir Davydov wrote:
> On Tue, May 28, 2019 at 07:58:17PM +0000, Roman Gushchin wrote:
> > It looks like outstanding questions are:
> > 1) synchronization around the dying flag
> > 2) removing CONFIG_SLOB in 2/7
> > 3) early sysfs_slab_remove()
> > 4) mem_cgroup_from_kmem in 7/7
> >=20
> > Please, let me know if I missed anything.
>=20
> Also, I think that it might be possible to get rid of RCU call in kmem
> cache destructor, because the cgroup subsystem already handles it and
> we could probably piggyback - see my comment to 5/7. Not sure if it's
> really necessary, since we already have RCU in SLUB, but worth looking
> into, I guess, as it might simplify the code a bit.

Added to the list. Thank you!

