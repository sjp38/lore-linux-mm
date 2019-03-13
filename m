Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2646C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:26:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96B1121019
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:26:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="mziFIS8O";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="B0BG1qry"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96B1121019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DE4E8E0003; Wed, 13 Mar 2019 14:26:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39B338E0001; Wed, 13 Mar 2019 14:26:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 230B08E0003; Wed, 13 Mar 2019 14:26:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D963B8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:26:12 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u19so3103762pfn.1
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:26:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=ud6/U5sLaNyQXgEDX4pHtMm5ih1hKxAeLoRbN2lxZms=;
        b=BslmPGCO67qmGLorlmQx8kpv3RB9h744u5j1iuNIDZdmGH489gdNkXUv/ZqgBkrhJc
         xTOApA6X9/HpBRS8B3ygh5yG9QK4JiMEzlc85wbaG88a00wnIl+5FPhVcUYvTT3cKlpJ
         AkgSaqu5a5BHu4WSal6Jxf52RxQ6RbEVkY8cdFUivtzos0zeGh1FyH//Q0AYecsJDoA1
         Zzd3A2TRso/9NmDcJkoPTDJW7YJH3auOE9xtKPMBIuwxJ7u8MLFvk4b9HzhYBNLZ3iSE
         uwDZp3SAAjirWblaMRITh9JC/YFhnjU1HV1EH16uOWrkFtprwTA/VwUaE3blK+ThRjk0
         Cg3A==
X-Gm-Message-State: APjAAAW3YaJH+kqrPo9NsvcXjZbAtjh583G5emrbQSAEUIhXTgcsooeb
	9m6bGlA4Lr72GjB8oz+AEqwIGLtS/YrGacHWlGDVD27KZ0iCeczvTMgkvaMrDHutk2OkDxiWwys
	TM+gE/PLdT98EeTKw55OovpICHFyjoxRwXzqP/e+mfNbeCvseUPioKFZnwUjA90jh1A==
X-Received: by 2002:aa7:81c5:: with SMTP id c5mr46493930pfn.217.1552501572458;
        Wed, 13 Mar 2019 11:26:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxANCCqmR8bYIrdYdnIqdMGdNHBRIwXcAFiy8fOAxpAt+sYMPFdKP467G6RnZG1MaBZXzZR
X-Received: by 2002:aa7:81c5:: with SMTP id c5mr46493884pfn.217.1552501571625;
        Wed, 13 Mar 2019 11:26:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552501571; cv=none;
        d=google.com; s=arc-20160816;
        b=Vug+2DN5X5e+XkS1edqsNU12wxKNmfh/PxY+X5QKp1qmdbR6MYlU9PODRErgm9JUuS
         KDrWmGCBQOjlptjtWktka1134SrAiZ56mG6vRsZk26c1O/CV+lmTZmAGZ4WPKOKKJGa5
         gFtyaRDWW6O5RKJSlwYwPoUKPDgpiiJ96B3t6Wnv0UTQks87BSK4ol8edUJdOsOQYopz
         arqC3qJiX6BE7UdLa1i85uiAlNp2mvMItwOHDSSsb1wIFg/5GhX6KlQCVWnZXUtPsDat
         TDLygG+wYsYudJTjsX6xlwBbEutToHupdKmk8plapUq3h1gm7TxI31uM5+vgeUIR2x7q
         /IDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=ud6/U5sLaNyQXgEDX4pHtMm5ih1hKxAeLoRbN2lxZms=;
        b=H4pyNn1MS+4D6PAebP8HqsWjqbU1jf09qNEBIky4e2+Mi1hqDZyZHGO///DXBevOcP
         AZ2qOt65xDl/athLRIQeL5rQtdLgm8iBVDODPWa03bYFCY1aOi4eOFWn/90aeFn2B7AG
         BiJDgktq+hUgFeF3t8f2nkkrK1x/FZfYaUKe4YxQwUbIoBudiym3cYbV4WO/ASztAZv0
         OUbq8EHmqtcglUmcAaeeD1046OfS2fFY31pqE08GFwRzT2JQafHebVXPsDIvv+pJgXOj
         ocndbBaJW97ZHgNrCkUoJghKoQYpbRpsO7knRDGvZTJ4AqEmCSY6i1ysxCvpYTKUqLJx
         FVBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mziFIS8O;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=B0BG1qry;
       spf=pass (google.com: domain of prvs=8975a33d68=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=8975a33d68=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id n1si10260712pgv.545.2019.03.13.11.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 11:26:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=8975a33d68=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mziFIS8O;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=B0BG1qry;
       spf=pass (google.com: domain of prvs=8975a33d68=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=8975a33d68=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2DIJp60006331;
	Wed, 13 Mar 2019 11:26:09 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=ud6/U5sLaNyQXgEDX4pHtMm5ih1hKxAeLoRbN2lxZms=;
 b=mziFIS8OmcB2Is91py7AUWN/UQz/Ls1qbwNhOrXSSsvF7DDruapGvastyLrSznxvm546
 yZRl/JHVjpWDgmR46CCVDi8S1Mk+x/icnHhB1e+lYa2BBkc7V8rpUU60bBSrhStn4YQ4
 8m7ZSKZmOknxa9KDASU8fwppT2LybCnBhF4= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2r771wg1js-11
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 13 Mar 2019 11:26:09 -0700
Received: from prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 13 Mar 2019 11:23:53 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 13 Mar 2019 11:23:53 -0700
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 13 Mar 2019 11:23:53 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ud6/U5sLaNyQXgEDX4pHtMm5ih1hKxAeLoRbN2lxZms=;
 b=B0BG1qryZKvLbkk6UtpBeut4ET96MlB4oTZu5rak8GF5wTZ5mcyoyWdNktcyf2timix7VwAiEVaQgJP9GuifI5MV24UhRBujxyLL68icPybzbN+Ssc0hTeLLfRQ022LO4t6KKBcIgSfwUvSz48ftxSsSFOKI+cXNu8TgiYZDGBw=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3192.namprd15.prod.outlook.com (20.179.56.94) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.13; Wed, 13 Mar 2019 18:23:35 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%2]) with mapi id 15.20.1686.021; Wed, 13 Mar 2019
 18:23:35 +0000
From: Roman Gushchin <guro@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
CC: Roman Gushchin <guroan@gmail.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Kernel Team <Kernel-team@fb.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Tejun Heo
	<tj@kernel.org>, Rik van Riel <riel@surriel.com>,
        Michal Hocko
	<mhocko@kernel.org>
Subject: Re: [PATCH v2 6/6] mm: refactor memcg_hotplug_cpu_dead() to use
 memcg_flush_offline_percpu()
Thread-Topic: [PATCH v2 6/6] mm: refactor memcg_hotplug_cpu_dead() to use
 memcg_flush_offline_percpu()
Thread-Index: AQHU2SPHfXxtM9jIQ0KuYqpravz+paYJu4eAgAAl6oA=
Date: Wed, 13 Mar 2019 18:23:35 +0000
Message-ID: <20190313182330.GB7336@castle.DHCP.thefacebook.com>
References: <20190312223404.28665-1-guro@fb.com>
 <20190312223404.28665-8-guro@fb.com> <20190313160749.GB31891@cmpxchg.org>
In-Reply-To: <20190313160749.GB31891@cmpxchg.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR06CA0024.namprd06.prod.outlook.com
 (2603:10b6:301:39::37) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::f5e6]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 078580ba-439e-4445-d3d0-08d6a7e1018c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3192;
x-ms-traffictypediagnostic: BYAPR15MB3192:
x-microsoft-antispam-prvs: <BYAPR15MB31923ECE92661A5BDCE4AED6BE4A0@BYAPR15MB3192.namprd15.prod.outlook.com>
x-forefront-prvs: 09752BC779
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(39860400002)(366004)(136003)(396003)(346002)(189003)(199004)(1076003)(6116002)(4744005)(6486002)(256004)(86362001)(316002)(6246003)(7736002)(305945005)(5660300002)(186003)(25786009)(229853002)(52116002)(4326008)(386003)(9686003)(6506007)(76176011)(6916009)(102836004)(81156014)(6436002)(71190400001)(478600001)(53936002)(8676002)(99286004)(97736004)(8936002)(446003)(46003)(14454004)(105586002)(106356001)(476003)(33656002)(11346002)(486006)(6512007)(81166006)(68736007)(2906002)(54906003)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3192;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: W4ZXKtGqonpn34CApX3WoIFNatmGsbukFbmxlANWRngoEECNmSisUrnXJIgSu8EmHqLF5ewi4pj3btJZCN6eS5PhhH/Vyl+QcUC0TfKuri+F6ryrEP4RL2lLlA40LIQtkS914W0Hn23QTUyLTHuB3PEe2YIIwtz8Reqz7EnKf0KBGgUuWMDc6hIp2dcGQekvn3eABJLPYT4zdY/hFlusj8k8bIsqf3WHQ98JaDngosO//ZJydinyGS3ZUsAJxVQALbX4u6LLAozXZ09WBSI3da0FCviiwolu8gn/eekKyG6xcy7Y7CRjE70ox8UcJDvW0ZBzO8YvOa7G5vC1K+lz3fn6vc6qxBW+T6jrEAjY2+TdL7dTF/P0Frtc7WwEoDRrLuLekcQsRPK4eTKS3C+7vPOV4xmT2+yIaKWycLuzwLU=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <65B672453086894D9C2E74DC37F97FB3@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 078580ba-439e-4445-d3d0-08d6a7e1018c
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Mar 2019 18:23:35.7732
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3192
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-13_11:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 12:07:49PM -0400, Johannes Weiner wrote:
> On Tue, Mar 12, 2019 at 03:34:04PM -0700, Roman Gushchin wrote:
> > @@ -2180,50 +2179,8 @@ static int memcg_hotplug_cpu_dead(unsigned int c=
pu)
> > +	for_each_mem_cgroup(memcg)
> > +		memcg_flush_offline_percpu(memcg, get_cpu_mask(cpu));
>=20
> cpumask_of(cpu) is the official API function, with kerneldoc and
> everything. I think get_cpu_mask() is just an implementation helper.
>=20
> [hannes@computer linux]$ git grep cpumask_of | wc -l
> 400
> [hannes@computer linux]$ git grep get_cpu_mask | wc -l
> 20
>=20
> Otherwise, looks good to me!

Fixed in v3.

Thank you!

