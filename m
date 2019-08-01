Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAA36C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 17:11:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58D1C20449
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 17:11:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="cB+7/PVp";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="HsL+Uni7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58D1C20449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD4F48E0007; Thu,  1 Aug 2019 13:11:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B856A8E0001; Thu,  1 Aug 2019 13:11:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4E508E0007; Thu,  1 Aug 2019 13:11:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC008E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 13:11:34 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id x24so79893126ioh.16
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 10:11:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=QbOJI0wUojkW1x4XCnDc45yYOalVj21+9ESdamFUjgc=;
        b=H+6KHDT8/cdrr78JiH0rPp33Q+Ouk5f7rQXgf0APp2wPvVDpgOJlkb/w1OynIsUE8V
         VpMuJHtTHMzLlCnaVEJ27LWgLZefMb/g1K6o956geXW+hvrpDhnA6GQSpUdmMOJnoslz
         XJYhMGs5iu/y/WqWu3DcfW+ovDs2sev4sZrZ60ZqSqgdfmTrenIHdrbT2W/FZC59ZKbd
         aKJK4z3qVv5YgteuTLdJLrtLFoykT7cgZ9UqqfLDksDtXg+MhfP18zCm/RnVE4yo5PWo
         Oc5RCIxKHs39oIvk/XDoLP4L6Q5ti2i52yQEd0yoiOMoNwJDJfOWZHYRbIhNBu7QUUoc
         HW2A==
X-Gm-Message-State: APjAAAWj1tks7Y2hhKFFpO7s3usyVz8RdphGfxJeG8Q4mNWnRgexBb7V
	VC8CMT+BKvDSDP5dBNCr4cH6Fdj7xWbzCGw38Pwz49w3Ofz0Mv+g1LF88rVIprtBbG8A+nWIDJc
	ofU+ezUhoRD4gCK5UfrJ8W/aBTZny0C3CxvNJs+Ob3FY3MdWISmKFxnBR0hr2xH+rLQ==
X-Received: by 2002:a05:6638:517:: with SMTP id i23mr18899504jar.71.1564679494194;
        Thu, 01 Aug 2019 10:11:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzG2EwN4Fm53+VflXLpVHP1Y9uV1oqvEmd5E2stWonbgsFF0c7dvTNRarcvQtWARSoUhjuo
X-Received: by 2002:a05:6638:517:: with SMTP id i23mr18899440jar.71.1564679493429;
        Thu, 01 Aug 2019 10:11:33 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564679493; cv=pass;
        d=google.com; s=arc-20160816;
        b=LEg4eU3+tk1TRNlRYRxVTf6D0qK/WZTMMrC+WvUMIbRx8qadjxVJ+t8+xbWt1LHTYD
         bkSY6WWOuKYsI2qXHRRl7hmPvysw4HarcM6SN3FUqs9/S2PCM3obSY8V6IkEz5e4/Cpg
         eV8J5jgKWMP7Ir+orrq0AZlRrOfWfoOmPxnRakhRHLT53jcM9BO2Gab7pNXqZu5UKQkZ
         oK0u+b7Uuia00LOcTlvh1jD6k7nq0h+UGg5wGDnWEzKBbRPqVUSmjVwwj0DL6Ux7cq1q
         FTwuADGBdidJcHJqyGgG+E8rUCE0K3/1OVLjs4FKCWQDpXWsQ14bcAjChyTVQdxn9GeT
         B81A==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=QbOJI0wUojkW1x4XCnDc45yYOalVj21+9ESdamFUjgc=;
        b=FTWa64iEA1yTEcWS500nqvtXwc4NbCFCffgXPusDNUDYKk2OSZc+xi69meQ8ojS3xc
         x58FGzgYTmnR33v3mFyytRVd2f9U1H2OaW07Uzi0+eZsUZhMNauzIHPH+jXJplr25n9P
         ir0W6NVHA8m6I9aik+/JxdHYTvqnwnubESVr8bUUoz19AEH1dpmi5Ut0DmRG5wt/6UIa
         Z/cugkYwnRlKZPXNzvaYqZb/s56otTVXWD60JcwkgFYeOWquiWekHdh9vi0xFgVwpipO
         ZdC7jpTbRNXkj5+9lOikdkr3F1fm3vXwab59u3aEP2PJoRs6wNEYGbfKtOCSs5THbx4Y
         ldTg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="cB+7/PVp";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=HsL+Uni7;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v188si99465053jaa.22.2019.08.01.10.11.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 10:11:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="cB+7/PVp";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=HsL+Uni7;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x71H5Gk8018978;
	Thu, 1 Aug 2019 10:11:31 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=QbOJI0wUojkW1x4XCnDc45yYOalVj21+9ESdamFUjgc=;
 b=cB+7/PVp8kHsJn5fdGnY9cF3GezWIOSww1IQfPuG4a9ZOiz7clm/oCQFxd94TPiyY6aw
 CTEp8yOswZlNGJpxsy5Nuv1O/6hhufSPgZAM5Zxxi7Y6+kmW1Cr6AY7yVzaCJSlu0bPr
 lWpT8ZGsEqTyd6yBebYqPt0OkhgsDCVCYAs= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u3xmt9pu9-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 01 Aug 2019 10:11:31 -0700
Received: from prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 1 Aug 2019 10:11:30 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 1 Aug 2019 10:11:29 -0700
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 1 Aug 2019 10:11:29 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=dUsRWEkoccoM//ON3qiP7iT8ujghuNUTYjHQvl68inKcXo36puYQAyD1EDyYYsikRUs0VUdW2l6X0Hl2ouXRM8mhsZjN6fWjg6aGQESsMltDmqD3g57J3pYQbL++1GyrlBd9yh1IdSZrcmU32EbQlVz8MXyJ9xfqEjsdgE5lAV9L0938fSKqvRak/jhe6sWWpmGWPzrch37XkNWtLDEGnrHHQNeVYCqKb+k6rwMeAyXafDVYIfkESB09AMgsSM6ZUxtEfin+dEfHBgdGPiuj+BrD/OBxqqKpIyVB+WpP2qjtFRbCk3k4N1Td8N/6io0MPb61NEnZmKl3JS9dYtd7wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QbOJI0wUojkW1x4XCnDc45yYOalVj21+9ESdamFUjgc=;
 b=YsXBUBdUv1FVEotQVbto4HmnXIVXCRwc6YrmGXKzxBluR36mBLYy86pNOz6RxKcjW39kmt+dlLqt1aS0JHxZNA4cpzCqgDvkrPlT8bAZKcy9NDzS6nR7j1ezQnhWRG7NCMoZ6fSt3E8ZqDjAM3FXXeFvKgNI0Rq/9c9oSKBSIGUGun9qoOC0Kj9a6IQyKDUQtQsfksrDu1P6+cgdtyi73O+3jAUW8G0SrzLLKrqkIprWIS1j/2pRJ0qTWgMeV3BwzboUhkFtiBtA91ycs7pCTR6q5cDPzSrZ/Sn0aT5erfDS7f7VY2tElaAyMngD7FZiipqcliSCpmRvk/nSk6+OEg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QbOJI0wUojkW1x4XCnDc45yYOalVj21+9ESdamFUjgc=;
 b=HsL+Uni7C1p8zMqLi/vQ0vMfA4rPS5mTc/RxGLFqB3k1F/w2CH0RRK+iNGRD/wCjmrwUCNxFoX8e1/6rRWbSulNxDapiF7GMDquNz0RFhyIOjRx7p5qxqoF2kqiuWQu7CmO9EEjT8grIcPWMXpwxVcRFv6wNxXUQsAKg7OW1zRk=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1904.namprd15.prod.outlook.com (10.174.98.138) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.15; Thu, 1 Aug 2019 17:11:28 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b%2]) with mapi id 15.20.2115.005; Thu, 1 Aug 2019
 17:11:28 +0000
From: Song Liu <songliubraving@fb.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        Andrew
 Morton <akpm@linux-foundation.org>,
        Matthew Wilcox
	<matthew.wilcox@oracle.com>,
        "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "William
 Kucharski" <william.kucharski@oracle.com>,
        "srikar@linux.vnet.ibm.com"
	<srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Thread-Topic: [PATCH v2 1/2] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Index: AQHVR86KvCEU4VHLnkGVG5f001755abmPe4AgABKxAA=
Date: Thu, 1 Aug 2019 17:11:28 +0000
Message-ID: <619E9EC6-0B6A-4C30-8BA7-D2CA83FFC4E7@fb.com>
References: <20190731183331.2565608-1-songliubraving@fb.com>
 <20190731183331.2565608-2-songliubraving@fb.com>
 <20190801124351.GA31538@redhat.com>
In-Reply-To: <20190801124351.GA31538@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::2:33d7]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2655aed1-83bd-4f83-21be-08d716a34ad8
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1904;
x-ms-traffictypediagnostic: MWHPR15MB1904:
x-microsoft-antispam-prvs: <MWHPR15MB1904AABF93FB0FCB10009D9BB3DE0@MWHPR15MB1904.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4125;
x-forefront-prvs: 01165471DB
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(136003)(346002)(376002)(396003)(366004)(199004)(189003)(14454004)(7736002)(86362001)(76176011)(99286004)(6916009)(186003)(6436002)(71200400001)(6506007)(66476007)(68736007)(316002)(53936002)(66946007)(53546011)(76116006)(66556008)(6512007)(305945005)(14444005)(64756008)(486006)(256004)(102836004)(476003)(229853002)(5660300002)(11346002)(36756003)(446003)(2616005)(6486002)(54906003)(71190400001)(46003)(6246003)(8936002)(81166006)(8676002)(33656002)(66446008)(6116002)(4326008)(25786009)(2906002)(50226002)(57306001)(478600001)(81156014);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1904;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: XNHVRJUxyTa4DAesDGRL/nYDMME3cJk0vLkmWPlK+Q3WskdobNHgq0/ThLcsc8Hs6f1YE7In75eeaYFYw6ZkIUBSJJ5xqrvbKQ5qF38wr4OkZAkIz0rn7OaSq4FDe1enHCaMfssRq8tSqPy47WaFCqovR3AYKYaEF7c6wzZme+fKjPDL+Efp2mrhr5N4xoD4eI3WA4SHiSBPp+RxvnYINMDRrAscJ7kQVaaHnRupGTV2z+vRNwx6/KFQ9tz12MuifjIJXbD16xRlnjkYKGom7q9O/Dt71EQZoFZpJniIEmVp0uHWn4+dtvTILbl4QmhwzSIZfewDcJh28o+f7bQhCSAJ5xnsK44j/SB/1ZzCDPEctBnbyjrcjy7DmI8utv7Dr/cp+sm1a4Mx9+hDT3+u0mn7c2VtpX2GRZrZFHyrOUM=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <EB954BAF84DA264B9D83A2A59D36276A@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 2655aed1-83bd-4f83-21be-08d716a34ad8
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Aug 2019 17:11:28.5541
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1904
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=998 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010179
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 1, 2019, at 5:43 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> On 07/31, Song Liu wrote:
>>=20
>> +void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long haddr)
>> +{
>> +	struct vm_area_struct *vma =3D find_vma(mm, haddr);
>> +	pmd_t *pmd =3D mm_find_pmd(mm, haddr);
>> +	struct page *hpage =3D NULL;
>> +	unsigned long addr;
>> +	spinlock_t *ptl;
>> +	int count =3D 0;
>> +	pmd_t _pmd;
>> +	int i;
>> +
>> +	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
>> +
>> +	if (!vma || !pmd || pmd_trans_huge(*pmd))
>                            ^^^^^^^^^^^^^^^^^^^^
>=20
> mm_find_pmd() returns NULL if pmd_trans_huge()

Good catch! I will simplify this one in v3.=20

>=20
>> +	/* step 1: check all mapped PTEs are to the right huge page */
>> +	for (i =3D 0, addr =3D haddr; i < HPAGE_PMD_NR; i++, addr +=3D PAGE_SI=
ZE) {
>> +		pte_t *pte =3D pte_offset_map(pmd, addr);
>> +		struct page *page;
>> +
>> +		if (pte_none(*pte))
>> +			continue;
>> +
>> +		page =3D vm_normal_page(vma, addr, *pte);
>> +
>> +		if (!PageCompound(page))
>> +			return;
>> +
>> +		if (!hpage) {
>> +			hpage =3D compound_head(page);
>> +			if (hpage->mapping !=3D vma->vm_file->f_mapping)
>=20
> Hmm. But how can we know this is still the same vma ?
>=20
> If nothing else, why vma->vm_file can't be NULL?

Good point. We should confirm vma->vm_file is not NULL.=20

Thanks,
Song

