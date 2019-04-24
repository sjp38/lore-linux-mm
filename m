Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECD20C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:55:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A48D218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:55:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A48D218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 409226B0005; Wed, 24 Apr 2019 16:55:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E0036B0006; Wed, 24 Apr 2019 16:55:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A9846B0007; Wed, 24 Apr 2019 16:55:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE676B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 16:55:40 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id z19so14307740qkj.5
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:55:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=tmaPrDxXgPtFEjDeHv8LiWjKFcMzR17j1C3OZ2r2DUk=;
        b=Q/nYorNrQ7gv0k1sxK2QVNUQvfRUaISXtkFUIY0SMFBRNo5P85vzchD1V2/SX341gh
         kSkpgVyYEF8EoqewGDwtg+HH7JSSABNklBCtWt07E6DPHavq/6JLOh4buV70qfKtIAA/
         d8LQArbFmMV/EyncyX++6qUvmwb7rmNlIDEMqfjwbb4h3vyU+Q8Ojcr973gSXFvkcQGh
         U308C1gC/+ssx8wbpT8862R7HXvm1vwHT51sn71hYfMESTPzIixy3XFmeusLCd84V6Si
         2acVcgY8pVcgyHQrpN+tt4AL9QoUXEmXYNHpIrVknkcP+GXbd22V9/tJeAAhQTCwzpqR
         JzTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWMfrcH8qawSfF9sE96SQLyhAeUD3q5pZKEtOZdeuLDEqi1AXsz
	OPEqssmwSlgqOFpTghJmeCm0DZrLo8H9m7FFV/Jyb+KbBnypa1mGwlJtCviRiSDAWqvtoPvqEAN
	a8qOg3DbS9DyVnwr/eLDuY4OovZOuGSUG/xOYLaU42v173X7KFUJ3kWqyj2odd8NhKw==
X-Received: by 2002:a37:b444:: with SMTP id d65mr25885908qkf.125.1556139339790;
        Wed, 24 Apr 2019 13:55:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTEtqJKs0ofS8iQprKk2HGXz95gWyLuUEIHMq9kqiDkMQLux+cCv6ZKQpfkchcoJJbwEor
X-Received: by 2002:a37:b444:: with SMTP id d65mr25885848qkf.125.1556139338897;
        Wed, 24 Apr 2019 13:55:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556139338; cv=none;
        d=google.com; s=arc-20160816;
        b=uVNDqzSxpzzRwirKPS4HMceIoZQBjZnmnI0xe8L7wMrlMdPHzCb2rxOV6/kMkn/mAT
         tFAih1opUCqB4OgLnAaHJowrcrqTBoPQ9lR4hUVtMpCcN1u6Ehszb5/rYa9Bnv0Qz5w+
         1XDFNE4dC7J270CwaWcs0SrnNpSBZX0FOIewQRgo2/WFPX+O1sSALq+EkVQyU86j0OIC
         kC5ZGE24QZ7wEpCOPLO2nrPKamXR0Q711kAiXoGyp+kLQRQJngy2Wwpl2A1bIWOqcWwb
         QuYUwbZdKtifdD7Ko8SaKfPnvrngc8SGZhtmSc5Edl2A6I/7A8D83tBaqzo7nZqmo8Tk
         5yDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:to:subject;
        bh=tmaPrDxXgPtFEjDeHv8LiWjKFcMzR17j1C3OZ2r2DUk=;
        b=XpATdEyyKUoqdN7lFpsRhW6IghljKk14KHhy7Ant3u5O7aFzQEfVaXg6xf8NXMQnot
         Z1RFTq+xp3VPPhIWSH+hdHK4JHCdo7CSfTSjSCwFezz1UkqL8UZ4QB/qiKAJoLXrx5ti
         v3Q20NaK2IpVTnHSd866VOWJPR6PUvfUwEccynRiFnPsCoDGX5LNHIV22mif8REGnyUT
         zaZoZRUO+IfRsl3o/cbrBZeEPv760uZMwlQ1+zLlqo7eTjCNwSXhxGwK3zWFs25C+Or0
         5+mBGCp+wouhg78ZLFCwNGAKvXkfW3wQI4JGUYX9c0rxK/J84Qi1buchOa92khXu8AiQ
         rLqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b28si1232655qtb.197.2019.04.24.13.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 13:55:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B0330308402F;
	Wed, 24 Apr 2019 20:55:37 +0000 (UTC)
Received: from [10.36.116.32] (ovpn-116-32.ams2.redhat.com [10.36.116.32])
	by smtp.corp.redhat.com (Postfix) with ESMTP id F09AA600C4;
	Wed, 24 Apr 2019 20:55:31 +0000 (UTC)
Subject: Re: [v2 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Pavel Tatashin <pasha.tatashin@soleen.com>, jmorris@namei.org,
 sashal@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, akpm@linux-foundation.org, mhocko@suse.com,
 dave.hansen@linux.intel.com, dan.j.williams@intel.com,
 keith.busch@intel.com, vishal.l.verma@intel.com, dave.jiang@intel.com,
 zwisler@kernel.org, thomas.lendacky@amd.com, ying.huang@intel.com,
 fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com,
 baiyaowei@cmss.chinamobile.com, tiwai@suse.de, jglisse@redhat.com
References: <20190421014429.31206-1-pasha.tatashin@soleen.com>
 <20190421014429.31206-3-pasha.tatashin@soleen.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <4ad3c587-6ab8-1307-5a13-a3e73cf569a5@redhat.com>
Date: Wed, 24 Apr 2019 22:55:30 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190421014429.31206-3-pasha.tatashin@soleen.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 24 Apr 2019 20:55:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 21.04.19 03:44, Pavel Tatashin wrote:
> It is now allowed to use persistent memory like a regular RAM, but
> currently there is no way to remove this memory until machine is
> rebooted.
> 
> This work expands the functionality to also allows hotremoving
> previously hotplugged persistent memory, and recover the device for use
> for other purposes.
> 
> To hotremove persistent memory, the management software must first
> offline all memory blocks of dax region, and than unbind it from
> device-dax/kmem driver. So, operations should look like this:
> 
> echo offline > echo offline > /sys/devices/system/memory/memoryN/state
> ...
> echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
> 
> Note: if unbind is done without offlining memory beforehand, it won't be
> possible to do dax0.0 hotremove, and dax's memory is going to be part of
> System RAM until reboot.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> ---
>  drivers/dax/dax-private.h |  2 +
>  drivers/dax/kmem.c        | 91 +++++++++++++++++++++++++++++++++++++--
>  2 files changed, 89 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
> index a45612148ca0..999aaf3a29b3 100644
> --- a/drivers/dax/dax-private.h
> +++ b/drivers/dax/dax-private.h
> @@ -53,6 +53,7 @@ struct dax_region {
>   * @pgmap - pgmap for memmap setup / lifetime (driver owned)
>   * @ref: pgmap reference count (driver owned)
>   * @cmp: @ref final put completion (driver owned)
> + * @dax_mem_res: physical address range of hotadded DAX memory
>   */
>  struct dev_dax {
>  	struct dax_region *region;
> @@ -62,6 +63,7 @@ struct dev_dax {
>  	struct dev_pagemap pgmap;
>  	struct percpu_ref ref;
>  	struct completion cmp;
> +	struct resource *dax_kmem_res;
>  };
>  
>  static inline struct dev_dax *to_dev_dax(struct device *dev)
> diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
> index 4c0131857133..d4896b281036 100644
> --- a/drivers/dax/kmem.c
> +++ b/drivers/dax/kmem.c
> @@ -71,21 +71,104 @@ int dev_dax_kmem_probe(struct device *dev)
>  		kfree(new_res);
>  		return rc;
>  	}
> +	dev_dax->dax_kmem_res = new_res;
>  
>  	return 0;
>  }
>  
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +/*
> + * Check that device-dax's memory_blocks are offline. If a memory_block is not
> + * offline a warning is printed and an error is returned. dax hotremove can
> + * succeed only when every memory_block is offlined beforehand.
> + */
> +static int
> +offline_memblock_cb(struct memory_block *mem, void *arg)

Function name suggests that you are actually trying to offline memory
here. Maybe check_memblocks_offline_cb(), just like we have in
mm/memory_hotplug.c.

> +{
> +	struct device *mem_dev = &mem->dev;
> +	bool is_offline;
> +
> +	device_lock(mem_dev);
> +	is_offline = mem_dev->offline;
> +	device_unlock(mem_dev);
> +
> +	if (!is_offline) {
> +		struct device *dev = (struct device *)arg;
> +		unsigned long spfn = section_nr_to_pfn(mem->start_section_nr);
> +		unsigned long epfn = section_nr_to_pfn(mem->end_section_nr);
> +		phys_addr_t spa = spfn << PAGE_SHIFT;
> +		phys_addr_t epa = epfn << PAGE_SHIFT;
> +
> +		dev_warn(dev, "memory block [%pa-%pa] is not offline\n",
> +			 &spa, &epa);
> +
> +		return -EBUSY;
> +	}
> +
> +	return 0;
> +}
> +
> +static int dev_dax_kmem_remove(struct device *dev)
> +{
> +	struct dev_dax *dev_dax = to_dev_dax(dev);
> +	struct resource *res = dev_dax->dax_kmem_res;
> +	resource_size_t kmem_start;
> +	resource_size_t kmem_size;
> +	unsigned long start_pfn;
> +	unsigned long end_pfn;
> +	int rc;
> +
> +	/*
> +	 * dax kmem resource does not exist, means memory was never hotplugged.
> +	 * So, nothing to do here.
> +	 */
> +	if (!res)
> +		return 0;
> +
> +	kmem_start = res->start;
> +	kmem_size = resource_size(res);
> +	start_pfn = kmem_start >> PAGE_SHIFT;
> +	end_pfn = start_pfn + (kmem_size >> PAGE_SHIFT) - 1;
> +
> +	/*
> +	 * Walk and check that every singe memory_block of dax region is
> +	 * offline
> +	 */
> +	lock_device_hotplug();
> +	rc = walk_memory_range(start_pfn, end_pfn, dev, offline_memblock_cb);
> +	unlock_device_hotplug();
> +
> +	/*
> +	 * If admin has not offlined memory beforehand, we cannot hotremove dax.
> +	 * Unfortunately, because unbind will still succeed there is no way for
> +	 * user to hotremove dax after this.
> +	 */
> +	if (rc)
> +		return rc;

Can't it happen that there is a race between you checking if memory is
offline and an admin onlining memory again? maybe pull the
remove_memory() into the locked region, using __remove_memory() instead.

> +
> +	/* Hotremove memory, cannot fail because memory is already offlined */
> +	remove_memory(dev_dax->target_node, kmem_start, kmem_size);
> +
> +	/* Release and free dax resources */
> +	release_resource(res);
> +	kfree(res);
> +	dev_dax->dax_kmem_res = NULL;
> +
> +	return 0;
> +}
> +#else
>  static int dev_dax_kmem_remove(struct device *dev)
>  {
>  	/*
> -	 * Purposely leak the request_mem_region() for the device-dax
> -	 * range and return '0' to ->remove() attempts. The removal of
> -	 * the device from the driver always succeeds, but the region
> -	 * is permanently pinned as reserved by the unreleased
> +	 * Without hotremove purposely leak the request_mem_region() for the
> +	 * device-dax range and return '0' to ->remove() attempts. The removal
> +	 * of the device from the driver always succeeds, but the region is
> +	 * permanently pinned as reserved by the unreleased
>  	 * request_mem_region().
>  	 */
>  	return 0;
>  }
> +#endif /* CONFIG_MEMORY_HOTREMOVE */
>  
>  static struct dax_device_driver device_dax_kmem_driver = {
>  	.drv = {
> 


-- 

Thanks,

David / dhildenb

