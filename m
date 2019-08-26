Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBC24C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 20:51:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 711422186A
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 20:51:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="BYXF20Pr";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="KKdiVhle"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 711422186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A1666B0281; Mon, 26 Aug 2019 16:51:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02ABE6B0283; Mon, 26 Aug 2019 16:51:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0DB96B0284; Mon, 26 Aug 2019 16:51:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id B903C6B0281
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:51:08 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 59635283E
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 20:51:08 +0000 (UTC)
X-FDA: 75865773816.18.jail68_6123f1c5c034b
X-HE-Tag: jail68_6123f1c5c034b
X-Filterd-Recvd-Size: 11508
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 20:51:07 +0000 (UTC)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x7QKoOYU013342;
	Mon, 26 Aug 2019 13:50:30 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=leA6kH0S+7OHIoKpl8dwRnx9oZdlUtLmMoAsl686Nkk=;
 b=BYXF20PrELut2ZzQU+4e50Is9jxIkzpjFPIw2ZC4+0lRTZhUfSnpinPSWfhjSSX0HRGP
 mlVlMlKB9zVbB/2y29gxa1s0XqC1etBtY5RDKvCXdLATRTaZ01CxQtppuZvNfpOg+b9L
 scW4SBKqumEDLrQKTGyKHyjtseJbnI1hIIQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2ukmxbe3cb-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Mon, 26 Aug 2019 13:50:29 -0700
Received: from ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) by
 ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 26 Aug 2019 13:50:03 -0700
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.101) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Mon, 26 Aug 2019 13:50:03 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=QWpaIBmYVrs6CMi1Lbk00y1VSCjNP9tDjqwnPA8XpS6s554j5GBYAiIQWqs/MZA+8SBJsiUoUM2gvaCuiMV/gXhgIc390pLIRdLlqu9MxsHVwwo0V178s4TsJJpul9PWzgEpztwSIwbeozzRgmZzPACR9DsbC3ieoFbjBpbV9P60fz/SxcUnrH+0iVLve+XFQldblVT2AwHo7ETRt3Xx+7TBptOUkI2GsI+aklh9hb4hdP2CmlazebIaCNJ+92E7KS+HZRIb1HxBxWhZ8fmr03i6+FmE4iYMRUb6iW575DRMrmeT1H4BiHPzfxUMjoTj7s8pMz0+Oh5C40cjkgjJpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=leA6kH0S+7OHIoKpl8dwRnx9oZdlUtLmMoAsl686Nkk=;
 b=DXhmaR4LmXOOspdidSL4M7imFOeMOAyP2ZNUSFSvXA2BUtizyIAfb2uJO05kIUIdU01TNH/NLKzuf0ENGQrntlveBeuHiWz/oTEnlu+mu2ZHx7tcjCsdWCR5OBDnr/Rpl0L2Ox2rG/2WFhUBmGRbeV/ww6VYgwNOgSacyml35S+7uOFWem8rFfyTafakayRqn3SIcz407MP2Pw78zKf/8I2FGnidLnuBdy8q8JX0FtkgMrfJfRTLRtlvpxFSiM1kSR2a9BBSRy5JxeUACdIhyu0oKcEkFxfQvpWGkDED1pgy0GEiTUU3glLIqfN0GCDAEjWZB6Tef5+fHnSJas9boQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=leA6kH0S+7OHIoKpl8dwRnx9oZdlUtLmMoAsl686Nkk=;
 b=KKdiVhleEC78D/OTNEG0pnhnxf1hvAHeOWIoVmstDEgB4os3xWVvWmbDdJiXjtFPJfADJafdzVfjFWUqXzhGFnwIPFo059S2fZasyLg7P9+sDQ4x6t38DA6g2XeY21p10++s3Ymez+kn8IWllYBqy6lLZ4Zv5D9JGm3yfIpu2wM=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1806.namprd15.prod.outlook.com (10.174.255.23) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2199.20; Mon, 26 Aug 2019 20:50:02 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::45ee:bc50:acfa:60a5]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::45ee:bc50:acfa:60a5%3]) with mapi id 15.20.2199.021; Mon, 26 Aug 2019
 20:50:02 +0000
From: Song Liu <songliubraving@fb.com>
To: Peter Zijlstra <peterz@infradead.org>
CC: Steven Rostedt <rostedt@goodmis.org>,
        "sbsiddha@gmail.com"
	<sbsiddha@gmail.com>,
        Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>, Kernel Team
	<Kernel-team@fb.com>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Dave Hansen <dave.hansen@intel.com>,
        Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH] x86/mm: Do not split_large_page() for
 set_kernel_text_rw()
Thread-Topic: [PATCH] x86/mm: Do not split_large_page() for
 set_kernel_text_rw()
Thread-Index: AQHVWXL45hcGbMxBFEmxITCR8fhmlKcIeZ6AgARkOQCAAE74AIAAYJqAgABfWYA=
Date: Mon, 26 Aug 2019 20:50:02 +0000
Message-ID: <28DA9193-BD70-4B81-B1A9-98BC3E8BDDFA@fb.com>
References: <20190823052335.572133-1-songliubraving@fb.com>
 <20190823093637.GH2369@hirez.programming.kicks-ass.net>
 <164D1F08-80F7-4E13-94FC-78F33B3E299F@fb.com>
 <20190826092300.GN2369@hirez.programming.kicks-ass.net>
 <0A94F7AA-7ECE-4363-B960-41F644CFE942@fb.com>
In-Reply-To: <0A94F7AA-7ECE-4363-B960-41F644CFE942@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::1:73d0]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d039bacc-b2a7-45b9-33e6-08d72a66f778
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1806;
x-ms-traffictypediagnostic: MWHPR15MB1806:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <MWHPR15MB180624722674ABE7AD005645B3A10@MWHPR15MB1806.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 01415BB535
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(376002)(396003)(39860400002)(346002)(189003)(199004)(476003)(11346002)(14444005)(2906002)(71190400001)(6436002)(256004)(446003)(91956017)(76116006)(5660300002)(66946007)(66476007)(66556008)(64756008)(66446008)(71200400001)(53936002)(316002)(486006)(6506007)(81156014)(6512007)(14454004)(4326008)(86362001)(25786009)(478600001)(57306001)(6486002)(99286004)(50226002)(7736002)(36756003)(46003)(33656002)(102836004)(305945005)(186003)(6916009)(8936002)(8676002)(2616005)(81166006)(229853002)(53546011)(54906003)(6116002)(76176011)(6246003);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1806;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: ninTDdRKKGOgVNgYLbUNG5ZBX2ozqDh2VywvmC6NOOlqIBdB64vxXdc7xqqmLLan2U9WvMF7mIaV/3HK8RENoLvZEeFPLdraDLhD1ATE4WiJ+5m35GyUjw5cJoNNH8BuYznjTJ+ZEuzb8rp4sDACZzlmcCfEI7EBU8zqfVQ2+csOWKtKAyRSlV861Fe6ufT+WfSi9i2sujP82Wonsy+S+QqimQ5zpwR1ej1VS+OLHeE8qkILQUG+e0JUv0TIXQpuFOlAU4LzVGgAuCo7l2BZcS79PsAh0e5w6pUD1ZXfCBBoxLXBhcCMJ7yqHXuq28LSSJBmUe3FvwbxThwXBejQTk604SMyu0f3LGVSK+oFH8TY7zFTfHmxFtaRhGr5/kj9SKu/3zv8cpQe3mVrAOBpL6aCGP1lr63Jmlmze8Cyw6A=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <9D2E2E6015FEFE4CA52E5932D281EA5E@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: d039bacc-b2a7-45b9-33e6-08d72a66f778
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Aug 2019 20:50:02.1246
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 4ML9PNjmsaE2juQkZTgKsJhzM6MpFq4+aTR9UjciuXp8+34cCcowfKKPQSHNE86PJYI4ysQ2fudYI0aQeU4aRQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1806
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:5.22.84,1.0.8
 definitions=2019-08-26_08:2019-08-26,2019-08-26 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 mlxscore=0 clxscore=1015
 bulkscore=0 mlxlogscore=999 suspectscore=0 adultscore=0 lowpriorityscore=0
 malwarescore=0 priorityscore=1501 phishscore=0 spamscore=0 impostorscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-1906280000
 definitions=main-1908260195
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 26, 2019, at 8:08 AM, Song Liu <songliubraving@fb.com> wrote:
>=20
>=20
>=20
>> On Aug 26, 2019, at 2:23 AM, Peter Zijlstra <peterz@infradead.org> wrote=
:
>>=20
>> So only the high mapping is ever executable; the identity map should not
>> be. Both should be RO.
>>=20
>>> kprobe (with CONFIG_KPROBES_ON_FTRACE) should work on kernel identity
>>> mapping.=20
>>=20
>> Please provide more information; kprobes shouldn't be touching either
>> mapping. That is, afaict kprobes uses text_poke() which uses a temporary
>> mapping (in 'userspace' even) to alias the high text mapping.
>=20
> kprobe without CONFIG_KPROBES_ON_FTRACE uses text_poke(). But kprobe with
> CONFIG_KPROBES_ON_FTRACE uses another path. The split happens with
> set_kernel_text_rw() -> ... -> __change_page_attr() -> split_large_page()=
.
> The split is introduced by commit 585948f4f695. do_split in=20
> __change_page_attr() becomes true after commit 585948f4f695. This patch=20
> tries to fix/workaround this part.=20
>=20
>>=20
>> I'm also not sure how it would then result in any 4k text maps. Yes the
>> alias is 4k, but it should not affect the actual high text map in any
>> way.
>=20
> I am confused by the alias logic. set_kernel_text_rw() makes the high map
> rw, and split the PMD in the high map.=20
>=20
>>=20
>> kprobes also allocates executable slots, but it does that in the module
>> range (afaict), so that, again, should not affect the high text mapping.
>>=20
>>> We found with 5.2 kernel (no CONFIG_PAGE_TABLE_ISOLATION, w/=20
>>> CONFIG_KPROBES_ON_FTRACE), a single kprobe will split _all_ PMDs in=20
>>> kernel text mapping into pte-mapped pages. This increases iTLB=20
>>> miss rate from about 300 per million instructions to about 700 per
>>> million instructions (for the application I test with).=20
>>>=20
>>> Per bisect, we found this behavior happens after commit 585948f4f695=20
>>> ("x86/mm/cpa: Avoid the 4k pages check completely"). That's why I=20
>>> proposed this PATCH to fix/workaround this issue. However, per
>>> Peter's comment and my study of the code, this doesn't seem the=20
>>> real problem or the only here.=20
>>>=20
>>> I also tested that the PMD split issue doesn't happen w/o=20
>>> CONFIG_KPROBES_ON_FTRACE.=20
>>=20
>> Right, because then ftrace doesn't flip the whole kernel map writable;
>> which it _really_ should stop doing anyway.
>>=20
>> But I'm still wondering what causes that first 4k split...
>=20
> Please see above.=20

Another data point: we can repro the issue on Linus's master with just
ftrace:

# start with PMD mapped
root@virt-test:~# grep ffff81000000- /sys/kernel/debug/page_tables/kernel
0xffffffff81000000-0xffffffff81c00000          12M     ro         PSE      =
   x  pmd

# enable single ftrace
root@virt-test:~# echo consume_skb > /sys/kernel/debug/tracing/set_ftrace_f=
ilter
root@virt-test:~# echo function > /sys/kernel/debug/tracing/current_tracer

# now the text is PTE mapped
root@virt-test:~# grep ffff81000000- /sys/kernel/debug/page_tables/kernel
0xffffffff81000000-0xffffffff81c00000          12M     ro                  =
   x  pte

Song


