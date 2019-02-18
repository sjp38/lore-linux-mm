Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A400C10F01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:16:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A663217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:16:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="cNvtYaWt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A663217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF87D8E0003; Mon, 18 Feb 2019 06:16:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A810A8E0002; Mon, 18 Feb 2019 06:16:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 922D78E0003; Mon, 18 Feb 2019 06:16:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A04A8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:16:19 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 2so11748104pgg.21
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:16:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=DZqQyXCcgD1TctuCMZ3oJqcD71M8+afEsxnaE6VsR4U=;
        b=RKrT7RFxcMrWRQ/BqPcOxUTDShs1OeJAJA/Gk8cBx93TtvDiMHL4UvCvII0X15ec09
         lWYr1PKFqcTOgH602NSf6pLLPQVZF82BS/8o0UYi9VKxREKxSyZaqD5Xf7zcz1hj3V4b
         TTd8LhyAbT8KkZ3Dh/NzkZkmAPp15EBSxg/RAvvm9rvVurHp4LJxQuPUQHpsHcKnkuUq
         J5FgUG6lDyRQDYFsn5bi7qmdTkIn4wAPYRX2hMHxzgGz+mWZtn0IhLZNcPm7X17jkkWy
         gOGBuAyduEBp634ah0p8PVhgi300vETBoFC9cy51BANMsopTYaZ4gBaJKZB9BaZJtLOu
         L34A==
X-Gm-Message-State: AHQUAuZl9sbqWWKqBsA58b+d4mtmetX78Nb1vK1sEIeR+rU319WXgEOG
	fJu0SgnWhtQNYd23i1O7/v/Ort1qFUvQM3H8+kVqomS51JaHLrQgf82fG+z7h0p53gA2EH7TSpS
	ZeRroY7FOkAbOKxj3smd2nT99qJIPQvEf2908QJEFDFdMIXHbyb1L+2r9/W+nD2CCiA==
X-Received: by 2002:a63:1c42:: with SMTP id c2mr18206175pgm.265.1550488578893;
        Mon, 18 Feb 2019 03:16:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaNXlDSO+gv1UqJRlYW9jY9I9X16PCSPIh6/i8P1CUR2M4nHfPmDy66raPsw2UAuBE9nYTB
X-Received: by 2002:a63:1c42:: with SMTP id c2mr18206124pgm.265.1550488578101;
        Mon, 18 Feb 2019 03:16:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550488578; cv=none;
        d=google.com; s=arc-20160816;
        b=fZC+RI7RNCvGrNPHnsPErRCdIDCDdCcWsa2QeGTj9ZFWKf7+TrU8sqOtE5dZrM7sVi
         DLGm6Ry/GCNMPif6MeR7+IKu1Gz3NIE7K1oYjSw8d97snU6ZSWzrCC0VJq3nEli1kKK6
         6c7rUZAaAIcDANPpRyAq2qs+pUjMN5o0Y5DPk283vjaTbC97sUhaHhwhGWGb91T1YE02
         kg2T3fsr48DohX5dPgorPK/WebZ41gGAdr2Tn3Fr2fzR1QpfmEa/G+lxCNu578mEt0SL
         wPcnwPCy2d1PCN3xbKArseL+rpPT9TdbZlYaF0UxKi+hPd59NOoiM/rYygnPpzlOy/2Z
         tcrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=DZqQyXCcgD1TctuCMZ3oJqcD71M8+afEsxnaE6VsR4U=;
        b=Rvg+CdE+Oe8wKefJm5CDlZxGg/eDb31G0HBgahVt/vFNulhLNsl9EMGTuProrHRAgV
         rU2sTfL4KQhBp576aXiO9XXJUPugr8AjMwXne4iN1IlvirhVlExOnkGlDBk85hT49puU
         eQ/zBLvZPbt9WymQCWwGpcwaP5CXILGxG9ekKysvK76TuMywDmT4MBaoAhRnRkbfLLM+
         g4YRX0DXc8nlTQtSBzHwRUkLbBMdYuhFzsADepDLTy1BjlvkOPZ//JSXcTD9vqMdCHya
         tHOQPc4ci9CifZn34ebW1jmAeXmNBT4V+fmtI577Ctg+Ap8BUzofdZx1uOdm7KPtx4zl
         4DeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b=cNvtYaWt;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 40.107.15.54 as permitted sender) smtp.mailfrom=Mark.Rutland@arm.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150054.outbound.protection.outlook.com. [40.107.15.54])
        by mx.google.com with ESMTPS id l123si9937274pfc.187.2019.02.18.03.16.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Feb 2019 03:16:18 -0800 (PST)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 40.107.15.54 as permitted sender) client-ip=40.107.15.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b=cNvtYaWt;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 40.107.15.54 as permitted sender) smtp.mailfrom=Mark.Rutland@arm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector1-arm-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=DZqQyXCcgD1TctuCMZ3oJqcD71M8+afEsxnaE6VsR4U=;
 b=cNvtYaWtWCofaIkS8LRYZhoJCLxOAFwsag2Sn6feb43hhmsTiuIyRsMG4LqjtVWqd2EW3XLxX5wym03duxARP5EVGFOg6MwYItHYsjKTqBDQIv+PnLTkIg2W5AYC2JnUMOFkKUIa4DIvX4r9nCQrZmXC+vnlHhU7nBWzOdcc5Kc=
Received: from VI1PR08MB3742.eurprd08.prod.outlook.com (20.178.15.26) by
 VI1PR08MB3040.eurprd08.prod.outlook.com (52.133.14.145) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.16; Mon, 18 Feb 2019 11:16:13 +0000
Received: from VI1PR08MB3742.eurprd08.prod.outlook.com
 ([fe80::2508:8790:80cb:2f91]) by VI1PR08MB3742.eurprd08.prod.outlook.com
 ([fe80::2508:8790:80cb:2f91%6]) with mapi id 15.20.1622.018; Mon, 18 Feb 2019
 11:16:13 +0000
From: Mark Rutland <Mark.Rutland@arm.com>
To: Steven Price <Steven.Price@arm.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski
	<luto@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann
	<arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Catalin Marinas
	<Catalin.Marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo
 Molnar <mingo@redhat.com>, James Morse <James.Morse@arm.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Peter Zijlstra
	<peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon
	<Will.Deacon@arm.com>, "x86@kernel.org" <x86@kernel.org>, "H. Peter Anvin"
	<hpa@zytor.com>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 01/13] arm64: mm: Add p?d_large() definitions
Thread-Topic: [PATCH 01/13] arm64: mm: Add p?d_large() definitions
Thread-Index: AQHUxVBWN94KMPHRGky/cHEAHAjWbKXlbBIA
Date: Mon, 18 Feb 2019 11:16:12 +0000
Message-ID: <20190218111610.GD8036@lakrids.cambridge.arm.com>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-2-steven.price@arm.com>
In-Reply-To: <20190215170235.23360-2-steven.price@arm.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
x-originating-ip: [217.140.106.52]
x-clientproxiedby: LO2P265CA0251.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:8a::23) To VI1PR08MB3742.eurprd08.prod.outlook.com
 (2603:10a6:803:bc::26)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Mark.Rutland@arm.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c1b8b040-c7d8-4678-b7e0-08d695927dae
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:VI1PR08MB3040;
x-ms-traffictypediagnostic: VI1PR08MB3040:
x-microsoft-exchange-diagnostics:
 1;VI1PR08MB3040;20:PAe4UTHox4RFirNarP6SeS7J5sqpFTbGvfRkDYVXTe29ZAg7gqQOw9WoRKGqd6Xx4H2iEygXxCTg+54oaaEglcKYq7mq3laRG+Q84eDN0OZgLHnOtpbOmY0JvBbexRKJSev6g/8w9UElUCp4voAUAlMNHmV8Wm49iYEMKdhzSEk=
x-microsoft-antispam-prvs:
 <VI1PR08MB30409863CC5B821026461B5284630@VI1PR08MB3040.eurprd08.prod.outlook.com>
x-forefront-prvs: 09525C61DB
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(396003)(346002)(39860400002)(376002)(366004)(40434004)(189003)(199004)(4326008)(6436002)(256004)(14444005)(71200400001)(54906003)(71190400001)(5024004)(33656002)(44832011)(6512007)(6246003)(53936002)(58126008)(66066001)(106356001)(6486002)(6862004)(105586002)(7416002)(486006)(97736004)(76176011)(52116002)(8676002)(5660300002)(26005)(99286004)(186003)(6636002)(8936002)(81156014)(7736002)(81166006)(25786009)(229853002)(386003)(6506007)(14454004)(2906002)(72206003)(102836004)(11346002)(478600001)(6116002)(3846002)(305945005)(476003)(68736007)(316002)(1076003)(446003)(86362001)(18370500001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR08MB3040;H:VI1PR08MB3742.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 MiAbm4pal49uvdYcysOYssPdAc7uIviWQPGe+4hPJQihXt7iCDAnOdzomM7T8n+S7jrWrpXQTFSvDOBJEsidIB1g1igrRJjrwXAa3o6ECIfrPZRWKthM7OV/Exn00xZjlHvJUczldMlAmHT/C2B+gPZbzOKp69bsSBJkTVMVPlinjn5PM2SXd71L6igobN0cxV2Uh0zdn/EAcRt0LosPPP6GbwzgYbQXnMiN1IrJ8tW0aARoVBX908UtDrqiNKPUXM1BGAUGzwDKEkwVlIluG3iXqep9CyhD+4Ip6UY7qbotvBKxAvZsBPAYqPtTkQ/hmIIZZVc3Nc8p+WpZZr5HcE5zqlHZ5NUjKFxCNd23y8G2bWxwemqapO9pCL1e7rsH7CPO7NF+x0rulxOXpVT8pQfn+a2CStgixBg47ccU3dc=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <D5B84DEA07E5D94F81D38A6C14E569A9@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c1b8b040-c7d8-4678-b7e0-08d695927dae
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Feb 2019 11:16:11.9985
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR08MB3040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 05:02:22PM +0000, Steven Price wrote:
> From: James Morse <james.morse@arm.com>
>
> Exposing the pud/pgd levels of the page tables to walk_page_range() means
> we may come across the exotic large mappings that come with large areas
> of contiguous memory (such as the kernel's linear map).
>
> Expose p?d_large() from each architecture to detect these large mappings.
>
> arm64 already has these macros defined, but with a different name.
> p?d_large() is used by s390, sparc and x86. Only arm/arm64 use p?d_sect()=
.
> Add a macro to allow both names.
>
> By not providing a pgd_large(), we get the generic version that always
> returns 0.

This last sentence isn't true until a subsequent patch, so it's probably
worth dropping it to avoid confusion.

Thanks,
Mark.

>
> Signed-off-by: James Morse <james.morse@arm.com>
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  arch/arm64/include/asm/pgtable.h | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pg=
table.h
> index de70c1eabf33..09d308921625 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *fil=
e, unsigned long pfn,
>   PMD_TYPE_TABLE)
>  #define pmd_sect(pmd)((pmd_val(pmd) & PMD_TYPE_MASK) =3D=3D \
>   PMD_TYPE_SECT)
> +#define pmd_large(x)pmd_sect(x)
>
>  #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
>  #define pud_sect(pud)(0)
> @@ -435,6 +436,7 @@ extern pgprot_t phys_mem_access_prot(struct file *fil=
e, unsigned long pfn,
>  #else
>  #define pud_sect(pud)((pud_val(pud) & PUD_TYPE_MASK) =3D=3D \
>   PUD_TYPE_SECT)
> +#define pud_large(x)pud_sect(x)
>  #define pud_table(pud)((pud_val(pud) & PUD_TYPE_MASK) =3D=3D \
>   PUD_TYPE_TABLE)
>  #endif
> --
> 2.20.1
>
IMPORTANT NOTICE: The contents of this email and any attachments are confid=
ential and may also be privileged. If you are not the intended recipient, p=
lease notify the sender immediately and do not disclose the contents to any=
 other person, use it for any purpose, or store or copy the information in =
any medium. Thank you.

