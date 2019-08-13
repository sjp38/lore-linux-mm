Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFA5AC32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:44:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70CAA20651
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:44:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="pcS4SbEu";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="kyGq+SHg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70CAA20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF8FC6B000A; Tue, 13 Aug 2019 10:44:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA9246B000C; Tue, 13 Aug 2019 10:44:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4A1F6B000D; Tue, 13 Aug 2019 10:44:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0087.hostedemail.com [216.40.44.87])
	by kanga.kvack.org (Postfix) with ESMTP id A422E6B000A
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:44:46 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4E4EA63D
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:44:46 +0000 (UTC)
X-FDA: 75817676172.11.dress91_46a0fa88f153f
X-HE-Tag: dress91_46a0fa88f153f
X-Filterd-Recvd-Size: 10679
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:44:45 +0000 (UTC)
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7DEdfqM003202;
	Tue, 13 Aug 2019 07:44:42 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=yH0xkvphXN2pvlHlFD8nixFsAn/Z/Bz3PIcG6BXDJ4U=;
 b=pcS4SbEu45IvC9Mwn0o3YfOWbBYTbExWT1rviUm5fxPpBiR+oBhbO/a86GU+IsL0uYn3
 cvYrAyw7KrncnQr2SMhabNRN/1hrwWT+wc1+bL8hGogWYnXLZMI5ZAgRFiqfheoinxrR
 B98iyCd40QordCE/czNc6UDRoRuJ+UC69as= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2ubu810xnh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Tue, 13 Aug 2019 07:44:42 -0700
Received: from ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) by
 ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 13 Aug 2019 07:44:41 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.101) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Tue, 13 Aug 2019 07:44:41 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=ExLSDDAN+5xj1wCvpxnMZ3F7mQTt5uCzwmw087AJbiKup9jxnROYQ3SU2WBIeIhj5Jelec90CRQ41cGaCmAkdMBlHk3qkzoSLonKbDgF/M6l7WgBFoeFY/Hg//c48XXxhkhu6tuRA2m7eu9P4PCCJgqGQP8QvnHh1teqTCci047Nr/5Butj9ja3ItGiyIr0QZtZagSM8hKkcGu0+yOuQPsBg0bW/0rsTifdJC126K89a3EMeHnxklz6sAlzdnH/QIn4wqPK3Uk5oc9OLvwGj0NCa09G8sPcysWvjF8LSwrbritegQKWTCcAtbg1Jo/zN0GB3/xY/8CAP3wyHyrLJTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yH0xkvphXN2pvlHlFD8nixFsAn/Z/Bz3PIcG6BXDJ4U=;
 b=JsqTwSdZhUhskR2gidGbCpm09f+IETczQ1dQP8izcTJGbvYhXYly8Dl1zQCen24VbH72yVSCMGn+erE3inpy9GAhwHdRnCmE+PVni+y3fTlZRXfOBVp/tcFJgqiTn7wSrgskHL5FrhSuNGEFIsfEZa/6UQKb9F6+MnBk5hXjV37rRirVMl+93cCuJpph0jaHD0+JgA1FI0wdmrMuioow+ixFSczSQO+u9Liv3yYMwsigkD9YlBq0rMKTh5n7Z1KPT6fJaqcoEbSpn0OcT+h4pWUhZ9oCfe1sgUtCowe5O1NlSjUJNy4NVJiZk+tV6kBAja2MpWqWkUanMYYCZQTf7Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yH0xkvphXN2pvlHlFD8nixFsAn/Z/Bz3PIcG6BXDJ4U=;
 b=kyGq+SHgBrOas7vBaPLd3vHleACKDdd9b5A/QQjHH27lv6jAOi73t/ityFCNnigYf12eGQqPC8EU8qzwuoMJ/NeaVLJdlm5ydP43cSKG+CO39q7wFUXxdKlJgXLY9olRI0bHTe1bFtOIs2j1lJy0LQQLKNa5z7atQpl/20x2/hY=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1312.namprd15.prod.outlook.com (10.175.4.13) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.14; Tue, 13 Aug 2019 14:44:40 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d%9]) with mapi id 15.20.2157.022; Tue, 13 Aug 2019
 14:44:40 +0000
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
	<srikar@linux.vnet.ibm.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        "Kirill A.
 Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Topic: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Index: AQHVTXlDuUiBx4u3AUqTmiQ0C68ad6bxcvOAgAAJMACAAXXfAIAAEp4AgAAZUACABFVTAIAAE+cAgAAVvICAAGtUAIABKBiA
Date: Tue, 13 Aug 2019 14:44:40 +0000
Message-ID: <857DA509-D891-4F4C-A55C-EE58BC2CC452@fb.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-6-songliubraving@fb.com>
 <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
 <20190812121144.f46abvpg6lvxwwzs@box> <20190812132257.GB31560@redhat.com>
 <20190812144045.tkvipsyit3nccvuk@box>
 <2D11C742-BB7E-4296-9E97-5114FA58474B@fb.com>
In-Reply-To: <2D11C742-BB7E-4296-9E97-5114FA58474B@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::b9f9]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 39b36ae0-ec90-480f-8079-08d71ffcc58b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1312;
x-ms-traffictypediagnostic: MWHPR15MB1312:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <MWHPR15MB131251072713338671A14A87B3D20@MWHPR15MB1312.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 01283822F8
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(376002)(366004)(396003)(136003)(346002)(189003)(199004)(33656002)(53546011)(102836004)(46003)(6436002)(476003)(305945005)(2616005)(11346002)(53936002)(54906003)(229853002)(186003)(6506007)(76176011)(14454004)(6916009)(86362001)(99286004)(66946007)(6486002)(478600001)(446003)(2906002)(6116002)(57306001)(6512007)(316002)(486006)(256004)(14444005)(36756003)(5660300002)(6246003)(7416002)(81156014)(5024004)(71190400001)(66446008)(64756008)(8936002)(71200400001)(4326008)(25786009)(50226002)(8676002)(76116006)(81166006)(66476007)(66556008)(7736002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1312;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 6bCzqwWa4tBAMPh3N9kK6BiQJuzOPSwERYvtyzhtOSNYKMdRXFmfb+8Z+xmVjlpkpcMd9EGwERShEbyLh5iUjLk+QHFwB3ZTRJqsDK3kLEeHdOqNti/oE6+c4xhMDq1OU6J4hkYo7jUGv6SPdP3oPepvKkZWWCBi7H95pCsLPTsZ7dvn0vMNcYAxO/3eRhRipK2C0GmE8bg3TI5E5SFAPgtf3V8aEWipuKW+I0jN8PmyXIk16zamXEiTVELy1AIWBX6i+qnGTkI0fymdfsuBpnChJc2CiV30LxUmk6H37zl2m3I1LhKPHRiwhkdk3lpma9q/RpGIV4NFKAEuFE1wb4FQAAuhRYFdSDNzFptrV8b+P1jmaR5AGxUu+fz/U1ObDSO1P+BJT/nM4mJzhdHIMZECyxnHpJyYQ9OZ0TWhJo4=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <9FB0981101AC8245A04EE324AAD61837@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 39b36ae0-ec90-480f-8079-08d71ffcc58b
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Aug 2019 14:44:40.0299
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: oMfXHxipdLeSMNkpJ385Kd5lgC7X6CMX/ofJAFeyebDnASkq9EM3GvvgRLRWXIRnPVLTzbn8GJvj71+vTqqQgg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1312
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-13_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=680 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908130156
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Oleg,

> On Aug 12, 2019, at 2:04 PM, Song Liu <songliubraving@fb.com> wrote:
>=20
>=20
>=20
>> On Aug 12, 2019, at 7:40 AM, Kirill A. Shutemov <kirill@shutemov.name> w=
rote:
>>=20
>> On Mon, Aug 12, 2019 at 03:22:58PM +0200, Oleg Nesterov wrote:
>>> On 08/12, Kirill A. Shutemov wrote:
>>>>=20
>>>> On Fri, Aug 09, 2019 at 06:01:18PM +0000, Song Liu wrote:
>>>>> +		if (pte_none(*pte) || !pte_present(*pte))
>>>>> +			continue;
>>>>=20
>>>> You don't need to check both. Present is never none.
>>>=20
>>> Agreed.
>>>=20
>>> Kirill, while you are here, shouldn't retract_page_tables() check
>>> vma->anon_vma (and probably do mm_find_pmd) under vm_mm->mmap_sem?
>>>=20
>>> Can't it race with, say, do_cow_fault?
>>=20
>> vma->anon_vma can race, but it doesn't matter. False-negative is fine.
>> It's attempt to avoid taking mmap_sem where it can be not productive.
>>=20
>> mm_find_pmd() cannot race with do_cow_fault() since the page is locked.
>> __do_fault() has to return locked page before we touch page tables.
>> It is somewhat subtle, but I wanted to avoid taking mmap_sem where it is
>> possible.
>>=20
>> --=20
>> Kirill A. Shutemov
>=20
> Updated version attached.=20
>=20
>=20
> Besides feedbacks from Oleg and Kirill, I also revise the locking in=20
> collapse_pte_mapped_thp(): use pte_offset_map_lock() for the two loops=20
> to cover highmem. zap_pte_range() has similar use of the lock.=20
>=20
> This change is suggested by Johannes.=20
>=20

Do you have further comments for the version below? If not, could you
please reply with your Acked-by or Reviewed-by?

Thanks,
Song


>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D 8< =3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> From 3d931bc4780abb6109fe478a4b1a0004ce81efe1 Mon Sep 17 00:00:00 2001
> From: Song Liu <songliubraving@fb.com>
> Date: Sun, 28 Jul 2019 03:43:48 -0700
> Subject: [PATCH 5/6] khugepaged: enable collapse pmd for pte-mapped THP
>=20

[...]=

