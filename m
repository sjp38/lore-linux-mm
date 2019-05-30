Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8448C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:37:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D6B724476
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:37:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="mEKjcb4y";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="SgV7m4q8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D6B724476
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D67B76B026E; Thu, 30 May 2019 13:37:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF1F66B026F; Thu, 30 May 2019 13:37:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6C436B0270; Thu, 30 May 2019 13:37:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 775366B026E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 13:37:47 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 61so4356929plr.21
        for <linux-mm@kvack.org>; Thu, 30 May 2019 10:37:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=dYvSx3n73QE5SPrO9pQBHil9DGJ6/LAvj9gyQnfT7kk=;
        b=OHIWVZhdkkXQdygbgvosx6DYZK0BUYbVPJX2ieUiFCfjBVCrwmAKOlJAQppkFN+wP1
         vi9PJ86fbZUsd35jknF+VpU5VxOKffpruYmXixxZn670ZtRFmiILPg2wRk3tRthmcy5Q
         xZSp9/bW1cGCJOrk99BXDrOb0tF4vo0nyeBckptN3/IkujXkp/3b85nXVq3Pp2QcPdhI
         zK4AU6LIH1I8Bi9IjWeEGzGZQIYGhj/z0mIPbWb+8Zh1dC+8DOoJhG6qRK01pLkOSKGW
         QdGTOiWJbItGv/XEZaddv3lXafKNuOxYYJDUf/J5o3Ni5iamMe+mZ0YbEWczu8urh7RZ
         5h0g==
X-Gm-Message-State: APjAAAVKN7jJ7CC4WgIlWbmIZAQODbNub1uwLRs7KfKolGaJFdHqVUei
	VdN9rqr+wiJ0cGkgFdGpXrcCkz/+iyDa3gCQoh2It80IktYVdCiQstPFVp77PvoHwRfW3x0sOpo
	/MVkORap3JUeRjo4tVgOQ0HV4Fux5pC7j4jmqhokhDthxIu02PcwjVGJvk8EZ8KBrUA==
X-Received: by 2002:a17:90a:7f02:: with SMTP id k2mr4786050pjl.78.1559237867166;
        Thu, 30 May 2019 10:37:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgGjM17/0G0FoMWxJCA8M8ZFlwOaodLH/RVpxaUlL0MH5da+Tebjrq8oxQNfo68GzzKWm5
X-Received: by 2002:a17:90a:7f02:: with SMTP id k2mr4786010pjl.78.1559237866520;
        Thu, 30 May 2019 10:37:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559237866; cv=none;
        d=google.com; s=arc-20160816;
        b=S18TF7qfH3I0bqLkyWXlMHymO2lXs9cqxEt6wOUZyJrmSfVeQZauShcKgvLJ8br0X9
         1kwLj8XAOxN7qqxI3ZsifqWvR8mNbG3X30o/Xaf+anQH1CTH6Bem5lTjVCDu7BZYHqRs
         R29F4WU2SAzIwX81iwC/EdWESHsK+C/JDdh5R/womW1w+kXRukWpHDlJ3T9dnMkCP2J3
         ybsNhJRWfaOp31/9o0MntwHwb7+jBIKY31ecCN3BVOfPrSErwPBxdWf3xhRSs19JsxB7
         2aJdpyLFimSQIBKUU5qsZ86aHcEkaleJ3EBcUcOH/KC0YYyU+9azS3sjpSeU591mvXX3
         wHzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=dYvSx3n73QE5SPrO9pQBHil9DGJ6/LAvj9gyQnfT7kk=;
        b=JvYZrzZ4aZn/5sk0YK58x6v+Rt8Fj7+29p9p/3cMc//KkeLk8XNBmNTXIA+V4bpBML
         YWXU1LtliasrInHPCHSk/u78OsMIUG/Ngc4bWVdFxA0unR8Je5PhbQh+kynrfG8g7Dy7
         3Aw7QeAgsbalkRPYTJQkgaT3UmBMcRG/+FMD6TLS3HmkeIuy56ebShLpAumo/ooLOl7Z
         bychHsKynIH9IPJ7ZTd1dkTY1Y9/ELzLhCs0JFT/okvfsLOH0Mai2IOwV0d4DtRKd9sZ
         IfhO+yupx7jaT3QcDm4IZkrS+LsRIIjY3+52cPjBuauuixMpuJUS7bJ6NPcOHXiCgfpD
         GXNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mEKjcb4y;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=SgV7m4q8;
       spf=pass (google.com: domain of prvs=105329df1d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=105329df1d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m15si3835614pfh.46.2019.05.30.10.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 10:37:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=105329df1d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mEKjcb4y;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=SgV7m4q8;
       spf=pass (google.com: domain of prvs=105329df1d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=105329df1d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4UHRerI019186;
	Thu, 30 May 2019 10:37:13 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=dYvSx3n73QE5SPrO9pQBHil9DGJ6/LAvj9gyQnfT7kk=;
 b=mEKjcb4yrYMTXS/uzghFQQjCB5hWBeA+2/LxHOlz/kdXzvZJH1KvFM0go0O+hSE3uJTn
 S7cgAFeaMiPktjiEgAosVIuePMNd8PhgarC+Dq1TJPFXspoQKwrcn1sG4lOgm+JggI3C
 Ssl2zvFyY2vcdisy+UB2mbR4/tTU6uXY/sM= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2stgkcrrby-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 30 May 2019 10:37:13 -0700
Received: from ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) by
 ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 30 May 2019 10:37:07 -0700
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.173) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 30 May 2019 10:37:07 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dYvSx3n73QE5SPrO9pQBHil9DGJ6/LAvj9gyQnfT7kk=;
 b=SgV7m4q8PkUAEPK0HF2bYXh8RJF600nC7MUtVeFrFsVnu4AmG2D+PkAbM8CyL1/79ADJcuVLjTHACqXG1hs7WSy0dqlxmQMaS8wiVfMyVlLC7MYkcGdLfyvLhOwJyEL3DA+HdxlYu6Qe6pPBrXpLtSjs4I5uDnadAj/LtbiJ2nM=
Received: from BN6PR15MB1154.namprd15.prod.outlook.com (10.172.208.137) by
 BN6PR15MB1859.namprd15.prod.outlook.com (10.174.115.140) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.17; Thu, 30 May 2019 17:37:03 +0000
Received: from BN6PR15MB1154.namprd15.prod.outlook.com
 ([fe80::adc0:9bbf:9292:27bd]) by BN6PR15MB1154.namprd15.prod.outlook.com
 ([fe80::adc0:9bbf:9292:27bd%2]) with mapi id 15.20.1922.021; Thu, 30 May 2019
 17:37:03 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "namit@vmware.com" <namit@vmware.com>,
        "peterz@infradead.org"
	<peterz@infradead.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>,
        "mhiramat@kernel.org"
	<mhiramat@kernel.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "chad.mynhier@oracle.com" <chad.mynhier@oracle.com>,
        "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>
Subject: Re: [PATCH uprobe, thp 3/4] uprobe: support huge page by only
 splitting the pmd
Thread-Topic: [PATCH uprobe, thp 3/4] uprobe: support huge page by only
 splitting the pmd
Thread-Index: AQHVFma7iu6PqkG6zkadRvREvp8axaaDlYUAgABaQgA=
Date: Thu, 30 May 2019 17:37:03 +0000
Message-ID: <2BF5CB81-166B-45E8-908A-CF5EDAEC05D1@fb.com>
References: <20190529212049.2413886-1-songliubraving@fb.com>
 <20190529212049.2413886-4-songliubraving@fb.com>
 <20190530121400.amti2s5ilrba2wvb@box>
In-Reply-To: <20190530121400.amti2s5ilrba2wvb@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:bc80]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c3e1cac9-7d79-446b-a22e-08d6e5256da6
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BN6PR15MB1859;
x-ms-traffictypediagnostic: BN6PR15MB1859:
x-microsoft-antispam-prvs: <BN6PR15MB18597C0843BFDE593349F381B3180@BN6PR15MB1859.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 00531FAC2C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(396003)(366004)(136003)(346002)(39860400002)(199004)(189003)(6506007)(53546011)(91956017)(66476007)(66556008)(53936002)(229853002)(6486002)(73956011)(68736007)(66446008)(7416002)(66946007)(186003)(5660300002)(102836004)(25786009)(486006)(33656002)(6512007)(6916009)(64756008)(76176011)(11346002)(256004)(14444005)(6246003)(6436002)(86362001)(54906003)(99286004)(305945005)(82746002)(7736002)(81166006)(4744005)(6116002)(81156014)(71200400001)(36756003)(316002)(476003)(2616005)(2906002)(478600001)(14454004)(57306001)(8936002)(8676002)(50226002)(71190400001)(83716004)(446003)(4326008)(46003)(76116006)(14583001);DIR:OUT;SFP:1102;SCL:1;SRVR:BN6PR15MB1859;H:BN6PR15MB1154.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: JB/7bIZPhvXvN7NNelf8yYrFjwTNfqCZVMvX/jZ2CXFIuOnJhfxWtRi4bykdtd8IyXXIZruJHZsC6UdaTruXc511WdwZ2oSHEQeYWgwdIs7KTGaHTO1ohnGUixqEvnmMg6G2/fJpDyeB/dE11DzR/ld67VJzz3Zi8zg7waqh9WTpCb6ZkLDSS7f3CDv+grS6/DL93llK8v2yNTARu/5SBY6o1ZXBKKrBp7VQZQSamjtfzOavfMRQNYKAUotMrBFbY18WEI84qlmMP913rQltOynaCGWrb0saN37zYouxgqHxRMfEJx/+JzrbLz6H1Qt58+mMRfhBFG3mYl/L66SV22RDReKLAuDFi1qMZKFYiMkKEB7JPZr8lfcweoo2a/qF5/s2vHDsL676PhJrbNDnon2+q+Mf4azgLcWZ/h85TZo=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8F4D7D9E124AFA45A85763D4C3198CA2@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: c3e1cac9-7d79-446b-a22e-08d6e5256da6
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 May 2019 17:37:03.4130
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR15MB1859
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-30_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=901 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905300123
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On May 30, 2019, at 5:14 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Wed, May 29, 2019 at 02:20:48PM -0700, Song Liu wrote:
>> Instead of splitting the compound page with FOLL_SPLIT, this patch allow=
s
>> uprobe to only split pmd for huge pages.
>>=20
>> A helper function mm_address_trans_huge(mm, address) was introduced to
>> test whether the address in mm is pointing to THP.
>=20
> Maybe it would be cleaner to have FOLL_SPLIT_PMD which would strip
> trans_huge PMD if any and then set pte using get_locked_pte()?

FOLL_SPLIT_PMD sounds like a great idea! Let me try it.=20

Thanks,
Song

>=20
> This way you'll not need any changes in split_huge_pmd() path. Clearing
> PMD will be fine.
>=20
> --=20
> Kirill A. Shutemov

