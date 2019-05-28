Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B43CCC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:29:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BF43208CB
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:29:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="bJeQPDz5";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="W5H/OB32"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BF43208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E21616B026C; Tue, 28 May 2019 18:29:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD20C6B0273; Tue, 28 May 2019 18:29:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C72166B0279; Tue, 28 May 2019 18:29:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id A778C6B026C
	for <linux-mm@kvack.org>; Tue, 28 May 2019 18:29:04 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id g1so130676itd.1
        for <linux-mm@kvack.org>; Tue, 28 May 2019 15:29:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=BqXrZYH8sAaIkc8wS42rAiXcrgzZJ8PEYyOJZew7260=;
        b=g6kkUNvz4PeVu3nDF0jR5LpxWlsQZxnjuWf/9GiuAIdCEBBVJAbJ3u7IeX9bUflYfT
         NxN8dUQU3MzjjTDBfqO5iOrnzAypt3wlfEi9XB2GIITP7u7f3mWlLZPXXurGdQwZ0HVL
         PiHKwqEZC4bsAL6A4PyrZu7cVD3ReIIZtDDu9h9HOQ9JAPekFeEa/dNWjUljMSta2LwL
         I0kVBcXFNEICUJCrmrPdcEWQy1eF8AnaJAq8tmAlFoqU8boiUS8D9HDj8xFuKrn/SaMV
         9TGk0WEs2q72orHules8v2EqWzKb5UWvpyv4DJt4LiCHT3Rog5yFvW6Tg3oSlVVyh43P
         HzFA==
X-Gm-Message-State: APjAAAUnhqSgCdVgLuV2B7kGnFX1mL8d7szfbV5W/+vvDuxT8Sl1y9kp
	2e18P/ltfk87oCKiLHF/GUtdBfoQsUcjEaA8lU+ffgpb1TzE06PM4h6WuCSThUCt/Ml/ptRl/62
	87onnWgDqHDMftLn1UYDtzqeP3pGP1GT215oAWagvdo+SBFIEl7Fkqol7PAMHHKcoFw==
X-Received: by 2002:a24:4350:: with SMTP id s77mr4792280itb.85.1559082544373;
        Tue, 28 May 2019 15:29:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzeZ8vDW7gM4LlqS8Qpwpx3w+9owu+Wvzo1Ky6F95UzxOXM8/YqJLBrYOpXxHdMJxOARvhO
X-Received: by 2002:a24:4350:: with SMTP id s77mr4792268itb.85.1559082543738;
        Tue, 28 May 2019 15:29:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559082543; cv=none;
        d=google.com; s=arc-20160816;
        b=nKA1KpijhSFYTVRJMQqasDxZYMHCT4BWPL4N2F/Q577F8VZMJf9MGkE7/cJGTGd+67
         3glik/H7+1A9vj6hZ3ZZnQiUG0vi32r6wDICu7SmizJEQjnTSz945sxeczv/iIrUL0zg
         p0/00+P9uovA3etYkwXV8P+mj0CwBCpvp2Knd/iASAlbHweR1/ZCDirxjla6KTQLumpR
         8v3y5YAy64yiFRRQX8oWcxIguu9PO1R9kYZvajf3EfWgXeseJR4mDCWGnvB/oex3/cQN
         /6zeeignisbHvlxeKpezzghQ4XuMLuIm8EzGGaSPt2Iiy+bjF5FA3WBN160rf7noj0rg
         i5iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=BqXrZYH8sAaIkc8wS42rAiXcrgzZJ8PEYyOJZew7260=;
        b=hJCYdM356lP7eyP++JRbEDg3LCqsKNwPNPPx+6QGIP3eo1bWfSPnFf3qcnFJYzWE1N
         IrVifMF/N8y2CC8/I8ZpKaB3wUMs5+7ioXVg5Uw3RGlZgfyfWLO4bZYISt6xUHr99/uB
         +ZF07i/15mxboWjtC6c0Dnn1JfD39iKVQthau5Z8awEwUShHeKhpa3A+sBRLIgz2MBEJ
         QGYumMVTclXw86xGF9iuWUGs/rfMQxzHTZkG35+5vKd7/tPtd9ZaVFfl5mMhPxBXC5cP
         1qO9JICZ6OWXIW0FKC/eGb1epZP/i7aQKFAYv3PkiP8/eWNIf9T8TL3AjpDRu8J4Jpe9
         qXbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bJeQPDz5;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="W5H/OB32";
       spf=pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1051accb5e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m12si4962030ion.8.2019.05.28.15.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 15:29:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bJeQPDz5;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="W5H/OB32";
       spf=pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1051accb5e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4SMKhgB027019;
	Tue, 28 May 2019 15:28:55 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=BqXrZYH8sAaIkc8wS42rAiXcrgzZJ8PEYyOJZew7260=;
 b=bJeQPDz5+RldEeWucq7npQkgDLVkDJHnjE1C7txLMO0hEbjmBTLTLhbJcMYMsyAp2nuD
 7cDoEBk6m8RMx26tbta3gIFD/ih/A0KRm8h5TFVdR+WnHs2PSPnblWKchdFXl5ZziRZ5
 BLw80p7bespEMYEQ4oXLd/64GyGYflKMo3g= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2ssac0gt7b-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Tue, 28 May 2019 15:28:55 -0700
Received: from ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) by
 ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 28 May 2019 15:28:54 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Tue, 28 May 2019 15:28:54 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=BqXrZYH8sAaIkc8wS42rAiXcrgzZJ8PEYyOJZew7260=;
 b=W5H/OB32nlYnyCx1cX+yqAc+BMQLLLnII/4CTmGvxwMg/BcQM2NqiYDfwc3dgAigFO7KHR5exNJEC7P4a72HNMkFW2i1EA6lhzxkSCnXeiH3HIwFp15LUvGesIRMMFYmTqPZo9R2ERe05ydABJxjraBtpY9CuDD1hKF5rZTEOxY=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2872.namprd15.prod.outlook.com (20.178.206.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.15; Tue, 28 May 2019 22:28:51 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1922.021; Tue, 28 May 2019
 22:28:51 +0000
From: Roman Gushchin <guro@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>, "Michal
 Hocko" <mhocko@kernel.org>,
        Rik van Riel <riel@surriel.com>, Shakeel Butt
	<shakeelb@google.com>,
        Christoph Lameter <cl@linux.com>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        "cgroups@vger.kernel.org"
	<cgroups@vger.kernel.org>,
        Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 5/7] mm: rework non-root kmem_cache lifecycle
 management
Thread-Topic: [PATCH v5 5/7] mm: rework non-root kmem_cache lifecycle
 management
Thread-Index: AQHVFaFKV+dsG3FY9UWPVf9hOznuvqaBHi0A
Date: Tue, 28 May 2019 22:28:51 +0000
Message-ID: <20190528222847.GE27847@tower.DHCP.thefacebook.com>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-6-guro@fb.com> <20190528220353.GC26614@cmpxchg.org>
In-Reply-To: <20190528220353.GC26614@cmpxchg.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BY5PR16CA0016.namprd16.prod.outlook.com
 (2603:10b6:a03:1a0::29) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:3dca]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 48e6e9a2-e879-43d9-1155-08d6e3bbdc0b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB2872;
x-ms-traffictypediagnostic: BYAPR15MB2872:
x-microsoft-antispam-prvs: <BYAPR15MB2872E3577F8B254BC37341A6BE1E0@BYAPR15MB2872.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 00514A2FE6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(136003)(376002)(346002)(39860400002)(199004)(189003)(478600001)(6512007)(9686003)(305945005)(186003)(14454004)(229853002)(7736002)(316002)(6486002)(2906002)(6116002)(8676002)(81156014)(81166006)(8936002)(86362001)(486006)(6436002)(68736007)(99286004)(446003)(11346002)(46003)(476003)(25786009)(14444005)(256004)(53936002)(76176011)(33656002)(4744005)(54906003)(102836004)(71200400001)(71190400001)(386003)(6506007)(1076003)(52116002)(6246003)(66556008)(73956011)(5660300002)(7416002)(64756008)(66446008)(66476007)(66946007)(4326008)(6916009);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2872;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: IfTB7nWGC3FiiEXQoIBT9huFAt0/xU6lma0aTS/1MgLw6JXZb6buwTZU4uWvqasPq6dpMiEFe3zNy9Abjj4/NVoPehOdiYxE8+UjNY/dW8T6sSeB2xWW4ee8NE5TeV1R5RB+ZRR3vW1DqGS+mqm2JDH7B1YiJd9Dxl/K9zqcxqnLo/yB+oxbsks+F4Hutr27+e2Jmv/DH79lNVqal/msG2NWrx5CWu/2ksUAJNAIOLrToD43wogPG8yJofvnhLP93yvJElhtqDJ9DZBzl7LJ10/wPN2ffMWWaOYZZBLhyBOFuv+Ost7hnEyUvgzCiwOkH9NWb7FE+PohMjwZesyzUxg0CtcpMcg+C1eS28sWQe1rSZ/6OW8mrSsPGdWeShWxoH76NEB9teJSPF3pgpMKWOCiK+22lKIWSJ1p9Alj8CY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <CA0D957DFE75114BB468938EE4F4C758@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 48e6e9a2-e879-43d9-1155-08d6e3bbdc0b
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 May 2019 22:28:51.2424
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2872
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-28_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=611 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905280140
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 06:03:53PM -0400, Johannes Weiner wrote:
> On Tue, May 21, 2019 at 01:07:33PM -0700, Roman Gushchin wrote:
> > +	arr =3D rcu_dereference(cachep->memcg_params.memcg_caches);
> > +
> > +	/*
> > +	 * Make sure we will access the up-to-date value. The code updating
> > +	 * memcg_caches issues a write barrier to match this (see
> > +	 * memcg_create_kmem_cache()).
> > +	 */
> > +	memcg_cachep =3D READ_ONCE(arr->entries[kmemcg_id]);
>=20
> READ_ONCE() isn't an SMP barrier, it just prevents compiler
> muckery. This needs an explicit smp_rmb() to pair with the smp_wmb()
> on the other side.

I believe rcu_dereference()/rcu_assign_pointer()/... are better replacement=
s.

>=20
> I realize you're only moving this code, but it would be good to fix
> that up while you're there.

Right. I'll try to fix it with new-ish rcu API in a separate patch
preceding this one.

Thank you for looking into the series!

