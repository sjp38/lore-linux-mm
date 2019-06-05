Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F6B2C282DE
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 08:35:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5DC62075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 08:35:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=marvell.com header.i=@marvell.com header.b="esH6/ahm";
	dkim=pass (1024-bit key) header.d=marvell.onmicrosoft.com header.i=@marvell.onmicrosoft.com header.b="Y/yiUMPC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5DC62075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=marvell.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31DFE6B0008; Wed,  5 Jun 2019 04:35:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A8D26B000A; Wed,  5 Jun 2019 04:35:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D44B6B000C; Wed,  5 Jun 2019 04:35:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id D24326B0008
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 04:35:35 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id s204so9045643yws.17
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 01:35:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:mime-version;
        bh=CD1TDIaGtrgyqSXfr16MQaL9Y0uMm1JTRdS3eT2ZtEY=;
        b=HzICwBbccke8HH/LiOvRP2P/8ZJPBgqtwdPDjAY96Ru7khwT4vNOtTtFnX7Kfw/3Sa
         4ss4OX95OHJZv4LLl1Jovaxxtzs9si56DIJqlnUYhLjZyHJsxOsxhzlyBxb4LlGPP72U
         jaS4+DJg/+uT1PHNJyQAkOlxgW3AA5GOJ9NdwX4Zq/9YRmba024vIU9SE09tjoPElMPc
         R2DABaEfnZIKWBj/wPpbk3mA9OBFRkm+mdNoFCE+XCAHrseSpf/um2P1qvmB+7jevlAQ
         ZDEWJd3QYdPLNG5OcCpg4DFFaDy+J/IdAuOXlpQikhHa7oIfJXfsJYlP3HkPM1/eCpBd
         bK5g==
X-Gm-Message-State: APjAAAXUJt1kbj1gHcoSNhYi+01i/l/7tPurtvIo2HWkk2Y1AuDtjv8E
	SpS2vgenpWZ62+COVdjd1+8JoStMYn1l+eOpkqWsL1lQxbN3dFJr8JEUHThd/gMbWNeAzQmxTCu
	QUq7wAEfPPc2sejGbnBgLCpCB5TTP1LNYGi5xorEVMG5MLWHbz4bS/Ja59UoP4PKpuQ==
X-Received: by 2002:a25:94b:: with SMTP id u11mr18645304ybm.227.1559723735419;
        Wed, 05 Jun 2019 01:35:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx32wqkhuxhu90zePR8mIzHphULHtaqaTqzAJ9e8dBGv90Rb66uS6sZhpaDaEPpoB52bL57
X-Received: by 2002:a25:94b:: with SMTP id u11mr18645271ybm.227.1559723734308;
        Wed, 05 Jun 2019 01:35:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559723734; cv=none;
        d=google.com; s=arc-20160816;
        b=fgfHg6YOdkvVInVPuMBgFPMdDyUxx2p+clJi6kQOPbDsEELNzJ9kEcHhhmCtgfZ//2
         rprwV+UkiRrHhxLTpCPkcYYiq/n7sS/7kOP5ZIonuN7rGCeQwOyar0ZJFIbT8RX28JyW
         /VQ/kQNO/TCQkpvnZ0ig7P6gUiPw4YzvikfVGjOds5h3QHbE/xzDzkvhll9WHI5N/7y1
         eOSCVzKCKsqx0AkPPJaJxM21f/f+W4xQK68JEUtTdrJYxMkNjJDgoafhmH0zyOZ78ids
         +KUTxccXqNLCgzq777Dhrc5CyPqvAGEPWVjJk2IVswJowlP9fXC4ihn3okwkc8DMdIDv
         PS1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-language:accept-language:in-reply-to
         :references:message-id:date:thread-index:thread-topic:subject:cc:to
         :from:dkim-signature:dkim-signature;
        bh=CD1TDIaGtrgyqSXfr16MQaL9Y0uMm1JTRdS3eT2ZtEY=;
        b=f0m04k0B5BVP2oIiXFp3X76OrkwEHipGeJbKE5hwr54OlcLuXobNsYJ/4EsGug5R1v
         dn1sUywDWYbXn+DVEalzOfXjKuJnEV6yWxolFN9xc9BmUnYCk+e/bM6Shgkl/wc+Nmf+
         zSTYyqnjLk7kfUcVaoHj6OJ83uu7+hgtePZr+RdOs4jcltC6eYgtcw8jlejnf2LcRY59
         3NZrkN8gR3RJOv1O+UDx0JTrgiFQZhHe/BUod2/j4Am4Bh6onRraWHenSnP3mflRQjkb
         dH3aHVq/RDSbOg0ntDsaMfUMWUjxCw90LO1U6oTninyt7xtyMqH28tPhyhL8XmRz/I8+
         Yieg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@marvell.com header.s=pfpt0818 header.b="esH6/ahm";
       dkim=pass header.i=@marvell.onmicrosoft.com header.s=selector2-marvell-onmicrosoft-com header.b="Y/yiUMPC";
       spf=pass (google.com: domain of prvs=3059138165=ynorov@marvell.com designates 67.231.156.173 as permitted sender) smtp.mailfrom="prvs=3059138165=ynorov@marvell.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=marvell.com
Received: from mx0b-0016f401.pphosted.com (mx0b-0016f401.pphosted.com. [67.231.156.173])
        by mx.google.com with ESMTPS id t189si6743054ywd.394.2019.06.05.01.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 01:35:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3059138165=ynorov@marvell.com designates 67.231.156.173 as permitted sender) client-ip=67.231.156.173;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@marvell.com header.s=pfpt0818 header.b="esH6/ahm";
       dkim=pass header.i=@marvell.onmicrosoft.com header.s=selector2-marvell-onmicrosoft-com header.b="Y/yiUMPC";
       spf=pass (google.com: domain of prvs=3059138165=ynorov@marvell.com designates 67.231.156.173 as permitted sender) smtp.mailfrom="prvs=3059138165=ynorov@marvell.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=marvell.com
Received: from pps.filterd (m0045851.ppops.net [127.0.0.1])
	by mx0b-0016f401.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x557tvhM009137;
	Wed, 5 Jun 2019 01:01:20 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=marvell.com; h=from : to : cc :
 subject : date : message-id : references : in-reply-to : content-type :
 mime-version; s=pfpt0818; bh=CD1TDIaGtrgyqSXfr16MQaL9Y0uMm1JTRdS3eT2ZtEY=;
 b=esH6/ahmH6OEGGOS36N8Tw7h2FiaiUWaESjfU3N0E20wlD8tRH9lubOdv3DHDAsX0GG4
 dvN/8yAIRvZbsk1G5B6mlbpRnVOLPbq2e3tgwd5u0KUYYuvX5WDIEqh9nAHk9/ERCjYY
 2K0mtJi6OpkZX967kb+ZgIpBcdb1UTVMyB+zwBbEuO7Rqv29qv4G1hbOXw31E/onrxKC
 IoL64EGjB1+m0darAUiCfy/YgdK8T10B8lGIXWa6JGvP8/JTlHw7dOt6NoflJ5JcjtCr
 Llvi/vlPTfLt0CQI2EHRIuaMVjIgwfaq2ZzD54B6Sg9Pv8tRFvgoV36PcX1rmvj5ukhK LA== 
Received: from sc-exch03.marvell.com ([199.233.58.183])
	by mx0b-0016f401.pphosted.com with ESMTP id 2sx3kf9747-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 05 Jun 2019 01:01:20 -0700
Received: from SC-EXCH02.marvell.com (10.93.176.82) by SC-EXCH03.marvell.com
 (10.93.176.83) with Microsoft SMTP Server (TLS) id 15.0.1367.3; Wed, 5 Jun
 2019 01:01:17 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (104.47.46.59) by
 SC-EXCH02.marvell.com (10.93.176.82) with Microsoft SMTP Server (TLS) id
 15.0.1367.3 via Frontend Transport; Wed, 5 Jun 2019 01:01:16 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=marvell.onmicrosoft.com; s=selector2-marvell-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=CD1TDIaGtrgyqSXfr16MQaL9Y0uMm1JTRdS3eT2ZtEY=;
 b=Y/yiUMPCxfB2Gadu+y1y3DAJVJkHx06MZsfoZuNmSMMCtXQEiK4bt2nEIa068h/VxmhDbv7VqtzDKonzWewB0K1KAGH0M/TXwNrbbKp/KOzAxUYXZro69PDx/EMUwzlfWFPJzd5/SOm+LLjB9m85DrIMqgq0qMfCpNU5ZvRGvE0=
Received: from BN6PR1801MB2065.namprd18.prod.outlook.com (10.161.157.12) by
 BN6PR1801MB1953.namprd18.prod.outlook.com (10.161.155.18) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1943.22; Wed, 5 Jun 2019 08:01:12 +0000
Received: from BN6PR1801MB2065.namprd18.prod.outlook.com
 ([fe80::78e0:ec65:c3d1:9b27]) by BN6PR1801MB2065.namprd18.prod.outlook.com
 ([fe80::78e0:ec65:c3d1:9b27%3]) with mapi id 15.20.1965.011; Wed, 5 Jun 2019
 08:01:12 +0000
From: Yuri Norov <ynorov@marvell.com>
To: Qian Cai <cai@lca.pw>
CC: Andrey Konovalov <andreyknvl@google.com>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Andy Shevchenko
	<andriy.shevchenko@linux.intel.com>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "Yury
 Norov" <yury.norov@gmail.com>
Subject: Re: [EXT] Re: "lib: rework bitmap_parse()" triggers invalid access
 errors
Thread-Topic: [EXT] Re: "lib: rework bitmap_parse()" triggers invalid access
 errors
Thread-Index: AQHVGwKZxgwFVttJ+ESek6gBx4HB86aMraDX
Date: Wed, 5 Jun 2019 08:01:11 +0000
Message-ID: <BN6PR1801MB20655CFFEA0CEA242C088C25CB160@BN6PR1801MB2065.namprd18.prod.outlook.com>
References: <1559242868.6132.35.camel@lca.pw>,<1559672593.6132.44.camel@lca.pw>
In-Reply-To: <1559672593.6132.44.camel@lca.pw>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [50.206.22.50]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a57c1bf1-039c-4edc-bbee-08d6e98bf9d8
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BN6PR1801MB1953;
x-ms-traffictypediagnostic: BN6PR1801MB1953:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <BN6PR1801MB19535CE109AF79AF0C39D44ECB160@BN6PR1801MB1953.namprd18.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 00594E8DBA
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(136003)(366004)(346002)(39860400002)(396003)(376002)(189003)(199004)(99286004)(54906003)(478600001)(71200400001)(52536014)(74316002)(606006)(14454004)(7736002)(53546011)(256004)(5024004)(476003)(66946007)(66556008)(73956011)(71190400001)(66446008)(64756008)(3846002)(486006)(14444005)(66476007)(76116006)(11346002)(316002)(2906002)(6116002)(86362001)(446003)(8936002)(81166006)(4326008)(33656002)(966005)(30864003)(55016002)(54896002)(6306002)(9686003)(25786009)(236005)(53936002)(66066001)(76176011)(229853002)(102836004)(6436002)(7696005)(5660300002)(8676002)(68736007)(6506007)(26005)(6916009)(186003)(81156014)(6246003);DIR:OUT;SFP:1101;SCL:1;SRVR:BN6PR1801MB1953;H:BN6PR1801MB2065.namprd18.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: marvell.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: BTlts3Rg0Jx4mlPe7myE3QNgfFoNWII6Q5Z9v0IuxT3BXBVEI7R5n73NmrZ0ZCXgKpn/RFHWMTUXgPFlP5I/rfCnr8fkTwLMBqe6dASUbRbbfA8gF3fKggqrroeTZcv56QicVMlcyfOs/38VtqlHuu1Qo/84Ed4yaQrhlCL69C3aXiTTTk74I0eFurfebRKUNdIKSrpdgSTlLZr4bJTfRF5xi40VoZ8yOKxbIm9pxRDpfAnslWNs878rTFKkpOcFkX7lHDXJZRVnLjChehQJPKgH8TwVMyIpyub+yUDWDZJFx+fKpqX3UBZpqp1sO+ZgdkONZPFeQIqheI1MoRx/9jh8lhDLUfj//GYABixZv7J33yKkV3tPuW5YAZWox0U0msOSoiZ4zCvdyaKveqpzc+TnjAHmGaueyuwm3PGzo9s=
Content-Type: multipart/alternative;
	boundary="_000_BN6PR1801MB20655CFFEA0CEA242C088C25CB160BN6PR1801MB2065_"
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: a57c1bf1-039c-4edc-bbee-08d6e98bf9d8
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Jun 2019 08:01:11.8971
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 70e1fb47-1155-421d-87fc-2e58f638b6e0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: ynorov@marvell.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR1801MB1953
X-OriginatorOrg: marvell.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-05_06:,,
 signatures=0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--_000_BN6PR1801MB20655CFFEA0CEA242C088C25CB160BN6PR1801MB2065_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

(Sorry for top-posting)

I can reproduce this on next-20190604. Is it new trace, or like one you've =
posted before?

Anyways,
echo "3" > /proc/irq/XX/set_affinity
crashes my kernel like you described below.

Briefly looking, in set_affinity()->cpumask_parse() path
bitmap_parse() is called with nbits=3D=3D4096. It looks suspicious
because my system has 4 cpus, not 4k.

At the very first glance, it looks like bitmap_parse() is called with
wrong nbits, and wipes unrelated memory. It causes panic later,
while the function itself works correctly. I'll check it for more and
get back soon.

Yury
________________________________
From: Qian Cai <cai@lca.pw>
Sent: Tuesday, June 4, 2019 10:23:13 PM
To: Yuri Norov
Cc: Andrey Konovalov; linux-kernel@vger.kernel.org; Andy Shevchenko; Andrew=
 Morton; linux-mm@kvack.org
Subject: [EXT] Re: "lib: rework bitmap_parse()" triggers invalid access err=
ors

External Email

----------------------------------------------------------------------
BTW, this problem below is still reproducible after applied the series [1] =
on
the top of today's linux-next tree "next-20190604" which has already includ=
ed
the patch for the "Bad swap file entry" issue.

[1] https://lore.kernel.org/lkml/20190501010636.30595-1-ynorov@marvell.com/

On Thu, 2019-05-30 at 15:01 -0400, Qian Cai wrote:
> The linux-next commit "lib: rework bitmap_parse" triggers errors below du=
ring
> boot on both arm64 and powerpc with KASAN_SW_TAGS or SLUB_DEBUG enabled.
>
> Reverted the commit and its dependency (lib: opencode in_str()) fixed the
> issue.
>
> [   67.056867][ T3737] BUG kmalloc-16 (Tainted: G    B            ): Redz=
one
> overwritten
> [   67.056905][ T3737] --------------------------------------------------=
-----
> ----------------------
> [   67.056905][ T3737]
> [   67.056946][ T3737] INFO: 0x00000000bd269811-0x0000000039a2fb86. First=
 byte
> 0x0 instead of 0xcc
> [   67.056989][ T3737] INFO: Allocated in alloc_cpumask_var_node+0x38/0x8=
0
> age=3D0
> cpu=3D62 pid=3D3737
> [   67.057029][ T3737]        __slab_alloc+0x34/0x60
> [   67.057052][ T3737]        __kmalloc_node+0x1a8/0x860
> [   67.057086][ T3737]        alloc_cpumask_var_node+0x38/0x80
> [   67.057133][ T3737]        write_irq_affinity.isra.0+0x84/0x1e0
> [   67.057178][ T3737]        proc_reg_write+0x90/0x130
> [   67.057224][ T3737]        __vfs_write+0x3c/0x70
> [   67.057261][ T3737]        vfs_write+0xd8/0x210
> [   67.057292][ T3737]        ksys_write+0x7c/0x140
> [   67.057325][ T3737]        system_call+0x5c/0x70
> [   67.057355][ T3737] INFO: Freed in free_cpumask_var+0x18/0x30 age=3D0 =
cpu=3D62
> pid=3D3737
> [   67.057392][ T3737]        free_cpumask_var+0x18/0x30
> [   67.057427][ T3737]        write_irq_affinity.isra.0+0x130/0x1e0
> [   67.057464][ T3737]        proc_reg_write+0x90/0x130
> [   67.057525][ T3737]        __vfs_write+0x3c/0x70
> [   67.057558][ T3737]        vfs_write+0xd8/0x210
> [   67.057607][ T3737]        ksys_write+0x7c/0x140
> [   67.057643][ T3737]        system_call+0x5c/0x70
> [   67.057692][ T3737] INFO: Slab 0x00000000786814bb objects=3D186 used=
=3D49
> fp=3D0x0000000019431596 flags=3D0x3fffc000000201
> [   67.057810][ T3737] INFO: Object 0x000000005c0b6a3a @offset=3D25352
> fp=3D0x00000000a42ffc35
> [   67.057810][ T3737]
> [   67.057922][ T3737] Redzone 00000000d929958b: cc cc cc cc cc cc cc
> cc                          ........
> [   67.058024][ T3737] Object 000000005c0b6a3a: 00 00 00 00 00 00 00 04 0=
0 00
> 00
> 00 00 00 00 00  ................
> [   67.058171][ T3737] Redzone 00000000bd269811: 00 00 00 00 00 00 00
> 00                          ........
> [   67.058283][ T3737] Padding 00000000b327be67: 5a 5a 5a 5a 5a 5a 5a
> 5a                          ZZZZZZZZ
> [   67.058383][ T3737] CPU: 62 PID: 3737 Comm: irqbalance Tainted:
> G    B             5.2.0-rc2-next-20190530 #13
> [   67.058508][ T3737] Call Trace:
> [   67.058531][ T3737] [c000001c4738f930] [c00000000089045c]
> dump_stack+0xb0/0xf4 (unreliable)
> [   67.058653][ T3737] [c000001c4738f970] [c0000000003dd368]
> print_trailer+0x23c/0x264
> [   67.058751][ T3737] [c000001c4738fa00] [c0000000003cd7d8]
> check_bytes_and_report+0x138/0x160
> [   67.058846][ T3737] [c000001c4738faa0] [c0000000003cfb9c]
> check_object+0x2ac/0x3e0
> [   67.058914][ T3737] [c000001c4738fb10] [c0000000003d646c]
> free_debug_processing+0x1ec/0x680
> [   67.059009][ T3737] [c000001c4738fc00] [c0000000003d6c54]
> __slab_free+0x354/0x6d0
> [   67.059113][ T3737] [c000001c4738fcc0] [c00000000088fda8]
> free_cpumask_var+0x18/0x30
> [   67.059205][ T3737] [c000001c4738fce0] [c0000000001c3fc0]
> write_irq_affinity.isra.0+0x130/0x1e0
> [   67.059324][ T3737] [c000001c4738fd30] [c00000000050c6b0]
> proc_reg_write+0x90/0x130
> [   67.059415][ T3737] [c000001c4738fd60] [c0000000004475ac]
> __vfs_write+0x3c/0x70
> [   67.059498][ T3737] [c000001c4738fd80] [c00000000044b0a8]
> vfs_write+0xd8/0x210
> [   67.059581][ T3737] [c000001c4738fdd0] [c00000000044b44c]
> ksys_write+0x7c/0x140
> [   67.059692][ T3737] [c000001c4738fe20] [c00000000000b108]
> system_call+0x5c/0x70
> [   67.059781][ T3737] FIX kmalloc-16: Restoring 0x00000000bd269811-
> 0x0000000039a2fb86=3D0xcc
> [   67.059781][ T3737]
> [   67.059922][ T3737] FIX kmalloc-16: Object at 0x000000005c0b6a3a not f=
reed
>
>
>   185.039693][ T3647] BUG: KASAN: invalid-access in bitmap_parse+0x20c/0x=
2d8
> [  185.039701][ T3647] Write of size 8 at addr 33ff809501263f20 by task
> irqbalance/3647
> [  185.039710][ T3647] Pointer tag: [33], memory tag: [fe]
> [  185.056475][ T3647]
> [  185.056486][ T3647] CPU: 218 PID: 3647 Comm: irqbalance Tainted:
> G        W         5.2.0-rc2-next-20190530+ #5
> [  185.056491][ T3647] Hardware name: HPE Apollo
> 70             /C01_APACHE_MB         , BIOS L50_5.13_1.0.9 03/01/2019
> [  185.056498][ T3647] Call trace:
> [  185.079885][ T3647]  dump_backtrace+0x0/0x268
> [  185.079896][ T3647]  show_stack+0x20/0x2c
> [  185.092149][ T3647]  dump_stack+0xb4/0x108
> [  185.092162][ T3647]  print_address_description+0x7c/0x330
> [  185.092172][ T3647]  __kasan_report+0x194/0x1dc
> [  185.116236][ T3647]  kasan_report+0x10/0x18
> [  185.116243][ T3647]  __hwasan_store8_noabort+0x74/0x7c
> [  185.116248][ T3647]  bitmap_parse+0x20c/0x2d8
> [  185.116254][ T3647]  bitmap_parse_user+0x40/0x64
> [  185.116268][ T3647]  write_irq_affinity+0x118/0x1a8
> [  185.135032][ T3647]  irq_affinity_proc_write+0x34/0x44
> [  185.135040][ T3647]  proc_reg_write+0xf4/0x130
> [  185.135057][ T3647]  __vfs_write+0x88/0x33c
> [  185.135067][ T3647]  vfs_write+0x118/0x208
> [  185.144546][ T3647]  ksys_write+0xa0/0x110
> [  185.158794][ T3647]  __arm64_sys_write+0x54/0x88
> [  185.158811][ T3647]  el0_svc_handler+0x198/0x260
> [  185.158820][ T3647]  el0_svc+0x8/0xc
> [  185.172464][ T3647]
> [  185.172469][ T3647] Allocated by task 3647:
> [  185.172476][ T3647]  __kasan_kmalloc+0x114/0x1d0
> [  185.172481][ T3647]  kasan_kmalloc+0x10/0x18
> [  185.172499][ T3647]  __kmalloc_node+0x1e0/0x7cc
> [  185.192389][ T3647]  alloc_cpumask_var_node+0x48/0x94
> [  185.192395][ T3647]  alloc_cpumask_var+0x10/0x1c
> [  185.192400][ T3647]  write_irq_affinity+0xa8/0x1a8
> [  185.192406][ T3647]  irq_affinity_proc_write+0x34/0x44
> [  185.192415][ T3647]  proc_reg_write+0xf4/0x130
> [  185.224744][ T3647]  __vfs_write+0x88/0x33c
> [  185.224750][ T3647]  vfs_write+0x118/0x208
> [  185.224756][ T3647]  ksys_write+0xa0/0x110
> [  185.224766][ T3647]  __arm64_sys_write+0x54/0x88
> [  185.258392][ T3647]  el0_svc_handler+0x198/0x260
> [  185.258398][ T3647]  el0_svc+0x8/0xc
> [  185.258401][ T3647]
> [  185.258405][ T3647] Freed by task 3647:
> [  185.258411][ T3647]  __kasan_slab_free+0x154/0x228
> [  185.258417][ T3647]  kasan_slab_free+0xc/0x18
> [  185.258422][ T3647]  kfree+0x268/0xb70
> [  185.258428][ T3647]  free_cpumask_var+0xc/0x14
> [  185.258446][ T3647]  write_irq_affinity+0x19c/0x1a8
> [  185.273666][ T3647]  irq_affinity_proc_write+0x34/0x44
> [  185.273675][ T3647]  proc_reg_write+0xf4/0x130
> [  185.288620][ T3647]  __vfs_write+0x88/0x33c
> [  185.288626][ T3647]  vfs_write+0x118/0x208
> [  185.288632][ T3647]  ksys_write+0xa0/0x110
> [  185.288645][ T3647]  __arm64_sys_write+0x54/0x88
> [  185.303075][ T3647]  el0_svc_handler+0x198/0x260
> [  185.303081][ T3647]  el0_svc+0x8/0xc
> [  185.303084][ T3647]
> [  185.303091][ T3647] The buggy address belongs to the object at
> ffff809501263f00
> [  185.303091][ T3647]  which belongs to the cache kmalloc-128 of size 12=
8
> [  185.303103][ T3647] The buggy address is located 32 bytes inside of
> [  185.303103][ T3647]  128-byte region [ffff809501263f00, ffff809501263f=
80)
> [  185.331347][ T3647] The buggy address belongs to the page:
> [  185.331356][ T3647] page:ffff7fe025404980 refcount:1 mapcount:0
> mapping:7fff800800010480 index:0xaff809501267d80
> [  185.331365][ T3647] flags: 0x17ffffffc000200(slab)
> [  185.331377][ T3647] raw: 017ffffffc000200 ffff7fe025997308 e5ff808b7d0=
0fd40
> 7fff800800010480
> [  185.350500][ T3647] raw: 19ff80950126aa80 0000000000660059 00000001fff=
fffff
> 0000000000000000
> [  185.350505][ T3647] page dumped because: kasan: bad access detected
> [  185.350514][ T3647] page allocated via order 0, migratetype Unmovable,
> gfp_mask 0x12cc0(GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY)
> [  185.350535][ T3647]  prep_new_page+0x2ec/0x388
> [  185.364704][ T3647]  get_page_from_freelist+0x2530/0x27fc
> [  185.364711][ T3647]  __alloc_pages_nodemask+0x360/0x1c60
> [  185.364719][ T3647]  new_slab+0x108/0x9d4
> [  185.364725][ T3647]  ___slab_alloc+0x57c/0x9e4
> [  185.364735][ T3647]  __kmalloc_node+0x734/0x7cc
> [  185.382050][ T3647]  alloc_rt_sched_group+0x17c/0x258
> [  185.382070][ T3647]  sched_create_group+0x54/0x9c
> [  185.382090][ T3647]  sched_autogroup_create_attach+0x40/0x1f0
> [  185.494511][ T3647]  ksys_setsid+0x158/0x15c
> [  185.494517][ T3647]  __arm64_sys_setsid+0x10/0x1c
> [  185.494524][ T3647]  el0_svc_handler+0x198/0x260
> [  185.494529][ T3647]  el0_svc+0x8/0xc
> [  185.494532][ T3647]
> [  185.494536][ T3647] Memory state around the buggy address:
> [  185.494549][ T3647]  ffff809501263d00: fe fe fe fe fe fe fe fe fe fe f=
e fe
> fe
> fe fe fe
> [  185.514973][ T3647]  ffff809501263e00: fe fe fe fe fe fe fe fe fe fe f=
e fe
> fe
> fe fe fe
> [  185.514979][ T3647] >ffff809501263f00: 33 33 fe fe fe fe fe fe fe fe f=
e fe
> fe
> fe fe fe
> [  185.514982][ T3647]                          ^
> [  185.514988][ T3647]  ffff809501264000: fe fe fe fe fe fe fe fe fe fe f=
e fe
> fe
> fe fe fe
> [  185.514997][ T3647]  ffff809501264100: fe fe fe fe fe fe fe fe 36 36 3=
6 36
> 36
> 36 36 36
>

--_000_BN6PR1801MB20655CFFEA0CEA242C088C25CB160BN6PR1801MB2065_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body>
(Sorry for top-posting)<br>
<br>
I can reproduce this on next-20190604. Is it new trace, or like one you've =
posted before?<br>
<br>
Anyways,<br>
echo &quot;3&quot; &gt; /proc/irq/XX/set_affinity <br>
crashes my kernel like you described below.<br>
<br>
Briefly looking, in set_affinity()-&gt;cpumask_parse() path <br>
bitmap_parse() is called with nbits=3D=3D4096. It looks suspicious <br>
because my system has 4 cpus, not 4k.<br>
<br>
At the very first glance, it looks like bitmap_parse() is called with <br>
wrong nbits, and wipes unrelated memory. It causes panic later, <br>
while the function itself works correctly. I'll check it for more and <br>
get back soon.<br>
<br>
Yury
<hr style=3D"display:inline-block;width:98%" tabindex=3D"-1">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" st=
yle=3D"font-size:11pt" color=3D"#000000"><b>From:</b> Qian Cai &lt;cai@lca.=
pw&gt;<br>
<b>Sent:</b> Tuesday, June 4, 2019 10:23:13 PM<br>
<b>To:</b> Yuri Norov<br>
<b>Cc:</b> Andrey Konovalov; linux-kernel@vger.kernel.org; Andy Shevchenko;=
 Andrew Morton; linux-mm@kvack.org<br>
<b>Subject:</b> [EXT] Re: &quot;lib: rework bitmap_parse()&quot; triggers i=
nvalid access errors</font>
<div>&nbsp;</div>
</div>
<div class=3D"BodyFragment"><font size=3D"2"><span style=3D"font-size:11pt;=
">
<div class=3D"PlainText">External Email<br>
<br>
----------------------------------------------------------------------<br>
BTW, this problem below is still reproducible after applied the series [1] =
on<br>
the top of today's linux-next tree &quot;next-20190604&quot; which has alre=
ady included<br>
the patch for the &quot;Bad swap file entry&quot; issue.<br>
<br>
[1] <a href=3D"https://lore.kernel.org/lkml/20190501010636.30595-1-ynorov@m=
arvell.com/">
https://lore.kernel.org/lkml/20190501010636.30595-1-ynorov@marvell.com/</a>=
<br>
<br>
On Thu, 2019-05-30 at 15:01 -0400, Qian Cai wrote:<br>
&gt; The linux-next commit &quot;lib: rework bitmap_parse&quot; triggers er=
rors below during<br>
&gt; boot on both arm64 and powerpc with KASAN_SW_TAGS or SLUB_DEBUG enable=
d.<br>
&gt; <br>
&gt; Reverted the commit and its dependency (lib: opencode in_str()) fixed =
the<br>
&gt; issue.<br>
&gt; <br>
&gt; [&nbsp;&nbsp;&nbsp;67.056867][ T3737] BUG kmalloc-16 (Tainted: G&nbsp;=
&nbsp;&nbsp;&nbsp;B&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;): Redzone<br>
&gt; overwritten<br>
&gt; [&nbsp;&nbsp;&nbsp;67.056905][ T3737] --------------------------------=
-----------------------<br>
&gt; ----------------------<br>
&gt; [&nbsp;&nbsp;&nbsp;67.056905][ T3737]&nbsp;<br>
&gt; [&nbsp;&nbsp;&nbsp;67.056946][ T3737] INFO: 0x00000000bd269811-0x00000=
00039a2fb86. First byte<br>
&gt; 0x0 instead of 0xcc<br>
&gt; [&nbsp;&nbsp;&nbsp;67.056989][ T3737] INFO: Allocated in alloc_cpumask=
_var_node&#43;0x38/0x80<br>
&gt; age=3D0<br>
&gt; cpu=3D62 pid=3D3737<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057029][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; __slab_alloc&#43;0x34/0x60<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057052][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; __kmalloc_node&#43;0x1a8/0x860<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057086][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; alloc_cpumask_var_node&#43;0x38/0x80<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057133][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; write_irq_affinity.isra.0&#43;0x84/0x1e0<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057178][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; proc_reg_write&#43;0x90/0x130<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057224][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; __vfs_write&#43;0x3c/0x70<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057261][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; vfs_write&#43;0xd8/0x210<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057292][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; ksys_write&#43;0x7c/0x140<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057325][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; system_call&#43;0x5c/0x70<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057355][ T3737] INFO: Freed in free_cpumask_var&=
#43;0x18/0x30 age=3D0 cpu=3D62<br>
&gt; pid=3D3737<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057392][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; free_cpumask_var&#43;0x18/0x30<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057427][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; write_irq_affinity.isra.0&#43;0x130/0x1e0<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057464][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; proc_reg_write&#43;0x90/0x130<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057525][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; __vfs_write&#43;0x3c/0x70<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057558][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; vfs_write&#43;0xd8/0x210<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057607][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; ksys_write&#43;0x7c/0x140<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057643][ T3737]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; system_call&#43;0x5c/0x70<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057692][ T3737] INFO: Slab 0x00000000786814bb ob=
jects=3D186 used=3D49<br>
&gt; fp=3D0x0000000019431596 flags=3D0x3fffc000000201<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057810][ T3737] INFO: Object 0x000000005c0b6a3a =
@offset=3D25352<br>
&gt; fp=3D0x00000000a42ffc35<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057810][ T3737]&nbsp;<br>
&gt; [&nbsp;&nbsp;&nbsp;67.057922][ T3737] Redzone 00000000d929958b: cc cc =
cc cc cc cc cc<br>
&gt; cc&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;........<br>
&gt; [&nbsp;&nbsp;&nbsp;67.058024][ T3737] Object 000000005c0b6a3a: 00 00 0=
0 00 00 00 00 04 00 00<br>
&gt; 00<br>
&gt; 00 00 00 00 00&nbsp;&nbsp;................<br>
&gt; [&nbsp;&nbsp;&nbsp;67.058171][ T3737] Redzone 00000000bd269811: 00 00 =
00 00 00 00 00<br>
&gt; 00&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;........<br>
&gt; [&nbsp;&nbsp;&nbsp;67.058283][ T3737] Padding 00000000b327be67: 5a 5a =
5a 5a 5a 5a 5a<br>
&gt; 5a&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;ZZZZZZZZ<br>
&gt; [&nbsp;&nbsp;&nbsp;67.058383][ T3737] CPU: 62 PID: 3737 Comm: irqbalan=
ce Tainted:<br>
&gt; G&nbsp;&nbsp;&nbsp;&nbsp;B&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.2.0-rc2-next-20190530 #13<br>
&gt; [&nbsp;&nbsp;&nbsp;67.058508][ T3737] Call Trace:<br>
&gt; [&nbsp;&nbsp;&nbsp;67.058531][ T3737] [c000001c4738f930] [c00000000089=
045c]<br>
&gt; dump_stack&#43;0xb0/0xf4 (unreliable)<br>
&gt; [&nbsp;&nbsp;&nbsp;67.058653][ T3737] [c000001c4738f970] [c0000000003d=
d368]<br>
&gt; print_trailer&#43;0x23c/0x264<br>
&gt; [&nbsp;&nbsp;&nbsp;67.058751][ T3737] [c000001c4738fa00] [c0000000003c=
d7d8]<br>
&gt; check_bytes_and_report&#43;0x138/0x160<br>
&gt; [&nbsp;&nbsp;&nbsp;67.058846][ T3737] [c000001c4738faa0] [c0000000003c=
fb9c]<br>
&gt; check_object&#43;0x2ac/0x3e0<br>
&gt; [&nbsp;&nbsp;&nbsp;67.058914][ T3737] [c000001c4738fb10] [c0000000003d=
646c]<br>
&gt; free_debug_processing&#43;0x1ec/0x680<br>
&gt; [&nbsp;&nbsp;&nbsp;67.059009][ T3737] [c000001c4738fc00] [c0000000003d=
6c54]<br>
&gt; __slab_free&#43;0x354/0x6d0<br>
&gt; [&nbsp;&nbsp;&nbsp;67.059113][ T3737] [c000001c4738fcc0] [c00000000088=
fda8]<br>
&gt; free_cpumask_var&#43;0x18/0x30<br>
&gt; [&nbsp;&nbsp;&nbsp;67.059205][ T3737] [c000001c4738fce0] [c0000000001c=
3fc0]<br>
&gt; write_irq_affinity.isra.0&#43;0x130/0x1e0<br>
&gt; [&nbsp;&nbsp;&nbsp;67.059324][ T3737] [c000001c4738fd30] [c00000000050=
c6b0]<br>
&gt; proc_reg_write&#43;0x90/0x130<br>
&gt; [&nbsp;&nbsp;&nbsp;67.059415][ T3737] [c000001c4738fd60] [c00000000044=
75ac]<br>
&gt; __vfs_write&#43;0x3c/0x70<br>
&gt; [&nbsp;&nbsp;&nbsp;67.059498][ T3737] [c000001c4738fd80] [c00000000044=
b0a8]<br>
&gt; vfs_write&#43;0xd8/0x210<br>
&gt; [&nbsp;&nbsp;&nbsp;67.059581][ T3737] [c000001c4738fdd0] [c00000000044=
b44c]<br>
&gt; ksys_write&#43;0x7c/0x140<br>
&gt; [&nbsp;&nbsp;&nbsp;67.059692][ T3737] [c000001c4738fe20] [c00000000000=
b108]<br>
&gt; system_call&#43;0x5c/0x70<br>
&gt; [&nbsp;&nbsp;&nbsp;67.059781][ T3737] FIX kmalloc-16: Restoring 0x0000=
0000bd269811-<br>
&gt; 0x0000000039a2fb86=3D0xcc<br>
&gt; [&nbsp;&nbsp;&nbsp;67.059781][ T3737]&nbsp;<br>
&gt; [&nbsp;&nbsp;&nbsp;67.059922][ T3737] FIX kmalloc-16: Object at 0x0000=
00005c0b6a3a not freed<br>
&gt; <br>
&gt; <br>
&gt; &nbsp; 185.039693][ T3647] BUG: KASAN: invalid-access in bitmap_parse&=
#43;0x20c/0x2d8<br>
&gt; [&nbsp;&nbsp;185.039701][ T3647] Write of size 8 at addr 33ff809501263=
f20 by task<br>
&gt; irqbalance/3647<br>
&gt; [&nbsp;&nbsp;185.039710][ T3647] Pointer tag: [33], memory tag: [fe]<b=
r>
&gt; [&nbsp;&nbsp;185.056475][ T3647]&nbsp;<br>
&gt; [&nbsp;&nbsp;185.056486][ T3647] CPU: 218 PID: 3647 Comm: irqbalance T=
ainted:<br>
&gt; G&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;W&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.2.0-rc2-next-20190530&#43; #5<br>
&gt; [&nbsp;&nbsp;185.056491][ T3647] Hardware name: HPE Apollo<br>
&gt; 70&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;/C01_APACHE_MB&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;, BIOS L50_5.13_1.0.9 03/01/2019<br>
&gt; [&nbsp;&nbsp;185.056498][ T3647] Call trace:<br>
&gt; [&nbsp;&nbsp;185.079885][ T3647]&nbsp;&nbsp;dump_backtrace&#43;0x0/0x2=
68<br>
&gt; [&nbsp;&nbsp;185.079896][ T3647]&nbsp;&nbsp;show_stack&#43;0x20/0x2c<b=
r>
&gt; [&nbsp;&nbsp;185.092149][ T3647]&nbsp;&nbsp;dump_stack&#43;0xb4/0x108<=
br>
&gt; [&nbsp;&nbsp;185.092162][ T3647]&nbsp;&nbsp;print_address_description&=
#43;0x7c/0x330<br>
&gt; [&nbsp;&nbsp;185.092172][ T3647]&nbsp;&nbsp;__kasan_report&#43;0x194/0=
x1dc<br>
&gt; [&nbsp;&nbsp;185.116236][ T3647]&nbsp;&nbsp;kasan_report&#43;0x10/0x18=
<br>
&gt; [&nbsp;&nbsp;185.116243][ T3647]&nbsp;&nbsp;__hwasan_store8_noabort&#4=
3;0x74/0x7c<br>
&gt; [&nbsp;&nbsp;185.116248][ T3647]&nbsp;&nbsp;bitmap_parse&#43;0x20c/0x2=
d8<br>
&gt; [&nbsp;&nbsp;185.116254][ T3647]&nbsp;&nbsp;bitmap_parse_user&#43;0x40=
/0x64<br>
&gt; [&nbsp;&nbsp;185.116268][ T3647]&nbsp;&nbsp;write_irq_affinity&#43;0x1=
18/0x1a8<br>
&gt; [&nbsp;&nbsp;185.135032][ T3647]&nbsp;&nbsp;irq_affinity_proc_write&#4=
3;0x34/0x44<br>
&gt; [&nbsp;&nbsp;185.135040][ T3647]&nbsp;&nbsp;proc_reg_write&#43;0xf4/0x=
130<br>
&gt; [&nbsp;&nbsp;185.135057][ T3647]&nbsp;&nbsp;__vfs_write&#43;0x88/0x33c=
<br>
&gt; [&nbsp;&nbsp;185.135067][ T3647]&nbsp;&nbsp;vfs_write&#43;0x118/0x208<=
br>
&gt; [&nbsp;&nbsp;185.144546][ T3647]&nbsp;&nbsp;ksys_write&#43;0xa0/0x110<=
br>
&gt; [&nbsp;&nbsp;185.158794][ T3647]&nbsp;&nbsp;__arm64_sys_write&#43;0x54=
/0x88<br>
&gt; [&nbsp;&nbsp;185.158811][ T3647]&nbsp;&nbsp;el0_svc_handler&#43;0x198/=
0x260<br>
&gt; [&nbsp;&nbsp;185.158820][ T3647]&nbsp;&nbsp;el0_svc&#43;0x8/0xc<br>
&gt; [&nbsp;&nbsp;185.172464][ T3647]&nbsp;<br>
&gt; [&nbsp;&nbsp;185.172469][ T3647] Allocated by task 3647:<br>
&gt; [&nbsp;&nbsp;185.172476][ T3647]&nbsp;&nbsp;__kasan_kmalloc&#43;0x114/=
0x1d0<br>
&gt; [&nbsp;&nbsp;185.172481][ T3647]&nbsp;&nbsp;kasan_kmalloc&#43;0x10/0x1=
8<br>
&gt; [&nbsp;&nbsp;185.172499][ T3647]&nbsp;&nbsp;__kmalloc_node&#43;0x1e0/0=
x7cc<br>
&gt; [&nbsp;&nbsp;185.192389][ T3647]&nbsp;&nbsp;alloc_cpumask_var_node&#43=
;0x48/0x94<br>
&gt; [&nbsp;&nbsp;185.192395][ T3647]&nbsp;&nbsp;alloc_cpumask_var&#43;0x10=
/0x1c<br>
&gt; [&nbsp;&nbsp;185.192400][ T3647]&nbsp;&nbsp;write_irq_affinity&#43;0xa=
8/0x1a8<br>
&gt; [&nbsp;&nbsp;185.192406][ T3647]&nbsp;&nbsp;irq_affinity_proc_write&#4=
3;0x34/0x44<br>
&gt; [&nbsp;&nbsp;185.192415][ T3647]&nbsp;&nbsp;proc_reg_write&#43;0xf4/0x=
130<br>
&gt; [&nbsp;&nbsp;185.224744][ T3647]&nbsp;&nbsp;__vfs_write&#43;0x88/0x33c=
<br>
&gt; [&nbsp;&nbsp;185.224750][ T3647]&nbsp;&nbsp;vfs_write&#43;0x118/0x208<=
br>
&gt; [&nbsp;&nbsp;185.224756][ T3647]&nbsp;&nbsp;ksys_write&#43;0xa0/0x110<=
br>
&gt; [&nbsp;&nbsp;185.224766][ T3647]&nbsp;&nbsp;__arm64_sys_write&#43;0x54=
/0x88<br>
&gt; [&nbsp;&nbsp;185.258392][ T3647]&nbsp;&nbsp;el0_svc_handler&#43;0x198/=
0x260<br>
&gt; [&nbsp;&nbsp;185.258398][ T3647]&nbsp;&nbsp;el0_svc&#43;0x8/0xc<br>
&gt; [&nbsp;&nbsp;185.258401][ T3647]&nbsp;<br>
&gt; [&nbsp;&nbsp;185.258405][ T3647] Freed by task 3647:<br>
&gt; [&nbsp;&nbsp;185.258411][ T3647]&nbsp;&nbsp;__kasan_slab_free&#43;0x15=
4/0x228<br>
&gt; [&nbsp;&nbsp;185.258417][ T3647]&nbsp;&nbsp;kasan_slab_free&#43;0xc/0x=
18<br>
&gt; [&nbsp;&nbsp;185.258422][ T3647]&nbsp;&nbsp;kfree&#43;0x268/0xb70<br>
&gt; [&nbsp;&nbsp;185.258428][ T3647]&nbsp;&nbsp;free_cpumask_var&#43;0xc/0=
x14<br>
&gt; [&nbsp;&nbsp;185.258446][ T3647]&nbsp;&nbsp;write_irq_affinity&#43;0x1=
9c/0x1a8<br>
&gt; [&nbsp;&nbsp;185.273666][ T3647]&nbsp;&nbsp;irq_affinity_proc_write&#4=
3;0x34/0x44<br>
&gt; [&nbsp;&nbsp;185.273675][ T3647]&nbsp;&nbsp;proc_reg_write&#43;0xf4/0x=
130<br>
&gt; [&nbsp;&nbsp;185.288620][ T3647]&nbsp;&nbsp;__vfs_write&#43;0x88/0x33c=
<br>
&gt; [&nbsp;&nbsp;185.288626][ T3647]&nbsp;&nbsp;vfs_write&#43;0x118/0x208<=
br>
&gt; [&nbsp;&nbsp;185.288632][ T3647]&nbsp;&nbsp;ksys_write&#43;0xa0/0x110<=
br>
&gt; [&nbsp;&nbsp;185.288645][ T3647]&nbsp;&nbsp;__arm64_sys_write&#43;0x54=
/0x88<br>
&gt; [&nbsp;&nbsp;185.303075][ T3647]&nbsp;&nbsp;el0_svc_handler&#43;0x198/=
0x260<br>
&gt; [&nbsp;&nbsp;185.303081][ T3647]&nbsp;&nbsp;el0_svc&#43;0x8/0xc<br>
&gt; [&nbsp;&nbsp;185.303084][ T3647]&nbsp;<br>
&gt; [&nbsp;&nbsp;185.303091][ T3647] The buggy address belongs to the obje=
ct at<br>
&gt; ffff809501263f00<br>
&gt; [&nbsp;&nbsp;185.303091][ T3647]&nbsp;&nbsp;which belongs to the cache=
 kmalloc-128 of size 128<br>
&gt; [&nbsp;&nbsp;185.303103][ T3647] The buggy address is located 32 bytes=
 inside of<br>
&gt; [&nbsp;&nbsp;185.303103][ T3647]&nbsp;&nbsp;128-byte region [ffff80950=
1263f00, ffff809501263f80)<br>
&gt; [&nbsp;&nbsp;185.331347][ T3647] The buggy address belongs to the page=
:<br>
&gt; [&nbsp;&nbsp;185.331356][ T3647] page:ffff7fe025404980 refcount:1 mapc=
ount:0<br>
&gt; mapping:7fff800800010480 index:0xaff809501267d80<br>
&gt; [&nbsp;&nbsp;185.331365][ T3647] flags: 0x17ffffffc000200(slab)<br>
&gt; [&nbsp;&nbsp;185.331377][ T3647] raw: 017ffffffc000200 ffff7fe02599730=
8 e5ff808b7d00fd40<br>
&gt; 7fff800800010480<br>
&gt; [&nbsp;&nbsp;185.350500][ T3647] raw: 19ff80950126aa80 000000000066005=
9 00000001ffffffff<br>
&gt; 0000000000000000<br>
&gt; [&nbsp;&nbsp;185.350505][ T3647] page dumped because: kasan: bad acces=
s detected<br>
&gt; [&nbsp;&nbsp;185.350514][ T3647] page allocated via order 0, migratety=
pe Unmovable,<br>
&gt; gfp_mask 0x12cc0(GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY)<br>
&gt; [&nbsp;&nbsp;185.350535][ T3647]&nbsp;&nbsp;prep_new_page&#43;0x2ec/0x=
388<br>
&gt; [&nbsp;&nbsp;185.364704][ T3647]&nbsp;&nbsp;get_page_from_freelist&#43=
;0x2530/0x27fc<br>
&gt; [&nbsp;&nbsp;185.364711][ T3647]&nbsp;&nbsp;__alloc_pages_nodemask&#43=
;0x360/0x1c60<br>
&gt; [&nbsp;&nbsp;185.364719][ T3647]&nbsp;&nbsp;new_slab&#43;0x108/0x9d4<b=
r>
&gt; [&nbsp;&nbsp;185.364725][ T3647]&nbsp;&nbsp;___slab_alloc&#43;0x57c/0x=
9e4<br>
&gt; [&nbsp;&nbsp;185.364735][ T3647]&nbsp;&nbsp;__kmalloc_node&#43;0x734/0=
x7cc<br>
&gt; [&nbsp;&nbsp;185.382050][ T3647]&nbsp;&nbsp;alloc_rt_sched_group&#43;0=
x17c/0x258<br>
&gt; [&nbsp;&nbsp;185.382070][ T3647]&nbsp;&nbsp;sched_create_group&#43;0x5=
4/0x9c<br>
&gt; [&nbsp;&nbsp;185.382090][ T3647]&nbsp;&nbsp;sched_autogroup_create_att=
ach&#43;0x40/0x1f0<br>
&gt; [&nbsp;&nbsp;185.494511][ T3647]&nbsp;&nbsp;ksys_setsid&#43;0x158/0x15=
c<br>
&gt; [&nbsp;&nbsp;185.494517][ T3647]&nbsp;&nbsp;__arm64_sys_setsid&#43;0x1=
0/0x1c<br>
&gt; [&nbsp;&nbsp;185.494524][ T3647]&nbsp;&nbsp;el0_svc_handler&#43;0x198/=
0x260<br>
&gt; [&nbsp;&nbsp;185.494529][ T3647]&nbsp;&nbsp;el0_svc&#43;0x8/0xc<br>
&gt; [&nbsp;&nbsp;185.494532][ T3647]&nbsp;<br>
&gt; [&nbsp;&nbsp;185.494536][ T3647] Memory state around the buggy address=
:<br>
&gt; [&nbsp;&nbsp;185.494549][ T3647]&nbsp;&nbsp;ffff809501263d00: fe fe fe=
 fe fe fe fe fe fe fe fe fe<br>
&gt; fe<br>
&gt; fe fe fe<br>
&gt; [&nbsp;&nbsp;185.514973][ T3647]&nbsp;&nbsp;ffff809501263e00: fe fe fe=
 fe fe fe fe fe fe fe fe fe<br>
&gt; fe<br>
&gt; fe fe fe<br>
&gt; [&nbsp;&nbsp;185.514979][ T3647] &gt;ffff809501263f00: 33 33 fe fe fe =
fe fe fe fe fe fe fe<br>
&gt; fe<br>
&gt; fe fe fe<br>
&gt; [&nbsp;&nbsp;185.514982][ T3647]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;^<br>
&gt; [&nbsp;&nbsp;185.514988][ T3647]&nbsp;&nbsp;ffff809501264000: fe fe fe=
 fe fe fe fe fe fe fe fe fe<br>
&gt; fe<br>
&gt; fe fe fe<br>
&gt; [&nbsp;&nbsp;185.514997][ T3647]&nbsp;&nbsp;ffff809501264100: fe fe fe=
 fe fe fe fe fe 36 36 36 36<br>
&gt; 36<br>
&gt; 36 36 36<br>
&gt; <br>
</div>
</span></font></div>
</body>
</html>

--_000_BN6PR1801MB20655CFFEA0CEA242C088C25CB160BN6PR1801MB2065_--

