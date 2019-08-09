Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEE01C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:30:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8997B20C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:30:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="kIIUx6Su";
	dkim=temperror (0-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="S7LS6+Fs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8997B20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 204C16B031C; Fri,  9 Aug 2019 12:30:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DADA6B031D; Fri,  9 Aug 2019 12:30:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 055BD6B031E; Fri,  9 Aug 2019 12:30:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id CECE36B031C
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:30:49 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id b25so69678931otp.12
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:30:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=HGvAmPcpKZSvkcSRvuvQFAoo5Mvu1Mh+eSrV5Fwdtis=;
        b=rpgR5bQByLMHjQ+k1XmixaYpBHFmeTMAwrjX93RIIJNbmCto+rtiE+wyDSU7RYq7V6
         KrHGAB5776RNiRU7YFX+09GM/E8XAO7He0A6Z2jPM645oJkG5JlBpf5h6f3a5iWHP6OL
         ov46t7tACAGOka5Nqe2FttYnETryfxW46yNTeCNxGpdpa/BtDgow+vSfsdC5bQNpc3oK
         o7DkTZwbGrHv/6OS8tsztAUQpwCFwgB/XMeodR9SmDHtT722CmFgvq97TSu0eT3AyWGK
         U/beIJDSVcUkw1qgxBDc+RyFF95OGAUhu5DzUwzO6nOdFgiFdzUPX2gIoVci+RWaAIqy
         SzSQ==
X-Gm-Message-State: APjAAAUAz0G+van4cVDHCiCkgca3k0QuUYJp8lTVeZGSTGvex57Naazp
	2InVrsa/sLs6F/2mlvp1zBDp6hd4QJYVkg6awnM/I43R2RxAazOUzO7nahCZx6ZWN0i1BCoCmgF
	wbB/o2AmNvNxYT+T29SeWLxL6PmDcXUY82r7hojWVfg1+b9Wmg+GyovZEHtoSX/069w==
X-Received: by 2002:a6b:f216:: with SMTP id q22mr20937786ioh.65.1565368249373;
        Fri, 09 Aug 2019 09:30:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEDSfZGiPhnxtGHRYrhwbwADj+Ig92haTPmR7wcPJNUkC1vH3yVNAkxjiBQhhOLdrleyLc
X-Received: by 2002:a6b:f216:: with SMTP id q22mr20937675ioh.65.1565368247899;
        Fri, 09 Aug 2019 09:30:47 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565368247; cv=pass;
        d=google.com; s=arc-20160816;
        b=pZDslBEt/u0vqsmq4L5BiszGpSw0QDXu/ZuzevEvP1T0QOU4iBcB3nwuLs7zkz96hJ
         TDQCfrzyHfFyk2SOthKJnmVdXXwswYufDGReAoWRH5a0J0ZmJz+TVjauOUvsZhK+apON
         wEw53FgIcR6ODMO5LY5TvEwEvjkz0TUaKM5CloT1teZRPrpSGKtF/uRUR7CoQ5EeIaLd
         epgCU1kgkGO90/Guz6Ms8E0+nqZG/ZJzGCbaLR08Z5V5wCddmLGhDwH1JSeCl2qhI9qI
         2Vfoj/CDBicuZ/b4wUJqW663rBez/G+TMm6HQNdq0J7fJRy5EqBeEyttUKZEOfP2J4Ly
         MNtQ==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=HGvAmPcpKZSvkcSRvuvQFAoo5Mvu1Mh+eSrV5Fwdtis=;
        b=d+tDRI41L69/TsYAJOwvNiGtdoZBKJd1sCorngYijRTlvOvwTFfnPUgh9h1HciK1CK
         c+URJiR00+g+05Sq7PScVw/3gFZQug1oS285S4Ke0Jre+5IhqADrG+Zmo7HqwhaiTdhj
         DWDnCL7rXIFOGBbpm8U/JnSKUaKCbehrzacNR2Q5Zx7g/F8CVKLCvGPpYkYY1nCushDt
         WvKXjQnxoQHIkUCl6FaMNLU+AsrS+RPHpU5kf4xXnARescPENiaXpzHcF1iTzUQQuKdy
         RGE1+/YTIW8if9py2CLGEIDt9LRg9J94Bn9xnpRo4MU8gl33/MzDJtgkTz2LExaGg5o7
         SdHw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=kIIUx6Su;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=S7LS6+Fs;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3124312b6f=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3124312b6f=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u73si11717773jab.120.2019.08.09.09.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:30:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3124312b6f=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=kIIUx6Su;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=S7LS6+Fs;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3124312b6f=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3124312b6f=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x79GUHHX008602;
	Fri, 9 Aug 2019 09:30:46 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=HGvAmPcpKZSvkcSRvuvQFAoo5Mvu1Mh+eSrV5Fwdtis=;
 b=kIIUx6Sum0ILfEMv62mxcrjV7W/5cPPC4K2YUcMKAEC00yrHxHDp5e/ZVGmnq+wC7OUx
 Gi0TH2jt7gqMcHPjXPxpCEq+4m8q0Eilc6HOZf1udjrOe91cYhdOmYM/PziFkA/T2hPC
 Bc1irOdMLKe6azCspQ5TQNWsRi5zomaYa2g= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u99v9grbj-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Fri, 09 Aug 2019 09:30:46 -0700
Received: from ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) by
 ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 9 Aug 2019 09:30:44 -0700
Received: from ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) by
 ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 9 Aug 2019 09:30:43 -0700
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.173) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Fri, 9 Aug 2019 09:30:43 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Ss1JzvP98NsQz9fAqIvsbm2gijiNYQLNaIwEpvlPPPJ5fMFtJwJ+eUPZ7qmyGI9lx1jzo3R5HRforzoJRApn9rVr8JSmWUzPAEgcvMfpH62rpImGuHfWWYb6wMjXr8cv08BwI724BAFtfrdkr7HJdkMDFokEo32xnGxSwylir9lSnFGU5kOLjSDHMyQA36rKZfuLie9k9MkMBBQ/R08nlg9ee5ErSHx8qNb+RVnD+DKbLfWcKTu6+C0f36QSCfB2lH6VWNhSHLMCDgEJz5KyGeKhmMidPKidCucpcQkF3BUxSCdOmxutalqE6/HfBqF2CD4yYc/bqyLxlzxMKdzXvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HGvAmPcpKZSvkcSRvuvQFAoo5Mvu1Mh+eSrV5Fwdtis=;
 b=UZGPhlPm+4e64oVfiK7e2QTRM3bnd6P3dzk42mM/BQZ2mMmjG7EhGXtQ6Rp3f958PVhd9XfqNG7Jx6na6gnnsicOqh2RZzdFM1lIrppdJaN40+HOOP5ZzpNmi97Li563B+il4oPRRhp18ls7jKBDgJhJVA1Snvm/qxfsjaRoBhQcQI+FhjutYbePIjZknxref7hzIXxQ71gxC0ivg7sx837KfGwz4OlUqZCr+5FP52UOcr2071OR8qKRvbEKKxXWNG28M60uqtie0tSILprVgTOXmO/H90KGPD7iwAm3BxurgM3gMgxmueRLkpujL6PVsgg+qxMvE1pWuGvACZFBEg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HGvAmPcpKZSvkcSRvuvQFAoo5Mvu1Mh+eSrV5Fwdtis=;
 b=S7LS6+FsjexAHX7Ral2SuZQC0WseWUiOuj4XUMblFU1HDkbu01sh2Ty3nAxsYTtEI/Vp/VVMX+4oVeIK/PwF6/AeG+9f2pD3iOk4fpePL7BycLVOpP9lzMX8+thnJ758AKQiWHXdwCAMn7s0TFXwrslDq30U+f99+r9Us6POHV4=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1920.namprd15.prod.outlook.com (10.174.96.139) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.14; Fri, 9 Aug 2019 16:30:43 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d%9]) with mapi id 15.20.2157.020; Fri, 9 Aug 2019
 16:30:43 +0000
From: Song Liu <songliubraving@fb.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux MM
	<linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        "Matthew
 Wilcox" <matthew.wilcox@oracle.com>,
        "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "William
 Kucharski" <william.kucharski@oracle.com>,
        "srikar@linux.vnet.ibm.com"
	<srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Topic: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Index: AQHVTXlDuUiBx4u3AUqTmiQ0C68ad6bxcvOAgAAJMACAAXXfAIAAEp4A
Date: Fri, 9 Aug 2019 16:30:42 +0000
Message-ID: <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-6-songliubraving@fb.com>
 <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
In-Reply-To: <20190809152404.GA21489@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::1:68ef]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 99675bca-17e0-409a-3899-08d71ce6ec63
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1920;
x-ms-traffictypediagnostic: MWHPR15MB1920:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <MWHPR15MB1920A85F9E8AC8889EEED8EFB3D60@MWHPR15MB1920.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7219;
x-forefront-prvs: 01244308DF
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(396003)(39860400002)(366004)(346002)(376002)(189003)(199004)(7736002)(6512007)(86362001)(66446008)(66946007)(186003)(66476007)(99286004)(66556008)(102836004)(476003)(64756008)(256004)(6506007)(486006)(76176011)(53546011)(71200400001)(57306001)(11346002)(71190400001)(8676002)(46003)(478600001)(5660300002)(53936002)(446003)(54906003)(2616005)(36756003)(33656002)(76116006)(14454004)(2906002)(6116002)(25786009)(316002)(8936002)(6436002)(6246003)(81156014)(50226002)(4326008)(6916009)(305945005)(229853002)(81166006)(6486002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1920;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: MZTbbp2obkSnCILkUmBmqV0ZnrU5zuO3pUgMFcpAr5x5voI2wc0jELAZZqLMKnca/rJ5S5Ub5Eu/LYuBanceyE/XbtshNT06yBWTzxYl2AQV1t9Sph7nf4cnhD5lbwMmHuhW+jxlElRCNHY7Ik5ODozycAfiQN2vae4Khi4vAzCXa58jjLi3aUUrZfdiWMylu75EiChRd7V6AZJKLYaXi36WR2Xs9cOUl436bf2io1w0SZTnaY24LANcgrH71L3qymxaQFfEgp0eAoC7cw27BzPl7c1o7t6jXo14G1eCoP3ewuXG2oAYWvFfdqUs18xKf+O/nDcVIHmMbumuah8cLPyHPrNXtydn/zccs+FUiQf4OAipPZt9EKIewyiMJ9/RjL9efmv85tq0NIs7q+XEf7gtM+PimoQcWoK9JgrtV1A=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <83AC1FAB0D521244AA9FE7F5B02D0A94@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 99675bca-17e0-409a-3899-08d71ce6ec63
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Aug 2019 16:30:42.7726
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 27QAnWOhkppLd5/AtNFaFFkQp9JYG5FzhzWbFYvRXmgFbVMYvQVYoCil4lboYKy9Pua3Yi4Y1Ba5K/QsmaHgjA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1920
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-09_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=792 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908090162
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 9, 2019, at 8:24 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> On 08/08, Song Liu wrote:
>>=20
>>> On Aug 8, 2019, at 9:33 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>>>=20
>>>> +	for (i =3D 0, addr =3D haddr; i < HPAGE_PMD_NR; i++, addr +=3D PAGE_=
SIZE) {
>>>> +		pte_t *pte =3D pte_offset_map(pmd, addr);
>>>> +		struct page *page;
>>>> +
>>>> +		if (pte_none(*pte))
>>>> +			continue;
>>>> +
>>>> +		page =3D vm_normal_page(vma, addr, *pte);
>=20
> just noticed... shouldn't you also check pte_present() before
> vm_normal_page() ?

Good catch! Let me fix this.=20

>=20
>>>> +		if (!page || !PageCompound(page))
>>>> +			return;
>>>> +
>>>> +		if (!hpage) {
>>>> +			hpage =3D compound_head(page);
>>>=20
>>> OK,
>>>=20
>>>> +			if (hpage->mapping !=3D vma->vm_file->f_mapping)
>>>> +				return;
>>>=20
>>> is it really possible? May be WARN_ON(hpage->mapping !=3D vm_file->f_ma=
pping)
>>> makes more sense ?
>>=20
>> I haven't found code paths lead to this,
>=20
> Neither me, that is why I asked. I think this should not be possible,
> but again this is not my area.
>=20
>> but this is technically possible.
>> This pmd could contain subpages from different THPs.
>=20
> Then please explain how this can happen ?
>=20
>> The __replace_page()
>> function in uprobes.c creates similar pmd.
>=20
> No it doesn't,
>=20
>> Current uprobe code won't really create this problem, because
>> !PageCompound() check above is sufficient. But it won't be difficult to
>> modify uprobe code to break this.
>=20
> I bet it will be a) difficult and b) the very idea to do this would be wr=
ong.
>=20
>> For this code to be accurate and safe,
>> I think both this check and the one below are necessary.
>=20
> I didn't suggest to remove these checks.
>=20
>> Also, this code
>> is not on any critical path, so the overhead should be negligible.
>=20
> I do not care about overhead. But I do care about a poor reader like me
> who will try to understand this code.
>=20
> If you too do not understand how a THP page can have a different mapping
> then use VM_WARN or at least add a comment to explain that this is not
> supposed to happen!

Fair enough. I will add WARN and more comments.=20

Thanks,
Song

