Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 188D8C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:49:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B12D820B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:49:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="IaULwSsm";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="qTw0lW6r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B12D820B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C7FB8E0001; Tue, 18 Jun 2019 23:49:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 579716B0008; Tue, 18 Jun 2019 23:49:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4417B8E0001; Tue, 18 Jun 2019 23:49:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21CFA6B0007
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:49:25 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id u9so606038ybb.14
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 20:49:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-transfer-encoding
         :mime-version;
        bh=Y3qrNJNd9qLhi81kMpYPdVA8BtXbh1Cd+a8VgaWX7xI=;
        b=Y6AikFUAqR+ZoEENk6pPn7VWxiZRMEUB8ry2UoS0xdUHohKKNEitE5VR89Qf/yBTyQ
         qmPQXM/S/aNqcv1vvudiFRNFYedaLkc0y9qZ4qpbgtheN04wv+/2OWeyPZpImtmlGBrE
         oFyWUj8BzJ5TSF+WlK38/FsiPv/zq1NBUBOWBD8u/repRL8bjRnN3SdfuZev5kt6+Gox
         eMbA6pz/b10C8pfpVVBOQGewM7nYZFeeGHnL0AfLB28aRHR3G2nOO8sTyK8aUqtmjMF6
         Z8YhMbqHQCrzYjnT5pU9pK0FFyqC/a33p5EMui7ncgwzJsMo8Tb2g9TAoX0w/U4yP0HN
         JADw==
X-Gm-Message-State: APjAAAX0qU2xPTM45Cu+028YZ9XP5xg15mCsH9oVGDWHG9MSWYMNAGS1
	k5VI51vbNncKKGnmeV2x5HN1zgR3u8jwgITl7rbg/CoIRbWJtPMc+Ab1ZRJzZtJjPhhWQtwhXRy
	x7oo3lpbUtQ72Vw+60Sim7TXbz3O0Ksl+4uOlYBO/8Xt4BEDuYYhw0cO3kn7t33VuWg==
X-Received: by 2002:a25:144:: with SMTP id 65mr53867790ybb.295.1560916164847;
        Tue, 18 Jun 2019 20:49:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzA5xOetobdhGVn+eAXdwIuVoU/9rmgL9Dx+woUYte64rnH2yhe5waGOumTbDlA93Uln5iT
X-Received: by 2002:a25:144:: with SMTP id 65mr53867774ybb.295.1560916164337;
        Tue, 18 Jun 2019 20:49:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560916164; cv=none;
        d=google.com; s=arc-20160816;
        b=c8ll+bADYwZMS3fEa1TtTFc2HNB5AV4D9zO/GxjMMXfOUu9OMimks2ZC0o8uiXBcGh
         VuOPfJPOQdzfu52fO9jMgAZmb4cpngfGPxNCI/SaS5RoGg8PQF4hzIbe2nKVq5rYe9r6
         dqMz2Jmo8RcNusfyZLxlgKV5FiAXE/wV6T+ReqM2iwsmHPs/Ys5UM5/5nvqrBXEMyfaM
         GftidbFT1vhmuAbfLSRMiG2rR1F4hCGztY6ZVnFJtb2K3GzSCLFOpACPI8D9F/NGYPtt
         p84XkE6WSnvHxXU6f9L97n4PU9i/r0y5D+VDQNKSP6tNB7b5XPSTolozhDuhxlCV7Xsb
         WBrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Y3qrNJNd9qLhi81kMpYPdVA8BtXbh1Cd+a8VgaWX7xI=;
        b=fRWOh48hDN2xN9dkZCKKtxTABZr6b10s+APGNziZCtQ92ndm9+WsvHDqVfkpAit3n8
         PSeQepPUIycwAm09EjNoVBnD2Ldz5DvwJjFEnSKyrPij7IS3WCLedMrYWe7Intu5Y0ta
         uRcD+IvjfJh01VbBF4UxnhxC54wswrTLaJAXBYb6RYxBBoAaKPRBJkEdCoWiqE7DgWpP
         J1KTh2XA+wwLbNa6dT4RQpHvh9cm3KAadxafMW3wK5TRyccs0B6fIcj69xh3c08Mu56U
         KGq/FcP2HOmd5RS65VGZtN5yCMmqS3IUd+a9uzhs33S4ymvaJD/xmYyw3XzJkFiHabwN
         JT5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=IaULwSsm;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=qTw0lW6r;
       spf=pass (google.com: domain of prvs=10734da445=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10734da445=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s6si5619173yws.447.2019.06.18.20.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 20:49:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10734da445=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=IaULwSsm;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=qTw0lW6r;
       spf=pass (google.com: domain of prvs=10734da445=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10734da445=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5J3mo5c009844;
	Tue, 18 Jun 2019 20:49:20 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type :
 content-transfer-encoding : mime-version; s=facebook;
 bh=Y3qrNJNd9qLhi81kMpYPdVA8BtXbh1Cd+a8VgaWX7xI=;
 b=IaULwSsmZLfVKv6QOkF2HizUkc30s5rdqIV1ubp537Cg7ezueOra1bjsntxGhZXK4nhx
 cXz2g42lBmS72N2HbACNUblmBRZjV9N28QP/GE0UgQ/Xuna68qMU5n/Ij7UHSE83j3Ew
 HuRfchgU7ErNRTzQE3sa4spPNcRdr8jey88= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t77ywh1hj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 18 Jun 2019 20:49:20 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-hub03.TheFacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 18 Jun 2019 20:49:19 -0700
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 18 Jun 2019 20:49:19 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Y3qrNJNd9qLhi81kMpYPdVA8BtXbh1Cd+a8VgaWX7xI=;
 b=qTw0lW6rCunZk3Nt5JP1twyeap40DUl2HkDSRwuohc3LxZUknWOsjZZYydGVUDQjwHYBeVEACvp0MXqkCJvVBZ//Ko7I0+TqKTKfCdLoqG1fqYnkykOsvFS+oVH9PnxirsssP1ByeIGypW5M2dYsXGNrLpxUS+SoBz0PQDwrEY0=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB2794.namprd15.prod.outlook.com (20.179.163.207) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Wed, 19 Jun 2019 03:49:17 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::5022:93e0:dd8b:b1a1]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::5022:93e0:dd8b:b1a1%7]) with mapi id 15.20.1987.014; Wed, 19 Jun 2019
 03:49:17 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrea Arcangeli <aarcange@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Rik van Riel <riel@surriel.com>, Michal Hocko
	<mhocko@kernel.org>
Subject: Re: [PATCH 1/1] fork,memcg: alloc_thread_stack_node needs to set
 tsk->stack
Thread-Topic: [PATCH 1/1] fork,memcg: alloc_thread_stack_node needs to set
 tsk->stack
Thread-Index: AQHVJjxrQUI1UpYnBUm17g7vVnU1B6aiV3al
Date: Wed, 19 Jun 2019 03:49:17 +0000
Message-ID: <A44BE69D-BD1C-4E31-B68E-EE4D579C0E8E@fb.com>
References: <20190619011450.28048-1-aarcange@redhat.com>
In-Reply-To: <20190619011450.28048-1-aarcange@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [2600:387:6:80f::1e]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bb527c95-7873-4b64-e829-08d6f4691a72
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DM6PR15MB2794;
x-ms-traffictypediagnostic: DM6PR15MB2794:
x-microsoft-antispam-prvs: <DM6PR15MB27941A9802C25E452AE83E6DBEE50@DM6PR15MB2794.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 0073BFEF03
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(39860400002)(136003)(346002)(376002)(189003)(199004)(66556008)(66446008)(64756008)(4326008)(76116006)(91956017)(73956011)(14454004)(186003)(305945005)(6246003)(7736002)(5660300002)(68736007)(66946007)(8676002)(81156014)(86362001)(8936002)(53936002)(81166006)(486006)(33656002)(102836004)(478600001)(71200400001)(71190400001)(256004)(99286004)(11346002)(446003)(66476007)(76176011)(14444005)(316002)(476003)(46003)(6916009)(25786009)(229853002)(6512007)(53546011)(6506007)(6116002)(2616005)(6436002)(6486002)(2906002)(54906003)(36756003)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB2794;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Uy8/eK1tX9tqDUzSW9XnhOG8ebugbxqIxY/GEQZX53R7og8QahJV3oeMHKJH2u8S9ks864YSY3SUDqyJuoptmUre1F2Fbfp25Uy1naofN+s2tIS0CDIx7uF2onwU+mR69xRYYxnhY/IEhkV2QZNdB7KO5mwgDtvMjdv6t6n2ebDOq4fcjt06Qge02FazdpTHS4NR+AlHljqTgVBjWnQ7Zknl2+bI0w4lLQycgEd/1E5vUZzlO0qVooxyMAjJUNqZQ01y2vv4XjeOnqehblIyOF/ACBAEJo5BQY1hHTOLBlhoiIfcy8bi8WEyH1G5A6hrMFw+Nz8SnGGLtKhFfa3U/Ep4lWduNmnRUkvm35uYOv+V73s4MTaCVoxJuGvBL/GxXBwe2cvW05oSUzax7SNM2KcpnibK2BAY/JovM1LZpio=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: bb527c95-7873-4b64-e829-08d6f4691a72
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Jun 2019 03:49:17.0726
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB2794
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-19_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906190029
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Acked-by: Roman Gushchin <guro@fb.com>

Thank you, Andrea!

> On Jun 18, 2019, at 18:15, Andrea Arcangeli <aarcange@redhat.com> wrote:
>=20
> Commit 5eed6f1dff87bfb5e545935def3843edf42800f2 corrected two
> instances, but there was a third instance of this bug.
>=20
> Without setting tsk->stack, if memcg_charge_kernel_stack fails, it'll
> execute free_thread_stack() on a dangling pointer.
>=20
> Enterprise kernels are compiled with VMAP_STACK=3Dy so this isn't
> critical, but custom VMAP_STACK=3Dn builds should have some performance
> advantage, with the drawback of risking to fail fork because
> compaction didn't succeed. So as long as VMAP_STACK=3Dn is a supported
> option it's worth fixing it upstream.
>=20
> Fixes: 9b6f7e163cd0 ("mm: rework memcg kernel stack accounting")
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> kernel/fork.c | 6 +++++-
> 1 file changed, 5 insertions(+), 1 deletion(-)
>=20
> diff --git a/kernel/fork.c b/kernel/fork.c
> index d6c324b1b29e..9ee28dfe7c21 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -248,7 +248,11 @@ static unsigned long *alloc_thread_stack_node(struct=
 task_struct *tsk, int node)
>    struct page *page =3D alloc_pages_node(node, THREADINFO_GFP,
>                         THREAD_SIZE_ORDER);
>=20
> -    return page ? page_address(page) : NULL;
> +    if (likely(page)) {
> +        tsk->stack =3D page_address(page);
> +        return tsk->stack;
> +    }
> +    return NULL;
> #endif
> }
>=20
>=20

