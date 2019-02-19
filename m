Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 295EFC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 16:21:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC38C2147A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 16:21:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="l/7T3zcx";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="TD8z8YyE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC38C2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69E0E8E0003; Tue, 19 Feb 2019 11:21:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 623368E0002; Tue, 19 Feb 2019 11:21:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49E1E8E0003; Tue, 19 Feb 2019 11:21:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 018D18E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 11:21:54 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 11so11269510pgd.19
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 08:21:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=+ziz4oSsS1e0CJ3WZgMyqljT7cHtXezRCNfHi9IV6vE=;
        b=nRX15Gz8dIKZIAUxmHcqK9EpE+9Ce9M6cM8ACaw0gU1zrjtHQA43+xeE9VATDR5Pt+
         7Qwvk1AGJOCtixu42sNuD49J6NarsOxUwMN+vLaMe57PcWttAlynHKTlVXM1N35/VKiN
         3ujZgqyBRYHUbcWgGocMefu/U+ZRVJDDQ+nm49O0k9KmoN+TizBIn5U1/8/NMfXIpqG3
         qdRqob8OjoX2YCgNa/z6EHEP6u/gacMvkSBzYQZ+zJZJ9Wx6R9iTU4YpBDbpxalbfFgV
         BCkAtDMhNYFtMnVcn+09lfUrWA3cBbIoicW39wPPQooajk4A5O1QY7wzT9KhR5zDhNpu
         vAng==
X-Gm-Message-State: AHQUAuZuifIhs13y1lrk3b8XIElDsbOKIMxAAKA1up1KU1p+75IMNY3S
	nZcqOWCUvx6VXebkBsQyDGxXfzSHRmXiKnM1Udgp7IcHFGRv997fp836OnAb7c9IA+rvZOmpVCO
	YFp5dhl0a8SYwYLF0QkZrI4UK4k+jdc3OY27KWXR+jEbwhBye3BPeCjMQvNzsAwCWqQ==
X-Received: by 2002:a17:902:c5:: with SMTP id a63mr32222939pla.267.1550593314551;
        Tue, 19 Feb 2019 08:21:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia998XmIQY5CnBmY4NgZ7x/+H5cZHoUQutY7v7r+rIRC4hfh7DQgAhegifhqcTnnHcSoA/s
X-Received: by 2002:a17:902:c5:: with SMTP id a63mr32222898pla.267.1550593313908;
        Tue, 19 Feb 2019 08:21:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550593313; cv=none;
        d=google.com; s=arc-20160816;
        b=NSh2E+dle/hPUehmJYfI1Zywoyak2O0o+pY+C4PhdSJ3gm/Gp8PcNDOfxb03P/FEwX
         0Je98IQbcWzGd7463pJMZkrMP0p9HJpl/ov7cJ326B016kntNbqO3DLzMynbWfumNPJW
         ml+sFr3ZazSsj4ne4daey3bxAHOl6euyCjxG4CNstKT4p+cpy3hm0kpAlkOpWedN0ktd
         w211uY55602KgOTFD6tc8jVQumosypgk/v6FB4DiD2ip+rtiueO85PrbyUZQvPULDKSE
         SySPoG0YJZ7UfWtPKzQLVD8lKLZDXffE2lT6JHNYci5lvVF3u7T/fzgK+b0xyxGsPnmJ
         KZpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=+ziz4oSsS1e0CJ3WZgMyqljT7cHtXezRCNfHi9IV6vE=;
        b=nKYKOy+flI8YtqcYHks1pxJwjtLn2uVHlc3gpEN/ft4jTWjAal/BD1wmozbGqTWsBb
         jrPo+yJkwf6ynJG2s2mtyEglO+2LkCjNNDggmDOgxy3ALb+rMgMxHGKEnUjP7Ug5LdK1
         H0a25S41gwl+h78JSnYk1U/PoKCsKtu+2NJlvrwXC/zn8sx/nZco6+JlOK3G0/7xJpfB
         +iQ4An6JIfR06zo7Q8bax/RyqWz+0S/a/N3BLNcT4pJjAuEA5Mh8v2VnuhkwkYax10QC
         YEJ5QEqd5qZ9kw+7fgF0IW5mMTvPoDLzkIGGnNS4f8lIAfZPj+JwIiHFM98xsp+yY3gq
         u12g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="l/7T3zcx";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=TD8z8YyE;
       spf=pass (google.com: domain of prvs=79538942c9=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79538942c9=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p4si11259931pli.159.2019.02.19.08.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 08:21:53 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=79538942c9=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="l/7T3zcx";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=TD8z8YyE;
       spf=pass (google.com: domain of prvs=79538942c9=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79538942c9=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1JGHSHi029003;
	Tue, 19 Feb 2019 08:21:51 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=+ziz4oSsS1e0CJ3WZgMyqljT7cHtXezRCNfHi9IV6vE=;
 b=l/7T3zcxNHGxLEw5Ru78lBeXoDlzsjrsfo/g96viWsQ96276Qd6fXQVKamEcSBCNNlBk
 wulieyZJZJg7KYJYTdNlhbhPmuPlxQw4gJQnv2K1fUVcU2NgYEjiWkbxJWkIrph9Tg53
 0capRUVD/Yd6U0u1bENAbl/p185kWyldfDs= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qrmh185we-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 19 Feb 2019 08:21:51 -0800
Received: from prn-mbx02.TheFacebook.com (2620:10d:c081:6::16) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Tue, 19 Feb 2019 08:21:51 -0800
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-mbx02.TheFacebook.com (2620:10d:c081:6::16) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Tue, 19 Feb 2019 08:21:50 -0800
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Tue, 19 Feb 2019 08:21:50 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+ziz4oSsS1e0CJ3WZgMyqljT7cHtXezRCNfHi9IV6vE=;
 b=TD8z8YyEX4OGOKBWKwnW/WRynRvlW7PFKf9A6VZtR/ahdP/Nob/XBGJu//je/tLGOLyRDHisDX4tuYwIncCr2bFKncJkkgyPBilFrp1osQpua41mOk3rvmdx2C76s8ZvZQ3b81X1YdEpptFalrbHgu2CMegzjLcc4989TAMqOWs=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2744.namprd15.prod.outlook.com (20.179.157.149) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.16; Tue, 19 Feb 2019 16:21:49 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1601.016; Tue, 19 Feb 2019
 16:21:49 +0000
From: Roman Gushchin <guro@fb.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: [LSF/MM ATTEND] MM track: dying memory cgroups and slab reclaim
 issue, memcg, THP
Thread-Topic: [LSF/MM ATTEND] MM track: dying memory cgroups and slab reclaim
 issue, memcg, THP
Thread-Index: AQHUyG83zDFivMD0sEySAs+j+iI3IQ==
Date: Tue, 19 Feb 2019 16:21:49 +0000
Message-ID: <20190219162145.GA10999@tower.DHCP.thefacebook.com>
References: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
 <20190219092323.GH4525@dhcp22.suse.cz>
In-Reply-To: <20190219092323.GH4525@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR02CA0019.namprd02.prod.outlook.com
 (2603:10b6:a02:ee::32) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::7:9af6]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5ecef25e-2ced-48a3-ec3c-08d6968659b4
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2744;
x-ms-traffictypediagnostic: BYAPR15MB2744:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2744;20:P7PmOlMJdTnEeEnUFcJYgjM0Iz12hORTzKYLlmWihAul10/rkpuhDklYkWC/tVGdYJ6KfqPO+7nsVT4qYORJbCM7w7h8wDHRJ/a1uWcCRkdKsnELPuO7A8SXPLJoNsaW8K8fXdan+accKfqt2dkeeR3Zig/73C83KvJny1cpkHA=
x-microsoft-antispam-prvs: <BYAPR15MB2744124EBAA8B14E59AE820ABE7C0@BYAPR15MB2744.namprd15.prod.outlook.com>
x-forefront-prvs: 09538D3531
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(346002)(39860400002)(396003)(366004)(136003)(199004)(189003)(105586002)(7736002)(99286004)(305945005)(46003)(52116002)(97736004)(33656002)(106356001)(4744005)(8936002)(71200400001)(14444005)(256004)(8676002)(81156014)(81166006)(71190400001)(1076003)(14454004)(76176011)(6116002)(478600001)(86362001)(486006)(11346002)(6512007)(446003)(68736007)(6486002)(476003)(186003)(4326008)(386003)(54906003)(102836004)(5660300002)(53936002)(316002)(6506007)(2906002)(25786009)(9686003)(6436002)(6916009)(33896004);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2744;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: FDorRq4HrsTCIjVrLmMz2+y3INzVWGKzQvP71Z/35RYHNGY6vkzgOdJ06MtHvaQPj7AfVTG1Gpf8Q04ounjj5P07is8XjFmUnhnSG2nyki0He4JdHRmNKVaWcbsiAYRsDvWJvkJilj40kBgecx4nocW6yYmAD67f5Rdrfn+pc5CSJkdaVXYEMH8tRWsc5JBMKtgo8u6jsmwNxF/eCBGmQ/VJHIEx4A1N090WqlqX+Psq6OdnSnM6eTbs+zO5e6FeNTs3fo4tgkYJJANTgJFF3AyLfnXselpFobDsqETF31r/LEg+16ZUpPkbl4DFeyAQc5d4W1hfeSyNzPqUvh1OpPYomzlquc7PhO9/aEsD9QJNYrwLPR9DAlvyahL/c8UBvPt77jTYE0pjEPmkShOc5QjZ35E8ybejiOgCRc44wAg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <9F78E47B3254E34084E082B17B68C938@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 5ecef25e-2ced-48a3-ec3c-08d6968659b4
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Feb 2019 16:21:49.1935
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2744
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-19_11:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 10:23:23AM +0100, Michal Hocko wrote:
> Hi Roman,
> you were not explicit here, but is this meant to be also an ATTEND
> request as well? MM track presumably?

Yes, please.

I'd be interested in discussing the problem described above, as well
as any other memcg- and THP/hugepages related topics.

Thank you!

Roman

