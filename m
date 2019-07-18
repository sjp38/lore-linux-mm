Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4E6CC7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 17:05:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61E0320651
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 17:05:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="dU5C6bmi";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="uHsjF9Gs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61E0320651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F36C76B0007; Thu, 18 Jul 2019 13:05:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE8116B0008; Thu, 18 Jul 2019 13:05:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D600F8E0001; Thu, 18 Jul 2019 13:05:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id AEAC06B0007
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:05:13 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id f15so21765602ywb.5
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 10:05:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=QojuxV2jTJXF80TcjA6Wa8saY53a7gMAKLPJsicXWR4=;
        b=OvxevKWNE4bqQoZ/3lVdcIiLzP8TR9xPoZLf7Hw7saQnN+oHd74O82rzrze9CJnrEP
         mKO6Jt4+H28LGAkmaHpLf/4eSdtOJb1HNbFP7oQCQVs927DDFNotnfvOfdQQ7G31zivn
         BEaDqvLdqPWJEL8BsL0VNcOPJT4tjV5fL3yW2kwH7PlFdcBMnExCJ44i46VdST6kq1f/
         QD2YXLdKbVSQPtRo3HQLx8hek8y22XMmiMyW73IDQrm4yCxIckFAvvi83CLQzVRDCkK7
         R38F8/vguGj4pMF83E9g9NMnQxqn7hV6xYc62Wna7ZjzZkRB16ftW+3BxuQtJ00KvmOX
         If1w==
X-Gm-Message-State: APjAAAV8ZSkse1iO8udB3wMvO8Fz7fxZlFwqbR5T4LGwvrts71Szsa8P
	jqJRB2kImkIsX21RqlT82dScglMVJZhEc8uMXFhEWCo6XeYep+KEGO99uij0FGcIHJOlFRoPtyS
	yThI6zg2PioXO0p8UtfDX1NU71fbAnQDYX+sazK3fdu3PxBurLJ8KeWZmcuBVl2dqjg==
X-Received: by 2002:a25:2085:: with SMTP id g127mr30138231ybg.442.1563469513374;
        Thu, 18 Jul 2019 10:05:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxckL4M9TSu4LftdDBzS5wHw0VheTQYZEUCzpT92DUUnBfwretaegcf9SKfoTZtyZCh1mc7
X-Received: by 2002:a25:2085:: with SMTP id g127mr30138180ybg.442.1563469512736;
        Thu, 18 Jul 2019 10:05:12 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563469512; cv=pass;
        d=google.com; s=arc-20160816;
        b=eaJ1w5LZtw7KLIXb2kWrR2T0/pzJrEgxK2QTuVcZ6abj2XaDJ3wVdQeyn729R4QddY
         bx0thgKMn33TQIjbIBStAgUNH2HUdHXud9pcUENsW4rnD7yQQo4exlVDihVchxcEBj/4
         ccBgpPKccFnSjPJo8eKFQg0hgC8PhzDF8IaSB3hxuUTYyo3QlTVLVPAjTIMgDEe10X94
         J19BiBUsJCmuG8Hkyz4b5IQ12aYrUdhV+cVCU056KNNwaNvVznS+3g4uHJwrrf6SYDhL
         BeAJ0HFVT92sy0mX/MAS61jKHNlwbSdH5NFDRk0SniDac33a2RwdWUOv42pmGwZNL7tk
         +FBw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=QojuxV2jTJXF80TcjA6Wa8saY53a7gMAKLPJsicXWR4=;
        b=eFeef4JY3gWLkCB3wLf8kO0kSBI5w4CoJhDpqL1KuTXWHVTttNx0ni1FyMMrS3cp43
         trTwGycE0HQbETze+/OMOhaJvCk4PgGh+CBX4lfPAsIeJ19EFDHCT7N8+arN13Xj1hLk
         bSz+UrhME+9vSGH4DBqryqfU0gHTfPdZyDVmRFRlT2IV+/Wo25cSA/ghMDPBxCePyPA+
         3+aLv7jPPcJShKUcHBf/JRe3w/TicVmsfTEOO+k0RGqo7xlfphO/flFLdG9My97QiIaZ
         pJhrhprleNn9MxeN8cPShgVH1AVRc0MYg8Sm61v7d+8PzugZeJl3CxYbhnwiX1WpdXry
         0YjA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=dU5C6bmi;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=uHsjF9Gs;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=210290121b=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=210290121b=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b185si3671429ybh.279.2019.07.18.10.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 10:05:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=210290121b=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=dU5C6bmi;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=uHsjF9Gs;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=210290121b=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=210290121b=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6IGwu4J012906;
	Thu, 18 Jul 2019 10:05:07 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=QojuxV2jTJXF80TcjA6Wa8saY53a7gMAKLPJsicXWR4=;
 b=dU5C6bmioayx34WQLchBEaQmfTdkx4m/PhmMUlHVwZCLbPxAg4JHb8DVSP29ZpnFkxMT
 51+MCqZth0cDrrIO9VnXX9E3995PmM9WoCX562X0SufoZ4XhlmZ96kL8wwK7Ypp/TewB
 qSIBSMfj6dE0JmIEkRklV7sAxYTIkAgVbR0= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2ttvqxg1ag-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 18 Jul 2019 10:05:07 -0700
Received: from ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) by
 ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 18 Jul 2019 10:05:06 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 18 Jul 2019 10:05:06 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=cMlNi8RcGzz6mmDpKFXrMzeEEcm3Ewjy8wiLovIPFoL5uMX2bisWLrxewvOj/vA8UitzVFM5QHEmwB7K7wHGdE/8HD7WP4inks3465VwwbQ1lI2flIYP+MnDS+xTrlBdUJuOWJY7GrT1SEy1UnAPVrCrFRxbsN5yi00kxb+6aq1WYsPwftFawiNMpdkOnqF05SMKyZmkicZW0VTMrq4dYnWm5h7bj+54Rxz5pjo9bYd0p2XaOE9hu68yitNgKdVttqd3MgjWqzlogi4hbAIWBQyfVaov+qO886BExp8E7hysRfKRg60Ke0Ne8/HbHMu5SDusNAEXj2XEffby8+legw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QojuxV2jTJXF80TcjA6Wa8saY53a7gMAKLPJsicXWR4=;
 b=ZUwOgw9K+79xfkYy5XXxmziUUv8v31aThYvOqaZz7eH/6ScD0IID6nVtofyg59h75QJhneK9HTKNZoOddjRuiG+Mc8jgujn1FyLJ7MgbQqyCRxhrT4mAluy4OSQ6bEesu4JJplb0pp61i09/EWR8yq9iZ3tZYICDO8GVfKZUtiw51i0Dt91BFF4DEhP+pxBhVIBlLKmJVEsm3seFzOOObfnNhYhbiErlIzkGUZYEXp+PTRLgPysGacYkzupiX8mIM9zE4dOnRpJZbLHIXf59/TK4/+xjCThk8bE0Ev11ks4mba657GKz26P7SrkNmyINvMI2x8cfv8zYo3ZoVNpuGQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QojuxV2jTJXF80TcjA6Wa8saY53a7gMAKLPJsicXWR4=;
 b=uHsjF9GsVErIv1RFrd4zzUd8RNma7MZSvASTr0gz/JnlixvuLJRL42H/fjeCytYEULIvt97mhE2X0MyG7MsSV1pyWeo7l1t4neegM20OG4pxjJvLSQKsrjiFPnTSFC+PjAqcHmsnRleJ5C6BNirxr6HlTLK08yDD+X19xitBCLo=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB3212.namprd15.prod.outlook.com (20.179.48.221) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2073.14; Thu, 18 Jul 2019 17:05:05 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::fc39:8b78:f4df:a053]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::fc39:8b78:f4df:a053%3]) with mapi id 15.20.2094.011; Thu, 18 Jul 2019
 17:05:05 +0000
From: Roman Gushchin <guro@fb.com>
To: Christopher Lameter <cl@linux.com>
CC: Waiman Long <longman@redhat.com>, Pekka Enberg <penberg@kernel.org>,
        "David Rientjes" <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        "Andrew Morton" <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        "Johannes
 Weiner" <hannes@cmpxchg.org>,
        Shakeel Butt <shakeelb@google.com>,
        "Vladimir
 Davydov" <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v2 1/2] mm, slab: Extend slab/shrink to shrink all memcg
 caches
Thread-Topic: [PATCH v2 1/2] mm, slab: Extend slab/shrink to shrink all memcg
 caches
Thread-Index: AQHVPN3TlomcCJJgFEONei6lr3vfPKbQQNKAgABbTQA=
Date: Thu, 18 Jul 2019 17:05:04 +0000
Message-ID: <20190718170458.GA6139@castle.dhcp.thefacebook.com>
References: <20190717202413.13237-1-longman@redhat.com>
 <20190717202413.13237-2-longman@redhat.com>
 <0100016c04e0192f-299df02d-a35f-46db-9833-37ba7a01f5f0-000000@email.amazonses.com>
In-Reply-To: <0100016c04e0192f-299df02d-a35f-46db-9833-37ba7a01f5f0-000000@email.amazonses.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR15CA0043.namprd15.prod.outlook.com
 (2603:10b6:300:ad::29) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c091:500::f13c]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 05be2f81-de36-44b7-4bba-08d70ba21433
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB3212;
x-ms-traffictypediagnostic: DM6PR15MB3212:
x-microsoft-antispam-prvs: <DM6PR15MB3212CC7F86C6E222DC26C67ABEC80@DM6PR15MB3212.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 01026E1310
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(39860400002)(376002)(136003)(366004)(199004)(189003)(7416002)(256004)(66476007)(6436002)(316002)(386003)(66946007)(54906003)(486006)(8936002)(6486002)(4326008)(6506007)(14454004)(2906002)(66556008)(64756008)(1076003)(33656002)(6512007)(9686003)(66446008)(86362001)(52116002)(46003)(102836004)(478600001)(53936002)(6916009)(5660300002)(446003)(6246003)(11346002)(76176011)(25786009)(229853002)(186003)(6116002)(476003)(81166006)(71190400001)(99286004)(68736007)(81156014)(7736002)(71200400001)(8676002)(305945005);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB3212;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: UttzXwjYz37a6xJhARcdDdxfMzY4N4l1ZkfZSMesNi8hLKGwauWy+tYiZS3Fd4o8bv/TsGhPecEXj6K6Mx1cO/asgEvI/Q0G9pUzCGc7Qn6nP8qr1sXys3FiV+XhGFDU+pj2Eukd4fJKpuMuEOZfu2/laAxQvThl2+6VG35RyFdsq6bjjwAyqk/y3W7xZA+Cec2utpY5Apq0U+viC+1WswFlwrOzDRmDVHbhyEJp4d08Ak/0JdA484lMpADsM/HXutXaWzuyWRmXoTWogPcmoON845pEZY5qxgvZ8NM8fQwCdoCxKgg0nV0xdr9wzmlvNUiH+FmYDpdh56cJ0TARFUvLoOrAIsZPx9Wgjlznc4dscFyuFOUF7hdAVvVJz4FFARgUHs5golbHfblvoNYEL3/u1FwLY79KV+GJ9jQGGYw=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <DF12C64E016D9B4989D6104F9506902D@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 05be2f81-de36-44b7-4bba-08d70ba21433
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Jul 2019 17:05:05.0346
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB3212
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-18_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=868 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907180179
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 11:38:11AM +0000, Christopher Lameter wrote:
> On Wed, 17 Jul 2019, Waiman Long wrote:
>=20
> > Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
> > file to shrink the slab by flushing out all the per-cpu slabs and free
> > slabs in partial lists. This can be useful to squeeze out a bit more me=
mory
> > under extreme condition as well as making the active object counts in
> > /proc/slabinfo more accurate.
>=20
> Acked-by: Christoph Lameter <cl@linux.com>
>=20
> >  # grep task_struct /proc/slabinfo
> >  task_struct        53137  53192   4288   61    4 : tunables    0    0
> >  0 : slabdata    872    872      0
> >  # grep "^S[lRU]" /proc/meminfo
> >  Slab:            3936832 kB
> >  SReclaimable:     399104 kB
> >  SUnreclaim:      3537728 kB
> >
> > After shrinking slabs:
> >
> >  # grep "^S[lRU]" /proc/meminfo
> >  Slab:            1356288 kB
> >  SReclaimable:     263296 kB
> >  SUnreclaim:      1092992 kB
>=20
> Well another indicator that it may not be a good decision to replicate th=
e
> whole set of slabs for each memcg. Migrate the memcg ownership into the
> objects may allow the use of the same slab cache. In particular together
> with the slab migration patches this may be a viable way to reduce memory
> consumption.
>=20

Btw I'm working on an alternative solution. It's way too early to present
anything, but preliminary results are looking promising: slab memory usage
is decreased by 10-40% depending on the workload.

Thanks!

