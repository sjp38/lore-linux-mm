Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AA85C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:05:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8383A20679
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 21:05:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="E5MhEJLY";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="E4aprigT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8383A20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D92446B0003; Mon, 12 Aug 2019 17:05:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D69086B0006; Mon, 12 Aug 2019 17:05:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEA636B0003; Mon, 12 Aug 2019 17:05:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0188.hostedemail.com [216.40.44.188])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0466B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 17:05:02 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 3897D45AE
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:05:02 +0000 (UTC)
X-FDA: 75815005644.10.wheel14_832ba05a43116
X-HE-Tag: wheel14_832ba05a43116
X-Filterd-Recvd-Size: 20179
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 21:05:01 +0000 (UTC)
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7CL4dt1023960;
	Mon, 12 Aug 2019 14:04:59 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=RY45zl18RK2ykUZHSlpmTbXnCK/WdLTf/jG6I+oZbg0=;
 b=E5MhEJLYLaUZkZgUVP1CcB2X9fvgELPcnRHVdTOmZVtsCTQSlTvBhUJc3T5j2d/m3FAV
 UFR0mN7v27gnwxMiSm2wxTBUnnhLjbXZa0wVkaL2SswpBMCIlo0dtxalsX0qBMjcjLMi
 nzKS9B4D4UuCrPuKEDg4qMUQIGWbSsUPzZ4= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2ubbta16h7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Mon, 12 Aug 2019 14:04:59 -0700
Received: from ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) by
 ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 12 Aug 2019 14:04:57 -0700
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Mon, 12 Aug 2019 14:04:57 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=U4dNigSirsgGbH3P9/Wa3Qao47RdiEA1LtQwDevdSAEUcQHcRwNjVJ2TDws7m79+sUcmGmMzvlJOjbIEp4fgPPgudesUIpMt5Ee1FGQ+AKgpA9KHtVZC9TiX7zKhJTBuCyu7dAAv0vdF+D9elVKJMFv1onKkbxh24ZmgHeQP32vSFLmZs7/6l//69eHxz0NLPJ0vvHrAqx5SDb/Jjth0ecGsy7wzumNTnbsPd5bO4EEUcUe0PpEDadjE/HfBtEDpsWNzfe+j5HRpk9KzSGJvfB2Zt9BusO0RUfyi8ZGhr46wOVmYpaCoQk9upoeMQ8GJ7UlAdMlQ/kr+0MoLm51fcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RY45zl18RK2ykUZHSlpmTbXnCK/WdLTf/jG6I+oZbg0=;
 b=XKSIV72pByGx0D0UqZTlGgd7J4voKn8Y3SNeHvsM4yuEj+r37cr1ab7+NsBEaBeYAaJqbboH2Bsf2B78HQEb6iw/TBbt0nHAVNeSGBz1Rvk9xcn5GI2oRvAVUtr4ua46BOSR/uXl6YjTh5Z8RtqqHbnYYThC8JSWbPAGTaDe03q1aINfSOgi4SEVGpW1zW+7A4WukNkU9tOWbQxBpxXreL5Xdgz/QZUETTCeHPdLXDEGBZRsXnDyS6GwwjChy/XcgJbXno7G2toX+93dPJfBHXngch8YvASh7dHb+hVRKjLpsrmEWet528ORDBUuE2FmPDba0Rr9zBs27+9VgeTsJw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RY45zl18RK2ykUZHSlpmTbXnCK/WdLTf/jG6I+oZbg0=;
 b=E4aprigT1EzsDaHU96Hu41p/YNxK8O2mpOiVv5sFy7uPATe0dsYmouDBrvHcOuz/p6n073zVk6Bo7Q7vesM22Qk8k2O1e6s1X/echIX0sJNBjKEFcBjbMQXgG6iq1sIddM9gxPVBLuOcRndtpSDOEgJYCkj4ZI7pU8AcN1YMBmQ=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1774.namprd15.prod.outlook.com (10.174.255.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.15; Mon, 12 Aug 2019 21:04:56 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d%9]) with mapi id 15.20.2157.022; Mon, 12 Aug 2019
 21:04:55 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: Oleg Nesterov <oleg@redhat.com>,
        Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        Matthew Wilcox <matthew.wilcox@oracle.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Kernel Team
	<Kernel-team@fb.com>,
        William Kucharski <william.kucharski@oracle.com>,
        "srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>,
        Johannes Weiner
	<hannes@cmpxchg.org>
Subject: Re: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Topic: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Index: AQHVTXlDuUiBx4u3AUqTmiQ0C68ad6bxcvOAgAAJMACAAXXfAIAAEp4AgAAZUACABFVTAIAAE+cAgAAVvICAAGtUAA==
Date: Mon, 12 Aug 2019 21:04:55 +0000
Message-ID: <2D11C742-BB7E-4296-9E97-5114FA58474B@fb.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-6-songliubraving@fb.com>
 <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
 <20190812121144.f46abvpg6lvxwwzs@box> <20190812132257.GB31560@redhat.com>
 <20190812144045.tkvipsyit3nccvuk@box>
In-Reply-To: <20190812144045.tkvipsyit3nccvuk@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::2:7e9a]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 01d14d81-80aa-4b2b-dd05-08d71f68ba3c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1774;
x-ms-traffictypediagnostic: MWHPR15MB1774:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <MWHPR15MB1774E8ED8A5084E11237A0CEB3D30@MWHPR15MB1774.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7219;
x-forefront-prvs: 012792EC17
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(346002)(376002)(136003)(39860400002)(396003)(189003)(199004)(81156014)(2906002)(46003)(5024004)(6246003)(5660300002)(36756003)(81166006)(66556008)(478600001)(66476007)(7416002)(14444005)(229853002)(66946007)(66446008)(64756008)(6512007)(6436002)(76116006)(6486002)(50226002)(53936002)(486006)(71190400001)(8936002)(71200400001)(6916009)(6116002)(76176011)(7736002)(8676002)(33656002)(316002)(305945005)(54906003)(25786009)(256004)(11346002)(102836004)(86362001)(446003)(14454004)(57306001)(4326008)(476003)(6506007)(186003)(99286004)(2616005)(53546011);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1774;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: wDsWuOedTZaUYyyoJafVDIlJ5AWUEF7pX38YxCnz1ujHuHdVqhylV5lPjggZJoTAnlDspLNxXhNo3ckufvVaet0TdhWbLdOOOlN6k/pq2tzjqyd0VsHVBysH8QKwDQNl8uudIws5m0edrpQcH3TMcFHXHNFEAg4oUstSc8sxGLHqAkCz0zqMnhRbT8FVqK+eVUY54opkaomwLSBGEifbOIJqF8OjIL3kizzZ6E0KFTh669Yd8gmbnHoHz8NYZE2mPDMPj0Z6q/wK3i3WfL+cMBeBaDN8bS0vl5fHjYOXDP1CsLmClh5hehZfGjeIqAUNynMniSRgMGEpRMLFD8S63Gb8Rnw7bbFEMX1BPz3Pmga8ciCgQQbLq+mtBTM+vPJyT3fIoPdyX1IneqTKNeFihQoN8dVy1R+X83bdrAENhxk=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F4DBE8430CC02541BA9213321D3127FE@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 01d14d81-80aa-4b2b-dd05-08d71f68ba3c
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Aug 2019 21:04:55.6096
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: fTvuuLgy6QXxNrCuYgmdC+cltsBKwrSAXpJs3DkL35u7Zgi7EUqZqixpaH7NBStaxtMBBN9mtqYXKjUZSsihqw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1774
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-12_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=466 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908120205
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 12, 2019, at 7:40 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Mon, Aug 12, 2019 at 03:22:58PM +0200, Oleg Nesterov wrote:
>> On 08/12, Kirill A. Shutemov wrote:
>>>=20
>>> On Fri, Aug 09, 2019 at 06:01:18PM +0000, Song Liu wrote:
>>>> +		if (pte_none(*pte) || !pte_present(*pte))
>>>> +			continue;
>>>=20
>>> You don't need to check both. Present is never none.
>>=20
>> Agreed.
>>=20
>> Kirill, while you are here, shouldn't retract_page_tables() check
>> vma->anon_vma (and probably do mm_find_pmd) under vm_mm->mmap_sem?
>>=20
>> Can't it race with, say, do_cow_fault?
>=20
> vma->anon_vma can race, but it doesn't matter. False-negative is fine.
> It's attempt to avoid taking mmap_sem where it can be not productive.
>=20
> mm_find_pmd() cannot race with do_cow_fault() since the page is locked.
> __do_fault() has to return locked page before we touch page tables.
> It is somewhat subtle, but I wanted to avoid taking mmap_sem where it is
> possible.
>=20
> --=20
> Kirill A. Shutemov

Updated version attached.=20


Besides feedbacks from Oleg and Kirill, I also revise the locking in=20
collapse_pte_mapped_thp(): use pte_offset_map_lock() for the two loops=20
to cover highmem. zap_pte_range() has similar use of the lock.=20

This change is suggested by Johannes.=20

Thanks,
Song

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D 8< =3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
From 3d931bc4780abb6109fe478a4b1a0004ce81efe1 Mon Sep 17 00:00:00 2001
From: Song Liu <songliubraving@fb.com>
Date: Sun, 28 Jul 2019 03:43:48 -0700
Subject: [PATCH 5/6] khugepaged: enable collapse pmd for pte-mapped THP

khugepaged needs exclusive mmap_sem to access page table. When it fails
to lock mmap_sem, the page will fault in as pte-mapped THP. As the page
is already a THP, khugepaged will not handle this pmd again.

This patch enables the khugepaged to retry collapse the page table.

struct mm_slot (in khugepaged.c) is extended with an array, containing
addresses of pte-mapped THPs. We use array here for simplicity. We can
easily replace it with more advanced data structures when needed.

In khugepaged_scan_mm_slot(), if the mm contains pte-mapped THP, we try
to collapse the page table.

Since collapse may happen at an later time, some pages may already fault
in. collapse_pte_mapped_thp() is added to properly handle these pages.
collapse_pte_mapped_thp() also double checks whether all ptes in this pmd
are mapping to the same THP. This is necessary because some subpage of
the THP may be replaced, for example by uprobe. In such cases, it is not
possible to collapse the pmd.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/khugepaged.h |  12 +++
 mm/khugepaged.c            | 168 ++++++++++++++++++++++++++++++++++++-
 2 files changed, 179 insertions(+), 1 deletion(-)

diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
index 082d1d2a5216..bc45ea1efbf7 100644
--- a/include/linux/khugepaged.h
+++ b/include/linux/khugepaged.h
@@ -15,6 +15,14 @@ extern int __khugepaged_enter(struct mm_struct *mm);
 extern void __khugepaged_exit(struct mm_struct *mm);
 extern int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
                                      unsigned long vm_flags);
+#ifdef CONFIG_SHMEM
+extern void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long ad=
dr);
+#else
+static inline void collapse_pte_mapped_thp(struct mm_struct *mm,
+                                          unsigned long addr)
+{
+}
+#endif

 #define khugepaged_enabled()                                          \
        (transparent_hugepage_flags &                                  \
@@ -73,6 +81,10 @@ static inline int khugepaged_enter_vma_merge(struct vm_a=
rea_struct *vma,
 {
        return 0;
 }
+static inline void collapse_pte_mapped_thp(struct mm_struct *mm,
+                                          unsigned long addr)
+{
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */

 #endif /* _LINUX_KHUGEPAGED_H */
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 40c25ddf29e4..cea0fbf2d7b9 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -77,6 +77,8 @@ static __read_mostly DEFINE_HASHTABLE(mm_slots_hash, MM_S=
LOTS_HASH_BITS);

 static struct kmem_cache *mm_slot_cache __read_mostly;

+#define MAX_PTE_MAPPED_THP 8
+
 /**
  * struct mm_slot - hash lookup from mm to mm_slot
  * @hash: hash collision list
@@ -87,6 +89,10 @@ struct mm_slot {
        struct hlist_node hash;
        struct list_head mm_node;
        struct mm_struct *mm;
+
+       /* pte-mapped THP in this mm */
+       int nr_pte_mapped_thp;
+       unsigned long pte_mapped_thp[MAX_PTE_MAPPED_THP];
 };

 /**
@@ -1254,6 +1260,159 @@ static void collect_mm_slot(struct mm_slot *mm_slot=
)
 }

 #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
+/*
+ * Notify khugepaged that given addr of the mm is pte-mapped THP. Then
+ * khugepaged should try to collapse the page table.
+ */
+static int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
+                                        unsigned long addr)
+{
+       struct mm_slot *mm_slot;
+
+       VM_BUG_ON(addr & ~HPAGE_PMD_MASK);
+
+       spin_lock(&khugepaged_mm_lock);
+       mm_slot =3D get_mm_slot(mm);
+       if (likely(mm_slot && mm_slot->nr_pte_mapped_thp < MAX_PTE_MAPPED_T=
HP))
+               mm_slot->pte_mapped_thp[mm_slot->nr_pte_mapped_thp++] =3D a=
ddr;
+       spin_unlock(&khugepaged_mm_lock);
+       return 0;
+}
+
+/**
+ * Try to collapse a pte-mapped THP for mm at address haddr.
+ *
+ * This function checks whether all the PTEs in the PMD are pointing to th=
e
+ * right THP. If so, retract the page table so the THP can refault in with
+ * as pmd-mapped.
+ */
+void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long addr)
+{
+       unsigned long haddr =3D addr & HPAGE_PMD_MASK;
+       struct vm_area_struct *vma =3D find_vma(mm, haddr);
+       struct page *hpage =3D NULL;
+       pte_t *start_pte, *pte;
+       pmd_t *pmd, _pmd;
+       spinlock_t *ptl;
+       int count =3D 0;
+       int i;
+
+       if (!vma || !vma->vm_file ||
+           vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE)
+               return;
+
+       /*
+        * This vm_flags may not have VM_HUGEPAGE if the page was not
+        * collapsed by this mm. But we can still collapse if the page is
+        * the valid THP. Add extra VM_HUGEPAGE so hugepage_vma_check()
+        * will not fail the vma for missing VM_HUGEPAGE
+        */
+       if (!hugepage_vma_check(vma, vma->vm_flags | VM_HUGEPAGE))
+               return;
+
+       pmd =3D mm_find_pmd(mm, haddr);
+       if (!pmd)
+               return;
+
+       start_pte =3D pte_offset_map_lock(mm, pmd, haddr, &ptl);
+
+       /* step 1: check all mapped PTEs are to the right huge page */
+       for (i =3D 0, addr =3D haddr, pte =3D start_pte;
+            i < HPAGE_PMD_NR; i++, addr +=3D PAGE_SIZE, pte++) {
+               struct page *page;
+
+               /* empty pte, skip */
+               if (pte_none(*pte))
+                       continue;
+
+               /* page swapped out, abort */
+               if (!pte_present(*pte))
+                       goto abort;
+
+               page =3D vm_normal_page(vma, addr, *pte);
+
+               if (!page || !PageCompound(page))
+                       goto abort;
+
+               if (!hpage) {
+                       hpage =3D compound_head(page);
+                       /*
+                        * The mapping of the THP should not change.
+                        *
+                        * Note that uprobe, debugger, or MAP_PRIVATE may
+                        * change the page table, but the new page will
+                        * not pass PageCompound() check.
+                        */
+                       if (WARN_ON(hpage->mapping !=3D vma->vm_file->f_map=
ping))
+                               goto abort;
+               }
+
+               /*
+                * Confirm the page maps to the correct subpage.
+                *
+                * Note that uprobe, debugger, or MAP_PRIVATE may change
+                * the page table, but the new page will not pass
+                * PageCompound() check.
+                */
+               if (WARN_ON(hpage + i !=3D page))
+                       goto abort;
+               count++;
+       }
+
+       /* step 2: adjust rmap */
+       for (i =3D 0, addr =3D haddr, pte =3D start_pte;
+            i < HPAGE_PMD_NR; i++, addr +=3D PAGE_SIZE, pte++) {
+               struct page *page;
+
+               if (pte_none(*pte))
+                       continue;
+               page =3D vm_normal_page(vma, addr, *pte);
+               page_remove_rmap(page, false);
+       }
+
+       pte_unmap_unlock(start_pte, ptl);
+
+       /* step 3: set proper refcount and mm_counters. */
+       if (hpage) {
+               page_ref_sub(hpage, count);
+               add_mm_counter(vma->vm_mm, mm_counter_file(hpage), -count);
+       }
+
+       /* step 4: collapse pmd */
+       ptl =3D pmd_lock(vma->vm_mm, pmd);
+       _pmd =3D pmdp_collapse_flush(vma, addr, pmd);
+       spin_unlock(ptl);
+       mm_dec_nr_ptes(mm);
+       pte_free(mm, pmd_pgtable(_pmd));
+       return;
+
+abort:
+       pte_unmap_unlock(start_pte, ptl);
+}
+
+static int khugepaged_collapse_pte_mapped_thps(struct mm_slot *mm_slot)
+{
+       struct mm_struct *mm =3D mm_slot->mm;
+       int i;
+
+       if (likely(mm_slot->nr_pte_mapped_thp =3D=3D 0))
+               return 0;
+
+       if (!down_write_trylock(&mm->mmap_sem))
+               return -EBUSY;
+
+       if (unlikely(khugepaged_test_exit(mm)))
+               goto out;
+
+       for (i =3D 0; i < mm_slot->nr_pte_mapped_thp; i++)
+               collapse_pte_mapped_thp(mm, mm_slot->pte_mapped_thp[i]);
+
+out:
+       mm_slot->nr_pte_mapped_thp =3D 0;
+       up_write(&mm->mmap_sem);
+       return 0;
+}
+
 static void retract_page_tables(struct address_space *mapping, pgoff_t pgo=
ff)
 {
        struct vm_area_struct *vma;
@@ -1287,7 +1446,8 @@ static void retract_page_tables(struct address_space =
*mapping, pgoff_t pgoff)
                        up_write(&vma->vm_mm->mmap_sem);
                        mm_dec_nr_ptes(vma->vm_mm);
                        pte_free(vma->vm_mm, pmd_pgtable(_pmd));
-               }
+               } else
+                       khugepaged_add_pte_mapped_thp(vma->vm_mm, addr);
        }
        i_mmap_unlock_write(mapping);
 }
@@ -1709,6 +1869,11 @@ static void khugepaged_scan_file(struct mm_struct *m=
m,
 {
        BUILD_BUG();
 }
+
+static int khugepaged_collapse_pte_mapped_thps(struct mm_slot *mm_slot)
+{
+       return 0;
+}
 #endif

 static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
@@ -1733,6 +1898,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned =
int pages,
                khugepaged_scan.mm_slot =3D mm_slot;
        }
        spin_unlock(&khugepaged_mm_lock);
+       khugepaged_collapse_pte_mapped_thps(mm_slot);

        mm =3D mm_slot->mm;
        /*
--
2.17.1



