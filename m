Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BDFDC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 06:32:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C77C20656
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 06:32:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="LCuuA8yK";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="toe00VUw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C77C20656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA87B8E0003; Thu, 27 Jun 2019 02:32:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5A2C8E0002; Thu, 27 Jun 2019 02:32:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF8F18E0003; Thu, 27 Jun 2019 02:32:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 98D568E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 02:32:06 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id f11so1796555ywc.4
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 23:32:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=h8pU6xF38JB3r9LlEsuLt4wH985rRUbhoyuS6lhAxts=;
        b=JRYMB3nZq2LZ4nRWiMwfIAwboPP75r08gujCn3OMG+jSkcDQFMQmxRp0kTcNg+z1K2
         T5+si2zMFepFKItUz2CUTSkcm/RAqcO/5DAjp4O+mGT2PfGV0ZwEVOmPbIMbWIfdHLA4
         rcWtIwk1xc8WO8r1kNCSEws/IXh+ZwXV2PVvBMJV0n64RxX0ux7xDUrw5cZTXwhZdpQj
         fRQ3U2lF0sRkt5DTfFWriHILal96De2nc/jybWjQoGTaJRZCIzbPwTa4i9F2TSt7UiCm
         Co+hovGCEfnNgVNRuJREwX3FeVq4nCtfPFRPIlPsue0T8+Ja9bfUt/fwmosRkjaCGSdJ
         OHNQ==
X-Gm-Message-State: APjAAAVjGpVxbE9+4TBUrEIXQGY97G2pp4KzqcwsAVm71znhCv8Dz9c+
	mC8LXXUsCxuwM3otI9beicrGo2pZ3VmIWaa0CpDn6kbpMT3GSTvt5/6BRpIC35zMyc8nNKnFWFG
	HWKXC889pMlyuvn1XC2jXquf5gvnaT0DH/JWZSdtA1++fdX0lzP2+hm2hMlOivvNyVw==
X-Received: by 2002:a0d:f944:: with SMTP id j65mr1130910ywf.331.1561617126260;
        Wed, 26 Jun 2019 23:32:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzk8tn8bDyXnlzmNtbjL9Px8catzF1+q749bMW4EMRV2STAG0BnFn3xHMIa/ek3M6lzI0mf
X-Received: by 2002:a0d:f944:: with SMTP id j65mr1130885ywf.331.1561617125640;
        Wed, 26 Jun 2019 23:32:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561617125; cv=none;
        d=google.com; s=arc-20160816;
        b=u7qEj/COrpvAQFeP4g5lC0W3QtD1lYXaAlX4yWUj9eFt+lyrrSqOVQjn8+momvrzl9
         d5MNpxiPDHjIjz88dCGXek9JqUpx6pz0Wy4kfilGncN33U0aGPo9E3SubWb4akLCE2GC
         vLYdKWyN6uu7xy4+kXEFlsafLyVODenx3XuuMEiwcm8YFTqw8AVvK6dAj+yK/i/YPjIA
         t6JEgRvTA1HqW5zzGveHWX3Il9Gi24/PkgYnYGZyhKPU4lE2Bslm3+iCo8aNTWeTFJbY
         IWHB6I6bGgqaDUK8HNK5gB1081/pX0tmgAeuTaCMEmM5ieKjRXRdxpJ5lphaXqGGw6jj
         qisA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=h8pU6xF38JB3r9LlEsuLt4wH985rRUbhoyuS6lhAxts=;
        b=erdIkp/foA+/MnIvhlIT/CaAX0uNvXfZl2DVTB4sYjItkEXoLVwCHdf8sgE+BPDWqa
         Zwo8LPRAno3PBp7JbisGmZ6FP8h0TzIBQiBWirRm61qvkRSzq3NlxVZ1NUO1pjBDRmUt
         9HROIVUV7CyLN1ugjGqObDTRujMJOaH6y8cvgHRmfncvTDKNeZh0Vu4ABA3yG38AMaYz
         eHV+mNfhsDRkt4gb/qgUjKNtEORIPoLIj1aqwDdwfEqRjHcG/z+SajoR9GOOMokClgXF
         4dqA7FaS1kUfkSPcyUO2TvaM0+xz2NWzhKBW9Aj8Z5UnC1eQzaHsj557HWwjyqVzDRKg
         EM6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LCuuA8yK;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=toe00VUw;
       spf=pass (google.com: domain of prvs=1081063969=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1081063969=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l20si472826ywc.428.2019.06.26.23.32.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 23:32:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1081063969=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LCuuA8yK;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=toe00VUw;
       spf=pass (google.com: domain of prvs=1081063969=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1081063969=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5R6UKfm025319;
	Wed, 26 Jun 2019 23:31:29 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=h8pU6xF38JB3r9LlEsuLt4wH985rRUbhoyuS6lhAxts=;
 b=LCuuA8yKcAhk7DukG7j+j0QQSZ8q3DLfcshEEep9vv5NPQj6/TfmwTQXEdRMMdc8+L8C
 syHsc56iIFIJeos5/pd/T4RwNqIRvokxaV+qpjOoQpiEobrLZCcTFf7l8MDCdk7u6xAm
 YIqBqf9+21IefoSpZRdpVBm6UA+jk7hhYtY= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2tcgav9h16-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Wed, 26 Jun 2019 23:31:29 -0700
Received: from ash-exopmbx101.TheFacebook.com (2620:10d:c0a8:82::b) by
 ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 26 Jun 2019 23:31:28 -0700
Received: from ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) by
 ash-exopmbx101.TheFacebook.com (2620:10d:c0a8:82::b) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 26 Jun 2019 23:31:28 -0700
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Wed, 26 Jun 2019 23:31:28 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=h8pU6xF38JB3r9LlEsuLt4wH985rRUbhoyuS6lhAxts=;
 b=toe00VUwFum1VsoZ3radHSBd36BaaFmuWFVSXLilMCk8VKR/ONCp9SX6mIM/jGMSHaDWEUTY4ufzs05lbfl9yrcdR5IMpz8/6MDdDTUHk8GJmiJ0LbaoB3oKNqiGHfe9fyv4r9Kem294GxflBANlbOetF17rgRKBtXDmlhFU6ug=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1951.namprd15.prod.outlook.com (10.175.9.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Thu, 27 Jun 2019 06:31:26 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.018; Thu, 27 Jun 2019
 06:31:26 +0000
From: Song Liu <songliubraving@fb.com>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>,
        Andrew Morton
	<akpm@linux-foundation.org>
CC: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        Matthew Wilcox <matthew.wilcox@oracle.com>,
        "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>,
        Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        Kernel
 Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com"
	<william.kucharski@oracle.com>
Subject: Re: [PATCH v7 4/4] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Thread-Topic: [PATCH v7 4/4] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Thread-Index: AQHVK7E785+oCFqbhUC2jl0BeioYsaatcZEAgAGa74A=
Date: Thu, 27 Jun 2019 06:31:26 +0000
Message-ID: <AE9CD0A1-14EB-4919-B14F-23B077C57891@fb.com>
References: <20190625235325.2096441-1-songliubraving@fb.com>
 <20190625235325.2096441-5-songliubraving@fb.com>
 <20190626060038.GB9158@linux.vnet.ibm.com>
In-Reply-To: <20190626060038.GB9158@linux.vnet.ibm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:6ea5]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2880b3e6-e60d-4289-66fa-08d6fac914f6
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1951;
x-ms-traffictypediagnostic: MWHPR15MB1951:
x-microsoft-antispam-prvs: <MWHPR15MB1951FA57F2B389231202505BB3FD0@MWHPR15MB1951.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 008184426E
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(39860400002)(396003)(366004)(346002)(136003)(199004)(189003)(68736007)(53546011)(6506007)(76176011)(36756003)(305945005)(8936002)(7736002)(6246003)(6486002)(186003)(6436002)(14454004)(229853002)(57306001)(4326008)(66446008)(64756008)(66556008)(66476007)(73956011)(102836004)(76116006)(316002)(99286004)(54906003)(110136005)(66946007)(25786009)(6116002)(4744005)(33656002)(5660300002)(50226002)(86362001)(8676002)(81156014)(81166006)(478600001)(6512007)(2906002)(71190400001)(71200400001)(53936002)(46003)(7416002)(11346002)(2616005)(486006)(476003)(446003)(14444005)(256004);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1951;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: hG+2Udvs0PDKgyESMlOCFnBsWbcJUdh09mID884t3JnFcFu/jA/TjncZLvFQdHNNnKWYBwaHAxPehm1Z9VE8rcb3peOPA7WQwUrHI4kjMeAGGc4MqPpda0vG/sJjnGj8M7II1cbaWqo+1w6v7bayVexgqKj40ex4601kULRxPSyYvypBKK5FshLHpXNlQEh4O7lv8Kxw7jqCV1cgEtw+eOvlBWjA/VaskOwJGB+QyNelqgU1zHHKcM466m3D0Vq0qO9Nk00AVDuxc24hTPWs9WXFnzAx4grh/+gxo9tKWC3MFMojV+PrvN7UPOlmcPvl4WoMVyAtqODGtQgUvw06JOfqKarmVGkuIwUznAXrbw79N/KwX3wgSY8YDwK1nX/hwsn7cSxunE1Y4DEJXFvcA4CJ96XqSQ3PkswPnz2tYXs=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <902646C75C382B46BB3D455B995697F5@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 2880b3e6-e60d-4289-66fa-08d6fac914f6
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Jun 2019 06:31:26.5305
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1951
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-27_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=954 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906270074
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 25, 2019, at 11:00 PM, Srikar Dronamraju <srikar@linux.vnet.ibm.co=
m> wrote:
>=20
> * Song Liu <songliubraving@fb.com> [2019-06-25 16:53:25]:
>=20
>> This patches uses newly added FOLL_SPLIT_PMD in uprobe. This enables eas=
y
>> regroup of huge pmd after the uprobe is disabled (in next patch).
>>=20
>> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Signed-off-by: Song Liu <songliubraving@fb.com>
>> ---
>> kernel/events/uprobes.c | 6 ++----
>> 1 file changed, 2 insertions(+), 4 deletions(-)
>=20
> Looks good to me.
>=20
> Reviewed-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Thanks Srikar!

I guess these 4 patches are ready to go?=20

Hi Andrew,=20

Could you please route them via the mm tree?=20

Thanks,
Song


