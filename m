Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1A06C282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:25:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8185218A3
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:25:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8185218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38DDB8E00BA; Wed,  6 Feb 2019 07:25:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33CF68E00AA; Wed,  6 Feb 2019 07:25:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 255CB8E00BA; Wed,  6 Feb 2019 07:25:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8A448E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 07:25:14 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id r24so5845211otk.7
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 04:25:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=mi5KBnxjYb4xRc+HhWLqQr3laG5bEwjglidil618y58=;
        b=POPexFqW5D5DvLC4Czvvao9JbFm4zUnwbOA1BMX5IY7KLwNLzWR9/NgnoZK3B5H6Aq
         2GJY5euzr1cUhd6lOE1Gl4eTE/t6Ogdcoet7025nY6tu+0h9nFnjNYIy6B2Q8Z1cKSBl
         HUIiGatZY6k71tKt7CoHx+k0FXfrMc8DwTWmYQRQ86fisWwzp0IRGVjo4ulwzibrWDTy
         bBiiF1DZzm1vs8wafsd6OtmKGXeZdG2ym9AwYOuRgeRe+zTOvDI0Jv/0A9Rn5oZUvkvi
         LUwGy+5/X/GGY9U1RbTB2CENgFNhgcYATToZ6taGYkTU52akF4Qqof0iKqHaXddALrfO
         p0pA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuaOXOD5ggcHUVB+RVj1SPwCLFMQHTpxc8qg3QhzkFcQqMOwj90+
	08ZYr7grgtISMDUBgTK9RxJKGkc+mv6uCCV4pk9WECA539M44kiprYe7Y5T9REpG1FO+GFx2S4r
	jqfgZe+ymmo2Bn1cd5ufVqW6sK3j5ODILEfnvIW7D87ekb1aT1twn/g9WIo/WGu4P8Q==
X-Received: by 2002:aca:3506:: with SMTP id c6mr5441531oia.65.1549455914708;
        Wed, 06 Feb 2019 04:25:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaP6hI0DU9xRvnsGrQj/q/Efm9b2EFOt/RI4RFDzsdXlWM7ztTX4mNRCN1i5dCqxgNWKg56
X-Received: by 2002:aca:3506:: with SMTP id c6mr5441507oia.65.1549455914074;
        Wed, 06 Feb 2019 04:25:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549455914; cv=none;
        d=google.com; s=arc-20160816;
        b=TpX2D0JD3QtvqcYJkF8g03NzkB1K48WnWxJpL/dcyPEo915zZ7enqaR2M4I5vKFSqp
         YgnPDnWDsY2MWGR0ywYW6sgefTMPVYZDT4vaaAC6aqf6hauoN/68tlPFPEEDVVVrAh+A
         M3EpDqtZzaap6wQdJMKdzYSJS5Xn9P8R2YaLrcAYvnoLeKq4Og81aZvDrLKvoKkJuixg
         GT8slw3xYs4k7MQGRL6VQfkgs6XSo2K3GqMLgKJzPpWAvBjPOSqUCHwv3VbUb0TIEUFt
         2u+1ft74qzqT2eQ1kB5FLemi/J/gRWYR3fRN4rSIitNvfYKuvEKe5Z07JNI+vfQ52bpP
         QsXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=mi5KBnxjYb4xRc+HhWLqQr3laG5bEwjglidil618y58=;
        b=yZEyssjpWqhN4p3oSIywuSpZlATJg4zJvM82HHy3k+igZbL+OM2J5Cx2/51ghEIQcg
         +YwWuMuKbXTv6cCIi8o1XuovPL/gIXp0SHAOQBTGkLdmmNfzsjaiWB2x8+ZS+qKLy/7c
         p/t75u6aRxSQ8U0W02zztm3YIXPqjzAIuYsiNczsgPiP6J5x9++Eh8fhDKjbzQZA7h2o
         1nmw5XSfmKrcEVkAutK/pIZtChk8yIRV64/WZJFVlRQo7Rw3kRm57X+UKwA6NlQkBAoS
         5RzOwkJVth1FhFcMnLO+Ksa5Tx2rhvwVUe7IdvWkbr7yL4az7y000o39gTaZfmxB1+sv
         T85g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id r132si9300779oib.112.2019.02.06.04.25.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 04:25:14 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS405-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 88D5DB51B782B0D4FAD9;
	Wed,  6 Feb 2019 20:25:09 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS405-HUB.china.huawei.com
 (10.3.19.205) with Microsoft SMTP Server id 14.3.408.0; Wed, 6 Feb 2019
 20:25:07 +0800
Date: Wed, 6 Feb 2019 12:24:58 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 07/10] acpi/hmat: Register performance attributes
Message-ID: <20190206122458.0000793c@huawei.com>
In-Reply-To: <20190124230724.10022-8-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
	<20190124230724.10022-8-keith.busch@intel.com>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
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

On Thu, 24 Jan 2019 16:07:21 -0700
Keith Busch <keith.busch@intel.com> wrote:

> Register the local attached performace access attributes with the memory's
performance

> node if HMAT provides the locality table. While HMAT does make it possible
> to know performance for all possible initiator-target pairings, we export
> only the local and matching pairings at this time.
> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/acpi/hmat/Kconfig |  1 +
>  drivers/acpi/hmat/hmat.c  | 14 ++++++++++++++
>  2 files changed, 15 insertions(+)
> 
> diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
> index c9637e2e7514..08e972ead159 100644
> --- a/drivers/acpi/hmat/Kconfig
> +++ b/drivers/acpi/hmat/Kconfig
> @@ -2,6 +2,7 @@
>  config ACPI_HMAT
>  	bool "ACPI Heterogeneous Memory Attribute Table Support"
>  	depends on ACPI_NUMA
> +	select HMEM_REPORTING
>  	help
>  	 If set, this option causes the kernel to set the memory NUMA node
>  	 relationships and access attributes in accordance with ACPI HMAT
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index 85fd835c2e23..917e6122b3f0 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -430,6 +430,19 @@ static __init void hmat_register_target_initiators(struct memory_target *target)
>  		hmat_register_if_local(target, initiator);
>  }
>  
> +static __init void hmat_register_target_perf(struct memory_target *target)
> +{
> +	unsigned mem_nid = pxm_to_node(target->memory_pxm);
> +	struct node_hmem_attrs hmem_attrs = {
> +		.read_bandwidth	= target->read_bandwidth,
> +		.write_bandwidth= target->write_bandwidth,
> +		.read_latency	= target->read_latency,
> +		.write_latency	= target->write_latency,
> +	};
> +
> +	node_set_perf_attrs(mem_nid, &hmem_attrs, 0);
> +}
> +
>  static __init void hmat_register_targets(void)
>  {
>  	struct memory_target *target, *tnext;
> @@ -439,6 +452,7 @@ static __init void hmat_register_targets(void)
>  	list_for_each_entry_safe(target, tnext, &targets, node) {
>  		list_del(&target->node);
>  		hmat_register_target_initiators(target);
> +		hmat_register_target_perf(target);
>  		kfree(target);
>  	}
>  


