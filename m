Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BB5AC43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 21:19:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB8852085A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 21:19:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="bmLfM3qw";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="UZgNhZP6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB8852085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AD3F6B0006; Wed, 19 Jun 2019 17:19:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45E468E0002; Wed, 19 Jun 2019 17:19:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FF9D8E0001; Wed, 19 Jun 2019 17:19:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB9AA6B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 17:19:22 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 14so259117pgo.14
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 14:19:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=3NY+crrjnx+TvV8HMgMwqtScaTHrRa6ZFF6/ZoDx/bI=;
        b=Oi41mfH0WQH+gN1DKxwro4b6TXImqx1hjIkAqnEgwa5K/Wwr0FxRzj/7aqmsJs4XpR
         qhfWnRaRaFPrYkdcTQJVbfsUhiDI8b3A1fuSs1UFdjopz2lGXEt2PaXTk3rQHdL0ryZf
         DWHWV3SS++D9gr3rV8YYZ0PZ/aZW2P01oi2qic+N1BzOoa/rOxeY3FhFODY+ejggjCJ8
         EpkZQCPwdRHhwInHpYqbj53MiQgsYcmG32P2kA6N/E63eRqIMp2k6ZXlh6O+E5P/IDp1
         f3TvzqFjWWGFh7M2gkxPYiCu0lragU3lSIi5X6RP4KzvHacTaLsCJ9C/RWBe5ACaMrON
         +yMA==
X-Gm-Message-State: APjAAAUjSxIti9AQI/GFcadovntjL0OX/YIicKaS0l9fYtIS+0w0Etvt
	lz1e6a86qmu3OusQhft5F150ROOLAev28DxNckXD1/yHqm9rnN0lqq9njrAycWOvli+EAGdE5gP
	g/O0t5yvxx6sZEIwKaC5v3hofl1aMW31e8nsWrvHQIuxAmnZYJUpBx3sepZzbvO8nhA==
X-Received: by 2002:a65:6102:: with SMTP id z2mr9305057pgu.194.1560979162332;
        Wed, 19 Jun 2019 14:19:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySgpKL2wtLIh6kNOfIjedFnwyd2C6B7iIUUjDheeVJFdtABNiQDWW67bUibCuIXuQ1ta8Z
X-Received: by 2002:a65:6102:: with SMTP id z2mr9304994pgu.194.1560979161489;
        Wed, 19 Jun 2019 14:19:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560979161; cv=none;
        d=google.com; s=arc-20160816;
        b=O9qGljRxf8nnz/El9ixjv7wf2pd5t4yKCfqlff6agORUDJ/Ltsd8WM+evz7oTDnryL
         HuwoCrxvKDjqFHHapRoCyzH9Sd/W2h5ie6BhWmY8PRq0o/jhK4bTWe3tld9osNyaPKed
         8JXJV/tVHik/oU/8GDmBu/zfocYBNPJAOJZQoR3ebVZYuCK7G66aw+rc/uYTDaZVmzK/
         OZo5T/8zs7HFrEawhtRg74hnsAMsBFvtttXYfBXZWLxCiI/bp56CQqsjUHBEGIVpW7n6
         0zPwGulbc+bvvZTyDQrV93zOG06MNQSlCkuQDsqnwjAGrvU7fdy77rSWYK2GgMRaZ9ex
         c7sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=3NY+crrjnx+TvV8HMgMwqtScaTHrRa6ZFF6/ZoDx/bI=;
        b=kHSe4of5cdyAnGzH5dmfl4YMQYRxfUyXXZdackY++koG8VqCk88hC4tZVsdTV5OzSr
         zO5mCIg2uamjwlzatd/1DYX6kliKO7TvX4jkWalP+kIkkWS/ockIeszCBkcib1ExEkLo
         C27zKqTq3paK08NsVoSFbbbsu5Z1EeYU9y2U6M/PU6qO+cI4BvfIPuh4CI2mKDTwZxeW
         pNWwLFTK28GwzLvxMpuFQaPVSTF6EJaAa5VT4/T6/Pm1oAkhLoVqDr9GnkmmWB2ejWzi
         RiSkziWPZHUtD9x6LcPxPLfARP9H0TeNA6hdl2J2J4J3zjeQjKXCvTarMMpW5boKz6W7
         fsUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bmLfM3qw;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=UZgNhZP6;
       spf=pass (google.com: domain of prvs=10734da445=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10734da445=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id n184si17290580pfn.59.2019.06.19.14.19.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 14:19:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10734da445=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bmLfM3qw;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=UZgNhZP6;
       spf=pass (google.com: domain of prvs=10734da445=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10734da445=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5JLFVWo000367;
	Wed, 19 Jun 2019 14:19:20 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=3NY+crrjnx+TvV8HMgMwqtScaTHrRa6ZFF6/ZoDx/bI=;
 b=bmLfM3qw3rWLd3gqel2Xys2m/uwQFDnFDqVQsppZF+VF9/7qKTREJ1b+fE8hDJW4lmOz
 xZg3Xb+lKFQxQ1Fnj2iGwzRmMjXlM5M0hWocteC6HmOWloQjKVqotLm7Osv6dJrd61mp
 VDInvEwJNvB8Iu8eF9+fZFdN7i7F8zi7EjQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t7r9v92tu-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 19 Jun 2019 14:19:20 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 19 Jun 2019 14:19:18 -0700
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 19 Jun 2019 14:19:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3NY+crrjnx+TvV8HMgMwqtScaTHrRa6ZFF6/ZoDx/bI=;
 b=UZgNhZP6yIuHddenr9xkBBVpkq1msj5Tca9c+3DXIf5YDry331CwN1E1qs6evb4Umbj4Wqf7P9kHj/poPzH1fGEdIxPqRCqfk31Cf+iCUybZaDSKUodX/dwC5PJ87+qxgDiwOcIfyYmpT3+xb1xppx+sbvQ8vwD0agMqspignac=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB2651.namprd15.prod.outlook.com (20.179.161.212) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.10; Wed, 19 Jun 2019 21:19:17 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::5022:93e0:dd8b:b1a1]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::5022:93e0:dd8b:b1a1%7]) with mapi id 15.20.1987.014; Wed, 19 Jun 2019
 21:19:17 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrei Vagin <avagin@gmail.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: WARNING: CPU: 0 PID: 11655 at mm/page_counter.c:62
Thread-Topic: WARNING: CPU: 0 PID: 11655 at mm/page_counter.c:62
Thread-Index: AQHVJkPy+Jr2Wzo7c0mhpNsIq/YA/aajfL8A
Date: Wed, 19 Jun 2019 21:19:16 +0000
Message-ID: <20190619211909.GA20860@castle.DHCP.thefacebook.com>
References: <CANaxB-xz6-uCYbSsSEXn3OScYCfpPwP_DxWdh63d9PuLNkeV5g@mail.gmail.com>
In-Reply-To: <CANaxB-xz6-uCYbSsSEXn3OScYCfpPwP_DxWdh63d9PuLNkeV5g@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO2PR04CA0075.namprd04.prod.outlook.com
 (2603:10b6:102:1::43) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:3e17]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b7fb7c26-7d9a-49cc-9ed9-08d6f4fbc906
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB2651;
x-ms-traffictypediagnostic: DM6PR15MB2651:
x-microsoft-antispam-prvs: <DM6PR15MB2651D7A5E6D69ED140A582ABBEE50@DM6PR15MB2651.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2582;
x-forefront-prvs: 0073BFEF03
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(189003)(199004)(53936002)(486006)(6506007)(73956011)(64756008)(66476007)(66446008)(4326008)(476003)(66556008)(256004)(66946007)(229853002)(14444005)(6486002)(6512007)(68736007)(446003)(25786009)(498600001)(14454004)(11346002)(8936002)(8676002)(6436002)(81166006)(81156014)(186003)(33656002)(52116002)(76176011)(9686003)(6916009)(71200400001)(99286004)(71190400001)(1076003)(102836004)(6246003)(46003)(305945005)(7736002)(4744005)(2906002)(6116002)(5660300002)(1411001)(86362001)(386003);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB2651;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: KkQxOtrhjnhjRMTUQYGLKFbtnkFobIc7p1y4GYeauUKGThVNvYun1SbUbx6rzarY84PVQEGfPbgl3JsSbALqlCmGINClyLz1ukEd6MYXrNOHWH18xOjk16SOzcJJ+oSeHe5DdX6pHS3YlDHuDCKPip7k+L8+FfuVnT+AfjL0DyT/TsStXeKznZDBEKy4MxciOBc5GuAkBKuSQOqipNJkPQr8TLc1u0i5nrFzABY7vyJsrMH0NNUa69Ka0QJmm34K8Vm0ybqJwycpONZcYX6KW6U1olRGM67X0M9PJ9NmHXDlro9DmGxuBOH3/+qYhHZAiw4xLLqpHpSlJLKy7sPFRSnulbd7Ss1dfwWn20lztYg7UDWyzWUIW6H+TMEHBc5KJYP9GrtXM19CEiXkqMtMyCTanpHXbSXl6GIR+9LgNi8=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <4E3B263D315271428FC070E91C93BB31@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: b7fb7c26-7d9a-49cc-9ed9-08d6f4fbc906
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Jun 2019 21:19:16.9984
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB2651
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-19_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906190175
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 07:08:26PM -0700, Andrei Vagin wrote:
> Hello,
>=20
> We run CRIU tests on linux-next kernels and today we found this
> warning in the kernel log:

Hello, Andrei!

Can you, please, check if the following patch fixes the problem?

Thanks a lot!

--

diff --git a/mm/slab.h b/mm/slab.h
index a4c9b9d042de..7667dddb6492 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -326,7 +326,8 @@ static __always_inline void memcg_uncharge_slab(struct =
page *page, int order,
        memcg =3D READ_ONCE(s->memcg_params.memcg);
        lruvec =3D mem_cgroup_lruvec(page_pgdat(page), memcg);
        mod_lruvec_state(lruvec, cache_vmstat_idx(s), -(1 << order));
-       memcg_kmem_uncharge_memcg(page, order, memcg);
+       if (!mem_cgroup_is_root(memcg))
+               memcg_kmem_uncharge_memcg(page, order, memcg);
        rcu_read_unlock();
=20
        percpu_ref_put_many(&s->memcg_params.refcnt, 1 << order);

