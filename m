Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5072C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:24:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7500B21BF6
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:24:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="mPU9f+UF";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="jLQti4kU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7500B21BF6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3EE36B0008; Wed, 24 Jul 2019 04:24:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEFB58E0003; Wed, 24 Jul 2019 04:24:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDECC8E0002; Wed, 24 Jul 2019 04:24:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A63386B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:24:32 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 6so28081355pfi.6
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:24:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=GuAGw17RyXr9asPnSzz9uWgs7lzuU8WSPVhALxvK5a8=;
        b=WLSi/Qk57PlaiTReRxGTdLn7PrdaM8N4Gscemn2YfrotQmt+0nODd1r1kF+NmauSXL
         L52oItcDYOgwZdznMVLAwQiD4UaSGgpXiN8jBDHK9WRCaOfZrow2Cllzs5zTBeZtbl3e
         5ifD41CJ6gI0lLLYJ3gZO+hof2C2uoDKm1gjetvxAePWhZcdtDq49/Irq4aB/fX9VJV1
         BEGCU3KBXgr9tmXC4AOXGIuehpm4g/EHUPPrjpz/lapWkfV1KTBYymjrHNj4T/b1R/FC
         X8EbSqEb+cyD6vdD3ITEod71PdrYggMfVE0c9WpFvBDLVqmqk32FnNhbexZlyPg/Uios
         wrew==
X-Gm-Message-State: APjAAAVCc0lxH+mmZN8syNqFhzjDPvW3Px74I26LYu4l2S8H36GlbVfm
	2dWMM9s9jA9hsZF1fh0uxdi8bYvkFn6bLDzMHRBheFhjfigTbyFsw0Id5NAzT43ilwLCYy5XZfW
	KHLQXQl6Z+ahLhMWDD4nsbwHrigBVacIRE45TccR0seH+qkUVPTO2nl+ooZWk4qKDDA==
X-Received: by 2002:a62:1616:: with SMTP id 22mr10270719pfw.120.1563956672265;
        Wed, 24 Jul 2019 01:24:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuLNJPPUYjuOKKb589lrJvDtl9OzoDirfi5qKkle+ZgEy6Uiq+APW36Z3Y63CyBgZ3DmvG
X-Received: by 2002:a62:1616:: with SMTP id 22mr10270681pfw.120.1563956671565;
        Wed, 24 Jul 2019 01:24:31 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563956671; cv=pass;
        d=google.com; s=arc-20160816;
        b=TojmKV3bhAAFU1RAIsaig2KUsBeA6xWljtGf3yR6GmdHC3JeR2AV1GeD4BdiRc5T1L
         S4CQ0GEmYOn2Di+KTD3hoGsCXr79y9LnfYWuwCSUspQ25Q9v6bMbJPtpMYckZzzYOxcT
         vahm2W8ynaxeObx44dTiOrMkz2pCjLOBqZcV4ko5fBxwq7RPst2RO4xAvLzwpg/pn1K6
         Ks1kUdXIW25MMZ26x0SwYObf4zKOvl3/us57+IKYtPGzIx1KjGE24E+BnJ4n9OLHx8kE
         VbCQapJd2ez107kb3/RgodX0Wi7HXAgH+0U0x0LJfHcCewCsd3+TTikifH7vRDIfQWQc
         D7CA==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=GuAGw17RyXr9asPnSzz9uWgs7lzuU8WSPVhALxvK5a8=;
        b=De+k32A1TMOWId6lXU/7+cNR9ojb9vUwo1hDKGRgc3wjHn7YnLOYP6A1voG6sJ19tU
         aZK87DbVnuzcpQhRNOpoZVAuES+fS06MkTb8zdusvk5b2ZCOymHoVZ6UgMf2VRE+VNtI
         Af97/k/aGtflKA4YLhX2HvQlG4UYBV5+kmqUmQhh1raYBy+VOISORUIaUPEVujHl3uFd
         foZmJa7kRpgXGH5Hd9Umv6VrV72Vkea5yP2bgGiy18TNaeGmrz+RtClVo6/wF8Tqx31K
         NKRIwXjfaGBIyKR2V6M84G7ipXVBmG8WPapXQBM4Q8QobZHR4Oih+C3MzC9PwideGKU/
         ol0Q==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mPU9f+UF;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=jLQti4kU;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l10si17260513pgp.411.2019.07.24.01.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 01:24:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mPU9f+UF;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=jLQti4kU;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6O8N9q9029716;
	Wed, 24 Jul 2019 01:23:56 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=GuAGw17RyXr9asPnSzz9uWgs7lzuU8WSPVhALxvK5a8=;
 b=mPU9f+UFvMhibuKDLHkXH0WG8A38VYedF2P1O5V2qTi75UN9oDo2skNfa2Zdfjj2oApH
 3dmenPGGJn3MzkCxHlei/glFwAvBQSCpgemD4RjECdPI4wFZLqUewV1stac8UV+p+8fC
 BG+rW8XWla/DU0iyBVF/07TRROLzwftPRlE= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2txcwah93h-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Wed, 24 Jul 2019 01:23:56 -0700
Received: from ash-exhub204.TheFacebook.com (2620:10d:c0a8:83::4) by
 ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 24 Jul 2019 01:23:55 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.100) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Wed, 24 Jul 2019 01:23:55 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=l29Ig/KyqrgfB9BYbottv5wEIJ3b3YYLujQtfqum1cO4J8FjjRdhk8qJqYhkKJ0DPfEPN/q3xOIoSFFfcs3qFk/Tz6XcH5Cd72Z0iqC3MVvuHN65l2qTenP4nNDGVxy8tKo0GCss+cZWP/H4L8U6tjkbzsHeEKblovJBlpcM6I02O4Fc50eBdm701MHe63VcwJcLSG7Pl7WmXy1m+aXXkt6Z/tym+8y9jMonZDRSaDH/41cV5YOygeMpF3QxxzTiHLDXodK4dWd/xjs1s/94XCUUQOvHYHto4VuPU+n5gk5xFJLTxoU2enMUJw71RK2Cnahr0VasU2XfDLhGM9q9XQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=GuAGw17RyXr9asPnSzz9uWgs7lzuU8WSPVhALxvK5a8=;
 b=dCgZ6gPpp9lhjvfCFPPJ2daz/RPSRlztDLEukly8ZaWSAnbz4XLvTfkKV4D3nP2ndcwkZMlXzQ2K9YjmQZYcR8GQRwHwHzlrFGpI2/rT9pl2RGrU0+aBvDFSyQgpl3jVB6bEj/4yOBWsfl+IinTF2monUk6S9pA1tlvyGIKn35NNrLcX7o8K8/1mwexRHI1KhHEUjK9bvME3Ul2zKf39EYPoJmUPmzfY4btUTlCLj0bB3uY1p+AbapZ1eRhWQ0sYVGKQW/5NwXbxdZSA8ynBLHsPgP3lGZUFDxdNChcdNGJ+zbsVIbhchKTkYxoG+NGkivTrjraBI1wfRNUYpGKflQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=GuAGw17RyXr9asPnSzz9uWgs7lzuU8WSPVhALxvK5a8=;
 b=jLQti4kUHSLZcb+8hbmYS7GtrSkuY8au7YgDlsusPqeUaM5iJQL70z7NY9zBAhvuphOBa8slBAVeSdX/xSRA+auRTXcPn5Dq1Vj9XasQPkw2Wyd5N9y38dWjjmLSN0FsZXNRdInLV1yV86akQ+izLUFi5AbNZ9peiDu4tlzLGTA=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1886.namprd15.prod.outlook.com (10.174.255.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.17; Wed, 24 Jul 2019 08:23:53 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::4066:b41c:4397:27b7]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::4066:b41c:4397:27b7%7]) with mapi id 15.20.2094.013; Wed, 24 Jul 2019
 08:23:53 +0000
From: Song Liu <songliubraving@fb.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        Matthew Wilcox <matthew.wilcox@oracle.com>,
        "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Steven Rostedt <rostedt@goodmis.org>, Kernel Team <Kernel-team@fb.com>,
        William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v7 2/4] uprobe: use original page when all uprobes are
 removed
Thread-Topic: [PATCH v7 2/4] uprobe: use original page when all uprobes are
 removed
Thread-Index: AQHVK7E/mgao02pfukuBDym1pWgYbqbL65wAgA2vQ4A=
Date: Wed, 24 Jul 2019 08:23:53 +0000
Message-ID: <EA58E3BD-7EB1-4433-8F7F-1E3894F8D563@fb.com>
References: <20190625235325.2096441-1-songliubraving@fb.com>
 <20190625235325.2096441-3-songliubraving@fb.com>
 <20190715152513.GD1222@redhat.com>
In-Reply-To: <20190715152513.GD1222@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:87bf]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c2dfda01-d6db-4416-421c-08d7101043c7
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1886;
x-ms-traffictypediagnostic: MWHPR15MB1886:
x-microsoft-antispam-prvs: <MWHPR15MB18861F8CEBEAA4E23B742C36B3C60@MWHPR15MB1886.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0108A997B2
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(39860400002)(366004)(136003)(376002)(396003)(199004)(189003)(8936002)(71190400001)(66946007)(71200400001)(53546011)(46003)(86362001)(316002)(76116006)(6506007)(186003)(66556008)(54906003)(76176011)(57306001)(11346002)(68736007)(478600001)(66476007)(486006)(64756008)(6116002)(102836004)(2616005)(476003)(33656002)(50226002)(229853002)(14454004)(446003)(6246003)(305945005)(7736002)(6512007)(25786009)(6916009)(53936002)(81166006)(256004)(66446008)(4326008)(6486002)(36756003)(4744005)(8676002)(5660300002)(6436002)(99286004)(81156014)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1886;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: DM9bz7qTmOMV7TTyawcNnCXSKtlWkjAHLvxeTjdnIvUz5+J/Ydhtvmsw0fKLU9TmiY66u39Zh0PNgij00rfJRTwgDsHLCvhJL2w1ynmBsVm28CE7Qgx5VmatwkQDcc9gQLOZl6PTk6Z89x7DhIDW4sHLpGXLjO5CUo52dfiTx9V2ubEEVPVaI9Yc4a6Zluetnh9aQ4ZWP7qd9ahg+tHEM5HuHEyDunooY82+SBKBc+6S1xS83idvRG+mg63mFnGGAAIHMxWlzBh2xpBpsyaGQ3qbEw+/cgHEr756k6MVMPdtITwgpj1HVLI/POkKMgPQYE+jApcd669je/S4K6yppwF5ky59n3rh3aTCmZpm+SI/r/p0QaPuC9q/8a9Nz1LUNBaTLQsNwG9LrWTRloLTmO2Qc4Vrs79yOPIQcxOIRJo=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8F2491EDA647EE46934F82283A5D9F9B@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: c2dfda01-d6db-4416-421c-08d7101043c7
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jul 2019 08:23:53.7726
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1886
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-24_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=836 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907240094
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 15, 2019, at 8:25 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> On 06/25, Song Liu wrote:
>>=20
>> This patch allows uprobe to use original page when possible (all uprobes
>> on the page are already removed).
>=20
> I can't review. I do not understand vm enough.
>=20
>> +	if (!is_register) {
>> +		struct page *orig_page;
>> +		pgoff_t index;
>> +
>> +		index =3D vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
>> +		orig_page =3D find_get_page(vma->vm_file->f_inode->i_mapping,
>> +					  index);
>> +
>> +		if (orig_page) {
>> +			if (pages_identical(new_page, orig_page)) {
>=20
> Shouldn't we at least check PageUptodate?

For page cache, we only do ClearPageUptodate() on read failures, so=20
this should be really rare case. But I guess we can check anyway.=20

>=20
> and I am a bit surprised there is no simple way to unmap the old page
> in this case...=20

The easiest way I have found requires flush_cache_page() plus a few
mmu_notifier calls around it. I think current solution is better than
that, as it saves a page fault.=20

Thanks,
Song

