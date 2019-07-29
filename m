Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DA4CC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 22:51:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6D9420578
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 22:51:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="GNQfQqKv";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="jbb2ykcJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6D9420578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C6588E0005; Mon, 29 Jul 2019 18:51:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7507A8E0002; Mon, 29 Jul 2019 18:51:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57AA28E0005; Mon, 29 Jul 2019 18:51:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 293308E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 18:51:40 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id v3so46033458ywe.21
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 15:51:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=quijLdpcoHDr9DfZpt0Qv5ecH4uOwaAo9BsdJAB1tLA=;
        b=TSy/KB/0EDcSthxdQSmnF8BksEUzTugriZutclVIgThpkydl8Yxp3IIRnbR9gYCBej
         fNbjpFZfJanZLEqammng9bguv9n5yoqtF5X30ckg+hO+Evg59I5cHjiYs1EFpaKMz/uQ
         7dZz1IkMm3OxuOP6tBnZH5MibsElqr+4aYbThaMaDs95nVXChuu/pxH+ep5YmYCmYrg0
         E4DddlNn4XOkq4d5L0wtE4VBZgm15VXcdYJLzMkPDAbFzXqZrRoWh+PGQ+iY+vOai1tl
         NheLjLAL82sRMnk0PlHS8m45nfKPjYx/iFlk6RZjvtPIGNeUfKKVhoZ2+vK9D/xLuFaB
         MMgg==
X-Gm-Message-State: APjAAAWgFB6v4dOA0bXnhOKaCSzTJK5x+D3O4EXPrbpcE3ZRHRmbDL0K
	puVNW/ozgiGTqH31uiWm/52o9xYdkqF/vYCZc4d5hko0GufA+ccg6aorK96i3qk2tevBPXXQ5bY
	t3h9b1nhhywmlBT3LWtE6Jl9H6emr3NNBthfKw6BsgmZyxbzPcrsYOarGes/T3+ozww==
X-Received: by 2002:a25:e681:: with SMTP id d123mr37299346ybh.382.1564440699746;
        Mon, 29 Jul 2019 15:51:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysiIdHOsrdmbvTzjVpfPy7GV7n07w9oInOn2yKBlErZM/NLHAARsrir8RCzXNpFckF97cu
X-Received: by 2002:a25:e681:: with SMTP id d123mr37299322ybh.382.1564440698710;
        Mon, 29 Jul 2019 15:51:38 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564440698; cv=pass;
        d=google.com; s=arc-20160816;
        b=ktcwluHeP421Rh1LYIb6gs9an4hmRc63m2Hvy/yAmyqX81zdVH9g1Pw8VG6HBARgS8
         JZnoXLlDTMMTkyMIxxOe7rmO7zRUsZU36fXmc9lrxGbTD6bWA66lVI2PLU6HgFjOdIlW
         OjT5n6xVSJ0BF3VjCJG9Bhup8ZRP4FbA1Fh5RgoO/uKbesyNi83quH0o3HcnCQ6ftLIB
         K/bWw9Wz2ieVqrUgqb4XjMs3ePPu7VbEef9u+6lcPaXRoVps4x4P7Q8J2LFHzRGtq9mC
         L5GTUcHtOLIorbLotyRn19lXWiwv9j06IUa2txCsrFlUf/aYLBNzhNymi5ERs+zA3axC
         w8Fg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=quijLdpcoHDr9DfZpt0Qv5ecH4uOwaAo9BsdJAB1tLA=;
        b=vh1BceEI9IAyxgpEWlWwmZLsmwxLkv7Xe3hL506PtWNZthlh377b0fEc1nTTpRJaAI
         MQ8wzRLXrKKwDcWytpguoo736j9obINalifOdlZ+Dz0uCDyszOca/Tahut4tG7/62YHX
         ntr3op76tKWqVX2YIaFo7k1Sb0mQSQI7bBGjED5j00UX1tdnRiNabWxDgqNTMPh+dovk
         cuN737FYDz8PXB9dSshfuDhyOvQfyChP76YrZy0AyVVsjU21UuCbWR/1VLTfhKUF1/58
         a6Qp0CMil6rQrZDIjEtLZM0LfNWQ9p4uCwzDkSX73sfEhQwmYv/tkLLtISsFYW4Au2x6
         sFHA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=GNQfQqKv;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=jbb2ykcJ;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3113871558=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3113871558=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d192si20599560ywd.112.2019.07.29.15.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 15:51:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3113871558=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=GNQfQqKv;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=jbb2ykcJ;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3113871558=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3113871558=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6TMnZvw022986;
	Mon, 29 Jul 2019 15:51:16 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=quijLdpcoHDr9DfZpt0Qv5ecH4uOwaAo9BsdJAB1tLA=;
 b=GNQfQqKvdVMKSzj+E++I98+fsdYPZTES6Nj/hsmS7YSYETDrWEXx/+HCURvKJ+fzoKRq
 dnSXvQoXtv9CXqE4IhR5oKCz9O7VKcAKLZ1vlJDtwIQ87r4FyJUGPcnKRzZSMBZshCEz
 IOTzH0LiOND//teNm0g/sUxMAUCXJ9OfbGY= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u27er8jbq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 29 Jul 2019 15:51:16 -0700
Received: from prn-hub04.TheFacebook.com (2620:10d:c081:35::128) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 29 Jul 2019 15:51:12 -0700
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.28) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 29 Jul 2019 15:51:12 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=QkUBc3GLZFC+fgTDmzcaLZjsfPjTLjKDviAtH6t40uGa26d/KX4CEVpowcONgz9gOrvWpwA3FdU6MKQxwC+vgx2VN9VYIPRYpMjfhq/yCg0OHUNazh83yG21UOeAnOLJDWiU/yLnlhjC/BC01SZcH8Az9tNN8zQDC4QvMMUr2E1gZ7u8/wGs3ihOfmEQuITejikpd7/bQXMkU2/kXIW3cRk1BXmmKW4fB9S/FkwfWX6LTb/zEa678T/cnirB2bGOiCMcclg6fIGF0o/vlAkhnFs+lzC0+BEB35kY+ehhuMlPfEiAP4z581BJWciBtpWe6L1ac4olzSJgBRXD/YJWmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=quijLdpcoHDr9DfZpt0Qv5ecH4uOwaAo9BsdJAB1tLA=;
 b=KxX31nk6lDZsp+rbyp94rf+EV3R2VKJavbXoC80AvpT7j/EYq/TG5ka+p2QNsodBBonVeXEIYktR85zNBGPrvKir3P3fG0u7xKTAOQsO2O8Ui6JLMEUQ3ElRsJME/TkztWmN8rJQne+bFUZSQO7pItyZLufIPPjjLFJWEi4s7jPVAruYaarsC61tLWodrdcBtVlA4U5Xga6RT+xSeH8MRSYARedpEdJOkprYxqYGoqgAFszmJ/RgEQ8GBQt5wPuYh7XipqLtiuRH47VmAx9XVHiluJhCOyFsrzjyuF3QMu31zFnFVXD/6FQd/YaJlUcgHFhy6iTQgQEAfogtOPq0Dw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=quijLdpcoHDr9DfZpt0Qv5ecH4uOwaAo9BsdJAB1tLA=;
 b=jbb2ykcJsvGu2qh3KmHpN85eqQOafiVxtSnKxJQqUg3zVu9rtr2nkZS2/0Msed7WCsWyeerhsIajfE2VQAIQNUKB5NfvqyhHA1oPrIZkJ49QsJM+3I89fSuf10fs4JqN33oreUQqrBrGKgDebpxNRQcZTZzUl7XIpj3DnMC3uPA=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1119.namprd15.prod.outlook.com (10.175.8.20) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.15; Mon, 29 Jul 2019 22:51:11 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b%2]) with mapi id 15.20.2115.005; Mon, 29 Jul 2019
 22:51:11 +0000
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
        "Alexander Duyck" <alexander.h.duyck@linux.intel.com>,
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
        "Pavel Tatashin" <pasha.tatashin@oracle.com>,
        Kirill Tkhai
	<ktkhai@virtuozzo.com>, Sage Weil <sage@redhat.com>,
        Ira Weiny
	<ira.weiny@intel.com>,
        Dan Williams <dan.j.williams@intel.com>,
        "Darrick J.
 Wong" <darrick.wong@oracle.com>,
        "Gao Xiang" <hsiangkao@aol.com>,
        Bartlomiej
 Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Ross Zwisler <zwisler@google.com>
Subject: Re: [PATCH v2 2/2] mm,thp: Add experimental config option
 RO_EXEC_FILEMAP_HUGE_FAULT_THP
Thread-Topic: [PATCH v2 2/2] mm,thp: Add experimental config option
 RO_EXEC_FILEMAP_HUGE_FAULT_THP
Thread-Index: AQHVRlIkIBeF3SPMIUmfTIWhM30vRKbiM5WA
Date: Mon, 29 Jul 2019 22:51:10 +0000
Message-ID: <E6E92F42-3FA0-473C-B6F2-E23826C766F5@fb.com>
References: <20190729210933.18674-1-william.kucharski@oracle.com>
 <20190729210933.18674-3-william.kucharski@oracle.com>
In-Reply-To: <20190729210933.18674-3-william.kucharski@oracle.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::2:d148]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5fc72d6f-6650-44b6-78cf-08d7147740ac
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1119;
x-ms-traffictypediagnostic: MWHPR15MB1119:
x-microsoft-antispam-prvs: <MWHPR15MB111921725B40C23C691B26AAB3DD0@MWHPR15MB1119.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 01136D2D90
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(346002)(376002)(136003)(39860400002)(396003)(189003)(199004)(76116006)(91956017)(46003)(36756003)(99286004)(30864003)(68736007)(53936002)(53546011)(7416002)(6436002)(7406005)(14444005)(7366002)(76176011)(486006)(6486002)(64756008)(66446008)(66476007)(66556008)(54906003)(66946007)(256004)(229853002)(33656002)(6916009)(446003)(2616005)(2906002)(11346002)(6512007)(316002)(186003)(476003)(102836004)(8936002)(6116002)(71190400001)(6246003)(4326008)(71200400001)(81166006)(8676002)(81156014)(6506007)(53946003)(57306001)(50226002)(25786009)(305945005)(14454004)(86362001)(478600001)(7736002)(5660300002)(21314003)(142933001)(14583001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1119;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: DwoW3Wz1/pUssgOcbF7oxIgmrkHy7IHEl2LgSMcp7PuQmG88s/e1C8aOEUqxUEDOEZl5m+qRgWqNb7meXsgbWET6UvwtI4MvkpDX16UiownLShOtGmM4kHkw12DH84mxqT8Ic6JjNiFzdNP4vNSLfHSpNJuopEIAioMdZnzQCf9oUa0U0rilDVqOMZlPs0Y8BAP1PMw3U+pGSS4Nh5QMQ5V2KG21MTymQaXFY/KEtBeWlh1YHHoUmq6tqqQkPI4oe8XzvyjIFanZUjTcpMIZJV0bAmDWtOk34Ta10StaufDNW12j3nmM2Npjs0TkVjZouXqlJ62lNmwpqxVOmzzsplp9DOk3x8Cqh2U93ik5HlyGQ5pOBSmFuv903b3i55lxquzDJbc/PFoJdbeDkVVn9oK1/27Mz+oe7hq49Wi5HUY=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <F0AF68F3A1C68640AE27AA6631F2FBD4@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 5fc72d6f-6650-44b6-78cf-08d7147740ac
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 Jul 2019 22:51:10.8668
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1119
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-29_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907290249
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 29, 2019, at 2:09 PM, William Kucharski <william.kucharski@oracle.=
com> wrote:
>=20
> Add filemap_huge_fault() to attempt to satisfy page faults on
> memory-mapped read-only text pages using THP when possible.

I think this 2/2 doesn't need pagecache_get_page() changes in 1/2.=20
Maybe we can split pagecache_get_page() related changes out?

>=20
> Signed-off-by: William Kucharski <william.kucharski@oracle.com>
> ---
> include/linux/huge_mm.h |  16 ++-
> include/linux/mm.h      |   6 +
> mm/Kconfig              |  15 ++
> mm/filemap.c            | 299 +++++++++++++++++++++++++++++++++++++++-
> mm/huge_memory.c        |   3 +
> mm/mmap.c               |  36 ++++-
> mm/rmap.c               |   8 ++
> 7 files changed, 373 insertions(+), 10 deletions(-)
>=20
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 45ede62aa85b..34723f7e75d0 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -79,13 +79,15 @@ extern struct kobj_attribute shmem_enabled_attr;
> #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
>=20
> #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -#define HPAGE_PMD_SHIFT PMD_SHIFT
> -#define HPAGE_PMD_SIZE	((1UL) << HPAGE_PMD_SHIFT)
> -#define HPAGE_PMD_MASK	(~(HPAGE_PMD_SIZE - 1))
> -
> -#define HPAGE_PUD_SHIFT PUD_SHIFT
> -#define HPAGE_PUD_SIZE	((1UL) << HPAGE_PUD_SHIFT)
> -#define HPAGE_PUD_MASK	(~(HPAGE_PUD_SIZE - 1))

> +#define HPAGE_PMD_SHIFT		PMD_SHIFT
> +#define HPAGE_PMD_SIZE		((1UL) << HPAGE_PMD_SHIFT)
> +#define	HPAGE_PMD_OFFSET	(HPAGE_PMD_SIZE - 1)
          ^ space vs. tab difference here.=20

> +#define HPAGE_PMD_MASK		(~(HPAGE_PMD_OFFSET))
> +
> +#define HPAGE_PUD_SHIFT		PUD_SHIFT
> +#define HPAGE_PUD_SIZE		((1UL) << HPAGE_PUD_SHIFT)
> +#define	HPAGE_PUD_OFFSET	(HPAGE_PUD_SIZE - 1)
> +#define HPAGE_PUD_MASK		(~(HPAGE_PUD_OFFSET))

Should HPAGE_PMD_OFFSET and HPAGE_PUD_OFFSET include bits for=20
PAGE_OFFSET? I guess we can just keep huge_mm.h as-is and use
~HPAGE_PMD_MASK.=20

>=20
> extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0334ca97c584..ba24b515468a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2433,6 +2433,12 @@ extern void truncate_inode_pages_final(struct addr=
ess_space *);
>=20
> /* generic vm_area_ops exported for stackable file systems */
> extern vm_fault_t filemap_fault(struct vm_fault *vmf);
> +
> +#ifdef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
> +extern vm_fault_t filemap_huge_fault(struct vm_fault *vmf,
> +			enum page_entry_size pe_size);
> +#endif
> +
> extern void filemap_map_pages(struct vm_fault *vmf,
> 		pgoff_t start_pgoff, pgoff_t end_pgoff);
> extern vm_fault_t filemap_page_mkwrite(struct vm_fault *vmf);
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 56cec636a1fc..2debaded0e4d 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -736,4 +736,19 @@ config ARCH_HAS_PTE_SPECIAL
> config ARCH_HAS_HUGEPD
> 	bool
>=20
> +config RO_EXEC_FILEMAP_HUGE_FAULT_THP
> +	bool "read-only exec filemap_huge_fault THP support (EXPERIMENTAL)"
> +	depends on TRANSPARENT_HUGE_PAGECACHE && SHMEM
> +
> +	help
> +	    Introduce filemap_huge_fault() to automatically map executable
> +	    read-only pages of mapped files of suitable size and alignment
> +	    using THP if possible.
> +
> +	    This is marked experimental because it is a new feature and is
> +	    dependent upon filesystmes implementing readpages() in a way
> +	    that will recognize large THP pages and read file content to
> +	    them without polluting the pagecache with PAGESIZE pages due
> +	    to readahead.
> +
> endmenu
> diff --git a/mm/filemap.c b/mm/filemap.c
> index a96092243fc4..4e7287db0d8e 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -199,6 +199,8 @@ static void unaccount_page_cache_page(struct address_=
space *mapping,
> 	nr =3D hpage_nr_pages(page);
>=20
> 	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
> +
> +#ifndef	CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
> 	if (PageSwapBacked(page)) {
> 		__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
> 		if (PageTransHuge(page))
> @@ -206,6 +208,13 @@ static void unaccount_page_cache_page(struct address=
_space *mapping,
> 	} else {
> 		VM_BUG_ON_PAGE(PageTransHuge(page), page);
> 	}
> +#else
> +	if (PageSwapBacked(page))
> +		__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
> +
> +	if (PageTransHuge(page))
> +		__dec_node_page_state(page, NR_SHMEM_THPS);
> +#endif
>=20
> 	/*
> 	 * At this point page must be either written or cleaned by
> @@ -1615,7 +1624,7 @@ EXPORT_SYMBOL(find_lock_entry);
>  * - FGP_FOR_MMAP: Similar to FGP_CREAT, only we want to allow the caller=
 to do
>  *   its own locking dance if the page is already in cache, or unlock the=
 page
>  *   before returning if we had to add the page to pagecache.
> - * - FGP_PMD: If FGP_CREAT is specified, attempt to allocate a PMD-sized=
 page.
> + * - FGP_PMD: If FGP_CREAT is specified, attempt to allocate a PMD-sized=
 page

I think we haven't used FGP_PMD yet?=20

>  *
>  * If FGP_LOCK or FGP_CREAT are specified then the function may sleep eve=
n
>  * if the GFP flags specified for FGP_CREAT are atomic.
> @@ -2642,6 +2651,291 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
> }
> EXPORT_SYMBOL(filemap_fault);
>=20
> +#ifdef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
> +/*
> + * Check for an entry in the page cache which would conflict with the ad=
dress
> + * range we wish to map using a THP or is otherwise unusable to map a la=
rge
> + * cached page.
> + *
> + * The routine will return true if a usable page is found in the page ca=
che
> + * (and *pagep will be set to the address of the cached page), or if no
> + * cached page is found (and *pagep will be set to NULL).
> + */
> +static bool
> +filemap_huge_check_pagecache_usable(struct xa_state *xasp,
> +	struct page **pagep, pgoff_t hindex, pgoff_t hindex_max)

We have been using name "xas" for "struct xa_state *". Let's keep using it?

> +{
> +	struct page *page;
> +
> +	while (1) {
> +		page =3D xas_find(xasp, hindex_max);
> +
> +		if (xas_retry(xasp, page)) {
> +			xas_set(xasp, hindex);
> +			continue;
> +		}
> +
> +		/*
> +		 * A found entry is unusable if:
> +		 *	+ the entry is an Xarray value, not a pointer
> +		 *	+ the entry is an internal Xarray node
> +		 *	+ the entry is not a Transparent Huge Page
> +		 *	+ the entry is not a compound page
> +		 *	+ the entry is not the head of a compound page
> +		 *	+ the enbry is a page page with an order other than
> +		 *	  HPAGE_PMD_ORDER
> +		 *	+ the page's index is not what we expect it to be
> +		 *	+ the page is not up-to-date
> +		 *	+ the page is unlocked
> +		 */
> +		if ((page) && (xa_is_value(page) || xa_is_internal(page) ||
> +			(!PageCompound(page)) || (PageHuge(page)) ||
> +			(!PageTransCompound(page)) ||
> +			page !=3D compound_head(page) ||
> +			compound_order(page) !=3D HPAGE_PMD_ORDER ||
> +			page->index !=3D hindex || (!PageUptodate(page)) ||
> +			(!PageLocked(page))))
> +			return false;
> +
> +		break;
> +	}
> +
> +	xas_set(xasp, hindex);
> +	*pagep =3D page;
> +	return true;
> +}
> +
> +/**
> + * filemap_huge_fault - read in file data for page fault handling to THP
> + * @vmf:	struct vm_fault containing details of the fault
> + * @pe_size:	large page size to map, currently this must be PE_SIZE_PMD
> + *
> + * filemap_huge_fault() is invoked via the vma operations vector for a
> + * mapped memory region to read in file data to a transparent huge page =
during
> + * a page fault.
> + *
> + * If for any reason we can't allocate a THP, map it or add it to the pa=
ge
> + * cache, VM_FAULT_FALLBACK will be returned which will cause the fault
> + * handler to try mapping the page using a PAGESIZE page, usually via
> + * filemap_fault() if so speicifed in the vma operations vector.
> + *
> + * Returns either VM_FAULT_FALLBACK or the result of calling allcc_set_p=
te()
> + * to map the new THP.
> + *
> + * NOTE: This routine depends upon the file system's readpage routine as
> + *       specified in the address space operations vector to recognize w=
hen it
> + *	 is being passed a large page and to read the approprate amount of da=
ta
> + *	 in full and without polluting the page cache for the large page itse=
lf
> + *	 with PAGESIZE pages to perform a buffered read or to pollute what
> + *	 would be the page cache space for any succeeding pages with PAGESIZE
> + *	 pages due to readahead.
> + *
> + *	 It is VITAL that this routine not be enabled without such filesystem
> + *	 support. As there is no way to determine how many bytes were read by
> + *	 the readpage() operation, if only a PAGESIZE page is read, this rout=
ine
> + *	 will map the THP containing only the first PAGESIZE bytes of file da=
ta
> + *	 to satisfy the fault, which is never the result desired.
> + */
> +vm_fault_t filemap_huge_fault(struct vm_fault *vmf,
> +		enum page_entry_size pe_size)
> +{
> +	struct file *filp =3D vmf->vma->vm_file;
> +	struct address_space *mapping =3D filp->f_mapping;
> +	struct vm_area_struct *vma =3D vmf->vma;
> +
> +	unsigned long haddr =3D vmf->address & HPAGE_PMD_MASK;
> +	pgoff_t hindex =3D round_down(vmf->pgoff, HPAGE_PMD_NR);
> +	pgoff_t hindex_max =3D hindex + HPAGE_PMD_NR;
> +
> +	struct page *cached_page, *hugepage;
> +	struct page *new_page =3D NULL;
> +
> +	vm_fault_t ret =3D VM_FAULT_FALLBACK;
> +	int error;
> +
> +	XA_STATE_ORDER(xas, &mapping->i_pages, hindex, HPAGE_PMD_ORDER);
> +
> +	/*
> +	 * Return VM_FAULT_FALLBACK if:
> +	 *
> +	 *	+ pe_size !=3D PE_SIZE_PMD
> +	 *	+ FAULT_FLAG_WRITE is set in vmf->flags
> +	 *	+ vma isn't aligned to allow a PMD mapping
> +	 *	+ PMD would extend beyond the end of the vma
> +	 */
> +	if (pe_size !=3D PE_SIZE_PMD || (vmf->flags & FAULT_FLAG_WRITE) ||
> +		(haddr < vma->vm_start ||
> +		(haddr + HPAGE_PMD_SIZE > vma->vm_end)))
> +		return ret;
> +
> +	xas_lock_irq(&xas);
> +
> +retry_xas_locked:
> +	if (!filemap_huge_check_pagecache_usable(&xas, &cached_page, hindex,
> +		hindex_max)) {
> +		/* found a conflicting entry in the page cache, so fallback */
> +		goto unlock;
> +	} else if (cached_page) {
> +		/* found a valid cached page, so map it */
> +		hugepage =3D cached_page;
> +		goto map_huge;
> +	}
> +
> +	xas_unlock_irq(&xas);
> +
> +	/* allocate huge THP page in VMA */
> +	new_page =3D __page_cache_alloc(vmf->gfp_mask | __GFP_COMP |
> +		__GFP_NOWARN | __GFP_NORETRY, HPAGE_PMD_ORDER);
> +
> +	if (unlikely(!new_page))
> +		return ret;
> +
> +	if (unlikely(!(PageCompound(new_page)))) {

   What condition triggers this case?=20

> +		put_page(new_page);
> +		return ret;
> +	}
> +
> +	prep_transhuge_page(new_page);
> +	new_page->index =3D hindex;
> +	new_page->mapping =3D mapping;
> +
> +	__SetPageLocked(new_page);
> +
> +	/*
> +	 * The readpage() operation below is expected to fill the large
> +	 * page with data without polluting the page cache with
> +	 * PAGESIZE entries due to a buffered read and/or readahead().
> +	 *
> +	 * A filesystem's vm_operations_struct huge_fault field should
> +	 * never point to this routine without such a capability, and
> +	 * without it a call to this routine would eventually just
> +	 * fall through to the normal fault op anyway.
> +	 */
> +	error =3D mapping->a_ops->readpage(vmf->vma->vm_file, new_page);
> +
> +	if (unlikely(error)) {
> +		put_page(new_page);
> +		return ret;
> +	}
> +
> +	/* XXX - use wait_on_page_locked_killable() instead? */
> +	wait_on_page_locked(new_page);
> +
> +	if (!PageUptodate(new_page)) {
> +		/* EIO */
> +		new_page->mapping =3D NULL;
> +		put_page(new_page);
> +		return ret;
> +	}
> +
> +	do {
> +		xas_lock_irq(&xas);
> +		xas_set(&xas, hindex);
> +		xas_create_range(&xas);
> +
> +		if (!(xas_error(&xas)))
> +			break;
> +
> +		if (!xas_nomem(&xas, GFP_KERNEL)) {
> +			if (new_page) {
> +				new_page->mapping =3D NULL;
> +				put_page(new_page);
> +			}
> +
> +			goto unlock;
> +		}
> +
> +		xas_unlock_irq(&xas);
> +	} while (1);
> +
> +	/*
> +	 * Double check that an entry did not sneak into the page cache while
> +	 * creating Xarray entries for the new page.
> +	 */
> +	if (!filemap_huge_check_pagecache_usable(&xas, &cached_page, hindex,
> +		hindex_max)) {
> +		/*
> +		 * An unusable entry was found, so delete the newly allocated
> +		 * page and fallback.
> +		 */
> +		new_page->mapping =3D NULL;
> +		put_page(new_page);
> +		goto unlock;
> +	} else if (cached_page) {
> +		/*
> +		 * A valid large page was found in the page cache, so free the
> +		 * newly allocated page and map the cached page instead.
> +		 */
> +		new_page->mapping =3D NULL;
> +		put_page(new_page);
> +		new_page =3D NULL;
> +		hugepage =3D cached_page;
> +		goto map_huge;
> +	}
> +
> +	__SetPageLocked(new_page);
> +
> +	/* did it get truncated? */
> +	if (unlikely(new_page->mapping !=3D mapping)) {
> +		unlock_page(new_page);
> +		put_page(new_page);
> +		goto retry_xas_locked;
> +	}
> +
> +	hugepage =3D new_page;
> +
> +map_huge:
> +	/* map hugepage at the PMD level */
> +	ret =3D alloc_set_pte(vmf, NULL, hugepage);
> +
> +	VM_BUG_ON_PAGE((!(pmd_trans_huge(*vmf->pmd))), hugepage);
> +
> +	if (likely(!(ret & VM_FAULT_ERROR))) {
> +		/*
> +		 * The alloc_set_pte() succeeded without error, so
> +		 * add the page to the page cache if it is new, and
> +		 * increment page statistics accordingly.
> +		 */
> +		if (new_page) {
> +			unsigned long nr;
> +
> +			xas_set(&xas, hindex);
> +
> +			for (nr =3D 0; nr < HPAGE_PMD_NR; nr++) {
> +#ifndef	COMPOUND_PAGES_HEAD_ONLY

Where do we define COMPOUND_PAGES_HEAD_ONLY?=20

> +				xas_store(&xas, new_page + nr);
> +#else
> +				xas_store(&xas, new_page);
> +#endif
> +				xas_next(&xas);
> +			}
> +
> +			count_vm_event(THP_FILE_ALLOC);
> +			__inc_node_page_state(new_page, NR_SHMEM_THPS);
> +			__mod_node_page_state(page_pgdat(new_page),
> +				NR_FILE_PAGES, HPAGE_PMD_NR);
> +			__mod_node_page_state(page_pgdat(new_page),
> +				NR_SHMEM, HPAGE_PMD_NR);
> +		}
> +
> +		vmf->address =3D haddr;
> +		vmf->page =3D hugepage;
> +
> +		page_ref_add(hugepage, HPAGE_PMD_NR);
> +		count_vm_event(THP_FILE_MAPPED);
> +	} else if (new_page) {
> +		/* there was an error mapping the new page, so release it */
> +		new_page->mapping =3D NULL;
> +		put_page(new_page);
> +	}
> +
> +unlock:
> +	xas_unlock_irq(&xas);
> +	return ret;
> +}
> +EXPORT_SYMBOL(filemap_huge_fault);
> +#endif
> +
> void filemap_map_pages(struct vm_fault *vmf,
> 		pgoff_t start_pgoff, pgoff_t end_pgoff)
> {
> @@ -2924,7 +3218,8 @@ struct page *read_cache_page(struct address_space *=
mapping,
> EXPORT_SYMBOL(read_cache_page);
>=20
> /**
> - * read_cache_page_gfp - read into page cache, using specified page allo=
cation flags.
> + * read_cache_page_gfp - read into page cache, using specified page allo=
cation
> + *			 flags.
>  * @mapping:	the page's address_space
>  * @index:	the page index
>  * @gfp:	the page allocator flags to use if allocating
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 1334ede667a8..26d74466d1f7 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -543,8 +543,11 @@ unsigned long thp_get_unmapped_area(struct file *fil=
p, unsigned long addr,
>=20
> 	if (addr)
> 		goto out;
> +
> +#ifndef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
> 	if (!IS_DAX(filp->f_mapping->host) || !IS_ENABLED(CONFIG_FS_DAX_PMD))
> 		goto out;
> +#endif
>=20
> 	addr =3D __thp_get_unmapped_area(filp, len, off, flags, PMD_SIZE);
> 	if (addr)
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 7e8c3e8ae75f..96ff80d2a8fb 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1391,6 +1391,10 @@ unsigned long do_mmap(struct file *file, unsigned =
long addr,
> 	struct mm_struct *mm =3D current->mm;
> 	int pkey =3D 0;
>=20
> +#ifdef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
> +	unsigned long vm_maywrite =3D VM_MAYWRITE;
> +#endif
> +
> 	*populate =3D 0;
>=20
> 	if (!len)
> @@ -1429,7 +1433,33 @@ unsigned long do_mmap(struct file *file, unsigned =
long addr,
> 	/* Obtain the address to map to. we verify (or select) it and ensure
> 	 * that it represents a valid section of the address space.
> 	 */
> -	addr =3D get_unmapped_area(file, addr, len, pgoff, flags);
> +
> +#ifdef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
> +	/*
> +	 * If THP is enabled, it's a read-only executable that is
> +	 * MAP_PRIVATE mapped, the length is larger than a PMD page
> +	 * and either it's not a MAP_FIXED mapping or the passed address is
> +	 * properly aligned for a PMD page, attempt to get an appropriate
> +	 * address at which to map a PMD-sized THP page, otherwise call the
> +	 * normal routine.
> +	 */
> +	if ((prot & PROT_READ) && (prot & PROT_EXEC) &&
> +		(!(prot & PROT_WRITE)) && (flags & MAP_PRIVATE) &&
> +		(!(flags & MAP_FIXED)) && len >=3D HPAGE_PMD_SIZE &&
> +		(!(addr & HPAGE_PMD_OFFSET))) {
> +		addr =3D thp_get_unmapped_area(file, addr, len, pgoff, flags);
> +
> +		if (addr && (!(addr & HPAGE_PMD_OFFSET)))
> +			vm_maywrite =3D 0;
> +		else
> +			addr =3D get_unmapped_area(file, addr, len, pgoff, flags);
> +	} else {
> +#endif
> +		addr =3D get_unmapped_area(file, addr, len, pgoff, flags);
> +#ifdef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
> +	}
> +#endif
> +
> 	if (offset_in_page(addr))
> 		return addr;
>=20
> @@ -1451,7 +1481,11 @@ unsigned long do_mmap(struct file *file, unsigned =
long addr,
> 	 * of the memory object, so we don't do any here.
> 	 */
> 	vm_flags |=3D calc_vm_prot_bits(prot, pkey) | calc_vm_flag_bits(flags) |
> +#ifdef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
> +			mm->def_flags | VM_MAYREAD | vm_maywrite | VM_MAYEXEC;
> +#else
> 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
> +#endif
>=20
> 	if (flags & MAP_LOCKED)
> 		if (!can_do_mlock())
> diff --git a/mm/rmap.c b/mm/rmap.c
> index e5dfe2ae6b0d..503612d3b52b 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1192,7 +1192,11 @@ void page_add_file_rmap(struct page *page, bool co=
mpound)
> 		}
> 		if (!atomic_inc_and_test(compound_mapcount_ptr(page)))
> 			goto out;
> +
> +#ifndef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
> 		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
> +#endif
> +
> 		__inc_node_page_state(page, NR_SHMEM_PMDMAPPED);
> 	} else {
> 		if (PageTransCompound(page) && page_mapping(page)) {
> @@ -1232,7 +1236,11 @@ static void page_remove_file_rmap(struct page *pag=
e, bool compound)
> 		}
> 		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
> 			goto out;
> +
> +#ifndef CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP
> 		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
> +#endif
> +
> 		__dec_node_page_state(page, NR_SHMEM_PMDMAPPED);
> 	} else {
> 		if (!atomic_add_negative(-1, &page->_mapcount))
> --=20
> 2.21.0
>=20

