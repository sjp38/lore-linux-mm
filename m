Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3F97C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 14:36:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4211C2054F
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 14:36:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="EJYQRq1x";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="GIKQc9Nj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4211C2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6C1E6B0003; Mon, 12 Aug 2019 10:36:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C430E6B0005; Mon, 12 Aug 2019 10:36:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0A5E6B0006; Mon, 12 Aug 2019 10:36:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0034.hostedemail.com [216.40.44.34])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1AD6B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 10:36:32 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 35D2E181AC9B4
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:36:32 +0000 (UTC)
X-FDA: 75814026624.21.hands75_560abb8b88d5b
X-HE-Tag: hands75_560abb8b88d5b
X-Filterd-Recvd-Size: 11109
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 14:36:31 +0000 (UTC)
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7CEYrfj000752;
	Mon, 12 Aug 2019 07:36:29 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=RN9FaKlDGnjFd716fOZN3np0ZuBkqvH9c+S8sf7rITk=;
 b=EJYQRq1xer7eYLeQg7erFkXcPxEQRrwmGE4VZyEEYozS02FsB9em4hIL5uJ2XEEtKxkS
 qbckoBHpJLPxN068ss0GAfw93e+4Z7iqBpZ6aWSEgka4BnniRNkv2Vmv0e4tUkP+C41Q
 OkElj+GYttsSTkgOYDqeXvv2tmVlSEUtVA8= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ub9rsg2pm-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 12 Aug 2019 07:36:29 -0700
Received: from prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) by
 prn-hub03.TheFacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 12 Aug 2019 07:36:29 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 12 Aug 2019 07:36:29 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 12 Aug 2019 07:36:29 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=EMJT7SSAARTkQhKP7uz+RLQyAS+Axn+6nYgKcTJeYuLneCgu91y/msI6IZIHY/SYRXvudETCLvCAOOej/gaFHhO/QPjj+Oj8NuztKoUNeWje2AqG2vEcMidEzYJAiPDamizldYRfHn30VSPMvg9JMyttsEGJhi1AxCvBF3cjWaBJ/tjVAx6jJdtwBVlJzGUEOVOn5ZpnYVkswcIhK3Ngugcfaqdkl6OUiQbrPWeRiX7b52RDTDXmd8iuew3KYQtE1CTE0Adj9XhA4H14URlWSI7brC1y4Mlq3Btco9cpux7ojy+i0p1K1GJY6dgQznsqq8IyF+4iz6OTv5AnOCR5mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RN9FaKlDGnjFd716fOZN3np0ZuBkqvH9c+S8sf7rITk=;
 b=Wo+rQx9VLtIcmH4ROtBHoVfPdeLHQ/egheTGlbxDjSndopn5TMm8O00jRVZLCsiuCSFg2VdQi3Uc3bgPN6XmpEng3plPndrBZBihNmkKdZB+dNher0vw1Kn/RNtt0L5ne3QgLrBC2s+U+KZX4wcdcLjRSJg4b0DmkIEFJA4m4rj9dMh/X8nwtdYARQWQ6MwrY0EjCyJ2O7rkfpD1Q+9ZtoRNn7PgZGcbCbFLv2v6cpHM/Vci+xVZxauVOrFkEPPcMfGXNpc76yPb6pS00SWE5GlKAY0H8ggkpVtuQ7YXrS7MlNN+nMTkugoXcQ9UID9fIWYJhhyAuaRZbhYqv3izfg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RN9FaKlDGnjFd716fOZN3np0ZuBkqvH9c+S8sf7rITk=;
 b=GIKQc9Njnh7hhVyvPC4MV0HLxu/depUTt/hYr+LTLPiYq09/Ef9KjtjsFmF2hB+NRfn6WmBCHO92/yJ9/y1FEfrvSHDAr9RRx51FJRJQeePxah83X7tI3CxXEXW8hXW6M08WG7hZClvCeceFy2XSZ5TjaC0cEdce8g6wUIvJ3sc=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1151.namprd15.prod.outlook.com (10.175.2.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.14; Mon, 12 Aug 2019 14:36:12 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d%9]) with mapi id 15.20.2157.022; Mon, 12 Aug 2019
 14:36:12 +0000
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
Thread-Index: AQHVTXlDuUiBx4u3AUqTmiQ0C68ad6bxcvOAgAAJMACAAXXfAIAAEp4AgAAZUACABGTDgIAAGOsA
Date: Mon, 12 Aug 2019 14:36:11 +0000
Message-ID: <0BD4D364-51BE-4844-8270-9A664C3E6216@fb.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-6-songliubraving@fb.com>
 <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
 <20190812130659.GA31560@redhat.com>
In-Reply-To: <20190812130659.GA31560@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::4519]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4a8cd62f-1759-4bc8-f835-08d71f326c38
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1151;
x-ms-traffictypediagnostic: MWHPR15MB1151:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <MWHPR15MB115132D1D67A9ABB7B7C0D69B3D30@MWHPR15MB1151.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:5236;
x-forefront-prvs: 012792EC17
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39860400002)(376002)(396003)(366004)(346002)(199004)(189003)(53936002)(71200400001)(71190400001)(81166006)(81156014)(6486002)(316002)(99286004)(6512007)(5660300002)(50226002)(76116006)(6916009)(2906002)(66446008)(66946007)(229853002)(66556008)(54906003)(66476007)(64756008)(6436002)(8936002)(86362001)(6246003)(36756003)(478600001)(4326008)(102836004)(46003)(256004)(7736002)(14454004)(305945005)(14444005)(33656002)(25786009)(8676002)(6506007)(57306001)(6116002)(76176011)(486006)(186003)(2616005)(53546011)(476003)(11346002)(446003);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1151;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: i4wAFsRZXzhnPe7MTQvDkxTDxK2UyQqZ+7Sd5dZQPcBx+C5D28ZYWqTKMzcJjnxxK0giXUp1ezjsAjyDnyQK0fvvgQiHE4zq4buLNyWR3A56WR4Eh/09PIppt62WEhKr/1Lm53+qd0e6QcG0Tc3iJ1uPWFywNgbtqlXG26fZjWYILEPJvNka7oeY4z8H6gQ/FXD3WOnSa4+9HewUOhqNW39ddy9ha79apSD5Y6WmHREQUJCWyp3ODK2FPo2Rq+4aXrkdKiYogDEJp5rCXrpSx4wszAbqzC8tnU/I0p2h6EZFHxq3z/vapK3cOi+/v/jZx+qalXxT+HO+wTAG/tWdH5aR21f5Ih6lmN9e1TVEfGpeHo6ZRtguK5NSsIwsYYeVEAfUQEFue67WLrXkgofvdcHpPLOCxfIVtjr+zlsClhw=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <301B9EE7F0B62C438BDA2973ED161B30@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 4a8cd62f-1759-4bc8-f835-08d71f326c38
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Aug 2019 14:36:11.8614
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: UbTSrmwvphCxOyn0Z+8eEYjvUUElg6H8sAgMjn12uM97Pvj0XX/phYz18TU/i580J+Dd/26KVInF7C0qGUE48w==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1151
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-12_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=485 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908120163
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 12, 2019, at 6:06 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> On 08/09, Song Liu wrote:
>>=20
>> +void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long addr)
>> +{
>> +	unsigned long haddr =3D addr & HPAGE_PMD_MASK;
>> +	struct vm_area_struct *vma =3D find_vma(mm, haddr);
>> +	struct page *hpage =3D NULL;
>> +	pmd_t *pmd, _pmd;
>> +	spinlock_t *ptl;
>> +	int count =3D 0;
>> +	int i;
>> +
>> +	if (!vma || !vma->vm_file ||
>> +	    vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE)
>> +		return;
>> +
>> +	/*
>> +	 * This vm_flags may not have VM_HUGEPAGE if the page was not
>> +	 * collapsed by this mm. But we can still collapse if the page is
>> +	 * the valid THP. Add extra VM_HUGEPAGE so hugepage_vma_check()
>> +	 * will not fail the vma for missing VM_HUGEPAGE
>> +	 */
>> +	if (!hugepage_vma_check(vma, vma->vm_flags | VM_HUGEPAGE))
>> +		return;
>> +
>> +	pmd =3D mm_find_pmd(mm, haddr);
>> +	if (!pmd)
>> +		return;
>> +
>> +	/* step 1: check all mapped PTEs are to the right huge page */
>> +	for (i =3D 0, addr =3D haddr; i < HPAGE_PMD_NR; i++, addr +=3D PAGE_SI=
ZE) {
>> +		pte_t *pte =3D pte_offset_map(pmd, addr);
>> +		struct page *page;
>> +
>> +		if (pte_none(*pte) || !pte_present(*pte))
>> +			continue;
>=20
> 		if (!pte_present(*pte))
> 			return;
>=20
> you can't simply flush pmd if this page is swapped out.

hmm... how about
		if (pte_none(*pte))
			continue;

		if (!pte_present(*pte))
			return;

If the page hasn't faulted in for this mm, i.e. pte_none(), we
can flush the pmd.=20

>=20
>> +
>> +		page =3D vm_normal_page(vma, addr, *pte);
>> +
>> +		if (!page || !PageCompound(page))
>> +			return;
>> +
>> +		if (!hpage) {
>> +			hpage =3D compound_head(page);
>> +			/*
>> +			 * The mapping of the THP should not change.
>> +			 *
>> +			 * Note that uprobe may change the page table,
>=20
> Not only uprobe can cow the page. Debugger can do. Or mmap(PROT_WRITE, MA=
P_PRIVATE).
>=20
> uprobe() is "special" because it a) it works with a foreign mm and b)
> it can't stop the process which uses this mm. Otherwise it could simply
> update the page returned by get_user_pages_remote(FOLL_FORCE), just we
> would need to add FOLL_WRITE and if we do this we do not even need SPLIT,
> that is why, say, __access_remote_vm() works without SPLIT.

Will update the comment in next version.=20

Thanks!
Song



