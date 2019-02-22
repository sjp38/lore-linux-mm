Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 581C0C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 01:58:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC63E20818
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 01:58:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="p6s8J03r";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Ox703dSf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC63E20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B1C58E00E4; Thu, 21 Feb 2019 20:58:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83AE18E00E2; Thu, 21 Feb 2019 20:58:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DB358E00E4; Thu, 21 Feb 2019 20:58:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9228E00E2
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 20:58:04 -0500 (EST)
Received: by mail-vk1-f197.google.com with SMTP id v82so340426vkd.13
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 17:58:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=jrbsSQj2CFXyJ1UHRLcu6crILcrnVBDj2bcke0H9CNg=;
        b=dqwyn4fo8GZBNBZVjhOIyXqpptz0HMbyNRNjipsUUWQjlsDXpbkt7hi49vRfk6TmuJ
         e0DJEn5eTvm/+N55JZGonPrqppM7EhFLN3vtWzope7JHuEYJ6cTvKthMHWUdUHP5eh/N
         8BBl1Vpg1Djy18foOxUSfCaggY92GQ+UFhIAmUcfd4OKPuRmpVmjjLS4LCTWqi+/rizJ
         ceDuCNxt14TUexKolVMVssBSF6uJ6PDNRkhwdN4iSxKMEQsulUeySAL8NiDG7+XwHIfy
         ddAFsRvSqgRHHvhYCP3n8IdewOHoYT0l6Crja35bp9Sylq+djpDwacaDG5wVynfvkY8I
         iqfQ==
X-Gm-Message-State: AHQUAuabDavFKjR6PEZ3Ye2dHVxSXzafNEPLpOLqFM5uspkzEGvDXQlF
	UW5CpA0bSkZbo5L/lOVMw7UGa11e3hhBymUqz4AD5QLl+VGRzfYjvFiwN3Z9310icxcntDKNlUn
	hFYkXxTnuWkm627iKEK/nJs46ubBVgg+QOK0s+SjCJzSFo8BwupcFLMTNTQRRI1ozVQ==
X-Received: by 2002:a1f:a0d7:: with SMTP id j206mr978864vke.37.1550800683805;
        Thu, 21 Feb 2019 17:58:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia2pBC+bdekkP/DmZpnWQFFXZk5gZ5+9RVs+ZkmsSEg+DwlG4JeL6gEIAMudOVqLQwjTQAA
X-Received: by 2002:a1f:a0d7:: with SMTP id j206mr978837vke.37.1550800683086;
        Thu, 21 Feb 2019 17:58:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550800683; cv=none;
        d=google.com; s=arc-20160816;
        b=NtHQkC5ThOGqcfho1QFHZu8Tm/lgbVKB3ZLQsB/OA7iU35MGyPzzRs+RMUHely1iEK
         hwKdRjaxWYs3Ntj8tOhLNX/BwFCzGvW7mHOAzhlo+JO93wzY1Ed1z1DVhciVUICVsLGT
         2MVxnxoop6jsTeu7qq+jJ3VN44TxLcovrBlCGlhwv/1HE3vQipXfVoamebUBcOBzQCy+
         VSu3/KJ0a4tpWx4sOTJtetpytXyWgA7ZyJiWMnZd0x4GxbZ2XFBUnmddnTktb6G/UZIh
         EmK+RFsC0J3K3L+DOS9qHhPKR/Z+g1BrMNedl3IQNNOUgIs/4uM0WUMS7O6Ir8F03sfQ
         JHFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=jrbsSQj2CFXyJ1UHRLcu6crILcrnVBDj2bcke0H9CNg=;
        b=c4MVV9VdYA1fd5iiUP4EU6MhjHFiwhqj1HGnqFOYICCiKlT891h/ruKeHkNb+BRIAh
         +wHlwHfkQa6kxgFi1hl4ozEmZ9IoxShLVUcFrhDjehdCr23nY+jR+NSa/D1iBEBh8fZa
         HoCS3oOa7VrntwED2n+NL0k8mGTSEh41WHKZGx2b31wtYw/zcgHQc6FRfZBHatS5JKcq
         3uTW/UVjP1zHpYKt0Wz+UUKGFl7yZUnosHUzEgdnMj541jjW5nyLfRMUXXsWpJ0Fyi7j
         jRjmbv8eat+FBgnyaA2gb8MAQAKuF+HLTBVHMcPwPlUWM0IthTFTBqXDbHT5b+BRInK7
         TgHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=p6s8J03r;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Ox703dSf;
       spf=pass (google.com: domain of prvs=7956a61bbb=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=7956a61bbb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id n200si91491vkd.18.2019.02.21.17.58.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 17:58:03 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=7956a61bbb=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=p6s8J03r;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Ox703dSf;
       spf=pass (google.com: domain of prvs=7956a61bbb=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=7956a61bbb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1M1vwhM000520;
	Thu, 21 Feb 2019 17:57:59 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=jrbsSQj2CFXyJ1UHRLcu6crILcrnVBDj2bcke0H9CNg=;
 b=p6s8J03rvBlOos3nbQOSLB+41sQ0oQGaDeabGMh/ztVNwaydj9cZnURKvE9zmZAyA2w0
 eLSIB24xWobZXg+/l3WCF255RztwEVKJEMNE9+RcY9PHDz1Ru0Bc2c9rYVRz1hhiVTqB
 nBjwk/fmpgYL1uWat/T0pGQGO5bv7k8L84k= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2qt6wpr4wy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 21 Feb 2019 17:57:59 -0800
Received: from frc-mbx03.TheFacebook.com (2620:10d:c0a1:f82::27) by
 frc-hub03.TheFacebook.com (2620:10d:c021:18::173) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Thu, 21 Feb 2019 17:57:55 -0800
Received: from frc-hub01.TheFacebook.com (2620:10d:c021:18::171) by
 frc-mbx03.TheFacebook.com (2620:10d:c0a1:f82::27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Thu, 21 Feb 2019 17:57:55 -0800
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.71) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Thu, 21 Feb 2019 17:57:55 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jrbsSQj2CFXyJ1UHRLcu6crILcrnVBDj2bcke0H9CNg=;
 b=Ox703dSfrzI0XbmOqTvwpRwl1W4xGDMNMHjbE1rutTkycGWrSGLw9Aoxghq8gUiFIomTKudYlwgB3wxytWiRlze3PKFN6h+GxC5CSL+9C6vJynu0TqCzfxKpS/0s71VjgWHpzxgULALb9+2T2zhkVE8IzwPMT+q1m7/EcpdbgCA=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3383.namprd15.prod.outlook.com (20.179.59.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.15; Fri, 22 Feb 2019 01:57:53 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1643.016; Fri, 22 Feb 2019
 01:57:53 +0000
From: Roman Gushchin <guro@fb.com>
To: Rik van Riel <riel@surriel.com>
CC: Dave Chinner <david@fromorbit.com>,
        "lsf-pc@lists.linux-foundation.org"
	<lsf-pc@lists.linux-foundation.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "dchinner@redhat.com" <dchinner@redhat.com>,
        "guroan@gmail.com"
	<guroan@gmail.com>,
        Kernel Team <Kernel-team@fb.com>,
        "hannes@cmpxchg.org"
	<hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Topic: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Index: AQHUyCKda3Qt+ClMVUers5iRNki+jqXn/PCAgAAzK4CAABr9gIACDQgAgAC5A4CAAAKegA==
Date: Fri, 22 Feb 2019 01:57:52 +0000
Message-ID: <20190222015745.GA7582@castle.DHCP.thefacebook.com>
References: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
 <20190220024723.GA20682@dastard> <20190220055031.GA23020@dastard>
 <20190220072707.GB23020@dastard>
 <20190221224616.GB24252@tower.DHCP.thefacebook.com>
 <2d4e6dd7a546640c9ecb6a60b730d6c3a3da980b.camel@surriel.com>
In-Reply-To: <2d4e6dd7a546640c9ecb6a60b730d6c3a3da980b.camel@surriel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR08CA0056.namprd08.prod.outlook.com
 (2603:10b6:a03:117::33) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:1d8b]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 307ae225-93bb-4f8b-dca1-08d6986927ba
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3383;
x-ms-traffictypediagnostic: BYAPR15MB3383:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB3383;20:z6QCcO5Uvkd3ERE5sHzbeOwXy80+dUerGb20F5x54ad1fSp8K+TZUl72DGOi8/BELzHu1BOk7IzGS6vOARVST90fVK82kcRg+/6yQxx+8LX/36Uq0kKIaNFqc6biDthTgKghepeWkYfteXmsoDTOboiYOnsIIKxLi8hw1/XOSaU=
x-microsoft-antispam-prvs: <BYAPR15MB338382A06C7FEBBDA50B6B6FBE7F0@BYAPR15MB3383.namprd15.prod.outlook.com>
x-forefront-prvs: 09565527D6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(136003)(366004)(376002)(39860400002)(199004)(189003)(316002)(229853002)(186003)(76176011)(6512007)(9686003)(53936002)(476003)(6436002)(99286004)(6486002)(386003)(6506007)(446003)(4326008)(11346002)(478600001)(6246003)(71190400001)(105586002)(6116002)(14454004)(25786009)(256004)(54906003)(71200400001)(46003)(106356001)(86362001)(52116002)(33896004)(1076003)(2906002)(6916009)(97736004)(7736002)(93886005)(5660300002)(102836004)(305945005)(68736007)(81166006)(8676002)(8936002)(486006)(33656002)(81156014);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3383;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: rsh/zREWdnpnt6yzzvA+ek9c7XqLQmdNyxAsy6SBSzWOHw3C1rfbo5xws1kEApNsyfHg3B1XbpdbfiKpPJBA/nBT6SaAYCawEMGfOTsz4bHY2J2Lb4p/oCBBT+kab/2dfNbRIuE9J0QTd1TPFVDLwAzmAduFmZUrFQIsSM+03ft4MrUHCDP/gJJ9HK/kCqbLSaMF/tWixj1bAOVGP2irjdOKIySdRlgfgJ5c1oOVCNCbF4dpHSIpj5HpKoEI+M+RtIONRFnFJPggJFjkOvXz8F1b7AA4GkLBrAtjldbGngxZSqTVBqYIbacn9yS1dHpcGUo8OuyvNAr2mF3yCX3vd28TutIGZW0kUVczJvTIhB6czfi0pPJ6EBtwK85NcxN1ByfIIswMkNWYcFnaaoIJku3iHT8zRB4O9M5eR/fgEy8=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6EA09F38CD4C0848B5AE2A551FF94BB4@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 307ae225-93bb-4f8b-dca1-08d6986927ba
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Feb 2019 01:57:51.8424
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3383
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-22_02:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 08:48:27PM -0500, Rik van Riel wrote:
> On Thu, 2019-02-21 at 17:46 -0500, Roman Gushchin wrote:
> > On Wed, Feb 20, 2019 at 06:27:07PM +1100, Dave Chinner wrote:
> > > On Wed, Feb 20, 2019 at 04:50:31PM +1100, Dave Chinner wrote:
> > > > I'm just going to fix the original regression in the shrinker
> > > > algorithm by restoring the gradual accumulation behaviour, and
> > > > this
> > > > whole series of problems can be put to bed.
> > >=20
> > > Something like this lightly smoke tested patch below. It may be
> > > slightly more agressive than the original code for really small
> > > freeable values (i.e. < 100) but otherwise should be roughly
> > > equivalent to historic accumulation behaviour.
> > >=20
> > > Cheers,
> > >=20
> > > Dave.
> > > --=20
> > > Dave Chinner
> > > david@fromorbit.com
> > >=20
> > > mm: fix shrinker scan accumulation regression
> > >=20
> > > From: Dave Chinner <dchinner@redhat.com>
> >=20
> > JFYI: I'm testing this patch in our environment for fixing
> > the memcg memory leak.
> >=20
> > It will take a couple of days to get reliable results.
>=20
> Just to clarify, is this test with fls instead of ilog2,
> so the last item in a slab cache can get reclaimed as
> well?

I'm testing both version.

Thanks!

