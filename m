Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9FA2C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:15:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DDE020693
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:15:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="EUuUKcia";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="LnZdNkhm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DDE020693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 089B28E0003; Tue, 30 Jul 2019 15:15:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 039AA8E0001; Tue, 30 Jul 2019 15:15:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF5958E0003; Tue, 30 Jul 2019 15:15:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD27F8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 15:15:19 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b195so48104003ywa.16
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:15:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=QK2E/gpSHrD0IH3cFtcW53NM5uCJd2+YWMDKDC3jclM=;
        b=r+4g7XqLzGdbcrNE18Bx2qh5jDDGxTJK+GtKm+LEzABCZ6yeSLs/FqQ9Q2wJmZj+zs
         iFZGsJuSLbGPpTzj3ql0ju1kxGFiet46iKDQW2raEqyBJ0yk8QjmGeIFVw8xqFpkM2lr
         iTScdomRw6dTW7zRPTAOskAvq2amFzPcS17qAGYSzQSd0d3iZXPti3O+mK/0bxg+lZZJ
         kaMS+9IJ6nlRyO6BKgiK3HkM6H/EFXhZiIR/Q2PV482/kxJ+Q+MFEIXDnntrLEeIF5wy
         cpdkIb/wotjKbPnAmqEZVvR99vTh5jZgc9+02SmPtgmvcOd/NMdOLMpvpmiY5d/zcKeh
         lEow==
X-Gm-Message-State: APjAAAV8QBib26SaI+mZQR+w1WkPR/dBZm5q3ppNPw45qCe1iJbg1uqN
	hKLlnr4HbYvp2gq1KBQGyEAx/eGYqorv78cU8lLdq+GUHQU8lM66ztEJVEJ3bFUR4AdgunI+KST
	FfDbLhd88BuuxUj2e2yja7cXQ/j3eSHKZcpxkDNnsPEO3HDgDx6Ce9+EZEFuGMcjN7w==
X-Received: by 2002:a25:2fcd:: with SMTP id v196mr31389703ybv.515.1564514119412;
        Tue, 30 Jul 2019 12:15:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyi5uz4wr0PEGfbOFmzne9uB+8jYtKnva/sPJvXpEwKwoZ3DRA3UFy/63q76PwsXPfNP4id
X-Received: by 2002:a25:2fcd:: with SMTP id v196mr31389646ybv.515.1564514118756;
        Tue, 30 Jul 2019 12:15:18 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564514118; cv=pass;
        d=google.com; s=arc-20160816;
        b=iifyCE+c0H9KfxHs57XLDpOHS4qbqKz1lY5QtkeDnoRobmwW8zl3SWDUq2/M15BhbE
         jDI6mO7pxhJdQilNP8agcmo9fYiQTepzbgeO82A3taC58v9lwzOrAC1cCSHjnfxhJzvr
         234SXTc64PjKSiFLgn18/f/hQwUvTEucXlL3T0uSOJwxcb/IePCZUCqk7ZQG4MCSyq6e
         +KiLdrsnvRkFhCcsG9mxMEvteKdoVKS5jtucu9SVw43+RAtkoa0K25YtnmH8xTeMR2Zj
         TLHQ7TEwtFmpwpQgAZCSlwZlMpCi+A5z6ROOzo2brPF/Heq9VT1S6km8gRFstPt/8ngk
         YPGA==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=QK2E/gpSHrD0IH3cFtcW53NM5uCJd2+YWMDKDC3jclM=;
        b=f681lvbEvcXJgq4AumQjJQp7GJpYn1dzC5H58M3NXz7WVnPK6yaLG1CquI7GTgx4NR
         eFiZGWS5LRYVC9xI2Ipeb3yHSeIEp7zgPtG3uzg8DSstYBjCXu5r3UKc1Gx4n2v6zsZ2
         t2KM4zBeXuXod2S2xRGDCul+0RpZHAKBM/NuVhbzM4CH/W5Ufq92R73Tbn3ZdpGHEaMk
         XgkibcevABK2PGX4Xu9QTU6F0IsCgy2CINVm8SAjtiRLVv60nrT9qDCl9BV3XSQWjEb1
         KgRjftzjJ+12krlSsp4Q86GBHyAimJVcXsYln7pcCTGCSE3LqxAckf0MVXIDQDTzoTj+
         MXsQ==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=EUuUKcia;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=LnZdNkhm;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id o73si24307581yba.384.2019.07.30.12.15.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 12:15:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=EUuUKcia;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=LnZdNkhm;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x6UJ73Cs010627;
	Tue, 30 Jul 2019 12:14:53 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=QK2E/gpSHrD0IH3cFtcW53NM5uCJd2+YWMDKDC3jclM=;
 b=EUuUKciakt4NLIyE+BGrfZa99AXISHbeOgsAFXvAHS2EEJnpSZEiaeEjRRvQUMU+qXdX
 j9miaZDxyhdxarZK6bm6iAzHzC10azgURPTbYB43sGjhYjkZjZKP0RG4wA5fovjnEbNw
 YHcfJwbhFI7SaumZe2QMFRXAif9zY4d4l70= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2u275g42ge-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 30 Jul 2019 12:14:52 -0700
Received: from prn-mbx04.TheFacebook.com (2620:10d:c081:6::18) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 30 Jul 2019 12:14:49 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-mbx04.TheFacebook.com (2620:10d:c081:6::18) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 30 Jul 2019 12:14:49 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 30 Jul 2019 12:14:49 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=ImyLJrQY0yxJS0tt7WAOGEuwH7Laj7HEpbE9gHBiA0HV5eMdWqN7pOBFi9cxguf7NmCzeal8UBy395x4LKdRaGEWHrIhhhbFh7eoZZx8KA8GKYWa7pW63AuLZNoxO3oSPrAvGxtGHyJgHgPFjCNAppctNqwecQvZ8pVCrzVkHCdH98LnbcQcG7NFWbK1yKzyp1gsHdPKwoFshlmwJ0v+FZtIc9wg22Nh7OwMNME3PZ/WqwURr5MpggmSYDSS+t91XjiQRswzmevpt9rHhaL8IzTTUEvUkgETX9KmYUguXj/LKHAvX2TY/Vuh7OL5kCs0x6s+1d2btQwhOzdz5tI0YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QK2E/gpSHrD0IH3cFtcW53NM5uCJd2+YWMDKDC3jclM=;
 b=IhFfKg7vHzG27TDnTW6YjUaWOanO+0SZUOomjwz2yM92rwGAh66gQ4POqPjY8HgjdCuc9tikC6ZzOy63TE+YVLMgCg8lotdRRsXtx6eXnxUfaTqr+E0vORIp/MiGZy7uMaUyRevfAEN5JBMw2YGiypB0o80HFpCckJBxhy+0EWUPxxBNpwn9E2vo4G0OfagsZEzYoOAj0uy/4E5AEfPPgMzfKK7bJaLAjnPoGhdr8jDdu72WOSq0KLwrdqv+Ofz/0e30l84SQAqRkFu01pnK0b8Y6bU5HWX4hc8gKQsq5ltYacHaA1koeW2bxyt57UZORItpTY0+Q8lB5gEaPOC8HA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QK2E/gpSHrD0IH3cFtcW53NM5uCJd2+YWMDKDC3jclM=;
 b=LnZdNkhmbZRvdFdM5zPkbxHvfelKufKq4xFQMRgBMyVwBLEzMMzlyOYjIteebI9ed1dsqrRDcM+01jE1vkLMsEjsemyOFBII5ZbkhX4C/VHNOmSHDVCmXSZASIL3G1tCEvKIRelwj/u7EMlptPpm+zU5GyBIIKC6c/sxhDeMrBI=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1520.namprd15.prod.outlook.com (10.173.234.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.14; Tue, 30 Jul 2019 19:14:47 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b%2]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 19:14:47 +0000
From: Song Liu <songliubraving@fb.com>
To: William Kucharski <william.kucharski@oracle.com>
CC: "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>,
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
        Johannes Weiner <jweiner@fb.com>,
        "Matthew
 Wilcox" <willy@infradead.org>,
        Dave Airlie <airlied@redhat.com>, "Vlastimil
 Babka" <vbabka@suse.cz>,
        Keith Busch <keith.busch@intel.com>,
        Ralph Campbell
	<rcampbell@nvidia.com>,
        Steve Capper <steve.capper@arm.com>,
        Dave Chinner
	<dchinner@redhat.com>,
        Sean Christopherson <sean.j.christopherson@intel.com>,
        Hugh Dickins <hughd@google.com>, Ilya Dryomov <idryomov@gmail.com>,
        Alexander
 Duyck <alexander.h.duyck@linux.intel.com>,
        Thomas Gleixner
	<tglx@linutronix.de>,
        =?iso-8859-1?Q?J=E9r=F4me_Glisse?=
	<jglisse@redhat.com>,
        Amir Goldstein <amir73il@gmail.com>, Jason Gunthorpe
	<jgg@ziepe.ca>,
        Michal Hocko <mhocko@suse.com>, Jann Horn <jannh@google.com>,
        David Howells <dhowells@redhat.com>,
        John Hubbard <jhubbard@nvidia.com>,
        Souptick Joarder <jrdr.linux@gmail.com>,
        "john.hubbard@gmail.com"
	<john.hubbard@gmail.com>,
        Jan Kara <jack@suse.cz>, Andrey Konovalov
	<andreyknvl@google.com>,
        Arun KS <arunks@codeaurora.org>,
        Aneesh Kumar K.V
	<aneesh.kumar@linux.ibm.com>,
        Jeff Layton <jlayton@kernel.org>, Yangtao Li
	<tiny.windzz@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "Robin
 Murphy" <robin.murphy@arm.com>,
        Mike Rapoport <rppt@linux.ibm.com>,
        "David
 Rientjes" <rientjes@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Yafang Shao <laoar.shao@gmail.com>, Huang Shijie <sjhuang@iluvatar.ai>,
        "Yang
 Shi" <yang.shi@linux.alibaba.com>,
        Miklos Szeredi <mszeredi@redhat.com>,
        Pavel Tatashin <pasha.tatashin@oracle.com>,
        Kirill Tkhai
	<ktkhai@virtuozzo.com>, Sage Weil <sage@redhat.com>,
        Ira Weiny
	<ira.weiny@intel.com>,
        Dan Williams <dan.j.williams@intel.com>,
        "Darrick J.
 Wong" <darrick.wong@oracle.com>,
        Gao Xiang <hsiangkao@aol.com>,
        "Bartlomiej
 Zolnierkiewicz" <b.zolnierkie@samsung.com>,
        Ross Zwisler <zwisler@google.com>
Subject: Re: [PATCH v2 2/2] mm,thp: Add experimental config option
 RO_EXEC_FILEMAP_HUGE_FAULT_THP
Thread-Topic: [PATCH v2 2/2] mm,thp: Add experimental config option
 RO_EXEC_FILEMAP_HUGE_FAULT_THP
Thread-Index: AQHVRlIkIBeF3SPMIUmfTIWhM30vRKbiM5WAgAEBOgCAAFSkgA==
Date: Tue, 30 Jul 2019 19:14:47 +0000
Message-ID: <1D97995B-E3A6-4397-AA99-2E7B90534559@fb.com>
References: <20190729210933.18674-1-william.kucharski@oracle.com>
 <20190729210933.18674-3-william.kucharski@oracle.com>
 <E6E92F42-3FA0-473C-B6F2-E23826C766F5@fb.com>
 <ffbdd056-e80c-41f4-37c4-c8b758fb59e7@oracle.com>
In-Reply-To: <ffbdd056-e80c-41f4-37c4-c8b758fb59e7@oracle.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:5cb8]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 03adb8e9-aca7-4801-9873-08d71522301b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1520;
x-ms-traffictypediagnostic: MWHPR15MB1520:
x-microsoft-antispam-prvs: <MWHPR15MB1520904FA58A127656D0343BB3DC0@MWHPR15MB1520.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(346002)(366004)(39860400002)(376002)(199004)(189003)(36756003)(6512007)(53936002)(71200400001)(71190400001)(8676002)(81156014)(7736002)(50226002)(81166006)(305945005)(68736007)(64756008)(5660300002)(8936002)(7416002)(76116006)(66446008)(66556008)(66476007)(7406005)(7366002)(66946007)(446003)(99286004)(46003)(6436002)(6486002)(57306001)(186003)(11346002)(2906002)(53546011)(6506007)(478600001)(316002)(14454004)(54906003)(6246003)(4326008)(256004)(6116002)(25786009)(76176011)(86362001)(33656002)(486006)(229853002)(102836004)(2616005)(6916009)(476003)(142933001)(14583001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1520;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: DcczXJnBs6wroH2ga6LynzGq4T5M0W0x6H0P0gzoPmPv+kJkTnEXqH1kpgkK3vjmUMLMa8V/l+aReLEnJ42DvBxWtzWR/p1zPLiQ/vO1xFKMUpfyOOLHOgbQSlg8DJSKRenvieiyZsQ+ou+qj0OVos++x2fLkxCc8t0Twb0rAfTRQ6StDuJbBqWEPKyeOKusy2rq5oC/ISfm9b/1rscoLM3DZ2AznUGfOcZ+huG01gymHtlOdvvioFMW4DEkOkVW0UA8N5McZMObjhqm7SK57D18/1RGUy4j1rIZqWdftRlcCWRgde6iEtsbLn4FRmOzWScBkPiGgMMUGxvYkXzrPEPJ6Zm+C/KKmZTaxBDndziS5zD/byfBqdmy7RjOuG02R6JOD+Q/01JRw9LCXzeKqipBfc5r+0Ar9o7BSkJK/Qw=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <3D2E2C12A13A2842AAE6A44FC1165839@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 03adb8e9-aca7-4801-9873-08d71522301b
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 19:14:47.2377
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1520
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-30_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300193
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 30, 2019, at 7:11 AM, William Kucharski <william.kucharski@oracle.=
com> wrote:
>=20
>=20
>=20
> On 7/29/19 4:51 PM, Song Liu wrote:
>=20
>>=20
>>> +#define	HPAGE_PMD_OFFSET	(HPAGE_PMD_SIZE - 1)
>>           ^ space vs. tab difference here.
>=20
> Thanks, good catch!
>=20
>>> +#define HPAGE_PMD_MASK		(~(HPAGE_PMD_OFFSET))
>>> +
>>> +#define HPAGE_PUD_SHIFT		PUD_SHIFT
>>> +#define HPAGE_PUD_SIZE		((1UL) << HPAGE_PUD_SHIFT)
>>> +#define	HPAGE_PUD_OFFSET	(HPAGE_PUD_SIZE - 1)
>=20
> Saw this one, too.
>=20
>> Should HPAGE_PMD_OFFSET and HPAGE_PUD_OFFSET include bits for
>> PAGE_OFFSET? I guess we can just keep huge_mm.h as-is and use
>> ~HPAGE_PMD_MASK.
>=20
> That's what I had intended; would you rather see those macros
> omit the unneeded for the larger page size bits?

I think using ~HPAGE_PMD_MASK is common practice. Let's keep it=20
that way.=20

>=20
>>> - * - FGP_PMD: If FGP_CREAT is specified, attempt to allocate a PMD-siz=
ed page.
>>> + * - FGP_PMD: If FGP_CREAT is specified, attempt to allocate a PMD-siz=
ed page
>=20
> No - this came in as part of patch 1/2 and I missed dropping the period a=
t the end of the line that caused this to be a diff, so I will put it
> back. :-)
>=20
>> We have been using name "xas" for "struct xa_state *". Let's keep using =
it?
>=20
> Thanks, done.
>=20
>>> +	if (unlikely(!(PageCompound(new_page)))) {
>>    What condition triggers this case
> I wanted a check to make sure that __page_cacke_alloc() returned a large =
page. I don't recall if the mechanism guarantees that when you ask for
> a large page, you get one, so I wanted to handle that case.
>=20
> If you prefer, I could make this a VM_BUG_ON_PAGE() instead, but I
> wanted it to fallback gracefully if it can't get a properly sized
> page.

I think __page_cache_alloc() guarantees compound page. If not, it
should return NULL.=20

>=20
>>> +#ifndef	COMPOUND_PAGES_HEAD_ONLY
>> Where do we define COMPOUND_PAGES_HEAD_ONLY?
>=20
> At present, we do not.
>=20
> I used this so I could include the code that would be needed once
> Matthew's "store only head pages in page cache" changes go back in,
> which looks like it may not be until 5.4-rc1. Matthew recommended I

We don't have to wait until 5.4-rc1. We could develop based on this=20
patch once it lands in mm tree.=20

Thanks,
Song

