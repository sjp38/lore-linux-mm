Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21691C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:46:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBF5620B1F
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:45:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="oP+Xs6vo";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="oZbpEOd1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBF5620B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 699236B026C; Tue, 28 May 2019 18:45:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64AA56B0279; Tue, 28 May 2019 18:45:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EB0C6B027C; Tue, 28 May 2019 18:45:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 13FF46B026C
	for <linux-mm@kvack.org>; Tue, 28 May 2019 18:45:59 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e6so287641pgl.1
        for <linux-mm@kvack.org>; Tue, 28 May 2019 15:45:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Dht/EQ/NW33hPf0N0sVtdqFlpzTQYlHxhyoym/GWSLw=;
        b=dfYuL9X1CKc8Xut6N6Xrc9efCgiL5dOYfIyDmW+X9Ats47NIdpCymh8EqTp1xa/BJ9
         Nyl4tJMoEzJVfS9jH4KygPyxLZcAZBGF1R2N/vrSKCgtsjRQWEmfskW8giN9wN0CjOb7
         2b/ih8BYx9wDyNPh/z/WMNaTmP2YllIsFYfhEypcZuh85wbDrKGX/OJjWN0mAOfS2s6Q
         vENruXBe/KZLtgXUx6H2M8WZD2rNuitCqoksLC6lTxdqcHsg0uDJ/8XtVYMSz9Ifk/yv
         ws26wyBHNYVnXDcniPSTzmHvBQj3oo+faQI1/9rd3PX6AJD6+Sbu7/eQ17XHJkNBo/gq
         JGYA==
X-Gm-Message-State: APjAAAUbNNaGCoxE/dRje4dTD6b3AW5mHlktUtupvyU0SOojR0+Jx4Ig
	ynFfoYDM09x6x+ivGpugr0e5OPkBJFPXB+Bg0b7pKgK7STxVNCS/iXWozjqAP0SaafLjyw8FcK6
	rpJ5fpUomaHoyd2I1m1L4pAirifm+p7h3NetDKNN7Q5K7xA2VhHi29kB+hjnyACpTKg==
X-Received: by 2002:a17:902:2865:: with SMTP id e92mr27147930plb.264.1559083558659;
        Tue, 28 May 2019 15:45:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxL5/iVnysBj2aWOvh8w8l+Az2vWIGg/cKPNhoIobtjnyPEhGfTMDJpJF654FkLX0HZtMQB
X-Received: by 2002:a17:902:2865:: with SMTP id e92mr27147906plb.264.1559083558112;
        Tue, 28 May 2019 15:45:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559083558; cv=none;
        d=google.com; s=arc-20160816;
        b=z1A50hrhjT2vCLWrTZO6GjwSVqEQGfdwy1sEqroiCzr+A2qIEPg5n589ai0AYEXY5C
         b1IvVfKSsyq4hTfbRJM5dvpiwNtC16gRdM0Axsk+xcOTNmiZbH95TzuQPUaQcXrG3+Za
         JcXF/SSmyj/aL7cP2HH7STJ3CxARs0wOMc4J54JVmHQQa2HllnU881imOcw9+9IKENz1
         6kloXvwyY0TiIYvlsWd/bYttztpQOUHEouAwbvSHzLUjYaHjR52r0O/O09STtyNtP9f5
         AJukfKgV9Co5rKhsam2iAdiRz+zqHbd61Ylk08k0VZKm83uxUUlMVdfMP7IHEb/R44kE
         Fshg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Dht/EQ/NW33hPf0N0sVtdqFlpzTQYlHxhyoym/GWSLw=;
        b=b4Rqzeh8biGKpkZaizu3pu3f3kynlvmtzbDDCV9NggtXwAzqEvnGlwfE3h94geWoGZ
         xnekjnjzazTa7M2jDkQ85zEfcOqQ4iCAUdIJ+G9x8VKCXRWoWuhFwt6ZvR4rtMf67hZo
         L2wVR1d2RL9HjCzm6k/FIEQsyOJpLy6N5sEZpApcO+e+XOMvvYPjqAgD6zntfPDjZEFW
         pIdqStxNY6V7pGCPNGEBOMiHR3vpuLT9qTzfEn4+5dF6Zt4jZFF44QpfswtSwKdlflwJ
         iJvOKiRodxp+uP4ikQSfpRlGtWL169qYVsCrMojwDL2edO30YllwpYwcdXgRnLjG0Gkt
         1kCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=oP+Xs6vo;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=oZbpEOd1;
       spf=pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1051accb5e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m1si24287426pgt.93.2019.05.28.15.45.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 15:45:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=oP+Xs6vo;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=oZbpEOd1;
       spf=pass (google.com: domain of prvs=1051accb5e=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1051accb5e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4SMeDTl022356;
	Tue, 28 May 2019 15:45:09 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=Dht/EQ/NW33hPf0N0sVtdqFlpzTQYlHxhyoym/GWSLw=;
 b=oP+Xs6voWwAiusXETLr3L9cA3PNnbAsuNrSsb8mIX1fkHPd5wFB297dAEVDqphX7dcHQ
 eLDqpUdQw9kDPsgboF79nVfxQSgzvYwnKa2erQEOQyLnbEWYc5nzSSwCEPsQXOmmuP+0
 bn7N98OtcoRQAUBsqATMIOfF3A3xbG3QGnw= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ss90ch6pt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 28 May 2019 15:45:09 -0700
Received: from prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 28 May 2019 15:45:08 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 28 May 2019 15:45:08 -0700
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 28 May 2019 15:45:08 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Dht/EQ/NW33hPf0N0sVtdqFlpzTQYlHxhyoym/GWSLw=;
 b=oZbpEOd1sVRudzcS8ruxOCx+8m2AM+/XB5Umb3mwfYQ21qMGKGjTJO4ixstSq+KgMZBvPLqWYyYEygffjIvsYmhnV7tEJUbPMuTUFY/LFQYY6krD75dPWCVOaNPFsAqwMBAwx7xzXkOBM3Xgava9eVFIbJBAPK1inm2iEfyKfmc=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2216.namprd15.prod.outlook.com (52.135.196.155) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.22; Tue, 28 May 2019 22:45:05 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1922.021; Tue, 28 May 2019
 22:45:05 +0000
From: Roman Gushchin <guro@fb.com>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Hillf Danton <hdanton@sina.com>, Michal Hocko
	<mhocko@suse.com>,
        Matthew Wilcox <willy@infradead.org>,
        LKML
	<linux-kernel@vger.kernel.org>,
        Thomas Garnier <thgarnie@google.com>,
        Oleksiy
 Avramchenko <oleksiy.avramchenko@sonymobile.com>,
        Steven Rostedt
	<rostedt@goodmis.org>,
        Joel Fernandes <joelaf@google.com>,
        Thomas Gleixner
	<tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 3/4] mm/vmap: get rid of one single unlink_va() when
 merge
Thread-Topic: [PATCH v3 3/4] mm/vmap: get rid of one single unlink_va() when
 merge
Thread-Index: AQHVFHAI/JciIcIEUUWzIo9i9KPWz6aBJReA
Date: Tue, 28 May 2019 22:45:05 +0000
Message-ID: <20190528224501.GH27847@tower.DHCP.thefacebook.com>
References: <20190527093842.10701-1-urezki@gmail.com>
 <20190527093842.10701-4-urezki@gmail.com>
In-Reply-To: <20190527093842.10701-4-urezki@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR1401CA0023.namprd14.prod.outlook.com
 (2603:10b6:301:4b::33) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:3dca]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b998bf86-8829-42a4-328a-08d6e3be209f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB2216;
x-ms-traffictypediagnostic: BYAPR15MB2216:
x-microsoft-antispam-prvs: <BYAPR15MB2216D649F2D69DE087853C2EBE1E0@BYAPR15MB2216.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2582;
x-forefront-prvs: 00514A2FE6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(376002)(366004)(39860400002)(136003)(199004)(189003)(305945005)(6916009)(86362001)(81166006)(7736002)(6116002)(81156014)(7416002)(6506007)(386003)(33656002)(25786009)(71190400001)(102836004)(476003)(52116002)(5660300002)(4326008)(4744005)(256004)(6246003)(486006)(446003)(11346002)(46003)(76176011)(71200400001)(66476007)(64756008)(1411001)(66946007)(6512007)(66446008)(68736007)(6436002)(73956011)(229853002)(66556008)(478600001)(1076003)(8676002)(2906002)(8936002)(54906003)(186003)(316002)(99286004)(6486002)(14454004)(53936002)(9686003)(26583001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2216;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: CGJxwBqTXVRi3HzqT5WQvCUdUv/yPQVJJCQTfiI08BNexPiTg6dlK9SfEjWSH4KI2ShBWfWo8IwXM8m5ZXwKPvSRcXJivMTHQqNtHEVgv+YhFsWFbDsq7srhuitthw0WO18666mrr+WCo4jiI00lymu0HLO9zHsPdknMPXoAcjZbHgoocvx0n6hcGAOWJL3g4M/yQHT97lQDpR1CifXmq93ql8O6uWTb0UOSOr6/ITblfARU7PVh4dm24YMHMReD2yJCx2kNjospynp9HjGrvrZ7daNHFxLzEXUFRQfBIAtK+tmJ7t14h3tNblr+SKqLAgx8K1wfgKJmFnJSRl8lGTZtWPzvt7cYHzBVx+yQ5u1RrXK625m83hiDTaju26+YaJRBTRHjLAQrODIfNxQP9Ih9yRqNvTMHbGHtVP9z3K0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <5ACA9FE83084AC42BDE0EF09E00EB164@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: b998bf86-8829-42a4-328a-08d6e3be209f
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 May 2019 22:45:05.2747
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2216
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-28_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=753 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905280142
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 11:38:41AM +0200, Uladzislau Rezki (Sony) wrote:
> It does not make sense to try to "unlink" the node that is
> definitely not linked with a list nor tree. On the first
> merge step VA just points to the previously disconnected
> busy area.
>=20
> On the second step, check if the node has been merged and do
> "unlink" if so, because now it points to an object that must
> be linked.
>=20
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> Acked-by: Hillf Danton <hdanton@sina.com>

Reviewed-by: Roman Gushchin <guro@fb.com>

Thanks!

