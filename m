Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFCA2C4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 21:24:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64B80216C8
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 21:24:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="jtmBavlC";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="U95UBX4T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64B80216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D75CE6B0005; Tue, 17 Sep 2019 17:24:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D26866B0006; Tue, 17 Sep 2019 17:24:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEEAD6B0007; Tue, 17 Sep 2019 17:24:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0017.hostedemail.com [216.40.44.17])
	by kanga.kvack.org (Postfix) with ESMTP id 963746B0005
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 17:24:49 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 41AB01A4B0
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:24:49 +0000 (UTC)
X-FDA: 75945692298.09.linen18_4718278310324
X-HE-Tag: linen18_4718278310324
X-Filterd-Recvd-Size: 15430
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:24:48 +0000 (UTC)
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x8HLLsQr005226;
	Tue, 17 Sep 2019 14:24:41 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=v30UJNALX0LM+Snv6eOhIqo8ESHEBprOyg8nqxwNh2Y=;
 b=jtmBavlCYQpbiq9lh+zAlpq71BF4DiGxxX0XBsvBiCAvt0EFCC+Rsh/gy+NXBxq2P64l
 3PmV10ZQKL4drPijl2YEvHwRBHw4r+ynQPjsRye1OiIvW+zm1RNuvTXAKtrXYAtTsGW3
 OTkDrrp4Q3Ldo7A8pZeqUwfP9kYI91a4kYs= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2v2kbmvtae-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 17 Sep 2019 14:24:41 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 17 Sep 2019 14:24:40 -0700
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 17 Sep 2019 14:24:40 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=VqNLMpncnzAGmXfJXWviMbHlpjcmmJufUe5Uk8mWJ19BH3RjP6v2YcB8YzH0UVlKHt3KOTeUCWmVyJZ65D+PkczVg5VriX6IkMCdJW4OuN5YNnE3KUEp0D32SFmGWufvYs8U+piTgRNHRnwdHdgAQICk4Fuw0ksLaDopgemMMO4BuI22+h5mMLtDJg1n1h1dHjz+BcdwlmJciQrGaIxcX0DSI2MpbhvZNg3kXkxbQL+8OP6sSVxkVf1ZR0c7ZTjPXoVgMFAsKE9FpOvhbiMX/QSdeGDQ8MpAHiseN7EcbeY0nzH1xMg+OSY89BVOhW8vfGXqFkf3FWYhfJuZJ1CEIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=v30UJNALX0LM+Snv6eOhIqo8ESHEBprOyg8nqxwNh2Y=;
 b=l1ZqiTh4gh0RPyvhiEXaKuGa6boG+LLprXqfZdh3Xq9sUqcoxfVr8JB3kgDrGzeJ/rgjeyB3bL297z5UM1pwOY3Mvmqo4ip74lzF6KvqE7qk30nPH7u+4tLQMKlx5bNWf/6wBK6ujlkDADNfWs70ZqoXWQhRkj5qq9KhIhSwnSVtJTHsw+yFZoSEaUBzYf3lRtyHZln7NLEl1kmEgd+NMChENmERblkOt67YBpyGqxXHgK6JiBt2pcT4XfV6TmSthXwwI6AvJalTb1BtVsLb7X5DKfJAs+T24/Z0R+P1E8L1Oij38qJkaMeLUeOUj9S9E6xU575VqGchIOYguIF1HQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=v30UJNALX0LM+Snv6eOhIqo8ESHEBprOyg8nqxwNh2Y=;
 b=U95UBX4TnlG/tCly6LFKu/1mI+y/VaERvKXM017nAtXTnLDXaWEkWHWVs8jLrdyULrf0ejTtM+9Vcz1WDqcmZ52sRMgqcyex/ho2Z4q5JeW84cu9fqovHjLctjLyEinYKIHKbQXgqCPx+IbjwQ15IgIUdnDKKW3rqhmiF56VjbQ=
Received: from BYASPR01MB0023.namprd15.prod.outlook.com (20.177.126.93) by
 BYAPR15MB2710.namprd15.prod.outlook.com (20.179.156.96) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2263.23; Tue, 17 Sep 2019 21:24:39 +0000
Received: from BYASPR01MB0023.namprd15.prod.outlook.com
 ([fe80::e448:b543:1171:8961]) by BYASPR01MB0023.namprd15.prod.outlook.com
 ([fe80::e448:b543:1171:8961%5]) with mapi id 15.20.2263.023; Tue, 17 Sep 2019
 21:24:39 +0000
From: Roman Gushchin <guro@fb.com>
To: Waiman Long <longman@redhat.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Michal Hocko
	<mhocko@kernel.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>, Shakeel Butt <shakeelb@google.com>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>
Subject: Re: [PATCH RFC 00/14] The new slab memory controller
Thread-Topic: [PATCH RFC 00/14] The new slab memory controller
Thread-Index: AQHVZDNwmo4dH7vFVEWbwj6k0KVokacwWXuAgAAatwA=
Date: Tue, 17 Sep 2019 21:24:38 +0000
Message-ID: <20190917212434.GA14586@castle.DHCP.thefacebook.com>
References: <20190905214553.1643060-1-guro@fb.com>
 <f63d7f69-83e2-22bc-c235-e887ea03f0c8@redhat.com>
In-Reply-To: <f63d7f69-83e2-22bc-c235-e887ea03f0c8@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR04CA0058.namprd04.prod.outlook.com
 (2603:10b6:300:6c::20) To BYASPR01MB0023.namprd15.prod.outlook.com
 (2603:10b6:a03:72::29)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::fb2c]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 099f689b-b5f6-4969-9d3d-08d73bb5722f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600167)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB2710;
x-ms-traffictypediagnostic: BYAPR15MB2710:
x-ms-exchange-purlcount: 3
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <BYAPR15MB2710270BE3CC33AFBBD265D0BE8F0@BYAPR15MB2710.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4502;
x-forefront-prvs: 01630974C0
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(39860400002)(366004)(376002)(396003)(136003)(55674003)(189003)(199004)(8676002)(6246003)(1076003)(6116002)(476003)(33656002)(66446008)(8936002)(478600001)(14454004)(4326008)(6512007)(25786009)(81156014)(7736002)(6306002)(966005)(305945005)(6436002)(66556008)(6486002)(6916009)(2906002)(229853002)(99286004)(86362001)(81166006)(9686003)(66946007)(71190400001)(64756008)(71200400001)(66476007)(186003)(102836004)(53546011)(76176011)(52116002)(6506007)(46003)(446003)(386003)(11346002)(5660300002)(256004)(486006)(316002)(54906003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2710;H:BYASPR01MB0023.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: G1wENpWGDjiZVN8uJUDoXQoR6MfJcNJ4sJ9Efp53wKM8A2ARQoJtHE6IZar3AAxY80UQqp74kwEjhDfmwEQKgr983RlJXGIg5MlHc6yTHjn2lJ9nZ/7SQKdr5QEMuCP3uQxumrJSBxRuL/oJrFaQuVn+vn6XckwODLcvusABcG192ZXNnyX1NaPxPNRl1U6welavfHQ0oj8BmRU+i07Ym9uIYDFis2xpgbxEyPHs+vNNS+r5FsSX1jGoPuBfZ8GSZy0BgKT5Jy57MmaYGk1FnOoYovIxILWtdW0/2oKqvsgeCEKV0Ih1ziI/7NZaoH0RrtxIA1m/p16K8z8byKIhpGfhEiYkZYQybNQff4Ri3wpcdQdIJFIhxE6fXBz9zaRmh2Zxx6UsXihbeXAxVc7es9AwNhwFf6VfGgV3rEUyCr8=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <EB8AD7FB4E246C4AB65B868EC7B1F083@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 099f689b-b5f6-4969-9d3d-08d73bb5722f
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Sep 2019 21:24:38.9115
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 4UT4zqUaE7QXbf5OV+ga5LnRk3WmGGbJ4/XuxocKqtL7sa9q2sDhchV/7LtzyxIC
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2710
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-17_11:2019-09-17,2019-09-17 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 mlxlogscore=999
 malwarescore=0 adultscore=0 spamscore=0 mlxscore=0 bulkscore=0
 clxscore=1015 suspectscore=0 lowpriorityscore=0 impostorscore=0
 priorityscore=1501 phishscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.12.0-1908290000 definitions=main-1909170198
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 03:48:57PM -0400, Waiman Long wrote:
> On 9/5/19 5:45 PM, Roman Gushchin wrote:
> > The existing slab memory controller is based on the idea of replicating
> > slab allocator internals for each memory cgroup. This approach promises
> > a low memory overhead (one pointer per page), and isn't adding too much
> > code on hot allocation and release paths. But is has a very serious fla=
w:
> > it leads to a low slab utilization.
> >
> > Using a drgn* script I've got an estimation of slab utilization on
> > a number of machines running different production workloads. In most
> > cases it was between 45% and 65%, and the best number I've seen was
> > around 85%. Turning kmem accounting off brings it to high 90s. Also
> > it brings back 30-50% of slab memory. It means that the real price
> > of the existing slab memory controller is way bigger than a pointer
> > per page.
> >
> > The real reason why the existing design leads to a low slab utilization
> > is simple: slab pages are used exclusively by one memory cgroup.
> > If there are only few allocations of certain size made by a cgroup,
> > or if some active objects (e.g. dentries) are left after the cgroup is
> > deleted, or the cgroup contains a single-threaded application which is
> > barely allocating any kernel objects, but does it every time on a new C=
PU:
> > in all these cases the resulting slab utilization is very low.
> > If kmem accounting is off, the kernel is able to use free space
> > on slab pages for other allocations.
> >
> > Arguably it wasn't an issue back to days when the kmem controller was
> > introduced and was an opt-in feature, which had to be turned on
> > individually for each memory cgroup. But now it's turned on by default
> > on both cgroup v1 and v2. And modern systemd-based systems tend to
> > create a large number of cgroups.
> >
> > This patchset provides a new implementation of the slab memory controll=
er,
> > which aims to reach a much better slab utilization by sharing slab page=
s
> > between multiple memory cgroups. Below is the short description of the =
new
> > design (more details in commit messages).
> >
> > Accounting is performed per-object instead of per-page. Slab-related
> > vmstat counters are converted to bytes. Charging is performed on page-b=
asis,
> > with rounding up and remembering leftovers.
> >
> > Memcg ownership data is stored in a per-slab-page vector: for each slab=
 page
> > a vector of corresponding size is allocated. To keep slab memory repare=
nting
> > working, instead of saving a pointer to the memory cgroup directly an
> > intermediate object is used. It's simply a pointer to a memcg (which ca=
n be
> > easily changed to the parent) with a built-in reference counter. This s=
cheme
> > allows to reparent all allocated objects without walking them over and =
changing
> > memcg pointer to the parent.
> >
> > Instead of creating an individual set of kmem_caches for each memory cg=
roup,
> > two global sets are used: the root set for non-accounted and root-cgrou=
p
> > allocations and the second set for all other allocations. This allows t=
o
> > simplify the lifetime management of individual kmem_caches: they are de=
stroyed
> > with root counterparts. It allows to remove a good amount of code and m=
ake
> > things generally simpler.
> >
> > The patchset contains a couple of semi-independent parts, which can fin=
d their
> > usage outside of the slab memory controller too:
> > 1) subpage charging API, which can be used in the future for accounting=
 of
> >    other non-page-sized objects, e.g. percpu allocations.
> > 2) mem_cgroup_ptr API (refcounted pointers to a memcg, can be reused
> >    for the efficient reparenting of other objects, e.g. pagecache.
> >
> > The patchset has been tested on a number of different workloads in our
> > production. In all cases, it saved hefty amounts of memory:
> > 1) web frontend, 650-700 Mb, ~42% of slab memory
> > 2) database cache, 750-800 Mb, ~35% of slab memory
> > 3) dns server, 700 Mb, ~36% of slab memory
> >
> > So far I haven't found any regression on all tested workloads, but
> > potential CPU regression caused by more precise accounting is a concern=
.
> >
> > Obviously the amount of saved memory depend on the number of memory cgr=
oups,
> > uptime and specific workloads, but overall it feels like the new contro=
ller
> > saves 30-40% of slab memory, sometimes more. Additionally, it should le=
ad
> > to a lower memory fragmentation, just because of a smaller number of
> > non-movable pages and also because there is no more need to move all
> > slab objects to a new set of pages when a workload is restarted in a ne=
w
> > memory cgroup.
> >
> > * https://github.com/osandov/drgn
> >
> >
> > Roman Gushchin (14):
> >   mm: memcg: subpage charging API
> >   mm: memcg: introduce mem_cgroup_ptr
> >   mm: vmstat: use s32 for vm_node_stat_diff in struct per_cpu_nodestat
> >   mm: vmstat: convert slab vmstat counter to bytes
> >   mm: memcg/slab: allocate space for memcg ownership data for non-root
> >     slabs
> >   mm: slub: implement SLUB version of obj_to_index()
> >   mm: memcg/slab: save memcg ownership data for non-root slab objects
> >   mm: memcg: move memcg_kmem_bypass() to memcontrol.h
> >   mm: memcg: introduce __mod_lruvec_memcg_state()
> >   mm: memcg/slab: charge individual slab objects instead of pages
> >   mm: memcg: move get_mem_cgroup_from_current() to memcontrol.h
> >   mm: memcg/slab: replace memcg_from_slab_page() with
> >     memcg_from_slab_obj()
> >   mm: memcg/slab: use one set of kmem_caches for all memory cgroups
> >   mm: slab: remove redundant check in memcg_accumulate_slabinfo()
> >
> >  drivers/base/node.c        |  11 +-
> >  fs/proc/meminfo.c          |   4 +-
> >  include/linux/memcontrol.h | 102 ++++++++-
> >  include/linux/mm_types.h   |   5 +-
> >  include/linux/mmzone.h     |  12 +-
> >  include/linux/slab.h       |   3 +-
> >  include/linux/slub_def.h   |   9 +
> >  include/linux/vmstat.h     |   8 +
> >  kernel/power/snapshot.c    |   2 +-
> >  mm/list_lru.c              |  12 +-
> >  mm/memcontrol.c            | 431 +++++++++++++++++++++--------------
> >  mm/oom_kill.c              |   2 +-
> >  mm/page_alloc.c            |   8 +-
> >  mm/slab.c                  |  37 ++-
> >  mm/slab.h                  | 300 +++++++++++++------------
> >  mm/slab_common.c           | 449 ++++---------------------------------
> >  mm/slob.c                  |  12 +-
> >  mm/slub.c                  |  63 ++----
> >  mm/vmscan.c                |   3 +-
> >  mm/vmstat.c                |  38 +++-
> >  mm/workingset.c            |   6 +-
> >  21 files changed, 683 insertions(+), 834 deletions(-)
> >
> I can only see the first 9 patches. Patches 10-14 are not there.

Hm, strange. I'll rebase the patchset on top of the current mm tree and res=
end.

In the meantime you can find the original patchset here:
  https://github.com/rgushchin/linux/tree/new_slab.rfc
or on top of the 5.3 release, which might be better for testing here:
  https://github.com/rgushchin/linux/tree/new_slab.rfc.v5.3

Thanks!

