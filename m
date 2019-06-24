Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C81DC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:26:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA159208E4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:26:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="fvv90ATV";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="NiTXhx5C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA159208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 676B38E0005; Mon, 24 Jun 2019 10:26:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6270A8E0002; Mon, 24 Jun 2019 10:26:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C7F38E0005; Mon, 24 Jun 2019 10:26:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 138198E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:26:22 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j7so9687589pfn.10
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:26:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=VNUcNhWYdG8mQDD1p88YZwedYbKAKNHyVEnUA3QHokk=;
        b=Wj3XIHfWW9PWKmrhn3XxMhTm8f4c6MvOxUxlTcVvGWdf2EzcR+22LOfVs8XuBn7P+t
         waRpTRjtsKhVFcqSVlix1fHFH6J3CgSUZzwnW91N37d6xxa/UYLw4IHke8Lid0rLosUz
         DSt6BmnbC2xgUQSpZUeEt21BagFjkcEyeX0sb85w9ICyHiJcvOCRVaFD2s5vXtSL9wyf
         Vx7RGd0kaLj5jgjH+eaQNauC1ta4wew1cOh3Yfyo1kQiC/QOFfVx9/5IANUa40ir6udj
         BzHnFWU1pgoTyEMr4VffaQEjNovSuAOxFY0UJutJ61LaIBfrDSgOUXAI36nD4ObzJ+F6
         qYOA==
X-Gm-Message-State: APjAAAXYxu1FyljUg1aGuV7+1xgKqnrIIJF6f8oIGJNEqjzxO1v9xdej
	3NsmY+RDke+dsTafMmB+ATmdAC3kRS3YSY7HsQPozlKTeHlIPylQiT0CFZ4Ty4KPbakDf2wtbxh
	kY6QpKr+IYSk2L8s8wJvsScPKEYe5Jo+qtSmlNbFLV6VQgBdmh106fq1pmnj0Sl4SKw==
X-Received: by 2002:a17:90a:a404:: with SMTP id y4mr26084724pjp.58.1561386381706;
        Mon, 24 Jun 2019 07:26:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeN9gK1OOCdX63Uowdn43Pn6yOWMMj0sj2rK2WzUO52uDvr7PeTICHXBGoL96RVnKwnRN+
X-Received: by 2002:a17:90a:a404:: with SMTP id y4mr26084651pjp.58.1561386380843;
        Mon, 24 Jun 2019 07:26:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386380; cv=none;
        d=google.com; s=arc-20160816;
        b=iQ2tGhtC+737d6BxkmLC/dypHa1WDftGuQlIVmC/88YP1Kv0VvfNuQ05obb6/+9Osm
         wFH6RhTUpemxSUfO59ThrZN/dy7DAgzBUiEseUPo97VUrJTd8rvm0VEDjjigE3KOZynd
         WUOvU1K4z/cjMJh/GB24x2Onf1//NpVlWUKscp1FowjZl0lyVUDOqN9DPXER/wtshKiY
         HKXdX6eK3V+Tj3R7FkSv1D9jc/XIdzJqoPlBs4KRLfegdkETX/cTaf74csESUQ25hVqU
         Ij/kIAUOw7ryw6SKcc3V1qt+SzkuOgYT57rxRHIm0jbvQSENRBysRT7xCSpn0Z4PnDtH
         LkIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=VNUcNhWYdG8mQDD1p88YZwedYbKAKNHyVEnUA3QHokk=;
        b=AcwnVjlmK6fvU+KHDqqpn0SUMa9m24IrVv8zVlnY4Ry+szpFA3j7hEAg6Iy30kXJ04
         hKH8Y8iDurTw16ydhNze3WPMlSlonKIy+6wC3zIF+ufxK34zdL1nOUG2+vN6tyjBsVKD
         2DCu7TqE3T+sgCDjti0FSkzHK8dUj2/W/4kKRvRJIk5olj7+GzC3TnfHCOz+uzoOlAjo
         ujt2RD4vlkg6tULB+wjCP+q5meLRVym4U0x/U+Vk6mf+o8OQ6CUQEmFvCl1b68j7Evvd
         udVK1IYTBpNm2K2IeFAmD+1aAUAv6SigzB+6SytYODUrJYhkgYg233oTop5NFRQFFp4q
         0uVw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=fvv90ATV;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=NiTXhx5C;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m45si11335651pje.39.2019.06.24.07.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 07:26:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=fvv90ATV;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=NiTXhx5C;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5OENOJE008035;
	Mon, 24 Jun 2019 07:25:46 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=VNUcNhWYdG8mQDD1p88YZwedYbKAKNHyVEnUA3QHokk=;
 b=fvv90ATVTwTg3fjACVh8I/YvPd742uTYfIX1bCkB1o8pj2YrjIbPQgBBpv9zBKG8WB8D
 3N2LoOfKrH7AqPsYZmlmWQ3CRiLGBiAOwTuJrrwIpdl2SNH29J1eSpYDqxN4rlytj0UE
 QZNu1M3TCLGuDTpNJKQDj2b94WDk8CFLACs= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2taujw10dk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Mon, 24 Jun 2019 07:25:45 -0700
Received: from ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) by
 ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 24 Jun 2019 07:25:44 -0700
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Mon, 24 Jun 2019 07:25:44 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=VNUcNhWYdG8mQDD1p88YZwedYbKAKNHyVEnUA3QHokk=;
 b=NiTXhx5CYASW5PXUZt+VUFHKUO6crNdNOpHY6x7ZBtuWc9b+GbXgrkreYqU4FPj7ZRFXWNFfcCnywWLO/n8UGlAu7rgxGhZTBaMYmCc+jzOk3WiRqisF72P4Cj4GJ6ZA0x+EOJfhnKdMIM2ymHITQMtORGUaRD31yGE1TBnOoJg=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1901.namprd15.prod.outlook.com (10.174.99.10) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.13; Mon, 24 Jun 2019 14:25:42 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.014; Mon, 24 Jun 2019
 14:25:42 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "oleg@redhat.com"
	<oleg@redhat.com>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>,
        Kernel Team
	<Kernel-team@fb.com>,
        "william.kucharski@oracle.com"
	<william.kucharski@oracle.com>
Subject: Re: [PATCH v6 5/6] khugepaged: enable collapse pmd for pte-mapped THP
Thread-Topic: [PATCH v6 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Index: AQHVKYdbTu9KGYA+hEyrpX71HNVoZKaqy94AgAASewA=
Date: Mon, 24 Jun 2019 14:25:42 +0000
Message-ID: <24FB1072-E355-4F9D-855F-337C855C9AF9@fb.com>
References: <20190623054829.4018117-1-songliubraving@fb.com>
 <20190623054829.4018117-6-songliubraving@fb.com>
 <20190624131934.m6gbktixyykw65ws@box>
In-Reply-To: <20190624131934.m6gbktixyykw65ws@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:d642]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0d3fe89d-432b-4191-b9ac-08d6f8afd6f9
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1901;
x-ms-traffictypediagnostic: MWHPR15MB1901:
x-microsoft-antispam-prvs: <MWHPR15MB190109F6BF1AAD279D223592B3E00@MWHPR15MB1901.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 007814487B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(366004)(346002)(396003)(376002)(136003)(189003)(199004)(86362001)(25786009)(81156014)(2906002)(186003)(33656002)(316002)(6246003)(6916009)(81166006)(50226002)(64756008)(478600001)(53936002)(66946007)(8676002)(66446008)(66476007)(66556008)(6512007)(73956011)(46003)(76176011)(76116006)(36756003)(68736007)(8936002)(6486002)(476003)(14454004)(53546011)(6506007)(6436002)(99286004)(7736002)(54906003)(4326008)(71200400001)(71190400001)(486006)(57306001)(256004)(5660300002)(6116002)(14444005)(305945005)(2616005)(446003)(11346002)(229853002)(102836004);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1901;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: uu8pUB07v53hS4mfz0wMGmBNrO9IrjTH9MNc4cEh81ZF5KOmcwMLWfalPpKT6N5/9yf2dKFpKsAAyyF9UPWXDuK6Ob07WyFDG/+//0FKB5WcvbJYgQYXkNFvvPaHukYc5x2N12xSnwbD8R6rS+DMZt84dvR/JvF2OkI1Ed7GYiJv1CWt2PzlqUY9D5SJoaw3MinxJKWC+9r4380n9806/Z4XdbQa5VbF93ARTU5ButG8yWLzVc1TiZKU0+0Un4Itvg+OcWcqefCbenm5GfbCxh7XoHSdLjdnqX/FMMVp8KGMprQOcRNYFh4A6ZhQZaflZPHtdjYbbXk5BKIOKp1Bbfy7sZNbv9EW9h9UP++lbHSQFPzfmY8UayNQesGABUHswM2nz3sFb8yDcS723Mm0GjQaQhXg3dPLFF+ZOJQ+4j0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <349B9B8B59FB0F46BCA25A81D92C28A3@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 0d3fe89d-432b-4191-b9ac-08d6f8afd6f9
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jun 2019 14:25:42.7768
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1901
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=710 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906240118
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 24, 2019, at 6:19 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Sat, Jun 22, 2019 at 10:48:28PM -0700, Song Liu wrote:
>> khugepaged needs exclusive mmap_sem to access page table. When it fails
>> to lock mmap_sem, the page will fault in as pte-mapped THP. As the page
>> is already a THP, khugepaged will not handle this pmd again.
>>=20
>> This patch enables the khugepaged to retry retract_page_tables().
>>=20
>> A new flag AS_COLLAPSE_PMD is introduced to show the address_space may
>> contain pte-mapped THPs. When khugepaged fails to trylock the mmap_sem,
>> it sets AS_COLLAPSE_PMD. Then, at a later time, khugepaged will retry
>> compound pages in this address_space.
>>=20
>> Since collapse may happen at an later time, some pages may already fault
>> in. To handle these pages properly, it is necessary to prepare the pmd
>> before collapsing. prepare_pmd_for_collapse() is introduced to prepare
>> the pmd by removing rmap, adjusting refcount and mm_counter.
>>=20
>> prepare_pmd_for_collapse() also double checks whether all ptes in this
>> pmd are mapping to the same THP. This is necessary because some subpage
>> of the THP may be replaced, for example by uprobe. In such cases, it
>> is not possible to collapse the pmd, so we fall back.
>>=20
>> Signed-off-by: Song Liu <songliubraving@fb.com>
>> ---
>> include/linux/pagemap.h |  1 +
>> mm/khugepaged.c         | 69 +++++++++++++++++++++++++++++++++++------
>> 2 files changed, 60 insertions(+), 10 deletions(-)
>>=20
>> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
>> index 9ec3544baee2..eac881de2a46 100644
>> --- a/include/linux/pagemap.h
>> +++ b/include/linux/pagemap.h
>> @@ -29,6 +29,7 @@ enum mapping_flags {
>> 	AS_EXITING	=3D 4, 	/* final truncate in progress */
>> 	/* writeback related tags are not used */
>> 	AS_NO_WRITEBACK_TAGS =3D 5,
>> +	AS_COLLAPSE_PMD =3D 6,	/* try collapse pmd for THP */
>> };
>>=20
>> /**
>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>> index a4f90a1b06f5..9b980327fd9b 100644
>> --- a/mm/khugepaged.c
>> +++ b/mm/khugepaged.c
>> @@ -1254,7 +1254,47 @@ static void collect_mm_slot(struct mm_slot *mm_sl=
ot)
>> }
>>=20
>> #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
>> -static void retract_page_tables(struct address_space *mapping, pgoff_t =
pgoff)
>> +
>> +/* return whether the pmd is ready for collapse */
>> +bool prepare_pmd_for_collapse(struct vm_area_struct *vma, pgoff_t pgoff=
,
>> +			      struct page *hpage, pmd_t *pmd)
>> +{
>> +	unsigned long haddr =3D page_address_in_vma(hpage, vma);
>> +	unsigned long addr;
>> +	int i, count =3D 0;
>> +
>> +	/* step 1: check all mapped PTEs are to this huge page */
>> +	for (i =3D 0, addr =3D haddr; i < HPAGE_PMD_NR; i++, addr +=3D PAGE_SI=
ZE) {
>> +		pte_t *pte =3D pte_offset_map(pmd, addr);
>> +
>> +		if (pte_none(*pte))
>> +			continue;
>> +
>> +		if (hpage + i !=3D vm_normal_page(vma, addr, *pte))
>> +			return false;
>> +		count++;
>> +	}
>> +
>> +	/* step 2: adjust rmap */
>> +	for (i =3D 0, addr =3D haddr; i < HPAGE_PMD_NR; i++, addr +=3D PAGE_SI=
ZE) {
>> +		pte_t *pte =3D pte_offset_map(pmd, addr);
>> +		struct page *page;
>> +
>> +		if (pte_none(*pte))
>> +			continue;
>> +		page =3D vm_normal_page(vma, addr, *pte);
>> +		page_remove_rmap(page, false);
>> +	}
>> +
>> +	/* step 3: set proper refcount and mm_counters. */
>> +	page_ref_sub(hpage, count);
>> +	add_mm_counter(vma->vm_mm, mm_counter_file(hpage), -count);
>> +	return true;
>> +}
>> +
>> +extern pid_t sysctl_dump_pt_pid;
>> +static void retract_page_tables(struct address_space *mapping, pgoff_t =
pgoff,
>> +				struct page *hpage)
>> {
>> 	struct vm_area_struct *vma;
>> 	unsigned long addr;
>> @@ -1273,21 +1313,21 @@ static void retract_page_tables(struct address_s=
pace *mapping, pgoff_t pgoff)
>> 		pmd =3D mm_find_pmd(vma->vm_mm, addr);
>> 		if (!pmd)
>> 			continue;
>> -		/*
>> -		 * We need exclusive mmap_sem to retract page table.
>> -		 * If trylock fails we would end up with pte-mapped THP after
>> -		 * re-fault. Not ideal, but it's more important to not disturb
>> -		 * the system too much.
>> -		 */
>> 		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
>> 			spinlock_t *ptl =3D pmd_lock(vma->vm_mm, pmd);
>> -			/* assume page table is clear */
>> +
>> +			if (!prepare_pmd_for_collapse(vma, pgoff, hpage, pmd)) {
>> +				spin_unlock(ptl);
>> +				up_write(&vma->vm_mm->mmap_sem);
>> +				continue;
>> +			}
>> 			_pmd =3D pmdp_collapse_flush(vma, addr, pmd);
>> 			spin_unlock(ptl);
>> 			up_write(&vma->vm_mm->mmap_sem);
>> 			mm_dec_nr_ptes(vma->vm_mm);
>> 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
>> -		}
>> +		} else
>> +			set_bit(AS_COLLAPSE_PMD, &mapping->flags);
>> 	}
>> 	i_mmap_unlock_write(mapping);
>> }
>> @@ -1561,7 +1601,7 @@ static void collapse_file(struct mm_struct *mm,
>> 		/*
>> 		 * Remove pte page tables, so we can re-fault the page as huge.
>> 		 */
>> -		retract_page_tables(mapping, start);
>> +		retract_page_tables(mapping, start, new_page);
>> 		*hpage =3D NULL;
>>=20
>> 		khugepaged_pages_collapsed++;
>> @@ -1622,6 +1662,7 @@ static void khugepaged_scan_file(struct mm_struct =
*mm,
>> 	int present, swap;
>> 	int node =3D NUMA_NO_NODE;
>> 	int result =3D SCAN_SUCCEED;
>> +	bool collapse_pmd =3D false;
>>=20
>> 	present =3D 0;
>> 	swap =3D 0;
>> @@ -1640,6 +1681,14 @@ static void khugepaged_scan_file(struct mm_struct=
 *mm,
>> 		}
>>=20
>> 		if (PageTransCompound(page)) {
>> +			if (collapse_pmd ||
>> +			    test_and_clear_bit(AS_COLLAPSE_PMD,
>> +					       &mapping->flags)) {
>=20
> Who said it's the only PMD range that's subject to collapse? The bit has
> to be per-PMD, not per-mapping.

I didn't assume this is the only PMD range that subject to collapse.=20
So once we found AS_COLLAPSE_PMD, it will continue scan the whole mapping:
retract_page_tables(), then continue.=20

>=20
> I beleive we can store the bit in struct page of PTE page table, clearing
> it if we've mapped anyting that doesn't belong to there from fault path.
>=20
> And in general this calls for more substantial re-design for khugepaged:
> we might want to split if into two different kernel threads. One works on
> collapsing small pages into compound and the other changes virtual addres=
s
> space to map the page as PMD.

I had almost same idea of splitting into two threads. Or ask one thread to=
=20
scan two lists: one for pages to collapse, the other for page tables to
map as PMD. However, that does need substantial re-design.=20

On the other hand, this patch is much simpler and does the work fine. It is
not optimal, as it scans the whole mapping for opportunity in just one PMD=
=20
range. But the overhead is not in any hot path, so it just works. The extra=
=20
double check in prepare_pmd_for_collapse() makes sure it will not collapse=
=20
wrong pages into pmd mapped.=20

Overall, I believe this is an accurate solution for the problem. We can=20
further improve it. But I really hope to do the improvements after these
two patchsets get in.=20

Thanks,
Song

