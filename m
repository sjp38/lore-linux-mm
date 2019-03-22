Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EED0C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 18:15:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE3E8218FE
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 18:15:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Z0V8pFOB";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="dklixkX3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE3E8218FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D2326B0005; Fri, 22 Mar 2019 14:15:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 582BF6B0006; Fri, 22 Mar 2019 14:15:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4720E6B0007; Fri, 22 Mar 2019 14:15:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 274AC6B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 14:15:32 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id b199so2397301iof.14
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:15:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=O0a8CzUlSMwq0DVSSZK9H7Q3Yu1lpslNBR2v6oFPAks=;
        b=GM2lAfoED31fws0gMhvjG6xck5bysAJ4KR0rOh7muJyN1LEeKZK3BnxFGVjJmOaJJX
         BU96GaKmuas8qDYmuC44VwTp02ze8pi6KfaFQVDI2/ZamrgMQjdoYyQkyjasd347dQwV
         dhIBIL92LH/Kf35Vrvazd8TQC76s8rClkxjfbnf8ATPT8CdT7vpkGSSdoaRK6Ghpr31M
         DjOgOZ5OvzBjjuZXrzULffUYhp+f7OjTDvWVCs8jg4Inzx0uBWvTQebFdy4skV1mI/Qa
         qWpB6xdJQt76ojCg3DWAJAjhUU0r/YLpi3612xW0fsrDb4apQulmjsfTsyCrOq1wUsC2
         NPqg==
X-Gm-Message-State: APjAAAUGBHAju4PfPXx6f9jQ4xn7I9hTL61forqfVk12HtqSatjp80yE
	fzo5asI5uSyEvczxByyBMyOh8tBvAKrlBOASWef2zSGEUG2uUgp4F8mdRTf+iVI62hl3T1CDvAr
	ZqpoucSnsjtFQmTdmOqyJDd2nFd+UmmcBlLRhzOUtueRlyeu4IkGGOFvUdU5ckJ7BtQ==
X-Received: by 2002:a02:c045:: with SMTP id u5mr8426462jam.95.1553278531913;
        Fri, 22 Mar 2019 11:15:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYoWGasYnR3RLe24n37O4Awp6Yvtx950ew918PGnLm+u/6++uqR/gJ8uLWOKzR4/PjTO79
X-Received: by 2002:a02:c045:: with SMTP id u5mr8426413jam.95.1553278531098;
        Fri, 22 Mar 2019 11:15:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553278531; cv=none;
        d=google.com; s=arc-20160816;
        b=Mw7zdQhe/NRwayT5N5qUVT8m2CwAHA99suXkEtmsl5JXNT6H4tr/Hlhco51CBFkkxi
         JnlTSXcoygONKbGmzZMnMU2zeTwT1Yuk1o7ciqgVJfUBoipprdA4BCPmgFbvfbQJwqYt
         tE5I4q/gtJwKZ+as0KUeeKy3JRRdkSbl9Ol5Yvm9aQkYU7K89qkENAwxw0Ztvj3XQqzb
         CGo96p7MXVeGmhNAtX4q1X54te89Thsi7h5XMqreGaiDstYrWAXjCzzh1hARd5udKq3Q
         effp3+P5HU6VqRtRf+6H/USh++jwd1gfbaTOzN80h6Q/m4r+AI6bamUpbhkRQRk4eKPQ
         3TbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=O0a8CzUlSMwq0DVSSZK9H7Q3Yu1lpslNBR2v6oFPAks=;
        b=J9JjvR91tY5XHnaC+qB1tjkA/c7z8izTEL138d4fIfEMTuf7NHCBz8uOlAAD8t1p1H
         tYW9XQybHk43/qnEAgfYe0TQgAIswm4EpXbzh90PnEp8lNMLR15+EVGBkUCgZli9iQoA
         Ni3On9khG7yrJGqKpGWf1R8fMbksLJx4Wvtj1tkXPH0M+pdTikWDjRfb62eNBzK5oV7u
         ERfOZuKmbknGNnTq5mKGkZwQ4smpePDN+jVzr0FVOg5FESsnRg/rzSHyOvdcdsgEea98
         aFGwVHmYFOz0bpL7XpaMm2JzdZdcnYeWeoyCPuVP2WT3zFhfa/Yo7lt0/bELRYHcQiJW
         5Ggw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Z0V8pFOB;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=dklixkX3;
       spf=pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=89845e868f=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y12si3936697iop.149.2019.03.22.11.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 11:15:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Z0V8pFOB;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=dklixkX3;
       spf=pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=89845e868f=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2MHxYpA017892;
	Fri, 22 Mar 2019 11:15:24 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=O0a8CzUlSMwq0DVSSZK9H7Q3Yu1lpslNBR2v6oFPAks=;
 b=Z0V8pFOB8m5wMakM1E5LT3sshHbDqE2P8OZIbeeXY3NTnDs2FLgVkHQpSRSDv6ISOytM
 ga6D7s67irQR+KxkeY78v0usgSodSJDf+tD6wfIVwPF5SnuzBlBk7Q3e8gYbxA+l3ZaY
 HolUdoOLSldbrMNht7ZHhkShjr4PY5jF9KQ= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rd45hg59t-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 22 Mar 2019 11:15:24 -0700
Received: from prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 22 Mar 2019 11:15:23 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 22 Mar 2019 11:15:23 -0700
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 22 Mar 2019 11:15:22 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=O0a8CzUlSMwq0DVSSZK9H7Q3Yu1lpslNBR2v6oFPAks=;
 b=dklixkX3+jXqR6fJ25lwLu2UK22xmxGRoR0xo1Uu8SYwu/7BeFjIvrttJes73pRk738RjAxfPKjF2xmVw7GhWcdpp1Vr3JCVLU7JSSv93W20nX8ZKIgfD41Ekt5hOijB9s3Bvhxft0c9pPwFd9WzSb2cRfOvF9x6SwGzYoZE9MA=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3080.namprd15.prod.outlook.com (20.178.239.18) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.15; Fri, 22 Mar 2019 18:15:21 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%3]) with mapi id 15.20.1709.017; Fri, 22 Mar 2019
 18:15:21 +0000
From: Roman Gushchin <guro@fb.com>
To: Greg Thelen <gthelen@google.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Johannes Weiner
	<hannes@cmpxchg.org>,
        Michal Hocko <mhocko@kernel.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] writeback: sum memcg dirty counters as needed
Thread-Topic: [PATCH] writeback: sum memcg dirty counters as needed
Thread-Index: AQHU1Qb/Wv6KWk71Ak24H1OecVDKlaYYDFmA
Date: Fri, 22 Mar 2019 18:15:20 +0000
Message-ID: <20190322181517.GA12378@tower.DHCP.thefacebook.com>
References: <20190307165632.35810-1-gthelen@google.com>
In-Reply-To: <20190307165632.35810-1-gthelen@google.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR11CA0040.namprd11.prod.outlook.com
 (2603:10b6:a03:80::17) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:d234]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 80e70a92-90be-4304-4006-08d6aef25831
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3080;
x-ms-traffictypediagnostic: BYAPR15MB3080:
x-microsoft-antispam-prvs: <BYAPR15MB3080FA634CE1B4393FE41544BE430@BYAPR15MB3080.namprd15.prod.outlook.com>
x-forefront-prvs: 09840A4839
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(136003)(396003)(39860400002)(366004)(189003)(199004)(99286004)(5660300002)(186003)(53936002)(68736007)(81166006)(256004)(1076003)(2906002)(229853002)(8936002)(54906003)(105586002)(86362001)(14444005)(106356001)(81156014)(4326008)(8676002)(52116002)(76176011)(14454004)(71200400001)(9686003)(305945005)(486006)(6512007)(316002)(71190400001)(6506007)(386003)(6116002)(97736004)(6916009)(6436002)(7736002)(46003)(6246003)(478600001)(476003)(33656002)(446003)(25786009)(6486002)(102836004)(11346002)(14143004);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3080;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: lqB4ST1t53ncLK3SaDVdUH4PvsU0qrsP6jfI5Hl9zjk0ztU/2Q2ZXIEbwTgGP50uj/W1TWuSinF82NgBnCsMLo0skGbJXzIoWOad8TEpwcjwDAjsVnEOWGimn7guBhmqU9Cg0miLGqvIqEL0hfyMJbSMArPAoFqUBQFYhwzKxMiL7vnwp/qpvkqIA+f4MrxJTHSBCYCdvG0RPjYafPvtmUWGExe6dyMWsLRRcBIlNIId6xiv3iIY4vSQqZL1eVn7RdfjKhPxR/v2G3CrnWCsRuSqmXvCvy/b6aScGVD9mr6BJgoVM8pu/gbSMY+qJR2IcziYrrKelGFcZwauyZO2GZOWrwjbr+MMC7wYt/5sQ+m0hk6n6JDGpTeRYdDpa6zv1G25FpSI5FPWZC11VdL2XRXVCGHMuugCQU+FgQEz7kY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <D5E78308D7D15849AB79E1E40C462DEF@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 80e70a92-90be-4304-4006-08d6aef25831
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Mar 2019 18:15:20.8307
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3080
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-22_10:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 08:56:32AM -0800, Greg Thelen wrote:
> Since commit a983b5ebee57 ("mm: memcontrol: fix excessive complexity in
> memory.stat reporting") memcg dirty and writeback counters are managed
> as:
> 1) per-memcg per-cpu values in range of [-32..32]
> 2) per-memcg atomic counter
> When a per-cpu counter cannot fit in [-32..32] it's flushed to the
> atomic.  Stat readers only check the atomic.
> Thus readers such as balance_dirty_pages() may see a nontrivial error
> margin: 32 pages per cpu.
> Assuming 100 cpus:
>    4k x86 page_size:  13 MiB error per memcg
>   64k ppc page_size: 200 MiB error per memcg
> Considering that dirty+writeback are used together for some decisions
> the errors double.
>=20
> This inaccuracy can lead to undeserved oom kills.  One nasty case is
> when all per-cpu counters hold positive values offsetting an atomic
> negative value (i.e. per_cpu[*]=3D32, atomic=3Dn_cpu*-32).
> balance_dirty_pages() only consults the atomic and does not consider
> throttling the next n_cpu*32 dirty pages.  If the file_lru is in the
> 13..200 MiB range then there's absolutely no dirty throttling, which
> burdens vmscan with only dirty+writeback pages thus resorting to oom
> kill.
>=20
> It could be argued that tiny containers are not supported, but it's more
> subtle.  It's the amount the space available for file lru that matters.
> If a container has memory.max-200MiB of non reclaimable memory, then it
> will also suffer such oom kills on a 100 cpu machine.
>=20
> The following test reliably ooms without this patch.  This patch avoids
> oom kills.
>
> ...
>=20
> Make balance_dirty_pages() and wb_over_bg_thresh() work harder to
> collect exact per memcg counters when a memcg is close to the
> throttling/writeback threshold.  This avoids the aforementioned oom
> kills.
>=20
> This does not affect the overhead of memory.stat, which still reads the
> single atomic counter.
>=20
> Why not use percpu_counter?  memcg already handles cpus going offline,
> so no need for that overhead from percpu_counter.  And the
> percpu_counter spinlocks are more heavyweight than is required.
>=20
> It probably also makes sense to include exact dirty and writeback
> counters in memcg oom reports.  But that is saved for later.
>=20
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---
>  include/linux/memcontrol.h | 33 +++++++++++++++++++++++++--------
>  mm/memcontrol.c            | 26 ++++++++++++++++++++------
>  mm/page-writeback.c        | 27 +++++++++++++++++++++------
>  3 files changed, 66 insertions(+), 20 deletions(-)
>=20
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 83ae11cbd12c..6a133c90138c 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -573,6 +573,22 @@ static inline unsigned long memcg_page_state(struct =
mem_cgroup *memcg,
>  	return x;
>  }

Hi Greg!

Thank you for the patch, definitely a good problem to be fixed!

> =20
> +/* idx can be of type enum memcg_stat_item or node_stat_item */
> +static inline unsigned long
> +memcg_exact_page_state(struct mem_cgroup *memcg, int idx)
> +{
> +	long x =3D atomic_long_read(&memcg->stat[idx]);
> +#ifdef CONFIG_SMP

I doubt that this #ifdef is correct without corresponding changes
in __mod_memcg_state(). As now, we do use per-cpu buffer which spills
to an atomic value event if !CONFIG_SMP. It's probably something
that we want to change, but as now, #ifdef CONFIG_SMP should protect
only "if (x < 0)" part.


> +	int cpu;
> +
> +	for_each_online_cpu(cpu)
> +		x +=3D per_cpu_ptr(memcg->stat_cpu, cpu)->count[idx];
> +	if (x < 0)
> +		x =3D 0;
> +#endif
> +	return x;
> +}

Also, isn't it worth it to generalize memcg_page_state() instead?
By adding an bool exact argument? I believe dirty balance is not
the only place, where we need a better accuracy.

Thanks!

