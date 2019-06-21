Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2484C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:35:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E5D7206B7
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:35:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="tqAjREXx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E5D7206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4AED8E0002; Fri, 21 Jun 2019 10:35:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFB3B8E0001; Fri, 21 Jun 2019 10:35:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC3858E0002; Fri, 21 Jun 2019 10:35:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE7E8E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:35:57 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r21so9449421edp.11
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:35:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:nodisclaimer:content-id
         :content-transfer-encoding:mime-version;
        bh=NX5L5F8xPNoJ5V01tQB34FROEeVHHpne1sUFjq/ejGY=;
        b=EETIYEP1XlzGPbtN+D9L0xeii5PVoxrq8YqwnLYHO9fNd/3JCiTryBHZ76s75qwl9/
         R15WkhMiz2XnIHVzcx20N/8olMTBjCB3kwE93C8lfvjxBZplXmDzVeoqPBhHLK5lCUvO
         2P+WdMNWbxt1q3NUKhQwUHkxxNdaAWmw4Q9wUtwLm5n9i533i5d+fSM6ExVz2UB2pUkZ
         tiDdU7fN04Geu9YdUFs2Brwze6gXrYdVv4AWZmcrCjKsxMFOtMNlMMgO/Lenncu3nceW
         Qk7DrSLx4wQO2YrxeXC69Se7XS7xgN3SUxP2aJUrMzKJhbpVtY5TVzol9NDYmAhhanhA
         mDAA==
X-Gm-Message-State: APjAAAWDhEqvU7LvfX+Qudlk0U99ljAim5Cp9XRKDwW4KtsGcbVqSoXN
	3rSDwBDPHFb9/R8wHCkKuw+KjItJzto2tkdWw9wOkEOzodJ6e7nu9vvCrRflp2ERkH/5CK9ZMaZ
	7UybdAr4aA0qCEgv/DcULpCdgeo+S1XWxsMDUWUfYCLktWmSDuAyCYMiy56OcW+rsag==
X-Received: by 2002:a17:906:244c:: with SMTP id a12mr10382624ejb.288.1561127756637;
        Fri, 21 Jun 2019 07:35:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjIToVHxCMJw6ghXEDM0vERGrPDwksQLm1kj4JZDeDrQwapDkGKG2ZZvVcpncOryIn15s4
X-Received: by 2002:a17:906:244c:: with SMTP id a12mr10382536ejb.288.1561127755489;
        Fri, 21 Jun 2019 07:35:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561127755; cv=none;
        d=google.com; s=arc-20160816;
        b=PWHRaaqfEOD4qB+LAwTggZ5NnF5ZKxpfZxmFMPXp7AL5r32YVtQYZrz6vmETc3wEix
         bdxvGUfNVW+OoEDF4FZQVWVmzqLSU+c8hOT2QljMyQ7eWTSzcJUlVs5YP6q8CMqC6z4E
         vyz+NtI3Wz8g6Toh6nQJqdu9GpXldB2CC1nLRpU0bC5V05eSqCTf7BdTi9qiyVYN9jdQ
         iO9+wCCvbKGkPCF9iRH/dS3anII6GaV/kHk/S6Y/t1VjSZ5E9vhJlep+MwObHL/ZBKFu
         bgES3w28DQYKzYG/Hqn/rIkBAcIOyOuB0GW+TVLe/6VlQFhc/GCqvrei6sbhoCBL30/O
         8PYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:nodisclaimer
         :user-agent:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from
         :dkim-signature;
        bh=NX5L5F8xPNoJ5V01tQB34FROEeVHHpne1sUFjq/ejGY=;
        b=eM2J9dgCOjbGbiEQRjPfYGW41lzuqWI9lvQsUFqXjdxY03B3Nxcrc1Pf5iCR9CnWk0
         36WaYsfiVshwZblvVC/kca0O3jnyk6jhSUl4wDGUdWpdzclehMu0hJ+greyIxCjnqUX8
         SThilOpFg0dwv4qd2ie9Xj4gbITnX5m2fY0v/7YJEWdD8AkbbpCnQqlSJjnVu5AS81t8
         reLg+swaHpNekyuCmXpmB301ggmmBJxdhNNRUITz86t0ZIrxHIPnNj1svpBD2c9f87an
         Qm+C8ZP0/adTk96cyu4vzhp1W5Jx79j2eyrLtcyH3wpcVdf/f5ArDbGuMS24FLnxB0/a
         x6Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector2-armh-onmicrosoft-com header.b=tqAjREXx;
       spf=pass (google.com: domain of steve.capper@arm.com designates 40.107.7.89 as permitted sender) smtp.mailfrom=Steve.Capper@arm.com
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70089.outbound.protection.outlook.com. [40.107.7.89])
        by mx.google.com with ESMTPS id l5si2706031edd.7.2019.06.21.07.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 07:35:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of steve.capper@arm.com designates 40.107.7.89 as permitted sender) client-ip=40.107.7.89;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector2-armh-onmicrosoft-com header.b=tqAjREXx;
       spf=pass (google.com: domain of steve.capper@arm.com designates 40.107.7.89 as permitted sender) smtp.mailfrom=Steve.Capper@arm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=NX5L5F8xPNoJ5V01tQB34FROEeVHHpne1sUFjq/ejGY=;
 b=tqAjREXxnx8hE2bqXIoeIy3DDhwPviqOBrxrnYOVFBwek97GDcXe2IsPRK6kZugNUCWRsrwywSgu0DHg3djMSlRFNEmk5QCGzrA/LTW0F/HAUkE70obv1f8NK5rB7KnMSGfPAkfAjmfFhUsHHVHcS2qyEch61Sz9IfGHVzgy/A8=
Received: from DB8PR08MB4105.eurprd08.prod.outlook.com (20.179.12.12) by
 DB8PR08MB5243.eurprd08.prod.outlook.com (20.179.15.224) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.12; Fri, 21 Jun 2019 14:35:54 +0000
Received: from DB8PR08MB4105.eurprd08.prod.outlook.com
 ([fe80::b4db:b3ed:75ff:167]) by DB8PR08MB4105.eurprd08.prod.outlook.com
 ([fe80::b4db:b3ed:75ff:167%3]) with mapi id 15.20.1987.014; Fri, 21 Jun 2019
 14:35:54 +0000
From: Steve Capper <Steve.Capper@arm.com>
To: Anshuman Khandual <Anshuman.Khandual@arm.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will
 Deacon <Will.Deacon@arm.com>, Mark Rutland <Mark.Rutland@arm.com>,
	"mhocko@suse.com" <mhocko@suse.com>, "ira.weiny@intel.com"
	<ira.weiny@intel.com>, "david@redhat.com" <david@redhat.com>, "cai@lca.pw"
	<cai@lca.pw>, "logang@deltatee.com" <logang@deltatee.com>, James Morse
	<James.Morse@arm.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>,
	"arunks@codeaurora.org" <arunks@codeaurora.org>, "dan.j.williams@intel.com"
	<dan.j.williams@intel.com>, "mgorman@techsingularity.net"
	<mgorman@techsingularity.net>, "osalvador@suse.de" <osalvador@suse.de>, Ard
 Biesheuvel <Ard.Biesheuvel@arm.com>, nd <nd@arm.com>
Subject: Re: [PATCH V6 3/3] arm64/mm: Enable memory hot remove
Thread-Topic: [PATCH V6 3/3] arm64/mm: Enable memory hot remove
Thread-Index: AQHVJlX53xPGOkVoAU2rO4Hf7Xy7J6amMIYA
Date: Fri, 21 Jun 2019 14:35:53 +0000
Message-ID: <20190621143540.GA3376@capper-debian.cambridge.arm.com>
References: <1560917860-26169-1-git-send-email-anshuman.khandual@arm.com>
 <1560917860-26169-4-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1560917860-26169-4-git-send-email-anshuman.khandual@arm.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mutt/1.10.1 (2018-07-13)
x-originating-ip: [82.20.117.196]
x-clientproxiedby: DM5PR18CA0057.namprd18.prod.outlook.com
 (2603:10b6:3:22::19) To DB8PR08MB4105.eurprd08.prod.outlook.com
 (2603:10a6:10:b0::12)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Steve.Capper@arm.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 255e8f05-0120-466c-08c8-08d6f655c382
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DB8PR08MB5243;
x-ms-traffictypediagnostic: DB8PR08MB5243:
nodisclaimer: True
x-microsoft-antispam-prvs:
 <DB8PR08MB5243320303F4912FC6AAB43881E70@DB8PR08MB5243.eurprd08.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0075CB064E
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(396003)(366004)(346002)(136003)(376002)(199004)(189003)(66446008)(5660300002)(3846002)(229853002)(54906003)(66066001)(8676002)(6246003)(6486002)(6862004)(81156014)(4326008)(6436002)(316002)(81166006)(66476007)(66556008)(6512007)(66946007)(53936002)(14444005)(99286004)(58126008)(8936002)(44832011)(76176011)(7416002)(6636002)(26005)(33656002)(446003)(102836004)(7736002)(64756008)(486006)(52116002)(6116002)(186003)(73956011)(476003)(25786009)(71200400001)(71190400001)(2906002)(86362001)(11346002)(6506007)(386003)(68736007)(478600001)(14454004)(305945005)(256004)(1076003)(72206003);DIR:OUT;SFP:1101;SCL:1;SRVR:DB8PR08MB5243;H:DB8PR08MB4105.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 dlqzxa4c3rI15RIYjatdpzG4RA3W30poknff97UGqg+YZ9slzXe1e90bipr9EPWaFPm2KynI0rxMfy7783taBsoETxHXuo888UztQ8fXKJQF2B93AbjfNkqXuSINJnnnUBOH1UK8c+SFcgYHrhw6a12K6kEbUeGomLLQ5NAjXOVcHmqQ8SRlCv3KxSHn60nmHIApe7W2iOE0B4YEgqoAgEtRFRBCvK9SX6WKXKBbZkkPWaqSK3dKGprAn44V+1VP1WaDh5o6U7+UNTBqyaK52f6Epjsks/FHE5wvtNLNP+u3SZ3lAe8XkkcTPnRJLGInzsb3vfiS6UFSQN3JWQePxJVTQxXkPPT8eLv3x4spesy6ktZQ0gEtbEmSQ7Gpz5iA/CDbqNf4sNHGFdD8eEWcXoXhl2uK6xX1lnHSPp0rY8Q=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <13FA276463D2474F8F2A95257EB18BC4@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 255e8f05-0120-466c-08c8-08d6f655c382
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Jun 2019 14:35:53.8832
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Steve.Capper@arm.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB8PR08MB5243
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Anshuman,

On Wed, Jun 19, 2019 at 09:47:40AM +0530, Anshuman Khandual wrote:
> The arch code for hot-remove must tear down portions of the linear map an=
d
> vmemmap corresponding to memory being removed. In both cases the page
> tables mapping these regions must be freed, and when sparse vmemmap is in
> use the memory backing the vmemmap must also be freed.
>=20
> This patch adds a new remove_pagetable() helper which can be used to tear
> down either region, and calls it from vmemmap_free() and
> ___remove_pgd_mapping(). The sparse_vmap argument determines whether the
> backing memory will be freed.
>=20
> remove_pagetable() makes two distinct passes over the kernel page table.
> In the first pass it unmaps, invalidates applicable TLB cache and frees
> backing memory if required (vmemmap) for each mapped leaf entry. In the
> second pass it looks for empty page table sections whose page table page
> can be unmapped, TLB invalidated and freed.
>=20
> While freeing intermediate level page table pages bail out if any of its
> entries are still valid. This can happen for partially filled kernel page
> table either from a previously attempted failed memory hot add or while
> removing an address range which does not span the entire page table page
> range.
>=20
> The vmemmap region may share levels of table with the vmalloc region.
> There can be conflicts between hot remove freeing page table pages with
> a concurrent vmalloc() walking the kernel page table. This conflict can
> not just be solved by taking the init_mm ptl because of existing locking
> scheme in vmalloc(). Hence unlike linear mapping, skip freeing page table
> pages while tearing down vmemmap mapping.
>=20
> While here update arch_add_memory() to handle __add_pages() failures by
> just unmapping recently added kernel linear mapping. Now enable memory ho=
t
> remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.
>=20
> This implementation is overall inspired from kernel page table tear down
> procedure on X86 architecture.
>=20
> Acked-by: David Hildenbrand <david@redhat.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---

FWIW:
Acked-by: Steve Capper <steve.capper@arm.com>

One minor comment below though.

>  arch/arm64/Kconfig  |   3 +
>  arch/arm64/mm/mmu.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++=
++++--
>  2 files changed, 284 insertions(+), 9 deletions(-)
>=20
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 6426f48..9375f26 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -270,6 +270,9 @@ config HAVE_GENERIC_GUP
>  config ARCH_ENABLE_MEMORY_HOTPLUG
>  	def_bool y
> =20
> +config ARCH_ENABLE_MEMORY_HOTREMOVE
> +	def_bool y
> +
>  config SMP
>  	def_bool y
> =20
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index 93ed0df..9e80a94 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -733,6 +733,250 @@ int kern_addr_valid(unsigned long addr)
> =20
>  	return pfn_valid(pte_pfn(pte));
>  }
> +
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +static void free_hotplug_page_range(struct page *page, size_t size)
> +{
> +	WARN_ON(!page || PageReserved(page));
> +	free_pages((unsigned long)page_address(page), get_order(size));
> +}

We are dealing with power of 2 number of pages, it makes a lot more
sense (to me) to replace the size parameter with order.

Also, all the callers are for known compile-time sizes, so we could just
translate the size parameter as follows to remove any usage of get_order?
PAGE_SIZE -> 0
PMD_SIZE -> PMD_SHIFT - PAGE_SHIFT
PUD_SIZE -> PUD_SHIFT - PAGE_SHIFT

Cheers,
--=20
Steve

