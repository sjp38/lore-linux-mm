Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6D7FC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:08:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 279352083B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:08:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="F/rPWR85";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="VZNbL9Qu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 279352083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7C088E0002; Fri, 21 Jun 2019 09:08:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C52C98E0001; Fri, 21 Jun 2019 09:08:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B43128E0002; Fri, 21 Jun 2019 09:08:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 926FB8E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:08:46 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id v83so5620409ybv.17
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:08:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=4P6eRpXWUnKjrNHd2v6FoaM6LVKEeh1Gda/8byIvIS8=;
        b=MWqooroQ5Xl/7hT6u/QUaqEJSTbVHSSFvmRP56hywtPrRQknh5YpjpF3cDMTEan38F
         22nPhbecvEXbnC8Fb3l1IXpSpvoNtvFkuOdQfWFDSCeUeR9zYn+Z3lz2N2z+BiffyKl3
         dW5RKpFdIUpeBxe/Bw8XNmKVCStkHjwa74VRB+9QPLTInjeAxjyl5lUGQBc0iMJcBJBT
         Ma4IrwW09d/bnjzKjg9daMpqBOsiS8Dn5LQiuXttjgEQDbQ6/Mk2zm6ie6gbuphIDRRy
         xi9zQkkPFok9bAS611x8w129cjVkPSgqchWQlKetaHNr5vboijoWSFb+tpsbE0SUgHve
         oEjw==
X-Gm-Message-State: APjAAAWayUEHxcXFpyK+n82ih9dO/AfQQj/tGPaIHTvsy7CkeGlhMGdf
	Gotxy/tf+DXd9+/Epg/hk/rkUmoAVLq3bred4saCWGG6kHltyd8ZLwGCIDv6IXjDG5GMpaQ+4rv
	QSPs2vx6Gk6VxlKEcsXA4UzwuXpRtojSWxN1jbSRRd0Nuzj3CPI8s5vDAnq7FjoQUuA==
X-Received: by 2002:a25:8382:: with SMTP id t2mr5346463ybk.454.1561122526311;
        Fri, 21 Jun 2019 06:08:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+mB4sABNxCU4Q85uiVnyV+mLqJcZLnGAY51yUFSX6J4+1k1FvG/RAVSY3Y32hyL/pl/aa
X-Received: by 2002:a25:8382:: with SMTP id t2mr5346415ybk.454.1561122525613;
        Fri, 21 Jun 2019 06:08:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561122525; cv=none;
        d=google.com; s=arc-20160816;
        b=AJx6F6iqa6xcRmzdSdjpSAOQxC3YGf7HV5VussrVlN2ib/DCXDgPjAXBgAJHwmQf/q
         mhmsg4Fw/g59JEbElpTRRd5mKQyem/z/FgvbkLwVxPbBtz2gOZkBfYrp5+rY6ivBr+4G
         eoZ4x4duSWXPwSItxzSTM8BLFSySp/L4gmtq0g9+bUQxDxCSgIUax4zqpsWVaZGJQ+uC
         vavobHFLZN+GkItNZA65CoqHmqj8YVf1qKM+8Q7m2Q9/VXf6BoaadWPCBzV/61w6DQkM
         s93QL3XokepJreNOm9hE6mrANF5HDbdq61s7tU6GlXcZOp0eFalO2xPgB+ySrAU7TZ0R
         sQcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=4P6eRpXWUnKjrNHd2v6FoaM6LVKEeh1Gda/8byIvIS8=;
        b=u6SgJN6MQpZR6m9ykSY9KMlKuDjp8FWS7Zq9yGKQRWIegJ/beYIysSB1iLXKz+vzFs
         Z0pjKRGKxDFTPuDePDeZIVb0NJgnHNh8VWV5Sbvc5VAztI/Xrty4JOBSZkzfx9DTstdE
         zlml089Y/9mDixJkS16lVlAHNgXykwBY+sMhd4MXu+PpDFJ8BfNIJri99vQ4SsxJEwbS
         +TwBh/i9GoLsJB+igwztQq3tMN/N7d7wHrvbFHAp1YoH+cKBoarWerRO0ukYQJa+cCzP
         1KQqefW4o88NFMv1WfK6r7OuisQNR55kE/7IcmSCdjuv+nFmpGD+unhPnOKGn2Tj9W6Q
         j8Iw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="F/rPWR85";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=VZNbL9Qu;
       spf=pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10751dd214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 21si968454ybl.461.2019.06.21.06.08.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 06:08:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="F/rPWR85";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=VZNbL9Qu;
       spf=pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10751dd214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LD3UFi030440;
	Fri, 21 Jun 2019 06:08:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=4P6eRpXWUnKjrNHd2v6FoaM6LVKEeh1Gda/8byIvIS8=;
 b=F/rPWR852QGe1RsKLe4qT7nQGI6B1q50MSq5lxjbg6cQbeNTXYIqEo1bUcdkmwg2AatV
 bHJr60PCAxYSZL5xwxNgraTtPqV7eqk86Gv7jSYJuKalxsCNJiwelqPV+bKBhsELHUQ0
 DYtsAIrvTfFy37VB60PifHRVuZbjq8WRapE= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8n909w8d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 21 Jun 2019 06:08:45 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-hub03.TheFacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 21 Jun 2019 06:08:42 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 21 Jun 2019 06:08:42 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4P6eRpXWUnKjrNHd2v6FoaM6LVKEeh1Gda/8byIvIS8=;
 b=VZNbL9Quyo1jQjH36sTlK523IlJu2mlDptWUnwHjWaLu0fWzbo2J30Ikb4LANeEL8VPrFYXnK1Ypi8x/7yjsOusZUkEfzTP4lRnVTSwf3gMclTZsuzddRHukcHiiY1NLpGKWpKFxAYGC4/kZMpr4s+gANZC747uU4t5Sl4jSo14=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1936.namprd15.prod.outlook.com (10.174.101.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.13; Fri, 21 Jun 2019 13:08:39 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.014; Fri, 21 Jun 2019
 13:08:39 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: Linux-MM <linux-mm@kvack.org>, Matthew Wilcox <matthew.wilcox@oracle.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Kernel Team
	<Kernel-team@fb.com>,
        William Kucharski <william.kucharski@oracle.com>,
        "Chad
 Mynhier" <chad.mynhier@oracle.com>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: Re: [PATCH v2 3/3] mm,thp: add read-only THP support for (non-shmem)
 FS
Thread-Topic: [PATCH v2 3/3] mm,thp: add read-only THP support for (non-shmem)
 FS
Thread-Index: AQHVIt4j7T4iE6bxX06HBdgJcq3L56amHDgAgAAC7oA=
Date: Fri, 21 Jun 2019 13:08:39 +0000
Message-ID: <B83B2259-7CF5-411E-BC4C-7112657FC48E@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
 <20190614182204.2673660-4-songliubraving@fb.com>
 <20190621125810.llsqslfo52nfh5g7@box>
In-Reply-To: <20190621125810.llsqslfo52nfh5g7@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:ed23]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: eabfea1e-ab39-41a7-558d-08d6f6499425
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1936;
x-ms-traffictypediagnostic: MWHPR15MB1936:
x-microsoft-antispam-prvs: <MWHPR15MB1936869777184F4ABDE9F2B8B3E70@MWHPR15MB1936.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0075CB064E
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(346002)(376002)(136003)(39860400002)(396003)(199004)(189003)(316002)(53936002)(46003)(11346002)(6512007)(256004)(102836004)(229853002)(446003)(6116002)(14444005)(66946007)(99286004)(66476007)(71190400001)(71200400001)(76116006)(76176011)(6506007)(73956011)(476003)(53546011)(2616005)(6486002)(66446008)(66556008)(64756008)(68736007)(305945005)(54906003)(6916009)(6246003)(50226002)(5660300002)(478600001)(36756003)(14454004)(486006)(4326008)(8936002)(6436002)(81156014)(81166006)(7736002)(25786009)(8676002)(33656002)(186003)(2906002)(57306001)(86362001)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1936;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 8Cd4CYlRuqhCCnwcBNKrFzHEwsrxH1aK8cb8ZBSkWCjKwncKKVnbSvwzIJ1Teowem47BInfk0Rip0VBZCOkU74hYnkU69noB/JlXh8JHIkzKbgAR00M6E9woR3BRes26vkO/s1B17bXUEjCTKJu9zuDpjxFOFqTld+clZql6C49nV/0sybiIb7aV+kXzyufPVeEwVVb6TT3yXfM9awU84BDpTh6UR6f0OJZHtD8yp/XJ/VCxORrRLI897Axvn8IFMUBau/iS8enCDga8M22LXM7mVc8q+O19zT8xdu2w6pB/Ms5mWIYK0WBfyJq92C3uHWCZP1qpHRwORHz1XgWrDAnmS/tBiVMwjTyjxioAdDVvSGK1T60V2OSTXSCyIKxG5bqkTPLUppAk5NAakazgdmUgKmDAnA9LfYWWqBqNa5w=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A1BD89E809276C42874DEBECA95B197D@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: eabfea1e-ab39-41a7-558d-08d6f6499425
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Jun 2019 13:08:39.6222
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1936
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=844 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210109
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi Kirill,

> On Jun 21, 2019, at 5:58 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Fri, Jun 14, 2019 at 11:22:04AM -0700, Song Liu wrote:
>> This patch is (hopefully) the first step to enable THP for non-shmem
>> filesystems.
>>=20
>> This patch enables an application to put part of its text sections to TH=
P
>> via madvise, for example:
>>=20
>>    madvise((void *)0x600000, 0x200000, MADV_HUGEPAGE);
>>=20
>> We tried to reuse the logic for THP on tmpfs. The following functions ar=
e
>> renamed to reflect the new functionality:
>>=20
>> 	collapse_shmem()	=3D>  collapse_file()
>> 	khugepaged_scan_shmem()	=3D>  khugepaged_scan_file()
>>=20
>> Currently, write is not supported for non-shmem THP. This is enforced by
>> taking negative i_writecount. Therefore, if file has THP pages in the
>> page cache, open() to write will fail. To update/modify the file, the
>> user need to remove it first.
>>=20
>> An EXPERIMENTAL config, READ_ONLY_THP_FOR_FS, is added to gate this
>> feature.
>=20
> Please document explicitly that the feature opens local DoS attack: any
> user with read access to file can block write to the file by using
> MADV_HUGEPAGE for a range of the file.
>=20
> As is it only has to be used with trusted userspace.
>=20
> We also might want to have mount option in addition to Kconfig option to
> enable the feature on per-mount basis.

This behavior has been removed from v3 to v5.=20

Thanks,
Song=

