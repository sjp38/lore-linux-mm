Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67291C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 22:46:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DF2B207E0
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 22:46:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="IdKDj3yG";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="bT+crDcB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DF2B207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DF328E00BA; Thu, 21 Feb 2019 17:46:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78F428E00B5; Thu, 21 Feb 2019 17:46:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 630618E00BA; Thu, 21 Feb 2019 17:46:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 336FE8E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 17:46:52 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id t15so147544otk.4
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 14:46:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=oT+xA3GC6kP7R1nN3FaXPR31Q9urTPB1nHHEH1EnIV8=;
        b=HdcLrAaAYEuNG/9qAHY9FINbfskUbSJCTaLcAtyaO6qHOISM/hq7CCHDeunwlqg9BG
         n6ErlPc/bs3iF5jYLBrzg8neJdr/dAvquyu7XTQoDSiFR3KLJ0flaoLz6vI9j5d9oPrr
         zLuWnIxT16e5WjlrSCNcyd2JubT9/KQ8VRLOG4FTPzUr8pmN/bH5ksLV6+sVbXZQMnxQ
         bSS+4gQl4eyIWxm1tdq1N0SG1X9PtYgINgLgSlgS+WvHKc3bkYMLB8VPgh9AwIotfmu9
         2RSd5N32S9sTG5kubyJiMfJg/axJDL4WcOTD/GcUd+l7NCe6afnIPW3omzJ2XDXlznAG
         Epow==
X-Gm-Message-State: AHQUAuYhrCVZCcqU3DpG/wSgWHs9q1+VhCZBnL0L/hKfIwBS9FGVtRVP
	D8VSFjRl7MDQUWRLHOh3Nw44A413Agam2fNMhDMOYz2vyVj2qP1h+eWraAS0xg68j4mzsRmXmkI
	95Rw6SEC/TG2rFkPsilTOdCB6JRfW2mSAThMpABHUXPr4lS5+87BOMcMIGZ26k9Dkpw==
X-Received: by 2002:aca:edd7:: with SMTP id l206mr591167oih.11.1550789211830;
        Thu, 21 Feb 2019 14:46:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYALwgVA2se1kWnVK1YlxGnp+r4/I7WlkITZlIai9mnp2Vaei9HVN0RlYsErSnSZ72lWR4C
X-Received: by 2002:aca:edd7:: with SMTP id l206mr591129oih.11.1550789210980;
        Thu, 21 Feb 2019 14:46:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550789210; cv=none;
        d=google.com; s=arc-20160816;
        b=HtEwG99R6NvO3TCldOHy516q3rhyhIDe2OjN++rXeWPSfwkt3rNqhofrgdmEfBh/Ub
         Gn29eWziXhyeQxbzImbs/y1UwdKywikUVbsTnM2d65lUFWaFUZiLtKzMt/H719AmDoct
         J6VEd9Y2AKgrcIHArmVbUWJmRq7zXQdmMhiGFzd17ZjwWbbYVYYJq4+goUqguZUBHz9r
         VhKNhjInsSpl7bNTN+Sejq1oPAPdjsbIzJXdh1WXemgx1CIwEsZ5lLV55sy9eLbPpRXt
         6B6BQigk48k+OdP44M8AKgfbp/EkkAf5wJ183oYsLm5EkMTm1tQWPVH1fVdRAIFg4P+G
         qK7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=oT+xA3GC6kP7R1nN3FaXPR31Q9urTPB1nHHEH1EnIV8=;
        b=mUQQBe+P1GhoQo6SnUzE7q1QoAEEH7lCMzgk/qtrxJtlUoxpONqzqI2Km4j0bvqfS8
         Yt4CDCCgOVcIndO0/GpGLDAsXNgATRtbIvDWHhZZxl79Vh0Pz7YBINfoP6VEoqSWLz6n
         uv4lhTtnV1WVEkuQYTGps587OSiq0ebbz5c9T+j1Vhw/F/c3cMdFdfMS120GWbarM2ut
         AVNUzDKli1/JXbKz1mCuuB3miLyAt0oY1qMjjiGPq/jdOllODquinPJ7jw0zH3eyTjKH
         30hsAjz0QV7tYdjbfjz55m5yXT9g3AqBO4cwGHvSPXpNSH+jiyXVZC2uJw67FfvhW0JA
         qofw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=IdKDj3yG;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=bT+crDcB;
       spf=pass (google.com: domain of prvs=795511d7f6=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=795511d7f6=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id g2si59961otj.44.2019.02.21.14.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 14:46:50 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=795511d7f6=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=IdKDj3yG;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=bT+crDcB;
       spf=pass (google.com: domain of prvs=795511d7f6=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=795511d7f6=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1LMYaKu013394;
	Thu, 21 Feb 2019 14:46:47 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=oT+xA3GC6kP7R1nN3FaXPR31Q9urTPB1nHHEH1EnIV8=;
 b=IdKDj3yG8mt0+0XwSTL/enI4wetn5K21WvNfN1RXYFHsQDqyAN7V5gAg5kCRG4vPTD3E
 TNqLy6Oy8xFwFXdoG/2ccCJjlPSCAiRxw+SSiZQlK8cxj2XtqD8uJP9nq8FNxPL/UlDk
 9Xdn3Et08UA9HenIcQOWgH5TeLDbBeXFd4c= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qt2bkrkar-7
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 21 Feb 2019 14:46:47 -0800
Received: from frc-hub02.TheFacebook.com (2620:10d:c021:18::172) by
 frc-hub06.TheFacebook.com (2620:10d:c021:18::176) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Thu, 21 Feb 2019 14:46:21 -0800
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.72) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Thu, 21 Feb 2019 14:46:21 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=oT+xA3GC6kP7R1nN3FaXPR31Q9urTPB1nHHEH1EnIV8=;
 b=bT+crDcBV8JbAs2Vwg3Akah0KUW6PbYl3nyo+ISrO/l3NqKwmNsmNbQQrvzRuHLPyjeVSpi0pLJ+5KAL1TZpDB6E8XLqHuEp2wUlWsRYTo2s0Veii0qDpX0i1om//jQ3ncEaFZKnt/HCywVn/fLqsWnbund+md/BPXBtyW520fk=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2599.namprd15.prod.outlook.com (20.179.155.160) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.20; Thu, 21 Feb 2019 22:46:20 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1643.016; Thu, 21 Feb 2019
 22:46:20 +0000
From: Roman Gushchin <guro@fb.com>
To: Dave Chinner <david@fromorbit.com>
CC: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "riel@surriel.com"
	<riel@surriel.com>,
        "dchinner@redhat.com" <dchinner@redhat.com>,
        "guroan@gmail.com" <guroan@gmail.com>,
        Kernel Team <Kernel-team@fb.com>,
        "hannes@cmpxchg.org" <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Topic: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Index: AQHUyCKda3Qt+ClMVUers5iRNki+jqXn/PCAgAAzK4CAABr9gIACkyWA
Date: Thu, 21 Feb 2019 22:46:19 +0000
Message-ID: <20190221224616.GB24252@tower.DHCP.thefacebook.com>
References: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
 <20190220024723.GA20682@dastard> <20190220055031.GA23020@dastard>
 <20190220072707.GB23020@dastard>
In-Reply-To: <20190220072707.GB23020@dastard>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR01CA0060.prod.exchangelabs.com (2603:10b6:a03:94::37)
 To BYAPR15MB2631.namprd15.prod.outlook.com (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::6:b358]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2dc6c074-f0fa-46a4-b346-08d6984e6575
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2599;
x-ms-traffictypediagnostic: BYAPR15MB2599:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2599;20:pKJEt33BUVS9bIyGxbz7qu0lEZkLkxf/S8YuSKDEOdx3r4YXR+KTlQbs5UZr/P9fogX5UCJGOtJtup+IlODBpe2txYJWz/bH4MwOy5ddl+9Jf06iTzzGDiwiIpD7NPWO8Wn0oz/RuPwinmFRz+doyOGEuaSHThuLABRMI5DlMX0=
x-microsoft-antispam-prvs: <BYAPR15MB25990D339B3F159CCBAA8BA1BE7E0@BYAPR15MB2599.namprd15.prod.outlook.com>
x-forefront-prvs: 09555FB1AD
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(366004)(136003)(39860400002)(396003)(189003)(199004)(97736004)(6246003)(86362001)(186003)(9686003)(102836004)(76176011)(229853002)(81156014)(8676002)(71200400001)(6512007)(106356001)(316002)(7736002)(52116002)(99286004)(6486002)(2906002)(305945005)(53936002)(8936002)(6436002)(33896004)(81166006)(71190400001)(25786009)(4744005)(33656002)(54906003)(386003)(446003)(93886005)(46003)(11346002)(14454004)(1076003)(6116002)(4326008)(6916009)(476003)(256004)(6506007)(486006)(105586002)(5660300002)(68736007)(478600001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2599;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: AjMjlhevrMBIzdRhfyw5m8qCu9ubCXvobnqFRQZidjvtIjYhdwblPJmcE7qW4cHXqssCEDTqlAhMw5wXmrK1DGKsDIWDFjj6X5UP5Ny3tVtG5xCmswJYHlXLoqPcr7vkdIdCZ9xbbSTemQQArbTLEzhW+pF2HwcSUEkQn8689NyY0DLg05XEqrWpdiXRp1Tg84SHmirVHoXX1nKAJUBxkhqaNIVx/4sIN/+FABOhOKWBx5LpB8AFtpUZvZg1HYjIJi1JJcCBWeSm4hBsr25YYeMLmV78E+NVN9cud4hqYSOokAnG06zdywMXxu0w6AG3gzouigUnEH3cNx8Hlzd2QhC168kfNhjl4DTgg1WvvAX4YNBRwhywLIH7fnkWHgYGEG84i5aOjA965uGCqhxRq1rxHLgbEU8T4fRa4lmGRvk=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <20451F9179FAF341ADFC9FE07EBE7BBE@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 2dc6c074-f0fa-46a4-b346-08d6984e6575
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Feb 2019 22:46:19.1964
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2599
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-21_14:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 06:27:07PM +1100, Dave Chinner wrote:
> On Wed, Feb 20, 2019 at 04:50:31PM +1100, Dave Chinner wrote:
> > I'm just going to fix the original regression in the shrinker
> > algorithm by restoring the gradual accumulation behaviour, and this
> > whole series of problems can be put to bed.
>=20
> Something like this lightly smoke tested patch below. It may be
> slightly more agressive than the original code for really small
> freeable values (i.e. < 100) but otherwise should be roughly
> equivalent to historic accumulation behaviour.
>=20
> Cheers,
>=20
> Dave.
> --=20
> Dave Chinner
> david@fromorbit.com
>=20
> mm: fix shrinker scan accumulation regression
>=20
> From: Dave Chinner <dchinner@redhat.com>

JFYI: I'm testing this patch in our environment for fixing
the memcg memory leak.

It will take a couple of days to get reliable results.

Thanks!

