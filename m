Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33DBDC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 21:48:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0C5220873
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 21:48:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Ud6tooM5";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="QNTDSUbq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0C5220873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D8096B0003; Tue, 18 Jun 2019 17:48:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 461DA8E0002; Tue, 18 Jun 2019 17:48:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DB868E0001; Tue, 18 Jun 2019 17:48:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 087EA6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 17:48:28 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id w17so17823167iom.2
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 14:48:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=gKeQAHGiCguXF8PWrmaFtB6YG4mQS8zmTH1/6Go6PXI=;
        b=Utlp8GxwJJ0TrvOUaARwEYzfeoRiQqiDSzjXST6PRrB5M8drEummQxqvkbaR1b0U4C
         sztFD0h9AW6ULyOLITmcyp5ypXQuL5+nZmDXemx2tPGISNeJwQnnHSrr6DMtRGH7sU/E
         ad8uV08teB/DceIVsq1uQrQbeu/EMMBKLa6+D6pqh8kK1UzSc/7HnfgNH9/8bywd1fpj
         NiidHzo0A43v7xwp4ylgDNR8fgs8X2DW88rDxFLC0BbKX2suIRsaNECvPvgaxqH449YO
         PPqWzFRGvSrMuH2nV0ckGarw+qO5bJ2m8/72xKvKUSQHbU7K0KsvlkZNGyoXc5/C7oqO
         8GOQ==
X-Gm-Message-State: APjAAAWXCwVvvbIQqD3aiTHgAoBR8TUjRZ9//jTVbl4bgS2yomhuR7mf
	rh+g1edwLe/mxqmHMqp46V6knyipHIIoTSQnQ4lPz4VLV6LDU0IKeXUSN8MgVutA7UYw/VxpVg6
	7aKDyQj/pR6viGt/ox8hkP+CIVJFmSIapndYjfm2QCK/Mkqs6EsHm0V4Q+9xOHx0sFQ==
X-Received: by 2002:a05:6602:22cc:: with SMTP id e12mr3084773ioe.192.1560894507709;
        Tue, 18 Jun 2019 14:48:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHG3NNBFrFJrtG/sjiEexdFsTn1Zi4BUJSP56gize0YW1jM0Il5KPk1CrnHsDtfTZxDw91
X-Received: by 2002:a05:6602:22cc:: with SMTP id e12mr3084722ioe.192.1560894506948;
        Tue, 18 Jun 2019 14:48:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560894506; cv=none;
        d=google.com; s=arc-20160816;
        b=HB0fKORNJYSNLjDv+FHTu5AeyN5cp4Uhg60VdfZL0lLvBJk+odRs8NWSZQAVZ+PplY
         2i0Cn4cJqebYmwGcQ4IuyIdo/+krzNurRhw1PnF0PQQFINOY+sotbCyvojpp1dukZ1Pn
         R4NlcUlwAnEd5t+BQQjE7CvRaeJAeSNS17VFxTD2F8fSlTAOfP3pMfF3Cras641UJEOX
         pjfhooVXfRBatHA+LimNHEML/GAa8F6eE89mtpUtAVSIq3JAE+YARjP4MskQyKzxqDPf
         kMsvMzBRBDISFdg3b2NxDC4ihULtcxwwrjMPMdV1IWpwMrb/INULYhzEF7hCllPHgyeL
         SXJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=gKeQAHGiCguXF8PWrmaFtB6YG4mQS8zmTH1/6Go6PXI=;
        b=bnIVsMYZFLQJH3Esxcg61oux+opOhhdSoVkHJXGh3/mbFzGnpGrej2kmjFVtdroEmJ
         /e/h8WUoohvzZaayVsHx3+DV4ZT7mThBbCvp0rB0aHTEJGcAlWcsMe1IwdHC9l7IoThx
         vVPQR3ls3VKLnE4FPV3j9cNY2ftlS3Y14vBP80dMXHPAsjdW5BsZNRkRWKz54LXtTGON
         wI6twOAhwelKXQiBA6yzTq+ABCIEl3Oua0iE5f3o/XErxMWRRcUbcSDmqqziPFiZ0JMk
         ZoEdEVvRVuN3DAvRcd2HV3R7VtuqxFd0IMtjL0N1D2KEy52F+7FxZGh8RYv0uvBT9PZH
         WjCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Ud6tooM5;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=QNTDSUbq;
       spf=pass (google.com: domain of prvs=1072dbd9ac=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1072dbd9ac=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o6si24896247jan.49.2019.06.18.14.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 14:48:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1072dbd9ac=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Ud6tooM5;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=QNTDSUbq;
       spf=pass (google.com: domain of prvs=1072dbd9ac=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1072dbd9ac=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5ILlcGL007068;
	Tue, 18 Jun 2019 14:48:25 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=gKeQAHGiCguXF8PWrmaFtB6YG4mQS8zmTH1/6Go6PXI=;
 b=Ud6tooM5blmauzJzBBwxM6JMbEUeQ7vm/lJZn3fmyn2CWXXDg1LmFqyTn7g7EryQpS3m
 R1VTwocXV7FRwqVE7Qa3PwPsWkltKOp7s4OWdb06No6N1LupzUgLNTnMqytPpgTrTlof
 cl0mvxQcauppgVx8xPuTI87i27C7dLQj3qI= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t77yjr1h4-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Tue, 18 Jun 2019 14:48:25 -0700
Received: from ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) by
 ash-exhub204.TheFacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 18 Jun 2019 14:48:18 -0700
Received: from ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) by
 ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 18 Jun 2019 14:48:18 -0700
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Tue, 18 Jun 2019 14:48:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=gKeQAHGiCguXF8PWrmaFtB6YG4mQS8zmTH1/6Go6PXI=;
 b=QNTDSUbq5mM31gBz4fZ0Csb4gYmQlJyTJ2N0OR5V4Jv6NRqlNstok6OaN6Gx7KpUZJHXr12ixwAFogcCtm7Nc4bEIpzLmmsHlUaEvFMeDsCRlOn9cyCN9gMDf4CWsKFNlNvuN/8y101QHH2Jqznn5kEKf7hq/OvlHWHaDkUTzpE=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1230.namprd15.prod.outlook.com (10.175.2.148) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.12; Tue, 18 Jun 2019 21:48:16 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.1987.014; Tue, 18 Jun 2019
 21:48:16 +0000
From: Song Liu <songliubraving@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "chad.mynhier@oracle.com" <chad.mynhier@oracle.com>,
        "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>
Subject: Re: [PATCH v2 0/3] Enable THP for text section of non-shmem files
Thread-Topic: [PATCH v2 0/3] Enable THP for text section of non-shmem files
Thread-Index: AQHVIt4f2F2VuI2II0W4i6vGZDY11qah706AgAAKBoA=
Date: Tue, 18 Jun 2019 21:48:16 +0000
Message-ID: <BA4D64DA-4F48-4683-8512-0402B9533EE7@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
 <20190618141223.4479989e18b1e1ea942b0e42@linux-foundation.org>
In-Reply-To: <20190618141223.4479989e18b1e1ea942b0e42@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:2b1d]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a9d26c59-fe43-4a4e-8c80-08d6f436abc3
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1230;
x-ms-traffictypediagnostic: MWHPR15MB1230:
x-microsoft-antispam-prvs: <MWHPR15MB1230E5EF0ADAF5FE643BC418B3EA0@MWHPR15MB1230.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 007271867D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(366004)(376002)(346002)(39860400002)(396003)(199004)(189003)(6436002)(102836004)(6506007)(478600001)(53546011)(11346002)(25786009)(76116006)(36756003)(33656002)(73956011)(66556008)(66476007)(2616005)(6246003)(446003)(66446008)(486006)(46003)(64756008)(6486002)(4326008)(186003)(76176011)(66946007)(71200400001)(8676002)(50226002)(256004)(71190400001)(476003)(81166006)(86362001)(6916009)(14444005)(305945005)(81156014)(68736007)(53936002)(99286004)(7736002)(2906002)(229853002)(6512007)(316002)(6116002)(54906003)(8936002)(14454004)(5660300002)(57306001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1230;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: jTfpDxwJuU1GuSeJcb+u1U0bETHd8008MkxbJKw0BHNc2WBBGJ5FDfRONeOVPBfznBr8ovKoHtSDfX0KLL+QI2oozdyYAp/evRHjzHSadJnCWWl+1Ea3zfpRmK5+tQdS0VS3omTGkzSUDZ1lSDAm/8uIqJT29qJPPwdV/CkTHQSjisbEmLHlSw3DyPZM9LIf03oInqKOI9MbHXG72kwbXW5uo1G9fsfR1gXLdJYsB3BfQ5OS+Nf2yAFDqOFVjp+WAzc3BDVdTk95JRvceXMYcSccfOty4BwjtXPHdH62UeN+9+cjIcn3BTdNMAGIHikCcQ4t+MxeihyaRfmB++A4QUs00acC5X7gJucdex6O3AIAU9WuZoDbh1f67A2KEPohj7yt+7hzxaddDG6yPe8ZPXtRkauH1FNdqaQHHj8BdYw=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <AB2F0BAC20E27C43BE321CD7B74858E5@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: a9d26c59-fe43-4a4e-8c80-08d6f436abc3
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Jun 2019 21:48:16.4102
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1230
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-18_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906180174
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 18, 2019, at 2:12 PM, Andrew Morton <akpm@linux-foundation.org> wr=
ote:
>=20
> On Fri, 14 Jun 2019 11:22:01 -0700 Song Liu <songliubraving@fb.com> wrote=
:
>=20
>> This set follows up discussion at LSF/MM 2019. The motivation is to put
>> text section of an application in THP, and thus reduces iTLB miss rate a=
nd
>> improves performance. Both Facebook and Oracle showed strong interests t=
o
>> this feature.
>>=20
>> To make reviews easier, this set aims a mininal valid product. Current
>> version of the work does not have any changes to file system specific
>> code. This comes with some limitations (discussed later).
>>=20
>> This set enables an application to "hugify" its text section by simply
>> running something like:
>>=20
>>          madvise(0x600000, 0x80000, MADV_HUGEPAGE);
>>=20
>> Before this call, the /proc/<pid>/maps looks like:
>>=20
>>    00400000-074d0000 r-xp 00000000 00:27 2006927     app
>>=20
>> After this call, part of the text section is split out and mapped to THP=
:
>>=20
>>    00400000-00425000 r-xp 00000000 00:27 2006927     app
>>    00600000-00e00000 r-xp 00200000 00:27 2006927     app   <<< on THP
>>    00e00000-074d0000 r-xp 00a00000 00:27 2006927     app
>>=20
>> Limitations:
>>=20
>> 1. This only works for text section (vma with VM_DENYWRITE).
>> 2. Once the application put its own pages in THP, the file is read only.
>>   open(file, O_WRITE) will fail with -ETXTBSY. To modify/update the file=
,
>>   it must be removed first.
>=20
> Removed?  Even if the original mmap/madvise has gone away?  hm.

Yeah, it is not ideal. The thp holds a negative count on i_mmap_writable,=20
so it cannot be opened for write.=20

>=20
> I'm wondering if this limitation can be abused in some fashion: mmap a
> file to which you have read permissions, run madvise(MADV_HUGEPAGE) and
> thus prevent the file's owner from being able to modify the file?  Or
> something like that.  What are the issues and protections here?

In this case, the owner need to make a copy of the file, and then remove=20
and update the original file.=20

In this version, we want either split huge page on writes, or fail the=20
write when we cannot split. However, the huge page information is only=20
available at page level, and on the write path, page level information=20
is not available until write_begin(). So it is hard to stop writes at=20
earlier stage. Therefore, in this version, we leverage i_mmap_writable,=20
which is at address_space level. So it is easier to stop writes to the=20
file.=20

This is a temporary behavior. And it is gated by the config. So I guess
it is OK. It works well for our use cases though. Once we have better=20
write support, we can remove the limitation.=20

If this is too weird, I am also open to suggestions.=20

Thanks,
Song=

