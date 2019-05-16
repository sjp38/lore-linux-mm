Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75500C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 17:59:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 207AF20657
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 17:59:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="TEqOa/xz";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="VGMc7HxM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 207AF20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEB686B0005; Thu, 16 May 2019 13:59:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A76366B0006; Thu, 16 May 2019 13:59:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C9016B0007; Thu, 16 May 2019 13:59:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4286B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 13:59:21 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g11so2435335plt.23
        for <linux-mm@kvack.org>; Thu, 16 May 2019 10:59:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=0sJJDVmVPbcqR4ccCTdWSoTemBmgF1vMg4myTuYmOBw=;
        b=fJRkhfqB/EeM6Hmehk2X210h2t3Wsnq3GLoAXkfqMnRJV+PU9Vp3KsJ/dvdWK/eS62
         pc+0qgoe3WWEWDNLNqtPjHJGgFK8cpv8cyVXHdVssqKILCnHLgD/Q5RAmGjPx6SS1fJ7
         vla49ZkwGZnYgxWaMPm2sXA7anGJXItR4QeYvAQXAAzzM7d5zS5FAUC+UUKCK7S/sGI0
         /aypx6ojJAaYMUwKwIcMdEKxDV8CRahqO+8cZTzVVe2wzY90elViqX6C4DjTluKSzzWw
         ERp/i29o4dqiSnfH4nbJ2nXpGCYfbqdjeuy/ucUKhGG1kzfpZ9Fwb4wmUrJpxdg8UgVU
         utXA==
X-Gm-Message-State: APjAAAXR6y4o5IfPwyeWNblP83W6OZkZdQDeQUd33dh0L0XFQ62f/CQl
	9V97tfZdQbOddawcPiA1k+cpUnqVrh/O74GX72CO+HZ9AF2rbnSgUu92CCLxK6Wvzj8CRRAtzl3
	29+KADHto4XTEjPfnGVGiNDtPn+jZXOJ5zUME1e0MTtwqIgEva4RJgMf39NS9Lu+JaQ==
X-Received: by 2002:a62:575b:: with SMTP id l88mr54842146pfb.143.1558029560893;
        Thu, 16 May 2019 10:59:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyswMZBcIcl+Adic+o+n8KIrJ1jr7XfDXcFkSdxWp9Vl9S5y3Ch2rDDHonjQDy2IRqIzY2S
X-Received: by 2002:a62:575b:: with SMTP id l88mr54842085pfb.143.1558029560006;
        Thu, 16 May 2019 10:59:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558029560; cv=none;
        d=google.com; s=arc-20160816;
        b=V8wXQXROBA56w+qbfUuVRiRf15Qa3QGDVI0SOZV4qObcLSh21JclgbQ1DjkReOgKtV
         LLLxSpCJ+Va0fUCQnxAYIOSXVk3jDzMb8P9YZQze3hXzXSL/R9IG+b71CuivKy+OzltN
         OGUejumdjknrTSOShh64UT2pkwsCMh+xvo/zuef4TtQkHH0jcEd1CV0D7AncPYEzKD/P
         T11bAvU9rg5brJ1I5du++vNiUwfoCzKImhGrbf5vGIysdWO7wyvbtPjJqJpdhXluqHsx
         Qhc9+EWNMR7ZP0nQkobiLXmqwVQu3Pp4dqJPEptxZQEOM7VU6lfVx6nb6ZkOyGFVfxPm
         Z1iA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=0sJJDVmVPbcqR4ccCTdWSoTemBmgF1vMg4myTuYmOBw=;
        b=fZ7OOPJH624UoHJgGG26smEL6I2riN+ZZXV7cNvmF9PMW8LCfVv8t+zieuMpUxUK8d
         PDrzR4QsZt6TjpbfwANCKmyAHoPlY3YRcl6bBTqnvSrzm66wBz9MB7FU2abA4szbq94Y
         D6MoNflH2L2RDRAyeRBDLzwXFVW/KBjYXQgac69epBqHrfkPHhBOV1/fWT2kOw7wX5/y
         zSpUE9nw6oiuhBsKqfHLn+/2Z4B55ao2vZQa+HbBHIaD0Zdyx+LIHwb+0b0lLq9qbFE2
         MzH1Z6UAAtHGWl+YNK0mFELz+4brKrGrjm1gghy7syvWp82JlS2k2J09/X2cSBp1VqfY
         6Wsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="TEqOa/xz";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=VGMc7HxM;
       spf=pass (google.com: domain of prvs=003920a4de=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=003920a4de=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id a67si6553180pfb.50.2019.05.16.10.59.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 10:59:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=003920a4de=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="TEqOa/xz";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=VGMc7HxM;
       spf=pass (google.com: domain of prvs=003920a4de=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=003920a4de=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4GHoDhi010470;
	Thu, 16 May 2019 10:59:19 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=0sJJDVmVPbcqR4ccCTdWSoTemBmgF1vMg4myTuYmOBw=;
 b=TEqOa/xzfvCDncyxqo+1idWCdfIT6egRjFoDuED2v1OFzZwhp0bGgmVxWyyLo/stIZOP
 300XgJZL0vB4yq4LeTowy+HM382CCUff9aPdMuaO6m7HbvHuBjdXi31S7lw2cP76hXOQ
 awPaaD50s0X5xOrje4HgU4oY4/9kk7GS7G8= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sh85m15u5-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 16 May 2019 10:59:19 -0700
Received: from ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) by
 ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 16 May 2019 10:59:18 -0700
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 16 May 2019 10:59:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0sJJDVmVPbcqR4ccCTdWSoTemBmgF1vMg4myTuYmOBw=;
 b=VGMc7HxMEbhiFCLj4xA0PPyD2EL0cVY5b1dKytduy4gktIw6ndpdLCnGuT6ylQb8vKeGfawFw85vEeJcPiG/6SqM/IHKPYYRio6pNM0f8LZqdAE+aFs8jPBpXWa4UhatalvTUzbVUBHZrQgbfjpH5QZaw1r7+t7aVUa/27FseBU=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3031.namprd15.prod.outlook.com (20.178.238.92) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.16; Thu, 16 May 2019 17:59:16 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1878.024; Thu, 16 May 2019
 17:59:16 +0000
From: Roman Gushchin <guro@fb.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH RFC] proc/meminfo: add KernelMisc counter
Thread-Topic: [PATCH RFC] proc/meminfo: add KernelMisc counter
Thread-Index: AQHVCxRXjFsvoo4AKkauNvlOgzDnXKZuC/qA
Date: Thu, 16 May 2019 17:59:16 +0000
Message-ID: <20190516175912.GA32262@tower.DHCP.thefacebook.com>
References: <155792098821.1536.17069603544573830315.stgit@buzz>
In-Reply-To: <155792098821.1536.17069603544573830315.stgit@buzz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR03CA0034.namprd03.prod.outlook.com
 (2603:10b6:a02:a8::47) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:138e]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 03b4d010-6576-4dcd-483e-08d6da283611
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3031;
x-ms-traffictypediagnostic: BYAPR15MB3031:
x-microsoft-antispam-prvs: <BYAPR15MB30316CF05D2A8A85CE9AAE51BE0A0@BYAPR15MB3031.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0039C6E5C5
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(376002)(366004)(396003)(39860400002)(189003)(199004)(6436002)(6486002)(71190400001)(6916009)(53936002)(2906002)(73956011)(9686003)(186003)(71200400001)(316002)(46003)(6512007)(33656002)(476003)(11346002)(66476007)(1076003)(66446008)(64756008)(66946007)(25786009)(102836004)(81166006)(6116002)(99286004)(256004)(8676002)(81156014)(305945005)(386003)(7736002)(8936002)(66556008)(52116002)(5660300002)(76176011)(6506007)(54906003)(14454004)(486006)(6246003)(478600001)(446003)(4326008)(68736007)(229853002)(86362001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3031;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: frmWzronCAilcO2IXv3AHzbtcFnmxjzAd9nf+m9+3xUOBnh/E7tg2KDz5FD6s5a6G3fUzSn9UzyozyN/kKCeGnfzCbyokd4P299ly5CsjMmpdCXGuAb0Ajji282ie+vcbEsBdFpiiCDwUjpOgq8Sk970E9h1mrlOb0Wg4MVDhBoDFo3ZUK6ujEEO4ej3NxYX1Q1yBR4mIjH2VafLsahQI8vqSa+6tK6RPjnyBlxYZ5xrm+7YwGbI9ig4I9Fc4pAWUP/UIzi6hxtCX4T1xEfpt2uU7j7v89P2FLBvOMGt/6QnTi7TeyNToAVrOveT95vrROG3vB9enQpD7VZV6m5v/o3ZmG5Ee9M2vs2Y7tZAcFSaqpFfwOapsgt1kvKb6E/IpONhLBXpolmSBfxx+23XoOyyT0VUbOQ6pLuJXJ9JhfY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <76805DF5D495384E8D32EC16E8F0E605@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 03b4d010-6576-4dcd-483e-08d6da283611
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 May 2019 17:59:16.2621
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3031
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-16_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905160113
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 02:49:48PM +0300, Konstantin Khlebnikov wrote:
> Some kernel memory allocations are not accounted anywhere.
> This adds easy-read counter for them by subtracting all tracked kinds.
>=20
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

We have something similar in userspace, and it was very useful several time=
s.
In our case, it was mostly vmallocs and percpu stuff (which are now shown
in meminfo), but for sure there are other memory users who are not.

I don't particularly like the proposed name, but have no better ideas.
It's really a gray area, everything we know, it's that the memory is occupi=
ed
by something.

> ---
>  Documentation/filesystems/proc.txt |    2 ++
>  fs/proc/meminfo.c                  |   41 +++++++++++++++++++++++++-----=
------
>  2 files changed, 30 insertions(+), 13 deletions(-)
>=20
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesyste=
ms/proc.txt
> index 66cad5c86171..f11ce167124c 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -891,6 +891,7 @@ VmallocTotal:   112216 kB
>  VmallocUsed:       428 kB
>  VmallocChunk:   111088 kB
>  Percpu:          62080 kB
> +KernelMisc:     212856 kB
>  HardwareCorrupted:   0 kB
>  AnonHugePages:   49152 kB
>  ShmemHugePages:      0 kB
> @@ -988,6 +989,7 @@ VmallocTotal: total size of vmalloc memory area
>  VmallocChunk: largest contiguous block of vmalloc area which is free
>        Percpu: Memory allocated to the percpu allocator used to back perc=
pu
>                allocations. This stat excludes the cost of metadata.
> +  KernelMisc: All other kinds of kernel memory allocaitons
                                                       ^^^
						       typo
> =20
>  ........................................................................=
......
> =20
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 568d90e17c17..7bc14716fc5d 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -38,15 +38,21 @@ static int meminfo_proc_show(struct seq_file *m, void=
 *v)
>  	long cached;
>  	long available;
>  	unsigned long pages[NR_LRU_LISTS];
> -	unsigned long sreclaimable, sunreclaim;
> +	unsigned long sreclaimable, sunreclaim, misc_reclaimable;
> +	unsigned long kernel_stack_kb, page_tables, percpu_pages;
> +	unsigned long anon_pages, file_pages, swap_cached;
> +	long kernel_misc;
>  	int lru;
> =20
>  	si_meminfo(&i);
>  	si_swapinfo(&i);
>  	committed =3D percpu_counter_read_positive(&vm_committed_as);
> =20
> -	cached =3D global_node_page_state(NR_FILE_PAGES) -
> -			total_swapcache_pages() - i.bufferram;
> +	anon_pages =3D global_node_page_state(NR_ANON_MAPPED);
> +	file_pages =3D global_node_page_state(NR_FILE_PAGES);
> +	swap_cached =3D total_swapcache_pages();
> +
> +	cached =3D file_pages - swap_cached - i.bufferram;
>  	if (cached < 0)
>  		cached =3D 0;
> =20
> @@ -56,13 +62,25 @@ static int meminfo_proc_show(struct seq_file *m, void=
 *v)
>  	available =3D si_mem_available();
>  	sreclaimable =3D global_node_page_state(NR_SLAB_RECLAIMABLE);
>  	sunreclaim =3D global_node_page_state(NR_SLAB_UNRECLAIMABLE);
> +	misc_reclaimable =3D global_node_page_state(NR_KERNEL_MISC_RECLAIMABLE)=
;
> +	kernel_stack_kb =3D global_zone_page_state(NR_KERNEL_STACK_KB);
> +	page_tables =3D global_zone_page_state(NR_PAGETABLE);
> +	percpu_pages =3D pcpu_nr_pages();
> +
> +	/* all other kinds of kernel memory allocations */
> +	kernel_misc =3D i.totalram - i.freeram - anon_pages - file_pages
> +		      - sreclaimable - sunreclaim - misc_reclaimable
> +		      - (kernel_stack_kb >> (PAGE_SHIFT - 10))
> +		      - page_tables - percpu_pages;
> +	if (kernel_misc < 0)
> +		kernel_misc =3D 0;

Hm, why? Is there any realistic scenario (not caused by the kernel doing
the memory accounting wrong) when it's negative?

Maybe it's better to show it as it is, if it's negative? Because
it might be a good indication that something's wrong with some of
the counters.

Thanks!

