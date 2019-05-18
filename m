Return-Path: <SRS0=dvGr=TS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 487B8C04AB4
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 00:02:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA30D216C4
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 00:02:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="SWsTNEXN";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="FBCEySaf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA30D216C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 617226B0006; Fri, 17 May 2019 20:02:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C64A6B0008; Fri, 17 May 2019 20:02:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 441506B000A; Fri, 17 May 2019 20:02:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 235E26B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 20:02:24 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id n190so7914281ywf.4
        for <linux-mm@kvack.org>; Fri, 17 May 2019 17:02:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=0yJFAjjXi07wEJ4fA+FNNXJlqovIbNk2gdEErTE86u4=;
        b=FxuZO/qAwjDcMOu++NjQFTNV2fRB47EgKl6He06N6mCiD2RtHgv8pMme8/buQZ1Mm4
         H1gH8cZNLlAMOdDZ66TetiyXhZH/q8qlmY0hFCgIuj09eREhYdR2dPMjwtugBxkPVA8T
         DM7hsB0pKru4KH0ADhACg9MJ8YYWFqvGx6XBg4YY4DGQpnkN8t0nRhKqViZIlP4WBw4e
         yY+jC5mcDhyGvfwHBeO7NPe1XteSthPTiq9l0cU3ZKzM/jGD50RVpI88q+3P7OfqeGZi
         3ud8HcYHDLcIjiDNRBFfgKIes0j2drdUlzEAC0PSVdiXAwkC7kJe7ljiYIRxqhca0Xxc
         jXvg==
X-Gm-Message-State: APjAAAVNfCvFV8nPdIQCpp3IeuNV6+Pg1RBKe94OCwBTXSZAjhwn6/4+
	w3J6l6md/XX8A+z98UZn3/WR0o+WIVdXhCvsDjSQVjMqgdaPiSAN6NW4Nu9GMLcA9XsrK9UJq6Z
	LVkJcraLeeZM9KGjGkMNw8Aq+2LFfAwpcm0SHpJQ38LKfnj6BZG3wC7rg58rNK6faYQ==
X-Received: by 2002:a81:66c6:: with SMTP id a189mr11065021ywc.189.1558137743793;
        Fri, 17 May 2019 17:02:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeQ/nNPEabSjX97+q+JDm5ETZViI3FhLcfN7bPudF71IsTMtgSoDY32QPl91ia3ibc98Bq
X-Received: by 2002:a81:66c6:: with SMTP id a189mr11064971ywc.189.1558137742953;
        Fri, 17 May 2019 17:02:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558137742; cv=none;
        d=google.com; s=arc-20160816;
        b=J5t8W0WwVKMR9PWQKxp3VtODUefAYleDuLcV6pXfHlHe+ky93Ohcq1l0DGMr3020Kj
         Unq6ZPP0kgirRyRkEk1pmEHEpnrD5H1TV/4i19H0HOkHF+g6SZuXCXRyxbBRRDIPbiRL
         oxJnHyQvikTS5X4wkB6ntwUjQS7/pfoUu0SnEHW60aCAl5GiK9CyK5ukBZALA3izUB0q
         Wp+M0tx/1BslUHPWBYAeL/XuJRtMP3M8VVUP+bHHqn98H2X0I+rIXkxTKMUTuS3q/jPH
         jOFsIjn30mwytyTTsQDwWHZg7TShlkGRJHVzioSErgHRGLpTnJVZ3TnEGZ0gbPNWDltT
         ulew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=0yJFAjjXi07wEJ4fA+FNNXJlqovIbNk2gdEErTE86u4=;
        b=J8oKZHsN/gw3IKUcv0NJQn02kXyu9wVIPRAVX9PTWa/F5ur3KFznos1DG0ICbsF3yV
         Sz9tnY83rB37L+/X9x6G0h7YIgJAR1fl27S6adEpMOTiuspr9WxSpue1rTE1jaJtwNbw
         i77GYV78IQ3QTZfaeASMf79lpwgPXm3czji6zZBQRJQ7PwRuxP+VQmuHZ+T42tdQ9YPq
         6103+l0A22oQRJ1YM6z6+rqqxL75ZY01aS1Hyg2cZiHVUaxy2uzWN1TM2zkXv62LEHu6
         42GauQFFBjhVQ2JYZuprJJ2RTFdDHNdBKq1k/qDt2eapG35NiZhO2XnywV5dkIbnOf08
         wIXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=SWsTNEXN;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=FBCEySaf;
       spf=pass (google.com: domain of prvs=0041bc8e50=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0041bc8e50=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p206si2711277yba.201.2019.05.17.17.02.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 17:02:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0041bc8e50=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=SWsTNEXN;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=FBCEySaf;
       spf=pass (google.com: domain of prvs=0041bc8e50=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0041bc8e50=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4HNr8Tw029763;
	Fri, 17 May 2019 17:02:14 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=0yJFAjjXi07wEJ4fA+FNNXJlqovIbNk2gdEErTE86u4=;
 b=SWsTNEXN5oyVqNvQm3KKYQfVGfUKXSMXT00I68bCuf7OCvF+vasbBtRLP0DRJkeJUeSQ
 XjZz9A1q0wFTPk024WaoWfrgHkR4TnR3CvlPz0tJsgmbyVExmMONqV6JaBtaD7f87prw
 KCj/zcf4sItlTCTFRpwv5bbOL+sanw4uj8U= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sj0k71byq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Fri, 17 May 2019 17:02:14 -0700
Received: from ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) by
 ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 17 May 2019 17:02:12 -0700
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Fri, 17 May 2019 17:02:12 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0yJFAjjXi07wEJ4fA+FNNXJlqovIbNk2gdEErTE86u4=;
 b=FBCEySafzGBYQ6hINRqfbreX61Sxe/OUyMC8oKUXJZ1Jvk0Fmw25zaqWcWGKjZvVdZGWOiGQaPoybgpgU7M3ZzT0mTPqa6gcPle5x7YlmhD2YFDMrAgiCU4+YmVnwzt+aadp0u/Niv2Z90yFDgrvbbNPLoCCQLtGD2oxc1xRnPM=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2440.namprd15.prod.outlook.com (52.135.198.156) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1878.25; Sat, 18 May 2019 00:02:10 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1900.010; Sat, 18 May 2019
 00:02:10 +0000
From: Roman Gushchin <guro@fb.com>
To: Shakeel Butt <shakeelb@google.com>
CC: Johannes Weiner <hannes@cmpxchg.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        Michal Hocko <mhocko@kernel.org>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        Chris Down <chris@chrisdown.name>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "cgroups@vger.kernel.org"
	<cgroups@vger.kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm, memcg: introduce memory.events.local
Thread-Topic: [PATCH] mm, memcg: introduce memory.events.local
Thread-Index: AQHVDQs6vMYC7L0Mr0mdinpaIfY8mqZv/8SA
Date: Sat, 18 May 2019 00:02:10 +0000
Message-ID: <20190518000203.GA13413@tower.DHCP.thefacebook.com>
References: <20190517234909.175734-1-shakeelb@google.com>
In-Reply-To: <20190517234909.175734-1-shakeelb@google.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR21CA0034.namprd21.prod.outlook.com
 (2603:10b6:300:129::20) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::b22a]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6925400e-b708-4265-226d-08d6db2412e1
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB2440;
x-ms-traffictypediagnostic: BYAPR15MB2440:
x-microsoft-antispam-prvs: <BYAPR15MB244099E10F0E1ADCED94F5E5BE040@BYAPR15MB2440.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0041D46242
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39850400004)(396003)(376002)(136003)(346002)(366004)(189003)(199004)(8676002)(229853002)(478600001)(33656002)(102836004)(53936002)(81156014)(76176011)(68736007)(52116002)(6506007)(99286004)(386003)(81166006)(66446008)(8936002)(86362001)(46003)(64756008)(66476007)(66556008)(1076003)(71190400001)(316002)(4326008)(446003)(476003)(66946007)(25786009)(5660300002)(73956011)(186003)(2906002)(6246003)(256004)(6116002)(6916009)(6512007)(14454004)(11346002)(486006)(71200400001)(9686003)(14444005)(6486002)(54906003)(6436002)(305945005)(7736002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2440;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: pC79anZDT7JnqgjfyR0A8BP7iQqBaTQ9/Yt3OQHSozW3OLYESKpCDMTj1+QyrJel0Tt+gvNlDLgyaGZ/6HxxNwXr/iHwqDN6nVluXVHiMZ7OnCVnWSN0ijv91oJBSboI1pzAAcLnU6FL9r8EAEHB+aYyNEjXn2etNUHiRLqUTQQS/J69muz1M9U0ibPiGEp6kGlorhj5xGzDunBLSMrkdgOgz5+ixLy7kNQj93yWZseXorkyW6dJY99z9zfB67ktB34XAUol3OZ0imfHmhPCi7rp2afqLxZMgvjLAIPCUIvDcElsaRi0Xlt+qGaZYAPysPiqZMHX2xlle/DWHldHwSTciBgs7d9hIrb9gXjzKlVutUGjR0MvUB/ISfPENCZI/htievQxPeonEM8z3T/9JrfuulnLL9iKQlTXyxS1Nfg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A243B38FB7E72E45A0F5595CB9DE1504@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 6925400e-b708-4265-226d-08d6db2412e1
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 May 2019 00:02:10.5551
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2440
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-17_15:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905170144
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 04:49:09PM -0700, Shakeel Butt wrote:
> The memory controller in cgroup v2 exposes memory.events file for each
> memcg which shows the number of times events like low, high, max, oom
> and oom_kill have happened for the whole tree rooted at that memcg.
> Users can also poll or register notification to monitor the changes in
> that file. Any event at any level of the tree rooted at memcg will
> notify all the listeners along the path till root_mem_cgroup. There are
> existing users which depend on this behavior.
>=20
> However there are users which are only interested in the events
> happening at a specific level of the memcg tree and not in the events in
> the underlying tree rooted at that memcg. One such use-case is a
> centralized resource monitor which can dynamically adjust the limits of
> the jobs running on a system. The jobs can create their sub-hierarchy
> for their own sub-tasks. The centralized monitor is only interested in
> the events at the top level memcgs of the jobs as it can then act and
> adjust the limits of the jobs. Using the current memory.events for such
> centralized monitor is very inconvenient. The monitor will keep
> receiving events which it is not interested and to find if the received
> event is interesting, it has to read memory.event files of the next
> level and compare it with the top level one. So, let's introduce
> memory.events.local to the memcg which shows and notify for the events
> at the memcg level.
>=20
> Now, does memory.stat and memory.pressure need their local versions.
> IMHO no due to the no internal process contraint of the cgroup v2. The
> memory.stat file of the top level memcg of a job shows the stats and
> vmevents of the whole tree. The local stats or vmevents of the top level
> memcg will only change if there is a process running in that memcg but
> v2 does not allow that. Similarly for memory.pressure there will not be
> any process in the internal nodes and thus no chance of local pressure.

Hi Shakeel!

Local counters make total sense to me. And I think they will very useful
in certain cases. Thank you for working on it!

>=20
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  include/linux/memcontrol.h |  7 ++++++-
>  mm/memcontrol.c            | 25 +++++++++++++++++++++++++
>  2 files changed, 31 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 36bdfe8e5965..de77405eec46 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -239,8 +239,9 @@ struct mem_cgroup {
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
> =20
> -	/* memory.events */
> +	/* memory.events and memory.events.local */
>  	struct cgroup_file events_file;
> +	struct cgroup_file events_local_file;
> =20
>  	/* handle for "memory.swap.events" */
>  	struct cgroup_file swap_events_file;
> @@ -286,6 +287,7 @@ struct mem_cgroup {
>  	atomic_long_t		vmevents_local[NR_VM_EVENT_ITEMS];
> =20
>  	atomic_long_t		memory_events[MEMCG_NR_MEMORY_EVENTS];
> +	atomic_long_t		memory_events_local[MEMCG_NR_MEMORY_EVENTS];
> =20
>  	unsigned long		socket_pressure;
> =20
> @@ -761,6 +763,9 @@ static inline void count_memcg_event_mm(struct mm_str=
uct *mm,
>  static inline void memcg_memory_event(struct mem_cgroup *memcg,
>  				      enum memcg_memory_event event)
>  {
> +	atomic_long_inc(&memcg->memory_events_local[event]);
> +	cgroup_file_notify(&memcg->events_local_file);
> +
>  	do {
>  		atomic_long_inc(&memcg->memory_events[event]);
>  		cgroup_file_notify(&memcg->events_file);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2713b45ec3f0..a746127012fa 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5648,6 +5648,25 @@ static int memory_events_show(struct seq_file *m, =
void *v)
>  	return 0;
>  }
> =20
> +static int memory_events_local_show(struct seq_file *m, void *v)
> +{
> +	struct mem_cgroup *memcg =3D mem_cgroup_from_seq(m);
> +
> +	seq_printf(m, "low %lu\n",
> +		   atomic_long_read(&memcg->memory_events_local[MEMCG_LOW]));
> +	seq_printf(m, "high %lu\n",
> +		   atomic_long_read(&memcg->memory_events_local[MEMCG_HIGH]));
> +	seq_printf(m, "max %lu\n",
> +		   atomic_long_read(&memcg->memory_events_local[MEMCG_MAX]));
> +	seq_printf(m, "oom %lu\n",
> +		   atomic_long_read(&memcg->memory_events_local[MEMCG_OOM]));
> +	seq_printf(m, "oom_kill %lu\n",
> +		   atomic_long_read(&memcg->memory_events_local[MEMCG_OOM_KILL])
> +		   );

Can you, please, merge this part with the non-local version? Then we'll hav=
e
a guarantee that the format is the same.

A helper like this can be used, for example:
    static void __memory_events_show(struct seq_file *m, atomic_long_t *eve=
nts)
    {
    	seq_printf(...);
    }

Other than that looks good to me.

Thanks!

