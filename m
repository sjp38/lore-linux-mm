Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7AA7C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 17:41:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9235620717
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 17:41:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="lE83oMi2";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="oDjmaKwL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9235620717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BBE16B0266; Wed,  5 Jun 2019 13:41:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26D186B0269; Wed,  5 Jun 2019 13:41:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10DB26B026A; Wed,  5 Jun 2019 13:41:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBF3E6B0266
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 13:41:39 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g9so7840154pgd.17
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 10:41:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=sOqGn9ZwObLOVZTlPo4MIna0mpVyceumsYH4WB2YKiE=;
        b=Fbmwlxu/Q9Jx9KqQOgfhcBeLnMqwWGhbSxq+AqWn0g+tlPnHt+bcalUHvW+QPO6wca
         qWH4ckOxXVSDqHbvSb6VQWiqnYjqc+CGbGhggNBRU1ud4TzwYuwjyMLii1UwoQFdLE8t
         bogXwg1Yh1HXAQx1Uv3EjxuLi2CE/wPY01CDS2zPz8YEXO84Uj5J5naa/i8ZvgPnzhbe
         wsy4g3v026Hc48+Z6Q9HxZUh00hbLaCMaQmD40q9CivY8qeBpbgZJ3Ycz/4VBgF8OzUi
         gejEbpYbEMs+M2NYDmOuODI8QfBDv45W2CWSn/yQ+lkUSPCO6ZZtlpiTDBCY7eW3WJ78
         LcoA==
X-Gm-Message-State: APjAAAWRJ9Ju0227aoWSOK94K4+Dueo19EkBW2hcsYjbu8Mr9E3lmbZN
	gvlNRrPKcULds3J+RMOjR80Mqt68PrXq409B2mTeZWGaukN6+MgLInwZ4YdOvt024neDc+hxgdR
	aDI07Vv+YGsKfvighsj6/AmwTHaoUAcQcRrrDLRgg6ZmXTcJXxInY5OoqEg8VsghP+Q==
X-Received: by 2002:a17:90a:1902:: with SMTP id 2mr46203485pjg.113.1559756499317;
        Wed, 05 Jun 2019 10:41:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZ57vCokH6GF6/A2i6j2ItTlI23VEduauMJolgMuhUm43oerbkhSDUNT49pBReTMjPtKwz
X-Received: by 2002:a17:90a:1902:: with SMTP id 2mr46203294pjg.113.1559756497479;
        Wed, 05 Jun 2019 10:41:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559756497; cv=none;
        d=google.com; s=arc-20160816;
        b=At9xRT06vDPe29xfow3GsaARcIhS/cQGHgL0UtAzb8sGF4fqz1xqp4rZU01abhyeIM
         fNnBv+CbcvbjkFnf+aa8oJqBwnYQDL94IEnJtZiiMBlumpdoUZGYgjsI4JxuqkhQcqAs
         oEF+HZF39XxTVmmb0s5Hwq+hxDmMwfYk8XTV/JIIuwyyJk6bYIjiCPqCoIparglmiEgu
         ql+NZCM1ynOhS339MIxbvK5gcA+tf7OhPNLt90bMAi709zGxNGe3H2N6SJIjIHAt5tRE
         zU4Ewgr6fbSt8pgqIDuZmMtC3JvTKoobSNJTgB5cdrtVYVyZQpwaM+iA0lGkbor+ScIf
         z6xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=sOqGn9ZwObLOVZTlPo4MIna0mpVyceumsYH4WB2YKiE=;
        b=r3WjaUrsp6KI26bwDrU+OgkuPSlBd/kB4C+6JtTrSnpUrgK33kNWOZn7QHwv1UchwU
         7WQ1jhtwsRppb3GDHusBFJ5vyFMvQLvEh0fjmBsxPk7+i6lekyFf2+TOQNtaMrDu93Zx
         Z0JNOFHi0j5Z8AXSJKXwJQfgaMlWgQAPp6Nexi09mvRZoTiOAxix6vocNrypPOoA8iSj
         T+d5GLpwkHyX0Z6Du92A1l5Yd9wN/TXn7VFFDJbqVMkxhzJAkGCcV/MlYwMvlBoOXkQM
         kqJXIwjnEj+NxZdNjWvV5dRjYT/yFrKn8WcGC4vAZNIhB+QPaHq/37kxRCAuaQImBNHd
         Y9NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=lE83oMi2;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=oDjmaKwL;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f38si1223741plb.99.2019.06.05.10.41.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 10:41:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=lE83oMi2;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=oDjmaKwL;
       spf=pass (google.com: domain of prvs=10599ee021=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10599ee021=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x55HAlL1016018;
	Wed, 5 Jun 2019 10:14:06 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=sOqGn9ZwObLOVZTlPo4MIna0mpVyceumsYH4WB2YKiE=;
 b=lE83oMi2rHMksp/wEvsV0eR9lom6x0P2YXyOEf7JCMtKHmBZXIudrgglu4qI/OC9/wqn
 oK6+98Dt75xIIAW2dXOZOo9aMUpNrP9fveofrtkQm7zSYhB6emoDItzEJv4hsFEE2BZ5
 sVJe7cvLkdS/r9Y818GQ0FtHaHUncN/SdYQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sx6ac22ed-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Wed, 05 Jun 2019 10:14:06 -0700
Received: from ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) by
 ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 5 Jun 2019 10:14:04 -0700
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Wed, 5 Jun 2019 10:14:04 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sOqGn9ZwObLOVZTlPo4MIna0mpVyceumsYH4WB2YKiE=;
 b=oDjmaKwLKyCaD349hNxyoh82EbhHeIZJHdT5S9nHWZ8+H44TMUayT3oMMl0msgwQFbz0TNoAtwZ8xR0ugx7eJroe/qbSHNFtQmvox5EkbdLXjs0gw5l7vOxC7AQK0Y3/m3gsZ2PzILg1qd4yTM8XUDUabvNwpd9U2Zp2GThI3cA=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2742.namprd15.prod.outlook.com (20.179.157.147) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.13; Wed, 5 Jun 2019 17:14:02 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1943.018; Wed, 5 Jun 2019
 17:14:02 +0000
From: Roman Gushchin <guro@fb.com>
To: Shakeel Butt <shakeelb@google.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v6 01/10] mm: add missing smp read barrier on getting
 memcg kmem_cache pointer
Thread-Topic: [PATCH v6 01/10] mm: add missing smp read barrier on getting
 memcg kmem_cache pointer
Thread-Index: AQHVG0i1Qy6vvrJhnUaeUsu3v8l0raaMeYMAgADUCYA=
Date: Wed, 5 Jun 2019 17:14:02 +0000
Message-ID: <20190605171355.GA10098@tower.DHCP.thefacebook.com>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190605024454.1393507-2-guro@fb.com>
 <CALvZod4F4FqO27Y+msXrxT9yaDLLN7njmBsRoTkmQSPE_7=FtQ@mail.gmail.com>
In-Reply-To: <CALvZod4F4FqO27Y+msXrxT9yaDLLN7njmBsRoTkmQSPE_7=FtQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR20CA0025.namprd20.prod.outlook.com
 (2603:10b6:300:ed::11) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:a19a]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bd9203ef-8253-4d50-bfc2-08d6e9d93499
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB2742;
x-ms-traffictypediagnostic: BYAPR15MB2742:
x-microsoft-antispam-prvs: <BYAPR15MB2742B6E0600DE4332F10EDF6BE160@BYAPR15MB2742.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 00594E8DBA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(136003)(376002)(39860400002)(396003)(366004)(189003)(199004)(5660300002)(6436002)(46003)(6486002)(1076003)(71200400001)(71190400001)(4744005)(25786009)(6246003)(186003)(6116002)(66946007)(73956011)(66476007)(66556008)(64756008)(66446008)(229853002)(33656002)(53936002)(2906002)(386003)(53546011)(6506007)(86362001)(7736002)(478600001)(68736007)(305945005)(102836004)(256004)(4326008)(11346002)(446003)(81166006)(81156014)(476003)(6916009)(9686003)(6512007)(54906003)(8936002)(99286004)(316002)(8676002)(14454004)(486006)(76176011)(52116002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2742;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: FSkxo7w4HX05jKNWoswf6c67IcY8DijrULMQUWnlmZ8wuDC1HOdJw6Jvk/Uc4qztNdtthlSiXPW0GekQLSYkSNMKjBz2aavbkfLS4+Ufz6lvfGhBd/23mrkplaazveVpKMJao0Dx/9sxngwH2a6VEUcnOHG3l5/yRPEILuMbvibn/dJImz/85qBba7U08467xdXRWK/Nw+lxdGg//bM9zBtb45XXA1ui26tRHee3ajN2KD7V4iS1xsxZm5FsDqrpKuUh7l2K771OtfzlPoaTj8z8aGl0fOs7haSaIUFPy/S8kXiO4m0om/rSkBI34+7++6U10mLudcPCNnK6wqZlkPXo69MU1FJIhkH6nkM4ywY5kIy9L6Vb4nREYDkUleY+rSL8Z1sIeZ/HFCOhiUo1PtSKqMdljxZEYDS3FtQV/fg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <45474FB10F28AD468D4F949947B3B6FB@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: bd9203ef-8253-4d50-bfc2-08d6e9d93499
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Jun 2019 17:14:02.2198
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2742
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-05_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906050107
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 09:35:02PM -0700, Shakeel Butt wrote:
> On Tue, Jun 4, 2019 at 7:45 PM Roman Gushchin <guro@fb.com> wrote:
> >
> > Johannes noticed that reading the memcg kmem_cache pointer in
> > cache_from_memcg_idx() is performed using READ_ONCE() macro,
> > which doesn't implement a SMP barrier, which is required
> > by the logic.
> >
> > Add a proper smp_rmb() to be paired with smp_wmb() in
> > memcg_create_kmem_cache().
> >
> > The same applies to memcg_create_kmem_cache() itself,
> > which reads the same value without barriers and READ_ONCE().
> >
> > Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Roman Gushchin <guro@fb.com>
>=20
> Reviewed-by: Shakeel Butt <shakeelb@google.com>
>=20
> This seems like independent to the series. Shouldn't this be Cc'ed stable=
?

It is independent, but let's keep it here to avoid merge conflicts.

It has been so for a long time, and nobody complained, so I'm not sure
if we really need a stable backport. Do you have a different opinion?

Thank you!

