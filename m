Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58606C3A5A1
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 00:34:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14AA2233A0
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 00:34:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="dxXUTWXk";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="J7P5M5yl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14AA2233A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C2DB6B036C; Thu, 22 Aug 2019 20:34:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 874D56B036D; Thu, 22 Aug 2019 20:34:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73CBC6B036E; Thu, 22 Aug 2019 20:34:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0191.hostedemail.com [216.40.44.191])
	by kanga.kvack.org (Postfix) with ESMTP id 534A56B036C
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 20:34:25 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id DE1D5181AC9AE
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 00:34:24 +0000 (UTC)
X-FDA: 75851821248.09.rock55_439044f1ccb17
X-HE-Tag: rock55_439044f1ccb17
X-Filterd-Recvd-Size: 9465
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 00:34:24 +0000 (UTC)
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7N0Xl1F023245;
	Thu, 22 Aug 2019 17:34:21 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=jXTDCEX9uB05m2ZAKn8xEBSbv7qpvVbJT68jNFrclZ0=;
 b=dxXUTWXkzNmGDbYsSzFMd65ZeAJ4nIId6HKr3ioZnQAis4SrDKvXd99GQt2aWIP8G+aX
 oAE09wNrwl178sJnkxdCyBtUX8gkZ2Fb4WWuqT5xnsl1c0h8kqiHa/wkof6/wjfz/BX4
 uw0tH6CfND841H7EF4DH3Oc3nLX4AlrwjwI= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2uj290ru5a-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 22 Aug 2019 17:34:21 -0700
Received: from prn-mbx01.TheFacebook.com (2620:10d:c081:6::15) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 22 Aug 2019 17:33:53 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-mbx01.TheFacebook.com (2620:10d:c081:6::15) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 22 Aug 2019 17:33:53 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 22 Aug 2019 17:33:53 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=JqAd/GgTzMNX/HC7LNXYNHwnlWmpCJZhhtIQVKrFrf8nTY6CpqdNW29tIcJVoB08jP0wa4+AaQJCrWk/7o+gwyWNWrqklKMhrZPaVcMA38LdrYnhuILZr2WJNk8ju+fLSg4AcLPQMaLeSjD+MvXzuLt8UeAA4xIHJJp70H26NtrDVR/CoH32SKeXpnSpWap0wlCXoWn2JZp9KB6HlBvZ+Qg1RXfXtoGaLhhHeCV8MehVFea1x4VpvRg43zlS95nljmNAmUw7348GrpqiWQLcYR54ceXfnjigUGXGwNDZRlv9Vv6o+2VWgJO3Hlz64STTpDgMU015D352ktB6JadzYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jXTDCEX9uB05m2ZAKn8xEBSbv7qpvVbJT68jNFrclZ0=;
 b=G3+MvNPlSjlkWWiyVlc0o2yd2+EWViCAI6qqmD3Y4D1F1YweX44O8ajviVAD/GOsTcEOeQ5d5e7OMwEbJi0zCfDtws+8WXxZ+0d2FngmZBo9+0g85xQkHcuLTxG2/yNpmevHIoTtB5m6cBDcXYfTQgNl1vDZSQgnmRHBTdXMe6fDmQXbDUwB9w25CkyPBbg2mZ84rdNqemWcanKHg11WSm+KRtd9Vp1SLSvlCHWLdQBpndMIgzB2KqKdrT62o8J3MaHUbt3A4nUxhZVeVht3cl3GFqMXA3zr0dYhuNb+vUxbBDcRAYQNpzi99cCJ2g7oxUFlajr5dycseJ10MI6RoQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jXTDCEX9uB05m2ZAKn8xEBSbv7qpvVbJT68jNFrclZ0=;
 b=J7P5M5yl4d1bGeU1umHInLCIAHpcuJNFvgkOgkADvtAJSC+VDSuIH+evQq12JiLnd/7go3TS8oWxal9BTFaKZtK4xWuRM36A/ecxc6Qxhw5n8FveIEU7J1WgRqBIm5Vb/1mMkC0JkNSRLLKqc87tU5Vg/s0Vh+Xt7PAsoE+qDds=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB3641.namprd15.prod.outlook.com (10.141.165.215) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Fri, 23 Aug 2019 00:33:51 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e%3]) with mapi id 15.20.2178.020; Fri, 23 Aug 2019
 00:33:51 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Michal Hocko
	<mhocko@kernel.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>
Subject: Re: [PATCH v3 0/3] vmstats/vmevents flushing
Thread-Topic: [PATCH v3 0/3] vmstats/vmevents flushing
Thread-Index: AQHVVuIB+G+nqdgGRkW4V6+4fmWsuqcH1HiAgAASnoA=
Date: Fri, 23 Aug 2019 00:33:51 +0000
Message-ID: <20190823003347.GA4252@castle>
References: <20190819230054.779745-1-guro@fb.com>
 <20190822162709.fa100ba6c58e15ea35670616@linux-foundation.org>
In-Reply-To: <20190822162709.fa100ba6c58e15ea35670616@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR14CA0052.namprd14.prod.outlook.com
 (2603:10b6:300:81::14) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::4e7c]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 26296089-602d-479d-4802-08d72761923f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB3641;
x-ms-traffictypediagnostic: DM6PR15MB3641:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <DM6PR15MB3641F6A11EBA94298849D625BEA40@DM6PR15MB3641.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0138CD935C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(7916004)(39860400002)(136003)(396003)(376002)(366004)(346002)(189003)(199004)(446003)(476003)(8936002)(52116002)(11346002)(33656002)(76176011)(6246003)(86362001)(6436002)(1076003)(81156014)(81166006)(7736002)(33716001)(316002)(8676002)(6512007)(5660300002)(9686003)(305945005)(102836004)(486006)(53936002)(6486002)(54906003)(99286004)(64756008)(66476007)(46003)(66446008)(66946007)(66556008)(6916009)(256004)(6116002)(386003)(25786009)(186003)(229853002)(6506007)(14454004)(4326008)(71190400001)(71200400001)(478600001)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB3641;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: KjJf1wRT6j6YO+1z6CZMOdzootfuLQkd7eKv3B7brDLkgBcDT5p8JztksnEOjT8IPnUWSLneDYqKjjklnWfextZX4FyT2QqZ78EvVOPBimzHb5MEik0jUu0ABBlGaPR09CBcdKsx6lNaUWIX9EfjWPkZZqXhVhL24axK9vMoDltuY98kRau5oVqJoE7HDz1rU1JzelIabIYNLGynCLAopRrwpR6uVXxu7tIOD3osprKaoAOfr+vhyLiipqGbLXjTXWoQ37lr6ZKyxjVU9lSPqvjxaByHceRpK/zR/fYptfrlWuUV1Ds9Baks8ahKNIk50g6mI3D8w5o6MUO72qpU0pTRg7zCL1lHg21tzPiegIXJZ0Qfs6QfWJuGNlrDSj2Gtqb7mpS5WIvFt3kbBOpcPgashGMkDXWZbS+FFDmKIW4=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <25B4E9D6247EA344B11B2F94180BC7C9@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 26296089-602d-479d-4802-08d72761923f
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Aug 2019 00:33:51.6085
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: dvwfwmS2tUge4jp2UF+IUJ/3rHUsv5XbcowdWWe+RMxi2olVBsZ6wK5Mlc7mF9zq
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB3641
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-22_15:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=809 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908230002
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 04:27:09PM -0700, Andrew Morton wrote:
> On Mon, 19 Aug 2019 16:00:51 -0700 Roman Gushchin <guro@fb.com> wrote:
>=20
> > v3:
> >   1) rearranged patches [2/3] and [3/3] to make [1/2] and [2/2] suitabl=
e
> >   for stable backporting
> >=20
> > v2:
> >   1) fixed !CONFIG_MEMCG_KMEM build by moving memcg_flush_percpu_vmstat=
s()
> >   and memcg_flush_percpu_vmevents() out of CONFIG_MEMCG_KMEM
> >   2) merged add-comments-to-slab-enums-definition patch in
> >=20
> > Thanks!
> >=20
> > Roman Gushchin (3):
> >   mm: memcontrol: flush percpu vmstats before releasing memcg
> >   mm: memcontrol: flush percpu vmevents before releasing memcg
> >   mm: memcontrol: flush percpu slab vmstats on kmem offlining
> >=20
>=20
> Can you please explain why the first two patches were cc:stable but not
> the third?
>=20
>=20

Because [1] and [2] are fixing commit 42a300353577 ("mm: memcontrol: fix
recursive statistics correctness & scalabilty"), which has been merged into=
 5.2.

And [3] fixes commit fb2f2b0adb98 ("mm: memcg/slab: reparent memcg kmem_cac=
hes
on cgroup removal"), which is in not yet released 5.3, so stable backport i=
sn't
required.

Thanks!

