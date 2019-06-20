Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A708EC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:04:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C2122080C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:04:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="YzGPP0v0";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="PAqKQDqL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C2122080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC3096B0003; Wed, 19 Jun 2019 22:04:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D738A8E0002; Wed, 19 Jun 2019 22:04:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C623C8E0001; Wed, 19 Jun 2019 22:04:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id A24256B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:04:34 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 97so1599963qtb.16
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:04:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Etc9Vd0yTbXngAkAH7iZ+GkPMeh4vFgiRZrCXkOPP6w=;
        b=SCXZQSzmUxbying4DP7PsCy2iNxgVF9+M/EPbWFp/d9zAfZGTzFrsNgqfSc12Rz+yN
         XEBcDGkFRK416rjJjsJacjHDc3zXX/kcRQGsR8VedyFRncvR8WOoYMnXHwqHmOW0RshF
         n7YIWBegRniL6rhjhJfJ2gDTsRcR51IXgMwLVx2ZHjLtVzAQFzXWsoZrRMEgOG9Ibsno
         WXjuM7eGkuPShvlH20iRt37+i+4IO95UqwSkKY0hfcdJHcXINoYupCb4nqcC+HkhXief
         K0FZoTwOjtMei9nFDbN5Yt+UT+ZbgVzPMBuLF9fZxsMcej+K4dO1/cUzPIwsd9ddKUUM
         8HTQ==
X-Gm-Message-State: APjAAAVPvlfCgFoMcMg+iF4l0HXZhXRyYlN3O/R6fNofVAutnHswCUVE
	/hHnglwUPVlb0z/6QDjsXxDaAMpZEfRWqZjsIE+9/mP9S6GWWoqQHTpjI8/UnHVeowG+dkHZdmi
	W2ignr0t+nsS3+krMvXb+XHwjoYX/CHVfEgNp0UkFejUhES2BsdUgcLuJbjnME25Gyg==
X-Received: by 2002:ae9:c108:: with SMTP id z8mr42686178qki.57.1560996274410;
        Wed, 19 Jun 2019 19:04:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJBZyJam8d286u2qNOXFUxQlQQfZTI4yDNLYF/CTQYu6nqoN869FPJVxlleoqoQbn+HurB
X-Received: by 2002:ae9:c108:: with SMTP id z8mr42686151qki.57.1560996273903;
        Wed, 19 Jun 2019 19:04:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560996273; cv=none;
        d=google.com; s=arc-20160816;
        b=O2ulTVZbpQEV0EzhKlHwAHLdvPvF2C67dVHqNWAmvi7Sottder4+nLya1KgHwo9OZF
         qIlthYJBSUcrcURLGbnkLzXqbw0mzEeqLtzrP2uaCotaTUaE9BMahe2UA7Ar+8DjOB/Z
         3RiOSsYq9gvzpL/xF9HZjxA+2FqVkaHPxiX3RpGbEvk4ec1w2eneUxLTVo0n8uBQkaaf
         0UdSXGAHxa6ligSFTj73/yCsdEf7Ke0FiWJJDhveNbdczFZVRe6KZU0h1ie9j2LLAnX7
         YggDXPkZsb3ILjPfNIDThyENDVZDFGFr9AI1Qh4iVTEnW+2tP7akRMPdRf9zR05rL+xS
         8ouw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Etc9Vd0yTbXngAkAH7iZ+GkPMeh4vFgiRZrCXkOPP6w=;
        b=hTg+OlIAELeR5ySOPNKIlsDauqlvdI0pejMG4sONNiZmmdzD/kVw/ierMZQPCW+XK5
         jdVv1gdSHykxQ4216XX0yAFZ+29620m4VxkWQVpiJ7fHfxIsUN2xN/TUEbzcI5AjlA+Y
         R7MNFdGGa+iEesAvQc9y89bfmqAbsBBfwT2CYl1KoggXDq2O5XWvlfqDIDws9R14Jzcg
         lw3xfNT/+KbB3j96eyjBvfn3xO5PUhb61NVGaIGpGX/fqA6DcovTGQy5+bv+RGvsegzl
         +VGsZ+52vDnAqFVMPdwfhRR+Hu4070gBr0k5HzYu3vcmRopl6+jkYx1ohFyeRq1Uzakn
         iegQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=YzGPP0v0;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=PAqKQDqL;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q36si3938931qta.74.2019.06.19.19.04.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:04:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=YzGPP0v0;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=PAqKQDqL;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5K21ZU2024351;
	Wed, 19 Jun 2019 19:04:31 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=Etc9Vd0yTbXngAkAH7iZ+GkPMeh4vFgiRZrCXkOPP6w=;
 b=YzGPP0v0Jx4e532mbnuzoO85wj3jn3mP4LvA0CFjUq7Epj4h314LNXAW7LWqgqZvRwv7
 qfzgaAp1rE3N5LtGLIM/BqMNB+pOP3VFtyt1zkM2wJZ/cXp2QKU3pxucr8i9YbZP583G
 frUJKQv/bXyo8MqaD4VL3bg8vCnsPQrURo4= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2t7rex1ttv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Wed, 19 Jun 2019 19:04:30 -0700
Received: from ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) by
 ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 19 Jun 2019 19:04:29 -0700
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.101) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Wed, 19 Jun 2019 19:04:29 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Etc9Vd0yTbXngAkAH7iZ+GkPMeh4vFgiRZrCXkOPP6w=;
 b=PAqKQDqLQVlHHPkm0JIi0bDHtSXE58i/7hb6aONKQfqu4Qs7XNX4NTTFBmE6iWYjAp2WLz5EJGRHpuN1/0UjJkNZFTQLvp7nNJGXSu6iQc3SUpf8xY28sHSppa1tnU71c4luJYT38CwB3tZoPHYyATzrrdBhMdB5pYP7K7vi2so=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1550.namprd15.prod.outlook.com (10.173.229.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Thu, 20 Jun 2019 02:04:15 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.1987.014; Thu, 20 Jun 2019
 02:04:15 +0000
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
Thread-Index: AQHVIt4f2F2VuI2II0W4i6vGZDY11qah706AgAAKBoCAAcvKAIAADhAA
Date: Thu, 20 Jun 2019 02:04:14 +0000
Message-ID: <603FB934-07C8-4486-84B2-BEBF1EB301FF@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
 <20190618141223.4479989e18b1e1ea942b0e42@linux-foundation.org>
 <BA4D64DA-4F48-4683-8512-0402B9533EE7@fb.com>
 <20190619181354.325242c09d5c2ef44f430b4a@linux-foundation.org>
In-Reply-To: <20190619181354.325242c09d5c2ef44f430b4a@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:8b5f]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 44ea46d6-3ada-410f-fee5-08d6f5239876
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1550;
x-ms-traffictypediagnostic: MWHPR15MB1550:
x-microsoft-antispam-prvs: <MWHPR15MB15505A6781182259846004F1B3E40@MWHPR15MB1550.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 0074BBE012
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(366004)(39860400002)(396003)(376002)(346002)(199004)(189003)(25786009)(6916009)(81166006)(446003)(2906002)(8676002)(6436002)(57306001)(99286004)(73956011)(71200400001)(66946007)(186003)(71190400001)(81156014)(66476007)(46003)(50226002)(476003)(68736007)(486006)(53546011)(102836004)(6506007)(6116002)(64756008)(36756003)(76116006)(66556008)(8936002)(66446008)(33656002)(2616005)(7736002)(86362001)(305945005)(11346002)(76176011)(6246003)(54906003)(14454004)(6486002)(14444005)(316002)(256004)(229853002)(5660300002)(4326008)(53936002)(6512007)(478600001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1550;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 9su698P8gMruShFzeGV9nlhFwd0vBofhQYtZnVaZ9ZmgfgKDM2xD3PH7fr9nRl6RCJ22UlJzbQGWUdytZTnwCrAZl3FYSNp3oVSW5mYtEiQO3a1nZ5dtREmJ4QhFsSFKx+u/4ZD579R984y8t3mG05BI2zqCVJoR7cFB//FE5GhP9qKNBNlJK6oMdGryAl8iP9KIRdpcqnNW95w91ntt8EnaPk3RHGfZ+lfI9OEjZlbCM1XqbpyLAguNzZA8RcSGLQCvTqTc7q5V9oGuN8YbvySiZImr4lc1BkbG3WaiR1Uf79UazIvbLcI8WkhbMuwwhcd12NdTyT41bQRXWfx8T/fKtxiE2W2JynTZthRpyMHIlDRStgdppWY4W56F/QGSGZTenNi7Ct1DtLeqt04ewzMw3aUojWXPH9PcAnfHMu4=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <15BC646F1A4D2F449564EA5E0D3B0EF3@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 44ea46d6-3ada-410f-fee5-08d6f5239876
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Jun 2019 02:04:14.8828
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1550
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200014
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 19, 2019, at 6:13 PM, Andrew Morton <akpm@linux-foundation.org> wr=
ote:
>=20
> On Tue, 18 Jun 2019 21:48:16 +0000 Song Liu <songliubraving@fb.com> wrote=
:
>=20
>>> I'm wondering if this limitation can be abused in some fashion: mmap a
>>> file to which you have read permissions, run madvise(MADV_HUGEPAGE) and
>>> thus prevent the file's owner from being able to modify the file?  Or
>>> something like that.  What are the issues and protections here?
>>=20
>> In this case, the owner need to make a copy of the file, and then remove=
=20
>> and update the original file.=20
>>=20
>> In this version, we want either split huge page on writes, or fail the=20
>> write when we cannot split. However, the huge page information is only=20
>> available at page level, and on the write path, page level information=20
>> is not available until write_begin(). So it is hard to stop writes at=20
>> earlier stage. Therefore, in this version, we leverage i_mmap_writable,=
=20
>> which is at address_space level. So it is easier to stop writes to the=20
>> file.=20
>>=20
>> This is a temporary behavior. And it is gated by the config. So I guess
>> it is OK. It works well for our use cases though. Once we have better=20
>> write support, we can remove the limitation.=20
>>=20
>> If this is too weird, I am also open to suggestions.=20
>=20
> Well, it's more than weird?  This permits user A to deny service to
> user B?  User A can, maliciously or accidentally, prevent user B from
> modifying a file which user B has permission to modify?  Such as, umm,
> /etc/hosts?

I have removed this behavior in v3. I think we really don't need this.=20

Thanks,
Song

