Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8DB2C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 16:30:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 706E420673
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 16:30:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="U3s/yHg0";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="kGUuYYiT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 706E420673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E6286B0005; Fri, 21 Jun 2019 12:30:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 097918E0002; Fri, 21 Jun 2019 12:30:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC7D08E0001; Fri, 21 Jun 2019 12:30:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id C9FFC6B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 12:30:57 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id y205so6879997ywy.19
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:30:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=0qTXnWbgZ2y9IbGAMibal2DIgS8gvxNT+41nZ2D/Dl8=;
        b=VDUEJ8eBdrxt06s82TQlG2tBVy3BQOS90OaLgwANPDSBkz02skknw9RN2teB4rtjr1
         d+rI8p99/os7cfN93H7/U61ZMDCx6QhSYhP10kHOApBhCy6NC+5O/iTYNucbtnhGEn3o
         J1qIJYC4DMnVWgridfeLLuPYWL/UvejDPxj6Yki527POcCzy+bwYfkuzVDQn5RyYynNl
         vcmseBwkXOnsKOuhlQiHICvlE4eWnxz/DwE7Z6szVQ2MU722p8MOKBH6A2p3ekOQ+SeE
         vU6jsyd97Vvf32bQ0qqCM4MskGx7lpkmAoqM3ZLt4UIiFOXzplxtasz3s2Rsm1jSuUuK
         6VFA==
X-Gm-Message-State: APjAAAWxRhSAjQ0E01BaZ7405XUKjM9py5E66sqMD3HPfN1oE35iQYAL
	PdsI/Dc9dXV8v8CL+s5Ky72+qiwN2zJ/qW4xGvVX0leNDAfYCLi/joMyzAa8aL14pX13M6NrH8a
	aAI8BFrBbGnti4irn0W+Gw43+z2PqMJz8+K6hhUgvPNpL7HzLxFGKbMx6rixGmybGcQ==
X-Received: by 2002:a0d:e650:: with SMTP id p77mr28173078ywe.189.1561134657498;
        Fri, 21 Jun 2019 09:30:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvO7Z9v1JxrCzsLaiXguA81+1/SrQXqOBZUA+lSZnrjeMijlw8Sotzou54LO8L3UAQr6UQ
X-Received: by 2002:a0d:e650:: with SMTP id p77mr28173026ywe.189.1561134656651;
        Fri, 21 Jun 2019 09:30:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561134656; cv=none;
        d=google.com; s=arc-20160816;
        b=B9AcYhw0q5EjXVbA/RHo02EvsY9fVM8KOd3ro8u1Die75QHnrATZhT8k0BwMXPFKZ5
         NljD4MCrQl+Rqt/wxwZsfyqBuNuEeSZIkt6DpkygmESSXkt66E6ucZertQvhO3xWgrol
         wfQux1pPUnPLsWAFHaIIsw/mrqKTxz+Pa3HJb2rF3ITXj8nt6fyQwDiklOlEMb8ATnNN
         16PI3R1DULI22GRW95EDjsVzBh3X90QGGxY0L8x2OdD6LacZntycTvPxFibQ11d6JJCS
         s/aJ5j2uZZHrlYiy9/ojaVsd29vcrDd+mJ5N9bLXVGrVq3DXVv3PGyR3LFGk1ElUXTym
         39vQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=0qTXnWbgZ2y9IbGAMibal2DIgS8gvxNT+41nZ2D/Dl8=;
        b=XW+1P3Pl5rfFYdz9LQB7C6VF4mH33e/rnhR5AG34SxTntBfEzkq9eqfnfFukDvhRo1
         PXNSqHaGueUHtX9QxhCx+nYi6heIQMCSVaanmoNdEu7COCuC01t8srM0bH73eO606pR5
         PtTiQpNN7KymianXYJSaemAOkUewOe8U+HJQDG8Za2dwnRFNhqMBWfmx5/lazzXkD2i0
         Kne9IcHXEiO5DK8uQEGguS9usWlUSwbBX6ssNTYGQ+StlHRvarI7B8LLa9AHpaZqtGpJ
         /hKGOGp3UUVVE9EKgJIPwKNHar/491z5lNmAZYfAehJytN0+KkDc4ksT8cUVvnJdQ617
         iD8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="U3s/yHg0";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=kGUuYYiT;
       spf=pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10751dd214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id h63si1151434ybh.279.2019.06.21.09.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 09:30:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="U3s/yHg0";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=kGUuYYiT;
       spf=pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10751dd214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5LGO01k004531;
	Fri, 21 Jun 2019 09:30:08 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=0qTXnWbgZ2y9IbGAMibal2DIgS8gvxNT+41nZ2D/Dl8=;
 b=U3s/yHg0hh7rWogH1ptMe3FO1h4BlINB0Ys7tPmYe6mmuo5mQsICNYTEcSqpGiNTtoy8
 Z2aXPvznL789zUex0QMn0BK0a4pU25PrbvGm4MaD4/xjy1YPZ4qLBLtr5k521yiI1fHg
 XUmA49IcGVzDhTjTgFHaPhb5IYD346yA8/c= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0089730.ppops.net with ESMTP id 2t8y020wee-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Fri, 21 Jun 2019 09:30:07 -0700
Received: from ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) by
 ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 21 Jun 2019 09:30:06 -0700
Received: from ash-exhub204.TheFacebook.com (2620:10d:c0a8:83::4) by
 ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 21 Jun 2019 09:30:06 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.100) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Fri, 21 Jun 2019 09:30:05 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0qTXnWbgZ2y9IbGAMibal2DIgS8gvxNT+41nZ2D/Dl8=;
 b=kGUuYYiTvo77BSwYIgm4jCvXPfn8v9Dp438QG8utOgAWcJpVDH8lvrdG+H2pEyfkBqyhe9PV3UXdaQAIp3nP8CiPXSAyTMNxgE9g99h2IbZ1jtMIqzmDvltkNCI4J+jNRspZbGHqGaYw8ODAAIR/WajGepRZKxB18uLI1dMA/No=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1616.namprd15.prod.outlook.com (10.175.142.17) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.15; Fri, 21 Jun 2019 16:30:04 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.014; Fri, 21 Jun 2019
 16:30:04 +0000
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
Thread-Index: AQHVIhGkBNxZAI1nUkK1d2OfbYvmTqamGxWAgAAIBYCAAAVYgIAAAncAgAAuG4A=
Date: Fri, 21 Jun 2019 16:30:04 +0000
Message-ID: <707D52CA-E782-4C9A-AC66-75938C8E3358@fb.com>
References: <20190613175747.1964753-1-songliubraving@fb.com>
 <20190613175747.1964753-6-songliubraving@fb.com>
 <20190621124823.ziyyx3aagnkobs2n@box>
 <B72B62C9-78EE-4440-86CA-590D3977BDB1@fb.com>
 <20190621133613.xnzpdlicqvjklrze@box>
 <4B58B3B3-10CB-4593-8BEC-1CEF41F856A1@fb.com>
In-Reply-To: <4B58B3B3-10CB-4593-8BEC-1CEF41F856A1@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::1:e314]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 637ab245-7cc0-476e-1212-08d6f665b71d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:MWHPR15MB1616;
x-ms-traffictypediagnostic: MWHPR15MB1616:
x-microsoft-antispam-prvs: <MWHPR15MB16166E627F6BB6978AEA180EB3E70@MWHPR15MB1616.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0075CB064E
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(396003)(376002)(366004)(346002)(136003)(199004)(189003)(5660300002)(76116006)(73956011)(256004)(50226002)(6246003)(54906003)(6916009)(33656002)(102836004)(186003)(76176011)(53546011)(6506007)(478600001)(25786009)(66946007)(486006)(4326008)(66556008)(66446008)(64756008)(66476007)(2906002)(7736002)(57306001)(81156014)(14454004)(46003)(81166006)(99286004)(316002)(476003)(8676002)(53936002)(6512007)(6486002)(6116002)(36756003)(2616005)(11346002)(229853002)(71200400001)(71190400001)(6436002)(68736007)(446003)(86362001)(8936002)(305945005);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1616;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: aQa6KhLL3tB5eksbA19jSs8upkISddY089JT1IO6zWnJlvIip9I1FMsDjUnVAOdG8LluV5BRIBl2eDqRXy/HEc5yyOwZNFkxFDF2D3VkYJUMp4vqTj4xXAOx0xV0dL3sNlP9Hm9M4V4R8M9zj3jfTOb1FeZmLubnyefbEsjlpwqWO0bbOyWU9y+Ges4Wyhfyxv66xSPku8WrbrGpUODwQaDEAhHV2W1wS6cgndnW6nithhAygoVQhAtAs7DMTN3j3LlZC2/DoX20ixRVQ/OsYfUXaIidUlaNd/P/aotdEwSF/g+t/QypzFe40CeEm91mD6L2jyvKVw+dW5k2p272T5nN+h2MzaaBe7IrpagF8CzX8c8SETdJ/eFP7/6tW0UxfZ7ZpCyweUiC+8cdoI+JNNe0ckd77J2uMOl6hrOpYCA=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <274FD60A5325DD41BC5BD6A652FD3B91@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 637ab245-7cc0-476e-1212-08d6f665b71d
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Jun 2019 16:30:04.1697
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1616
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=706 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210132
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 21, 2019, at 6:45 AM, Song Liu <songliubraving@fb.com> wrote:
>=20
>=20
>=20
>> On Jun 21, 2019, at 6:36 AM, Kirill A. Shutemov <kirill@shutemov.name> w=
rote:
>>=20
>> On Fri, Jun 21, 2019 at 01:17:05PM +0000, Song Liu wrote:
>>>=20
>>>=20
>>>> On Jun 21, 2019, at 5:48 AM, Kirill A. Shutemov <kirill@shutemov.name>=
 wrote:
>>>>=20
>>>> On Thu, Jun 13, 2019 at 10:57:47AM -0700, Song Liu wrote:
>>>>> After all uprobes are removed from the huge page (with PTE pgtable), =
it
>>>>> is possible to collapse the pmd and benefit from THP again. This patc=
h
>>>>> does the collapse.
>>>>>=20
>>>>> An issue on earlier version was discovered by kbuild test robot.
>>>>>=20
>>>>> Reported-by: kbuild test robot <lkp@intel.com>
>>>>> Signed-off-by: Song Liu <songliubraving@fb.com>
>>>>> ---
>>>>> include/linux/huge_mm.h |  7 +++++
>>>>> kernel/events/uprobes.c |  5 ++-
>>>>> mm/huge_memory.c        | 69 ++++++++++++++++++++++++++++++++++++++++=
+
>>>>=20
>>>> I still sync it's duplication of khugepaged functinallity. We need to =
fix
>>>> khugepaged to handle SCAN_PAGE_COMPOUND and probably refactor the code=
 to
>>>> be able to call for collapse of particular range if we have all locks
>>>> taken (as we do in uprobe case).
>>>>=20
>>>=20
>>> I see the point now. I misunderstood it for a while.=20
>>>=20
>>> If we add this to khugepaged, it will have some conflicts with my other=
=20
>>> patchset. How about we move the functionality to khugepaged after these
>>> two sets get in?=20
>>=20
>> Is the last patch of the patchset essential? I think this part can be do=
ne
>> a bit later in a proper way, no?
>=20
> Technically, we need this patch to regroup pmd mapped page, and thus get=
=20
> the performance benefit after the uprobe is detached.=20
>=20
> On the other hand, if we get the first 4 patches of the this set and the=
=20
> other set in soonish. I will work on improving this patch right after tha=
t..

Actually, it might be pretty easy. We can just call try_collapse_huge_pmd()=
=20
in khugepaged.c (in khugepaged_scan_shmem() or khugepaged_scan_file() after=
=20
my other set).=20

Let me fold that in and send v5.=20

Thanks,
Song


