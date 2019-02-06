Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32F6EC282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:26:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D13DD2073D
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 12:26:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D13DD2073D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 821DE8E00BB; Wed,  6 Feb 2019 07:26:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F74A8E00AA; Wed,  6 Feb 2019 07:26:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70F2D8E00BB; Wed,  6 Feb 2019 07:26:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4746B8E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 07:26:19 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id g4so5938258otl.14
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 04:26:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=dII07c4W0htzdVtth7I+TCEXJkcVOeWjLDqvsRI8Z8Y=;
        b=cf7HfoYOW6OYXDH22P+/zheyNO7oShpk11VeZjvWeF56Qv4TXp0BWnDmHxTP/68o9W
         yz80jG+1V8hkjL+L+bwKQaZv6uplS1IU5gDlfUxe3QxpW0gQKx9wN3XAThwoNNm8Xe1w
         oTcjfXaJ/Qhs4ewTqTzak+enH3ezIE0EtDikJpwdF7jRmDXwL49coLJ5tVPaJ4Tt7GL4
         0MyjTwFxCgp/PUJP99Qy25Po0qtbwWVjFh042twVfYU7srONIYBdastXCxXynUONnRqW
         kpAsoq2OztQf9TB5slKuMdI5k2u4p6MWDVX+8M/PNKtpDA13VUXCp/CfmX+5Yxvm3CCW
         AfJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuaDhPoKoBZ+gnwY6SmU1/BNJ3SIH3gKwq4PxDcXpMG8OkP/GOG1
	uFhlsZdke6SCU4UwER3ea6P4OEzCo8cwwUxuaxapAETnm6d9I+F/fH13/3KJ+p7g8MkQe+U0pta
	ESWpOqfUKrz0+m94VbWX/wzfOC4iAJB7a+W2Sa6aQooEoZYOnBMm8bFDGyAyFXzW4jg==
X-Received: by 2002:aca:554b:: with SMTP id j72mr1404028oib.282.1549455979029;
        Wed, 06 Feb 2019 04:26:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbEAABaUZrtFDMnkdXhs/dgx3BQcsQ3e0AvrVStRM1fvxeFkY+/wahvjs7rRkF6/774iNRI
X-Received: by 2002:aca:554b:: with SMTP id j72mr1403997oib.282.1549455978098;
        Wed, 06 Feb 2019 04:26:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549455978; cv=none;
        d=google.com; s=arc-20160816;
        b=eNoY3krvm8pS/zhE9+dgeC2Vor18o3UfI1EefF5i1PoZVXP86gqSNF2I2kyKRq6x8I
         J22If8g1IBpduVEgVtFyXS5/yyYKSoHvOpHhvNxb8S7eE5meiKsvr3VTN8nMzPD7zWsI
         Ao5GRrjbFI9hgKsJE/YMmIOIcJVNR22d64+152XiwekxI3Df/nTwqp7M7lA7DDSbpkm4
         Z4icfOZ2XML9C9IWFhv0fqOe7KGYMK7o4/8GuD3d0ZFdDgNVOgeB8ujX41XyRcafgJH8
         MMq9ep5/GtMFaIF+9EXkIMzTX03wPJrigU5ZSzRma/CinrxW/x4ZamYVrx2Z8FkNIUp5
         525g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=dII07c4W0htzdVtth7I+TCEXJkcVOeWjLDqvsRI8Z8Y=;
        b=cvZOVoa6S55uNW1aAgPawFVk2SzEif3j8rrk9g3EZCVpZ2kyMl/6iJ45l95msOq6zL
         Zv70Vea3jwMbH7egGFSnKCzOypiDn1qZZ15RNpNFr+zFttgFd+he58YkuG+gKvmGQp0U
         VcI95maHzVgrO9HKju/F8drMSeUw0NS1s4WDeJz+Ge7XZY4ezgWPCkpoqUkLcQtg3i7z
         GK5oFkPluI78Kvgi0iTQF74n1QQwGxkm1bbukG6IpUc1VKdG7XAYHF1EQc1+/SYDxXWV
         seAzzoSZgmbtFxit6MvsqH2JV3DW8LzuVBuV9tI87MhwYh99Y+HxVU+grtdIyFcC9PTZ
         4b6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id v134si9229993oie.236.2019.02.06.04.26.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 04:26:18 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id E5041BF2ED58E3A20B87;
	Wed,  6 Feb 2019 20:26:12 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.408.0; Wed, 6 Feb 2019
 20:26:11 +0800
Date: Wed, 6 Feb 2019 12:26:00 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 05/10] acpi/hmat: Register processor domain to its
 memory
Message-ID: <20190206122600.00006585@huawei.com>
In-Reply-To: <20190124230724.10022-6-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
	<20190124230724.10022-6-keith.busch@intel.com>
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

On Thu, 24 Jan 2019 16:07:19 -0700
Keith Busch <keith.busch@intel.com> wrote:

> If the HMAT Subsystem Address Range provides a valid processor proximity
> domain for a memory domain, or a processor domain matches the performance
> access of the valid processor proximity domain, register the memory
> target with that initiator so this relationship will be visible under
> the node's sysfs directory.
> 
> Since HMAT requires valid address ranges have an equivalent SRAT entry,
> verify each memory target satisfies this requirement.
> 
> Signed-off-by: Keith Busch <keith.busch@intel.com>
A few comments inilne.

Thanks,

Jonathan

> ---
>  drivers/acpi/hmat/hmat.c | 310 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 310 insertions(+)
> 
> diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
> index 1741bf30d87f..85fd835c2e23 100644
> --- a/drivers/acpi/hmat/hmat.c
> +++ b/drivers/acpi/hmat/hmat.c
> @@ -16,6 +16,91 @@
>  #include <linux/node.h>
>  #include <linux/sysfs.h>
>  
> +static __initdata LIST_HEAD(targets);
> +static __initdata LIST_HEAD(initiators);
> +static __initdata LIST_HEAD(localities);
> +
> +struct memory_target {
> +	struct list_head node;
> +	unsigned int memory_pxm;
> +	unsigned int processor_pxm;
> +	unsigned int read_bandwidth;
> +	unsigned int write_bandwidth;
> +	unsigned int read_latency;
> +	unsigned int write_latency;
> +};
> +
> +struct memory_initiator {
> +	struct list_head node;
> +	unsigned int processor_pxm;
> +};
> +
> +struct memory_locality {
> +	struct list_head node;
> +	struct acpi_hmat_locality *hmat_loc;
> +};
> +
> +static __init struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
> +{
> +	struct memory_initiator *intitator;
> +
> +	list_for_each_entry(intitator, &initiators, node)
> +		if (intitator->processor_pxm == cpu_pxm)
> +			return intitator;
> +	return NULL;
> +}
> +
> +static __init struct memory_target *find_mem_target(unsigned int mem_pxm)
> +{
> +	struct memory_target *target;
> +
> +	list_for_each_entry(target, &targets, node)
> +		if (target->memory_pxm == mem_pxm)
> +			return target;
> +	return NULL;
> +}
> +
> +static __init struct memory_initiator *alloc_memory_initiator(
> +							unsigned int cpu_pxm)
> +{
> +	struct memory_initiator *intitator;
> +
> +	if (pxm_to_node(cpu_pxm) == NUMA_NO_NODE)
> +		return NULL;
> +
> +	intitator = find_mem_initiator(cpu_pxm);
> +	if (intitator)
> +		return intitator;
> +
> +	intitator = kzalloc(sizeof(*intitator), GFP_KERNEL);
> +	if (!intitator)
> +		return NULL;
> +
> +	intitator->processor_pxm = cpu_pxm;
> +	list_add_tail(&intitator->node, &initiators);
> +	return intitator;
> +}
> +
> +static __init void alloc_memory_target(unsigned int mem_pxm)
> +{
> +	struct memory_target *target;
> +
> +	if (pxm_to_node(mem_pxm) == NUMA_NO_NODE)
> +		return;
> +
> +	target = find_mem_target(mem_pxm);
> +	if (target)
> +		return;
> +
> +	target = kzalloc(sizeof(*target), GFP_KERNEL);
> +	if (!target)
> +		return;
> +
> +	target->memory_pxm = mem_pxm;
> +	target->processor_pxm = PXM_INVAL;
> +	list_add_tail(&target->node, &targets);
> +}
> +
>  static __init const char *hmat_data_type(u8 type)
>  {
>  	switch (type) {
> @@ -52,13 +137,45 @@ static __init const char *hmat_data_type_suffix(u8 type)
>  	};
>  }
>  
> +static __init void hmat_update_target_access(struct memory_target *target,
> +                                             u8 type, u32 value)
> +{
> +	switch (type) {
> +	case ACPI_HMAT_ACCESS_LATENCY:
> +		target->read_latency = value;
> +		target->write_latency = value;
> +		break;
> +	case ACPI_HMAT_READ_LATENCY:
> +		target->read_latency = value;
> +		break;
> +	case ACPI_HMAT_WRITE_LATENCY:
> +		target->write_latency = value;
> +		break;
> +	case ACPI_HMAT_ACCESS_BANDWIDTH:
> +		target->read_bandwidth = value;
> +		target->write_bandwidth = value;
> +		break;
> +	case ACPI_HMAT_READ_BANDWIDTH:
> +		target->read_bandwidth = value;
> +		break;
> +	case ACPI_HMAT_WRITE_BANDWIDTH:
> +		target->write_bandwidth = value;
> +		break;
> +	default:
> +		break;
> +	};
> +}
> +
>  static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>  				      const unsigned long end)
>  {
>  	struct acpi_hmat_locality *hmat_loc = (void *)header;
> +	struct memory_target *target;
> +	struct memory_initiator *initiator;
>  	unsigned int init, targ, total_size, ipds, tpds;
>  	u32 *inits, *targs, value;
>  	u16 *entries;
> +	bool report = false;
>  	u8 type;
>  
>  	if (hmat_loc->header.length < sizeof(*hmat_loc)) {
> @@ -82,16 +199,42 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
>  		hmat_loc->flags, hmat_data_type(type), ipds, tpds,
>  		hmat_loc->entry_base_unit);
>  
> +	/* Don't report performance of memory side caches */
> +	switch (hmat_loc->flags & ACPI_HMAT_MEMORY_HIERARCHY) {
> +	case ACPI_HMAT_MEMORY:
> +	case ACPI_HMAT_LAST_LEVEL_CACHE:

Both can be true under ACPI 6.2 do we actually want to report them both if
they are both there?

> +		report = true;
> +		break;
> +	default:
> +		break;
> +	}
> +
>  	inits = (u32 *)(hmat_loc + 1);
>  	targs = &inits[ipds];
>  	entries = (u16 *)(&targs[tpds]);
>  	for (init = 0; init < ipds; init++) {
> +		initiator = alloc_memory_initiator(inits[init]);
Error handling?

>  		for (targ = 0; targ < tpds; targ++) {
>  			value = entries[init * tpds + targ];
>  			value = (value * hmat_loc->entry_base_unit) / 10;
>  			pr_info("  Initiator-Target[%d-%d]:%d%s\n",
>  				inits[init], targs[targ], value,
>  				hmat_data_type_suffix(type));
> +
> +			target = find_mem_target(targs[targ]);
> +			if (target && report &&
> +			    target->processor_pxm == initiator->processor_pxm)
> +				hmat_update_target_access(target, type, value);
> +		}
> +	}
> +
> +	if (report) {
> +		struct memory_locality *loc;
> +
> +		loc = kzalloc(sizeof(*loc), GFP_KERNEL);
> +		if (loc) {
> +			loc->hmat_loc = hmat_loc;
> +			list_add_tail(&loc->node, &localities);
>  		}

Error handling for that memory alloc failing?  Obviously it's unlikely
to happen, but nice to handle it anyway.

>  	}
>  
> @@ -122,16 +265,35 @@ static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
>  					   const unsigned long end)
>  {
>  	struct acpi_hmat_address_range *spa = (void *)header;
> +	struct memory_target *target = NULL;
>  
>  	if (spa->header.length != sizeof(*spa)) {
>  		pr_debug("HMAT: Unexpected address range header length: %d\n",
>  			 spa->header.length);
>  		return -EINVAL;
>  	}
> +

Might as well tidy that to the right patch.

>  	pr_info("HMAT: Memory (%#llx length %#llx) Flags:%04x Processor Domain:%d Memory Domain:%d\n",
>  		spa->physical_address_base, spa->physical_address_length,
>  		spa->flags, spa->processor_PD, spa->memory_PD);
>  
> +	if (spa->flags & ACPI_HMAT_MEMORY_PD_VALID) {
> +		target = find_mem_target(spa->memory_PD);
> +		if (!target) {
> +			pr_debug("HMAT: Memory Domain missing from SRAT\n");
> +			return -EINVAL;
> +		}
> +	}
> +	if (target && spa->flags & ACPI_HMAT_PROCESSOR_PD_VALID) {
> +		int p_node = pxm_to_node(spa->processor_PD);
> +
> +		if (p_node == NUMA_NO_NODE) {
> +			pr_debug("HMAT: Invalid Processor Domain\n");
> +			return -EINVAL;
> +		}
> +		target->processor_pxm = p_node;
> +	}
> +
>  	return 0;
>  }
>  
> @@ -155,6 +317,142 @@ static int __init hmat_parse_subtable(union acpi_subtable_headers *header,
>  	}
>  }
>  
> +static __init int srat_parse_mem_affinity(union acpi_subtable_headers *header,
> +					  const unsigned long end)
> +{
> +	struct acpi_srat_mem_affinity *ma = (void *)header;
> +
> +	if (!ma)
> +		return -EINVAL;
> +	if (!(ma->flags & ACPI_SRAT_MEM_ENABLED))
> +		return 0;
> +	alloc_memory_target(ma->proximity_domain);
> +	return 0;
> +}
> +
> +static __init bool hmat_is_local(struct memory_target *target,
> +                                 u8 type, u32 value)
> +{
> +	switch (type) {
> +	case ACPI_HMAT_ACCESS_LATENCY:
> +		return value == target->read_latency &&
> +		       value == target->write_latency;
> +	case ACPI_HMAT_READ_LATENCY:
> +		return value == target->read_latency;
> +	case ACPI_HMAT_WRITE_LATENCY:
> +		return value == target->write_latency;
> +	case ACPI_HMAT_ACCESS_BANDWIDTH:
> +		return value == target->read_bandwidth &&
> +		       value == target->write_bandwidth;
> +	case ACPI_HMAT_READ_BANDWIDTH:
> +		return value == target->read_bandwidth;
> +	case ACPI_HMAT_WRITE_BANDWIDTH:
> +		return value == target->write_bandwidth;
> +	default:
> +		return true;
> +	};
> +}
> +
> +static bool hmat_is_local_initiator(struct memory_target *target,
> +				    struct memory_initiator *initiator,
> +				    struct acpi_hmat_locality *hmat_loc)
> +{
> +	unsigned int ipds, tpds, i, idx = 0, tdx = 0;
> +	u32 *inits, *targs, value;
> +	u16 *entries;
> +
> +	ipds = hmat_loc->number_of_initiator_Pds;
> +	tpds = hmat_loc->number_of_target_Pds;
> +	inits = (u32 *)(hmat_loc + 1);
> +	targs = &inits[ipds];
> +	entries = (u16 *)(&targs[tpds]);
As earlier, I'd prefer not having indexes off the end of arrays.
Clearer to my eye to just have explicit pointer maths.

> +
> +	for (i = 0; i < ipds; i++) {
> +		if (inits[i] == initiator->processor_pxm) {
> +			idx = i;
> +			break;
> +		}
> +	}
> +
> +	if (i == ipds)
> +		return false;
> +
> +	for (i = 0; i < tpds; i++) {
> +		if (targs[i] == target->memory_pxm) {
> +			tdx = i;
> +			break;
> +		}
> +	}
> +	if (i == tpds)
> +		return false;
> +
> +	value = entries[idx * tpds + tdx];
> +	value = (value * hmat_loc->entry_base_unit) / 10;
Just noticed, this might well overflow.  entry_base_unit is 8 bytes long.

> +
> +	return hmat_is_local(target, hmat_loc->data_type, value);
> +}
> +
> +static __init void hmat_register_if_local(struct memory_target *target,
> +					  struct memory_initiator *initiator)
> +{
> +	unsigned int mem_nid, cpu_nid;
> +	struct memory_locality *loc;
> +
> +	if (initiator->processor_pxm == target->processor_pxm)
> +		return;
> +
> +	list_for_each_entry(loc, &localities, node)
> +		if (!hmat_is_local_initiator(target, initiator, loc->hmat_loc))
> +			return;
> +
> +	mem_nid = pxm_to_node(target->memory_pxm);
> +	cpu_nid = pxm_to_node(initiator->processor_pxm);
> +	register_memory_node_under_compute_node(mem_nid, cpu_nid, 0);
> +}
> +
> +static __init void hmat_register_target_initiators(struct memory_target *target)
> +{
> +	struct memory_initiator *initiator;
> +	unsigned int mem_nid, cpu_nid;
> +
> +	if (target->processor_pxm == PXM_INVAL)
> +		return;
> +
> +	mem_nid = pxm_to_node(target->memory_pxm);
> +	cpu_nid = pxm_to_node(target->processor_pxm);
> +	if (register_memory_node_under_compute_node(mem_nid, cpu_nid, 0))

As mentioned in previous patch, I think this can register devices
that aren't freed in the error path... 

In general I think the error handling needs another look.
In particular making sure we get helpful error messages for likely
table errors.

> +		return;
> +
> +	if (list_empty(&localities))
> +		return;
> +
> +	list_for_each_entry(initiator, &initiators, node)
> +		hmat_register_if_local(target, initiator);
> +}
> +
> +static __init void hmat_register_targets(void)
> +{
> +	struct memory_target *target, *tnext;
> +	struct memory_locality *loc, *lnext;
> +	struct memory_initiator *intitator, *inext;
> +
> +	list_for_each_entry_safe(target, tnext, &targets, node) {
> +		list_del(&target->node);
> +		hmat_register_target_initiators(target);
> +		kfree(target);
> +	}
> +
> +	list_for_each_entry_safe(intitator, inext, &initiators, node) {
> +		list_del(&intitator->node);
> +		kfree(intitator);
> +	}
> +
> +	list_for_each_entry_safe(loc, lnext, &localities, node) {
> +		list_del(&loc->node);
> +		kfree(loc);
> +	}
> +}
> +
>  static __init int hmat_init(void)
>  {
>  	struct acpi_table_header *tbl;
> @@ -164,6 +462,17 @@ static __init int hmat_init(void)
>  	if (srat_disabled())
>  		return 0;
>  
> +	status = acpi_get_table(ACPI_SIG_SRAT, 0, &tbl);
> +	if (ACPI_FAILURE(status))
> +		return 0;
> +
> +	if (acpi_table_parse_entries(ACPI_SIG_SRAT,
> +				sizeof(struct acpi_table_srat),
> +				ACPI_SRAT_TYPE_MEMORY_AFFINITY,
> +				srat_parse_mem_affinity, 0) < 0)
> +		goto out_put;
> +	acpi_put_table(tbl);
> +
>  	status = acpi_get_table(ACPI_SIG_HMAT, 0, &tbl);
>  	if (ACPI_FAILURE(status))
>  		return 0;
> @@ -174,6 +483,7 @@ static __init int hmat_init(void)
>  					     hmat_parse_subtable, 0) < 0)
>  			goto out_put;
>  	}
> +	hmat_register_targets();
>  out_put:
>  	acpi_put_table(tbl);
>  	return 0;


