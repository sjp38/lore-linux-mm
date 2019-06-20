Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8C4AC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:26:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 910D32070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 21:26:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="kuBjMvcO";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="kI6wjRRL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 910D32070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E1DC6B0005; Thu, 20 Jun 2019 17:26:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 293748E0002; Thu, 20 Jun 2019 17:26:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10D4F8E0001; Thu, 20 Jun 2019 17:26:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCB486B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 17:26:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k19so2265201pgl.0
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 14:26:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=uwop1dAgrTKoJsb+U3ozbQ4/2pGcctGST07cc68noyM=;
        b=BnTG9+3Dw6rcha9hZrRagwPVEhLFzutq+w9TZHTwdfZRf+i1mLfDL96rXcJfs3VyxL
         fDSL95KSWBz2viJuCE/rAVoZ7qf6lbHs3sbkJdwwWD2wSO22uxq5ni2DR+c+Od01t9bw
         RGDolODwEnATwmcoEW50VEq2C8p0hXyksbr7ATz56JePXmXQQpL1AIaFEMyPu+BatXjg
         ba/7VSWBpdcI9ZSzC67bDYqqtywoTAFwU2sNMxKsw1zCDXGPaYSGqxMqIoDEujfkR93D
         hcYqNDkqG95H6rY0kXQCByq7kGbuUeKu+5WYTSy9NHOd9JDtoT9uyQap2/GQ6sk9QMHH
         4/uw==
X-Gm-Message-State: APjAAAUgBOx3iFK9lmCLnbxK8Fe1R+/H3L77L9ijJvdLVoyhORiVEiGG
	Dt2PmHLTMfP6fF1PF9yp3bZxE+f/CQgDaYcnzQd6FBL8eyVri+lxQFP2Bk9LYkxffLa4bUG2+l9
	cCgocKbEH2EETFaymmq/sGgFrZX0plUlyIr235HemTumYvBnQieM9JZaFdror2BWs5g==
X-Received: by 2002:a17:90a:8d04:: with SMTP id c4mr1719458pjo.126.1561066010353;
        Thu, 20 Jun 2019 14:26:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZauddUjAGzXfYGDIGKPMfffxxzwHE7mXYfFKXqCR0AmJksA4/J/9Yw3ukXtePVSrXMZZk
X-Received: by 2002:a17:90a:8d04:: with SMTP id c4mr1719392pjo.126.1561066009466;
        Thu, 20 Jun 2019 14:26:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561066009; cv=none;
        d=google.com; s=arc-20160816;
        b=mRwwWJtL654igjmw+rS3DNIqddL+3D/avX89dT8PsbGxxoOHT0DV1XQsgTw1L6AOgT
         3vo4/TZp+aU7TKs0XZSUSiZZA7k9rheufTkea7/VgYxVw7+ZdUkCe9EeDiYDOlBn0srV
         Hqshg1thbt4X3GWM2rekuel+xPtqRnBrkHa9kB4y6MQuwVUhZMmOC2dnwmSazRv7cAnX
         jTNdSKKvOTfNGNsNMzkEmY8LyiMbgyXqOSCMhOGihsrFesgStikTCcGfzNaJnn5nKV2u
         8nvUMVkFNVtWb1yXN/5WuE+QRvqJPgJlG4SFHI/Ha2t8/LXTaRwixbcardg1NP8NUisH
         7/nA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=uwop1dAgrTKoJsb+U3ozbQ4/2pGcctGST07cc68noyM=;
        b=TLOo1C8NE29oL44p+XZou5hbz2rRtD0K7BlofitPhl9ByWb8GEkSndUd7kXvfLVySP
         KCtHQlgZiKHFUdVJcgJCz7dSRFetlpRYZhKMn+Vt0Nn6Dx/U7/ZGKfVRK/L+WKGq2dQu
         vWiIPd7TSYpjSKATo5VqZggx0T18vvTDxQgzsixgojLoC0D7qXQv0J+zD2MBH8sCVjhs
         9GSyvIIiG3W8bBIyTbqAIGkzgLdr1axDsfalAj0YmR9MkU+1SL0nq3ekrJX5/aR5Kc1j
         A5nSSrHvBCf/LCTKAHUk7ZKPlvd8JKEWwYqLjPY9kCt815UXz1DbHR0stoFNUZgDHn+s
         EPyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=kuBjMvcO;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=kI6wjRRL;
       spf=pass (google.com: domain of prvs=1074ecebd6=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1074ecebd6=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q1si732805pll.25.2019.06.20.14.26.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 14:26:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1074ecebd6=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=kuBjMvcO;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=kI6wjRRL;
       spf=pass (google.com: domain of prvs=1074ecebd6=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1074ecebd6=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KL9Ghu011246;
	Thu, 20 Jun 2019 14:26:42 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=uwop1dAgrTKoJsb+U3ozbQ4/2pGcctGST07cc68noyM=;
 b=kuBjMvcOLuEI+f7bQt+lPV3TgzdmOTGKWxjGD5u57kjaE8ohlnTo0NRoeelpKBYJlkR0
 V8eJWjEKE048IO1CLEoY29FAaXPY0Ei3d6Q+rIbEMPs6PbH+ij7CT6B1VJnXJkMZ6rGl
 OXUcI1m0TpdXkWb//eM5zPQdTU2EFlCR8OQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8f1n0q4g-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 14:26:42 -0700
Received: from prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 20 Jun 2019 14:26:42 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 20 Jun 2019 14:26:41 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 20 Jun 2019 14:26:41 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=uwop1dAgrTKoJsb+U3ozbQ4/2pGcctGST07cc68noyM=;
 b=kI6wjRRLF7sqTIlpT3eIscoiVaU7GYY1Eg2yaSx7yrI0agpt56ZC1+ydDKjWON7YisnpSmNepH1hx/xOEPol5ZsNeW7GJ9TBuxagthWRnsaikLOqqmCwEyvbAq4KWlI3Nl7PF3Fq9/aczgW17za87JioKt+DtugN4q7z2Q6F3V0=
Received: from BN8PR15MB2626.namprd15.prod.outlook.com (20.179.137.220) by
 BN8PR15MB2595.namprd15.prod.outlook.com (20.179.137.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.15; Thu, 20 Jun 2019 21:26:37 +0000
Received: from BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::e594:155f:a43:92ad]) by BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::e594:155f:a43:92ad%6]) with mapi id 15.20.1987.014; Thu, 20 Jun 2019
 21:26:37 +0000
From: Roman Gushchin <guro@fb.com>
To: Shakeel Butt <shakeelb@google.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        Linux MM <linux-mm@kvack.org>, LKML
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        "Johannes
 Weiner" <hannes@cmpxchg.org>,
        Waiman Long <longman@redhat.com>, "Christoph
 Lameter" <cl@linux.com>,
        Michal Hocko <mhocko@suse.com>, David Rientjes
	<rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Pekka Enberg
	<penberg@kernel.org>
Subject: Re: [PATCH] mm: memcg/slab: properly handle kmem_caches reparented to
 root_mem_cgroup
Thread-Topic: [PATCH] mm: memcg/slab: properly handle kmem_caches reparented
 to root_mem_cgroup
Thread-Index: AQHVJwuPcADS+4yViE2ojhNJy2JiKqaksPwAgABekoA=
Date: Thu, 20 Jun 2019 21:26:37 +0000
Message-ID: <20190620212624.GA3494@castle.DHCP.thefacebook.com>
References: <20190620015554.1888119-1-guro@fb.com>
 <CALvZod6MzPvX67AxrGddNWhr99oVY7_v6tXh_7yXdf-g24b6nQ@mail.gmail.com>
In-Reply-To: <CALvZod6MzPvX67AxrGddNWhr99oVY7_v6tXh_7yXdf-g24b6nQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR19CA0004.namprd19.prod.outlook.com
 (2603:10b6:300:d4::14) To BN8PR15MB2626.namprd15.prod.outlook.com
 (2603:10b6:408:c7::28)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:4392]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 16c3150f-5858-4d0b-f633-08d6f5c5f9e1
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BN8PR15MB2595;
x-ms-traffictypediagnostic: BN8PR15MB2595:
x-microsoft-antispam-prvs: <BN8PR15MB2595F5C6EB0F93CCDF67FF34BEE40@BN8PR15MB2595.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2331;
x-forefront-prvs: 0074BBE012
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(396003)(376002)(346002)(136003)(366004)(51234002)(189003)(199004)(5660300002)(25786009)(99286004)(46003)(11346002)(66446008)(9686003)(66556008)(54906003)(316002)(86362001)(73956011)(68736007)(14454004)(386003)(102836004)(229853002)(186003)(66946007)(6512007)(66476007)(64756008)(476003)(256004)(6486002)(6246003)(6506007)(4326008)(71190400001)(6116002)(81166006)(53546011)(14444005)(6436002)(81156014)(486006)(8676002)(33656002)(7736002)(71200400001)(53936002)(446003)(45080400002)(478600001)(6916009)(76176011)(2906002)(7416002)(52116002)(8936002)(1076003)(305945005);DIR:OUT;SFP:1102;SCL:1;SRVR:BN8PR15MB2595;H:BN8PR15MB2626.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: ePbx8GGULvG91h4xMI26A3RplptaOSNwS8v77+MKQt1oMaKAlGx525KEcASQFqhnd9Astj5voOFyNhG7i1sJOpmNJ0qecn7ljig1RCkgJVOlzb4O4bbNO6IximNPeCfnWYFXQ/z7Kih4UzIazaVzvGXi8dTri/yk54JD+T32NzLWErDoDNSdhXNjewOYOxlk/Fkhl0x3izqhA0ywwhENbbY7q3+G6+2X+kF9vyJwXVDb4+tv6jgrkL/hLCKsCqz6PLyRt/c1NawqFfXDBZbOC3JrQ5a5KalkD4/vBsVE9XBZS7WP0b81QUCBb1rhf96q+yZWXj2LBmRbtWP2/OKawl8Jh0mwi1RLKXJSzdX83U//ELMs4Woefqc/ctMMwz3U8tgTrK+vpiUnSDUM55jzjEFlP/fVFgh+np8XyH/LjnQ=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E1B95286E8237B43A153BBD75D8B7E05@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 16c3150f-5858-4d0b-f633-08d6f5c5f9e1
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Jun 2019 21:26:37.3529
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR15MB2595
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200152
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 08:48:00AM -0700, Shakeel Butt wrote:
> On Wed, Jun 19, 2019 at 6:57 PM Roman Gushchin <guro@fb.com> wrote:
> >
> > As a result of reparenting a kmem_cache might belong to the root
> > memory cgroup. It happens when a top-level memory cgroup is removed,
> > and all associated kmem_caches are reparented to the root memory
> > cgroup.
> >
> > The root memory cgroup is special, and requires a special handling.
> > Let's make sure that we don't try to charge or uncharge it,
> > and we handle system-wide vmstats exactly as for root kmem_caches.
> >
> > Note, that we still need to alter the kmem_cache reference counter,
> > so that the kmem_cache can be released properly.
> >
> > The issue was discovered by running CRIU tests; the following warning
> > did appear:
> >
> > [  381.345960] WARNING: CPU: 0 PID: 11655 at mm/page_counter.c:62
> > page_counter_cancel+0x26/0x30
> > [  381.345992] Modules linked in:
> > [  381.345998] CPU: 0 PID: 11655 Comm: kworker/0:8 Not tainted
> > 5.2.0-rc5-next-20190618+ #1
> > [  381.346001] Hardware name: Google Google Compute Engine/Google
> > Compute Engine, BIOS Google 01/01/2011
> > [  381.346010] Workqueue: memcg_kmem_cache kmemcg_workfn
> > [  381.346013] RIP: 0010:page_counter_cancel+0x26/0x30
> > [  381.346017] Code: 1f 44 00 00 0f 1f 44 00 00 48 89 f0 53 48 f7 d8
> > f0 48 0f c1 07 48 29 f0 48 89 c3 48 89 c6 e8 61 ff ff ff 48 85 db 78
> > 02 5b c3 <0f> 0b 5b c3 66 0f 1f 44 00 00 0f 1f 44 00 00 48 85 ff 74 41
> > 41 55
> > [  381.346019] RSP: 0018:ffffb3b34319f990 EFLAGS: 00010086
> > [  381.346022] RAX: fffffffffffffffc RBX: fffffffffffffffc RCX: 0000000=
000000004
> > [  381.346024] RDX: 0000000000000000 RSI: fffffffffffffffc RDI: ffff9c2=
cd7165270
> > [  381.346026] RBP: 0000000000000004 R08: 0000000000000000 R09: 0000000=
000000001
> > [  381.346028] R10: 00000000000000c8 R11: ffff9c2cd684e660 R12: 0000000=
0fffffffc
> > [  381.346030] R13: 0000000000000002 R14: 0000000000000006 R15: ffff9c2=
c8ce1f200
> > [  381.346033] FS:  0000000000000000(0000) GS:ffff9c2cd8200000(0000)
> > knlGS:0000000000000000
> > [  381.346039] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [  381.346041] CR2: 00000000007be000 CR3: 00000001cdbfc005 CR4: 0000000=
0001606f0
> > [  381.346043] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
> > [  381.346045] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000=
000000400
> > [  381.346047] Call Trace:
> > [  381.346054]  page_counter_uncharge+0x1d/0x30
> > [  381.346065]  __memcg_kmem_uncharge_memcg+0x39/0x60
> > [  381.346071]  __free_slab+0x34c/0x460
> > [  381.346079]  deactivate_slab.isra.80+0x57d/0x6d0
> > [  381.346088]  ? add_lock_to_list.isra.36+0x9c/0xf0
> > [  381.346095]  ? __lock_acquire+0x252/0x1410
> > [  381.346106]  ? cpumask_next_and+0x19/0x20
> > [  381.346110]  ? slub_cpu_dead+0xd0/0xd0
> > [  381.346113]  flush_cpu_slab+0x36/0x50
> > [  381.346117]  ? slub_cpu_dead+0xd0/0xd0
> > [  381.346125]  on_each_cpu_mask+0x51/0x70
> > [  381.346131]  ? ksm_migrate_page+0x60/0x60
> > [  381.346134]  on_each_cpu_cond_mask+0xab/0x100
> > [  381.346143]  __kmem_cache_shrink+0x56/0x320
> > [  381.346150]  ? ret_from_fork+0x3a/0x50
> > [  381.346157]  ? unwind_next_frame+0x73/0x480
> > [  381.346176]  ? __lock_acquire+0x252/0x1410
> > [  381.346188]  ? kmemcg_workfn+0x21/0x50
> > [  381.346196]  ? __mutex_lock+0x99/0x920
> > [  381.346199]  ? kmemcg_workfn+0x21/0x50
> > [  381.346205]  ? kmemcg_workfn+0x21/0x50
> > [  381.346216]  __kmemcg_cache_deactivate_after_rcu+0xe/0x40
> > [  381.346220]  kmemcg_cache_deactivate_after_rcu+0xe/0x20
> > [  381.346223]  kmemcg_workfn+0x31/0x50
> > [  381.346230]  process_one_work+0x23c/0x5e0
> > [  381.346241]  worker_thread+0x3c/0x390
> > [  381.346248]  ? process_one_work+0x5e0/0x5e0
> > [  381.346252]  kthread+0x11d/0x140
> > [  381.346255]  ? kthread_create_on_node+0x60/0x60
> > [  381.346261]  ret_from_fork+0x3a/0x50
> > [  381.346275] irq event stamp: 10302
> > [  381.346278] hardirqs last  enabled at (10301): [<ffffffffb2c1a0b9>]
> > _raw_spin_unlock_irq+0x29/0x40
> > [  381.346282] hardirqs last disabled at (10302): [<ffffffffb2182289>]
> > on_each_cpu_mask+0x49/0x70
> > [  381.346287] softirqs last  enabled at (10262): [<ffffffffb2191f4a>]
> > cgroup_idr_replace+0x3a/0x50
> > [  381.346290] softirqs last disabled at (10260): [<ffffffffb2191f2d>]
> > cgroup_idr_replace+0x1d/0x50
> > [  381.346293] ---[ end trace b324ba73eb3659f0 ]---
> >
> > Reported-by: Andrei Vagin <avagin@gmail.com>
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Christoph Lameter <cl@linux.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Shakeel Butt <shakeelb@google.com>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: Waiman Long <longman@redhat.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Cc: Pekka Enberg <penberg@kernel.org>
> > ---
> >  mm/slab.h | 17 +++++++++++++----
> >  1 file changed, 13 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/slab.h b/mm/slab.h
> > index a4c9b9d042de..c02e7f44268b 100644
> > --- a/mm/slab.h
> > +++ b/mm/slab.h
> > @@ -294,8 +294,12 @@ static __always_inline int memcg_charge_slab(struc=
t page *page,
> >                 memcg =3D parent_mem_cgroup(memcg);
> >         rcu_read_unlock();
> >
> > -       if (unlikely(!memcg))
> > +       if (unlikely(!memcg || mem_cgroup_is_root(memcg))) {
> > +               mod_node_page_state(page_pgdat(page), cache_vmstat_idx(=
s),
> > +                                   (1 << order));
> > +               percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order=
);
> >                 return true;
>=20
> Should the above be "return 0;" instead of true?

Yeah... Good catch!
Somehow I missed this previously...

I'll send v2 with the fix.

Thank you!

