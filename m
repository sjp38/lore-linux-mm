Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C84D8C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 20:39:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A0A52184C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 20:39:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="cEQ+OyI1";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="ch1z74cP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A0A52184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACF486B0007; Fri, 29 Mar 2019 16:39:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7E276B0008; Fri, 29 Mar 2019 16:39:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 923556B000A; Fri, 29 Mar 2019 16:39:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE386B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 16:39:07 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id q127so2930985qkd.2
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 13:39:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=vET/YL8t8/5jAemAGsjXaYnc56x41+TQJDJMlG4DVD4=;
        b=OPTgPLQMJ1kiVf+vpfAtIDZF466l2tHknQFbdwunZuWXc2l334OrwXHxwEwIyWauVy
         0tV/ALr/QfLPi2en0AV6WCQaMVyYPpaWnarK1Sg0iizDCCh3pZd+ZTQdX729XfwhgpGE
         u9vPQEupjES2GscyJpQo6szdbca/zKTjIM5WZQw3Xz5ofa6CfOOjKBc0p7EP4q/FB+O5
         X7gL7wiqXfpP9/5YXeVB0jQltczr8m4OcyXZ0lSgfQjSRUM6Xllr9ETcS/bFHuVL37wK
         0dAMi2Wr48fsQV1HvloPHmxQBeegWB0Gk6cyW5B2MVCLwS85fyglEYO/vmfHjcRr8jc4
         sjiQ==
X-Gm-Message-State: APjAAAUtS4+btRvDkZUhCT+gpG82NOpgORbKakHRRC4qHmeebCwIy46C
	1FpZ9a7pFhQpUDiO/+WXDiGGxIaEj4faxiQuBifNdsN27oF1o5XrT7AUdXWzS7l5JEM+XXOMqmD
	wirmldaJFgV6bN3ETIgURWLbP1wWX/nrSJY6ReEnX6rdxZWm/FW/UnzMPY1UiVRPFUg==
X-Received: by 2002:a0c:91cc:: with SMTP id r12mr41947945qvr.35.1553891947104;
        Fri, 29 Mar 2019 13:39:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/tvI563yAl7vIegOm1OS5gUHEqBR+Us3NNyIlnD/ZVRk9ODIyPfe57mhZvqFpkG9rhjLm
X-Received: by 2002:a0c:91cc:: with SMTP id r12mr41947570qvr.35.1553891940922;
        Fri, 29 Mar 2019 13:39:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553891940; cv=none;
        d=google.com; s=arc-20160816;
        b=XtfOXCCGf7rDTB09aaxjaUi5gUQN4KbvyG5bfMDAtxOR4dOCtqvhsWwVqzXMfKKer4
         rBFnRyL+WuIKN291j+QaSvWeQ86SPe5c1MTisXYAKkILE2WO7IHol2EqJEMPq/dgs8ei
         T5uwKMFg6Zeply0dy+zh8dHv8fSgNd/0qVdmWts60Az6+isZZpg5UdeMXA5OcY4Vd+Qo
         I/b3kANKcd5rJwWxWfGJntGil38zNuOLCq03abdgIJ2UlFCdi1QVUAPlUiKruj0viJ0K
         6kvZ7l8BMCC6Xg2zZaD2LCPvSBJSB0mIqVs9t9vhFjyV3iSHk5d894dvCaS4WN8npLFU
         8Sfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=vET/YL8t8/5jAemAGsjXaYnc56x41+TQJDJMlG4DVD4=;
        b=Cx6cNflN3wQhhRfkI5M8b2gbY5IhcElgtsQii7/nScMVrHBrrdwlEPj7WTzZsag5SE
         Nf8KcgX4nvv2eVcz456/ldqADIYDTZ5FnY+um8IWW5/aNI7XWJyeatlhN2oImGXvMOiF
         +6W3zxzwUnYq3N9cwGXGrRcdsgpz7B1YTzn+v2M7cgjOPNhkl1VB61S0VamOtuAQAAxc
         5mDLa9Xznwov8okXJKao2bI8EPZuIv15XT86CVGQWDu8wpDIdDrWp6ZpQIaATlgv93y5
         y2UAobQuEXJFQqmQH/1rtpTGQiOH7/fCT/4HOTdruJh+3scbJWBclrocE9nUJmbSKrDb
         LVtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=cEQ+OyI1;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=ch1z74cP;
       spf=pass (google.com: domain of prvs=99918b81f1=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=99918b81f1=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id r7si1354830qtj.61.2019.03.29.13.39.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 13:39:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=99918b81f1=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=cEQ+OyI1;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=ch1z74cP;
       spf=pass (google.com: domain of prvs=99918b81f1=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=99918b81f1=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x2TKVolF006439;
	Fri, 29 Mar 2019 13:38:54 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=vET/YL8t8/5jAemAGsjXaYnc56x41+TQJDJMlG4DVD4=;
 b=cEQ+OyI14V4WN6k5btgGpKXbpsuZCpBNfqaVyFWykIeIORHHZYAkGhknEL6e11+kP/iT
 z1n0kGlrkWAx2/tjQhPvXZzwGMOMeXw9fY+bldfi2kyGaB5DlBSkAC5pSY324NV2F8Gj
 HfJzgp7vvz4AiIEu18oPXhDQf1R3bGtlr1o= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by m0001303.ppops.net with ESMTP id 2rhs9rga0d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 29 Mar 2019 13:38:54 -0700
Received: from frc-mbx02.TheFacebook.com (2620:10d:c0a1:f82::26) by
 frc-hub03.TheFacebook.com (2620:10d:c021:18::173) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 29 Mar 2019 13:38:54 -0700
Received: from frc-hub05.TheFacebook.com (2620:10d:c021:18::175) by
 frc-mbx02.TheFacebook.com (2620:10d:c0a1:f82::26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 29 Mar 2019 13:38:54 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.75) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 29 Mar 2019 13:38:54 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=vET/YL8t8/5jAemAGsjXaYnc56x41+TQJDJMlG4DVD4=;
 b=ch1z74cPHNyrVJQbcsKDEVxf1C2qxkX4AbbPOOZoCaez94gbmFCbqHRcLVbm5a3wLfAsXnFKleIDgEvGGCM/3BZ/wfHNorYegJU/QOcTjO6m0KQYQFznpYvgL+to8eYTd0lG+Au3qbYBZMzi/g5qD+o+hEucC49pOKjZQ9Ftz+Y=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2536.namprd15.prod.outlook.com (20.179.154.217) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.16; Fri, 29 Mar 2019 20:38:51 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%3]) with mapi id 15.20.1750.017; Fri, 29 Mar 2019
 20:38:51 +0000
From: Roman Gushchin <guro@fb.com>
To: Greg Thelen <gthelen@google.com>
CC: Johannes Weiner <hannes@cmpxchg.org>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>,
        "Vladimir
 Davydov" <vdavydov.dev@gmail.com>,
        Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        "stable@vger.kernel.org"
	<stable@vger.kernel.org>
Subject: Re: [PATCH v2] writeback: use exact memcg dirty counts
Thread-Topic: [PATCH v2] writeback: use exact memcg dirty counts
Thread-Index: AQHU5ldV+o6YfPDV3E6lTVYX7xBNtKYjEiEA
Date: Fri, 29 Mar 2019 20:38:50 +0000
Message-ID: <20190329203844.GA24069@tower.DHCP.thefacebook.com>
References: <20190329174609.164344-1-gthelen@google.com>
In-Reply-To: <20190329174609.164344-1-gthelen@google.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR11CA0029.namprd11.prod.outlook.com
 (2603:10b6:300:115::15) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:7c]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9bdeb2b8-affb-4cd2-3452-08d6b4868d17
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2536;
x-ms-traffictypediagnostic: BYAPR15MB2536:
x-microsoft-antispam-prvs: <BYAPR15MB25360863BEB5783D0D374006BE5A0@BYAPR15MB2536.namprd15.prod.outlook.com>
x-forefront-prvs: 0991CAB7B3
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(136003)(376002)(396003)(346002)(366004)(189003)(199004)(102836004)(71200400001)(46003)(6506007)(6436002)(6246003)(86362001)(386003)(8936002)(81156014)(106356001)(71190400001)(81166006)(316002)(14454004)(6486002)(6916009)(186003)(68736007)(33656002)(53936002)(486006)(14444005)(99286004)(476003)(229853002)(4326008)(11346002)(8676002)(105586002)(256004)(5660300002)(6116002)(305945005)(2906002)(446003)(97736004)(478600001)(6512007)(1076003)(52116002)(54906003)(25786009)(76176011)(9686003)(7736002)(14143004);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2536;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: V5q8AZpHDQqmxMENzJ3YprUvJIC6CVEeJ7d2p77eTKDQVxV7p9aeh+Etx6ojaLGncm6MQdEb93TKQO0xmotrWuN054tiZh8ed/dYwzNDjLZ4tGcM2O417FrukQzdTxYyietOEvlbv9ykKIeMVENnQSBvuPlJFUDYeBbwhqeaRC7cCJX699mHzki6fDNdztHsDfQ4ldMPU1Kx9J1Vl0uvoAGIgl5zuB6qi2rrzvebGzrSRP8fy6UlToxQ4rBhqcnAlqHVU6OlDl73nIBwLBuWy/KoozWDtD6yRy8+g7DqZPAqpoBTXJ/qQQUdZoXzd6BaWwp21/e1ERnT+W+0SC4ZMBBNb05EDqMMFf0daX9hgSfAx2LgqU4r7AfLki/mEjUZ5BVzovFA5nvNjpMn7fLiLvLEzAv/4gCagj9DmcY9tIk=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <EBA624BDEC2CAE4C9D89E7FF1151A9B7@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 9bdeb2b8-affb-4cd2-3452-08d6b4868d17
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 Mar 2019 20:38:50.9822
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2536
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-29_12:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 10:46:09AM -0700, Greg Thelen wrote:
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
>=20
>   $ cat test
>   mount -t cgroup2 none /dev/cgroup
>   cd /dev/cgroup
>   echo +io +memory > cgroup.subtree_control
>   mkdir test
>   cd test
>   echo 10M > memory.max
>   (echo $BASHPID > cgroup.procs && exec /memcg-writeback-stress /foo)
>   (echo $BASHPID > cgroup.procs && exec dd if=3D/dev/zero of=3D/foo bs=3D=
2M count=3D100)
>=20
>   $ cat memcg-writeback-stress.c
>   /*
>    * Dirty pages from all but one cpu.
>    * Clean pages from the non dirtying cpu.
>    * This is to stress per cpu counter imbalance.
>    * On a 100 cpu machine:
>    * - per memcg per cpu dirty count is 32 pages for each of 99 cpus
>    * - per memcg atomic is -99*32 pages
>    * - thus the complete dirty limit: sum of all counters 0
>    * - balance_dirty_pages() only sees atomic count -99*32 pages, which
>    *   it max()s to 0.
>    * - So a workload can dirty -99*32 pages before balance_dirty_pages()
>    *   cares.
>    */
>   #define _GNU_SOURCE
>   #include <err.h>
>   #include <fcntl.h>
>   #include <sched.h>
>   #include <stdlib.h>
>   #include <stdio.h>
>   #include <sys/stat.h>
>   #include <sys/sysinfo.h>
>   #include <sys/types.h>
>   #include <unistd.h>
>=20
>   static char *buf;
>   static int bufSize;
>=20
>   static void set_affinity(int cpu)
>   {
>   	cpu_set_t affinity;
>=20
>   	CPU_ZERO(&affinity);
>   	CPU_SET(cpu, &affinity);
>   	if (sched_setaffinity(0, sizeof(affinity), &affinity))
>   		err(1, "sched_setaffinity");
>   }
>=20
>   static void dirty_on(int output_fd, int cpu)
>   {
>   	int i, wrote;
>=20
>   	set_affinity(cpu);
>   	for (i =3D 0; i < 32; i++) {
>   		for (wrote =3D 0; wrote < bufSize; ) {
>   			int ret =3D write(output_fd, buf+wrote, bufSize-wrote);
>   			if (ret =3D=3D -1)
>   				err(1, "write");
>   			wrote +=3D ret;
>   		}
>   	}
>   }
>=20
>   int main(int argc, char **argv)
>   {
>   	int cpu, flush_cpu =3D 1, output_fd;
>   	const char *output;
>=20
>   	if (argc !=3D 2)
>   		errx(1, "usage: output_file");
>=20
>   	output =3D argv[1];
>   	bufSize =3D getpagesize();
>   	buf =3D malloc(getpagesize());
>   	if (buf =3D=3D NULL)
>   		errx(1, "malloc failed");
>=20
>   	output_fd =3D open(output, O_CREAT|O_RDWR);
>   	if (output_fd =3D=3D -1)
>   		err(1, "open(%s)", output);
>=20
>   	for (cpu =3D 0; cpu < get_nprocs(); cpu++) {
>   		if (cpu !=3D flush_cpu)
>   			dirty_on(output_fd, cpu);
>   	}
>=20
>   	set_affinity(flush_cpu);
>   	if (fsync(output_fd))
>   		err(1, "fsync(%s)", output);
>   	if (close(output_fd))
>   		err(1, "close(%s)", output);
>   	free(buf);
>   }
>=20
> Make balance_dirty_pages() and wb_over_bg_thresh() work harder to
> collect exact per memcg counters.  This avoids the aforementioned oom
> kills.
>=20
> This does not affect the overhead of memory.stat, which still reads the
> single atomic counter.
>=20
> Why not use percpu_counter?  memcg already handles cpus going offline,
> so no need for that overhead from percpu_counter.  And the
> percpu_counter spinlocks are more heavyweight than is required.
>=20
> It probably also makes sense to use exact dirty and writeback counters
> in memcg oom reports.  But that is saved for later.
>=20
> Cc: stable@vger.kernel.org # v4.16+
> Signed-off-by: Greg Thelen <gthelen@google.com>

Hi , Greg!

Looks good to me!
Reviewed-by: Roman Gushchin <guro@fb.com>

Thanks!

