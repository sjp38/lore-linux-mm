Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 774F2C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:25:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1149825E50
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:25:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Ja5wUa4h";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="IxHHHKuG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1149825E50
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8BFE6B026F; Thu, 30 May 2019 13:25:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3C3E6B0270; Thu, 30 May 2019 13:25:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DC806B0271; Thu, 30 May 2019 13:25:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE496B026F
	for <linux-mm@kvack.org>; Thu, 30 May 2019 13:25:19 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id n4so4058270ioc.0
        for <linux-mm@kvack.org>; Thu, 30 May 2019 10:25:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=yVqMKbVLVx/XNxTAag7lRIIZNSJ+Voj0UhYKwYYmDOs=;
        b=oOg6u+jwxGWhuj2xBAc/8OkCw8uUEzUMXfsV6yV+tWmN7r5jC4wo0J3fwZHuQ2upZm
         X83lwFA87g6AC9S7RygnSVl0mLU6YlztJ6yiqC2ee0KENQJDP7uFF41dptEeukrhC9lb
         PmKl95COP77sLx/LGQh8Pzn3lQXI5rz3QyGKXYzDSx4etKNZntXobfaYRPru0LDeT9vh
         C2ne7LT7Xo1HzEAAvW9imZ6NCUd06Z/Tu2uPgiLX2bWrgywkvvOl4vpyy63y4h5UUL5K
         kRdLO7nyRN/pCyuqJKFL6E9nNWFda1+aFXQyBRybmJPc2MmO7pCZpn5ndLO4p2uIwYZH
         Y2Jw==
X-Gm-Message-State: APjAAAUN9zaalLI2p6xD1rObr5QTJW5hoVRbwCthskoUcge0MUHR4Cu6
	bv/HkaO1lLqo1IbmfuHZgIR6xT34l4QwPbemrKKja+o7/bj2YfLU5MKe4dQ4PINyv3yx7GhYAHv
	DqoUP6LXyabQZsLaqV/dp5zfinE9yk8nll7ZpGylOTHav1aN82rCRS8uNScnBputzQg==
X-Received: by 2002:a5d:9957:: with SMTP id v23mr3335212ios.117.1559237119153;
        Thu, 30 May 2019 10:25:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzhohLaA/tq7IS/yxD8lU3kdor8zLMLRZ376Yi/+b6aA0zCdNaqb68jw+eIMYt693eg0VF
X-Received: by 2002:a5d:9957:: with SMTP id v23mr3335184ios.117.1559237118539;
        Thu, 30 May 2019 10:25:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559237118; cv=none;
        d=google.com; s=arc-20160816;
        b=Iv78Puapos6Nd9gU+zlw1fEtdGmfEoVNYn/fdr7YSTH8/OvWBAuwaYnxjqqgED2AxK
         5NN5OMXacw4sZYkD9yU4XZXMeF6rCIBNVASXY45xT1TjrLEshh1uglsaQwMZv9Jvw4Jr
         0RDD3+M0L7a1ebr6Sa8IiYIUkMTU4gZDNaV2e0ptKr9Rwt9QoK40kYBci8SYlh0IHC5G
         qdBOtrRcF58aN+qDbLYkC1aH9dyR7WDomvkqFc7ECDQrzw5U8kW3z2RUY8VINMSERzCX
         +npUJR8LhDFS9NKd7t5tPBJkmVNl7FnCIkYCVY+dmOWoX8GFLz9/+JNBtp1oq8HUFGwf
         0Z7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=yVqMKbVLVx/XNxTAag7lRIIZNSJ+Voj0UhYKwYYmDOs=;
        b=B4uRqase5dsEb/uDjSGCwbCmlT81XjXRPi5GaQvQVK+Uy1Dc6NJc3UwWivYqlNp4I7
         mYxc2+6iFC14QBiBA4+R613lxR2b8We8lZp1Nfnd9mZzKcfET/d6IE/Bg7EiAGTBpDU2
         C7rmJVBt+iwv6clFOoPnvdNWDa5cJA2sBmra8EuBIcT/IiVnZg6EE5oRXOH3ZRon9e8S
         Z0GjwSoFi9tLnO97CO0ukRnr2A5T5MOzFBUxCxR3HQ095ni8luWE5tsnOiXO0G41HAcA
         PsYUPmHGFgEfSRER5lYqp86bElq6Ou2GJN+gmYgYGbEJDh6RYpq5TBwwViCPViHNes1P
         tbxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Ja5wUa4h;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=IxHHHKuG;
       spf=pass (google.com: domain of prvs=105329df1d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=105329df1d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id m12si2052079ioc.15.2019.05.30.10.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 10:25:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=105329df1d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Ja5wUa4h;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=IxHHHKuG;
       spf=pass (google.com: domain of prvs=105329df1d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=105329df1d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4UHNJfI005963;
	Thu, 30 May 2019 10:24:47 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=yVqMKbVLVx/XNxTAag7lRIIZNSJ+Voj0UhYKwYYmDOs=;
 b=Ja5wUa4hKjbbzNkMqx7CYmgU930z2qtAX5ClA8liGP6ltXFux+t+HlMHjT2Ivq4ItaOb
 MCrq5vHAP0nKTBL7u09hHm5TEhlX5pDkoHCCreyGah2ryx9UMXEO8wtimMF/e+wfrDrt
 76zF6gYXJ/I2K54INX+ubExQI6rKTVLPUek= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2stj9w8a5d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 30 May 2019 10:24:46 -0700
Received: from ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) by
 ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 30 May 2019 10:24:46 -0700
Received: from ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) by
 ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 30 May 2019 10:24:45 -0700
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.173) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 30 May 2019 10:24:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yVqMKbVLVx/XNxTAag7lRIIZNSJ+Voj0UhYKwYYmDOs=;
 b=IxHHHKuGdQB8P97KbVvvr7chw+alfdSeL9Bd2yVi2NWakf0ZG1uhhydBvE74jrL+8fOTiwqvXmsCLG2DUY+gJk1DomhEKFTURrinnJC3oSyY9IOqrPEg2C6DlT2+XuZJnTC+SdZo5CLxkG26bCck/tbBba4u+ldP9FISEjV6nHo=
Received: from BN6PR15MB1154.namprd15.prod.outlook.com (10.172.208.137) by
 BN6PR15MB1441.namprd15.prod.outlook.com (10.172.150.149) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.17; Thu, 30 May 2019 17:24:42 +0000
Received: from BN6PR15MB1154.namprd15.prod.outlook.com
 ([fe80::adc0:9bbf:9292:27bd]) by BN6PR15MB1154.namprd15.prod.outlook.com
 ([fe80::adc0:9bbf:9292:27bd%2]) with mapi id 15.20.1922.021; Thu, 30 May 2019
 17:24:42 +0000
From: Song Liu <songliubraving@fb.com>
To: William Kucharski <william.kucharski@oracle.com>
CC: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "namit@vmware.com" <namit@vmware.com>,
        Peter Zijlstra <peterz@infradead.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        "mhiramat@kernel.org" <mhiramat@kernel.org>,
        Matthew Wilcox
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "Chad
 Mynhier" <chad.mynhier@oracle.com>,
        "mike.kravetz@oracle.com"
	<mike.kravetz@oracle.com>
Subject: Re: [PATCH uprobe, thp 3/4] uprobe: support huge page by only
 splitting the pmd
Thread-Topic: [PATCH uprobe, thp 3/4] uprobe: support huge page by only
 splitting the pmd
Thread-Index: AQHVFma7iu6PqkG6zkadRvREvp8axaaDg0iAgABpC4A=
Date: Thu, 30 May 2019 17:24:42 +0000
Message-ID: <564E2603-C77C-408A-9E51-B20266407360@fb.com>
References: <20190529212049.2413886-1-songliubraving@fb.com>
 <20190529212049.2413886-4-songliubraving@fb.com>
 <6D76CB61-CF13-4610-A883-0C25ECC5CFB7@oracle.com>
In-Reply-To: <6D76CB61-CF13-4610-A883-0C25ECC5CFB7@oracle.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:bc80]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bc89de3d-f609-49d5-3c25-08d6e523b3ce
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BN6PR15MB1441;
x-ms-traffictypediagnostic: BN6PR15MB1441:
x-microsoft-antispam-prvs: <BN6PR15MB14419B67E977B6C45A755814B3180@BN6PR15MB1441.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 00531FAC2C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(376002)(39860400002)(366004)(396003)(189003)(199004)(6512007)(256004)(6436002)(76116006)(73956011)(186003)(229853002)(6246003)(8936002)(7416002)(6486002)(99286004)(66946007)(4326008)(91956017)(102836004)(53936002)(6116002)(66476007)(66556008)(64756008)(66446008)(57306001)(33656002)(25786009)(478600001)(14454004)(6916009)(2906002)(36756003)(76176011)(6506007)(486006)(8676002)(86362001)(46003)(7736002)(50226002)(54906003)(5660300002)(68736007)(4744005)(53546011)(71200400001)(81166006)(81156014)(476003)(2616005)(446003)(11346002)(316002)(83716004)(82746002)(305945005)(71190400001)(14583001);DIR:OUT;SFP:1102;SCL:1;SRVR:BN6PR15MB1441;H:BN6PR15MB1154.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: gP/dd2a2N4q5o2sBPjM+mn7HBWbn3a0fvTgh8Flq39DKJ75YxDdeEi8CGjKVZIr7N1OsnkDikyTHR9JHKHW1iOKF633EWcjZv9E0+nHF2NRn6+7uvPnYG+MIhrzQ2tDu8AHmeDEULspgHrvpsVPNyq60T4Myp7G8vZmI3oTyxq+cVQHHVJFHo0K0oShsz9k3c4yNSGHJgp9HyvxpyFvqnY5iJO+cuIaX7BiJH5MvoSLHHC23uT1EwKApTx41C0lIlRqCWtmicBz8IPXeGRg6+QNmxzfCYQL4vV/LheofT2yPq+ZVwwMWsSh2js1QxiuPkwCkb44tmAc93pmWk6hN6EIq/MdYryvH9fPL7zfRqQdRHfg/AnpuziCAxLcmCxRalHq33SF6ZPU5z8a2JUXK+42Dc5uFAs6hvucqg6Jgxj0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2AC4C67832FD484DB240662BBA37899A@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: bc89de3d-f609-49d5-3c25-08d6e523b3ce
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 May 2019 17:24:42.0515
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR15MB1441
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-30_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905300122
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On May 30, 2019, at 4:08 AM, William Kucharski <william.kucharski@oracle.=
com> wrote:
>=20
>=20
> Is there any reason to worry about supporting PUD-sized uprobe pages if
> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is defined? I would prefer
> not to bake in the assumption that "huge" means PMD-sized and more than
> it already is.
>=20
> For example, if CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is configured,
> mm_address_trans_huge() should either make the call to pud_trans_huge()
> if appropriate, or a VM_BUG_ON_PAGE should be added in case the routine
> is ever called with one.
>=20
> Otherwise it looks pretty reasonable to me.
>=20
>    -- Bill
>=20

I will try that in v2.=20

Thanks,
Song=

