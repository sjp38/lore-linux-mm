Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB200C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:28:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6126920693
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:28:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="qyhR0H5z";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="jXkgWIX6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6126920693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5DEC8E0003; Tue, 30 Jul 2019 13:28:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0F718E0001; Tue, 30 Jul 2019 13:28:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9619C8E0003; Tue, 30 Jul 2019 13:28:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CFF98E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:28:19 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id l141so48014404ywc.11
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:28:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=qhQj2IBUvescjnW+8zn0Zx2UMjQDJCmJ6uGfo4ot6ZQ=;
        b=S0TNpwd0MdVNhwc8+rrjH9F6TWgO2kBo4RRwOZ6K0NcIhboPbVO907Fjsb7X3GLtc3
         KsiXEJezR/qNTUwGgFDOV6yZ3kbu3+et8iUa7jST+euK1CWnVfJZfAUpwb66Qv3wpZfV
         Y0jwClQeaalWUzMzlZYe24LUjsj5jhN4FiyIrAm49aSB2CLg12KDCI8LD1jRTs8oL87K
         FwB0KNKo3iFMg0wQXkLytyrXJCfpM9QzkqiPJh+Tbg8aENr5i6mmQ5vZc/QSx+letEJW
         h52cBV0wmRJtWDa0pMlU2MAMXbEzEav3fTzXUhtymNW/PEN0nenRVf64wkPu5G1olncz
         XC5Q==
X-Gm-Message-State: APjAAAVu8Ch8TazBhehb9ZmT+7czI3UsivR1dXn9HsCR/QCneLVnMhzS
	c7nMziJ9jK4PIDdoPkP0JGzhDJ8imQKsnmc0u3zspXV/ueOTvHzcUDpKB6GN0CvpkBfuw2uNprb
	7EQ2KLJi4XlGgxSuGbwyVYwmZHpy9fkOZiN3i0Ri26hiW0N1QY1z2HD+cdxmeAeMmVg==
X-Received: by 2002:a81:5e44:: with SMTP id s65mr67062472ywb.441.1564507699131;
        Tue, 30 Jul 2019 10:28:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKfGOQYzwAF/PS4XDS24WU2TxQRTo5jC1NsePrUCIK14rBaqfkOc+7QW3lu0Tj5khKS7mi
X-Received: by 2002:a81:5e44:: with SMTP id s65mr67062401ywb.441.1564507698119;
        Tue, 30 Jul 2019 10:28:18 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564507698; cv=pass;
        d=google.com; s=arc-20160816;
        b=BxhcBiANEzIiwuw4HgMkCV4+bwBz0SgiNaz8wGpmw/JK067iGQmkoHg9v1ZcYq7xSz
         zQkSZnzD5PAOQc/abD8w9f3cppABS/rADfKIwHO6OtlDnD6K9DIfyuzE7DRQh1iqHqgX
         rtByIsGD9FkhnxXzw8AtDFRBTl+ymIWYhWkjqGZ1/4kVLrEpBnc9mThTSW0UyX1NCQ0O
         fkclaCXuXLvV72IhBYnxItUTH9FqZWZyrTAykCcxcqmV6+xCEB0SKyg3oEUBYbquhDq2
         w3I9xJSNw+OWA/vnXFNQRZWssrDLv8giCw605hExPgIJeI0FV2Devx4xSA97C28ORF75
         1M8w==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=qhQj2IBUvescjnW+8zn0Zx2UMjQDJCmJ6uGfo4ot6ZQ=;
        b=YwZXbVL/laq87iuFuaVRUoweRs+Vuk7hXf/yqBDuVsQ3Gy9QID3M81+U3zwfZLOiPA
         1iGMknHpBpvHOPgX7U5RflyW1UWdDUdiHFfzRmstebm1pmzG+7WN/IjEhMqDM4QzSRQ0
         33mokhZ953UhhIeBMVNBwuNlEO22Iy4Hbn8BO9DA92XZP+CdrqaEo46PZ15pdO/NLO2m
         YU0GaXQMfb+LTMiXsu2gMImF78UhdmLroGbAVXIiJXOC+ItHgHazxtbwAwxIGYuJD8TJ
         O2cupUD7JO5QqdaBNfdHizkCvsSfCZ79Aulf9iHUcmsXWUdXq45YaOl1fdso6mqAUut9
         j3Ng==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qyhR0H5z;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=jXkgWIX6;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id a14si7607969ybp.39.2019.07.30.10.28.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 10:28:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qyhR0H5z;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=jXkgWIX6;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6UHRjw6026808;
	Tue, 30 Jul 2019 10:28:16 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=qhQj2IBUvescjnW+8zn0Zx2UMjQDJCmJ6uGfo4ot6ZQ=;
 b=qyhR0H5zR/19m8SvTwn/kNBt0r6i4EejsDiPT2t3d3GaEMlSgE7iD39CEQpn+QZV5JnX
 tT1OOErQSgkiVPXA280jKBlTa38gezqKauhRFZ7rKwJhVST2OqOzewxoSmrj7WHNCy6d
 nqTwWVaM4Dj1b6tbhS3X2bYtWprRUfw6y6g= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u2f53taqb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 30 Jul 2019 10:28:15 -0700
Received: from prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 30 Jul 2019 10:28:14 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 30 Jul 2019 10:28:14 -0700
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 30 Jul 2019 10:28:14 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=gxg11wfl2C61zOAi+RkV41YRAgVwM+KLOpN0QoaPgtS9fLfLnHNhI/UAOpcYollQIJHit9FEeCUYW2qy7j9XNXFpcSJdzJtt0I68xjrnJwZxU6GTOV/oC1d+RMFnmlvP/N9crQf7DQROPOuQXBNzuF3GYastgWR3BtHqTw6dZJD2ZZP2GEtn3LbsyZ/m4klfP+jKNDtAQn+yhWfOcKqriyFgA1w7uq1PHcI9vq6cWYNjQMk+j8QONcIYWopO+4IRDBTI9RxJUBsCWbnS+2jsvRxKGjsDC1cI7PJ86haDSa2Ohr/M/hz84REte7834nZ1JLGhLIUt7gi7J4nfXClkUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qhQj2IBUvescjnW+8zn0Zx2UMjQDJCmJ6uGfo4ot6ZQ=;
 b=W3/5rLl4dwmWQdFvqkk/czbTS6CbCj3E4yzHJoXKMLFdI5h421dKHNKlFH9z61keVHocIpqQpdpxV5K5FN9c0KF0K615WgLXWtR6mOMpBGHF8qrgfZ+twFHMH5AeCb+HLL5EWVramPj43u43xkMXsGbWTdkdBvJgOEUXfaUjyiItyFXOSVOCUcHVMBbDgfQUQ7oT0yFLNTVDNabXG4pLLiqeXbSGxxaMIypdeITSbUrVIpclVBHuvXMTPdH1wTlnjRh/z5aMecJC3oQcP8mhaWqQwhernnPThCxHgPSkcjWjWmxUFMsu6X+PYqsJ4uFjCjek2FoeBSFkcsAJa3ddOw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qhQj2IBUvescjnW+8zn0Zx2UMjQDJCmJ6uGfo4ot6ZQ=;
 b=jXkgWIX6rBvrdJCiqLkcMN0orU5rRFW18l1nxD9Cox5RnyktK4nrM8ZalXr5PClWl+I/1kvcIRKUDvbIEDh7fBTwaYku82JXHXm/Z/942LpW7yTCoKQFnpaVVUZtX9gYlRzWmOOh5UfsoNzE/iwf6GOFh4u4HziaJv7Ferhv6nI=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1230.namprd15.prod.outlook.com (10.175.2.148) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.10; Tue, 30 Jul 2019 17:28:13 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b%2]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 17:28:13 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "oleg@redhat.com" <oleg@redhat.com>, Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Thread-Topic: [PATCH 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Thread-Index: AQHVRdCXaB8qUzCo40K8bOFQNuNjzqbjQxwAgAAplQA=
Date: Tue, 30 Jul 2019 17:28:13 +0000
Message-ID: <452746EE-186C-43D8-B15C-9921E587BA3A@fb.com>
References: <20190729054335.3241150-1-songliubraving@fb.com>
 <20190729054335.3241150-2-songliubraving@fb.com>
 <20190730145922.m5omqqf7rmilp6yy@box>
In-Reply-To: <20190730145922.m5omqqf7rmilp6yy@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:5cb8]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1887e6b1-793e-45c7-57fa-08d715134cbd
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1230;
x-ms-traffictypediagnostic: MWHPR15MB1230:
x-microsoft-antispam-prvs: <MWHPR15MB12303F9BC5E6996671715AF7B3DC0@MWHPR15MB1230.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(376002)(366004)(39860400002)(136003)(199004)(189003)(64756008)(66556008)(229853002)(53546011)(486006)(6506007)(66446008)(4326008)(68736007)(86362001)(25786009)(76116006)(66946007)(102836004)(50226002)(305945005)(186003)(7736002)(76176011)(316002)(54906003)(5660300002)(66476007)(99286004)(6116002)(33656002)(11346002)(46003)(256004)(476003)(36756003)(2616005)(71200400001)(14454004)(2906002)(71190400001)(8676002)(6916009)(478600001)(14444005)(8936002)(6486002)(53936002)(6246003)(81166006)(6512007)(6436002)(57306001)(81156014)(446003);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1230;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 6oN+fujpdEwcYIh7o1XCFJsX99Uya5vf4esIp9Up96LJl2vt486tfBgOgk5NAgvn/XpDXTmvgNOn1zmyZTuxcZugqfm8MctDqVnH8FHuGzkg7xm4/7iok8y0ARXUccYkUFydz7JrWgkR94ym852S1Ys/IgPj+G/kzKJ+xa9C9DVUzkdxkI2uKnwuXwehS/f1lpMETIQqBT+xcdlErv1dxuPbF3w8mL9WRldmWWBonMxb2OiG4coSmCo2G+FEfpt11f4o4NTGZM+630oSe56uO0JikV4dw1Yh7aL/9yMwg41/HX0u+Lvpg0BGXCM53RgvXjDmc9SZVjVpiNFhAfm86eYS84GDN9+gWthTCIe8VztROqOFjyVsgD3xs1vDjikhZrJJ5Pz1u4LLKkoBBJlA0x5p3wSEGl+gQGdgiqX69N8=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <4F13321A534DB342B5F10348C15BAEFB@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 1887e6b1-793e-45c7-57fa-08d715134cbd
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 17:28:13.0622
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1230
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-30_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=892 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300183
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 30, 2019, at 7:59 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Sun, Jul 28, 2019 at 10:43:34PM -0700, Song Liu wrote:
>> khugepaged needs exclusive mmap_sem to access page table. When it fails
>> to lock mmap_sem, the page will fault in as pte-mapped THP. As the page
>> is already a THP, khugepaged will not handle this pmd again.
>>=20
>> This patch enables the khugepaged to retry collapse the page table.
>>=20
>> struct mm_slot (in khugepaged.c) is extended with an array, containing
>> addresses of pte-mapped THPs. We use array here for simplicity. We can
>> easily replace it with more advanced data structures when needed. This
>> array is protected by khugepaged_mm_lock.
>>=20
>> In khugepaged_scan_mm_slot(), if the mm contains pte-mapped THP, we try
>> to collapse the page table.
>>=20
>> Since collapse may happen at an later time, some pages may already fault
>> in. collapse_pte_mapped_thp() is added to properly handle these pages.
>> collapse_pte_mapped_thp() also double checks whether all ptes in this pm=
d
>> are mapping to the same THP. This is necessary because some subpage of
>> the THP may be replaced, for example by uprobe. In such cases, it is not
>> possible to collapse the pmd.
>>=20
>> Signed-off-by: Song Liu <songliubraving@fb.com>
>> ---
>> include/linux/khugepaged.h |  15 ++++
>> mm/khugepaged.c            | 136 +++++++++++++++++++++++++++++++++++++
>> 2 files changed, 151 insertions(+)
>>=20
>> diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
>> index 082d1d2a5216..2d700830fe0e 100644
>> --- a/include/linux/khugepaged.h
>> +++ b/include/linux/khugepaged.h
>> @@ -15,6 +15,16 @@ extern int __khugepaged_enter(struct mm_struct *mm);
>> extern void __khugepaged_exit(struct mm_struct *mm);
>> extern int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
>> 				      unsigned long vm_flags);
>> +#ifdef CONFIG_SHMEM
>> +extern int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
>> +					 unsigned long addr);
>> +#else
>> +static inline int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
>> +						unsigned long addr)
>> +{
>> +	return 0;
>> +}
>> +#endif
>>=20
>> #define khugepaged_enabled()					       \
>> 	(transparent_hugepage_flags &				       \
>> @@ -73,6 +83,11 @@ static inline int khugepaged_enter_vma_merge(struct v=
m_area_struct *vma,
>> {
>> 	return 0;
>> }
>> +static inline int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
>> +						unsigned long addr)
>> +{
>> +	return 0;
>> +}
>> #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>>=20
>> #endif /* _LINUX_KHUGEPAGED_H */
>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>> index eaaa21b23215..247c25aeb096 100644
>> --- a/mm/khugepaged.c
>> +++ b/mm/khugepaged.c
>> @@ -76,6 +76,7 @@ static __read_mostly DEFINE_HASHTABLE(mm_slots_hash, M=
M_SLOTS_HASH_BITS);
>>=20
>> static struct kmem_cache *mm_slot_cache __read_mostly;
>>=20
>> +#define MAX_PTE_MAPPED_THP 8
>=20
> Is MAX_PTE_MAPPED_THP value random or do you have any justification for
> it?

In our use cases, we only have small number (< 10) of huge pages for the
text section, so 8 should be enough to cover the worse case.=20

If this is not sufficient, we can make it a list.=20

>=20
> Please add empty line after it.
>=20
>> /**
>>  * struct mm_slot - hash lookup from mm to mm_slot
>>  * @hash: hash collision list
>> @@ -86,6 +87,10 @@ struct mm_slot {
>> 	struct hlist_node hash;
>> 	struct list_head mm_node;
>> 	struct mm_struct *mm;
>> +
>> +	/* pte-mapped THP in this mm */
>> +	int nr_pte_mapped_thp;
>> +	unsigned long pte_mapped_thp[MAX_PTE_MAPPED_THP];
>> };
>>=20
>> /**
>> @@ -1281,11 +1286,141 @@ static void retract_page_tables(struct address_=
space *mapping, pgoff_t pgoff)
>> 			up_write(&vma->vm_mm->mmap_sem);
>> 			mm_dec_nr_ptes(vma->vm_mm);
>> 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
>> +		} else if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
>> +			/* need down_read for khugepaged_test_exit() */
>> +			khugepaged_add_pte_mapped_thp(vma->vm_mm, addr);
>> +			up_read(&vma->vm_mm->mmap_sem);
>> 		}
>> 	}
>> 	i_mmap_unlock_write(mapping);
>> }
>>=20
>> +/*
>> + * Notify khugepaged that given addr of the mm is pte-mapped THP. Then
>> + * khugepaged should try to collapse the page table.
>> + */
>> +int khugepaged_add_pte_mapped_thp(struct mm_struct *mm, unsigned long a=
ddr)
>=20
> What is contract about addr alignment? Do we expect it PAGE_SIZE aligned
> or PMD_SIZE aligned? Do we want to enforce it?

It is PMD_SIZE aligned. Let me add VM_BUG_ON() for it.=20

>=20
>> +{
>> +	struct mm_slot *mm_slot;
>> +	int ret =3D 0;
>> +
>> +	/* hold mmap_sem for khugepaged_test_exit() */
>> +	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
>> +
>> +	if (unlikely(khugepaged_test_exit(mm)))
>> +		return 0;
>> +
>> +	if (!test_bit(MMF_VM_HUGEPAGE, &mm->flags) &&
>> +	    !test_bit(MMF_DISABLE_THP, &mm->flags)) {
>> +		ret =3D __khugepaged_enter(mm);
>> +		if (ret)
>> +			return ret;
>> +	}
>=20
> Any reason not to call khugepaged_enter() here?

No specific reasons... Let me try it.=20

>=20
>> +
>> +	spin_lock(&khugepaged_mm_lock);
>> +	mm_slot =3D get_mm_slot(mm);
>> +	if (likely(mm_slot && mm_slot->nr_pte_mapped_thp < MAX_PTE_MAPPED_THP)=
)
>> +		mm_slot->pte_mapped_thp[mm_slot->nr_pte_mapped_thp++] =3D addr;
>=20
> It's probably good enough for start, but I'm not sure how useful it will
> be for real application, considering the limitation.

For limitation, do you mean MAX_PTE_MAPPED_THP? I think this is good for=20
our use cases. We sure can improve that without too much work.=20

Thanks,
Song=20

>=20
>> +
>=20
> Useless empty line?
>=20
>> +	spin_unlock(&khugepaged_mm_lock);
>> +	return 0;
>> +}
>> +
>> +/**
>> + * Try to collapse a pte-mapped THP for mm at address haddr.
>> + *
>> + * This function checks whether all the PTEs in the PMD are pointing to=
 the
>> + * right THP. If so, retract the page table so the THP can refault in w=
ith
>> + * as pmd-mapped.
>> + */
>> +static void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long=
 haddr)
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
>> +	if (!vma || !pmd || pmd_trans_huge(*pmd))
>> +		return;
>> +
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
>=20
> I think khugepaged_scan_shmem() and collapse_shmem() should changed to no=
t
> stop on PageTransCompound() to make this useful for more cases.

With locking sorted out, we could call collapse_pte_mapped_thp() for=20
PageTransCompound() cases.=20

>=20
> Ideally, it collapse_shmem() and this routine should be the same thing.
> Or do you thing it's not doable for some reason?

This routine is part of retract_page_tables(). collapse_shmem() does more=20
work. We can still go into collapse_shmem() and bypass the first half of
it.=20

On the other hand, I would like to keep it separate for now to minimize
conflicts with my other set, which is waiting for fixed version of=20
5fd4ca2d84b249f0858ce28cf637cf25b61a398f.

How about we start with current design (with small things fixed) and=20
improve it once both sets get in?

Thanks,
Song


