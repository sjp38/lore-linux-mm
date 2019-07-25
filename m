Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7655C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:17:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B032218F0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:17:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="N3desboZ";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Ine+0bUy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B032218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2436B6B0006; Thu, 25 Jul 2019 14:17:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F3D06B0007; Thu, 25 Jul 2019 14:17:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BD3B8E0002; Thu, 25 Jul 2019 14:17:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id DEEB66B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:17:50 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id h203so37543426ywb.9
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:17:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=pq2qzrh1qaVrXV/n5Yq4sKeQS8gRbO36P48MvAQhh+E=;
        b=OFMeQ8+ks4bjlTePNwsLxm8LyVPnzBmUXeM7EjN+ORvSaR6iHHEBw9SZJeEgDrL+L+
         jcyYN6J3c8dFyOXP0PfVFXBOUxUK+ccv3w3qATLbg1jz6E0O1OL8oQTtEjzdSPWNXSxb
         d17KVgvdoza8DJWYsrtAdzG53cqk7P+IYwXwYfQrXmFtN5fM1dB1cPpiqPt+zcYC15T1
         pZKR615B66r06xK0bUgZXd+4jayQsH9zeQpuZ0mYC6JsoRchE7IKE4NsaPtX4elTj/tc
         vs+1bOnWIqXd6kT84HtMrbu3brFmRppn3sJXzZV6Vr+csCh7G+52/VbGxNkzs4FsKKTW
         9I5w==
X-Gm-Message-State: APjAAAVTCf6UTzCGlXXUvsZ0dlUPxsEEZAZx/tPJ2r5KunzHGBCePdoG
	OxCrL04yMNy0TGGa9zKbPx71nLYUNUSLjBh/QbmytgCQ1vozSQir1RwIXhTvXbBwuM+jLgTtQej
	csfC05Ucu5u0XD/j2pJMc0/SzRfwV/+R8veTqORHvgYGQxDClOK4fL1BaAZmPNUgGCQ==
X-Received: by 2002:a81:aa50:: with SMTP id z16mr51340410ywk.278.1564078670665;
        Thu, 25 Jul 2019 11:17:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLs97gbKCzhmH2boCU8pZR47EtmOQ+ZlLwWSA6PiJpRpb+Qbf7X1/2CKe/g9QwGmmsDtDB
X-Received: by 2002:a81:aa50:: with SMTP id z16mr51340385ywk.278.1564078670099;
        Thu, 25 Jul 2019 11:17:50 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564078670; cv=pass;
        d=google.com; s=arc-20160816;
        b=icPooLBvBvkOSCB43X2/2HHWRFm1UbuLgGwW8K30pvc4PaV6OK3aDlHcGOjOU3Tqhg
         tJBeNHRLF4CBvF6PmsTuH63tnm7EoVa7Ykza18fKcunZ62EjpE/UpMsOFrSVs8rZ80bJ
         2gDurfA2oRPR6aHC58moIopbt/CVFm0aXkrR9sYDCVS2SZUzkEYGnWyBeA3jGu03581u
         viuSvkLUUvwMm+s8PFixp5Gy23l02X5xLbOjri80wQzdH7H+nZmqgsHSTwjR6FAB9naH
         Ue43o4aEeHvrF0TVWRMZBix84s5CMyodsChO8u4r6E+ons9N3q9XU2fyUw9fdZjmaG8f
         eVXw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=pq2qzrh1qaVrXV/n5Yq4sKeQS8gRbO36P48MvAQhh+E=;
        b=I+yq1jjRBcWDYCR6n8a4TJHehUysPiHnlFkYhaX1WzDZZWua6l2oVafyVbpMsolojv
         VtXcN2No6oo9PqiGj29+z3wv0wwTql337byQw3Ely9/NCjSGWopzrGJBUiPm2aqkZSuA
         cmyg20HjIZ8VxKbe2uospRUiSAYoMTKhrfvg2++skgt0gdLILrjGgqHq39ZxjkiC2wFr
         0WthCaLBlE3IJ5gPtcXVird7qDkzHlXGdzVVi/vR7X3cF620Jm+ZaRQq8iBzerOg+FbK
         hhk6NcwV3Cq2uBAU3AmpZXcG/pyaXS9TNG+DNpLXVp9oh9cRjXzuC9XO+9dekynwRIgi
         NtRQ==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=N3desboZ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=Ine+0bUy;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=21092c3477=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21092c3477=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u65si19205513ywe.320.2019.07.25.11.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 11:17:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21092c3477=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=N3desboZ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=Ine+0bUy;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=21092c3477=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21092c3477=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6PIEYHG027245;
	Thu, 25 Jul 2019 11:17:14 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=pq2qzrh1qaVrXV/n5Yq4sKeQS8gRbO36P48MvAQhh+E=;
 b=N3desboZgUFp+XSW5aCR7jV2BtrZTfPiK5MN16hf4HiBECxoVawFrWXXipCPE6+BFqtv
 Qg+bt4lkJPRA2OZlB1WiWYqAR99MOhHxMKiF8rHbafkT5vZG7UloYFqRr74Kpewr6ljx
 9FOc8qfRtOIr9Mag7a6xqYG7f3z7VQFTZfw= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2ty9n6a231-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 25 Jul 2019 11:17:13 -0700
Received: from ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) by
 ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 25 Jul 2019 11:17:11 -0700
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 25 Jul 2019 11:17:11 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=aeUYo/hEE1zkjJRYMjEu2E+yVEBmXHq3VSxNmhHTwZ1Ie5FYUK6k8cjrHSunJCrD6MpkS2e4KgcsM6P/dD7XiV5IVSHtKgXr+JwDQ/LVRnFSyETADAoKLRirwlFCQw8cpxcHqXhSJloL3K1TRRQdnmS7cjCWOAleZZw9a/KDncoytnnLS3v7BnzuTwcuNbu+6svYyKn81oV3BgXYNkMfOZRUB6TlUIN/W+ntCDR0x13WurkiLPQs3hui4n6EIzyH6V6zEisM7YnXybXic5ycaACLgvQyfH3+Hd/9uO0Bw6MHh8NleLJDnSYgHltcZUfXXZKuqR3Ex10yvDB972WRZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pq2qzrh1qaVrXV/n5Yq4sKeQS8gRbO36P48MvAQhh+E=;
 b=C3EEYSBfQiJa5tc4gBDa4d5vzi8u8ou4Z51PxNWfItGvbTM/zh3sdr2xQtWXR3zMMw4PPwERdo8Wjm3f2m4ElevAK6hve2KwrBBedZijdL3dh5SISLggmOO06QvsO8fLo3qIIqjtz1EJWsb6OZGhbPZ3H6T5kkeEd/O4x4NQhwZE+Hw+CTKafHNueC4XoyhjJ1ikvCK1VreppZCxUuVks6I9nvZSiyJEvac99BhUH6yi2UWd4FpLOXc7ka68NMNCDVbWssFG3F84OCVK+FAK+RrPMn/h9aYdj2A2rFvtxoiHHkVDrfVxy9ToM/EegJN2qHS9JtOP0CnTBh7Uh4lSvw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pq2qzrh1qaVrXV/n5Yq4sKeQS8gRbO36P48MvAQhh+E=;
 b=Ine+0bUyIbvVDOVQz66OzicnrxoBxhGzpy6SNyCQY2ALtsvrDS8n1x4zzDoU4dlfToxLYyBGtSIKTwKgwG5KsN45iacLZLKkCCDTVZtE7LwkcbmI386adoEQWGaQo188C002AR9VrJiB/Tfj2ptJcBKljNzvc7fgadYexrAuuRw=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1279.namprd15.prod.outlook.com (10.175.4.142) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.16; Thu, 25 Jul 2019 18:17:10 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::4066:b41c:4397:27b7]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::4066:b41c:4397:27b7%7]) with mapi id 15.20.2094.013; Thu, 25 Jul 2019
 18:17:10 +0000
From: Song Liu <songliubraving@fb.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "Andrew Morton" <akpm@linux-foundation.org>,
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
Thread-Index: AQHVQfsnepoAlMhPK0qmuIU0gpphb6bZpE2AgAB5kgCAAOAOAIAAqHSA
Date: Thu, 25 Jul 2019 18:17:10 +0000
Message-ID: <A0D24D6F-B649-4B4B-8C33-70B7DCB0D814@fb.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
 <20190724083600.832091-3-songliubraving@fb.com>
 <20190724113711.GE21599@redhat.com>
 <BCE000B2-3F72-4148-A75C-738274917282@fb.com>
 <20190725081414.GB4707@redhat.com>
In-Reply-To: <20190725081414.GB4707@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:63dc]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 06967bf3-325c-4572-da0f-08d7112c4f45
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1279;
x-ms-traffictypediagnostic: MWHPR15MB1279:
x-microsoft-antispam-prvs: <MWHPR15MB1279BDC7BF352878A15D1FF5B3C10@MWHPR15MB1279.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2331;
x-forefront-prvs: 0109D382B0
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(346002)(136003)(39860400002)(396003)(199004)(189003)(71200400001)(71190400001)(446003)(53546011)(6916009)(7736002)(305945005)(6506007)(57306001)(6116002)(186003)(6246003)(11346002)(229853002)(8676002)(14454004)(50226002)(46003)(6512007)(14444005)(2616005)(476003)(256004)(486006)(6486002)(4326008)(68736007)(81156014)(81166006)(316002)(76176011)(478600001)(86362001)(54906003)(76116006)(5660300002)(25786009)(36756003)(66476007)(64756008)(102836004)(53936002)(99286004)(66446008)(66556008)(2906002)(66946007)(6436002)(33656002)(8936002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1279;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Py+MpX7eqEO6ozt7iJSCb1rz7PRouDhOlzXfz4TmBUxkK69wYT/nwCFaaEBFylXpbwmih83yI3UiGs1aLAP1n/r7OzGxuM5IJyyDgwzB4b7qO7uq4N77mygyNPlOrilAAFl6tAbDHxAmoYTYv2IBZUk5+hd0VwBxl/wD4p+8gkJdimuWhEJKtnOQLo+Y63iGFYopk3kjKye/Fh6m9ONv6IQpOVAgqBiTcihzaxj+TkAYyLy+DK9wGdEOPTa1xZjzq6eojmA7A00oiF2/qBcVgJgY7yXaGe7wr0vrVrWR6c5lAEqDyqvviCdu/OROBfsw/JZryOjR9951pHxDd0HQ0P1bPKxemRSrz7Xe1FYiffuutkct40b894sSW4o8lFogeQJd5LQhY4qoPkldxjpEZd+iY3gG2WE/e4PwAabM9Ls=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8D5E5C7D092DC2418E8E69FF9C0E6753@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 06967bf3-325c-4572-da0f-08d7112c4f45
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jul 2019 18:17:10.0784
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1279
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-25_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907250215
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 25, 2019, at 1:14 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> On 07/24, Song Liu wrote:
>>=20
>>=20
>>> On Jul 24, 2019, at 4:37 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>>>=20
>>> On 07/24, Song Liu wrote:
>>>>=20
>>>> 	lock_page(old_page);
>>>> @@ -177,15 +180,24 @@ static int __replace_page(struct vm_area_struct =
*vma, unsigned long addr,
>>>> 	mmu_notifier_invalidate_range_start(&range);
>>>> 	err =3D -EAGAIN;
>>>> 	if (!page_vma_mapped_walk(&pvmw)) {
>>>> -		mem_cgroup_cancel_charge(new_page, memcg, false);
>>>> +		if (!orig)
>>>> +			mem_cgroup_cancel_charge(new_page, memcg, false);
>>>> 		goto unlock;
>>>> 	}
>>>> 	VM_BUG_ON_PAGE(addr !=3D pvmw.address, old_page);
>>>>=20
>>>> 	get_page(new_page);
>>>> -	page_add_new_anon_rmap(new_page, vma, addr, false);
>>>> -	mem_cgroup_commit_charge(new_page, memcg, false, false);
>>>> -	lru_cache_add_active_or_unevictable(new_page, vma);
>>>> +	if (orig) {
>>>> +		lock_page(new_page);  /* for page_add_file_rmap() */
>>>> +		page_add_file_rmap(new_page, false);
>>>=20
>>>=20
>>> Shouldn't we re-check new_page->mapping after lock_page() ? Or we can't
>>> race with truncate?
>>=20
>> We can't race with truncate, because the file is open as binary and
>> protected with DENYWRITE (ETXTBSY).
>=20
> No. Yes, deny_write_access() protects mm->exe_file, but not the dynamic
> libraries or other files which can be mmaped.

I see. Let me see how we can cover this.=20

>=20
>>> and I am worried this code can try to lock the same page twice...
>>> Say, the probed application does MADV_DONTNEED and then writes "int3"
>>> into vma->vm_file at the same address to fool verify_opcode().
>>>=20
>>=20
>> Do you mean the case where old_page =3D=3D new_page?
>=20
> Yes,
>=20
>> I think this won't
>> happen, because in uprobe_write_opcode() we only do orig_page for
>> !is_register case.
>=20
> See above.
>=20
> !is_register doesn't necessarily mean the original page was previously co=
w'ed.
> And even if it was cow'ed, MADV_DONTNEED can restore the original mapping=
.

I guess I know the case now. We can probably avoid this with an simp=10le=20
check for old_page =3D=3D new_page?

Thanks,
Song

