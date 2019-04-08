Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB0E2C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 23:20:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B2E7206C0
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 23:20:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="WVOyTNzb";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="SaXxx9DD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B2E7206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C77F6B0010; Mon,  8 Apr 2019 19:20:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94E5C6B0266; Mon,  8 Apr 2019 19:20:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CA9E6B0269; Mon,  8 Apr 2019 19:20:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2926B0010
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 19:20:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 41so7803714edq.0
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 16:20:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=R5KmHGlX6NVqP1HVdkVvBxurQ3c+PPWd1dCpJKzJMKI=;
        b=jWWrMQaDdrc/iaJd/ycGSbg9F9RjZelghWOTY7MyKMlnGl6Tjtwam/SVRDHQM+CSAx
         cCa1g3SpWfg8RNsIzKseSCi6YtaeAsRUS+eNofXSmszRM7WGYYvSKI6ZUzkIOWGZHc3D
         qSK+sY9UoYwQ5fQ5YvMjhNhGvlXdabap1wdfi+EtXl94wH4UYWKgWu4r5AOz4qucH0me
         SwcOk6Jk+62LRrI/JsxekUM3QhGlhVdIbJfCcF2U6Qmn0yIcEX66gnjV3QpSzRtFtYT6
         uUSjHLDUkLm290mKczttwwONaluDn4XM5+jbyKjNTroHB8o1vSyVvkoDry2qaPNemP9T
         mUug==
X-Gm-Message-State: APjAAAXcFwkUQJtVsfVTzWhBc4UnJh2m0cLyJhqwcOTswraUyDYfI66X
	c+UdkJSiu6n/JgbuMLdGBZ/paWd7mTrZaEiRX0SZg1t4TLo24qb19pniSlwdglwAJyF96kpaxux
	Gny8IGKIsh5Hj2ySp1LfsD4P0nyaODuPgyYaFHrf9ACAC5aSXqmzT/kZmS1MjfzWFyQ==
X-Received: by 2002:a50:aa31:: with SMTP id o46mr20088746edc.6.1554765619626;
        Mon, 08 Apr 2019 16:20:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw974id9uO1jrlbKrJJvtKg6gr+v+4z2OVlIA1oAEpo0Ay4IvSAtKRPhrfb1NAwzXQIK/v2
X-Received: by 2002:a50:aa31:: with SMTP id o46mr20088708edc.6.1554765618745;
        Mon, 08 Apr 2019 16:20:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554765618; cv=none;
        d=google.com; s=arc-20160816;
        b=U2s9qxc32Cv2zxi/g5B7MuSASD3fzLSOKwkhys8e2NZM6DTQj/CHPxHPR2BHdDUE3L
         xnFBQGEtUtBmcXVFDhAMqk62G8EgBr6FV1oLxw8x18cqJISyqg7O2WSpeA6rYT5pSqeB
         rReRkhBTtQ6+NeN3/4Sw9H66Hfny+pP+vSAzinx9Wm8xaSSC5p7kqmmFL5/Q3x+bKPod
         SYgB/WikAJIgV3Nh6usfKEWDOrLbDeTAoZva9XHPYEaq2wHL7Tr3MFpxp2fCqxiSd+Jm
         eyQOWFPheUYEv5YH/sbe/y8I9c/QT4vRNIWonyWDhYGj+2ftOiPnAc8R/DN5GhOKg5vR
         3FnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=R5KmHGlX6NVqP1HVdkVvBxurQ3c+PPWd1dCpJKzJMKI=;
        b=R6+yRKnLBcpBrsXiTpvJsjKd0FWLnRwOrz1q5RLKIxRkUnewyaqAqxHMrl9xsmYN3T
         3Z00nGsXq7h3zTch4OiUGPIux2kXbU9w/igeL88YWyaLG4bdXRMGtlB4bcdSAN+pRwNW
         gjkUMi4XlUug94PKU4N1yVj2aXNav9T5G5hzJGLxDfEnq2URuAbo55S2WbVKO3SfGqrx
         heVFjnt0PyYZuhNMiO+AB2rFojfwgHCe6l0M9LsjM1DEDWviGbux0R7mQ2nkfpqqdQQi
         v8XVFhrO8NXhtzPWnKAFLwYu4gT11kidMEWah44kxrxrsDMlcLY5fj3f2ddADjST3wpK
         b2lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=WVOyTNzb;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=SaXxx9DD;
       spf=pass (google.com: domain of prvs=90016e4aa1=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90016e4aa1=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f1si4434374ejb.121.2019.04.08.16.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 16:20:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90016e4aa1=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=WVOyTNzb;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=SaXxx9DD;
       spf=pass (google.com: domain of prvs=90016e4aa1=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90016e4aa1=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x38N9kWH000320;
	Mon, 8 Apr 2019 16:19:22 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=R5KmHGlX6NVqP1HVdkVvBxurQ3c+PPWd1dCpJKzJMKI=;
 b=WVOyTNzbCAH4RRDrLwAz4AeXF4sJDt80ByXJnV1oMB3e6FvjZZPkjh9knV9GIgIBIJ4U
 4E7MnO1qvp21H7mKUr9op9ECRf9jxYxrOgeIplPTHY6+kbDYZDlJSEipA1KdJ27neI6e
 D9chldNQNUzTsR9QVddIxTp0fGpvEUykRdY= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rrevrg705-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 08 Apr 2019 16:19:22 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 8 Apr 2019 16:19:13 -0700
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 8 Apr 2019 16:19:13 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=R5KmHGlX6NVqP1HVdkVvBxurQ3c+PPWd1dCpJKzJMKI=;
 b=SaXxx9DDfRi2NffLDj+uAD3Xe7LlE7crecyOpGZVSeHNc1bgpLxlDNT71CP3kNWmzCvTQf3mNghCp8YfiDyMKACeZmwEHiUqyHeIZsRjER6aqN44uKJB84Bw4YXMJKJYC9L0WtbBwRYNQO5XsWMO7VrEYF7zdhV9soZvtTkIOVY=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3397.namprd15.prod.outlook.com (20.179.59.30) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.13; Mon, 8 Apr 2019 23:19:11 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%3]) with mapi id 15.20.1771.016; Mon, 8 Apr 2019
 23:19:11 +0000
From: Roman Gushchin <guro@fb.com>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
        Matthew Wilcox <willy@infradead.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Thomas Garnier
	<thgarnie@google.com>,
        Oleksiy Avramchenko
	<oleksiy.avramchenko@sonymobile.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        Joel Fernandes <joelaf@google.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 1/3] mm/vmap: keep track of free blocks for vmap
 allocation
Thread-Topic: [PATCH v4 1/3] mm/vmap: keep track of free blocks for vmap
 allocation
Thread-Index: AQHU7KeAYDXmPyf7LE+XJfMAqtm1ZaYy6Z6A
Date: Mon, 8 Apr 2019 23:19:11 +0000
Message-ID: <20190408231905.GA31139@tower.DHCP.thefacebook.com>
References: <20190406183508.25273-1-urezki@gmail.com>
 <20190406183508.25273-2-urezki@gmail.com>
In-Reply-To: <20190406183508.25273-2-urezki@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR05CA0106.namprd05.prod.outlook.com
 (2603:10b6:a03:e0::47) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:d96]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: dd234fb2-fde6-4565-8e9d-08d6bc789b5c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3397;
x-ms-traffictypediagnostic: BYAPR15MB3397:
x-microsoft-antispam-prvs: <BYAPR15MB3397040140913949298BE58CBE2C0@BYAPR15MB3397.namprd15.prod.outlook.com>
x-forefront-prvs: 0001227049
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(376002)(396003)(366004)(136003)(346002)(189003)(199004)(6246003)(81156014)(446003)(5660300002)(6486002)(316002)(86362001)(9686003)(6512007)(8676002)(71190400001)(1411001)(106356001)(14444005)(105586002)(33656002)(8936002)(256004)(478600001)(97736004)(71200400001)(14454004)(53936002)(52116002)(6916009)(6436002)(81166006)(6506007)(476003)(25786009)(1076003)(46003)(6116002)(305945005)(486006)(7736002)(386003)(102836004)(68736007)(54906003)(7416002)(186003)(2906002)(229853002)(4326008)(76176011)(99286004)(11346002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3397;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: rz7Z00MrtDVwkgtEYDV/EcZaPtj8fx0jBlcdCb+fz13HSHlJFbXPBPxjHyeASjHRu5bWkLSU/sWSezG3hzwOxG8V0OrTrcWbEzkgBxnBHJuVWhXkLHfIu4YDC6GzqeoIujZkDlHqaHynqo2wWz2Ru9COPWY0V1rCqywS4GFZ8wq6QaDp4NQ6/70m4aEpj/I65GNX2dDcLVI9ihgxok1B63AoNLYNdGmFzn+wY+vTwm8zNzdvg3v8bJUvRSkcG/xGU9HgtK3+zlM9aDphzL4YoysWYuCY8gwbbk/2KKRZWPkUTuBYN46XD4cHWC2YrzS/r2f31EjpnkAvw3qWl5Pf/LnGPb/mY68+5/Oy2vS3IXD4N/T3K4rNAg0/cvTnfsBhCLXK95pJI+Sq3Xt+O4bVPOccHMqs52n4MCUPhpGUXmU=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <C4FA4A1AF8985F409BA7BA14D4B29AB2@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: dd234fb2-fde6-4565-8e9d-08d6bc789b5c
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Apr 2019 23:19:11.1888
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3397
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-08_10:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 06, 2019 at 08:35:06PM +0200, Uladzislau Rezki (Sony) wrote:
> Currently an allocation of the new vmap area is done over busy
> list iteration(complexity O(n)) until a suitable hole is found
> between two busy areas. Therefore each new allocation causes
> the list being grown. Due to over fragmented list and different
> permissive parameters an allocation can take a long time. For
> example on embedded devices it is milliseconds.
>=20
> This patch organizes the KVA memory layout into free areas of the
> 1-ULONG_MAX range. It uses an augment red-black tree that keeps
> blocks sorted by their offsets in pair with linked list keeping
> the free space in order of increasing addresses.
>=20
> Nodes are augmented with the size of the maximum available free
> block in its left or right sub-tree. Thus, that allows to take a
> decision and traversal toward the block that will fit and will
> have the lowest start address, i.e. it is sequential allocation.
>=20
> Allocation: to allocate a new block a search is done over the
> tree until a suitable lowest(left most) block is large enough
> to encompass: the requested size, alignment and vstart point.
> If the block is bigger than requested size - it is split.
>=20
> De-allocation: when a busy vmap area is freed it can either be
> merged or inserted to the tree. Red-black tree allows efficiently
> find a spot whereas a linked list provides a constant-time access
> to previous and next blocks to check if merging can be done. In case
> of merging of de-allocated memory chunk a large coalesced area is
> created.
>=20
> Complexity: ~O(log(N))
>=20
> Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>

Reviewed-by: Roman Gushchin <guro@fb.com>

Thanks!

