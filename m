Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36CD2C04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:14:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC0222081C
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 14:14:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC0222081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 777A96B0003; Thu,  2 May 2019 10:14:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7015F6B0006; Thu,  2 May 2019 10:14:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57ABE6B0007; Thu,  2 May 2019 10:14:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 312BB6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 10:14:26 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id w34so2341704qtc.16
        for <linux-mm@kvack.org>; Thu, 02 May 2019 07:14:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=RSbIwFHU7AgL39gzc7AKZT10tSw1+jRY7LqhW/nACuE=;
        b=YuN20r6uby8FSPLesWWA+J4dG1r0EZXsnssjAGEIohgtskoR3e+L5PzhKuqRnUTPVR
         edov6+8P8ShrxdKrCuPTVla3amWThyXq/sKS6yAuO7P/n9Sq1YX/mULpomcLaA1qJLqG
         d/Ta9WXCOLki3+tcC2kOuOBzCJ7UtBKbS5P12skepyKwlJ1cnx+/LzUr8Wbthx9AtyVA
         Du/CyPnnfyU+tyhvqKrQadWlKRaV/vZzy3BZsk/NBlK3LL+UbkCV7QWeRGrhXsm49YhH
         ZUWkr5hnwvuP5uJyZC9euOPMGrcBcnmsHevYPw4p9C8cWA7HSOOJ4JtPjx4Cl/0HbeXk
         0BQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX+m17P7hqVmMoy8pfP8MWOXV7GCT3WSFrJVcVnor1HS+no2ACG
	Q5POA0Q9OP6yruCPd5BBn+zImw2Flg9ieEu3joYWxI2d6BDUGRmSQOWAnv7TPpR1r8s9v9oF/ZP
	Ow4Gk+jSgZocMU5RQAYQJ8z+jM1ok1IeUC2HFMq7rCDN1nEOOD+sloeVEhVYGCT2yyw==
X-Received: by 2002:a05:620a:15fb:: with SMTP id p27mr2989321qkm.286.1556806465941;
        Thu, 02 May 2019 07:14:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLWLGLY2kjW+e9dkfPnxTYNLWJ8KQaN7VGXkDj+DFANAvM0FCBskxvbDfzQsAzPqkeB3in
X-Received: by 2002:a05:620a:15fb:: with SMTP id p27mr2989240qkm.286.1556806464811;
        Thu, 02 May 2019 07:14:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556806464; cv=none;
        d=google.com; s=arc-20160816;
        b=XEltw5ZAOQlFSorW3/H3s77FS5DhZU1HFgNX43IWyQWyPoBHyQEdcIxkVNGmlpgk+0
         qsS9c6QWYa/WvsKf/pgOAT7Ogpodu5mRM6NlXILbAlpQ493G+hLM+U9bWmB1lvQ7uWPe
         omkXXyFGa7H8yyiGSWmaRXJe/Wm+ftf9a0SmVo9g5kB5cskoZ+dZHM+Uahbcj+fAA5wg
         mnTrM0Roen/4PX7jIisXZaRSOC+A9LDV0LlIxTZhX5H1IBiHzCRCktoJ125EMhq+ZLlh
         qLy2Wtx0PrFKpFwQq5LBHdjS/sWY2BGskiC/iTT81C+0kNbeg9y8fCQpIjEmsEBFNEVx
         YKPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:to:subject;
        bh=RSbIwFHU7AgL39gzc7AKZT10tSw1+jRY7LqhW/nACuE=;
        b=U5NHm/rA1u81Bh5cPnI8Rhi74aXFd0097XzohBhwrOI0B44jOXLEJfAQp3iv+U/nBd
         uE9MQVRaROE6N/wx68Kj9k36Qphv2M0sofxXGw08D/zgTY4qEh9jIA2TVa3XoInfc3yg
         S3182Syf0wfGCqvS7kOPUicRvbb1RHfAxTerkxyqA6QYTGbHeuA4j393iGdk0J8u3G+3
         QhK6ONBMsifioH8R04wsznsPHMYoCaZ/3cqJBHwRB6mOWw3xVkZOokAnWYqypQJoZXhx
         7rShrrc6fYwvDlkSfiHp80qur/4wrJcl9jAPBQhHyqlcT7P+BkYAsdZo1wfQ+gsl94/H
         Czag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e35si4472253qte.32.2019.05.02.07.14.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 07:14:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 67B1C13A82;
	Thu,  2 May 2019 14:14:23 +0000 (UTC)
Received: from [10.36.117.88] (ovpn-117-88.ams2.redhat.com [10.36.117.88])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 51D3983179;
	Thu,  2 May 2019 14:14:15 +0000 (UTC)
Subject: Re: [v4 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Pavel Tatashin <pasha.tatashin@soleen.com>, jmorris@namei.org,
 sashal@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, akpm@linux-foundation.org, mhocko@suse.com,
 dave.hansen@linux.intel.com, dan.j.williams@intel.com,
 keith.busch@intel.com, vishal.l.verma@intel.com, dave.jiang@intel.com,
 zwisler@kernel.org, thomas.lendacky@amd.com, ying.huang@intel.com,
 fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com,
 baiyaowei@cmss.chinamobile.com, tiwai@suse.de, jglisse@redhat.com
References: <20190501191846.12634-1-pasha.tatashin@soleen.com>
 <20190501191846.12634-3-pasha.tatashin@soleen.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <9e15bf41-8e74-3a76-c7b9-9712b2d5290b@redhat.com>
Date: Thu, 2 May 2019 16:14:14 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190501191846.12634-3-pasha.tatashin@soleen.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 02 May 2019 14:14:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.05.19 21:18, Pavel Tatashin wrote:
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
>  drivers/dax/kmem.c        | 99 +++++++++++++++++++++++++++++++++++++--
>  2 files changed, 97 insertions(+), 4 deletions(-)
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
> index 4c0131857133..72b868066026 100644
> --- a/drivers/dax/kmem.c
> +++ b/drivers/dax/kmem.c
> @@ -71,21 +71,112 @@ int dev_dax_kmem_probe(struct device *dev)
>  		kfree(new_res);
>  		return rc;
>  	}
> +	dev_dax->dax_kmem_res = new_res;
>  
>  	return 0;
>  }
>  
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +static int
> +check_devdax_mem_offlined_cb(struct memory_block *mem, void *arg)
> +{
> +	/* Memory block device */
> +	struct device *mem_dev = &mem->dev;
> +	bool is_offline;
> +
> +	device_lock(mem_dev);
> +	is_offline = mem_dev->offline;
> +	device_unlock(mem_dev);
> +
> +	/*
> +	 * Check that device-dax's memory_blocks are offline. If a memory_block
> +	 * is not offline a warning is printed and an error is returned.
> +	 */
> +	if (!is_offline) {
> +		/* Dax device device */
> +		struct device *dev = (struct device *)arg;
> +		struct dev_dax *dev_dax = to_dev_dax(dev);
> +		struct resource *res = &dev_dax->region->res;
> +		unsigned long spfn = section_nr_to_pfn(mem->start_section_nr);
> +		unsigned long epfn = section_nr_to_pfn(mem->end_section_nr) +
> +						       PAGES_PER_SECTION - 1;
> +		phys_addr_t spa = spfn << PAGE_SHIFT;
> +		phys_addr_t epa = epfn << PAGE_SHIFT;
> +
> +		dev_err(dev,
> +			"DAX region %pR cannot be hotremoved until the next reboot. Memory block [%pa-%pa] is not offline.\n",
> +			res, &spa, &epa);
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
> +	kmem_start = res->start;
> +	kmem_size = resource_size(res);
> +	start_pfn = kmem_start >> PAGE_SHIFT;
> +	end_pfn = start_pfn + (kmem_size >> PAGE_SHIFT) - 1;
> +
> +	/*
> +	 * Keep hotplug lock while checking memory state, and also required
> +	 * during __remove_memory() call. Admin can't change memory state via
> +	 * sysfs while this lock is kept.
> +	 */
> +	lock_device_hotplug();
> +
> +	/*
> +	 * Walk and check that every singe memory_block of dax region is
> +	 * offline. Hotremove can succeed only when every memory_block is
> +	 * offlined beforehand.
> +	 */
> +	rc = walk_memory_range(start_pfn, end_pfn, dev,
> +			       check_devdax_mem_offlined_cb);
> +
> +	/*
> +	 * If admin has not offlined memory beforehand, we cannot hotremove dax.
> +	 * Unfortunately, because unbind will still succeed there is no way for
> +	 * user to hotremove dax after this.
> +	 */
> +	if (rc) {
> +		unlock_device_hotplug();
> +		return rc;
> +	}
> +
> +	/* Hotremove memory, cannot fail because memory is already offlined */
> +	__remove_memory(dev_dax->target_node, kmem_start, kmem_size);
> +	unlock_device_hotplug();
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

Memory unplug bits

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

