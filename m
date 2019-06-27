Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34C4AC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 11:18:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C66C5205F4
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 11:18:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=os.amperecomputing.com header.i=@os.amperecomputing.com header.b="n84QFvk5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C66C5205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F51C6B0003; Thu, 27 Jun 2019 07:18:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57EBB8E0003; Thu, 27 Jun 2019 07:18:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D1378E0002; Thu, 27 Jun 2019 07:18:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 10EB36B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 07:18:04 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id b4so966435otf.15
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 04:18:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=rPksX9kTKCzYCXwG24gRwSMKH1dwPvwYcTm0uG09s8o=;
        b=Jt/GujtoC22qGR7wgPS5L5D6pq44PRH79Bm1Ida7AJM2UGgVS6hhHxc1edw/3Zh/Cf
         +DUUwJaQzbR2t0LStPYuwRYj7hlc8KZ0sRgC5nqdfc1XQc9wMaC6yCXz10FWe3CGqkEA
         9uleaY1NHMgc89BvLXiNs889JUdJYZJ9LqOBZuQsk5c6my+flZvHQVqKSbJvXVxZts7H
         yCTp7gE0VrRjRuiUBvuXQ46ASttcK/jM6dekwoI0YuOzkP6+inID0gEiUjSjlcoiJQHU
         t82barYwfRJjD8RqBhCls42aX7MKM6h6LjSGoV0bKvPEY0/9BgoLYGP2RZ7KbvAXDHyE
         ftJw==
X-Gm-Message-State: APjAAAXudgy9nGde8+a6RwCq5AOeGNul/wFsoG9vmCa27Y/ESfyIQs9u
	iSVrvHVuUDKKictjVX0FGNS6NWkFgNOIfMWhfnYet18ZXGY/NyZ7753YiAkWqBAWO7HHGUO/lbu
	4YCoVl7lz4/sFPLjdBLA1GfKPUCFNFAtyLkfFo7gLlfYP7gWdCvH8pPv+3Qw7Mh4fcQ==
X-Received: by 2002:aca:ac42:: with SMTP id v63mr1778671oie.46.1561634283614;
        Thu, 27 Jun 2019 04:18:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwh820wP2kjeA04MMx6edc0XI2BgQmO+v0/EZ6mAi255rVfDQ+JkY6GeaRau1XHF7epy0ID
X-Received: by 2002:aca:ac42:: with SMTP id v63mr1778633oie.46.1561634282670;
        Thu, 27 Jun 2019 04:18:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561634282; cv=none;
        d=google.com; s=arc-20160816;
        b=QXoWeK6YPnMcXYI/MLL8tDxrtomGjm1/wGAuEU/7bq7VWNY35paEBcHIgLaioslTW+
         ejglHgHDFYK1UJvQf/sdisX8I4IVx8Wbh8s2txFhTkU00kWJoOjTlpmXepSZFk4WJTka
         PP5Kpvckz57vgUKsYeJgYYwr97MxMux9hMDDra/EsbaSO4wwii09CdxVftI7oQv/RLmd
         D8v3bAIonduUsk7eQzzVjeRhPitmIFyfn8V2Kewg3GNBozhbBzNc5z0ZR739rhTLgxA9
         84nXT84AwzYD5DyvMftSI2v/k/iFAdsbGyx7uZKcOh3O/0nS0cIyA7cwvba/lHpuf0nK
         Mcvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=rPksX9kTKCzYCXwG24gRwSMKH1dwPvwYcTm0uG09s8o=;
        b=hpu7a3CI/1CUWTsBtMaHMwixSpuCWtuDf5Hqe5BIEnuOM/HemgiJFW6CwZLRQtOfL9
         LvFJeNhPotIc2ePGqMELA7GnmtdXQVTl4l5qAUH4xkd+JfhZJ6qwXgBhrQ2AWgxvYsFr
         0Ltx+QEVtf735FBReQGjI2kq26tUw5ngmX6UkKLmaHYGaA8wQX8OU2SQ5AEoZhTshEeI
         iCZCQeegK2L4lfGH/UuCiK2TpkvmKIgRRwyBM1S3p7W8YixX0gj+jy4wGL3d7Gh0Gw79
         lvpVt5znFq5lQNkhJPsnKVX/SxmDd4mccwq/1xakEmtVpVJwKi+Fc6r0MfStLcf+WuZI
         mxjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=n84QFvk5;
       spf=pass (google.com: domain of aaron@os.amperecomputing.com designates 40.107.76.90 as permitted sender) smtp.mailfrom=aaron@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760090.outbound.protection.outlook.com. [40.107.76.90])
        by mx.google.com with ESMTPS id s11si1419089otq.322.2019.06.27.04.18.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Jun 2019 04:18:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of aaron@os.amperecomputing.com designates 40.107.76.90 as permitted sender) client-ip=40.107.76.90;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=n84QFvk5;
       spf=pass (google.com: domain of aaron@os.amperecomputing.com designates 40.107.76.90 as permitted sender) smtp.mailfrom=aaron@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=os.amperecomputing.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=rPksX9kTKCzYCXwG24gRwSMKH1dwPvwYcTm0uG09s8o=;
 b=n84QFvk5ZqMJzHVSoL1riHfmgpB591XYvxtW7Tob7LiAj5ePFXt6flNRGsXU0UXMNNePBEJ5/zMv+z8spKYpK6VrjGReTc2hZqPvDdlceGH/M1cGL9w5m110d8dTba9/kA+Z0sY5mrGBDbrmPGFXvSqzlr1+zwj2DE+i6JqE5G0=
Received: from DM6PR01MB4825.prod.exchangelabs.com (20.177.218.222) by
 DM6PR01MB4906.prod.exchangelabs.com (20.176.119.95) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.18; Thu, 27 Jun 2019 11:17:59 +0000
Received: from DM6PR01MB4825.prod.exchangelabs.com
 ([fe80::390e:9996:6dec:d60f]) by DM6PR01MB4825.prod.exchangelabs.com
 ([fe80::390e:9996:6dec:d60f%6]) with mapi id 15.20.2032.016; Thu, 27 Jun 2019
 11:17:59 +0000
From: Aaron Lindsay OS <aaron@os.amperecomputing.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Hoan Tran OS <hoan@os.amperecomputing.com>, Catalin Marinas
	<catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton
	<akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka
	<vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>, Pavel Tatashin
	<pavel.tatashin@microsoft.com>, Mike Rapoport <rppt@linux.ibm.com>, Alexander
 Duyck <alexander.h.duyck@linux.intel.com>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael
 Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin"
	<hpa@zytor.com>, "David S . Miller" <davem@davemloft.net>, Heiko Carstens
	<heiko.carstens@de.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian
 Borntraeger <borntraeger@de.ibm.com>, "open list:MEMORY MANAGEMENT"
	<linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-s390@vger.kernel.org"
	<linux-s390@vger.kernel.org>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Open Source
 Submission <patches@amperecomputing.com>
Subject: Re: [PATCH 0/5] Enable CONFIG_NODES_SPAN_OTHER_NODES by default for
 NUMA
Thread-Topic: [PATCH 0/5] Enable CONFIG_NODES_SPAN_OTHER_NODES by default for
 NUMA
Thread-Index: AQHVK6WT5IKFNhd5LECqV06L4uyCQKatFN0AgAJHxoA=
Date: Thu, 27 Jun 2019 11:17:58 +0000
Message-ID: <20190627111755.GJ7133@okra.localdomain>
References: <1561501810-25163-1-git-send-email-Hoan@os.amperecomputing.com>
 <CAADWXX8wdEPNZ26SFJUfwrhQson3HPTrZ7D2jju3RhEeMuc+QQ@mail.gmail.com>
In-Reply-To:
 <CAADWXX8wdEPNZ26SFJUfwrhQson3HPTrZ7D2jju3RhEeMuc+QQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR04CA0016.namprd04.prod.outlook.com
 (2603:10b6:208:d4::29) To DM6PR01MB4825.prod.exchangelabs.com
 (2603:10b6:5:6b::30)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=aaron@os.amperecomputing.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2600:3c03::f03c:91ff:febb:cdda]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 41020974-51cb-4a3d-32c1-08d6faf11be8
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR01MB4906;
x-ms-traffictypediagnostic: DM6PR01MB4906:
x-microsoft-antispam-prvs:
 <DM6PR01MB490676652E3A18AA2A5EE7738AFD0@DM6PR01MB4906.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 008184426E
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(366004)(136003)(376002)(346002)(39850400004)(396003)(189003)(199004)(54906003)(71200400001)(71190400001)(52116002)(46003)(8936002)(25786009)(8676002)(316002)(6116002)(81166006)(81156014)(1076003)(99286004)(446003)(186003)(11346002)(7416002)(386003)(6506007)(478600001)(486006)(102836004)(476003)(4326008)(33656002)(14454004)(76176011)(2906002)(14444005)(256004)(305945005)(5660300002)(7736002)(66946007)(6436002)(73956011)(45080400002)(9686003)(6512007)(68736007)(229853002)(66556008)(64756008)(6486002)(66476007)(86362001)(66446008)(107886003)(53936002)(6916009)(6246003);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR01MB4906;H:DM6PR01MB4825.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:0;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 S716oI9qHr9HoTifdQqNcAn+wRHxHq8BZGRzkdC9r3kNYPJ0F8JFHXzYx0SUOMq7ebgM62lCx+oVLzPlCypRkfyBve7WzA8ySs9nYANe2AjFY4bNJfJIZ2OONOm8zg0DMl/4TJtLFA8wg7EhvQp8zAFDre7IfLPXk/TLYKEM9ryqa+D1HtNpPnIMjuloBa7MejlWhifKAIVoL57h6X9ZzWrr9dbVpntQYKJGa8/ttYTwvgdVSPEmzauMFrB1ym2iCTn/fzAb2ttKXWkYyk88Yyfoa1DW6AKYrLYSJ3PiIs2rUeNjtGE4mmV/IcZCOUY7REJeaTXGK4Yit4lDLoLYa0JjtqNSjERT40U7jXVxNvg5Q2kFiZXA3krua9Em2Km6etMvmIhXSFW1sWtXqxljUVvr2n6EBUlal8Pd9Rhu+Oc=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <DE70FA20B7464849A9C1EC473C6D4C0A@prod.exchangelabs.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 41020974-51cb-4a3d-32c1-08d6faf11be8
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Jun 2019 11:17:59.0263
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3bc2b170-fd94-476d-b0ce-4229bdc904a7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Aaron@os.amperecomputing.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR01MB4906
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Jun 26 08:28, Linus Torvalds wrote:
> This is not a comment on the patch series itself, it is a comment on the =
emails.
>=20
> Your email is mis-configured and ends up all being marked as spam for
> me, because you go through the wrong smtp server (or maybe your smtp
> server itself is miconfigured)
>=20
> All your emails fail dmarc, because the "From" header is
> os.amperecomputing.com, but the DKIM signature is for
> amperemail.onmicrosoft.com.

It appears Microsoft enables DKIM by default, but does so using keys
advertised at *.onmicrosoft.com domains, and our IT folks didn't
initially notice this. We believe we've rectified the situation, so
please let us know if our emails (including this one) continue to be an
issue.

> End result: it wil all go into the spam box of anybody who checks DKIM.

Interestingly, *some* receiving mail servers (at least gmail.com) were
reporting DKIM/DMARC pass for emails sent directly from our domain
(though not those sent through a mailing list), which I believe allowed
our IT to falsely think they had everything configured correctly.

-Aaron

