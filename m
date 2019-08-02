Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6C4DC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 20:59:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46EE320880
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 20:59:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Lvky+b+w";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="BTxFIuaG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46EE320880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF77F6B0005; Fri,  2 Aug 2019 16:59:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCF4B6B0006; Fri,  2 Aug 2019 16:59:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C96EE6B0008; Fri,  2 Aug 2019 16:59:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id A33716B0005
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 16:59:18 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id n185so32875322vkf.14
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 13:59:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=kIoPUk5o/Cl0Ic8pxt+zHjpGGOgAyvDwK7h1W+GIdjE=;
        b=PkS20AYIjQ7zjXuYc78F/OUFb4E+E9yVSNhzmj7Mh9brm4VU/XxUr6YKfiHs/qaKRP
         7OrQtZm6+3/xjDDqr9X3yM0uqx0YpVXj3uDuH2GHtElY2142K7ZZvAJzR51nZjrC6ehJ
         0zqvZn7lHqCb3eIqcOrhCD2C3nylElFUDTplxvyfXjsiI2gM1R+qLf0cFkrY2Mc88eZ5
         xaKBSDoq3gFhUSV8Wkp2+mjo9naHeqc+VDRsUqCqWC9mg7Yd2VMwCXzdMgst/leHQtRa
         lezTbyRAC9emDgTvOjzOelaDFWiP4tiy81v81UCMX56zSfnzgtuKZBieZjHMT7SSa0MJ
         SpIw==
X-Gm-Message-State: APjAAAWGqllSOXbDnhXNjlcun9GoXUB0Vp2bCr/vwXgQNgyaGgEBQYMb
	DJt3rCtQ9RkeGC+Ab9eyHPhXXd66Z4gIeIA35WDYOzccZ0VzxCRIkkdO9245U3icSw9jsgcasuj
	BYofbNEdUa6hsHSucTleCwwehiFtTtsZIcLaRKN38NntFor/dAweWitdAOspfv1xnLw==
X-Received: by 2002:a67:eec2:: with SMTP id o2mr1542741vsp.221.1564779558292;
        Fri, 02 Aug 2019 13:59:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywoH8e3BEsk7FjTY3Crwj3TnARcrJsCEx4dYZHcnXEanUHDv+OBBKMg0JJLIBqpOLhjsWd
X-Received: by 2002:a67:eec2:: with SMTP id o2mr1542726vsp.221.1564779557675;
        Fri, 02 Aug 2019 13:59:17 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564779557; cv=pass;
        d=google.com; s=arc-20160816;
        b=splRfIiyoEez1SY0Rtm7JxN0tMfRd5ZySpuuuNPHovbI6NlIlGjo2Y1tjHreUiGySR
         u8P/3ykpQyKCDAnhTzcXTLxouUF4pL3rvPdF2/8q/f058Gyjn7HAiven1jEJh3s4Bzee
         dyuFHayNlJU1rJZUKSgcMsBbWWFfeQBveFAmAA1nQRw80UvmmTzYpF5bL5NKKOsFqTQh
         4VfbE1FkvdTmCyNhoXD4frD0S3x7xkXxdcgy7bfpr8xmN15uTxseW/2ZM74wsrqDMFnp
         /emt4+VBiKYqsFedVWCPed1R7G80wtY734/Wx9qDy5z/XqWjiARWAyJTS8Mo2mLk/DbQ
         eAAA==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=kIoPUk5o/Cl0Ic8pxt+zHjpGGOgAyvDwK7h1W+GIdjE=;
        b=I5d3ol5/3Mrlha+g3Yk+NtEPMFzbkJEJZJy9Z9TYXFam1RlEblphQPAiYSUe1WXwA1
         GeKi9BlkxwwBzCPtkDQnw5NAlzO6YxDAhgAa0TtQykj4wW7NJUOZ3bWjYpbok0EMXVs4
         S4mhZPBz6cwYRBNkIx8NU2rSN/0lFjGe+K6adXmiihAURNeL+otsDbcnRsZnYebOAdEV
         tuERZKkNgpM5QZ9yPAnI7zyUnknTLKrlgQZDVSFfCtVStoh24jHshp7HpLEebNbe4B5M
         gftFt5q8W1W/Gi21t7kH2ws5wwjsAKtdv4xiBpOH2Xs8X8BBMy42mvFA1y8cBEyPtNOF
         d0Fw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Lvky+b+w;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=BTxFIuaG;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3117788d8b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3117788d8b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id y1si16800974vso.26.2019.08.02.13.59.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 13:59:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3117788d8b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Lvky+b+w;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=BTxFIuaG;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3117788d8b=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3117788d8b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x72Kv2uk018818;
	Fri, 2 Aug 2019 13:59:16 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=kIoPUk5o/Cl0Ic8pxt+zHjpGGOgAyvDwK7h1W+GIdjE=;
 b=Lvky+b+wsMFHsQ6jMs7eeceOksuAlvLsLD/e7njMq13JTzwwhbiDPGg4CtpCjNqdFhDy
 TifQ4dbIG08G5BIgPjZ89tByjGikz60W5pjy5nJkd6GTHTrBBaquRJCMUeS9hULoKUzx
 K0TKNmvv5tPDUVhDIUREW6FAxA0q5RmN/EI= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2u4s4q0t9x-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 02 Aug 2019 13:59:16 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 2 Aug 2019 13:59:15 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 2 Aug 2019 13:59:15 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=JU7ICG9jiJm2LFO9a7Pts096JGQ+5kcJNlpxEXOfgxwWS41so0yMvmD1++1f1tu2h2EuObrnUTQN4zO+fCV8G2HZpcowJsjK26r56c169HBYjTmO+Wo5G8MBLl0PqPi5z832Gr2WcRGwbQPSQ7wwp/yq30Dj2JN44ZN0dnaXLRn4WG5rXptLPT/2ePohvzXv7G/lHwWMNpPTOcqHn2Mrirfvwg7X37p7hPjes+tGSrbyjjnYpo7CU+OyZpEn2EKAGJRNDnBDpEnNFDjr+eorAputvQ2okYCEFkoH0kwfceQ+BsVi0pdMC4Xb+W8KWmb7OheiP2Z88ho29Yh5OBAXAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=kIoPUk5o/Cl0Ic8pxt+zHjpGGOgAyvDwK7h1W+GIdjE=;
 b=N79Q6Opw9ApdgOLV25Ss8AC4E+0Vll9V3Ns7G8LMaLElGTiWG/SYoFl1+IpvFtOHApHWulXFVIHKdHliBz3kYYrfLp/Kz7mRB/sopikJrQqaA06+/bldU2AW2ib3/gOcZxqM2xltPBduykz5WLJqo0Ymnl27jJlaRkHR5TX47uDZSq4YAtIu/6kBCPiG6yrGVzz0fie2NxaZ6jF+2J6F4hGkKtCZZ1AxUBezCjzq4+BPTPEkdp9xz75ZfXj//vCM3bmU/AbsncTs2JfAdDY3gNPv+z03hiFlnGqCGB1WN+WSjO3dUuZ68AtxmicCWJBTALYfA6h65pOtdjHNnua41w==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=kIoPUk5o/Cl0Ic8pxt+zHjpGGOgAyvDwK7h1W+GIdjE=;
 b=BTxFIuaGGV7fQzG70fSmusXaFxI8k0YLb1DkloahRav52/qB0qj8pjN5WGhiVwmwJs7SUe/qJguftzFVDo9xM+K59ufp0HzmYxtphIbjpVOaksqdQi8uGHwv4muyMmwAEoKY9UacRgTc7zb/atanQQvH/kCJMBWIAqZ9GaXRJJA=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1710.namprd15.prod.outlook.com (10.174.96.7) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.15; Fri, 2 Aug 2019 20:59:13 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b%2]) with mapi id 15.20.2115.005; Fri, 2 Aug 2019
 20:59:13 +0000
From: Song Liu <songliubraving@fb.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: lkml <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Thread-Topic: [PATCH v2 1/2] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Index: AQHVR86KvCEU4VHLnkGVG5f001755abmYVIAgAAuhoCAARtbgIAAr3UA
Date: Fri, 2 Aug 2019 20:59:13 +0000
Message-ID: <0893F3AE-CAC5-4241-BA69-585F268E482C@fb.com>
References: <20190731183331.2565608-1-songliubraving@fb.com>
 <20190731183331.2565608-2-songliubraving@fb.com>
 <20190801145032.GB31538@redhat.com>
 <36D3C0F0-17CE-42B9-9661-B376D608FA7D@fb.com>
 <20190802103112.GA20111@redhat.com>
In-Reply-To: <20190802103112.GA20111@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c091:480::5569]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f57ddcbe-07db-40ac-d7e6-08d7178c4648
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1710;
x-ms-traffictypediagnostic: MWHPR15MB1710:
x-microsoft-antispam-prvs: <MWHPR15MB171041ACC296B6C9057B96A3B3D90@MWHPR15MB1710.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 011787B9DD
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39860400002)(366004)(136003)(376002)(346002)(199004)(189003)(446003)(66476007)(46003)(11346002)(53936002)(6116002)(6486002)(478600001)(7736002)(6916009)(229853002)(33656002)(476003)(2616005)(2906002)(25786009)(316002)(6436002)(36756003)(86362001)(5024004)(14444005)(256004)(53546011)(486006)(6506007)(57306001)(186003)(8676002)(5660300002)(71200400001)(71190400001)(81166006)(81156014)(99286004)(14454004)(305945005)(91956017)(6512007)(8936002)(76116006)(68736007)(4326008)(54906003)(76176011)(66446008)(102836004)(50226002)(66556008)(6246003)(66946007)(64756008);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1710;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: SW6XxiFgrdpOk1KhZ3fDvThpty3OCVv23VkGmxVB/XY7vVazTCPzUKcP33/doZ0U19WCyMWKKaijhHXE40XXy6v+Mh/D5z5iwCjUCVPuVsjnDJKX5F7xoZNU4ugWl9nO2ua+mRkRjmSzw1O9daa+YL8hskaerU62aCn38zUgGwI6CMUP171W2XkO+Fm8X9qmGVisJQ2kh17q0Fwgs7h+Ob/lW2tRHrvv7rHl5TRFVMEYGiLj5QWm2MU7DRTiSGu0OILMpiNc13Cq7idae//ANDAKJWuyCaf8D+AzR7dVnoIO0THSkn8gBMmQ7FxMiTIbEsK9LlCi4jgp+EIiasUtOu/FsBE1QC3kEqJfZLs0QBNKB3sblNQDg3UFLrHPjRpBFv1Asv6sBT4g+4QJwbHOMl0s1X0UFJoFCLW/co9Jk+g=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <5C00C6A1160E9243A3C040C03C7A210C@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: f57ddcbe-07db-40ac-d7e6-08d7178c4648
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Aug 2019 20:59:13.6262
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1710
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-02_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=851 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908020224
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 2, 2019, at 3:31 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> On 08/01, Song Liu wrote:
>>=20
>>=20
>>> On Aug 1, 2019, at 7:50 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>>>=20
>>> On 07/31, Song Liu wrote:
>>>>=20
>>>> +static int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
>>>> +					 unsigned long addr)
>>>> +{
>>>> +	struct mm_slot *mm_slot;
>>>> +	int ret =3D 0;
>>>> +
>>>> +	/* hold mmap_sem for khugepaged_test_exit() */
>>>> +	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
>>>> +	VM_BUG_ON(addr & ~HPAGE_PMD_MASK);
>>>> +
>>>> +	if (unlikely(khugepaged_test_exit(mm)))
>>>> +		return 0;
>>>> +
>>>> +	if (!test_bit(MMF_VM_HUGEPAGE, &mm->flags) &&
>>>> +	    !test_bit(MMF_DISABLE_THP, &mm->flags)) {
>>>> +		ret =3D __khugepaged_enter(mm);
>>>> +		if (ret)
>>>> +			return ret;
>>>> +	}
>>>=20
>>> could you explain why do we need mm->mmap_sem, khugepaged_test_exit() c=
heck
>>> and __khugepaged_enter() ?
>>=20
>> If the mm doesn't have a mm_slot, we would like to create one here (by
>> calling __khugepaged_enter()).
>=20
> I can be easily wrong, I never read this code before, but this doesn't
> look correct.
>=20
> Firstly, mm->mmap_sem cam ONLY help if a) the task already has mm_slot
> and b) this mm_slot is khugepaged_scan.mm_slot. Otherwise khugepaged_exit=
()
> won't take mmap_sem for writing and thus we can't rely on test_exit().
>=20
> and this means that down_read(mmap_sem) before khugepaged_add_pte_mapped_=
thp()
> is pointless and can't help; this mm was found by vma_interval_tree_forea=
ch().
>=20
> so __khugepaged_enter() can race with khugepaged_exit() and this is wrong
> in any case.
>=20
>> This happens when the THP is created by another mm, or by tmpfs with
>> "huge=3Dalways"; and then page table of this mm got split by split_huge_=
pmd().
>> With current kernel, this happens when we attach/detach uprobe to a file
>> in tmpfs with huge=3Dalways.
>=20
> Well. In this particular case khugepaged_enter() was likely already calle=
d
> by shmem_mmap() or khugepaged_enter_vma_merge(), or madvise.
>=20
> (in fact I think do_set_pmd() or shmem_fault() should call _enter() too,
> like do_huge_pmd_anonymous_page() does, but this is another story).

Hmm.. I didn't notice the one in shmem_mmap(). And yes, you are right, we=20
don't really need __khugepaged_enter() in khugepaged_add_pte_mapped_thp(),
especially when uprobes.c doesn't call it.=20

This should simplify this patch.=20

>=20
>=20
> And I forgot to mention... I don't understand why
> khugepaged_collapse_pte_mapped_thps() has to be called with khugepaged_mm=
_lock.

You are right that khugepaged_collapse_pte_mapped_thps() doesn't need=20
khugepaged_mm_lock in this version. For v1, when uprobes.c calls=20
khugepaged_add_pte_mapped_thp(), this is necessary.=20

Let me clean this up.=20

Thanks,
Song

