Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F709C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 22:47:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C994233FC
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 22:47:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Z2IpM7cu";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="DMzgTzI1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C994233FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE5656B035C; Thu, 22 Aug 2019 18:47:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C95B26B035D; Thu, 22 Aug 2019 18:47:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5D2A6B035E; Thu, 22 Aug 2019 18:47:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0154.hostedemail.com [216.40.44.154])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFF16B035C
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 18:47:06 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 285D7180AD7C1
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 22:47:06 +0000 (UTC)
X-FDA: 75851550852.06.hat35_3b19395e5660
X-HE-Tag: hat35_3b19395e5660
X-Filterd-Recvd-Size: 11544
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 22:47:05 +0000 (UTC)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7MMdtGc027057;
	Thu, 22 Aug 2019 15:47:01 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=ANjLt2oNMUL0RwT0zTxujJKcYyok9UmVfuENmSwwb0k=;
 b=Z2IpM7cu9d8Z5KQ9ilY9fpq6/xMymzeJR5DxMFtvki2GlyZl6bH45PBT6Ol9LMQNrCil
 4U+HDXr4HtdGJCPdH21IA8h2EoykPZkIyH2YIRxtzKiLjjeQe+oFwR+6Au6ZHEFRy6YG
 fvShusxn6zPrv/RNIwPmKP30rmECoCdMCHk= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2uj3yer18u-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 22 Aug 2019 15:47:01 -0700
Received: from ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) by
 ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 22 Aug 2019 15:46:59 -0700
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 22 Aug 2019 15:46:59 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=nbTCLuHrNijfE+PqmFTDcyQ0Yy2bJ8YYiB7bLEVr/0ImOCBXPAI4haWRQ5ebcsmICrSdSHlip+9b4U5KFo16qBhkExab3QChN9NzL4v3RqLXj956qO/Ww/5alxqkiHyd2VEzUg/PsAXs5ByBo02xOEu+Pk864NEFbYs8Ep5pqfM3aeu0bl/gPux9vG+ToSOAf33sIV9nhT8dW0vzUnnixIdvUyjeJocpJbYBjFQmpTRcmd6b5m7yC8odS+o51qnggMU9bHTUfcFMvW+wHWDs24Ij/CzbS8eaGLzp3lB1hJQZMRm1p/Dc0h+IVkf3zrIAlK3wZhVy29MnmEjslvxGXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ANjLt2oNMUL0RwT0zTxujJKcYyok9UmVfuENmSwwb0k=;
 b=a5bAP8qFbxWHcWK1N/OzWuaoSrqsXkpKhDbsGdQ5SXaiiUpZslKZNnHNwCaEP3p9NJFH2yvxWfxegy6XwSwnL1QeX2bw0QDsGNOymY9CFPeIgGTap8DDyj1i9eZ67bMHweXlx2JlHWt3l7sxhks8KPRLEnGSpYb6fk0uv2bp8esILGuPffGb8dg3SVw9hTblQusmBTT1lJX4djkUzCGwDI4teW8u47bHBUvl8SqX3xNa1+LhNybtVWGwVl0uFLeokdnHP0V3h9LG2oatMjuzLTM+fOBSk3fFNNJceKd0upf+qIyuwKOgj0KNI9RAOO0smh1SWKCW4hhFJ5JmDnLCaA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ANjLt2oNMUL0RwT0zTxujJKcYyok9UmVfuENmSwwb0k=;
 b=DMzgTzI1wU66GYKaAeQCDOtGfy7DvWwpqCDGmIczFAIQOC1UylR+dIoEoL0KUEX9gwfTDv6uxxazPamTf0wPra80hYtzVUK3PY3J/EcSx5qiD5x8hSVABzxe/mMb7aVz99JVteyNKqAsMfauE5+x8C9zE+bAPTDjPJqP3eMtzv8=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB3323.namprd15.prod.outlook.com (20.179.52.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.18; Thu, 22 Aug 2019 22:46:58 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e%3]) with mapi id 15.20.2178.020; Thu, 22 Aug 2019
 22:46:58 +0000
From: Roman Gushchin <guro@fb.com>
To: Michal Hocko <mhocko@suse.com>
CC: Yafang Shao <laoar.shao@gmail.com>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>, Johannes Weiner
	<hannes@cmpxchg.org>,
        Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] mm, memcg: introduce per memcg oom_score_adj
Thread-Topic: [PATCH] mm, memcg: introduce per memcg oom_score_adj
Thread-Index: AQHVWMeLnQZUP4QpYEi1u9mF3AnXhqcG47cAgAAEbgCAABeVAIAAxbQA
Date: Thu, 22 Aug 2019 22:46:58 +0000
Message-ID: <20190822224654.GA27164@tower.DHCP.thefacebook.com>
References: <1566464189-1631-1-git-send-email-laoar.shao@gmail.com>
 <20190822091902.GG12785@dhcp22.suse.cz>
 <CALOAHbAOH+Y+sN3ynAiBDm=JWrm4XpyUm8s3r9G=Oz4b0iNvCA@mail.gmail.com>
 <20190822105918.GH12785@dhcp22.suse.cz>
In-Reply-To: <20190822105918.GH12785@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR15CA0039.namprd15.prod.outlook.com
 (2603:10b6:300:ad::25) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:8ee7]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4a8555d8-c59c-40af-fea8-08d72752a38f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600166)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DM6PR15MB3323;
x-ms-traffictypediagnostic: DM6PR15MB3323:
x-microsoft-antispam-prvs: <DM6PR15MB3323056C6318D1DA2833A5A3BEA50@DM6PR15MB3323.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 01371B902F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(396003)(346002)(376002)(366004)(136003)(199004)(189003)(51444003)(54906003)(5660300002)(486006)(8936002)(81156014)(1076003)(81166006)(66946007)(66446008)(478600001)(6246003)(66476007)(66556008)(64756008)(386003)(6506007)(53546011)(2906002)(71200400001)(446003)(4326008)(76176011)(186003)(8676002)(25786009)(71190400001)(11346002)(53936002)(316002)(6436002)(52116002)(6916009)(9686003)(6512007)(476003)(14444005)(6486002)(14454004)(229853002)(7736002)(6116002)(305945005)(86362001)(99286004)(256004)(33656002)(46003)(102836004);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB3323;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: NUmsoRjUuGAjStfHi8R5NTJZbqj28qutqf96VfXaQBjERYO69oxHVIMJgNhD3uDeSm8fHfhvgqcjNGfSrcSNRE3l1C1DHqPE5+aavOwznqgQXiS16Fs3OCGWq6gwML/I6QYxSiaRkNSavkn7kAacmOTDzy16cxOu3lW86DhZUI9z75AshLzGFosRI47Xpk1P4unQZl4lzk1fxc1Gy7sJuqcWSfimpxUp7Ar7iAFolOJ8q5aMcdVTjefTKavUCn/qPKxreQSaUtxa1A0UrnrHOl5/0h3zyLRALmu3yQ1qNdE09St4O+z8BdTZOlOBLVkZVRXdbtUwWy/dIa/TcQFTsPjmIiB3NcA4FIPML3aRvSuUBLKSygYNc0zOYBrNEKPOH7lm5Op1pd4eimgtoNfz0XmwVVIpJs8xVY4p+FLHtXE=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <84EE99794DD47D42A5564BC790E8063B@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 4a8555d8-c59c-40af-fea8-08d72752a38f
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Aug 2019 22:46:58.4017
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: mLGTI1uhkBujD8Kydi8NZbMcm1O7cPGQlV6m+0IwfFddPZzUsw2/rnYrZ6B9lFSG
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB3323
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-22_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908220199
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 12:59:18PM +0200, Michal Hocko wrote:
> On Thu 22-08-19 17:34:54, Yafang Shao wrote:
> > On Thu, Aug 22, 2019 at 5:19 PM Michal Hocko <mhocko@suse.com> wrote:
> > >
> > > On Thu 22-08-19 04:56:29, Yafang Shao wrote:
> > > > - Why we need a per memcg oom_score_adj setting ?
> > > > This is easy to deploy and very convenient for container.
> > > > When we use container, we always treat memcg as a whole, if we have=
 a per
> > > > memcg oom_score_adj setting we don't need to set it process by proc=
ess.
> > >
> > > Why cannot an initial process in the cgroup set the oom_score_adj and
> > > other processes just inherit it from there? This sounds trivial to do
> > > with a startup script.
> > >
> >=20
> > That is what we used to do before.
> > But it can't apply to the running containers.
> >=20
> >=20
> > > > It will make the user exhausted to set it to all processes in a mem=
cg.
> > >
> > > Then let's have scripts to set it as they are less prone to exhaustio=
n
> > > ;)
> >=20
> > That is not easy to deploy it to the production environment.
>=20
> What is hard about a simple loop over tasklist exported by cgroup and
> apply a value to oom_score_adj?
>=20
> [...]
>=20
> > > Besides that. What is the hierarchical semantic? Say you have hierarc=
hy
> > >         A (oom_score_adj =3D 1000)
> > >          \
> > >           B (oom_score_adj =3D 500)
> > >            \
> > >             C (oom_score_adj =3D -1000)
> > >
> > > put the above summing up aside for now and just focus on the memcg
> > > adjusting?
> >=20
> > I think that there's no conflict between children's oom_score_adj,
> > that is different with memory.max.
> > So it is not neccessary to consider the parent's oom_sore_adj.
>=20
> Each exported cgroup tuning _has_ to be hierarchical so that an admin
> can override children setting in order to safely delegate the
> configuration.

+1

>=20
> Last but not least, oom_score_adj has proven to be a terrible interface
> that is essentially close to unusable to anything outside of extreme
> values (-1000 and very arguably 1000). Making it cgroup aware without
> changing oom victim selection to consider cgroup as a whole will also be
> a pain so I am afraid that this is a dead end path.
>=20
> We can discuss cgroup aware oom victim selection for sure and there are
> certainly reasonable usecases to back that functionality. Please refer
> to discussion from 2017/2018 (dubbed as "cgroup-aware OOM killer"). But
> be warned this is a tricky area and there was a fundamental disagreement
> on how things should be classified without a clear way to reach
> consensus. What we have right now is the only agreement we could reach.
> It is likely possible that the only more clever cgroup aware oom
> selection has to be implemented in the userspace with an understanding
> of the specific workload.

I think the agreement is that the main goal of the kernel OOM killer is to
prevent different memory dead- and live-lock scenarios. And everything
that involves policies which define which workloads are preferable over
others should be kept in userspace.

So the biggest issue of the kernel OOM killer right now is that it often ki=
cks
in too late, if at all (which has been discussed recently). And it looks li=
ke
the best answer now is PSI. So I'd really look into that direction to enhan=
ce
it.

Thanks!

