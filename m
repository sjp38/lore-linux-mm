Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C0B7C04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 00:39:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4878421743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 00:39:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="VYSChcHG";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Lpxvp1lM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4878421743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC7136B0003; Mon, 20 May 2019 20:39:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D513F6B0005; Mon, 20 May 2019 20:39:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B81036B0006; Mon, 20 May 2019 20:39:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1305A6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 20:39:07 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id p13so16205872ywm.20
        for <linux-mm@kvack.org>; Mon, 20 May 2019 17:39:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=E3+cLSVQNP4p25wZAs7M154LsdZMQ5nxvcwFvwkF7vA=;
        b=MN4eEpIX2k3WSwxfZGDOaywIR/osUKWugfkypAMzqAyf4R8pXmyehKM7IZpGimlokQ
         2AS/JiKsauDq3iIlHHnIt6EYE5s7XhBcwENBbS4MkvRUc1y2iY/uAdMHWGtLkwv4xl16
         yOxXYd3jFWYoi/vlZElQ3Dkt8slVZKsFsudaubkLxSXFOXRaMeL/PL6pNj0PdwG6lhrD
         a6wWM+3NOiEAiIxtL8eLSCH6ElD4DkNbVSarcAHjdFeHKh9cYHLksqfnPPs9T9DUTonf
         0bRmf0mRDhdi0BQBptlCsfWGqfPt7HBogZheJzVN//ScTAn4g9ZesfVNu3//kfn+LcJW
         Eg5g==
X-Gm-Message-State: APjAAAUgOP0nfvAzQGhF7K+o2r4vK2LFfUyszuqpeXksKIasENP/M7bA
	jRXY+5xRClFpUpqxT3nT5/Alh7qwv/P67dIOL6ThoGE8r+rLNsS8lYbPFa01Jg3VBePfxSUZBn9
	vnryUa46AVleYAwFeQP5fYRlawwnA4InJddn9jYMzo8NLBJgMwNch1Plrons5FII2CQ==
X-Received: by 2002:a81:9913:: with SMTP id q19mr36740909ywg.215.1558399146774;
        Mon, 20 May 2019 17:39:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyT9xL9fol/1SMYj5VPD0/7wcztS6iDK3unzqgyOkAQVa9eUoxHhcq7V0O/ID0G1632pF+V
X-Received: by 2002:a81:9913:: with SMTP id q19mr36740894ywg.215.1558399146256;
        Mon, 20 May 2019 17:39:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558399146; cv=none;
        d=google.com; s=arc-20160816;
        b=HTJa/nThO9cX94CTtP+gZrXygnjGyBFfkeb32ciu8FSOfIvTe8tqOFyWz5tvnVuaku
         Ev0GX8wcQY5cdm0YcpInNilpFRqXseKi1rX+MJoTU+vvCS9srIkHgzz6ODuSSju9s2v0
         DGVfh8gsKnF5Cxv/Bsbvy6eYBnkYPEcwx/RyG8DlHnOxg6k7b59yqA7XXWD5zW+dsO+z
         f3iO5fBBwTvetbgTnzCkikFNDb6r7DxcuU7LGsD9wDvrRJ4peVT0g06vmWFSTJDsUTN4
         DATmovhdpzxhUr3mZ0soJkHG6VIS/HDwmbtELKFctnx4X5TBlY17OmFXtLaKDsif57Rr
         Y4kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=E3+cLSVQNP4p25wZAs7M154LsdZMQ5nxvcwFvwkF7vA=;
        b=ZT6/PpZ6swdGQdS+Uf9If2TpYiOSC0DwSurGDXNqQlG5KyzzFcrcgZXKdu85Vqnugp
         PF7q/mNe3yZPDmJonwdqpZ4lhYgnZ9xgbRSRXrzWUGUGOD3B+LxE1/t3fv8lF73sG+Mn
         J/8EFcZIfi83pblBCMku76gzwFfep9AY4vPPFjXAfxGdzFEXlJcKPi0GFi6SK7+h0Ve7
         YesdT4L59glSXMx2PUCzDRKNKlYmklv4Bg7cX4qlF/yhqZ61uN9sWmol7qKwFSAgIw8t
         RyofAqNrD17g3MOwF4x01jKq1l5UZIFJjXGGValPaGpecSjkw3o1hn+c/zVtXI9QVJP3
         7MuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VYSChcHG;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=Lpxvp1lM;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u200si6037308ywe.319.2019.05.20.17.39.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 17:39:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VYSChcHG;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=Lpxvp1lM;
       spf=pass (google.com: domain of prvs=0044fe9fa5=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0044fe9fa5=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4L0S56l028300;
	Mon, 20 May 2019 17:38:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=E3+cLSVQNP4p25wZAs7M154LsdZMQ5nxvcwFvwkF7vA=;
 b=VYSChcHGvoes0aoHcuoyIWkJa98s0Lw6pyTkZms7n4RKfOV8ThxKfoTSR1NLZnjwHuA7
 4FH3nhtzfrCG4/NDm1MIakVc68YqpIROcUIXOmsdtabEFXzdLitGSMUtODonzFAuvtkK
 M3DQTdxuZyil9qiekFKPBfewi9OhnqAI5MI= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2skusdtf1h-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 20 May 2019 17:38:45 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 20 May 2019 17:38:44 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 20 May 2019 17:38:44 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=E3+cLSVQNP4p25wZAs7M154LsdZMQ5nxvcwFvwkF7vA=;
 b=Lpxvp1lM86qlDs6r95jZcMFZ0d8iGkyYmH7giaFCbaBKGAWOyaOX7NhJh2hyXLvNGr11y5TPa8cFfg2eXB7HfOjc+7qQqaVhd8/a+wIKRHkGZutgy7QjG3o8QMVdOa2DDbjtTG44I47V4m6AcfYAhRAsX3o1gq8ZWcxJfj853EA=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3030.namprd15.prod.outlook.com (20.178.238.91) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.17; Tue, 21 May 2019 00:38:40 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1900.020; Tue, 21 May 2019
 00:38:40 +0000
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
Subject: Re: [RFC PATCH v5 03/16] slub: Sort slab cache list
Thread-Topic: [RFC PATCH v5 03/16] slub: Sort slab cache list
Thread-Index: AQHVDs62IV4Zydo66E+iHqIO5Pdo5qZ0vW8A
Date: Tue, 21 May 2019 00:38:40 +0000
Message-ID: <20190521003835.GB21811@tower.DHCP.thefacebook.com>
References: <20190520054017.32299-1-tobin@kernel.org>
 <20190520054017.32299-4-tobin@kernel.org>
In-Reply-To: <20190520054017.32299-4-tobin@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR14CA0005.namprd14.prod.outlook.com
 (2603:10b6:300:ae::15) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:a985]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 70c0967b-98c8-44cd-25cf-08d6dd84ab7c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3030;
x-ms-traffictypediagnostic: BYAPR15MB3030:
x-microsoft-antispam-prvs: <BYAPR15MB30307E13ABD855F4D387D23CBE070@BYAPR15MB3030.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2887;
x-forefront-prvs: 0044C17179
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(39860400002)(376002)(346002)(396003)(199004)(189003)(6116002)(7736002)(8676002)(81166006)(81156014)(4326008)(66946007)(73956011)(64756008)(186003)(66476007)(66556008)(68736007)(66446008)(6436002)(53936002)(9686003)(6486002)(6246003)(99286004)(6512007)(7416002)(305945005)(446003)(316002)(6916009)(8936002)(46003)(102836004)(229853002)(76176011)(54906003)(52116002)(486006)(25786009)(476003)(2906002)(11346002)(33656002)(386003)(6506007)(14454004)(256004)(71200400001)(86362001)(71190400001)(478600001)(1076003)(5660300002)(4744005);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3030;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 4s+SYJPSmiJ7nXYS5W4A3hnVp7aVbFPYyJbjP1TFSqIoKDGJQgHciWYFBrFvNzAUgySmic9Mv2MTMg0OLmiX8cNilaXRRmzYCnc09FqqhZH+ONyDzTSHnsjRoDkYirOUepqEdIGj2LmxYw6ngRqMU8nH6nV+luREC7o55arAdrMnqG5QLm7/9OGXX/EMqcV6HV+QJons4uiGp9Vgm+7BIH7jvfV9svnHD3bmg1dwTTuQhnxstF+YXvzEnJ8lFuNzLnzh4+M8elynSCGoHe7t43wRrnahpsL+ctMjIr4uTDaHWLA/lrvLJmG2cjkLq+8V1CSAgpl/bhj4ldGgsDe5eEItXoM+fWIlIPxws27p7q6ryj9Eq5G5nviPUQ8+eEJvYOShEMPyTiSQVkpVmVbskqxw6qp1KdK1dxW3nJ41JIQ=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <7DA0F6E4E77DF64B87BF2DF516986776@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 70c0967b-98c8-44cd-25cf-08d6dd84ab7c
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 May 2019 00:38:40.5953
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3030
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-20_09:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 03:40:04PM +1000, Tobin C. Harding wrote:
> It is advantageous to have all defragmentable slabs together at the
> beginning of the list of slabs so that there is no need to scan the
> complete list. Put defragmentable caches first when adding a slab cache
> and others last.
>=20
> Co-developed-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>

Reviewed-by: Roman Gushchin <guro@fb.com>

