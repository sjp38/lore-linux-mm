Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 173F7C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:02:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1772206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:02:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="kD42B98R";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Eq1svsfJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1772206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BD5F8E0005; Tue, 30 Jul 2019 13:02:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46D088E0001; Tue, 30 Jul 2019 13:02:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30DEA8E0005; Tue, 30 Jul 2019 13:02:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0796C8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:02:29 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c207so55475521qkb.11
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:02:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=sMqUNkLrDohNl43QagJ/TUpqn2DtW2DHAtvXZU/8Dz8=;
        b=XxnPfXUmiYUMNMDn56emv6i51zW1HbY+hWUTQ5rfNLoVhPGrI9d7jA80F//ZcEompC
         AvOY/k9DZRTagpc5u8Ig4ZxpdtvsXy8oZMR8sfn7Z0xl9RdpKKdQIoerP4DhDIasZjoj
         g9zy6QzJnpRP32ezIUSPf8AZxVyFumgQtSrpdzgiL2nOREyVlDUkCJiC10dnXZQR8i6e
         Vgn8j2l2x5GpEq7Vvr+PgzzzH0/f0rrhFUMC8TZFAqKH4ZEpCi/IkTuYIlFD7UoX1Kx+
         YV6jpxOelMMZmrOR0mLISPbvOWg1xuObzLI6ABRNR0r/HqJYnIpZTC00ox93PxV8214h
         1Zzw==
X-Gm-Message-State: APjAAAWRMh7874xBPeazEVp5hksdNENGaV+8K0s98rOgS8TfzEfLIX6l
	YAgXDBDLuO5o7ZojffTATaGUsiOakV9QGzwL1+w6Rg4KRsA6JTJa5Otx1mcbIJZnFCo2yVGKuNl
	kJOiVXIitm/K+t8M9Hw8tTfsfDYodo2XqQeEU+0bKmGi87PyVWPdz1BCCGAWHdzvbug==
X-Received: by 2002:a37:7dc1:: with SMTP id y184mr72375630qkc.58.1564506148698;
        Tue, 30 Jul 2019 10:02:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFm+NCydnEXZ9kQCyUgJdajLtH2eL1qW/vUyTTL3PpKDFUtsYG3EoSVSIVE9j7lb7mY1tR
X-Received: by 2002:a37:7dc1:: with SMTP id y184mr72375597qkc.58.1564506148112;
        Tue, 30 Jul 2019 10:02:28 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564506148; cv=pass;
        d=google.com; s=arc-20160816;
        b=QUOsoPoBBU/pfoFwGFUV6tXq/XBd1NDd6YBl/NoveHbMUHRlFiV8g+1CG3V0W5fjPH
         t7zOVARWi8oIk0pAX4Aeq1Y9L9Rqr6sFoh2OUuMMDjHNw6k2yh+up/wPeO/b0Dtp/YR2
         VK1T3BNPwjTA55umteeGVFRIerjk2RMzMsw0lst2vLJjhFQZ6mwZeg6LDvhuuwzdF2JY
         Mc+57J8vVEdor3FDf8XeJLH3vDCXmVE6TTA5FjWcx3h/yiYOdOiCqC+8C+s5c6JHNHYD
         hYLZ77MTCvWFCUZV8eCY1fSV3yKyXzNmNlR5Ce6Yu1qQqnkBEjSEfNIm/a8Jminhk0Wa
         Nq5w==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=sMqUNkLrDohNl43QagJ/TUpqn2DtW2DHAtvXZU/8Dz8=;
        b=Ge0EanNccD0m9tSasQGiUG0u4Nig/HZCvbGPlVY7NsUF8ar39pnV7jtXwFrRjwChXg
         PQgXGVKgJPkTcE1/nV/JJtmYZtql4RhCRL5rssjH8+8+h8IeZco0ihguXtN9iyx3V2T9
         sRv8S1EeGHhdjrZfSRZ4C7eYooDGSOc4ztEkGC68KPjwmaLIgvvST1bZQmZHA33kML9h
         cFeLh2FdT7vkkSuhmqoTdQZ5viLLYT4rSBJNQPnzJ+mI1TTi+6Ri3KFNvtXk0Kbekq24
         6+B+Q7TrXVBCeXJu9afYEpl42xDTJgppLXahHZJuq7f0ytBjw+XzBkJ7O6Hbs0irHx6C
         4cuQ==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=kD42B98R;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=Eq1svsfJ;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l29si40220098qtk.192.2019.07.30.10.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 10:02:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=kD42B98R;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=Eq1svsfJ;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6UH2A3a012729;
	Tue, 30 Jul 2019 10:02:23 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=sMqUNkLrDohNl43QagJ/TUpqn2DtW2DHAtvXZU/8Dz8=;
 b=kD42B98RvpZPd6BW80M2pOHOA253iTABFHXppvSMZCywuj5pqVwnsv24nOvlgqghQ5o8
 FjuJYEYVobVeMai3l8QY2Z52sSq0z35E+J6aauwH8DrEvtTSd7n+dXdAIgAe6qZkdPQF
 34pMfZsJCzmRhSprwbnT8OJu30NLXqubgqQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2u2gk2sx31-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Tue, 30 Jul 2019 10:02:23 -0700
Received: from ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) by
 ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 30 Jul 2019 10:02:22 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.103) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Tue, 30 Jul 2019 10:02:22 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=RPwy0mTcuEEw+AirnRvcy5ShNuBRcE7Rjf8W0A+LFoIyJ+eDG309VP52N6zdxveZEIrlA1k30W1MDUVm9aK+ycE4mcJyDyGQf1BhtJosXWZD8R83+T4yesJKE5jPzAmkg4Dg4Nx9aonKxCgiZ202kN5M1nh4PfuLGXKvk2IpPwJ7/Wd+uQFYkhwAEP4evAceyQgNuWkWCqGU0J++9vlu9wt9EHe5VVKWvFOlrHW+1Ji3fF5iusESvDRT0e8/RwXsnPXf1alsy8bNLBqPq47a8pyIFscm3//fahcPfs3ulql4k0c+On5/THP0KROlSjOj88Oau1G5Nl2GxieGk71v9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sMqUNkLrDohNl43QagJ/TUpqn2DtW2DHAtvXZU/8Dz8=;
 b=Sp/y/GNvVXxZYtdJhYGhAjRgqA9Pn28NpZ+Yum65QAT8P7Kc6hB46g4BVmPaeHtbwGHn9PaLuYrM5KGwn+TYt9JNNdB8uI2+ztu94B1mSF8UiCtWgo7G7AiUP7mXiG4sKFBY50i+CDYbTCux/ROUAzRu5A9+xAXUZLZd7TJA3pOImBbXGl4BmlIHyrmp0hwe7l2qrW5ViZo6NA/HwkNF6DCagTusq+Pk6czm86Oa0HBN5yfkfrudnOdLfkwLOFvfDbymAIqayi+nUfxGQFYz+Pcu6yYFAYrk3C084Lhx18LYCZq1zvwJHkxtteNJ9VAfAb6NXSST2ZT3Yby5nUJJDg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sMqUNkLrDohNl43QagJ/TUpqn2DtW2DHAtvXZU/8Dz8=;
 b=Eq1svsfJUplpQQGFFgGQdP3vhup8UieSq43HZSxr0v044Ap4n5yNcQastHrluWhYmsjfftPV65vqfXUoEY85Q8Ra6UlYRjOlXhtYJztv3h5kmsCPt6s839P7wQsDLHswkR2mPM7anGygVl9aDIN0hH3gxrJ6WbECqHMOiSDcscQ=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1262.namprd15.prod.outlook.com (10.175.3.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.14; Tue, 30 Jul 2019 17:02:20 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b%2]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 17:02:20 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "Andrew Morton" <akpm@linux-foundation.org>,
        Matthew Wilcox
	<matthew.wilcox@oracle.com>,
        "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>,
        Oleg Nesterov <oleg@redhat.com>, "Kernel
 Team" <Kernel-team@fb.com>,
        William Kucharski <william.kucharski@oracle.com>,
        "srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] uprobe: collapse THP pmd after removing all uprobes
Thread-Topic: [PATCH 2/2] uprobe: collapse THP pmd after removing all uprobes
Thread-Index: AQHVRdClSGoRT5gntEqzOPZk9S20/6bjQ50AgAAh2YA=
Date: Tue, 30 Jul 2019 17:02:19 +0000
Message-ID: <4C2B6C8C-963A-422F-B419-5D794BAAEB0B@fb.com>
References: <20190729054335.3241150-1-songliubraving@fb.com>
 <20190729054335.3241150-3-songliubraving@fb.com>
 <20190730150110.yqib7bawsude2vqt@box>
In-Reply-To: <20190730150110.yqib7bawsude2vqt@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:5cb8]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b75d4a47-e33e-4dd3-0f7c-08d7150faef5
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1262;
x-ms-traffictypediagnostic: MWHPR15MB1262:
x-microsoft-antispam-prvs: <MWHPR15MB12626FB6FC7A038FB8BD3491B3DC0@MWHPR15MB1262.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(376002)(346002)(136003)(396003)(366004)(199004)(189003)(46003)(68736007)(71200400001)(81156014)(71190400001)(25786009)(486006)(6116002)(81166006)(53936002)(6506007)(186003)(57306001)(102836004)(14454004)(8676002)(478600001)(8936002)(5660300002)(36756003)(53546011)(14444005)(476003)(33656002)(2616005)(7736002)(316002)(54906003)(6246003)(66446008)(6486002)(76176011)(229853002)(256004)(446003)(99286004)(6436002)(76116006)(50226002)(86362001)(6512007)(2906002)(4326008)(66946007)(64756008)(11346002)(66476007)(66556008)(305945005)(6916009);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1262;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: r67VQm7lYo5A6WQW9iw096lINAIe3dwEzvHSIU1bvioJ9+Bnk1mpeODMl4mMWerx8SpPg/oM4udeyX21a+EfwRbLmX21XaX0py7w31uJvYmMoVIQ0EudXgjl+Ljts5Sw1weNZ4etf4A0i5cL8FY7H0rWneVTtx5HazEkGfTNuthF9Em/7bqTooXgE+759GzEdxpXZLlLascJ1TDaNJlCCxluH6pUJZoTW1qS0HS3J41dFY6NahSc9QfvZHaHDHgtkC5DhnxXZassohj9XNp4U6z8IAMpnrA1J6eAYKogfZRJpeqPL3BW1FTeEDI6vf6fuyGW6zQ9Ga/Tg31TfnMd/kHk6Y8ZDsbPcIFF5+SdKS9LQAtn+FOcYpK054lz9X3elWbSSzxtJj/S7+jqCgdji5PZHBfVauLJ/2mV9K5U+fE=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <4E8DDDB46EDD4A47B58E21AE800ED803@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: b75d4a47-e33e-4dd3-0f7c-08d7150faef5
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 17:02:19.8171
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1262
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-30_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=840 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300178
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 30, 2019, at 8:01 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Sun, Jul 28, 2019 at 10:43:35PM -0700, Song Liu wrote:
>> After all uprobes are removed from the huge page (with PTE pgtable), it
>> is possible to collapse the pmd and benefit from THP again. This patch
>> does the collapse by calling khugepaged_add_pte_mapped_thp().
>>=20
>> Signed-off-by: Song Liu <songliubraving@fb.com>
>> ---
>> kernel/events/uprobes.c | 9 +++++++++
>> 1 file changed, 9 insertions(+)
>>=20
>> diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
>> index 58ab7fc7272a..cc53789fefc6 100644
>> --- a/kernel/events/uprobes.c
>> +++ b/kernel/events/uprobes.c
>> @@ -26,6 +26,7 @@
>> #include <linux/percpu-rwsem.h>
>> #include <linux/task_work.h>
>> #include <linux/shmem_fs.h>
>> +#include <linux/khugepaged.h>
>>=20
>> #include <linux/uprobes.h>
>>=20
>> @@ -470,6 +471,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe,=
 struct mm_struct *mm,
>> 	struct page *old_page, *new_page;
>> 	struct vm_area_struct *vma;
>> 	int ret, is_register, ref_ctr_updated =3D 0;
>> +	bool orig_page_huge =3D false;
>>=20
>> 	is_register =3D is_swbp_insn(&opcode);
>> 	uprobe =3D container_of(auprobe, struct uprobe, arch);
>> @@ -525,6 +527,9 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe,=
 struct mm_struct *mm,
>>=20
>> 				/* dec_mm_counter for old_page */
>> 				dec_mm_counter(mm, MM_ANONPAGES);
>> +
>> +				if (PageCompound(orig_page))
>> +					orig_page_huge =3D true;
>> 			}
>> 			put_page(orig_page);
>> 		}
>> @@ -543,6 +548,10 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe=
, struct mm_struct *mm,
>> 	if (ret && is_register && ref_ctr_updated)
>> 		update_ref_ctr(uprobe, mm, -1);
>>=20
>> +	/* try collapse pmd for compound page */
>> +	if (!ret && orig_page_huge)
>> +		khugepaged_add_pte_mapped_thp(mm, vaddr & HPAGE_PMD_MASK);
>> +
>=20
> IIUC, here you have all locks taken, so you should be able to call
> collapse_pte_mapped_thp() directly, shouldn't you?
>=20

Yes, we can call it directly. I had it that way in a very early=20
version.=20

Let me do that in the next version.=20

Thanks,
Song

