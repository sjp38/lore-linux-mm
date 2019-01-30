Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BA87C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:12:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1371E218AF
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 21:12:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="j7RFVe1Y";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="KaopT+1M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1371E218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B134E8E0002; Wed, 30 Jan 2019 16:12:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9D2E8E0001; Wed, 30 Jan 2019 16:12:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93CD08E0002; Wed, 30 Jan 2019 16:12:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 688B08E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 16:12:44 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id u17so492012ybk.20
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:12:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=tH/IbfNKhRC6ZrYi91YP5b3b99YaZHESbAqbffdYLP0=;
        b=kce3rQc7m3WVth93jjWYjVTUjeZv0yEL6uSdvKMz3feNgPF3YreHb9Ep7gw/O186F4
         wV0uCL2dLhQXylP4eMcLjI4+9DiJqpfQvQellRuF5pFRC5OOsRKVrOxPDk9MzLQ0wWGA
         EjJ01mfoFilKE477GkD6i22TcOJk2YkASuhpyw+JW2sYGSCX9GZvFShtVktNwpsbnq/X
         FxdtFZVgV1J2d+hLVz2gqpdfXhEhTuOogDjQ+0M2F3UYxVTc/dLOTN9nPA2DJFUEY0Xo
         fujBwaZvPAsgQEwmCzpL7LweDC5IvII9mhOKRZeax3yRpyPf/9ZsMIw40C571crrJv1W
         CG8A==
X-Gm-Message-State: AHQUAubBinO2BE1vkFcmMrRXO2ns1fwyQyvQolnKPs16icXbuKZKoJSV
	pBzLQmIVZLLFZWKLR62eGtLWJFlKWDiJevWY6IZI2OD6BZF4WBgDYotIdc7BNXOyDsq+uf5lDh6
	ap/NAP+gNCKlFjYxMVjZUSoH3bWwbdWSld9vvjGAOj3KRfXK7H5L5/YTNE+pUCmW71w==
X-Received: by 2002:a25:30c3:: with SMTP id w186mr19180824ybw.24.1548882763784;
        Wed, 30 Jan 2019 13:12:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IafsAx+p01QjYHt5upheY3oQ+8O9YBje1cEuet47cCijYQFSSz4+PLUcUwPdh0RQjsWfrzJ
X-Received: by 2002:a25:30c3:: with SMTP id w186mr19180786ybw.24.1548882763140;
        Wed, 30 Jan 2019 13:12:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548882763; cv=none;
        d=google.com; s=arc-20160816;
        b=EULV8BAgt7mabX9Vr48w6a98dhQsHkTKo/acBlbJzSqJLy/9sRTzxuAvy4+IucMDI/
         0PahTrHK9whbGbgr3GlMeKGsZEMFXLgTyaNGoM30+fUgekeNAwY4GEjxdSuL49s7brmV
         0P2gUCv4PMJ8k4JU81SMERsYm2GhYotKY8f7RNWZBkOZNn0ifnKiBd44bjOp1QHfMdY2
         zJfu1aNKLLZgd8d8Omw32kVg7ZMFwjNuEe6T4C2NQVeFbtCvzekzBLgVYwuy8ZuFfowe
         dgOKuXXjNh64CsciIokNLkZHz1zHB8xlsfzbeQutT3Lll7br38NB8lCy3Y/rxljn+lxo
         jYow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=tH/IbfNKhRC6ZrYi91YP5b3b99YaZHESbAqbffdYLP0=;
        b=n3ig1ykAgVj/TeT9rdIZS8qVSXgfbnF7rZH+auzbUYJoSCaXoLxo3crsSoGYx6BjFD
         nL/YCelGmVVvGVCJt6itKKRsqi7G4CJWZxz4QhoIRNa+iOtteUHwSSUlqy7x21pKDzgv
         oNFC7jFxOCTr/MPaY7of7oAVFXEXOJtWb9+CpEptL3W4Cukh3Y7DuBAK6K8XYE8JNP/S
         EUG084XtJKB5tR7zwNwsEluS+YsKjY7OfunyA02UnlP89/ycUvhKgmN0wO3HeevzjNJD
         4aOkV1v0Ob+9Y8oCghjPNgQ4wFMM0pn+ZfRrFg/Ls6huna6rrQrQ2UdYVztVCRclJhke
         MFhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=j7RFVe1Y;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=KaopT+1M;
       spf=pass (google.com: domain of prvs=793397e901=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=793397e901=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id j190si1509054ywd.368.2019.01.30.13.12.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 13:12:43 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=793397e901=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=j7RFVe1Y;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=KaopT+1M;
       spf=pass (google.com: domain of prvs=793397e901=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=793397e901=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0UL9LbQ009030;
	Wed, 30 Jan 2019 13:12:39 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=tH/IbfNKhRC6ZrYi91YP5b3b99YaZHESbAqbffdYLP0=;
 b=j7RFVe1YRRvGgsrFau+tskht5dMEWRpu6r0fQ/lfty+436yrVlEsJlxpoBGqbO+vi3LH
 27BqNo+Iv9ZazaJN510Dp3AIg84uh7ioerCpFeCPsM7OU7kkqHSptP/teY6aP6/sveeX
 w6nT3neR2tJGSoNnPAjkD4EJsMWPlErZG+U= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qbkf3r1f1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 30 Jan 2019 13:12:39 -0800
Received: from frc-mbx05.TheFacebook.com (2620:10d:c0a1:f82::29) by
 frc-hub03.TheFacebook.com (2620:10d:c021:18::173) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Wed, 30 Jan 2019 13:12:37 -0800
Received: from frc-hub05.TheFacebook.com (2620:10d:c021:18::175) by
 frc-mbx05.TheFacebook.com (2620:10d:c0a1:f82::29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Wed, 30 Jan 2019 13:12:37 -0800
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.75) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Wed, 30 Jan 2019 13:12:37 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=tH/IbfNKhRC6ZrYi91YP5b3b99YaZHESbAqbffdYLP0=;
 b=KaopT+1McO7R//b2r5nPkrPXflGDzGDJtucXHNqWXU1IR4uwzohxZBYYWet5fqTKBhKuSt11NpeuoSdBjPaLsd91l1OD7+4HaiTWbges8c2c7iBijAVkxh1CtLj8zlFIjGeREdnjUp3xQAcLSxxJddhh5cP8+43GECV6zAd5AQE=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2230.namprd15.prod.outlook.com (52.135.196.157) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.17; Wed, 30 Jan 2019 21:12:35 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1580.017; Wed, 30 Jan 2019
 21:12:35 +0000
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
Subject: Re: [PATCH v3] mm: Make memory.emin the baseline for utilisation
 determination
Thread-Topic: [PATCH v3] mm: Make memory.emin the baseline for utilisation
 determination
Thread-Index: AQHUuAcB1sKq7eSF7Ue9hhxxElYkPqXIUPYA
Date: Wed, 30 Jan 2019 21:12:35 +0000
Message-ID: <20190130211226.GA6216@castle.DHCP.thefacebook.com>
References: <20190129182516.GA1834@chrisdown.name>
 <20190129190253.GA10430@chrisdown.name>
 <20190129191525.GB10430@chrisdown.name>
In-Reply-To: <20190129191525.GB10430@chrisdown.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR1601CA0017.namprd16.prod.outlook.com
 (2603:10b6:300:da::27) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:1669]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2230;20:KCu0Kij4zkirSSPpDAMa1FmCaulPC8bmhz3co3hkp3wLEznaHNCAA+bejy9AoQ0dl21I86w+3daSlROrJ+S7qNNUbMmR+dnYoKmDH78f+MTAb+MDGk7Q2m9cb82I/offnacHGlkaK6HwiWcuXVLS2ziIF7rggFkYkyregTJhFpo=
x-ms-office365-filtering-correlation-id: e87b0942-1915-4fbd-e157-08d686f7a820
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2230;
x-ms-traffictypediagnostic: BYAPR15MB2230:
x-microsoft-antispam-prvs: <BYAPR15MB22306A7784D125097EE8A5E6BE900@BYAPR15MB2230.namprd15.prod.outlook.com>
x-forefront-prvs: 0933E9FD8D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(346002)(396003)(136003)(366004)(39860400002)(189003)(199004)(9686003)(6506007)(76176011)(478600001)(2906002)(71200400001)(6512007)(81166006)(186003)(8676002)(33896004)(33656002)(25786009)(53936002)(81156014)(71190400001)(6916009)(52116002)(97736004)(102836004)(386003)(14454004)(68736007)(446003)(6116002)(105586002)(4326008)(229853002)(8936002)(46003)(86362001)(6436002)(99286004)(6246003)(54906003)(256004)(476003)(11346002)(106356001)(316002)(6486002)(7736002)(486006)(1076003)(305945005)(45673001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2230;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: m2d6xh0DOXSSl3ylnm9Tw1Z4dC/jU3iZbSLkvXGFOoXoyqbGsJAFATgTDXkFsGmIYYkeHXPAdESz3gv+wwv2HzqWHcT50VDX8BVqUHzMzwNC9sj/q1g4kz2OGM5XJ0bdetgT3XOwOEgFgVxj7zN440YFQXF2aQ+wc/9oDLUZBfpPYvXQ5LB2x+P2aiVL6/Oz+UlR/d3geSBebymgny0wDAtnGmh0NTq5NRvMFCA7kGJiaHwrYFA6BWxfc0EH+3INwl6hvy8Jnr0pL4gIV4q8hGjCYAT7Vr5AlUiRv/nLDAFengkKzyhz5Kp4aDaVYlQw0lMeKgsLxauQMDLs08JNAxdXQYWGNu44xO1UZDg2DJv3Xh5T7sC7Hj96SuFKI3KnJWozt3X0pH9AN/flfZFmhfOddCooy4mCT0573+2VwTU=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <CC376DBE2AD86543AB31870EA097DB32@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: e87b0942-1915-4fbd-e157-08d686f7a820
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jan 2019 21:12:34.4907
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2230
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-30_16:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 02:15:25PM -0500, Chris Down wrote:
> Roman points out that when when we do the low reclaim pass, we scale the
> reclaim pressure relative to position between 0 and the maximum
> protection threshold.
>=20
> However, if the maximum protection is based on memory.elow, and
> memory.emin is above zero, this means we still may get binary behaviour
> on second-pass low reclaim. This is because we scale starting at 0, not
> starting at memory.emin, and since we don't scan at all below emin, we
> end up with cliff behaviour.
>=20
> This should be a fairly uncommon case since usually we don't go into the
> second pass, but it makes sense to scale our low reclaim pressure
> starting at emin.
>=20
> You can test this by catting two large sparse files, one in a cgroup
> with emin set to some moderate size compared to physical RAM, and
> another cgroup without any emin. In both cgroups, set an elow larger
> than 50% of physical RAM. The one with emin will have less page
> scanning, as reclaim pressure is lower.
>=20
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Suggested-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Dennis Zhou <dennis@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com

Acked-by: Roman Gushchin <guro@fb.com>

Thanks!

