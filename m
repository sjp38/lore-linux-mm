Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7E50C282CD
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:53:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 810F42148E
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:53:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="JsV9D11I";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="K9ps7GQK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 810F42148E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EBA48E0003; Mon, 28 Jan 2019 16:53:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29B868E0001; Mon, 28 Jan 2019 16:53:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13D878E0003; Mon, 28 Jan 2019 16:53:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF8D58E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:53:14 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id p4so15202203iod.17
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:53:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=LfhIbcF3M8aVM48F9+/YcRQvZsDVHnk6M8q59YUonQw=;
        b=MIXR2TnO+q/gMEPUOPP1kWRxPfZNx9uhwnMXaXpurRRSpGNU7LitibyHDNadfgujnN
         blnNVNR59LuEjhvyGYbqO9psKGUYS61YxkHemyqFtGdo7i/IWFiN9Oe8FhJHoggAqWD9
         kUwwxxncxjNO5vxgjMF7SG8LfzKrw4tK+YfV0doflQ4QaYtA6noh3YHXTCzUhyoIVfai
         oUz2VY9efYfgY+EjcbVF9m6+6jWFvXhgvHLT26JTiIOwf4qrzHG7gVvbu8IKFN/AuhlE
         tYj7ug0mvq8iNWYPHlKgT717N53wgWohPGo6omYc2k65Sb/Nk79tNcXpJgmtL3eXTbgz
         EqAw==
X-Gm-Message-State: AHQUAubkFwrZgN2QjAEkAXG9q8WFv6jr/AzF8mECBpPtvcQw166AYAi1
	omDD+ggIjlwo7d2JVzpc052KuP+M4yH2rP0dw9gSBuqHmce10Sl4G3eTJJG7ysBWjuUb0yy3Ra5
	cXocg6ZCk85VdQzFe2C9CwEylGp3fAVK0m/Qi1dfJ4uxykQ8FW/sgSGxt873GlxGTRQ==
X-Received: by 2002:a24:af0a:: with SMTP id t10mr2087599ite.159.1548712394660;
        Mon, 28 Jan 2019 13:53:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6ymSBclHkJclduHBGVQ7hIwUQrhuuqB0JcS3qmngiRColwjbzL5DsccDZmdPbsxB1HMDnt
X-Received: by 2002:a24:af0a:: with SMTP id t10mr2087576ite.159.1548712393978;
        Mon, 28 Jan 2019 13:53:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548712393; cv=none;
        d=google.com; s=arc-20160816;
        b=fEXhPy+41hwBMwt5RA6FC883aTm65fouOwvY6JONcoipurTCg0IY1LjiOxRiLYKgBX
         7/VeIFxvGi90SbQ6nuGXbR/MsfqJoHpOT+l7ZjFQPAKjR6FnAR0l/PUwt2kd2lpDMSBc
         apcBduKX8LGC5XWJB9wHNBLasZWB63maad9TGRdhOyOh0W3ZQs9f5MZW7U7EWlX4pZhL
         S+oVohmcvUvqoQGBQ/64lp22o5yLoFTgiqYuBHKjTACwlGXAPOnpDT/JcxxHHlVqfC7m
         7MObJMpD0acWDMSoVhuDHhqYFW299eKqLjMnIFjf7wXHGHQepaAS7Q14ldTNBmLrel/p
         M0BQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=LfhIbcF3M8aVM48F9+/YcRQvZsDVHnk6M8q59YUonQw=;
        b=xCqNQ6ih2RKD+803lNWiaakdXbsdFB+rkwuc/PtoPxTEpw5fRUIv0wIHOMSZpHOIxU
         9s+1p6pG2Yqu/xzaaKSrPMH5nDUv2awVqXNDxv/Y1Sy9GJ4luwF9Blb8Bp510Ze620Ws
         QRuZeHBLGay1fB2P16QyuP0Cwb8oU1nS7YXVr4n6qr3dqDsHO6tMNGIMkJW54tH5q+MG
         OXBomGEPKL0iQ9pLHgXy7kbC3tAgYBatvhjy9uGwrchJMjhHw/Txk+G2TBgFEoBHQp9c
         0dRc+CH7nXloN5ZToKqVUmRRGvUmkwDe0JaSYWOmyiqyZpy2jGDs8u6rxM5efIEQW3AH
         BMtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=JsV9D11I;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=K9ps7GQK;
       spf=pass (google.com: domain of prvs=79316e96ce=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79316e96ce=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id n128si447208itc.40.2019.01.28.13.53.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 13:53:13 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=79316e96ce=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=JsV9D11I;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=K9ps7GQK;
       spf=pass (google.com: domain of prvs=79316e96ce=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79316e96ce=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0SLirqh020306;
	Mon, 28 Jan 2019 13:53:10 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=LfhIbcF3M8aVM48F9+/YcRQvZsDVHnk6M8q59YUonQw=;
 b=JsV9D11IV2vMLN9eMA5RW4i5XBGbxXM2QJmvzXQZ0djf9wD+glfmcQI1zeOa4PHh/LON
 sbun26Dp8vDVdx727ngAjV4CAqjWMQqQbzWO2oxT7fR8T6raQ7yKspmrOD+PJlB209o7
 OAKio4KU00g+zxPa7QsdN2BKNDMjWVFgR0Y= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qa71f0nfj-5
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 28 Jan 2019 13:53:10 -0800
Received: from frc-mbx06.TheFacebook.com (2620:10d:c0a1:f82::30) by
 frc-hub01.TheFacebook.com (2620:10d:c021:18::171) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Mon, 28 Jan 2019 13:52:42 -0800
Received: from frc-hub06.TheFacebook.com (2620:10d:c021:18::176) by
 frc-mbx06.TheFacebook.com (2620:10d:c0a1:f82::30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Mon, 28 Jan 2019 13:52:41 -0800
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.76) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Mon, 28 Jan 2019 13:52:41 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LfhIbcF3M8aVM48F9+/YcRQvZsDVHnk6M8q59YUonQw=;
 b=K9ps7GQKknaMfI4k9y3HvYVKGsO2j2vURVfdPcTruD7DuAOOnPMkdPbiGSg0Ie1EWYtj3NPsTDSjI1fCFoC0J+fKiuFjDoeHoZGrm58E6Or0ibOefYQQykmh3gE7pXo7wM1sMc23lsQwPpKZXSBwYLYDxLAwRZo3B1IU9RtWb/k=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3496.namprd15.prod.outlook.com (20.179.60.24) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.16; Mon, 28 Jan 2019 21:52:40 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::7459:36fe:91f2:8b8a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::7459:36fe:91f2:8b8a%6]) with mapi id 15.20.1558.023; Mon, 28 Jan 2019
 21:52:40 +0000
From: Roman Gushchin <guro@fb.com>
To: Chris Down <chris@chrisdown.name>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Johannes Weiner
	<hannes@cmpxchg.org>,
        Michal Hocko <mhocko@kernel.org>, Tejun Heo
	<tj@kernel.org>,
        Dennis Zhou <dennis@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH] mm: Proportional memory.{low,min} reclaim
Thread-Topic: [PATCH] mm: Proportional memory.{low,min} reclaim
Thread-Index: AQHUs4Zt38UF96mTm0amM4LuPUpLpqXEq9uAgACRwICAAALjgA==
Date: Mon, 28 Jan 2019 21:52:40 +0000
Message-ID: <20190128215230.GA32069@castle.DHCP.thefacebook.com>
References: <20190124014455.GA6396@chrisdown.name>
 <20190128210031.GA31446@castle.DHCP.thefacebook.com>
 <20190128214213.GB15349@chrisdown.name>
In-Reply-To: <20190128214213.GB15349@chrisdown.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR21CA0055.namprd21.prod.outlook.com
 (2603:10b6:300:db::17) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:3227]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BYAPR15MB3496;20:5iA5z/Qj4nXGrh8vODal1Zj8OQgU0oX45GR2IgILXxlyNqhOEx6GYKm6K6mWG6SA8hbkXOlCAiCj0RBsPrzCBjd5Ol8N6CTQ+uPC9o3SUacEOYW5lBZYtZK7c+URsw5rew/ek61IOYph3r06kQKDBrO8WEj19K4ZqNvb17B8v9o=
x-ms-office365-filtering-correlation-id: 5ed55505-12ca-48f2-805e-08d6856aec55
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3496;
x-ms-traffictypediagnostic: BYAPR15MB3496:
x-microsoft-antispam-prvs: <BYAPR15MB3496C403E749FA568AA7E4ABBE960@BYAPR15MB3496.namprd15.prod.outlook.com>
x-forefront-prvs: 0931CB1479
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(366004)(396003)(136003)(39860400002)(199004)(189003)(51914003)(68736007)(6512007)(54906003)(9686003)(99286004)(186003)(33656002)(25786009)(478600001)(14454004)(53936002)(6246003)(97736004)(6116002)(6916009)(316002)(4326008)(106356001)(105586002)(11346002)(476003)(14444005)(256004)(86362001)(33896004)(6486002)(229853002)(446003)(71190400001)(71200400001)(46003)(102836004)(2906002)(8936002)(81166006)(7736002)(81156014)(1076003)(305945005)(486006)(8676002)(6436002)(6506007)(386003)(76176011)(52116002)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3496;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: LXMXN4eV1jOswqrPSESsADce4138v6jrblUcKdTNCllQCn32SRz7KZ66ppeBNVJHPdrP5pL8Sx1nZXw3mA8tPRieJRsvciXmcBAU31y/pNmB+ghIKDr9t3rpffdCghT4mrd0MH2Qc54ANWDavt2FVUUNEiMhxOUoyefsheN3iKqOVV3qhTu/a4OWZGqkaj+jY8B7z5WOgnDHqFpL9GnXxGKyEUqURUMTNgWXY9HOMbhnl4Mf1HUAKkJRBki3x2CG+EmugPhmLLPlhVQZFwyl9bfrrflc8T2NXBJURBJNy/5l7bUYBe+0TfQYMq6aLQkUZFHXQX6JYU/j7kcDjJQAB8Dp+kXtUiWNl8lypOac5K0FNt1PYbWZwz/uWDJTk1ymGoU7jlGB0ogrI6nE7me7tgyO8ReIBQ4bi7GYqBEW+74=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6FEBCAB4621E644BA86E11E1DCC17B38@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 5ed55505-12ca-48f2-805e-08d6856aec55
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Jan 2019 21:52:38.8621
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3496
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-28_12:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 04:42:13PM -0500, Chris Down wrote:
> Roman Gushchin writes:
> > Hm, it looks a bit suspicious to me.
> >=20
> > Let's say memory.low =3D 3G, memory.min =3D 1G and memory.current =3D 2=
G.
> > cgroup_size / protection =3D=3D 1, so scan doesn't depend on memory.min=
 at all.
> >=20
> > So, we need to look directly at memory.emin in memcg_low_reclaim case, =
and
> > ignore memory.(e)low.
>=20
> Hmm, this isn't really a common situation that I'd thought about, but it
> seems reasonable to make the boundaries when in low reclaim to be between
> min and low, rather than 0 and low. I'll add another patch with that. Tha=
nks

It's not a stopper, so I'm perfectly fine with a follow-up patch.

>=20
> > > +			scan =3D clamp(scan, SWAP_CLUSTER_MAX, lruvec_size);
> >=20
> > Idk, how much sense does it have to make it larger than SWAP_CLUSTER_MA=
X,
> > given that it will become 0 on default (and almost any other) priority.
>=20
> In my testing, setting the scan target to 0 and thus reducing scope for
> reclaim can result in increasing the scan priority more than is desirable=
,
> and since we base some vm heuristics based on that, that seemed concernin=
g.
>=20
> I'd rather start being a bit more cautious, erring on the side of scannin=
g
> at least some pages from this memcg when priority gets elevated.
>=20
> Thanks for the review!

For the rest of the patch:
Reviewed-by: Roman Gushchin <guro@fb.com>

Thanks!

