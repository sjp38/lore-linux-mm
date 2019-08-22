Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3307C3A59E
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 00:32:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 728C521848
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 00:32:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="pWJ8zzkV";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="foIsS5aR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 728C521848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC40F6B02C1; Wed, 21 Aug 2019 20:32:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B74F26B02C2; Wed, 21 Aug 2019 20:32:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A163C6B02C3; Wed, 21 Aug 2019 20:32:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0103.hostedemail.com [216.40.44.103])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA0A6B02C1
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 20:32:15 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2E2158E74
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 00:32:15 +0000 (UTC)
X-FDA: 75848187030.08.baby21_87f8d99e1f64c
X-HE-Tag: baby21_87f8d99e1f64c
X-Filterd-Recvd-Size: 10413
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 00:32:14 +0000 (UTC)
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7M0RqUR019641;
	Wed, 21 Aug 2019 17:32:10 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=oSE+RwcHIkDnEuPCRSODAq2wzcqedAaQ+s8FBmD2K2w=;
 b=pWJ8zzkVy0QnA5juoBeON74gmV04mYmdfXJG4ALYvmy/g+vAp/mNhZ5+Yp4CPtVfmpZk
 xo70ZDt1T0MBUT/ZT9bLwxw6360IuX7Fp2QDiP+htcTny4WjiERMfGD849w8EzJEG5pQ
 tGDQD88emx4GaftfKdur32wo0cZqGzX+ZbM= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2uhfrjr5jx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Wed, 21 Aug 2019 17:32:10 -0700
Received: from ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) by
 ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 21 Aug 2019 17:32:09 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Wed, 21 Aug 2019 17:32:09 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=lOoFREMdY9KbO9U2LmivMH/F2CL5rlfE4/0PqepUPb9v3Or6ViDA4fofoZGRRmd2/fX82FsMdFDB2JvGVz1crrLpaGcd7H4yReZfwPOgSWI/IrFuMTeBicdFgSOHusHF7B2jTH1+5hf/JluBP464B9KjrQMAAK8Y5E8Xka22uPZmukvcpQapyX1MzGL05rc1YHDw+f4qYhZ3Vk9qs+w6H1bDbWsFQTZAl+Dyd75nShlyZh9Yiezq9iYXezkdAmuqvGbQqxr8fLJsBNwgmkfy/BE2tpYvdiEHMQCwmHbSZKHPSALyBtvP2cX1V1e3XUuSFLFrnddrpUT5cPTt+qlMXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=oSE+RwcHIkDnEuPCRSODAq2wzcqedAaQ+s8FBmD2K2w=;
 b=GHQkN3VaYiZSAWCQabVMC0d3xULXURtlrgNaaJumcwSioaPF80/W1LENDT/qRQ2Y6tu8KCWdlTPOv4xhjEw1W3HaHCPvpLiljgp6dWNijIky9BZfjMQ9FAJxu0wnA1t8fzzz/VoqCoOXTqrahEduHob5+wLpP3WQAlA3+GJf0SdeA30SOgxFGmXchS8KkStXIMMIRVX+eWK+kxtkyZkfqV4mvgnnyDYkxrwaxN5aWZFuWoTHS2tVXu/O/mX3Nn1vlVp8KQDBdcT+s5g5JNxtcRIFKAtSM6CuWpiB2gkqJkSfiko24Q5QDEraXbnVIuSRpVpjqyNKzMYo6kBZat5tcw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=oSE+RwcHIkDnEuPCRSODAq2wzcqedAaQ+s8FBmD2K2w=;
 b=foIsS5aRqy1rUp4/qB1WrRQRBZsrvKhP6nB15pa3uM+tFeRlREnLOO8WP7iAsIDHyS/dfpURAUtsmY/EZdKFUsG31iCZCL9jE7aj60x/6fLFrfBOoSydNvEv/hN5/tCg9T6EeTZ/Y3cYmOmOD6DQzMozCl/POMTrtY38xsxiIig=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB3195.namprd15.prod.outlook.com (20.179.52.78) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.18; Thu, 22 Aug 2019 00:32:08 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e%3]) with mapi id 15.20.2178.020; Thu, 22 Aug 2019
 00:32:08 +0000
From: Roman Gushchin <guro@fb.com>
To: Rong Chen <rong.a.chen@intel.com>
CC: Qian Cai <cai@lca.pw>, Linux Memory Management List <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Johannes Weiner
	<hannes@cmpxchg.org>,
        kbuild test robot <lkp@intel.com>,
        "kbuild-all@01.org"
	<kbuild-all@01.org>
Subject: Re: [kbuild-all] [rgushchin:fix_vmstats 21/221]
 include/asm-generic/5level-fixup.h:14:18: error: unknown type name 'pgd_t';
 did you mean 'pid_t'?
Thread-Topic: [kbuild-all] [rgushchin:fix_vmstats 21/221]
 include/asm-generic/5level-fixup.h:14:18: error: unknown type name 'pgd_t';
 did you mean 'pid_t'?
Thread-Index: AQHVUYgEjnCL7xpfoUOwYYOZHtmUpab5KmCAgAClygCACdj5gIACtdcA
Date: Thu, 22 Aug 2019 00:32:08 +0000
Message-ID: <20190822003204.GA13510@tower.DHCP.thefacebook.com>
References: <201908131117.SThHOrZO%lkp@intel.com>
 <1565707945.8572.10.camel@lca.pw>
 <20190814004548.GA18813@tower.DHCP.thefacebook.com>
 <3edbc032-4cc3-a87c-03c9-2b2fcaec32e8@intel.com>
In-Reply-To: <3edbc032-4cc3-a87c-03c9-2b2fcaec32e8@intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MW2PR2101CA0004.namprd21.prod.outlook.com
 (2603:10b6:302:1::17) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:85f]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0e21e54b-edfb-4fe6-60e7-08d726982a31
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DM6PR15MB3195;
x-ms-traffictypediagnostic: DM6PR15MB3195:
x-ms-exchange-purlcount: 3
x-microsoft-antispam-prvs: <DM6PR15MB3195C37DC98EF810A5EA4B72BEA50@DM6PR15MB3195.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 01371B902F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(366004)(39860400002)(396003)(376002)(346002)(199004)(189003)(186003)(76176011)(9686003)(6306002)(86362001)(25786009)(6512007)(6436002)(66946007)(8936002)(66476007)(66556008)(64756008)(66446008)(6116002)(2906002)(6246003)(4326008)(14454004)(7736002)(478600001)(53936002)(966005)(33656002)(486006)(46003)(476003)(71190400001)(71200400001)(446003)(11346002)(256004)(1076003)(305945005)(316002)(54906003)(99286004)(6506007)(102836004)(53546011)(8676002)(386003)(6916009)(6486002)(81166006)(52116002)(5660300002)(81156014)(5024004)(229853002)(41533002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB3195;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Qt6YXrGSWvzdD4X8PBQfb7MhHVBBKfh43Eobz9Thb55IuBqrTrmJM1PSNcp2jjlnpxKyqyUDzn4Iktk+mVOkcWTZfXBCPlJvIVW5KvFwUDIdIot3XvUSGubzGFWj2lTWVY4fZBSjY0VpW2QF4ueOJ/X6kBoYhGAv2/oZq/j4h4v0Ewcijf7+lhfViNlO9We4ig5yj2EfeWOnzk11Ns2NFILsYVYhndRj0+bejEfESW2JLDEbcJ4oGgLn00lfUrBRHMjn3HJsYGlTO+il4CEMx7MdhSD6J1fUCmQIuvOxlmp2WV2uyAfgUfqiCcf4C1gI0P1equx0VCrR8jqfHOgjbXjID0IxvGeI+cJgo/viYHcP6K6YuDuR9eurF+vZPC63KQNrtzdFs/EjrehP3T1edtEkjbtvyS3dGQFkHz+6Xqg=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <8D9DAEF93A40D34AAA914B5C5DD4A532@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 0e21e54b-edfb-4fe6-60e7-08d726982a31
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Aug 2019 00:32:08.3876
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: u2R0QPUOODaPDGld6wNS2zWY8HsyWlmLpaEfyyu00pvl1x1s2ZAGIorJQqMnQ7GT
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB3195
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-21_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908220003
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 03:08:43PM +0800, Rong Chen wrote:
>=20
>=20
> On 8/14/19 8:45 AM, Roman Gushchin wrote:
> > On Tue, Aug 13, 2019 at 10:52:25AM -0400, Qian Cai wrote:
> > > On Tue, 2019-08-13 at 11:33 +0800, kbuild test robot wrote:
> > > > tree:=A0=A0=A0https://github.com/rgushchin/linux.git fix_vmstats
> > > > head:=A0=A0=A04ec858b5201ae067607e82706b36588631c1b990
> > > > commit: 938dda772d9d05074bfe1baa0dc18873fbf4fedb [21/221] include/a=
sm-
> > > > generic/5level-fixup.h: fix variable 'p4d' set but not used
> > > > config: parisc-c3000_defconfig (attached as .config)
> > > > compiler: hppa-linux-gcc (GCC) 7.4.0
> > > > reproduce:
> > > >  =A0=A0=A0=A0=A0=A0=A0=A0wget https://urldefense.proofpoint.com/v2/=
url?u=3Dhttps-3A__raw.githubusercontent.com_intel_lkp-2Dtests_master_sbin_m=
ak&d=3DDwIFaQ&c=3D5VD0RTtNlTh3ycd41b3MUw&r=3DjJYgtDM7QT-W-Fz_d29HYQ&m=3DTOi=
r6b4wrmTSQpeaAQcpcHZUk9uWkTRUOJaNgbh4m-o&s=3D0IeTTEfMlxl9cDI9YAz2Zji8QaiE8B=
29qreDUnvID5E&e=3D
> > > > e.cross -O ~/bin/make.cross
> > > >  =A0=A0=A0=A0=A0=A0=A0=A0chmod +x ~/bin/make.cross
> > > >  =A0=A0=A0=A0=A0=A0=A0=A0git checkout 938dda772d9d05074bfe1baa0dc18=
873fbf4fedb
> > > >  =A0=A0=A0=A0=A0=A0=A0=A0# save the attached .config to linux build=
 tree
> > > >  =A0=A0=A0=A0=A0=A0=A0=A0GCC_VERSION=3D7.4.0 make.cross ARCH=3Dpari=
sc
> > > I am unable to reproduce this on today's linux-next tree. What's poin=
t of
> > > testing this particular personal git tree/branch?
> > I'm using it to test my patches before sending them to public mailing l=
ists.
> > It really helps with reducing the number of trivial issues and upstream
> > iterations as a consequence. And not only trivial...
> >=20
> > If there is a way to prevent notifying anyone but me, please, let me kn=
ow,
> > I'm happy to do it.
> >=20
> Hi Roman,
>=20
> The reports should only be sent to you now. please see
> https://github.com/intel/lkp-tests/blob/master/repo/linux/rgushchin

Hi Rong!

Oh, thanks a lot! It's exactly what I need.

Regards,
Roman

