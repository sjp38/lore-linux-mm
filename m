Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96E0BC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 21:58:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3717A2133F
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 21:58:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="nDc52NDQ";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="EmqEA843"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3717A2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAD1E6B0005; Wed, 14 Aug 2019 17:58:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5D546B0007; Wed, 14 Aug 2019 17:58:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C261F6B0008; Wed, 14 Aug 2019 17:58:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0241.hostedemail.com [216.40.44.241])
	by kanga.kvack.org (Postfix) with ESMTP id A189A6B0005
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:58:27 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 537DB180AD7C1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 21:58:27 +0000 (UTC)
X-FDA: 75822397854.11.wing45_83efd10c7ed47
X-HE-Tag: wing45_83efd10c7ed47
X-Filterd-Recvd-Size: 11579
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 21:58:26 +0000 (UTC)
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7ELsmwQ025219;
	Wed, 14 Aug 2019 14:58:23 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=1kkyzVk2jHlfVRKXiUBTb3FpFJi8KTgZoFWEasjroUU=;
 b=nDc52NDQWEjwspnIEZpY4WKbsZLPa035EoIkKd108TzrpqAWlMhUHEDg/kc1nuAwiE/z
 agMQHiov5GlCatim2LK9idj3sw16+Y7g2STur83KRNYRzqMiZ8jyKJEG85FHisIkjJun
 gCJUJqfIilCBDkrGKOA4t08a6A2diQtbENE= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ucrp2gfqb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 14 Aug 2019 14:58:23 -0700
Received: from prn-hub04.TheFacebook.com (2620:10d:c081:35::128) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 14 Aug 2019 14:54:14 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.28) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 14 Aug 2019 14:54:14 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=WYQnYrjGJ6nVMTkVEpc+uDGE7djIP+huq5F8Ij2arRwwsUzgHDEDEA7LLN7EK9CmCRWT+mfXPr94NJPfxmY1YRTp/yhcUCE3ixqeTdpbZWi6IADZ2oBMXmgcBOJ1wQgyyH0q56ei0RmOikf7LVJRhX2ozs7mydrMf/QiEWBE6v3+yMePWzbG9x3iXiFGg46J205EXfhtfb7jvZiWOFrRPKqBI2c3m3Tb6/kDvXwQDClQhA6lnjpt6LrecyKSwXmckhbQTS1ZaF8gr+ffe3y15f8NxGze8guBfASSDyJ+ZXmVmtojvbmmxGwXTXUU3i5bXUPbUrNYNA5UVAav9aUMUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1kkyzVk2jHlfVRKXiUBTb3FpFJi8KTgZoFWEasjroUU=;
 b=bEcXPBp+843hwLpaXeXbjirnTSesTp8GyyOR3N2Esrk7uUyp6QenLQtUQAsR7r9sQmB5vhXu8UKjkrO9/85AbiVMjjMHwPcpr5avjCckudIfeGcESeJ5819jl5lRQXUxM2eHyvAyi1UW2AXILNW5Htxup33lBE0Xw5LGozC3oSIAQVsmlX2RStNlhywqPmoAOeF4begugm22kFB0HU25xAC0zNkpEGTx+KlMAEMNuamjQhjn4sx2MK0Rl6Ix8ZAT60qs6MmO1ypcfNO/kGNkQQ+LQf5CoEwaohuB3ZsGuzof1LB6wSzcFvjHkEr+dheMLLuIm1W5YnX6q/118HQXiA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1kkyzVk2jHlfVRKXiUBTb3FpFJi8KTgZoFWEasjroUU=;
 b=EmqEA843TT1ISqQY/RaaIL/2crr6G6rPWtHlW0KqKJ09DI2N4qgEXU6WfNmuTB2PNkRmkixLXmHzh+G943yltB3k9NWga/evHkgzTBDti/VWZm//gUw3rtLNxWRpWOa7bQTklvIW/d4WpE9qQcVptPSSztR0lKXGaAKxx+UGwNg=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB3033.namprd15.prod.outlook.com (20.179.16.27) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.14; Wed, 14 Aug 2019 21:54:13 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e%3]) with mapi id 15.20.2157.022; Wed, 14 Aug 2019
 21:54:13 +0000
From: Roman Gushchin <guro@fb.com>
To: Michal Hocko <mhocko@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>
Subject: Re: [PATCH 2/2] mm: memcontrol: flush percpu slab vmstats on kmem
 offlining
Thread-Topic: [PATCH 2/2] mm: memcontrol: flush percpu slab vmstats on kmem
 offlining
Thread-Index: AQHVUV1hvAVvSRmwcUimEiQ4N3nZcqb6hT0AgACtoAA=
Date: Wed, 14 Aug 2019 21:54:12 +0000
Message-ID: <20190814215408.GA5584@tower.dhcp.thefacebook.com>
References: <20190812222911.2364802-1-guro@fb.com>
 <20190812222911.2364802-3-guro@fb.com>
 <20190814113242.GV17933@dhcp22.suse.cz>
In-Reply-To: <20190814113242.GV17933@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR0201CA0058.namprd02.prod.outlook.com
 (2603:10b6:301:73::35) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:42e9]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a5e01cea-861c-478a-f6e6-08d72101f183
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DM6PR15MB3033;
x-ms-traffictypediagnostic: DM6PR15MB3033:
x-microsoft-antispam-prvs: <DM6PR15MB303339F1DA044EA8727197A4BEAD0@DM6PR15MB3033.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1091;
x-forefront-prvs: 01294F875B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(39860400002)(136003)(346002)(366004)(396003)(54534003)(189003)(199004)(53936002)(486006)(81166006)(229853002)(8676002)(446003)(7736002)(54906003)(46003)(66446008)(66946007)(14444005)(476003)(2906002)(305945005)(6512007)(11346002)(86362001)(256004)(25786009)(9686003)(8936002)(64756008)(66476007)(66556008)(81156014)(316002)(99286004)(6916009)(6116002)(6506007)(386003)(5660300002)(478600001)(71190400001)(33656002)(71200400001)(102836004)(6436002)(186003)(6246003)(76176011)(4326008)(1076003)(6486002)(14454004)(52116002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB3033;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Kgzyti8swt3PssWZ3EEYvoBVKMeVgE4871TcwmDRcyTahZFUxTyOlB+/PcqXRTH7OkbCa8Sf/xlDjNY0ydM2Bs0nIiEMzPvyrKRvXXMaaMMpvYa7Uf/7OCjdS2bnX+7Slc6aQu2Lq0VUlrUZnw6jePK8FZmOxIMIzK3NrccSB5yx1ec7lXv9ibGE+h2tGDyF+I/31owQhXlTQWd7NWqkgWqnzIioVkrbw1H42TJr3YiD0fBG29qPQK49sgBj+YZuRf/LUnYZvOg7LFVcKSXM99VcsdDCfd6uIgptz5cv0t9zyW/FeQyJobPpWoG+3b+JS1O5YV5uu6Du/uo90OyowKo5zqZN6sbjnnTX37CrU+Uhec4sPAFgF1sD+52phGTNBt1Y5VAzBwWsNf1qPTsl+HtkUPtzVOvH53k2D64kVJY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E25D2105252C0942B543BDF57088D813@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: a5e01cea-861c-478a-f6e6-08d72101f183
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 Aug 2019 21:54:12.8964
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: qlWJgczNVsF+tOzWjAM138j2cuLR7xBvXIc1NlcewpR/U/xgyF4SuMGf45+Ke1mz
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB3033
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=776 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908140199
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 01:32:42PM +0200, Michal Hocko wrote:
> On Mon 12-08-19 15:29:11, Roman Gushchin wrote:
> > I've noticed that the "slab" value in memory.stat is sometimes 0,
> > even if some children memory cgroups have a non-zero "slab" value.
> > The following investigation showed that this is the result
> > of the kmem_cache reparenting in combination with the per-cpu
> > batching of slab vmstats.
> >=20
> > At the offlining some vmstat value may leave in the percpu cache,
> > not being propagated upwards by the cgroup hierarchy. It means
> > that stats on ancestor levels are lower than actual. Later when
> > slab pages are released, the precise number of pages is substracted
> > on the parent level, making the value negative. We don't show negative
> > values, 0 is printed instead.
>=20
> So the difference with other counters is that slab ones are reparented
> and that's why we have treat them specially? I guess that is what the
> comment in the code suggest but being explicit in the changelog would be
> nice.

Right. And I believe the list can be extended further. Objects which
are often outliving the origin memory cgroup (e.g. pagecache pages)
are pinning dead cgroups, so it will be cool to reparent them all.

>=20
> [...]
> > -static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg)
> > +static void memcg_flush_percpu_vmstats(struct mem_cgroup *memcg, bool =
slab_only)
> >  {
> >  	unsigned long stat[MEMCG_NR_STAT];
> >  	struct mem_cgroup *mi;
> >  	int node, cpu, i;
> > +	int min_idx, max_idx;
> > =20
> > -	for (i =3D 0; i < MEMCG_NR_STAT; i++)
> > +	if (slab_only) {
> > +		min_idx =3D NR_SLAB_RECLAIMABLE;
> > +		max_idx =3D NR_SLAB_UNRECLAIMABLE;
> > +	} else {
> > +		min_idx =3D 0;
> > +		max_idx =3D MEMCG_NR_STAT;
> > +	}
>=20
> This is just ugly has hell! I really detest how this implicitly makes
> counters value very special without any note in the node_stat_item
> definition. Is it such a big deal to have a per counter flush and do
> the loop over all counters resp. specific counters around it so much
> worse? This should be really a slow path to safe few instructions or
> cache misses, no?

I believe that it is a big deal, because it's
NR_VMSTAT_ITEMS * all memory cgroups * online cpus * numa nodes.
If the goal is to merge it with cpu hotplug code, I'd think about passing
cpumask to it, and do the opposite. Also I'm not sure I understand
why reordering loops will make it less ugly.

But you're right, a comment nearby NR_SLAB_(UN)RECLAIMABLE definition
is totaly worth it. How about something like:

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8b5f758942a2..231bcbe5dcc6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -215,8 +215,9 @@ enum node_stat_item {
        NR_INACTIVE_FILE,       /*  "     "     "   "       "         */
        NR_ACTIVE_FILE,         /*  "     "     "   "       "         */
        NR_UNEVICTABLE,         /*  "     "     "   "       "         */
-       NR_SLAB_RECLAIMABLE,
-       NR_SLAB_UNRECLAIMABLE,
+       NR_SLAB_RECLAIMABLE,    /* Please, do not reorder this item */
+       NR_SLAB_UNRECLAIMABLE,  /* and this one without looking at
+                                * memcg_flush_percpu_vmstats() first. */
        NR_ISOLATED_ANON,       /* Temporary isolated pages from anon lru *=
/
        NR_ISOLATED_FILE,       /* Temporary isolated pages from file lru *=
/
        WORKINGSET_NODES,


--

Thanks!

