Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D8C4C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 11:22:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1B602075C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 11:22:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1B602075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9028F8E0018; Mon, 11 Mar 2019 07:22:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B29C8E0002; Mon, 11 Mar 2019 07:22:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 754928E0018; Mon, 11 Mar 2019 07:22:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2618E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 07:22:12 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id r22so2620299otk.1
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 04:22:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=V7KvQJVfMyuHJJopiQ1mG3Lbgtsi0/OmlyDfYBCBs0E=;
        b=pa+kuz28TAPrj9+9hfNaYPpkb+MCg73zgBoPVTI5MxBpmCB5GAEVMJtdxhoA/XbThK
         239JLAeK7gtYF4nUm4VoNJHSiCUZQdEbxEamHxbjJjfjwy+9DLASN9TVoFtMWzYAg7Pi
         +d0toglIkz4yXlRgRgDXMn8Hak2+plzDBPGIrIqIntigcpY8fCMmFsV2vh10iqecPISk
         n8kFcw5BGvYNt2zVJEdz0Gl38VylLQDFk+rSQBBoRF6ZVINRe4DKxzJyfujwlyw3MApa
         guN5+J5SiiN2xcQBYN0JnUgDS596P7QzcZSwylghV+lgxDH+H3jj7WkhFqxxBIQj6OWD
         3jSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAUNZ+xGqGSpumTJqLZGJyqQMd/Mmic18h6dTb6L+uoqPYjP0PHh
	NrERWYALTMGPxFtCDjSPmOEQ44P8tUEDaHctfDFlamL9HlqgDSs/prd+sgkdfS5y+YXOu/Yf9pD
	nxhyWpCLtrabHcLsBpE7wnweBgzX3qRWOGQvpbr5IOTAMUPT52KvCd2bcB5MiKoGSCw==
X-Received: by 2002:a05:6830:1642:: with SMTP id h2mr20439192otr.152.1552303331971;
        Mon, 11 Mar 2019 04:22:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybmfwstsyriwogMpnhJsuVBCS3EVkvR+X4nZR9Iy7Juww16mlG4bp0HvpFIvPX8pE9SoX7
X-Received: by 2002:a05:6830:1642:: with SMTP id h2mr20439160otr.152.1552303331287;
        Mon, 11 Mar 2019 04:22:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552303331; cv=none;
        d=google.com; s=arc-20160816;
        b=slqmv7RtnKc7yvVagn7efEPDzRH26ShRjr6O/iMgVXjr8YR+L1+FXCUdnaqdsD/Ud9
         Rw7ekQS4OaWioEAqeP90bBBAy8visErooQ1sijz3ody+qU+UyGGj8u1hlkPiFCOmbZuW
         sRQvXmRm7J5AYGd8TtQmogo0h6ziY+iXo3kJXL+1bd3BnT5XKgGe/KkxGo+jsu7zx3Kj
         BshTCikDxKQNaMwFkgXD1Rvg42dMoTf52/Rn5Q8Eiy429P7t5mp94fZolhxuZA6mcT2V
         G1lOIFIF2BCY2SocTiwn33DSwOOkq5V9Sb6sFblMllxzwsinJwpDaBCkoTgcxTB95EJ1
         cTQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=V7KvQJVfMyuHJJopiQ1mG3Lbgtsi0/OmlyDfYBCBs0E=;
        b=fBNw5DHGNNUnfuuS2p/l6tYgOzBXkJ+tH3MWMiLUmJyrMk8mVfLEhac395WpBGH7Cl
         rWJARh0QkBweJULpiU3zgjTpYPli3SKpTP3biXXzW0UOm4tAFnI8xxdl+SitoYjiJgNh
         Y8SPh8AD3Tscg2XOZlgTMPdsreqw+Ol26JEVrPtkVaKZI6H7qP//704ytmNF4Ok5fIUG
         s8QVsmlGzEwC+P86ST/wGzquiCcjlj5zmkQZ1wGLKqbEgmhJghBJ7dSA3AEFkNhFcoQn
         S42LG3tTpZOkqEJQCFRkS8L3NnWU7KMMHNFfOwXOFSdtjRT9sD/b7m1TCPvs7tYDjHUs
         UZ0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id h68si2412711otb.17.2019.03.11.04.22.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 04:22:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS405-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 8D0C5B8C6C6F8FFD30DB;
	Mon, 11 Mar 2019 19:22:07 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS405-HUB.china.huawei.com
 (10.3.19.205) with Microsoft SMTP Server id 14.3.408.0; Mon, 11 Mar 2019
 19:22:03 +0800
Date: Mon, 11 Mar 2019 11:21:52 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-api@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, "Dave
 Hansen" <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv7 08/10] acpi/hmat: Register performance attributes
Message-ID: <20190311112152.0000639c@huawei.com>
In-Reply-To: <20190227225038.20438-9-keith.busch@intel.com>
References: <20190227225038.20438-1-keith.busch@intel.com>
	<20190227225038.20438-9-keith.busch@intel.com>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2019 15:50:36 -0700
Keith Busch <keith.busch@intel.com> wrote:

> Save the best performace access attributes and register these with the

performance

> memory's node if HMAT provides the locality table. While HMAT does make
> it possible to know performance for all possible initiator-target
> pairings, we export only the local pairings at this time.
> 
> Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

Jonathan
> ---
>  drivers/acpi/hmat/Kconfig |  5 ++++-
>  drivers/acpi/hmat/hmat.c  | 10 +++++++++-
>  2 files changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> index 13cddd612a52..95a29964dbea 100644
> --- a/drivers/acpi/hmat/Kconfig
> +++ b/drivers/acpi/hmat/Kconfig
> @@ -2,7 +2,10 @@
>  config ACPI_HMAT
>  	bool "ACPI Heterogeneous Memory Attribute Table Support"
>  	depends on ACPI_NUMA
> +	select HMEM_REPORTING
>  	help
>  	 If set, this option has the kernel parse and report the
>  	 platform's ACPI HMAT (Heterogeneous Memory Attributes Table),
> -	 and register memory initiators with their targets.
> +	 register memory initiators with their targets, and export
> +	 performance attributes through the node's sysfs device if
> +	 provided.
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index bb6a11653729..5b469c98a454 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -549,12 +549,20 @@ static __init void hmat_register_target_initiators(struct memory_target *target)
>  	}
>  }
>  
> +static __init void hmat_register_target_perf(struct memory_target *target)
> +{
> +	unsigned mem_nid = pxm_to_node(target->memory_pxm);
> +	node_set_perf_attrs(mem_nid, &target->hmem_attrs, 0);
> +}
> +
>  static __init void hmat_register_targets(void)
>  {
>  	struct memory_target *target;
>  
> -	list_for_each_entry(target, &targets, node)
> +	list_for_each_entry(target, &targets, node) {
>  		hmat_register_target_initiators(target);
> +		hmat_register_target_perf(target);
> +	}
>  }
>  
>  static __init void hmat_free_structures(void)


