Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47370C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:29:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 049B6218D0
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:29:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="bR3K6vBa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 049B6218D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99CC98E0002; Thu, 13 Jun 2019 13:29:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94DA28E0001; Thu, 13 Jun 2019 13:29:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 814278E0002; Thu, 13 Jun 2019 13:29:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id 58FB08E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:29:17 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id m2so1976757uap.12
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:29:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Hwm1tvsKbGpRo9J2H8Em3256KGsQwcdi/VSqqm65kwU=;
        b=Fs5t3pgHVVLSTkCp2GOtozEIJZHuCZgPRBRCeLtRC/hUbGMSfdWoTreF9ePIj1R5mY
         mHMhpZUNOHDKw/9vl+CQt92WoskkYYcSrzU/TeHgyGX2ruWwuFO+28VRHeT06s59RITH
         2Ql7J0zyH8RPSK0A8CyK+JVvadogXe2PJJey/Y8qmycsGEYWlDCyOFCDcVf5h0j3HJ66
         V5Q40xM6odc4RsBw92OkFR7pGBALCf5EKxEu224SM3lxYE5aUE9jn3rFBE+dYXaoJ+tG
         6oxr3lMX1CQ3cApBRj9LJUy0Kdu8WgpnS5jrCl+uXZZZYyW8EpBYeakFuXwyUtekSL+M
         HKRg==
X-Gm-Message-State: APjAAAXQvb0DMzoyw9ycxCfx6mAQIPJEpiBmZjn0M2yuYsDjINL4rJL6
	n1F6m0EuS4EN0R5wQ5Y5BoIYcka0hKR/8Twf9BjEovxuQDt9R5u9hRbb5xMj/1ftGmK0E5mCfMp
	6+YnfqYIMVhU5CnOfxv4iWNkwkbG84L2GvmUJhF1x3ArSIIOP5/1gGEq05T8USoVAeQ==
X-Received: by 2002:ab0:e08:: with SMTP id g8mr21179048uak.32.1560446957028;
        Thu, 13 Jun 2019 10:29:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7jUmJwMyc7iqCLfWhM9muE5nI/RJy3ZNdR2ZBfaRr/ZBC1EEsl7rwsy4NesDB+WjCAvVt
X-Received: by 2002:ab0:e08:: with SMTP id g8mr21178960uak.32.1560446956188;
        Thu, 13 Jun 2019 10:29:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560446956; cv=none;
        d=google.com; s=arc-20160816;
        b=buTcprtmMGlF39SejeD49yodSatB4QULgt2f/uZb3x3rXdLEga8V09KkXKCzuG+NQR
         LX0F/DdP+zJKf83hfoD7mW+L6Uzr9n+8aM1RxFkm0b8GL+29AirSGHKF0ioVoxIuvtXL
         ZIFJHSwiOWr4beo+YLELLzWNwdFSipIPTfPrGDczJRBMYv1aCmOaXeOXbF8V2oQxO/U2
         bKIr4ysIUw7kxxuEgWKrZasNLA81Uuf3C3/OYWuAkaloSkms2d7jCGntAjyReD/mx6aO
         Uazg7mkHsZn1AkX0r51ads8bzRj49IR2qqIqCza4Gop27N2IX9R9DmgUSGrFasJWL6+p
         DErw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Hwm1tvsKbGpRo9J2H8Em3256KGsQwcdi/VSqqm65kwU=;
        b=UbPpDSbOsizv38hDeC/76OzMxtzMyRFtZz8dTJ6+TWcLNY+hAPbluqrAqO/g1gKx1l
         1reYSNLYLLT/0NNslijFbI0NpKxzCC99I68O8IEVtnVXb4i1TLHMTv0YxTmKG/6powZy
         iTK1oCiBB1wNf/BlC7SNnDaUrsO2wt/Kdd80tCwP73682Wk4NLQnL2NvFGwboUNbx191
         rLT2IUtb1pk7l/2IxlTob7dwtiE8T0JAqCRqFQ+hec0gIAfCJ6V1duj5oqdyfjp12yx5
         wxnFqpwYNyJM+xDEQUpEZUgQV2P+fcvI5NNaFQY9UI1g/hgHtkK9HsscDp92BZ7M+WMF
         KHIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=bR3K6vBa;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.74.89 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740089.outbound.protection.outlook.com. [40.107.74.89])
        by mx.google.com with ESMTPS id k22si185448vsj.46.2019.06.13.10.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 10:29:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.74.89 as permitted sender) client-ip=40.107.74.89;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=bR3K6vBa;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.74.89 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Hwm1tvsKbGpRo9J2H8Em3256KGsQwcdi/VSqqm65kwU=;
 b=bR3K6vBaMftvslR+9iLuITBnrdRy8CmpCDsWjrER+a9SfapXiJehwLGGzUZoPSZ81SnWzC3FB4V6bib2rlq3dbJem4bTeEhP4M2u/gxB1jHijQEx6mFpESdd46paEbyl/Ollifv9wYR7G4fToWhXFxDBb50W3mRUX8ppZu7q9pE=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB5606.namprd05.prod.outlook.com (20.177.186.155) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.10; Thu, 13 Jun 2019 17:29:14 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::134:af66:bedb:ead9]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::134:af66:bedb:ead9%3]) with mapi id 15.20.1987.008; Thu, 13 Jun 2019
 17:29:14 +0000
From: Nadav Amit <namit@vmware.com>
To: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>
CC: Alexander Graf <graf@amazon.com>, Marius Hillenbrand <mhillenb@amazon.de>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Kernel
 Hardening <kernel-hardening@lists.openwall.com>, Linux-MM
	<linux-mm@kvack.org>, Alexander Graf <graf@amazon.de>, David Woodhouse
	<dwmw@amazon.co.uk>, the arch/x86 maintainers <x86@kernel.org>, Peter
 Zijlstra <peterz@infradead.org>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
Thread-Topic: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
Thread-Index: AQHVIYeR2j5VBjf3eUa9RwR3XpurVaaZNvCAgACL1YCAAAIdgIAAExeA
Date: Thu, 13 Jun 2019 17:29:14 +0000
Message-ID: <70BEF143-00BA-4E4B-ACD7-41AD2E6250BE@vmware.com>
References: <20190612170834.14855-1-mhillenb@amazon.de>
 <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
 <CALCETrXHbS9VXfZ80kOjiTrreM2EbapYeGp68mvJPbosUtorYA@mail.gmail.com>
 <459e2273-bc27-f422-601b-2d6cdaf06f84@amazon.com>
 <CALCETrVRuQb-P7auHCgxzs5L=qA2_qHzVGTtRMAqoMAut0ETFw@mail.gmail.com>
 <f1dfbfb4-d2d5-bf30-600f-9e756a352860@intel.com>
In-Reply-To: <f1dfbfb4-d2d5-bf30-600f-9e756a352860@intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3138119f-192d-4a66-3623-08d6f024a7b4
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR05MB5606;
x-ms-traffictypediagnostic: BYAPR05MB5606:
x-microsoft-antispam-prvs:
 <BYAPR05MB560608061DABE837F6843E9DD0EF0@BYAPR05MB5606.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(136003)(346002)(376002)(366004)(39860400002)(189003)(199004)(186003)(54906003)(478600001)(7416002)(73956011)(66066001)(68736007)(66446008)(2906002)(53936002)(66556008)(256004)(6512007)(229853002)(66476007)(102836004)(86362001)(26005)(316002)(110136005)(66946007)(99286004)(76116006)(6436002)(25786009)(14444005)(64756008)(8676002)(6116002)(476003)(81166006)(2616005)(81156014)(3846002)(14454004)(8936002)(71200400001)(71190400001)(6506007)(6486002)(446003)(33656002)(486006)(5660300002)(76176011)(305945005)(7736002)(11346002)(36756003)(4326008)(6246003)(53546011);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB5606;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 tfM+xbizek82UJYpE3G8pFbHDAIfKne8E0piLlxImGYOVsTd/BtZ271EEEBwBUKnQvUnNFfwmQT1AWlkDaI64IcidF58phoH4FFXKV+gGo0vBj3kSsnAaqrPulXuCVHqEFuUF5hDg72K8XxAUVavRX1pXZWXlxr8VZGrNncEExqK7Hs0NTkNgUAknDyN82STOU8RYlsHp+BtEeAJRq409Z6t7EGI3WeaXa/VA5/qyObjcInqbybd8D1Dbxp6ITMC4VECnHQADw6XowyZ6n2d4iF71avLFRAzZjU0Bu/k8WE4sSB9NdS6RLPPiL2wIKWCWpBvcsLPcNHqd3aYwpCLSnGUB3Rbx4iIoqNfkaEgCjGYZakqV5ybKCcrxnN4p2TPL/pgDFyFVeAEhm6GO55EfdS9zjmTn5GBs/NNoh5UfME=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <561CA2F7569D154F92346C3F1D71EDE0@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3138119f-192d-4a66-3623-08d6f024a7b4
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 17:29:14.0329
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB5606
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Jun 13, 2019, at 9:20 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
> On 6/13/19 9:13 AM, Andy Lutomirski wrote:
>>> It might make sense to use it for kmap_atomic() for debug purposes, as
>>> it ensures that other users can no longer access the same mapping
>>> through the linear map. However, it does come at quite a big cost, as w=
e
>>> need to shoot down the TLB of all other threads in the system. So I'm
>>> not sure it's of general value?
>> What I meant was that kmap_atomic() could use mm-local memory so that
>> it doesn't need to do a global shootdown.  But I guess it's not
>> actually used for real on 64-bit, so this is mostly moot.  Are you
>> planning to support mm-local on 32-bit?
>=20
> Do we *do* global shootdowns on kmap_atomic()s on 32-bit?  I thought we
> used entirely per-cpu addresses, so a stale entry from another CPU can
> get loaded in the TLB speculatively but it won't ever actually get used.
> I think it goes:
>=20
> kunmap_atomic() ->
> __kunmap_atomic() ->
> kpte_clear_flush() ->
> __flush_tlb_one_kernel() ->
> __flush_tlb_one_user() ->
> __native_flush_tlb_one_user() ->
> invlpg
>=20
> The per-cpu address calculation is visible in kmap_atomic_prot():
>=20
>        idx =3D type + KM_TYPE_NR*smp_processor_id();

From a security point-of-view, having such an entry is still not too good,
since the mapping protection might override the default protection. This
might lead to potential W+X cases, for example, that might stay for a long
time if they are speculatively cached in the TLB and not invalidated upon
kunmap_atomic().

Having said that, I am not too excited to deal with this issue. Do people
still care about x86/32-bit? In addition, if kunmap_atomic() is used when
IRQs are disabled, sending a TLB shootdown during kunmap_atomic() can cause
a deadlock.

