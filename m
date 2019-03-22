Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 427DCC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 23:01:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF9A320685
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 23:01:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="m+dyKmDO";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="ThIKySID"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF9A320685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 709636B0007; Fri, 22 Mar 2019 19:01:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B5986B0008; Fri, 22 Mar 2019 19:01:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57E2D6B000A; Fri, 22 Mar 2019 19:01:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C31A6B0007
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 19:01:26 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id b199so2980878iof.14
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 16:01:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=fa+tMZG2kBtBSTSbDQRVIvcUjPD1/3k13sgEyM6tr2s=;
        b=cLroLExV1h6DH1jYSKNo7PPcwk5QU8BHJTu2uspK4UU/2AD65JHInjhF969hRFYh+J
         zPxmq0wDB4lxVpcF6eyUNHtx9v3l6aB8WjDPymS1nXWA2yGJPKADiVCONcQDk4DKgKe2
         m7O0/xkcNG81INvsGM5+8vr81w2Yd5PBuBeOpk4maUXVra0Vm2AZU3CdZ9Suq6mF23U3
         x2IahZKOV2vpoPTbLlhwgArspqVWoW2fFKUWkkYekAlR41t89Mvi2Z4cKzdKXdpOYcIk
         MP1cwXc4VtxKah/wFaN4nu54YefcpzESHFDQzxXq27SZT73vO0QlZbVFlDy4vG4fbtDm
         yLiQ==
X-Gm-Message-State: APjAAAVcgsfjFXIG8Q44J5st9vyL8/XDEi2tNbsmim1Gp2kzk5Dp6uby
	lYYzhx4/HY1+NSZPFYMWEL2bKFC4uJQJ0k1FSZkgfgbxPxWtnnf2t0agRjjzWNHj2AvEQcXBLFU
	WVMXFAUpVzo2OFV8tChGynfRhn+rC0KLxWk4xW2nXD4pnXmU/EvWLcfBeI2gf2rl0lg==
X-Received: by 2002:a05:660c:b44:: with SMTP id m4mr2990890itl.132.1553295686021;
        Fri, 22 Mar 2019 16:01:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoizBGoqfIvj276E/Q6AiUwvbI04VWvZU75YP7oV/uJRmFiY/mGPi1M2lT6g3C8IGpIDwS
X-Received: by 2002:a05:660c:b44:: with SMTP id m4mr2990833itl.132.1553295685262;
        Fri, 22 Mar 2019 16:01:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553295685; cv=none;
        d=google.com; s=arc-20160816;
        b=K6ok8dC9NHOKMk4FxITV8AKdszwn4rl0KvnldZ+BBD8uqL2Pne45CIAyujiYvdEEdV
         a2pwzjrgrM439X217UH7SM2z+P+kNrnR8yAsTPBw03rl2jx7E3rVTRkk/6fJujirEloZ
         DF7zzkOQuKhH4l5aq62Cp+9NbBMjXc6R8ts//rsWFp+v5/UY5WWHCB2IFFJxblxK5wDE
         SrprRD8p5l4MeL7TVGxAdwqvBKs4QZ4qaIrM3uEdmIG9qf1w8TKQAqURSPRjRCBzqOj+
         otc3DHQhjzsyFI3eBMcAe8Wo3mAnK5lwS3V+3b2zuTRleE1dl6AjTZPxosofclfn0/pU
         XnZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=fa+tMZG2kBtBSTSbDQRVIvcUjPD1/3k13sgEyM6tr2s=;
        b=qW0oXSl9u2Ibc5EwQvKq/76bWaFPUH8TQhs5HPhC2bdwxec21zWTXqyHsVlF5sfBG6
         m3W7HiWG0O/3RGgbWt250+fRHLR+Mj5EmWiEAdVACYaFT8wXaY6HskEfsEvxpdmeXBpt
         tT5bkIFx7AIdBefgT9GjcWlWnshsYp08X/ZOBayimRn+G1+XbFR1PtPK5l9D1Q8ppH32
         1XkJ9gsdALoWIentdsonvjZNymHHly8D2imMcxfCWrIfPs2gIEemQxOfbzL5QMesuNGc
         7tdUBN+JTf5Ybp5yaLpusx34SMUml/cQNyXvX4mlT7j3FvfPzjZz2IlhLKxnlcFUplfl
         61Bw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=m+dyKmDO;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=ThIKySID;
       spf=pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=89845e868f=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m21si4225041jad.62.2019.03.22.16.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 16:01:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=m+dyKmDO;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=ThIKySID;
       spf=pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=89845e868f=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2MMoVQ9009704;
	Fri, 22 Mar 2019 16:01:05 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=fa+tMZG2kBtBSTSbDQRVIvcUjPD1/3k13sgEyM6tr2s=;
 b=m+dyKmDO1DNtCA3BIDm0x1kgypByM+wKW0iN8wLwScUJULe5v3prnUWNk84jpIPUI/ei
 f8b814nraklXSFC7oT3Ii0gYwRZVxKNkEHcAmDRBU96jTF6V46m5aUqsF0U0x4lki5z0
 GRDnjzPwOC53f4GZWjefQXqXOz9+698CbVk= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rd45hh59p-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 22 Mar 2019 16:01:05 -0700
Received: from prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) by
 prn-hub03.TheFacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 22 Mar 2019 16:01:04 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 22 Mar 2019 16:01:03 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 22 Mar 2019 16:01:04 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=fa+tMZG2kBtBSTSbDQRVIvcUjPD1/3k13sgEyM6tr2s=;
 b=ThIKySIDLaX9uORRfhaE9MTVCrFtE146gMvsKVRB1oeoYZQv+Nr8Ditjf023OrpvHuHGS+jkp3Y42Rkt4IFfJuMEsVwDAJEXs3Xh6bWZ2pTFeNo4M5BR/1QHyuz4JuYuNAfkB3mC0B0lLXRId6p4wZBa8Ml0t+QGS2MGr6akaeo=
Received: from BN8PR15MB2626.namprd15.prod.outlook.com (20.179.137.220) by
 BN8PR15MB3089.namprd15.prod.outlook.com (20.178.221.212) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Fri, 22 Mar 2019 23:01:02 +0000
Received: from BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::adfe:efd3:ae90:1f2a]) by BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::adfe:efd3:ae90:1f2a%4]) with mapi id 15.20.1730.017; Fri, 22 Mar 2019
 23:01:02 +0000
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
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Thread-Topic: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Thread-Index: AQHU4MjBAXhBvPMCI0qZ3+WtTr5x4qYXxmuAgAB7GwCAAAMggA==
Date: Fri, 22 Mar 2019 23:01:02 +0000
Message-ID: <20190322230054.GA11625@tower.DHCP.thefacebook.com>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
 <20190322222907.GA17496@tower.DHCP.thefacebook.com>
 <20190322224946.GA12527@chrisdown.name>
In-Reply-To: <20190322224946.GA12527@chrisdown.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR20CA0045.namprd20.prod.outlook.com
 (2603:10b6:300:ed::31) To BN8PR15MB2626.namprd15.prod.outlook.com
 (2603:10b6:408:c7::28)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:b690]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: cae3c621-689c-48ad-a9ae-08d6af1a4164
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BN8PR15MB3089;
x-ms-traffictypediagnostic: BN8PR15MB3089:
x-microsoft-antispam-prvs: <BN8PR15MB3089BC4EABFFC40330301518BE430@BN8PR15MB3089.namprd15.prod.outlook.com>
x-forefront-prvs: 09840A4839
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(376002)(366004)(136003)(396003)(346002)(189003)(199004)(305945005)(476003)(6512007)(6246003)(33656002)(4744005)(6116002)(71200400001)(81166006)(6436002)(6916009)(9686003)(71190400001)(102836004)(106356001)(256004)(97736004)(53936002)(5660300002)(99286004)(76176011)(14454004)(229853002)(1076003)(8676002)(52116002)(478600001)(6486002)(2906002)(316002)(446003)(8936002)(486006)(6506007)(386003)(93886005)(25786009)(105586002)(7736002)(54906003)(46003)(68736007)(186003)(11346002)(86362001)(81156014)(4326008);DIR:OUT;SFP:1102;SCL:1;SRVR:BN8PR15MB3089;H:BN8PR15MB2626.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 9COWnh/URAc49y7HFV1Mve6zoJkBf3B7brATq17xoC/6qSljd4qVajeIL0yapnfCLJ2VclD8Wz8Syokly8ftbPcnFzYktS/8PtpKTDQHEMxluvy9dE5gd1brHPb81Mknei79LdliVnCHa43QukSZ9yVbv6l5jDRrk3aqXPV5v1nKnbE6GbQr4awwGsXu0INfrTmt8pYu96TQe85nMh6F8WBYspz7Oxueuu4qcZ6GgbsazgOIFDjPKOcVoFIcf/xf1+7e1oHEinf8LbxqeT4EtgKreHwY8imhtDR/Bz+Yy3EsiRg6rgodtLka5CLEpCWtMqaks5FkGKcQ9h+Vm1FiOKwfC2Ao4+rdNcqWn+Wl/Xq/4rSypW5AzZz2k0fJfViv1ZYAvLNWBMvbr4Mf6vT0o3UCCCds7ZC+eKJ3hmqszjY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3094D3D488845C44BF820DA1A4FFFC13@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: cae3c621-689c-48ad-a9ae-08d6af1a4164
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Mar 2019 23:01:02.4032
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR15MB3089
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-22_13:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 10:49:46PM +0000, Chris Down wrote:
> Roman Gushchin writes:
> > I've noticed that the old version is just wrong: if cgroup_size is way =
smaller
> > than max(min, low), scan will be set to -lruvec_size.
> > Given that it's unsigned long, we'll end up with scanning the whole lis=
t
> > (due to clamp() below).
>=20
> Are you certain? If so, I don't see what you mean. This is how the code
> looks in Linus' tree after the fixups:
>=20
>    unsigned long cgroup_size =3D mem_cgroup_size(memcg);
>    unsigned long baseline =3D 0;
>=20
>    if (!sc->memcg_low_reclaim)
>            baseline =3D lruvec_size;
>    scan =3D lruvec_size * cgroup_size / protection - baseline;

>=20
> This works correctly as far as I can tell:

I'm blaming the old version, not the new one.

New one is perfectly fine, thanks to these lines:
+                       /* Avoid TOCTOU with earlier protection check */
+                       cgroup_size =3D max(cgroup_size, protection);

The old one was racy.

Thanks!

