Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 587E8C32750
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:14:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E82EB2067D
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 21:14:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="qwd4Krkn";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="EdZ0K8zW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E82EB2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B1678E0003; Tue, 30 Jul 2019 17:14:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 761848E0001; Tue, 30 Jul 2019 17:14:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B5238E0003; Tue, 30 Jul 2019 17:14:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 349648E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 17:14:34 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id q196so50232385ybg.8
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:14:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=wZ+7DlVW/DgJ0Ms3EBm0xDsWfXcC4XSD3bCIcnEjCMw=;
        b=CNd+cUBLN4OJO6r/N5U9hBBPjwhhTbKwI4+c/Higv9Habbl+nSWU6h++0m571bliL5
         djxdH66XE17IfHgv2iBwlrsxVlXr7POl/EdPSaIJKQlFZ7WNYG3VVLVyww+fesXbjaYR
         Y8B1qJE+QTJPEVZVLR/Zd3SVMDs0dwd1j67h2UDYQ45Furo5Djy/RpBIUd+N/kA/RdWp
         5LA56M2yEEHO+Lqpm/fPG8rvUu9cILNAVe82NK797kFc2cbYZXEI6dburqShwnGLyeA8
         nTIhsuRUXPdWj3+Gqs3uwf9UhIGsUw9ds5W4HXGufH3w273PWnOyBi7/PcgUbXuueObS
         8j0Q==
X-Gm-Message-State: APjAAAU6lpp0jtNdDe2bR5Otw9giNcGGoMv+0aeuPid13g4obdUsRFvR
	pwRaupqHihqSTxBWMgPQr0lxIA6YAbCCfk9oZ0fofLZmkVSu8lV8Eb+RBlzvDJWXcAZt9w7aPvc
	Cc3gU1r9Lo4NYIe5fAArMf7qedddPSRwEKlAh2/fWcDh8c123v9mNNHoOSnN74ua97g==
X-Received: by 2002:a81:990a:: with SMTP id q10mr68248523ywg.385.1564521273924;
        Tue, 30 Jul 2019 14:14:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDDemEETXJQc0NiyhdC2x5/FiVBvn7PBeQtjEEgIs5GwB9tSqx9tsFXOWQjTkBzPQakjKQ
X-Received: by 2002:a81:990a:: with SMTP id q10mr68248495ywg.385.1564521273297;
        Tue, 30 Jul 2019 14:14:33 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564521273; cv=pass;
        d=google.com; s=arc-20160816;
        b=J5JTYRxcq2LphGe3oN3gHk/L8kwE1Gen8bCv6wjtww1IqwUxdOzzL25IV3ACM6QO25
         N12WnzvUJxTfDE/ZPP0Uga2i3Uz0FL0ZOrcCft22ESNYsDiBkj3nGV8oSDPLn/cYKIvV
         1yubY+osONKpm/X9PZDmbfoBWa6zYYlKkt9Uwp71PSWqLt3Wzt5BIeFs0gP1cD1XEcpz
         G0nmAm5Qgj5q57s/4R85LclWUTOcHTLcaWHwQhRAKTq7APptJlsywqUJCkXZnHCcAGQi
         KWkXEoRTU10KfWUp9IaOmRY7yPcoS6qP89WZ/z82u0dmmksffwZcQfZrNqFtQvtMuaji
         oF8A==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=wZ+7DlVW/DgJ0Ms3EBm0xDsWfXcC4XSD3bCIcnEjCMw=;
        b=pcolzukGdVd4ZkcUWly1k+/6Xa1gQMaz7uBevvJomEdlaSADTcMiNAqXhjjwz01p+/
         dzEYBuyKeX3HGV2RTQ3eCyThAKyJGAAbpPWkLmQF7noPdw281s0WT4Izzjz8/bvqHTn0
         4Sqv1BYiceghzG3qeLYf3I/ViHXc/Dt8tOxqdcyRWw+uCZyDeF+gXw+aMHAxc47J6x79
         wCw0oK69HAJ0b1OjQ+/vMmZb00SMjTwKI24rJMcesM75EQWyBzfkuifDS0QhXLHTYBQU
         fc6MvXc+FszQTQubm5IT/Y3Xi6MmnTC1vGMNg7Y6BH+fIFcdK5qQM1DaoOt1zeB3W7qc
         OsNQ==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qwd4Krkn;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=EdZ0K8zW;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id a3si16594127ybr.207.2019.07.30.14.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 14:14:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qwd4Krkn;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=EdZ0K8zW;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6UL8hcG010240;
	Tue, 30 Jul 2019 14:14:14 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=wZ+7DlVW/DgJ0Ms3EBm0xDsWfXcC4XSD3bCIcnEjCMw=;
 b=qwd4Krkn67n5eRSdBKUtBlYzdIaSgB6sgyFa1ObcDd8zEk2kugl16YXkBAkmGpl0M0iz
 oFnp4m6dtLP1Gqf2BJFPV5aUCH/bYYzN98QxmH/GKrCdstMMOV1d0uieLvS9Yi+72INC
 DmIAy8Ue5fCTYE7/kqIcjVcD8FlplMmE5yY= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u2pwm1ne0-13
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 30 Jul 2019 14:14:14 -0700
Received: from prn-mbx01.TheFacebook.com (2620:10d:c081:6::15) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 30 Jul 2019 14:13:53 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-mbx01.TheFacebook.com (2620:10d:c081:6::15) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 30 Jul 2019 14:13:52 -0700
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 30 Jul 2019 14:13:52 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=klGPbVmMw/UJbAb+GLTpjzvVgWtRagrZHXNpIVByr5fAZ4PQQo24YRl594POv/TXdURIDdAsOQ32lX+S4KL2FqTb+hE4uQg0/Wu0u4boqA/JHg77xJ2j1YJRyXve3Mfz66ftxSWGxGUzDxJavLC5ZODOY98MIh18QjUVsrJeB/iVi6Dunl982NlRJVpjii6tRjbOvz3HPQNu05j4dJ6UErb+o06C6yQHxC+0JZNa85lnvLAvcWCxjoCV+V2Y4AIJpPnzGYQu3CHRYjJho1XA+9wlfRQIIwtV8RV+/mXHQpOgiwZI3TGj11WgE/7A0uf7dHfVp0BTZlpiFOmFi/lwqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=wZ+7DlVW/DgJ0Ms3EBm0xDsWfXcC4XSD3bCIcnEjCMw=;
 b=gffZMU0Kz/9sowgPWZhAlK99XI15m32+LsnY4SxUJIt0sia/8Kslyc93GNWOvoitMI3fZrGhY5iDgZVXNbz1ZF0+HC6+s0Zm1hqT1f4hmNJ3xMHAcntywcqOo1Llq7Pej3QfYkycrgzbSh2ZnvsPjOI0w9mZ2Ty1KUMAT8qtV8fMOAQyeFIK2gd0BocCEOJC/L+n4gMGcDrtQs0if9MpP1eCgKu+EyXI0yD4eUr6/PiphDHxIgC2obYdqQxBEXPmAppgmsHHBKtKlC/7fa2iRoqB5so+k90MSjMQSwNUfgBtCJFEzw790ajen4DonMiFDPXUIhiCotfBe8rKhcCviQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=wZ+7DlVW/DgJ0Ms3EBm0xDsWfXcC4XSD3bCIcnEjCMw=;
 b=EdZ0K8zWtMVzK00kTxhBAmY6NEg63gHSv+u6lonLhqEq1xdORg+PIh0VJ8k4GS5e0ZsJvy0yKoIzHbFURN5UT1z/SpuPo/r2d1vKysN+8PFAKpShMxvW2yFq/VmwrX8BUNa/+Xvxko8Tnf94oVIlZU1CqMsxN4JfnvTylzrwsF8=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1888.namprd15.prod.outlook.com (10.174.100.137) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.15; Tue, 30 Jul 2019 21:13:51 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b%2]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 21:13:51 +0000
From: Song Liu <songliubraving@fb.com>
To: Matthew Wilcox <willy@infradead.org>
CC: William Kucharski <william.kucharski@oracle.com>,
        "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>,
        "linux-afs@lists.infradead.org" <linux-afs@lists.infradead.org>,
        "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>,
        lkml
	<linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        Networking
	<netdev@vger.kernel.org>, Chris Mason <clm@fb.com>,
        "David S. Miller"
	<davem@davemloft.net>,
        David Sterba <dsterba@suse.com>, Josef Bacik
	<josef@toxicpanda.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Bob Kasten
	<robert.a.kasten@intel.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        "Chad
 Mynhier" <chad.mynhier@oracle.com>,
        "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>,
        Johannes Weiner <jweiner@fb.com>, "Dave
 Airlie" <airlied@redhat.com>,
        Vlastimil Babka <vbabka@suse.cz>, Keith Busch
	<keith.busch@intel.com>,
        Ralph Campbell <rcampbell@nvidia.com>,
        Steve Capper
	<steve.capper@arm.com>,
        Dave Chinner <dchinner@redhat.com>,
        "Sean
 Christopherson" <sean.j.christopherson@intel.com>,
        Hugh Dickins
	<hughd@google.com>, Ilya Dryomov <idryomov@gmail.com>,
        Alexander Duyck
	<alexander.h.duyck@linux.intel.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>,
        Amir Goldstein
	<amir73il@gmail.com>, Jason Gunthorpe <jgg@ziepe.ca>,
        Michal Hocko
	<mhocko@suse.com>, Jann Horn <jannh@google.com>,
        David Howells
	<dhowells@redhat.com>,
        John Hubbard <jhubbard@nvidia.com>,
        Souptick Joarder
	<jrdr.linux@gmail.com>,
        "john.hubbard@gmail.com" <john.hubbard@gmail.com>,
        Jan Kara <jack@suse.cz>, Andrey Konovalov <andreyknvl@google.com>,
        Arun KS
	<arunks@codeaurora.org>,
        Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>,
        "Jeff
 Layton" <jlayton@kernel.org>,
        Yangtao Li <tiny.windzz@gmail.com>,
        "Andrew
 Morton" <akpm@linux-foundation.org>,
        Robin Murphy <robin.murphy@arm.com>,
        Mike Rapoport <rppt@linux.ibm.com>,
        David Rientjes <rientjes@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Yafang Shao
	<laoar.shao@gmail.com>,
        Huang Shijie <sjhuang@iluvatar.ai>,
        Yang Shi
	<yang.shi@linux.alibaba.com>,
        Miklos Szeredi <mszeredi@redhat.com>,
        "Pavel
 Tatashin" <pasha.tatashin@oracle.com>,
        Kirill Tkhai <ktkhai@virtuozzo.com>, Sage Weil <sage@redhat.com>,
        Ira Weiny <ira.weiny@intel.com>,
        Dan Williams
	<dan.j.williams@intel.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        "Gao
 Xiang" <hsiangkao@aol.com>,
        Bartlomiej Zolnierkiewicz
	<b.zolnierkie@samsung.com>,
        Ross Zwisler <zwisler@google.com>,
        "kbuild test
 robot" <lkp@intel.com>
Subject: Re: [PATCH v2 1/2] mm: Allow the page cache to allocate large pages
Thread-Topic: [PATCH v2 1/2] mm: Allow the page cache to allocate large pages
Thread-Index: AQHVRlJNqktwHlJ0XkWeiU6bbajOXKbiJk4AgAF3MwCAAA04AA==
Date: Tue, 30 Jul 2019 21:13:51 +0000
Message-ID: <74E5DB03-E8C0-40A0-8C8A-DF53B53734F4@fb.com>
References: <20190729210933.18674-1-william.kucharski@oracle.com>
 <20190729210933.18674-2-william.kucharski@oracle.com>
 <443BA74D-9A8E-479B-9E63-4ACD6D6C0AF9@fb.com>
 <20190730202632.GC4700@bombadil.infradead.org>
In-Reply-To: <20190730202632.GC4700@bombadil.infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:5cb8]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0bdf4884-1cc6-4cc5-ed40-08d71532d261
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:MWHPR15MB1888;
x-ms-traffictypediagnostic: MWHPR15MB1888:
x-microsoft-antispam-prvs: <MWHPR15MB1888456186DC09999F3797ABB3DC0@MWHPR15MB1888.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(396003)(376002)(366004)(39860400002)(199004)(189003)(71190400001)(25786009)(54906003)(102836004)(76116006)(6116002)(14444005)(7416002)(7406005)(7366002)(229853002)(66446008)(68736007)(305945005)(256004)(66476007)(99286004)(316002)(66556008)(66946007)(64756008)(6486002)(86362001)(4744005)(14454004)(446003)(4326008)(46003)(6436002)(486006)(6512007)(36756003)(11346002)(6916009)(2906002)(478600001)(5660300002)(33656002)(6506007)(81156014)(53936002)(6246003)(7736002)(186003)(8936002)(8676002)(57306001)(53546011)(2616005)(81166006)(71200400001)(76176011)(476003)(50226002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1888;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: UH2XJQO7wNz8442LVmrH7iitcKAQGDBy4k/AnFreDSe21HiCzmKOgfFwDOqjwjXaWmmb6NSmvpRWb2y/bofbb89qI9ftt4FKLlfmkySS75kx/JBbNDQ04RJyC5KnfpiPFM4ZXImg1yohJSRYxFB1jQqdSGofVh1PHwv1Rko6rECQazCJsk2tP4jZlyUsSSk+dj9pOhtJ6WpPUF7PBrt1nCC7ckhetKdLLlGWXbOIr3m1N4UujUmBaeVSmL3+PolElnfOJX95cjG/M05Kx5I4b71DLBbMXknD1qgnDFmXS2lGbdCBVgxItB8i0okSKxDErA2bya22b0+0CffoyKZ7MwmjL0Y0cJzAEuzbN1b3bz3Uiam+iEdU+MNWmdBqr7fXVOJwQYCDT8TRKYz8KDrwNTy/5YihmIhh3yUiGm64F8g=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <C0508030DADA914F80479A0B5C474F71@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 0bdf4884-1cc6-4cc5-ed40-08d71532d261
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 21:13:51.2110
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1888
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-30_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=662 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300212
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 30, 2019, at 1:26 PM, Matthew Wilcox <willy@infradead.org> wrote:
>=20
> On Mon, Jul 29, 2019 at 10:03:40PM +0000, Song Liu wrote:
>>> +/* If you add more flags, increment FGP_ORDER_SHIFT */
>>> +#define	FGP_ORDER_SHIFT		7
>>> +#define	FGP_PMD			((PMD_SHIFT - PAGE_SHIFT) << FGP_ORDER_SHIFT)
>>> +#define	FGP_PUD			((PUD_SHIFT - PAGE_SHIFT) << FGP_ORDER_SHIFT)
>>> +#define	fgp_get_order(fgp)	((fgp) >> FGP_ORDER_SHIFT)
>>=20
>> This looks like we want support order up to 25 (32 - 7). I guess we don'=
t=20
>> need that many. How about we specify the highest order to support here?=
=20
>=20
> We can support all the way up to order 64 with just 6 bits, leaving 32 -
> 6 - 7 =3D 19 bits free.  We haven't been adding FGP flags very quickly,
> so I doubt we'll need anything larger.

lol. I misread the bit usage.=20

>=20
>> Also, fgp_flags is signed int, so we need to make sure fgp_flags is not
>> negative.=20
>=20
> If we ever get there, I expect people to convert the parameter from signe=
d
> int to unsigned long.

Agreed.=20

Thanks,
Song

