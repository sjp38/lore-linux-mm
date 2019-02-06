Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18368C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:17:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D19E42175B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:17:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D19E42175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73C238E00B4; Wed,  6 Feb 2019 07:17:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6ECAA8E00AA; Wed,  6 Feb 2019 07:17:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DB898E00B4; Wed,  6 Feb 2019 07:17:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE268E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 07:17:25 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id q11so5792885otl.23
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 04:17:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=II8OMufhG/IDudGVaJTEeoLvmhvMsANdXN5ZKG00Km8=;
        b=oUBmGZr4dR0AfdYKL1XtoNzlDJSVN1lEE4X/ZqExWAyBKSGt6nrMCREt5UVvHCPcuK
         yYBYXKAGXjnJchG0FSYoY8khw8J0H7Wm+hK6b79hXPUYqzfRhBDjQUQnyqr4kcfV66QQ
         6g42EFt+WUh/kKJG9lRmzwYqtOpT3OEAKRzsHbFDqN7gb6AW2kDZuGqJfSyzy2RKgRV8
         mhYAzUipl8mF6SBhvoPLn8OFcBb0ryoSbaBjh6OCVJAF7xNwBtLFPj+We01P4ro5zyAQ
         Bg91JYKw2/m9FYu4u6oArslx5li1LRJXcB08Ggm9nR9wn+RzGNveIx7C8FxwBsw22VEX
         a0XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuZrI6w5tIuVKk47YAMhmm8spFeVn8ShT2/OTwJiyiQATiH+H5mW
	JR8H0BmNKEkoPO1R3Aq4XKRxnECPzfP37tzWetQRcZ5XQntAfH9u5YKrYmkPSQOpwjVnLgxtQIp
	8BO1SQlqGi9LX6HSHew7VP5bizmMH2v8wEAUu9Xvj/eLjosdfLvlWrOcJFiGYY45n8A==
X-Received: by 2002:a9d:3ecb:: with SMTP id b69mr5175816otc.329.1549455444838;
        Wed, 06 Feb 2019 04:17:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia/fGIdePywrFW8mXFrVnRxYtukHKwSsk8Xuwiphy0sI0FEnayf1agR71QPSfbl9ozX1z61
X-Received: by 2002:a9d:3ecb:: with SMTP id b69mr5175767otc.329.1549455443387;
        Wed, 06 Feb 2019 04:17:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549455443; cv=none;
        d=google.com; s=arc-20160816;
        b=bcbTC77Uxm16+YoV2gtaHog1aKb4wOQ0/2oFwmGeBlqPMwq7nO6LhEFB5fluWUwSTs
         Eglrm09B4nqdsi+nowVoKCeT3AsO7SoWIkxSkhQw9np53zme8sZZkkCcyMgEc7dqE2tc
         yJBDN7L6NQiTRGeGF4BkVboIa87QVslw+9i0hIl4pbmFKYhG/CZZHXtk4ZtQIgNjDjQa
         iGHOe3A9MOmBuxagPP2wwTWu7cOE1HXMFSZsPMXAqY/Nmdg5AEMmPJ/uv6k0EtQUUGsK
         DLTqudMFQqVQXjlZ1AanHYQ9ydleC62M5NL9ZWoTN7ZMPfKWXc/4kPvu0uzAyInKPvRw
         AItg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=II8OMufhG/IDudGVaJTEeoLvmhvMsANdXN5ZKG00Km8=;
        b=LjyY5qTPMlJO1AWCy3gNbjRvMbtObHR8ZA5DOU/1lumVkVLTupmNBLBqh411Y33+7M
         3cXQDjRaXCR8pNr2VxS9D1mYPSu1mE5rK5kcv+IKxqDMCg0aH0QuGJuAVEGo8JrGyud/
         /nf5r9RSvBLetocegbMD5W60w0yR/2+xopGt/Pc1YyRoVXZNhv+HGdErgYXhliV/8H7X
         lD+m8G7kFBotJAW3LB5VpZuuEtN7OatPnERC3dq9z5RiEZQxg8hqez01HFLLpFGxBdAL
         ygiVkjWpjYT5esH78PIT14iJgq0RdbhEi0cY0t3BJgz9sBFhKhQzYxzPV3rpIdOhNQRf
         FQRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id f203si9039091oig.29.2019.02.06.04.17.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 04:17:23 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS412-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 16D01AC5852869D1A110;
	Wed,  6 Feb 2019 20:17:19 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS412-HUB.china.huawei.com
 (10.3.19.212) with Microsoft SMTP Server id 14.3.408.0; Wed, 6 Feb 2019
 20:17:17 +0800
Date: Wed, 6 Feb 2019 12:17:06 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 09/10] acpi/hmat: Register memory side cache
 attributes
Message-ID: <20190206121706.00005246@huawei.com>
In-Reply-To: <20190124230724.10022-10-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
	<20190124230724.10022-10-keith.busch@intel.com>
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

On Thu, 24 Jan 2019 16:07:23 -0700
Keith Busch <keith.busch@intel.com> wrote:

> Register memory side cache attributes with the memory's node if HMAT
> provides the side cache iniformation table.
> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>
Trivial suggestion inline.
> ---
>  drivers/acpi/hmat/hmat.c | 32 ++++++++++++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
> 
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index 917e6122b3f0..11f65b38e9f9 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -245,6 +245,7 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
>  				   const unsigned long end)
>  {
>  	struct acpi_hmat_cache *cache = (void *)header;
> +	struct node_cache_attrs cache_attrs;
>  	u32 attrs;
>  
>  	if (cache->header.length < sizeof(*cache)) {
> @@ -258,6 +259,37 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
>  		cache->memory_PD, cache->cache_size, attrs,
>  		cache->number_of_SMBIOShandles);
>  
> +	cache_attrs.size = cache->cache_size;
> +	cache_attrs.level = (attrs & ACPI_HMAT_CACHE_LEVEL) >> 4;
> +	cache_attrs.line_size = (attrs & ACPI_HMAT_CACHE_LINE_SIZE) >> 16;
> +
> +	switch ((attrs & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8) {

FIELD_GET might be nice for these to avoid having the shifts and the mask.

> +	case ACPI_HMAT_CA_DIRECT_MAPPED:
> +		cache_attrs.associativity = NODE_CACHE_DIRECT_MAP;
> +		break;
> +	case ACPI_HMAT_CA_COMPLEX_CACHE_INDEXING:
> +		cache_attrs.associativity = NODE_CACHE_INDEXED;
> +		break;
> +	case ACPI_HMAT_CA_NONE:
> +	default:
> +		cache_attrs.associativity = NODE_CACHE_OTHER;
> +		break;
> +	}
> +
> +	switch ((attrs & ACPI_HMAT_WRITE_POLICY) >> 12) {
> +	case ACPI_HMAT_CP_WB:
> +		cache_attrs.write_policy = NODE_CACHE_WRITE_BACK;
> +		break;
> +	case ACPI_HMAT_CP_WT:
> +		cache_attrs.write_policy = NODE_CACHE_WRITE_THROUGH;
> +		break;
> +	case ACPI_HMAT_CP_NONE:
> +	default:
> +		cache_attrs.write_policy = NODE_CACHE_WRITE_OTHER;
> +		break;
> +	}
> +
> +	node_add_cache(pxm_to_node(cache->memory_PD), &cache_attrs);
>  	return 0;
>  }
>  


