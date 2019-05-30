Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D986FC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:27:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83D6F23AA3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:27:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="RxGK/uFy";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="eDBovvm1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83D6F23AA3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35D676B026E; Thu, 30 May 2019 13:27:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30F3D6B026F; Thu, 30 May 2019 13:27:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FD916B0270; Thu, 30 May 2019 13:27:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 051186B026E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 13:27:25 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id s83so5279638iod.13
        for <linux-mm@kvack.org>; Thu, 30 May 2019 10:27:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=9U3qrZ3RryzWGHqSkFT9H2WatAYQxpSDV8ga1mgvl8c=;
        b=GAAeMhycXJIzCMze9yxn+i0i/mOEiGekDl+or/0AhtgDnwmBeOqqC13r83ER4qyet9
         5Bjy4XCYJZ18bXvh5DF1K2cWkONLpCw465A/0xXy37UV39LG2d5cC8XAw8NfBR2PoEAB
         /9oC4IKB+j9AzmJOo7mEkUDg+1W9X76tTaZoKQofdDalWNjy6caenYKY1aWfU0DLgXz7
         YdoC8Zm5Wn+sKi0vkcYyl4Fx8rOlZ6Sx9ff2preMD4Dq2hXp8D4S9bXC2B4HJVF+DsIA
         RV4nhMYRxG+E+G5XNjdnTgyUAbE9WzvvATqAInn9rdGNzmquPDg9RWm1i+3T9GAy8p/k
         QoBQ==
X-Gm-Message-State: APjAAAXGR8U9JYfGvPnc4JdMwAzvs+uVmXSgfplEP0DlrhYcEAGON5ul
	1Xmr8gLdp8X3WnYynkWLsiDiNRON8Mqwnme8m9hHn1L0MsaBrtshsXt+CLL7kTK1Zyk8WFd8ZW1
	ULPPmHDjcCzPeHqTMf+e62CV/7m/xxhATcEmR6fGWUnxMz2zv0zRgJNvksBaXiDxK6A==
X-Received: by 2002:a24:910b:: with SMTP id i11mr4096904ite.76.1559237244822;
        Thu, 30 May 2019 10:27:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHP7QkEpW10G2fZzKyS+SLC67l4cH8s7qCBlAPT+EQcToAT7MmgZnv7yfln0DCYefin+nW
X-Received: by 2002:a24:910b:: with SMTP id i11mr4096862ite.76.1559237244122;
        Thu, 30 May 2019 10:27:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559237244; cv=none;
        d=google.com; s=arc-20160816;
        b=SH0GjXyKwQDt9qNyCtzvE5BRmMmwfta+3SRy5rlWrQrWaXpcfD/MXDPy4UeFe3agX/
         k/aYhO+nQFpRNinBSixw99WFo87Dc2skA7S9c6tqXt4bmRfjjWweROXekYSrm9gjjnhv
         dBXAKQrbVQlRWe9vOJkN1AbP7TdlNBeArgFrfWE+9V5/qF9a0jV+jsRMoADL+I7H2Hj/
         hJiwpfRVq5yoAGbz673FPzbrJm06FdN3oXP3Zh52vSdXGRqFoXBeZMff1Yi6NBBu0fI7
         NS+PP4/XQV2hKNYjGvyL79hMCGCTmqLF1oR6aoXTt1e17WxpMu3UeheDdp3hK9+vUAi5
         jjQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=9U3qrZ3RryzWGHqSkFT9H2WatAYQxpSDV8ga1mgvl8c=;
        b=AWOltiF2EsM/fPOPSGqY0cEj7vTFt6dwEKkqpG+8c/H4wYbf60uBgaayEwAOIskoCe
         18c8qWXHYg8KeL3Sscjv6Zi3R6muokS/UBNGWy+5ZRjbYEQIy92zQO9IY40+JHDctuXz
         sL6EemmfS2pZkUm3C55qlBNxnwEfxKqI5cL7yNGApDyqvuYq7PWQ5R9wGaW/A8To0dUW
         16AoTcOGZP5NieyqLX9kO+VrZSB/9teQWeYCBfCiCu0zN6LM8iFuUjXp+zI3AQ7rnE/2
         D/srMQ+5ZKzYJFJsuzDiw/Rcln8j7OyiD0sdbeBQopJPgaIpDiQgyEKVOtv0siBAh+F1
         jnDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="RxGK/uFy";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=eDBovvm1;
       spf=pass (google.com: domain of prvs=105329df1d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=105329df1d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id i16si2273896ioo.96.2019.05.30.10.27.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 10:27:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=105329df1d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="RxGK/uFy";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=eDBovvm1;
       spf=pass (google.com: domain of prvs=105329df1d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=105329df1d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4UHNH4H005940;
	Thu, 30 May 2019 10:27:01 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=9U3qrZ3RryzWGHqSkFT9H2WatAYQxpSDV8ga1mgvl8c=;
 b=RxGK/uFyepKW2OcaM88QZjGOteO2TwGkKbUBcscndBF+gJjgqe2zHBqckpXAC0xHwAxz
 SEJKdWlF6/e05nRkgEMN3VwLDQdK/5xLWgGqdQH61q2iZHUJOKuG87AssGVr/cmZOXDw
 giFrG83h3hPmRN0x+ojy5tTn7yD+uV3VbMg= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2stj9w8adh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 30 May 2019 10:27:01 -0700
Received: from ash-exhub204.TheFacebook.com (2620:10d:c0a8:83::4) by
 ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 30 May 2019 10:26:57 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.100) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 30 May 2019 10:26:57 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9U3qrZ3RryzWGHqSkFT9H2WatAYQxpSDV8ga1mgvl8c=;
 b=eDBovvm1UNpINdHG75i95BFebOLVcIGUHKHpQZMWiWvJwgyxqmCXylBzfUSos18XBqPjHTQWeAdqz557qQjONxeG21HwKk18olJTO05F/AynWV+bVPpKp4tAQoULVz/qU0Hf0PUkzwxsYYlBlYqS7Yx+Q0C7Q1OmRrxtJ9dPiuo=
Received: from BN6PR15MB1154.namprd15.prod.outlook.com (10.172.208.137) by
 BN6PR15MB1857.namprd15.prod.outlook.com (10.174.113.139) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1943.17; Thu, 30 May 2019 17:26:38 +0000
Received: from BN6PR15MB1154.namprd15.prod.outlook.com
 ([fe80::adc0:9bbf:9292:27bd]) by BN6PR15MB1154.namprd15.prod.outlook.com
 ([fe80::adc0:9bbf:9292:27bd%2]) with mapi id 15.20.1922.021; Thu, 30 May 2019
 17:26:38 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "namit@vmware.com" <namit@vmware.com>,
        "peterz@infradead.org"
	<peterz@infradead.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>,
        "mhiramat@kernel.org"
	<mhiramat@kernel.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "chad.mynhier@oracle.com" <chad.mynhier@oracle.com>,
        "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>
Subject: Re: [PATCH uprobe, thp 4/4] uprobe: collapse THP pmd after removing
 all uprobes
Thread-Topic: [PATCH uprobe, thp 4/4] uprobe: collapse THP pmd after removing
 all uprobes
Thread-Index: AQHVFmai8W5Yq1+OvE6IJWAoNhoGxKaDl3SAgABVaoA=
Date: Thu, 30 May 2019 17:26:38 +0000
Message-ID: <4E8A7A5E-D425-40EC-B40A-7DA21BA1866F@fb.com>
References: <20190529212049.2413886-1-songliubraving@fb.com>
 <20190529212049.2413886-5-songliubraving@fb.com>
 <20190530122055.xzlbo3wfpqtmo2fw@box>
In-Reply-To: <20190530122055.xzlbo3wfpqtmo2fw@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:bc80]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 87e47887-e2ce-48d5-6d68-08d6e523f91f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BN6PR15MB1857;
x-ms-traffictypediagnostic: BN6PR15MB1857:
x-microsoft-antispam-prvs: <BN6PR15MB185740D059C650658FB05523B3180@BN6PR15MB1857.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 00531FAC2C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(396003)(346002)(39860400002)(376002)(366004)(189003)(199004)(64756008)(50226002)(46003)(81166006)(66446008)(4744005)(316002)(6506007)(53936002)(6246003)(14454004)(6512007)(8676002)(478600001)(4326008)(2906002)(91956017)(73956011)(66476007)(76116006)(66556008)(5660300002)(305945005)(7736002)(6116002)(25786009)(66946007)(14444005)(476003)(68736007)(71190400001)(54906003)(86362001)(99286004)(71200400001)(83716004)(229853002)(446003)(2616005)(53546011)(11346002)(256004)(6916009)(8936002)(486006)(102836004)(76176011)(33656002)(36756003)(57306001)(6486002)(81156014)(186003)(6436002)(7416002)(82746002);DIR:OUT;SFP:1102;SCL:1;SRVR:BN6PR15MB1857;H:BN6PR15MB1154.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: cg38ktuGDSdnLQFnRRwOCu9VhGBUi85YIRwrbqiVzceEdEX+l+3ZTiWgOFb4Z2uyN5snafUqSPH0LzJIOj+rhttcHeobAYED0k+AqOqpM4oADMZSclCZvCSuFHJiaEzxH4TJLC3jdJEWZB5996OslEDQUYEy4vbKM9DHzUrGwUTOZX9oRiywyLHkQGkFVrkN0wZgvKHsYVxePRyHu9gLFmAv2MdA9ieJrLJZyS4ruHTk25nt1tmjeoL/mDcP7jLv6GgVAvlN8ej4pLQFAST0DdCNnBfn1Qi0ptdu0RskSmUzGZDG54cAFEaMFdoFFsWpT/tyZ1L8CQq1dhlD4xWHwJFHxu4mOgnUXK05a70DJrdgE7L5BcoKArWYVnAM6lVgxigCkaPuXuKIpX27j2+2RSZFk4Es7ulatm/rIfgWah0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <717A3B52E0DEBB468BE5462786ACC0C7@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 87e47887-e2ce-48d5-6d68-08d6e523f91f
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 May 2019 17:26:38.2213
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR15MB1857
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-30_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=659 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905300122
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On May 30, 2019, at 5:20 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Wed, May 29, 2019 at 02:20:49PM -0700, Song Liu wrote:
>> After all uprobes are removed from the huge page (with PTE pgtable), it
>> is possible to collapse the pmd and benefit from THP again. This patch
>> does the collapse.
>=20
> I don't think it's right way to go. We should deferred it to khugepaged.
> We need to teach khugepaged to deal with PTE-mapped compound page.
> And uprobe should only kick khugepaged for a VMA. Maybe synchronously.
>=20

I guess that would be the same logic, but run in khugepaged? It doesn't
have to be done synchronously.=20

Let me try that

Thanks,
Song


> --=20
> Kirill A. Shutemov

