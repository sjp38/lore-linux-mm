Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05A45C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:12:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9029D20873
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:12:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="eZvkGVIB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9029D20873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EB446B0005; Tue, 14 May 2019 17:12:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29D956B0006; Tue, 14 May 2019 17:12:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13D5F6B0007; Tue, 14 May 2019 17:12:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E5ECC6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:12:06 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o34so541112qte.5
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:12:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=+Wr4AoBQ+WbNrtNZIjnG9aEHD3jB7iv08RurNxCwk54=;
        b=F0R/bLUizEXcAKGTUVjVJHxQF7YEUqvHt0kFvjXFx5HzW4EiPmO8AHbG+QKKX8i9TA
         kWFSHx4CmfiQ5+2PDAIUcetwSJg/kPFY7yyh/QVZMSuYC2+Mzh0EINKhZRmJTyx5KxsJ
         MG60YgZXLrkFYk0s9QNN3/6CfAjVAv/UQZGkf51+AIJdqAbeuAnyUw0WpWMGtoYcnXBx
         996a4kY4R3qSUuYqRVeB+faluFM7Lwnp53T6KZ5q/fD2lSxIAvpwNgA3nPMLgwaQV1Qy
         A2nKcxu/lMt/KzbewVPWCos2P1p9sMh5dDhi52tdunOOB1Jp6mkBDnebbf8ybAYzAOvb
         f0iA==
X-Gm-Message-State: APjAAAVAmnvy3Pl5F283uKbLjmGKqF5RoNS0rUEzP93FKwkzCVe6lNi5
	KLdbwTeAhbgShbXgiAK6j7B0Ja4U0iJtspwKrb5eFpudhh8VDy0FNcMqzmL5RpLB2JeeCzZLg93
	jTveHqhLvrPId+wvZOfxykvkw362iDtMCtbH0Rgdm+p+Uoqx6ZVoRK7hcGiiRsFw=
X-Received: by 2002:ac8:3f33:: with SMTP id c48mr32517873qtk.347.1557868326632;
        Tue, 14 May 2019 14:12:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzSZ8Y+07TPORwqgDYtQYX/qem9ISvYHP6sx6Ao/IK6ueN05j9K0MUL7oZy1BDYgm88grM8
X-Received: by 2002:ac8:3f33:: with SMTP id c48mr32517831qtk.347.1557868325994;
        Tue, 14 May 2019 14:12:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557868325; cv=none;
        d=google.com; s=arc-20160816;
        b=jnwXYRdpqQfNnFMrwcrTPUUhnoubwF1IC9Yd0hpYYCHAuvEQRQ2USaxBZCQfA2GjMx
         Iq/YxgjGKCOnvbv7byUq1IlVaW3jRSAklzLcLZckSikf3LjfqvCvpdqQSBUlUfeOkeQE
         V82peCv9Lr9QibuhCx9sHaUQSF4AYedBea4vY6vROjGEtzJtOhwxBNcQg4v5AJilQ8rC
         AO7yHgEc1gKCbV3R5zBjnn8IeM8ALDoL0V0wCSV4rUds2Z30BdxnfkIykjhzVti/yN+7
         vejkFyqYEFtbrVnK7OcJw1MtVb0oGCc9XrBRkz/vJlKB4ZHfNRmPE6MiYjI3/R5RpPOC
         pAxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=+Wr4AoBQ+WbNrtNZIjnG9aEHD3jB7iv08RurNxCwk54=;
        b=KxHoTZiAO+/lJ9W0mBKvW51c4/swHeK1zwpdqpEelEMo2cfdXZAR0paIUVaEUu1R1p
         fEiLKXcqqIoXZ/p6GIR3KHCoDjM4IRLoK294aSQkKjc1WCfzMshN6N36gwj7yBUW9wMg
         lXX3Ey57CY5sEnibOFPsBYy/RFgMYBTh87ArmnnSXuZ8Ho2Lg/BXYknFsD6irL3ooOvn
         9aWZkAbV6d9dCj7u8Ga6t1pF313MrqDQeNNg+PxBlESrmAwQQkTIqyUBHyIRs0+a3pHR
         Hxu7jKMXgdilGkWU8hdRdytdUu2s3L2L5QlmZdsajBinq4LXr2oo4sM+dISBS3trpGmP
         4Ewg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=eZvkGVIB;
       spf=neutral (google.com: 40.107.68.55 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680055.outbound.protection.outlook.com. [40.107.68.55])
        by mx.google.com with ESMTPS id d19si3351809qtn.150.2019.05.14.14.12.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 14 May 2019 14:12:05 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.68.55 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.68.55;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=eZvkGVIB;
       spf=neutral (google.com: 40.107.68.55 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+Wr4AoBQ+WbNrtNZIjnG9aEHD3jB7iv08RurNxCwk54=;
 b=eZvkGVIBeP4DlpRrYqiY6bq9iQPg8OjNC/Bp4p8q5IE2DaUdCQU4zhat/ZJkNM1KPU2mva/XPoy5Rm4TntRYGfoX2sJzRQEwteIVgU+fkdLk/PcN4mXxm3Mzd8Fh0EpNUS6b6eV0jyTYNgFIBw9nmygawMkXAIrPEJzT7IZEGI8=
Received: from MN2PR12MB3949.namprd12.prod.outlook.com (10.255.238.150) by
 MN2PR12MB2989.namprd12.prod.outlook.com (20.178.241.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1878.25; Tue, 14 May 2019 21:12:04 +0000
Received: from MN2PR12MB3949.namprd12.prod.outlook.com
 ([fe80::b9af:29f1:fcab:6f6f]) by MN2PR12MB3949.namprd12.prod.outlook.com
 ([fe80::b9af:29f1:fcab:6f6f%4]) with mapi id 15.20.1878.024; Tue, 14 May 2019
 21:12:04 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: "Deucher, Alexander" <Alexander.Deucher@amd.com>, Jerome Glisse
	<jglisse@redhat.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "airlied@gmail.com"
	<airlied@gmail.com>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "alex.deucher@amd.com"
	<alex.deucher@amd.com>
Subject: Re: [PATCH 2/2] mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for
 non-blocking
Thread-Topic: [PATCH 2/2] mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for
 non-blocking
Thread-Index: AQHVB2oH3gumKK8uVkW/G1cJvzIbZqZkyv6AgASsjwCAAAyWgIABoGIA
Date: Tue, 14 May 2019 21:12:04 +0000
Message-ID: <cf8bdc0c-96b9-8a73-69ca-a4aae11f36d5@amd.com>
References: <20190510195258.9930-1-Felix.Kuehling@amd.com>
 <20190510195258.9930-3-Felix.Kuehling@amd.com>
 <20190510201403.GG4507@redhat.com>
 <65328381-aa0d-353d-68dc-81060e7cebdf@amd.com>
 <BN6PR12MB1809F26E6AF74BE9F96DB22DF70F0@BN6PR12MB1809.namprd12.prod.outlook.com>
In-Reply-To:
 <BN6PR12MB1809F26E6AF74BE9F96DB22DF70F0@BN6PR12MB1809.namprd12.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
x-clientproxiedby: YTOPR0101CA0061.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:14::38) To MN2PR12MB3949.namprd12.prod.outlook.com
 (2603:10b6:208:16b::22)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 48f27e2d-0ef1-4474-c083-08d6d8b0d057
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:MN2PR12MB2989;
x-ms-traffictypediagnostic: MN2PR12MB2989:
x-ms-exchange-purlcount: 2
x-microsoft-antispam-prvs:
 <MN2PR12MB298911B82CC25BA9B49AFEB692080@MN2PR12MB2989.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3383;
x-forefront-prvs: 0037FD6480
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(376002)(346002)(39860400002)(396003)(199004)(189003)(99286004)(66946007)(71190400001)(71200400001)(52116002)(6512007)(76176011)(31696002)(86362001)(66476007)(66556008)(73956011)(256004)(14444005)(64756008)(66446008)(66574012)(26005)(446003)(478600001)(6436002)(72206003)(36756003)(25786009)(966005)(110136005)(54906003)(58126008)(6116002)(3846002)(66066001)(4326008)(65956001)(65806001)(6506007)(386003)(53546011)(6306002)(102836004)(316002)(2906002)(64126003)(6486002)(31686004)(486006)(476003)(305945005)(14454004)(53936002)(81156014)(81166006)(229853002)(186003)(2616005)(7736002)(11346002)(5660300002)(8936002)(6246003)(65826007)(8676002)(68736007);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR12MB2989;H:MN2PR12MB3949.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 g8k529k8oFqSej3kV6GCS0dudwmO0TQmeUuQS7npheoukfhYS49HH/IvO08Zu6Qz6DxAzmBowjl2MQTRbycjUdmIQjQS6FrWb3EP6lVRHL0Qn1NL0ySMqyTriFGPo+e8KTbYADeVAs7ibWeY7ErtBJPgT2L6OS4OLCLrI5lSyhCJp2xr6GnCnA33V50ROKN3ThQ4TvvsUESpX+ap9RiwVEnuMt+F7IOpCBv25LgXnmXEHyhitEiGgIQUW5ecI4teoByKV5xT4RAham3vqJtEOSzoW21MkkvjSwQUmwt1zJ2rdyprNuM7sjF40OAxy1ixuY6ko8OhvPljGGdjwc/V4/MbWj1btnymjVFIIH4rboE3Ff75uIMsL9SLZKJHpdO2U5Lgn7sG4Wxbm9n6IBnPOKdiiuMPW/xkh/oDv+CWWO4=
Content-Type: text/plain; charset="Windows-1252"
Content-ID: <47E40BF62063C549A60D2FA213D1D422@namprd12.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 48f27e2d-0ef1-4474-c083-08d6d8b0d057
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 May 2019 21:12:04.2660
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR12MB2989
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019-05-13 4:21 p.m., Deucher, Alexander wrote:
> [CAUTION: External Email]
> I reverted all the amdgpu HMM patches for 5.2 because they also=20
> depended on this patch:
> https://cgit.freedesktop.org/~agd5f/linux/commit/?h=3Ddrm-next-5.2-wip&id=
=3Dce05ef71564f7cbe270cd4337c36ee720ea534db
> which did not have a clear line of sight for 5.2 either.

When was that? I saw "Use HMM for userptr" in Dave's 5.2-rc1 pull=20
request to Linus.


Regards,
 =A0 Felix


>
> Alex
> ------------------------------------------------------------------------
> *From:* amd-gfx <amd-gfx-bounces@lists.freedesktop.org> on behalf of=20
> Kuehling, Felix <Felix.Kuehling@amd.com>
> *Sent:* Monday, May 13, 2019 3:36 PM
> *To:* Jerome Glisse
> *Cc:* linux-mm@kvack.org; airlied@gmail.com;=20
> amd-gfx@lists.freedesktop.org; dri-devel@lists.freedesktop.org;=20
> alex.deucher@amd.com
> *Subject:* Re: [PATCH 2/2] mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for=20
> non-blocking
> [CAUTION: External Email]
>
> Hi Jerome,
>
> Do you want me to push the patches to your branch? Or are you going to
> apply them yourself?
>
> Is your hmm-5.2-v3 branch going to make it into Linux 5.2? If so, do you
> know when? I'd like to coordinate with Dave Airlie so that we can also
> get that update into a drm-next branch soon.
>
> I see that Linus merged Dave's pull request for Linux 5.2, which
> includes the first changes in amdgpu using HMM. They're currently broken
> without these two patches.
>
> Thanks,
> =A0=A0 Felix
>
> On 2019-05-10 4:14 p.m., Jerome Glisse wrote:
> > [CAUTION: External Email]
> >
> > On Fri, May 10, 2019 at 07:53:24PM +0000, Kuehling, Felix wrote:
> >> Don't set this flag by default in hmm_vma_do_fault. It is set
> >> conditionally just a few lines below. Setting it unconditionally
> >> can lead to handle_mm_fault doing a non-blocking fault, returning
> >> -EBUSY and unlocking mmap_sem unexpectedly.
> >>
> >> Signed-off-by: Felix Kuehling <Felix.Kuehling@amd.com>
> > Reviewed-by: J=E9r=F4me Glisse <jglisse@redhat.com>
> >
> >> ---
> >>=A0=A0 mm/hmm.c | 2 +-
> >>=A0=A0 1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/mm/hmm.c b/mm/hmm.c
> >> index b65c27d5c119..3c4f1d62202f 100644
> >> --- a/mm/hmm.c
> >> +++ b/mm/hmm.c
> >> @@ -339,7 +339,7 @@ struct hmm_vma_walk {
> >>=A0=A0 static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long =
addr,
> >>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 bool write_fault, uint64_t *pfn)
> >>=A0=A0 {
> >> -=A0=A0=A0=A0 unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FL=
AG_REMOTE;
> >> +=A0=A0=A0=A0 unsigned int flags =3D FAULT_FLAG_REMOTE;
> >>=A0=A0=A0=A0=A0=A0=A0 struct hmm_vma_walk *hmm_vma_walk =3D walk->priva=
te;
> >>=A0=A0=A0=A0=A0=A0=A0 struct hmm_range *range =3D hmm_vma_walk->range;
> >>=A0=A0=A0=A0=A0=A0=A0 struct vm_area_struct *vma =3D walk->vma;
> >> --
> >> 2.17.1
> >>
> _______________________________________________
> amd-gfx mailing list
> amd-gfx@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/amd-gfx

