Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42744C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 00:46:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDA9920842
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 00:46:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="bGHV/L0h";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="BYZW7aqO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDA9920842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D5786B0005; Tue, 13 Aug 2019 20:46:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 185A96B0006; Tue, 13 Aug 2019 20:46:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04DF36B0007; Tue, 13 Aug 2019 20:45:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0204.hostedemail.com [216.40.44.204])
	by kanga.kvack.org (Postfix) with ESMTP id D95D96B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 20:45:59 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 7A7E03AB7
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 00:45:59 +0000 (UTC)
X-FDA: 75819191238.04.sock23_5156e522c114f
X-HE-Tag: sock23_5156e522c114f
X-Filterd-Recvd-Size: 9784
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 00:45:58 +0000 (UTC)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7E0iveb023656;
	Tue, 13 Aug 2019 17:45:55 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=dIQAAfEz6LOJFPmr08ugSLlsKygRLr/l9SOWYs5ltc0=;
 b=bGHV/L0hzad8gPI/6EHy6efKO062KUVvyG3t3+tsDf8kG0WD+l8618NKsVA+V+N9aaOI
 AAWLYg/qknpOPYHpla/8g8MwskrxH1BSYO4s+LkafovHlJovqXG17A9nHOGHcOmCx6fN
 pos3bwNpLEuvkISk6Fez8eQPcPC2W3hQrsE= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2uc1muhr1k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 13 Aug 2019 17:45:54 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 13 Aug 2019 17:45:54 -0700
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 13 Aug 2019 17:45:53 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=BALE0/zoIrmGrZg1iq3sjaaUq8ALlhb767kfRR9/eB8fIkLy9fusWhMasINMOvmkEaZhnpM2LejqgYr4MTJDD5LgiT30mCMp4hW771l+9GzZGDRT2yKafkSP/2n08wkr+GYIk9wsy/W/Jnf7eRth5dr7UJbNM1JyeIp2rFaTm3U0KGzLO/ZYOBEyL81axn8iXxXMhsvBJMRIsJNghEct304HqFG5r+Y6Ut7sstMnmEhKcPeK5s64vAZjr3xNs3U/y8AX+uqLSWq+xkfo2BcoEvqWD+Az5+I2EPRN1m3ziCu0ZfPniHicGvX6ruF95GNdij53fiTZDx7hGmd7UojydQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dIQAAfEz6LOJFPmr08ugSLlsKygRLr/l9SOWYs5ltc0=;
 b=Aa4FWqR5CLFiuTvZNkd6lknYxfuHlqx9mp2UalYnjyxQ+5Mcrjmmx82/B7Lu0PbnAx+xRVXkk2zPltxISjY2gaZRGZxLKQ+Ra4racFf/hyhWrXpE0kP0J2j2IYE4i8WDGVSIwgJCcWIFByHIxhrrgLRQaQ8+NJM27FKkETf9XdhfVaA1C2+TfwAereJHQFP8V5SIvHWSQMq9M1d54KkOHDfvI6E5/B2l46RgtfMcOGWTO8G7el2tx/GYfWV3AlZlpS2nNhU9IyC7wJRH2cLE/ziPhpXNvkAP3G0NPfhLI1uNJRRIBSNPx9BR4OnslIInsnHrJyW672MoNbRQUqGmMA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dIQAAfEz6LOJFPmr08ugSLlsKygRLr/l9SOWYs5ltc0=;
 b=BYZW7aqO53ExcpiAAc7lXXauc9KVJ2XTOXKfKhb7Z1hxZF9vuPPSpAf9Jq1Z/afTIyOZjNH/lFbThWzRAPCCEoeQINuHGgqgzcKZmLPfrBcv8B1N0jDKWvgCYeEAOhb74iRNYGYKpVnZ8Aq+liJJaOWutCXu3fgvPQf3K8m0a7E=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB2458.namprd15.prod.outlook.com (20.176.67.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.21; Wed, 14 Aug 2019 00:45:53 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e%3]) with mapi id 15.20.2157.022; Wed, 14 Aug 2019
 00:45:53 +0000
From: Roman Gushchin <guro@fb.com>
To: Qian Cai <cai@lca.pw>
CC: kbuild test robot <lkp@intel.com>,
        "kbuild-all@01.org"
	<kbuild-all@01.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        Linux Memory Management List
	<linux-mm@kvack.org>
Subject: Re: [rgushchin:fix_vmstats 21/221]
 include/asm-generic/5level-fixup.h:14:18: error: unknown type name 'pgd_t';
 did you mean 'pid_t'?
Thread-Topic: [rgushchin:fix_vmstats 21/221]
 include/asm-generic/5level-fixup.h:14:18: error: unknown type name 'pgd_t';
 did you mean 'pid_t'?
Thread-Index: AQHVUYgEjnCL7xpfoUOwYYOZHtmUpab5KmCAgAClygA=
Date: Wed, 14 Aug 2019 00:45:52 +0000
Message-ID: <20190814004548.GA18813@tower.DHCP.thefacebook.com>
References: <201908131117.SThHOrZO%lkp@intel.com>
 <1565707945.8572.10.camel@lca.pw>
In-Reply-To: <1565707945.8572.10.camel@lca.pw>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR02CA0024.namprd02.prod.outlook.com
 (2603:10b6:300:4b::34) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:4e16]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f771713c-ac13-4842-8766-08d72050c260
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB2458;
x-ms-traffictypediagnostic: DM6PR15MB2458:
x-ms-exchange-purlcount: 2
x-microsoft-antispam-prvs: <DM6PR15MB245875FE7D54B7EC8B4C88DBBEAD0@DM6PR15MB2458.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 01294F875B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(376002)(346002)(39860400002)(366004)(136003)(199004)(189003)(11346002)(64756008)(446003)(52116002)(6486002)(8676002)(386003)(14454004)(46003)(6306002)(6506007)(486006)(6246003)(76176011)(229853002)(4326008)(966005)(53936002)(25786009)(186003)(6916009)(476003)(8936002)(316002)(81156014)(81166006)(2906002)(102836004)(7736002)(305945005)(6116002)(54906003)(71190400001)(66476007)(33656002)(5024004)(478600001)(66556008)(256004)(1076003)(71200400001)(66446008)(6512007)(6436002)(99286004)(9686003)(66946007)(5660300002)(86362001)(41533002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB2458;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: E/ufD4o8F7qo9UWqR7sRwpvkiZo+CgjJbbKrWDNQrkNkfBaiC7FRK0i7Ki5oOSaB5cmHUiS4wc5Pgxd0nFjtnWjtYx3wkpiBmvcVPcokhoXvyEygsaB8vMP2pQwuDSer4fLLwcOxTKxq4xJ338Rgcn/yJw+d6rJXxdQD7XByFhQbZjh1AFC79dhoi1IjOtiKF1bTbTQo7Bi+SgcaYRFI8zT/cUl+dwA/4e3BccBzzjdMyBbeTb+Ke+aWWGcHVcOpzva0yJCCNDTQ/QwKJL0aRzXjC08gh3SWHDy6TuLTT0o0da0zSv7hN9XLl6AkimiDfeKpZ4HgdLOgr4yWVA/3fCcfSRAdCz7jLbPyajitgcQ6jYdjVVXF/gfmHFq1QEIVXaSncjpHN5+aFgog12YXEmR6ROvi5/OYIsnRfbiTO7s=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <B77E64EAC7C43F4CA4567CC68D35D318@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: f771713c-ac13-4842-8766-08d72050c260
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 Aug 2019 00:45:52.9091
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: VBfivuKd6XP6NXKIQOyxREUyafgETWrMGQPkVM9LtQFok+uE+7GKHoJDnCVgLOjh
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB2458
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-13_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=704 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908140004
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 10:52:25AM -0400, Qian Cai wrote:
> On Tue, 2019-08-13 at 11:33 +0800, kbuild test robot wrote:
> > tree:=A0=A0=A0https://github.com/rgushchin/linux.git fix_vmstats
> > head:=A0=A0=A04ec858b5201ae067607e82706b36588631c1b990
> > commit: 938dda772d9d05074bfe1baa0dc18873fbf4fedb [21/221] include/asm-
> > generic/5level-fixup.h: fix variable 'p4d' set but not used
> > config: parisc-c3000_defconfig (attached as .config)
> > compiler: hppa-linux-gcc (GCC) 7.4.0
> > reproduce:
> > =A0=A0=A0=A0=A0=A0=A0=A0wget https://urldefense.proofpoint.com/v2/url?u=
=3Dhttps-3A__raw.githubusercontent.com_intel_lkp-2Dtests_master_sbin_mak&d=
=3DDwIFaQ&c=3D5VD0RTtNlTh3ycd41b3MUw&r=3DjJYgtDM7QT-W-Fz_d29HYQ&m=3DTOir6b4=
wrmTSQpeaAQcpcHZUk9uWkTRUOJaNgbh4m-o&s=3D0IeTTEfMlxl9cDI9YAz2Zji8QaiE8B29qr=
eDUnvID5E&e=3D=20
> > e.cross -O ~/bin/make.cross
> > =A0=A0=A0=A0=A0=A0=A0=A0chmod +x ~/bin/make.cross
> > =A0=A0=A0=A0=A0=A0=A0=A0git checkout 938dda772d9d05074bfe1baa0dc18873fb=
f4fedb
> > =A0=A0=A0=A0=A0=A0=A0=A0# save the attached .config to linux build tree
> > =A0=A0=A0=A0=A0=A0=A0=A0GCC_VERSION=3D7.4.0 make.cross ARCH=3Dparisc=A0
>=20
> I am unable to reproduce this on today's linux-next tree. What's point of
> testing this particular personal git tree/branch?

I'm using it to test my patches before sending them to public mailing lists=
.
It really helps with reducing the number of trivial issues and upstream
iterations as a consequence. And not only trivial...

If there is a way to prevent notifying anyone but me, please, let me know,
I'm happy to do it.

Thanks!

