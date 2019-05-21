Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 909DFC04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 00:37:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F24521479
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 00:37:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="HhWaXluL";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="a4DyncUz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F24521479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA5F16B0003; Mon, 20 May 2019 20:37:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B56FD6B0005; Mon, 20 May 2019 20:37:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1F1C6B0006; Mon, 20 May 2019 20:37:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1236B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 20:37:57 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id o12so10154336pll.17
        for <linux-mm@kvack.org>; Mon, 20 May 2019 17:37:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=ZJ85rOyElubMYipRdbsgjUk3NtByDcHSnWPVtvc7k/s=;
        b=mJG4MmlOkQBGBTUvJB63fh5eNPxHprdw5KcDdrWvmSPm01oyOMLuVSIuwOxqealmQk
         OaBBTnIOKxaHM8j5ODJRasC6XWrkepeLGyaua6iweHXzfdCn8J4g1RrowOXioCH2jxgM
         XdqfrARqhO8xK7DhSNq1OQ5gDNi+FgGTn26Hsm3elnf6saXvwERQ4nIb8vKrIj7U70dF
         xiCfmUkM6G8i03viYqXdeDT7moysShxoecihlHGS5FAhRTWDg3+RI8vYFYo6n3QXISel
         NFCORU15QICQmyXaP4N/PCQv94AVUGGzgRUUR4xWVmXx2ez99zlYF3hsAP3KX7waqLsU
         n8mw==
X-Gm-Message-State: APjAAAXL3cHN0PcgYS/PI6CpKZxF++AmTyPvWPXyctXZ4XDsEVugBTE8
	0q65RRipjko5ztk4hTroC1UlSriSJt+f/nPLLcDWrD/Eicnp6Mxkk7uSLREtJbdZmTXaIz4cheS
	A/3GsxUo7SUsrV4ZDBVTm8WqufYJA87Rjt1EZT3h42uQxzP1DL1pO3XH67nBaTQilMg==
X-Received: by 2002:a17:902:5ac8:: with SMTP id g8mr50976226plm.154.1558399077040;
        Mon, 20 May 2019 17:37:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5ZvLcThrHXk0ZLsoTOkOgMcg6A3oFnnDwH0gER7U/ug9FUf2XUf9xxX4rdN0oe2EAwORn
X-Received: by 2002:a17:902:5ac8:: with SMTP id g8mr50976171plm.154.1558399076384;
        Mon, 20 May 2019 17:37:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558399076; cv=none;
        d=google.com; s=arc-20160816;
        b=QXJCiH8A/vLKxL+zD0e9dNKQqI4js1qLa3SIGgDkbqjKm3J2Opd0GFL/NA1Bif/uzq
         LJBBBLf6amQ7r15JoQPGZ1JNqXGtxdwmOHjLUEd2pGS29+G0xdTFFMbHAOHJ+ypvOWlG
         rjlXeoZeJeN4fqYUuz5itAjBKr5Uwy79/Orp/84slu9I3f4HSP930TBy7BaLQtwyY8is
         UUNFtxcqgsV0z7NV8kgGh2VmQ4WVWgRHZMYCD2jpCWTKDaTnfzgdAk1s0JLZq3YJCMyr
         mLd6+UL8wRbm+uwkC1yvEhiw6DPyB1ZNDsC9lrs0eKF74pkjU1Rw94pXQwCr3N3lpYqw
         1HAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=ZJ85rOyElubMYipRdbsgjUk3NtByDcHSnWPVtvc7k/s=;
        b=flELXScJ++FOYz9H0oYwI32Mg7No8UUaL6ZAZyGJ7PpCPX+8G8cb70sgVlGTWgLZ0e
         IcIAzNGYJ3DSq7RXp9O5pZqjqS2AC9HOcG/53hBWAl0HT1JLhq3rpa5LLTk4Keehayiy
         079BmZBV7JF4FcXCh4yoHN67JQy6ZhSeW34eb/ZFyOzUywV39PzeOYwymkQG5xwGwJKq
         T0VQFhiDU4EVykKa5TtyKdN5lTpht/oPZizaYF3g+g8zUrdZiVEasxNA7W9OYhopgHRs
         vK6/lJg9vD/KrowJnPn7C0hHu6SxYlyvFtSYsSELxDcMDouA6XL7PFCP0AGS2b4T+pCI
         LPPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=HhWaXluL;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=a4DyncUz;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f8si17986092pgc.267.2019.05.20.17.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 17:37:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=HhWaXluL;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=a4DyncUz;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4L0Y8kL000574;
	Mon, 20 May 2019 17:37:22 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=ZJ85rOyElubMYipRdbsgjUk3NtByDcHSnWPVtvc7k/s=;
 b=HhWaXluLu5nFDvbQxTzRd6wzSCFoPxAa+8aFMdTwYpfKAzeS1RbbrpcWt1pd2WsgVNWa
 v3Q0bkSeu4x24xtleW6bihP/RDIk0nFkZUMZxGxWrXQ7dolVeSPYdVn/9l8zgR48nVCS
 LEaUJCT3r6YybKdLcExVHKncu3DcwCTWcts= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2sm23rh1y0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Mon, 20 May 2019 17:37:22 -0700
Received: from ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) by
 ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 20 May 2019 17:37:20 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.101) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Mon, 20 May 2019 17:37:20 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZJ85rOyElubMYipRdbsgjUk3NtByDcHSnWPVtvc7k/s=;
 b=a4DyncUzmiZ5gpVA064d/cW45taQmb924H0FSFJZSvZKaWFVps/S9AFVHTRIpMkgP94DuO3dZFrdS8fZdvnyrGpK86EZdffnH2RdwnENC2YWKkexyyUe3fOe9CvXvkppQFDoVTq1Av2DyouaKmOq7EKqgPZQNF5y1i7rKMHAPIY=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3030.namprd15.prod.outlook.com (20.178.238.91) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.17; Tue, 21 May 2019 00:37:16 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1900.020; Tue, 21 May 2019
 00:37:16 +0000
From: Roman Gushchin <guro@fb.com>
To: "Tobin C. Harding" <tobin@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Matthew Wilcox
	<willy@infradead.org>,
        Alexander Viro <viro@ftp.linux.org.uk>,
        "Christoph
 Hellwig" <hch@infradead.org>,
        Pekka Enberg <penberg@cs.helsinki.fi>,
        "David
 Rientjes" <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Christopher Lameter <cl@linux.com>,
        Miklos Szeredi <mszeredi@redhat.com>,
        Andreas Dilger <adilger@dilger.ca>, Waiman Long <longman@redhat.com>,
        "Tycho
 Andersen" <tycho@tycho.ws>, Theodore Ts'o <tytso@mit.edu>,
        Andi Kleen
	<ak@linux.intel.com>, David Chinner <david@fromorbit.com>,
        Nick Piggin
	<npiggin@gmail.com>, Rik van Riel <riel@redhat.com>,
        Hugh Dickins
	<hughd@google.com>, Jonathan Corbet <corbet@lwn.net>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH v5 01/16] slub: Add isolate() and migrate() methods
Thread-Topic: [RFC PATCH v5 01/16] slub: Add isolate() and migrate() methods
Thread-Index: AQHVDs6pVcV/OG74Wk6CpvJtS3vh06Z0vQqA
Date: Tue, 21 May 2019 00:37:16 +0000
Message-ID: <20190521003709.GA21811@tower.DHCP.thefacebook.com>
References: <20190520054017.32299-1-tobin@kernel.org>
 <20190520054017.32299-2-tobin@kernel.org>
In-Reply-To: <20190520054017.32299-2-tobin@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR03CA0006.namprd03.prod.outlook.com
 (2603:10b6:300:117::16) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:a985]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d99cefef-97a6-4cbe-1c5b-08d6dd847948
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3030;
x-ms-traffictypediagnostic: BYAPR15MB3030:
x-microsoft-antispam-prvs: <BYAPR15MB30305CE52774139B0ECF71D3BE070@BYAPR15MB3030.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0044C17179
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(39860400002)(376002)(346002)(396003)(199004)(189003)(6116002)(7736002)(8676002)(81166006)(81156014)(4326008)(66946007)(73956011)(64756008)(186003)(66476007)(66556008)(68736007)(66446008)(6436002)(53936002)(9686003)(6486002)(6246003)(99286004)(6512007)(7416002)(305945005)(446003)(316002)(6916009)(8936002)(46003)(102836004)(229853002)(76176011)(54906003)(52116002)(486006)(25786009)(476003)(2906002)(11346002)(33656002)(386003)(6506007)(14454004)(256004)(71200400001)(86362001)(71190400001)(478600001)(1076003)(5660300002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3030;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: bafUyGvs+JShrCdkx+i9PqhNPl7JekYoyH+hc3VkdhMYWXujaWEKv0qb1nRn/qHYxRN4vv8HSbcqxbYMCmlbff+HC6/t0cQj1YVCsjB6XQ0FY77txq1cwq+7BPdjMskEC4OZzrs3i2FHsKaqxnCLsjeXc31lgVU2sLoOmyD0OFrEG8A0G+G8j/MZy2u9fAoFmu5WpYrSTqxEVgoGOHlC1u28Fch/daYKUsGp/MgG0SaW8UUmEB3x9Tz79nIthZChJ0MpzFNt6SdhKPW1Oj8GIkXKEjQEgAt/I+JV+aAK7+noNGEn8BuCU+1CQ0BgAmHd8bhhvjZnmMY6oTSuLMVT00mwj97C963bBiZvI4l6vsIaBrDTO7q9NfR83FXlwURDLwPLP0tDa+rS5praDNjN1S5QGPG22xmp7ovXP8cvaqk=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <D27462347A96654B8D1C91CD8BAF33C5@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: d99cefef-97a6-4cbe-1c5b-08d6dd847948
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 May 2019 00:37:16.3502
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3030
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-20_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=442 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905210002
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 03:40:02PM +1000, Tobin C. Harding wrote:
> Add the two methods needed for moving objects and enable the display of
> the callbacks via the /sys/kernel/slab interface.
>=20
> Add documentation explaining the use of these methods and the prototypes
> for slab.h. Add functions to setup the callbacks method for a slab
> cache.
>=20
> Add empty functions for SLAB/SLOB. The API is generic so it could be
> theoretically implemented for these allocators as well.
>=20
> Change sysfs 'ctor' field to be 'ops' to contain all the callback
> operations defined for a slab cache.  Display the existing 'ctor'
> callback in the ops fields contents along with 'isolate' and 'migrate'
> callbacks.
>=20
> Co-developed-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> ---
>  include/linux/slab.h     | 70 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/slub_def.h |  3 ++
>  mm/slub.c                | 59 +++++++++++++++++++++++++++++----
>  3 files changed, 126 insertions(+), 6 deletions(-)

Reviewed-by: Roman Gushchin <guro@fb.com>

Thanks!

