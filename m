Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16851C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:15:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9979A20835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:15:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="aIO4jOg/";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Wqbxv25g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9979A20835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 381506B0005; Wed, 17 Apr 2019 15:15:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 331536B0006; Wed, 17 Apr 2019 15:15:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D3A66B0007; Wed, 17 Apr 2019 15:15:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF80B6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:15:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g1so13335341edm.16
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:15:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=o6NTzqE9GXtMEqiRcU33hNcS7lBA7ANxuiMMUVC8F+8=;
        b=ucPbdL0IDxNo7EEhAlg7lu+00WPoHoKeuMo09N/Z/CLxRGvHw+UKem8duAXIMts1Na
         bLl9xo3q1Op7L0qNv9cGT8cQfztykUST+JIDbsqfc2UdadqxRH/zM6qyXrKhD4ca1D4N
         WVV9l4qWx3xYval1NCup37T8bxX0axJZCJMGRndmX5tEEc3lgaEILsybbm3dmZAuA2Mi
         uptCnR0Yzon6g7V4FYi/pcGOtiQYLOVtDJQw1sWnyqCy+G7253jp3QYOsWADCHEwbMFg
         FcF3rJY64W7NeUtA8/5zcFiYKXbW2sizIjbJAPOChtdbiyeXEARjfJr5CVu3lh2oGxSS
         HOWw==
X-Gm-Message-State: APjAAAWYGRO7RpSajSG03whZg04FCz7jBb6m5ht7qd/RIH/70eEYcZGi
	/iUcDf4ctm+rW6XpPT1zrY9FFApjzjp/LVW2teiUdo9AiCNVXb/f8xZ8bp9fVNRBuin0UriGHhH
	8/arF8K9bboAg1AFv0RGdTLkB1ww9KMPY2Vcwh2vhoYZA3EA17e0K91EFCfa2A3upRw==
X-Received: by 2002:a50:901b:: with SMTP id b27mr21504142eda.250.1555528557260;
        Wed, 17 Apr 2019 12:15:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfITaMG4odS7GI3qNQEwMFcEEfq1aOW/Q/CKcmPGFT+ZUthfwcvvrWcpdH04lddY3PkT1x
X-Received: by 2002:a50:901b:: with SMTP id b27mr21504105eda.250.1555528556545;
        Wed, 17 Apr 2019 12:15:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555528556; cv=none;
        d=google.com; s=arc-20160816;
        b=Q1GeYfZs3rz4CM8JZMY/yK9beBFe/2jlmtK6Wb22+OnP+kbQy1uzTB9F2MkHzH25U7
         WD+069YWPaqodKiehdyTIwffQyI07MU6TCHd0x+YQhv0WxFqnnqURHFTg+Qrtd/kP6HG
         iV4UmwFBPp+TLz93ihvq1Fpftq4bEzh3FMqF+stZxYasMAxzVL73n2eJYNxglLj9XtRL
         GP3+idfo/Oe8CtNRYVo9u7HRkocn3CUnQf9V854CeU7H3cT4+yeLF59LAjewI5ITCJSX
         GJo+Kvm3QiWDd1XnlqBbwO6Rg0FOwi4BmZQD/j8uQLMFnjoIORk6Al2ZANdTVn5NZFaP
         QE9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=o6NTzqE9GXtMEqiRcU33hNcS7lBA7ANxuiMMUVC8F+8=;
        b=SsxQ8wPhjl4mVL89mkeK0THFGqPWBoxPZAgO17gwlPsBqENMwNhhfC7VVzRyilKL2x
         RnyNyY+WYgNLG+6RH77KvMRZExKxl+B+OPcRtBZsBhMvOnmeYeDvIk+2HaJW8AQOhxDM
         o3kVG5v1Trb6GL9YO4t3/lZkwlQggRGxAt+0cOnd5oRlU15HjtQm79cBoWo8g2h2Ck/P
         DlU4U8JKYVnS5WmIXeYBeRILuZOWigN3LomxTFoZGkp731RGyJo2dgVPTwjncASejI44
         Wnvuvi0nXJgT4VpfZyOXZI41FNXxn5mWGjfVuZiCBdsAvpDmSBfzm/JErC8lJV2Sx8V8
         dEFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="aIO4jOg/";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Wqbxv25g;
       spf=pass (google.com: domain of prvs=9010ac11df=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=9010ac11df=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id j25si3371394ejt.234.2019.04.17.12.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 12:15:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=9010ac11df=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="aIO4jOg/";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Wqbxv25g;
       spf=pass (google.com: domain of prvs=9010ac11df=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=9010ac11df=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3HJD46U025462;
	Wed, 17 Apr 2019 12:15:44 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=o6NTzqE9GXtMEqiRcU33hNcS7lBA7ANxuiMMUVC8F+8=;
 b=aIO4jOg/LrhZxFrYyxWQDSXv2F0JJxHXHhvHR2FGNXvL6IvJRT5r/erZMYSW4j0Nw6R+
 fJLy9Y3vxgDigPtb4WopgSJ7DQvRWKSqhISStTBj1apkqs663mQWagfkzN2MjLtVA++r
 iJGDWut3uwKCNayirWDt4Es8WgchnixVJu8= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rx7w1gj35-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 17 Apr 2019 12:15:44 -0700
Received: from frc-hub05.TheFacebook.com (2620:10d:c021:18::175) by
 frc-hub02.TheFacebook.com (2620:10d:c021:18::172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 17 Apr 2019 12:15:43 -0700
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.75) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 17 Apr 2019 12:15:43 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=o6NTzqE9GXtMEqiRcU33hNcS7lBA7ANxuiMMUVC8F+8=;
 b=Wqbxv25gXdes6Ju45aufZJOR9wZe9e2LTdusHfghxg5aSvRwWnvyzRMK+nrMrH0sN3pKj07yOCcKZTBixl4a7DYEgakSV+1plptbpng55yqydR01m4+n4zTFUY3UtswRbSgsI6/ZKNhEAhk1nB2K6YwYxO8eVus/2wDkmRnj4kw=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3510.namprd15.prod.outlook.com (20.179.60.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.12; Wed, 17 Apr 2019 19:15:41 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e%5]) with mapi id 15.20.1792.021; Wed, 17 Apr 2019
 19:15:41 +0000
From: Roman Gushchin <guro@fb.com>
To: Vlastimil Babka <vbabka@suse.cz>
CC: Roman Gushchin <guroan@gmail.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Matthew Wilcox <willy@infradead.org>,
        Johannes Weiner <hannes@cmpxchg.org>, Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH 2/3] mm: separate memory allocation and actual work in
 alloc_vmap_area()
Thread-Topic: [PATCH 2/3] mm: separate memory allocation and actual work in
 alloc_vmap_area()
Thread-Index: AQHUzUkHvmEZiK9g+UuhGR24XSYfTqX236aA//+c5QCASiueAIAAYSWA
Date: Wed, 17 Apr 2019 19:15:41 +0000
Message-ID: <20190417191535.GA16663@tower.DHCP.thefacebook.com>
References: <20190225203037.1317-1-guro@fb.com>
 <20190225203037.1317-3-guro@fb.com>
 <db6b9745-7e64-6eb9-6b2b-da9d157a779b@suse.cz>
 <20190301164834.GA3154@tower.DHCP.thefacebook.com>
 <ed835e2c-9357-c7ea-f458-0cd9b8f6e966@suse.cz>
In-Reply-To: <ed835e2c-9357-c7ea-f458-0cd9b8f6e966@suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR12CA0047.namprd12.prod.outlook.com
 (2603:10b6:301:2::33) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:856]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7c66eff2-ce3d-4827-6217-08d6c36914e5
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600141)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB3510;
x-ms-traffictypediagnostic: BYAPR15MB3510:
x-microsoft-antispam-prvs: <BYAPR15MB3510AE76931D0CB681CE1094BE250@BYAPR15MB3510.namprd15.prod.outlook.com>
x-forefront-prvs: 0010D93EFE
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(136003)(376002)(346002)(39860400002)(199004)(189003)(478600001)(476003)(46003)(11346002)(446003)(6436002)(71200400001)(6116002)(54906003)(186003)(71190400001)(14454004)(1076003)(486006)(6512007)(33656002)(316002)(53936002)(2906002)(305945005)(6916009)(6246003)(6486002)(4326008)(25786009)(68736007)(53546011)(386003)(5660300002)(7736002)(229853002)(9686003)(6506007)(14444005)(8936002)(256004)(8676002)(81166006)(52116002)(81156014)(99286004)(76176011)(106356001)(86362001)(97736004)(105586002)(102836004)(93886005);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3510;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: u5AC+a5Vz+MMnt3NWdzfnAlZW4w1U+GfW00UMx27X76ezXhGx9kBu3MBa96lWoTQm/GQhv3oF6T2hieyXOaj5W4m4O4d+I7puN0/7yLphumvyeiE4aIVf4CqaIJ0VJnzZ2yzF6ygi0VHZuVEwF9k7urTA95R4r1NPHNO25w4MgEz3PBcUu3h0+Fy0I9j6+jiDDGHG4XLXY2WkvqEvO5ra6NXB21CLKtJAjUd++L3gic2oDvppIsbCsQMk7JIK4VCn/gYjojiMmO+NwFkfiVl4t6kEPQPx8XAsgXidfQHh7cHleA+JbuaYZ4gY6LjBZmISitXkSLNJAJLnC1KQrG0ZOw03YAt9vUTIvf8WmM2MnB9vhZSRbYnySV2SdMzrCB8FPfaZP3IMipqaAzAhUigOx87jblNMVR1T4jqATyslIQ=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <212D8DE2A7DDF946B1E64CEB54733AEC@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 7c66eff2-ce3d-4827-6217-08d6c36914e5
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Apr 2019 19:15:41.2986
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3510
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-17_08:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 03:27:56PM +0200, Vlastimil Babka wrote:
> On 3/1/19 5:48 PM, Roman Gushchin wrote:
> > On Fri, Mar 01, 2019 at 03:43:19PM +0100, Vlastimil Babka wrote:
> >> On 2/25/19 9:30 PM, Roman Gushchin wrote:
> >>> alloc_vmap_area() is allocating memory for the vmap_area, and
> >>> performing the actual lookup of the vm area and vmap_area
> >>> initialization.
> >>>
> >>> This prevents us from using a pre-allocated memory for the map_area
> >>> structure, which can be used in some cases to minimize the number
> >>> of required memory allocations.
> >>
> >> Hmm, but that doesn't happen here or in the later patch, right? The on=
ly
> >> caller of init_vmap_area() is alloc_vmap_area(). What am I missing?
> >=20
> > So initially the patch was a part of a bigger patchset, which
> > tried to minimize the number of separate allocations during vmalloc(),
> > e.g. by inlining vm_struct->pages into vm_struct for small areas.
> >=20
> > I temporarily dropped the rest of the patchset for some rework,
> > but decided to leave this patch, because it looks like a nice refactori=
ng
> > in any case, and also it has been already reviewed and acked by Matthew
> > and Johannes.
>=20
> OK then,
>=20
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thank you for looking into this and other patches from the series!

Btw, it looks like that recent changes in vmalloc code are in a conflict
with this patch, so I'll drop it for now, and will resend two other as v4.

Thanks!

