Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26E6FC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:18:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C40D72083B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:18:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="dKmPtv9X";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="ojGJLcDB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C40D72083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F5748E0003; Fri, 21 Jun 2019 09:18:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A59B8E0001; Fri, 21 Jun 2019 09:18:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56E2F8E0003; Fri, 21 Jun 2019 09:18:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 20D8C8E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:18:05 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i27so4367287pfk.12
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:18:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=1ld9Z63169YHwkqRRST1VdvjEeMIhUAUDISex3uFQwM=;
        b=mgGWXIdsn6lnPiFwxKz8F8hOKcQ7z46s47P+/bWq2yKIPi0kNezqMISID8/60qLxJN
         83kt7x8bubB/XOZeN1x4qo4jnct8msIbNtY5pAypfpur6TYsqZvkxZSrsDTwAu0Y+Do/
         c71/RSgukUJ0Lmljea/uxSiNWmz7bPmW4S1snYISXVhgPcLB8QnzG1QA97faru7PDTTI
         0dWukWNMAAifa4CEhF7MYpuuQJGyySIA99UwCJ6/JgeOqONLN5Jp4J2aJiAEwHqUUyWq
         gouCKvKfVu4NC2m2eZMjvr7Z6Byj19QNYVYHQ0kAdzZknI8NZTzb/HN+il76PRNZxC7G
         WWcg==
X-Gm-Message-State: APjAAAVPiMPz0GbSUW2/sVOAfBqIOTGYgtAZmDO3+0Slw5pUS+pnGaKJ
	B5UKb3Gi2r/hyaamJuWAneTSifL87Sq14NUd5Zth9eZyjkR40TMQBuXCBAAwgV1YRvVoy3Yo0W7
	TCak4qN7uHd8s80O+SQ7m73/4uGpDAfZMqRih7LYlNIRtyDLR/Eq8rShZ4vteAvC1bg==
X-Received: by 2002:a17:902:f301:: with SMTP id gb1mr75010168plb.292.1561123084639;
        Fri, 21 Jun 2019 06:18:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxO8hXO015RzTa8wjVmGZtpsm2saJ22nj4DSK3nZk2LuoPN4+eKeONWVtFz4MZdrWlJ+FAg
X-Received: by 2002:a17:902:f301:: with SMTP id gb1mr75010105plb.292.1561123084069;
        Fri, 21 Jun 2019 06:18:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561123084; cv=none;
        d=google.com; s=arc-20160816;
        b=VeSNvgiYWehprGSKjx1/Gbaun1qCdTO/UdzXoqc10ry5mz2P0i3mZDYQIShSUlNMiw
         caR1bAQs9muf5higl2m/yT9Z2HOV6VOoKqBsWPqJmuXMfDTxN98H/ctob3wAUQBMrqLn
         up/t7YiQvpkdF8O7LxvIgYKGB/dHbTeDXaOSmnYXZe9McfWNyKSKFfugCi8aWtOO9SPH
         O9VutnMWFDjQAeDwKWfm/fcWepdc6xizYUiTOZJq8pbILUBWRKpGiUzAQ0B+ezNh5ssZ
         Apys94RJYzGwfKgHTGpob8nxr4ohZ1/23pPe65oNqkTusu08alPFyYEAfRVYVyNCCiKR
         koGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=1ld9Z63169YHwkqRRST1VdvjEeMIhUAUDISex3uFQwM=;
        b=dXZTWq4h7wbD3+md+YJtk41i/SB5OVZBbNTn2AkdNUmIMwuaJwt0bs11p9gwREyVYZ
         ztdXaRFGdfSiZjgndZBLeApQyHe37eCkTw8jkqSgin1MovBL3MEO2KtgpZN3Jq0l1JcD
         RUbHpJCOoFYgBiEisqAzE6xNKoQ9jVFG7ZfI+TGKHUOsXXVRlMKiZNvMd96ngPG6/Z6E
         uiv8b7sxAWIglIVSEuCfuP47VFcKiToybgRarrOHwwBuaBgvdBMm4X77zq7qZrl8x0LU
         jgPreL28NCA5ub81QdT2yHHNF3QXE+2GSudln2NZisVWnAeGXmBmmpkc7dr298q4cyRo
         0t3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=dKmPtv9X;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=ojGJLcDB;
       spf=pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10751dd214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m26si2375530pgv.388.2019.06.21.06.18.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 06:18:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=dKmPtv9X;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=ojGJLcDB;
       spf=pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10751dd214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LDCjCc030641;
	Fri, 21 Jun 2019 06:17:34 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=1ld9Z63169YHwkqRRST1VdvjEeMIhUAUDISex3uFQwM=;
 b=dKmPtv9XjZHTuRe+tVObLxiwzvmTSqrqOR2SjceXqIeDnQ+NpEmfM52Fto2+Av2MqpKK
 t6H6xx1sX9riCVgQQcxPOf+Joa9DzWXheYv3j0QTc42hTRcY1fkUr/KxqE7Hpw+BgnXw
 xqVPyZPiujWzeq1oeMh/adUeE3h28to04hA= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8gchb06f-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Fri, 21 Jun 2019 06:17:34 -0700
Received: from ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) by
 ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 21 Jun 2019 06:17:07 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.173) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Fri, 21 Jun 2019 06:17:07 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1ld9Z63169YHwkqRRST1VdvjEeMIhUAUDISex3uFQwM=;
 b=ojGJLcDBczowfk7TX6eMW79RmAvEbOCl63K1cl+tIBlwhTa0yEuPPEtm8x8Qtja3trVIQsY4X4XEHOqpmyLg+okg/Ko6nsbwz8yOP4LtgBzLcWC1tPgZR9GRF2wx0xAuIEkVtFWhjFg2aRruUdQUbCS40/9unH/SKYfdffkDI5M=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1725.namprd15.prod.outlook.com (10.174.255.139) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Fri, 21 Jun 2019 13:17:06 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.014; Fri, 21 Jun 2019
 13:17:06 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "rostedt@goodmis.org"
	<rostedt@goodmis.org>,
        "mhiramat@kernel.org" <mhiramat@kernel.org>,
        "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "Kernel
 Team" <Kernel-team@fb.com>
Subject: Re: [PATCH v4 5/5] uprobe: collapse THP pmd after removing all
 uprobes
Thread-Topic: [PATCH v4 5/5] uprobe: collapse THP pmd after removing all
 uprobes
Thread-Index: AQHVIhGkBNxZAI1nUkK1d2OfbYvmTqamGxWAgAAIBYA=
Date: Fri, 21 Jun 2019 13:17:05 +0000
Message-ID: <B72B62C9-78EE-4440-86CA-590D3977BDB1@fb.com>
References: <20190613175747.1964753-1-songliubraving@fb.com>
 <20190613175747.1964753-6-songliubraving@fb.com>
 <20190621124823.ziyyx3aagnkobs2n@box>
In-Reply-To: <20190621124823.ziyyx3aagnkobs2n@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:ed23]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f69183ac-cd4a-4b90-2377-08d6f64ac1f9
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1725;
x-ms-traffictypediagnostic: MWHPR15MB1725:
x-microsoft-antispam-prvs: <MWHPR15MB172584294457B679A395B14BB3E70@MWHPR15MB1725.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0075CB064E
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(39860400002)(346002)(376002)(366004)(189003)(199004)(8676002)(33656002)(81156014)(81166006)(71200400001)(71190400001)(53936002)(57306001)(66446008)(73956011)(66946007)(66476007)(66556008)(64756008)(91956017)(76116006)(36756003)(256004)(316002)(305945005)(54906003)(7736002)(8936002)(6512007)(76176011)(99286004)(2906002)(68736007)(50226002)(6116002)(229853002)(25786009)(4326008)(478600001)(6436002)(5660300002)(6486002)(6246003)(6916009)(446003)(186003)(476003)(14454004)(2616005)(11346002)(486006)(102836004)(46003)(6506007)(53546011)(86362001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1725;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 8XW8vXgU8ZP8n0S9h2AdO0jmC3JWrOHyjNjvLx+drCR6Tz3Rj7Z1kTi6o5tbMfDh9GBTmJmD/ft5N68u9pxMU0XhqxT2Qc8jnBMkS0JfOfpIyVFOzZ/injwneuZHNQ2rhfVQUcK84VYLjBjYvjR3N3Fey6XmEyTmNyKeuiQ3E+ORFijWAlDSV6SGrMKZwf0otAPTke9YbJbIqYTfIpLRsQseLDVQSW7JTcsCCHl22Viy3+cC+Q7V1r2TyVt8mFkMAkhAubzrYasIvr6d3fio6bpQpzW2Klqw21ajuDILDBiBCr58dso9oXjP++y5E4gN/xp57GYCUtdL+/JRU/hKVOUFjtkZGWoKh9Ic/9OHpYTiCUSUJHnw3Y8L6wYzRkrnVnmwP/j+nl397bmJiOqfxzmZ2lJvUfL6RRe+WAfrzuo=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6354BF88B6CF574CB9E48124A6928505@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: f69183ac-cd4a-4b90-2377-08d6f64ac1f9
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Jun 2019 13:17:05.9715
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1725
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=579 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210110
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 21, 2019, at 5:48 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Thu, Jun 13, 2019 at 10:57:47AM -0700, Song Liu wrote:
>> After all uprobes are removed from the huge page (with PTE pgtable), it
>> is possible to collapse the pmd and benefit from THP again. This patch
>> does the collapse.
>>=20
>> An issue on earlier version was discovered by kbuild test robot.
>>=20
>> Reported-by: kbuild test robot <lkp@intel.com>
>> Signed-off-by: Song Liu <songliubraving@fb.com>
>> ---
>> include/linux/huge_mm.h |  7 +++++
>> kernel/events/uprobes.c |  5 ++-
>> mm/huge_memory.c        | 69 +++++++++++++++++++++++++++++++++++++++++
>=20
> I still sync it's duplication of khugepaged functinallity. We need to fix
> khugepaged to handle SCAN_PAGE_COMPOUND and probably refactor the code to
> be able to call for collapse of particular range if we have all locks
> taken (as we do in uprobe case).
>=20

I see the point now. I misunderstood it for a while.=20

If we add this to khugepaged, it will have some conflicts with my other=20
patchset. How about we move the functionality to khugepaged after these
two sets get in?=20

Thanks,
Song=

