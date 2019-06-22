Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE7DCC43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 04:48:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11D492075E
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 04:48:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Ahuczc3Y";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="MLNpD0rZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11D492075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 749D56B0003; Sat, 22 Jun 2019 00:48:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FADF8E0002; Sat, 22 Jun 2019 00:48:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5998E8E0001; Sat, 22 Jun 2019 00:48:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 34F1F6B0003
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 00:48:44 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id n82so164777ybg.10
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 21:48:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Ge55FUa7qfaj4R5csk5DvO4vnJxSG45JSpxaqoQOo1o=;
        b=Wxn0M97jnud2sAFvRYkKt1jW8ZMPNkghE9CFP1tDrYAYVnY0nIWlAGHMkaeMpjFJLE
         aOQlr+BFKUcHzPI1koVqHOt+gnWns0q6y2OD16rPBBTwrcS8Gc7AMmpmTJGoGlfCRfp+
         WCw+KqoQ8YnDVC5IKl1V+R0CQMCTPqNii8JRBloahrbap7mn9Buj9RBx2BiPVymNAmpD
         8dwKtFq/LUcwf7c2YRFw/u8jojO4bp3Z/xpQik6mhLbqCXC8XAam+/Y0THkwVqYUTIM6
         vP+hnMW0sgKPEm69Q9qG50t5Nn/hXPsndbPh2WkKtE+UHCb2Dd912V/NINqji3wu7Gs0
         DFGA==
X-Gm-Message-State: APjAAAUDwLMLJNJ6EwcmSmb8Fs+AeCYWg8iwONidxn61jpF1CRsWbIFF
	P+w+EdPdLOcHVa6SAhqOt5g5H0/S0pD9HxcXdp3XjlczQgLelf22arVFZDwa8GviiBK8sCGrgkT
	mK7o43xta2EzRKvRB9MWCQXN34jutGxX+AoDcUtRK2ttLuGB8brs34nUZyBy8LQWBbg==
X-Received: by 2002:a25:84d1:: with SMTP id x17mr69238578ybm.397.1561178923903;
        Fri, 21 Jun 2019 21:48:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxHoUWcXIXya3QwU2GZzJ7WB5sHNIpwo0UGP96CSYdJJCTXBxolwPgfGDPNqIEVlYtsvob
X-Received: by 2002:a25:84d1:: with SMTP id x17mr69238570ybm.397.1561178923207;
        Fri, 21 Jun 2019 21:48:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561178923; cv=none;
        d=google.com; s=arc-20160816;
        b=mxRiSY8zoiAtn7jgcuBCtbfDDKGyYu20cBCfNvpmSDqZf+PS2Pqzt/pclQsKMENLX+
         O4CoIJC5wEKrIcNaHGyh+P2Rny9JgUW//6WxSeSWrlscLv5FTpOC6y3PgPPABfHwpBeH
         U3N32Wv/83+3gAE/7vrz+1uoxwcOJDxn9/VCDuxUoU3v7WJBHEEN5cOnqhFM0Xpv1iPI
         xQndS+ENpwErkWbYg6PcQiwxnqwcU5ETxZsUkMx8u/ohmbc6zIYqpuVvUAsiSc9SQKzf
         HK6nOsVZBJXnE4ZjXALohBxoUJsL+eZQ0jgIZO+IezJtK2PdZML3GqqfbZMDwd+DiWn6
         MAtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Ge55FUa7qfaj4R5csk5DvO4vnJxSG45JSpxaqoQOo1o=;
        b=f2nQ9eqaBkrQYJZ7jXguvl1VhYpHLKC0/h6slM51yEv6SAkSZN17Hzno2KeOl13jsE
         aDCf5gKI2lxN3cCydsPpfg8flRGyMaJBnu+a1vhJZnGUpyV+SwVBrvzQ11CZLOYTbATm
         hUvZWdf71uYNGL6pz7pkD7eO2w/rjlYI+lUdQ84ZGRluXYAnbjOVtg23t/Q/9pySUL9Z
         8XAYt/IaT+CTEB+BG4uXz9tDLkRZbiEQGR+ThPZ4ZcoxUOXQJNg8XGjLg1TtSeK9WbWi
         Q8fGgMpsS6ZLfaQoHtPWuhwClpxlCDaJbmqFj70QgAiXK92A3GJhP6YyzDAqOFLF1yWs
         uXzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Ahuczc3Y;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=MLNpD0rZ;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 206si1681263ywf.423.2019.06.21.21.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 21:48:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Ahuczc3Y;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=MLNpD0rZ;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5M4dhdk002638;
	Fri, 21 Jun 2019 21:48:41 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=Ge55FUa7qfaj4R5csk5DvO4vnJxSG45JSpxaqoQOo1o=;
 b=Ahuczc3YMlaD7KIyAWJOcA10zwJBwrJQc16cDLb52TWXjIvCEGNuhF7RcDpTBMPE5eej
 lJ9x69Z3BCwwCYMo4BLRX+rUzWzCbqWjLgXcbXcjerjKaLapBaxeGhuveWFUjLOk5R62
 TZkQN26EFyLQwSkMumtlEIcwigdibALHc40= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9d3er2eu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 21 Jun 2019 21:48:41 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 21 Jun 2019 21:48:40 -0700
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 21 Jun 2019 21:48:40 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Ge55FUa7qfaj4R5csk5DvO4vnJxSG45JSpxaqoQOo1o=;
 b=MLNpD0rZgmzdxlqnaMRyhk/OW5c6NDpNm+Vit2jhcvoGO1HHQa3O1qIlL4gKk7jeDq11N2sr07GIsNAa3RrgwrkacAvgYm6fEF6W/4soKmBXhbawybfhnGE3Th3pck+VjONyTm/EOkIB9Fy2S9lQntKMQBcCTEExmSLj+nnRmP0=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1471.namprd15.prod.outlook.com (10.173.233.137) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.12; Sat, 22 Jun 2019 04:48:25 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.014; Sat, 22 Jun 2019
 04:48:25 +0000
From: Song Liu <songliubraving@fb.com>
To: Hillf Danton <hdanton@sina.com>
CC: Linux-MM <linux-mm@kvack.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 4/6] khugepaged: rename collapse_shmem() and
 khugepaged_scan_shmem()
Thread-Topic: [PATCH v6 4/6] khugepaged: rename collapse_shmem() and
 khugepaged_scan_shmem()
Thread-Index: AQHVKKhH0iJY1YD8bkGfCTvF/8doEqanGiIA
Date: Sat, 22 Jun 2019 04:48:25 +0000
Message-ID: <55244DE8-D7BD-4DBB-A518-45CA746DE4FE@fb.com>
References: <20190622031151.3316-1-hdanton@sina.com>
In-Reply-To: <20190622031151.3316-1-hdanton@sina.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:e75a]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 19273941-80fe-416e-04be-08d6f6ccdc82
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1471;
x-ms-traffictypediagnostic: MWHPR15MB1471:
x-microsoft-antispam-prvs: <MWHPR15MB1471817921291D172FA05DD7B3E60@MWHPR15MB1471.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7219;
x-forefront-prvs: 0076F48C8A
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(39860400002)(136003)(376002)(346002)(189003)(199004)(14454004)(81166006)(81156014)(6512007)(99286004)(76116006)(64756008)(102836004)(8676002)(66476007)(66446008)(66556008)(66946007)(73956011)(54906003)(316002)(71200400001)(71190400001)(5660300002)(68736007)(256004)(14444005)(8936002)(25786009)(86362001)(4326008)(186003)(33656002)(229853002)(57306001)(7736002)(53546011)(36756003)(478600001)(6116002)(2616005)(6506007)(6246003)(305945005)(50226002)(6486002)(6436002)(486006)(76176011)(6916009)(46003)(2906002)(476003)(11346002)(53936002)(446003);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1471;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 7Ky2ztEtEzuGvqNpculwpX8J9tTFv/8GssQEI+4G+zFbT/9rNk39rUkl3R6X/zaT0g026qFpTe26pbC863QN3Nm2Ies+buc0h2Oegr4p2DZxeIZuix9XN5T6uNsDaTi4fLQc/SlznCNBbrTBd6OCeZa11lYPi6OAQEer0y2Y0ISJ5leKAjnvYIZtV7SCNqkfeaqicIRzlemyPCJN4DHgmOiF+m0J5uAkAEkkafLfZbOYPQUMrhhDEIqZMPbTIMHgADuhbhqrlo/LIn3NfZih4eNCpAe6PFpxysrQUrrEi+Xjg+jr9kmMYNZ79uEl5AwDNQQi38ZHBwFsJN7IAligXItzWw1U7YGD44tKRCVIx67EkbAsfKRqQFWPtU/Gv3Ob5biI/YeigUED2CrI/BsCEh4B5DrycRJuoZpuQXJpZHo=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <C0A1412AD7F79E4083FAF55DF07CF8C8@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 19273941-80fe-416e-04be-08d6f6ccdc82
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Jun 2019 04:48:25.1022
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1471
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-22_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=840 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906220042
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 21, 2019, at 8:11 PM, Hillf Danton <hdanton@sina.com> wrote:
>=20
>=20
> Hello
>=20
> On Fri, 21 Jun 2019 17:05:10 -0700 Song Liu <songliubraving@fb.com> wrote=
:
>> Next patch will add khugepaged support of non-shmem files. This patch
>> renames these two functions to reflect the new functionality:
>>=20
>>    collapse_shmem()        =3D>  collapse_file()
>>    khugepaged_scan_shmem() =3D>  khugepaged_scan_file()
>>=20
>> Acked-by: Rik van Riel <riel@surriel.com>
>> Signed-off-by: Song Liu <songliubraving@fb.com>
>> ---
>> mm/khugepaged.c | 13 +++++++------
>> 1 file changed, 7 insertions(+), 6 deletions(-)
>>=20
>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>> index 0f7419938008..dde8e45552b3 100644
>> --- a/mm/khugepaged.c
>> +++ b/mm/khugepaged.c
>> @@ -1287,7 +1287,7 @@ static void retract_page_tables(struct address_spa=
ce *mapping, pgoff_t pgoff)
>> }
>>=20
>> /**
>> - * collapse_shmem - collapse small tmpfs/shmem pages into huge one.
>> + * collapse_file - collapse small tmpfs/shmem pages into huge one.
>>  *
>>  * Basic scheme is simple, details are more complex:
>>  *  - allocate and lock a new huge page;
>> @@ -1304,10 +1304,11 @@ static void retract_page_tables(struct address_s=
pace *mapping, pgoff_t pgoff)
>>  *    + restore gaps in the page cache;
>>  *    + unlock and free huge page;
>>  */
>> -static void collapse_shmem(struct mm_struct *mm,
>> +static void collapse_file(struct vm_area_struct *vma,
>> 		struct address_space *mapping, pgoff_t start,
>> 		struct page **hpage, int node)
>> {
>> +	struct mm_struct *mm =3D vma->vm_mm;
>> 	gfp_t gfp;
>> 	struct page *new_page;
>> 	struct mem_cgroup *memcg;
>> @@ -1563,7 +1564,7 @@ static void collapse_shmem(struct mm_struct *mm,
>> 	/* TODO: tracepoints */
>> }
>>=20
>> -static void khugepaged_scan_shmem(struct mm_struct *mm,
>> +static void khugepaged_scan_file(struct vm_area_struct *vma,
>> 		struct address_space *mapping,
>> 		pgoff_t start, struct page **hpage)
>> {
>> @@ -1631,14 +1632,14 @@ static void khugepaged_scan_shmem(struct mm_stru=
ct *mm,
>> 			result =3D SCAN_EXCEED_NONE_PTE;
>> 		} else {
>> 			node =3D khugepaged_find_target_node();
>> -			collapse_shmem(mm, mapping, start, hpage, node);
>> +			collapse_file(vma, mapping, start, hpage, node);
>> 		}
>> 	}
>>=20
>> 	/* TODO: tracepoints */
>> }
>> #else
>> -static void khugepaged_scan_shmem(struct mm_struct *mm,
>> +static void khugepaged_scan_file(struct vm_area_struct *vma,
>> 		struct address_space *mapping,
>> 		pgoff_t start, struct page **hpage)
>> {
>> @@ -1722,7 +1723,7 @@ static unsigned int khugepaged_scan_mm_slot(unsign=
ed int pages,
>> 				file =3D get_file(vma->vm_file);
>> 				up_read(&mm->mmap_sem);
>> 				ret =3D 1;
>> -				khugepaged_scan_shmem(mm, file->f_mapping,
>> +				khugepaged_scan_file(vma, file->f_mapping,
>> 						pgoff, hpage);
>> 				fput(file);
>=20
> Is it a change that should have put some material in the log message?
> Is it unlikely for vma to go without mmap_sem held?

This is a great point. We really need to be more careful. Let me fix=20
it in the next version.=20

Thanks,
Song

