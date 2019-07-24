Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41E57C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:52:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BAFF21841
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:52:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="U/B4/BsH";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="m/tM6G9W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BAFF21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 130B48E0007; Wed, 24 Jul 2019 14:52:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E2FD8E0003; Wed, 24 Jul 2019 14:52:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC56A8E0007; Wed, 24 Jul 2019 14:52:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id CBAA48E0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:52:56 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id d135so35370576ywd.0
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:52:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=aa1yNHhGub2q5giAEw5YCf3oqlsTy4a2Ha1OCMwoAtU=;
        b=RnvLP4ySeMIj8n7hyE8n2YA09xi7tYHBl3J/Bdy7xJGEQ9RgXg/zOw10xWu/Q3BVTj
         GPPJU/3QiW3sAlLKDvw1MozhkA6X60n3VbSw0J5c01WX8DfziRwYurgI3AGOt/QlzLkq
         7FYSHbmaQotBq9bUM8qkAGzvpjm2p0RWrqsTOwxH4VDEcyD8quMC+7AreLigfTpwang5
         laNSAUpW7NXS+Ic+H7C915Udh9+/KUCdXJdJ30xAb6YErf9nAsa4eKHtnvbcB2cnAame
         i393ZF8z9Xz2AmvWbDz0TybeKFVd8QT3ljDIfCKO00NLKWoCOnXI7M8FbSppjlWBDRh0
         1fkg==
X-Gm-Message-State: APjAAAUp9ZMOYUFOE+HJLK7Mql8s0RHE9lRtKG0d7nuDxR1myVhyu9h9
	ts2xFDmL9x5QsUfUUff6NVR526Xqb4ttcxAfvZkYFZArUTb9gSmkUYBkDxrkkvM3qlvg8f2NFZ6
	gsUKnqKMzZPm5KbpBhUhjmUf0Vmfvpzh52TiFM78E1NhXkRokxs2xtCsHJQge80fWEw==
X-Received: by 2002:a05:6902:4e1:: with SMTP id w1mr45353355ybs.247.1563994376467;
        Wed, 24 Jul 2019 11:52:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAJCtS7daJMqss7cbEecE6G1h4awTN7aI6ggKWCwnViP4oKgdY8twbmxRrX1gqW0bEuUCd
X-Received: by 2002:a05:6902:4e1:: with SMTP id w1mr45353327ybs.247.1563994375750;
        Wed, 24 Jul 2019 11:52:55 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563994375; cv=pass;
        d=google.com; s=arc-20160816;
        b=yBlfA5T5d8EVcSLRk5bhAHMH0w2Sm/M7LN6BKqri+/DGXaY6XVCkPVxkWPB3ZrPtlc
         CYtfyecZcByn8Ul9Me2HDgQyO1Zuhm0MvXgiATVE9HdzVIWcPvgnFC+zWzi4vcN8hXG5
         m4tHKoPxWnQIM5cuTKVsT6GBN017olv+6dfHMNZPR276wxQTi3ojvmERKSgS4MF+wRED
         b2sKauYLMWB5jHDGsFFCwzIq2dPtLmXiyCjQRTX8QWQOtRqDwK1/cFd1IhmWJJET3rRv
         WqY1MWqybI4BvvD7MdoSdjSgwSy7YJqYK8sjQ8xk0CWFrPbsuFQMAtM5ztz2Fdl0JKy5
         Bizw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=aa1yNHhGub2q5giAEw5YCf3oqlsTy4a2Ha1OCMwoAtU=;
        b=HBJsCASZMSVHibGbxGCp6qsXJbXGKC9AmwAhqRUfWayWfSpR5GWzIqY9PLY1Q/VPeZ
         1OuiUOXq5tP+sP4Ci/gS9Ty3Y5zZthY5eXoFDYe1chXPs7NhsAOhtcjLUeb4P2SDNpY4
         RIuGWOBc/8xyQL4FTFi+e5U0j6AmAVVughVbvU/NyQBGWRty0rWvxL/JVHaV4tTOan2u
         a0T0bDElkwF1LE3ooInEFdQuBvLEonPI1W7LPLBB17H91sdr47jAA273hpHiwwmQSPBc
         gm/oA8QTuMtZ3EbMl8J93O1B0N091bxAHZLz9kBfFFynQrV8MyDIV/EZX1DW5WwX5GtH
         ipFg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="U/B4/BsH";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="m/tM6G9W";
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t187si16978610ywd.83.2019.07.24.11.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 11:52:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="U/B4/BsH";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="m/tM6G9W";
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6OInMH8026088;
	Wed, 24 Jul 2019 11:52:22 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=aa1yNHhGub2q5giAEw5YCf3oqlsTy4a2Ha1OCMwoAtU=;
 b=U/B4/BsH+TbZIGHSloph0x+gn8OgEk83PznMCUXCgDhWTQZP1gkOAEGOGsEPm/OFPXRd
 gtItcoxCEjzA+QiVal1XBJs4hJhRlHGXADi3FoZNALgZwMN0PMfwIM8MGou+651MCbcE
 nQeS5OsYSh2ggskGMmQpFDGbR5yemRzqOcI= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2txr5nh805-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 24 Jul 2019 11:52:22 -0700
Received: from prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 24 Jul 2019 11:52:21 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 24 Jul 2019 11:52:20 -0700
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 24 Jul 2019 11:52:20 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=N1VOVF1/xToYqtmwjQr1BbNSIbOR6k//XqrYIrUKeM9OfXuuuMtwaCp2pxnTS5YIcHtna7v+dDk3BH7Yyr6K+2XQZM+rca7RDzkeZPt7kib83xcIm3HihOj4ETMOd5zrDoRu90cDu1OIN2xvzyVHM/XgD2ZH3oc237xele5LKBaigWdgd4RcffvJjn62DviU4oAb2+ev0EFjlzp1LtzcPZ78/+FUfvaRa+TrkM9CiPUtwWKAuZngUg2m3/itcY55vGjidHgo7KphVMCKkBe62FEwD8EzRe9m/Rc5Kp+VQH4VRnXL7eniU4jVpdug33mb85l9XiTySMV314Nxl12qSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aa1yNHhGub2q5giAEw5YCf3oqlsTy4a2Ha1OCMwoAtU=;
 b=hBngRUTrvnD3mIhTR+VxeCxP3qAqkKnBcj9fAxBPvTJzCk1XHpRr29FXsvQ8HH+B8EdHFgKqSx1etH24Y5Juaa8gmKYBqu+esOECor213w14JbbiZBY38SK86S1KV58Gw1F2Yfq+WftmCamnKGxw2gKOxJ+IWqEE4baw5iszJUDF0nkHxRm5Z/R11ds8mf3bjfTgqaox0Iq9TWNS0aO+29VoMnPvEaVGAG3otRlZr/IqNJcA2cWXk2y2iO2kjR0CJNbEJF48sy6k3vcoWQA7lvIKSRmOdHSJAg9bIUO4N6kX2KTSHvNBtlWY69oiVSSgdS3mI0UEf4iur6xy1eC8eg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aa1yNHhGub2q5giAEw5YCf3oqlsTy4a2Ha1OCMwoAtU=;
 b=m/tM6G9W32ZbdAMbknK1hPp8rYtAhFTNX8j8R/Euqzem/EmEgbeG4PGP8vIXNMELhc/u0jbf5dZW+2C3rgwcwiyJ3S57qnqHchHnsACOIaOLrGaYfOFsm/sfOD3rdqPMELIZf1ZeexGDoreGK1B3/OJdl45nnqxXpHEtdPBLqk4=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1789.namprd15.prod.outlook.com (10.174.96.8) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.10; Wed, 24 Jul 2019 18:52:20 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::4066:b41c:4397:27b7]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::4066:b41c:4397:27b7%7]) with mapi id 15.20.2094.013; Wed, 24 Jul 2019
 18:52:19 +0000
From: Song Liu <songliubraving@fb.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        Andrew
 Morton <akpm@linux-foundation.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        "peterz@infradead.org"
	<peterz@infradead.org>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>,
        "Kernel
 Team" <Kernel-team@fb.com>,
        "william.kucharski@oracle.com"
	<william.kucharski@oracle.com>
Subject: Re: [PATCH v8 2/4] uprobe: use original page when all uprobes are
 removed
Thread-Topic: [PATCH v8 2/4] uprobe: use original page when all uprobes are
 removed
Thread-Index: AQHVQfsnepoAlMhPK0qmuIU0gpphb6bZpE2AgAB5kgA=
Date: Wed, 24 Jul 2019 18:52:19 +0000
Message-ID: <BCE000B2-3F72-4148-A75C-738274917282@fb.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
 <20190724083600.832091-3-songliubraving@fb.com>
 <20190724113711.GE21599@redhat.com>
In-Reply-To: <20190724113711.GE21599@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:856f]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6f3fbdb3-69ad-42f9-8813-08d710680e4a
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1789;
x-ms-traffictypediagnostic: MWHPR15MB1789:
x-microsoft-antispam-prvs: <MWHPR15MB17893F0D7DB172E16EAABA0FB3C60@MWHPR15MB1789.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:605;
x-forefront-prvs: 0108A997B2
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(366004)(136003)(396003)(376002)(39860400002)(199004)(189003)(71200400001)(71190400001)(36756003)(5660300002)(14444005)(256004)(57306001)(76116006)(66476007)(66946007)(66446008)(66556008)(64756008)(6116002)(33656002)(6506007)(53546011)(229853002)(102836004)(6916009)(186003)(6246003)(54906003)(316002)(4326008)(76176011)(99286004)(14454004)(6486002)(6436002)(25786009)(11346002)(2616005)(446003)(8676002)(6512007)(7736002)(86362001)(68736007)(81156014)(81166006)(8936002)(46003)(476003)(305945005)(478600001)(50226002)(486006)(53936002)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1789;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: RZX72aB+99LXHP1bXefZKENqiHQ2YcvdUIqmL6a12NlCiFuAjEKTgoLadlF1kNbIC4ywIXgWxoBT0TIDWbaZZofomrU44V+V3dvuzYZlvgblaTYZ78lsMeZP88ulbBKssmTlcz3W5x6zjXFzFAkrXItKQn70edH25yJ9IDr15a6NCimj3/bfag8EehArsS357dlyHi1kz+g7rnq5Z80Zc9SfNzTk+9kehA+K1yBGnIKhERhnO7QQMs5IaYRSZQL38mt3x2Bo1VMWM+2UMalW9GTxNHThS9ge5nAyzQxP7CDj7uIWZtCntUP6xMjJAJqoFS8ff2E9FYruHrEK4MAElpZgQjLSHrEBXlRzjYmokMSDCqAJ5M5uv3hYMXvXHNOsBU7LmsXVs1hC/Rk5quRhicsit0LHHk8j0ddFpn1ol1Q=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <BED125F3441AB64F9DAE1BC94B08C78C@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 6f3fbdb3-69ad-42f9-8813-08d710680e4a
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jul 2019 18:52:19.1547
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1789
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-24_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907240200
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 24, 2019, at 4:37 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> On 07/24, Song Liu wrote:
>>=20
>> 	lock_page(old_page);
>> @@ -177,15 +180,24 @@ static int __replace_page(struct vm_area_struct *v=
ma, unsigned long addr,
>> 	mmu_notifier_invalidate_range_start(&range);
>> 	err =3D -EAGAIN;
>> 	if (!page_vma_mapped_walk(&pvmw)) {
>> -		mem_cgroup_cancel_charge(new_page, memcg, false);
>> +		if (!orig)
>> +			mem_cgroup_cancel_charge(new_page, memcg, false);
>> 		goto unlock;
>> 	}
>> 	VM_BUG_ON_PAGE(addr !=3D pvmw.address, old_page);
>>=20
>> 	get_page(new_page);
>> -	page_add_new_anon_rmap(new_page, vma, addr, false);
>> -	mem_cgroup_commit_charge(new_page, memcg, false, false);
>> -	lru_cache_add_active_or_unevictable(new_page, vma);
>> +	if (orig) {
>> +		lock_page(new_page);  /* for page_add_file_rmap() */
>> +		page_add_file_rmap(new_page, false);
>=20
>=20
> Shouldn't we re-check new_page->mapping after lock_page() ? Or we can't
> race with truncate?

We can't race with truncate, because the file is open as binary and=20
protected with DENYWRITE (ETXTBSY).=20

>=20
>=20
> and I am worried this code can try to lock the same page twice...
> Say, the probed application does MADV_DONTNEED and then writes "int3"
> into vma->vm_file at the same address to fool verify_opcode().
>=20

Do you mean the case where old_page =3D=3D new_page? I think this won't=20
happen, because in uprobe_write_opcode() we only do orig_page for=20
!is_register case.=20

Thanks,
Song

