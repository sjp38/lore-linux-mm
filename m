Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2A2FC31E49
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:47:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BAEE2082C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:47:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="XRwjp1b9";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="KqkshA3/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BAEE2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB45C8E0003; Thu, 13 Jun 2019 12:47:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D659B8E0001; Thu, 13 Jun 2019 12:47:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2C3E8E0003; Thu, 13 Jun 2019 12:47:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id A04508E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:47:25 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id r142so19284551ybc.0
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:47:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Rl6wOXJYCzDQwlutYVbitb+2UlSRrel76r98JpXVsVA=;
        b=rb2jDEdZMuNS6Qn4VACm8AjoVk04bT1S9QxWJnm+rK8+WygCwnHoSdfDt0NeKO1llj
         eVFmbyvTw/0NjKX0oYeUO//t20BOqzgFj7uEq0tT8w/DO+Xx02DtZZSYm4UsorJJMnMd
         nlDKIazMrezNqJJf3b56IblbiLQNNiVeFdO7/gEKFMLZe88ryX3BSYMUKY/PnZhQaan6
         MG2WlOHEThc+GSGNrzOSo+fKGjooRJl57OxKEDww/NVYDF6KDbt+Y6wC6F645TyKltci
         2L61Ubs9QJIxAxxQxdAcrHGOPG0XFBwQrWJH7/9OBmC0S5aZm8xFO4xYMmn7IBPLFXKZ
         SbSA==
X-Gm-Message-State: APjAAAU4paTe9UHk5l4pZRk0X2Fgyb51alBVnjpOTnSArmgPbrFS8+lZ
	F3MMddmrYuQETaZ71lvknx21N7VQh1KoKcaDKnaUcu+e7LXwb68nKQUp7znB5AsKez2sCQkfVJ2
	zRLI6VAgA8QBebSZNfCvSeIfANzDZkL2wRedvVwB1xqHwHd3reDerO1bHNJIljyUkCA==
X-Received: by 2002:a5b:ec8:: with SMTP id a8mr36013439ybs.363.1560444445373;
        Thu, 13 Jun 2019 09:47:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRJkZ39InJw8ldeL47NqzvXqGYDu3Ov3Mvm3zq5hbGGSMDqw4mFyHlGf3vMwGGG0whE1aY
X-Received: by 2002:a5b:ec8:: with SMTP id a8mr36013403ybs.363.1560444444672;
        Thu, 13 Jun 2019 09:47:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560444444; cv=none;
        d=google.com; s=arc-20160816;
        b=u1kYds9099EWk9OM9HAzdJuRb88X+4IY4zRtZxb3Bc2DsiE2y/gWt/3rXwVok8045z
         8JJubkEN5DIO2sfFvAzjoJ/pmkpLpXM3X6UWZC/sZOy5KsgMttpIbP3vd4H9ptmxwG1w
         Pl4qKpV3vUEWt7NvZGn0BQ6d2vpOytQnkksY8x+b+XHhevnj67srNGat6T7ijGQ6kndo
         eYCx/lzxskVMmmRefiIz2MfHdWLNC7ku4yomSDSlqbaXd50eVIFNmk0LKzAQFd+xdno4
         nRjnEmqUJtj8fguDBZQoZqVIHC/ezA5Hd9EyVBaVT5mFuRUrlVElYIlVMaxr+QqOwAGy
         SCBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Rl6wOXJYCzDQwlutYVbitb+2UlSRrel76r98JpXVsVA=;
        b=ECfjSzz51SOY9N14kb9RBP9IGEtRMJCAYiy9Z5SbayuaBqKAvpFlSTYPynoyUsgtYj
         Ox7R+Pe+cTjrNsxPKV/8L7wnKG3zwfjbiqa6qEBUl87xbyGacugbKD5u+2E6sA3a5mBp
         chijPYH/EJEKama1xBcWsZ538RY0E5y5Fab1SlL0Ua6hdWo3EA1DmWMzvge3UYSs7RKp
         /RBqDFQfXrON5RhJ4az97kea2MrMBterP314TWxd8Nke2hndRXsZ47wSBu/aKgHu0Tfd
         qg87VFH7FzT1v0IIW1w+7NPFIK6daAWHsUrHXz1bCKjVxtLwhL6g8mbB6teeokKCZzjD
         Ql0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=XRwjp1b9;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="KqkshA3/";
       spf=pass (google.com: domain of prvs=10671a9cb7=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10671a9cb7=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l15si101062ybq.217.2019.06.13.09.47.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 09:47:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10671a9cb7=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=XRwjp1b9;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="KqkshA3/";
       spf=pass (google.com: domain of prvs=10671a9cb7=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10671a9cb7=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5DGPDRn016963;
	Thu, 13 Jun 2019 09:25:47 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=Rl6wOXJYCzDQwlutYVbitb+2UlSRrel76r98JpXVsVA=;
 b=XRwjp1b9ikxfeAOuIvdFmEVvIiuDswDFcK2oRfxyVOLyYKK7RR/Ju8xUrNO+YB8cYahW
 FE6+1/QeEkE1sy+AfLz0j5JfmSJfuvjzIN7Nx8KiptKjUWAHU65JpbQbhR/iHw7Hvd2L
 p080+1I+8CsjJ9zz17R+7yFnhPq+zBupkKw= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2t3s7yg65q-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 13 Jun 2019 09:25:47 -0700
Received: from prn-hub04.TheFacebook.com (2620:10d:c081:35::128) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 13 Jun 2019 09:25:34 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.28) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 13 Jun 2019 09:25:34 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Rl6wOXJYCzDQwlutYVbitb+2UlSRrel76r98JpXVsVA=;
 b=KqkshA3/ZVEiC02VnHlUkeFk4R+Z/vkYpbDgM9wJDmP8DV8Gm4zfRqZQ4nRNAWn05k4RppPDiUfiOrhmkkpyWpvn3VSpiSmtvmRJ7soEEQ0b5s4iiUrKdcEU2OaGwiNlfOhu88uxg8Ag2I0Uo3brB4RGW6sp+Ecl4zr6h5cM2aU=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB3082.namprd15.prod.outlook.com (20.179.16.209) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.13; Thu, 13 Jun 2019 16:25:31 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::5022:93e0:dd8b:b1a1]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::5022:93e0:dd8b:b1a1%7]) with mapi id 15.20.1987.010; Thu, 13 Jun 2019
 16:25:31 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Vladimir Davydov <vdavydov.dev@gmail.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        "Johannes
 Weiner" <hannes@cmpxchg.org>,
        Shakeel Butt <shakeelb@google.com>, Waiman Long
	<longman@redhat.com>
Subject: Re: [PATCH v7 01/10] mm: postpone kmem_cache memcg pointer
 initialization to memcg_link_cache()
Thread-Topic: [PATCH v7 01/10] mm: postpone kmem_cache memcg pointer
 initialization to memcg_link_cache()
Thread-Index: AQHVIKv7eKlgl+FF5UyOUicyA2PiQKaY10uAgADwlYA=
Date: Thu, 13 Jun 2019 16:25:31 +0000
Message-ID: <20190613162524.GA1267@tower.DHCP.thefacebook.com>
References: <20190611231813.3148843-1-guro@fb.com>
 <20190611231813.3148843-2-guro@fb.com>
 <20190612190423.9971299bba0559e117faae92@linux-foundation.org>
In-Reply-To: <20190612190423.9971299bba0559e117faae92@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO2PR18CA0043.namprd18.prod.outlook.com
 (2603:10b6:104:2::11) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:17da]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 53fc8be4-9a53-4d51-c052-08d6f01bc0fb
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB3082;
x-ms-traffictypediagnostic: DM6PR15MB3082:
x-microsoft-antispam-prvs: <DM6PR15MB308283347AD9359FE329F538BEEF0@DM6PR15MB3082.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(979002)(366004)(396003)(376002)(346002)(136003)(39860400002)(189003)(199004)(25786009)(6512007)(46003)(5660300002)(386003)(1076003)(71200400001)(4744005)(52116002)(9686003)(102836004)(478600001)(71190400001)(76176011)(86362001)(6116002)(11346002)(446003)(2906002)(256004)(6916009)(54906003)(229853002)(476003)(316002)(6506007)(99286004)(14454004)(486006)(64756008)(186003)(66556008)(305945005)(6436002)(6486002)(6246003)(66476007)(8676002)(73956011)(66946007)(8936002)(53936002)(7736002)(4326008)(33656002)(68736007)(81166006)(66446008)(81156014)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB3082;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 34PhiovMekORtJW+wmeKsEmgDgCCa+BTVmm0EgoXs3zUpEoREPCkZ8LK/lmRpkkXPZAtTR46QF2K1QDFmcnrXqWzSA2HjjeYISXlDdbCCtjIzNFXVbmZWKr4u2sM/Ka1R28Rx+wSPsRKh5M6YKc+jouTt4kB8JeEOlgP2O0mxdFiveDSwHDy5TD9a4rkf+Q5cggM7ww9Wq5v3oNhAWFKL+dibEd5vcP+kw+vxrlUGogCyjyooV8PGCOkFW1JbXBPfBexYEBe4/jjq3Q7orpu6uTDiKHm9jD1yO70GajoIFFInkChrV47MRwfe7y17OaS6PTLMvEd/zJ33g+Qd19gpBv53u13DVcdLJYw4sZFaAUs/sR4Nx4XXvb/R7QzPCOxahefSzVK2Dq39EuIoZrBCesCqu7VkHCzofUVPOX8+tI=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <CE277DF53E86E740945AB8546EF59B7D@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 53fc8be4-9a53-4d51-c052-08d6f01bc0fb
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 16:25:31.5739
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB3082
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=676 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130121
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 07:04:23PM -0700, Andrew Morton wrote:
> On Tue, 11 Jun 2019 16:18:04 -0700 Roman Gushchin <guro@fb.com> wrote:
>=20
> > Subject: [PATCH v7 01/10] mm: postpone kmem_cache memcg pointer initial=
ization to memcg_link_cache()]
>=20
> I think mm is too large a place for patches to be described as
> affecting simply "mm".  So I'll irritatingly rewrite all these titles to
> "mm: memcg/slab:".

Works for me. Thanks!

