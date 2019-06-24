Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FDFFC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 04:27:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08927208CA
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 04:27:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="TLG0EvqL";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="B6yi5Vl3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08927208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BED16B0003; Mon, 24 Jun 2019 00:27:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 948D38E0002; Mon, 24 Jun 2019 00:27:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EA818E0001; Mon, 24 Jun 2019 00:27:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B58D6B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 00:27:46 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s83so20409763iod.13
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 21:27:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=XuTjufMvw1F3LPzFlw9eNFH3K9AJjMcbnTPS75xB6GE=;
        b=h3e06RD6p6Zz7XFVERyhFVmXLvxvuiQEB/gQyXzqrfzUrZOlwqSWjePO+qd80S3kLf
         RKCCJqn4BSQvGSBgAmdCgUOrwvSmpVKTFsCbxlQk7DsQC9sKhEmrzRGU1u0HD2o7Ct1o
         ILYOL2G5sV3xwX9dm2Z3qU2cWyToNehLl4VSjUQU0D6/2uFp2N4t22DpADEaRW5xBHuD
         zZY/B6+i9IqgKHuGS1Uc0Ml+k14CjP/am+UDgLwW+pAjMDiBBaPtR7JhdNdkEXR4n9Pp
         uy1Euo0Nvzbdc86Ube2AMN/UlaGZ+TqBkYmJFi7iO53jTfT/8mVaEdECwJBrc/9Rbjfr
         u3+Q==
X-Gm-Message-State: APjAAAU3exNo7Nx+evmbuJJKDBZM3QaCq1zj3aT5NKGMb/02QgVP1r0U
	905s3Z7SaQgORXiOAM45qOlbhY28Zm/9yATjxMsYsF1MF/v60pqYCdzs0dyS+jbLb5MWjB9df+c
	0lovFUbZl77YhtG5hE0tcoq6v6R4jrdTPQvB9DPxPdQlzMGacXw/zjhprE+HuOFl2KA==
X-Received: by 2002:a02:7c2:: with SMTP id f185mr11669435jaf.16.1561350466015;
        Sun, 23 Jun 2019 21:27:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwK35ZwI/doUwELCNJCLbvd6s88Fw2viz1HCmc/OPc6q58xxMTUDQNiY+n1y7/joyYZp5Gp
X-Received: by 2002:a02:7c2:: with SMTP id f185mr11669396jaf.16.1561350465295;
        Sun, 23 Jun 2019 21:27:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561350465; cv=none;
        d=google.com; s=arc-20160816;
        b=aicGciQlYcfyGHWQCGxBRuBstwXyAN8QRiXQj6aE4QgSSjbqqNkKQkfWSkOb9txYEE
         hWCN1yVag2MjauIvd/8dHpJo3JqP7XOiOb0cXw4ni2MLzuH5pkEYJzfwRLBRJ49D2b6j
         ueX+lXC3gWM1GGNQaF5WVJnZtW6RJA66rmfxUT/uqY0EkJnW+7Au9LBDR+Ca332Tfco6
         uOfaMp8TlD7XT+BDnz7n4+JN+WQw/ovlaXhyslww+C43rWYWv42LUf2RMdNkWDXd2ayb
         IO0uZjKZKf8e49ObsmOnEzkw6/WkI93oxnDcABLYxvetMCI9zyxQVeHrLoU7ie0q5fPv
         QCPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=XuTjufMvw1F3LPzFlw9eNFH3K9AJjMcbnTPS75xB6GE=;
        b=PrJ2lZsc9yRYUbMvCrxi4yTQyMGruKaHX1M1fyQFHXUEiXyusvJNIBNvLsTy+ceu2p
         GjSeZ1fz0nsDasK/zjiV0a/AoFvL72sSTLLmdYoPjOM7T99e011kV6PliMFrT2Mkbn42
         j4m0zt1RCjw2hQc21ypf4IkmLY5PF5I+L9Pu3SmyeWI17MjRlganqAp5dSsCY4Ut8k/s
         IKDaN4x4g3WZW3Zyx55wzsHcMziCyFOSplJIJu7shqriadBXFQkja92hecy+wljAl6aP
         Q+Zd7BlB0zqP57sjbMp5R9fcYit+NKHSsKsnWbdM2siUjkytoLOqIM1NlPNEkc5wBk9m
         NAfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=TLG0EvqL;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=B6yi5Vl3;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g24si15399410jao.59.2019.06.23.21.27.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jun 2019 21:27:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=TLG0EvqL;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=B6yi5Vl3;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5O4MUB0010133;
	Sun, 23 Jun 2019 21:27:43 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=XuTjufMvw1F3LPzFlw9eNFH3K9AJjMcbnTPS75xB6GE=;
 b=TLG0EvqLadctEf3wQ1gcbGiwKgnt1GAGZKOIpnat2IbQuTi8Qw6TJWDmnbWXfacm7nRQ
 UFDywD2TCrH8KrowxuRGSODlmkHrv1SGnoV99x8BHzoJUHpicHE4Ob+xmdOiAPeerKG9
 jSUCZdsJbLKnbtHC8H4gba+LLyHbeaBzjr4= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9he9mrd0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Sun, 23 Jun 2019 21:27:43 -0700
Received: from ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) by
 ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Sun, 23 Jun 2019 21:27:42 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.101) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Sun, 23 Jun 2019 21:27:42 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=XuTjufMvw1F3LPzFlw9eNFH3K9AJjMcbnTPS75xB6GE=;
 b=B6yi5Vl3DUKwpCdutqT7m6zMQPeMRwyAWdC14fh7GRh4P5dCZ4VFjYx7plw5cTsHxbXJzuyVkEO7sGCChYl2xZi1RdoILX5mB+BIE8SAjDv4qy2kAZ5jK1oatB1LeEEev7Ha8OaPvJ3dBvMp0BT4KfAHMIzc4kCni3tX81jtQis=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1278.namprd15.prod.outlook.com (10.175.3.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Mon, 24 Jun 2019 04:27:25 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.014; Mon, 24 Jun 2019
 04:27:24 +0000
From: Song Liu <songliubraving@fb.com>
To: Hillf Danton <hdanton@sina.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 5/6] mm,thp: add read-only THP support for (non-shmem)
 FS
Thread-Topic: [PATCH v7 5/6] mm,thp: add read-only THP support for (non-shmem)
 FS
Thread-Index: AQHVKjs2dBa2nM4KLk66F9b20QIHQqaqNccA
Date: Mon, 24 Jun 2019 04:27:24 +0000
Message-ID: <3959BFED-F105-4CDC-8490-B48337812276@fb.com>
References: <20190624031604.7764-1-hdanton@sina.com>
In-Reply-To: <20190624031604.7764-1-hdanton@sina.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:2524]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1f412b9e-6367-44e4-7336-08d6f85c4225
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1278;
x-ms-traffictypediagnostic: MWHPR15MB1278:
x-microsoft-antispam-prvs: <MWHPR15MB12780CE6476F80A4233D7CE6B3E00@MWHPR15MB1278.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 007814487B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(39860400002)(366004)(396003)(136003)(189003)(199004)(446003)(66946007)(46003)(11346002)(99286004)(73956011)(66446008)(66556008)(64756008)(25786009)(6246003)(6486002)(66476007)(5660300002)(71200400001)(71190400001)(486006)(57306001)(6436002)(86362001)(229853002)(476003)(6512007)(53936002)(4326008)(6116002)(68736007)(6916009)(76176011)(81166006)(8936002)(50226002)(6506007)(81156014)(53546011)(102836004)(2616005)(76116006)(2906002)(8676002)(305945005)(7736002)(316002)(36756003)(33656002)(186003)(256004)(14454004)(54906003)(478600001)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1278;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Fh8FU9fBWXQPfCRS0fNoGHNF67Y+mYRaB7q0GheRnNGJXWIzQxvL3rtZ3zwbEt9DrjKel0OA4PDbjcCSXMY4gYYXzr7/aEzanRERh4UcwSyS4j4OVi9dogaSXCcZUzbBlD+SfbiVEiVgFJ6I3+tIfhEduCQVr656ug2cnivHWlNgSNYUTXF26PMYQ87RvZ4OOoElYby4EiYv52YynLX2qLExI2aEY1i9Nlp4F89ZzpHOzOb/124acPnOjBG47QvExoHbv7mSDlNMdyLNSknhT3oFheydwSr0nLxF+1hl5V8iJB9c+CosZpNEqwMcz7BJPxCbhJzYBHoyV9XJx61l4iyIkvK80ZXm0Ch61p0al7dI7y853j09gMUArTmJGuktl2m4i3FlRqjp5oQ1HH/8QW1OW+cJC2RJ4y9duzMOjlI=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B635E38414FB2D44A9FA87A5C78512A8@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 1f412b9e-6367-44e4-7336-08d6f85c4225
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jun 2019 04:27:24.8192
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1278
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906240036
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hillf,

> On Jun 23, 2019, at 8:16 PM, Hillf Danton <hdanton@sina.com> wrote:
>=20
>=20
> Hello
>=20
> On Sun, 23 Jun 2019 13:48:47 +0800 Song Liu wrote:
>> This patch is (hopefully) the first step to enable THP for non-shmem
>> filesystems.
>>=20
>> This patch enables an application to put part of its text sections to TH=
P
>> via madvise, for example:
>>=20
>>    madvise((void *)0x600000, 0x200000, MADV_HUGEPAGE);
>>=20
>> We tried to reuse the logic for THP on tmpfs.
>>=20
>> Currently, write is not supported for non-shmem THP. khugepaged will onl=
y
>> process vma with VM_DENYWRITE. The next patch will handle writes, which
>> would only happen when the vma with VM_DENYWRITE is unmapped.
>>=20
>> An EXPERIMENTAL config, READ_ONLY_THP_FOR_FS, is added to gate this
>> feature.
>>=20
>> Acked-by: Rik van Riel <riel@surriel.com>
>> Signed-off-by: Song Liu <songliubraving@fb.com>
>> ---
>> mm/Kconfig      | 11 ++++++
>> mm/filemap.c    |  4 +--
>> mm/khugepaged.c | 90 ++++++++++++++++++++++++++++++++++++++++---------
>> mm/rmap.c       | 12 ++++---
>> 4 files changed, 96 insertions(+), 21 deletions(-)
>>=20
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index f0c76ba47695..0a8fd589406d 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -762,6 +762,17 @@ config GUP_BENCHMARK
>>=20
>> 	  See tools/testing/selftests/vm/gup_benchmark.c
>>=20
>> +config READ_ONLY_THP_FOR_FS
>> +	bool "Read-only THP for filesystems (EXPERIMENTAL)"
>> +	depends on TRANSPARENT_HUGE_PAGECACHE && SHMEM
>> +
> The ext4 mentioned in the cover letter, along with the subject line of
> this patch, suggests the scissoring of SHMEM.

We reuse khugepaged code for SHMEM, so the dependency does exist.=20

Thanks,
Song

