Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 291BAC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 01:32:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 996882084B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 01:32:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="GUlgyYGW";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="fZMuCzBE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 996882084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BBA76B0003; Wed, 19 Jun 2019 21:32:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06C408E0002; Wed, 19 Jun 2019 21:32:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E76008E0001; Wed, 19 Jun 2019 21:32:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B1DE56B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 21:32:48 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j7so818264pfn.10
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:32:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=G8BtisHhd5Vt2Qox+hinRoNXTbf3XL9RP9rCNGI3myo=;
        b=K7BvEJJOMVw0mnsjm/NOvSxjuhtIPbZ/O32FTmom2UPg6ZIl7jA4ep1HQU/b3pdY7p
         K624kIv29r7MF4Nj2oSbyFKr7rs/Ga9O77l5xUzvuerj7lE2h9ze27ZInNufE11tJRIr
         KmUj3+9UWYfcvWUfYGUosuvQDzN2W4XIQZ6OxhXd8B6bGvFUv/OTyrPPlX6vtpbW4ok7
         k1WwGgo7M2RO4rpgQ+4A8FYygs8cECtnmqR1xgMID+Y/1D8Gyx2A/YKn6GZU9PInkgC7
         B0OTSwaUKrb6oRCGUhFa9wKsYCEZeynSQ//8NZkrYNw7/ktpX30QOf27T7jDqrsSWuSB
         tlAQ==
X-Gm-Message-State: APjAAAWoJ1fltukb1Yj6mbU/0Z5C/h7w/wA++fvdckBcD1F212V4CDr3
	JdP7VBrVzOTpiK12siEkfoIBeCZdYtcKwd1sVF6bWcebdMuNr0pEhq6wpSAKPu9UN7IKfjfKsE1
	F0PflX5nTQ4RXZo1sisWCRP6xQVxlNLS/6w7Dyo9UnOAQeTyywSq35t35TB0Gx5EcxA==
X-Received: by 2002:a17:90a:9b88:: with SMTP id g8mr242614pjp.100.1560994368047;
        Wed, 19 Jun 2019 18:32:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLaTsY81tNiIO8Q6aagNIxIIb0u3ktYLdY55hxdvSLOvzt9bR9mzyUW9xX6p53dmVcY9f0
X-Received: by 2002:a17:90a:9b88:: with SMTP id g8mr242578pjp.100.1560994367318;
        Wed, 19 Jun 2019 18:32:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560994367; cv=none;
        d=google.com; s=arc-20160816;
        b=Jjw5qUcY9EodF+BZ2+m2B7hVnQfwMCWEvGR/4Mz9NCxY6pcmau6dM0t0HU22xb884x
         QAqL8TB1+h85iQemN6EraUR/Hhv6WQaFeWxjMiR2j2bIO9fRFFSwE7cWrm8DXnUwdQQk
         1I+U8TrwDW5sqkRg5SK2JIzRi23m0HPGkeYrGfVJenH2iSO77HXI/vpLb4eYGfDOGjEj
         2umKhBw+oN/OfjHcrssLY5uBM5ni3ykSwttG7Vyvs5lwSEyzDKa2Ydo8/Z+Lx1z8raBS
         mjUJ85+AwHN+f/7ik41Gos7+a46mOQTBqr5CU9T5tbDJFRr0GqgEiaJTwJ03QLnbYDlc
         W8Zw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=G8BtisHhd5Vt2Qox+hinRoNXTbf3XL9RP9rCNGI3myo=;
        b=wHLtlME2vyV8ziMdq6r4UZyXUYLqgTvddLxA4MDJ2wu0KlQM0waemIA/895zA+4Xd5
         cNhrIGARQttAATSJTPovcWh3LFiExCrLZGbwD3idXnUBJV0t0JJnS9KUF3c/fo/xssWz
         FEtKP1BW5ugnSW6W+fG885KEuswiFK9QJTK0kk88LvP/58lnuYs2bOReCpPpT4N8D18X
         X1CUZF2QwN7tQfDEZe8bKAItyjtOfXQ/xZl2+f5ieBWqPLKPTNEBiAiu34TlupnYX+GT
         zEQmWX0dLAiWGi++Ujf9ArOj+hsY3cELKCn+aGjk8dZrjmdDvaJrWhDOud5bLCLa6aBy
         Ksvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=GUlgyYGW;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=fZMuCzBE;
       spf=pass (google.com: domain of prvs=1074ecebd6=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1074ecebd6=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p93si2787306pjp.66.2019.06.19.18.32.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 18:32:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1074ecebd6=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=GUlgyYGW;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=fZMuCzBE;
       spf=pass (google.com: domain of prvs=1074ecebd6=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1074ecebd6=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5K1TbGC026474;
	Wed, 19 Jun 2019 18:32:46 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=G8BtisHhd5Vt2Qox+hinRoNXTbf3XL9RP9rCNGI3myo=;
 b=GUlgyYGW8viX+9T6OTgAujUAqtMp6LbsNehp9cA85gTRj0UQ7K3b+DjbBN9vRJar0mj9
 E0pxMu+6+Jgy/wRIkiVS3VI47kguQSHQ7rr3wWhwM4zc/k8esO9W0/0y86/GF4MyTjgf
 v2IQIV7lEw3E0FaFUqhYEXcxd+540mkBGec= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t7wrj0h2e-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 19 Jun 2019 18:32:46 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-hub03.TheFacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 19 Jun 2019 18:32:45 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 19 Jun 2019 18:32:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=G8BtisHhd5Vt2Qox+hinRoNXTbf3XL9RP9rCNGI3myo=;
 b=fZMuCzBEWpSpWYu/P4FbiXA9LncWBpvehECs7Q29aXIbzDo43vQGe8tVsGHtenGNNJecQU1ClZ/V/ApDHiwRyvq+BOrvg4TDKpwhci1uB0IbgiGZLHMdlPZwPqwlJEUOKvqYToDMK5krN2ARiGyAw/yvPZ/qyRkWBYq2vzBSNIY=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB2345.namprd15.prod.outlook.com (20.176.70.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Thu, 20 Jun 2019 01:32:44 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::5022:93e0:dd8b:b1a1]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::5022:93e0:dd8b:b1a1%7]) with mapi id 15.20.1987.014; Thu, 20 Jun 2019
 01:32:43 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrei Vagin <avagin@gmail.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: WARNING: CPU: 0 PID: 11655 at mm/page_counter.c:62
Thread-Topic: WARNING: CPU: 0 PID: 11655 at mm/page_counter.c:62
Thread-Index: AQHVJkPy+Jr2Wzo7c0mhpNsIq/YA/aajB2WAgACc/4CAAB8lAA==
Date: Thu, 20 Jun 2019 01:32:43 +0000
Message-ID: <20190620013227.GA27615@castle>
References: <CANaxB-xz6-uCYbSsSEXn3OScYCfpPwP_DxWdh63d9PuLNkeV5g@mail.gmail.com>
 <20190619211909.GA20860@castle.DHCP.thefacebook.com>
 <CANaxB-xAjfpmLSVLMWb2EETQR5zroizJ9xjTNmTTARnJBSEYvA@mail.gmail.com>
In-Reply-To: <CANaxB-xAjfpmLSVLMWb2EETQR5zroizJ9xjTNmTTARnJBSEYvA@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR2201CA0078.namprd22.prod.outlook.com
 (2603:10b6:301:5e::31) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:261d]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4e7e56fb-427e-496e-99d5-08d6f51f30ef
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB2345;
x-ms-traffictypediagnostic: DM6PR15MB2345:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <DM6PR15MB2345B8CC1E1B36C922BE57D7BEE40@DM6PR15MB2345.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0074BBE012
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(7916004)(346002)(366004)(39860400002)(376002)(136003)(396003)(189003)(199004)(256004)(102836004)(8676002)(486006)(446003)(7736002)(81166006)(81156014)(66556008)(33716001)(1411001)(4744005)(476003)(33656002)(14444005)(53936002)(316002)(46003)(14454004)(305945005)(229853002)(478600001)(6916009)(8936002)(966005)(186003)(68736007)(66476007)(73956011)(6246003)(99286004)(386003)(6436002)(66946007)(66446008)(71200400001)(64756008)(86362001)(11346002)(25786009)(6116002)(6506007)(9686003)(52116002)(53546011)(1076003)(76176011)(71190400001)(2906002)(6486002)(6306002)(5660300002)(6512007)(4326008);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB2345;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: +rHVRR9Y5v4yvQ3/ZffYPlumNaKMp3m5LpMMbsP7bcPLQGEXIHzHZRwcRP5kmDfKWghb2HtVizzIngc7icXHOrp9w6D2Lu5PJUueUDL34EIbQKWtpPcV5DNQC05vRI947sDlrKhyPyRBbhmvIxUVAx1KdGO2Hkpw2NpOMVykykxozUtygp1INJyMibkd6iItYTjTUkxpZjqw1n7Bw6t1p2yyGBL/JzTnppCn8wBBUM49OlO6HUL3bi/ggkv7hFRFSnjHWnh5A+1fxSAhe8vnvn0xW6fkqLZzwgDRs9Q5qEAoVDgIZYebTi0YG9LzeMbZLn4p9qtgfNgrNnjSEafrh9iSGrEqMSMBtYBOw1vBANiCEYgISVXfKfqYy9o5j73SqlijFmup3/n/fFlcVdUnCbau4S5tHkN3+6VRKZLOxQM=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E9B624C3D1927245ACC7143F18478F12@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 4e7e56fb-427e-496e-99d5-08d6f51f30ef
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Jun 2019 01:32:43.7971
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB2345
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-19_15:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=947 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200009
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 04:41:05PM -0700, Andrei Vagin wrote:
> On Wed, Jun 19, 2019 at 2:19 PM Roman Gushchin <guro@fb.com> wrote:
> >
> > On Tue, Jun 18, 2019 at 07:08:26PM -0700, Andrei Vagin wrote:
> > > Hello,
> > >
> > > We run CRIU tests on linux-next kernels and today we found this
> > > warning in the kernel log:
> >
> > Hello, Andrei!
> >
> > Can you, please, check if the following patch fixes the problem?
>=20
> All my tests passed: https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3=
A__travis-2Dci.org_avagin_linux_builds_547940031&d=3DDwIBaQ&c=3D5VD0RTtNlTh=
3ycd41b3MUw&r=3DjJYgtDM7QT-W-Fz_d29HYQ&m=3DPL584FpQp6_68teeNmPDMBi6YNZHVSL9=
_X83jLmfid0&s=3Dg-gMywZpFZp5GRfXixu-iX_YPx0rRrMhCgMZc-5IcF4&e=3D=20
>=20
> Tested-by: Andrei Vagin <avagin@gmail.com>

Thank you very much!

I'll send the proper patch soon. It's a bit different to what you've tested
(I realized that for root_mem_cgroup vmstats should be handled differently =
too).
So I won't put your tested-by for now, let's wait for tests passing with th=
e
actual patch.

Thank you!

Roman

