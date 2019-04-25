Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85E75C4321A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:01:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C63D720678
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:01:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C63D720678
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA54B6B0006; Thu, 25 Apr 2019 15:01:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E55CE6B0008; Thu, 25 Apr 2019 15:01:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D44956B000A; Thu, 25 Apr 2019 15:01:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B92D6B0006
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 15:01:36 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e20so510796pfn.8
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:01:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=LCJXFU5B8rbEvUwiOx4147JjzT/63MWgnqIQeuPDnbg=;
        b=NC49AOJGGkYs88Vx0lMPfbQnFEBTaz1Q3+FYzgKukhs4FMqY9sDN76oKoQHsrsrikH
         /MzrK7CC21H0x6Lx06l+Kw/TFtDoy8UyPBCBtX641E02Sg5sXV9WP9LUnzB1aRK8kBrc
         5YrbhnBl0C4/UpYVogvGZbHAIgMHW2km9Ap8X+jOx0yO7f0Zd+RpIOco/8xFR8kx9acI
         3Aa+6U0N2YXi7pFUMpin0RTaacg58WFGVFKpBQDZMZcnFFlVtbTkts2Dseaf7SX7jQoy
         Ed8fXbWXagQU5SGVOpvwl328tFhdrVFI+IyuYd2qxbRLQhXvCgCrPb746WZNtLRSvcY+
         +7Dw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUgNx0dduL1aoBMUSRnFLlfFK2KfPAQjjd2552AWQcfkvouGMdj
	tnnBX1hWbhxM3FZB0vsgCj5gOAQv4gAMC5VSyOykh1gvjP3/175Us8EUxE1fpsBrjHzCKpByZzD
	KZBK/0S4clKLpQ2d3C71XiLNEPrw8bw23LrRMaf6WFmWhZewckCsbiEeJcT++dnBM0Q==
X-Received: by 2002:a17:902:2b87:: with SMTP id l7mr41355058plb.130.1556218895706;
        Thu, 25 Apr 2019 12:01:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOjoZ+DNRhp54W7fscdV2q1iSlChPBtEWyM+EmJPjacObgl3xFfzowW9D6kjfbKdSSsXiF
X-Received: by 2002:a17:902:2b87:: with SMTP id l7mr41354960plb.130.1556218894801;
        Thu, 25 Apr 2019 12:01:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556218894; cv=none;
        d=google.com; s=arc-20160816;
        b=RtRtk1whlgi94m82aNRfv+Bg8fICVIqjVKuPUT0haGqS1cxhqhl2BN8R6nef6Pkinq
         minBjSSJrTB9nAWRoziPM0jH+PnxhmxQBouJSSz9J/DtoPtSHKCu0MvghDHJ6DoOqp4E
         cp/zldibUcQchAyz3OS/HXa/CTPr5XP8P51n/cufx8CS39vqRar8Yy0WNT3D/q+AuNgz
         W68nMmMBMLyETiCgIZSj58ae2OFsJqG6GXLa2lxcKW/8Hmp+RUuNlU4oSzHF45/pqQ4f
         lA3IMBcIKKKMtAD9Lt4qabDNrB6+YpoVKiW3D99w2IYGEyqWRnyuWG0ESQ6BsVlrztNX
         eAJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:to
         :subject;
        bh=LCJXFU5B8rbEvUwiOx4147JjzT/63MWgnqIQeuPDnbg=;
        b=nPcZaqO3++nbtnOOWmJeYFExy4pQTlf0ziMs3yuCIBT+skQIGa+CbrMc73Bgt83+rh
         ZiE41FEQ2ppUpIHt1b5VYGmpHHwPLvv64hT653zIV25BySDlal9wjgnKtsZi2tX2M4sr
         eL1TtDnftMfGyOkIw1QofIrwfWm+fiD3PpA0AyzvxKnbqCWjcEdnK2Sv++zQnAuL2ZAc
         Z8Wb3YJ24Vj6WjLY0bnIAAv46poAn4nHgEUkEXgmgH2dMthQv9LPCqtOn4dghSd7pnIA
         um8lFJoZMEcwQ9luAa1IJiiJxfdXNqJkRjlfUlnSE9SWsthTQroC4ZuAxWI2JcVRQAtV
         BElA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i1si22907697pld.197.2019.04.25.12.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 12:01:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 12:01:34 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,394,1549958400"; 
   d="scan'208";a="134388328"
Received: from ray.jf.intel.com (HELO [10.7.201.17]) ([10.7.201.17])
  by orsmga007.jf.intel.com with ESMTP; 25 Apr 2019 12:01:33 -0700
Subject: Re: [v3 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Pavel Tatashin <pasha.tatashin@soleen.com>, jmorris@namei.org,
 sashal@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, akpm@linux-foundation.org, mhocko@suse.com,
 dave.hansen@linux.intel.com, dan.j.williams@intel.com,
 keith.busch@intel.com, vishal.l.verma@intel.com, dave.jiang@intel.com,
 zwisler@kernel.org, thomas.lendacky@amd.com, ying.huang@intel.com,
 fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com,
 baiyaowei@cmss.chinamobile.com, tiwai@suse.de, jglisse@redhat.com,
 david@redhat.com
References: <20190425175440.9354-1-pasha.tatashin@soleen.com>
 <20190425175440.9354-3-pasha.tatashin@soleen.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <77c286e3-8708-6e64-94a1-fb44b6bbff3f@intel.com>
Date: Thu, 25 Apr 2019 12:01:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190425175440.9354-3-pasha.tatashin@soleen.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Pavel,

Thanks for doing this!  I knew we'd have to get to it eventually, but
sounds like you needed it sooner rather than later.

...
>  static inline struct dev_dax *to_dev_dax(struct device *dev)
> diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
> index 4c0131857133..6f1640462df9 100644
> --- a/drivers/dax/kmem.c
> +++ b/drivers/dax/kmem.c
> @@ -71,21 +71,107 @@ int dev_dax_kmem_probe(struct device *dev)
>  		kfree(new_res);
>  		return rc;
>  	}
> +	dev_dax->dax_kmem_res = new_res;
>  
>  	return 0;
>  }
>  
> +#ifdef CONFIG_MEMORY_HOTREMOVE

Instead of this #ifdef, is there any downside to doing

	if (!IS_ENABLED(CONFIG_MEMORY_HOTREMOVE)) {
		/*
		 * Without hotremove, purposely leak ...
		 */
		return 0;
	}
		

> +/*
> + * Check that device-dax's memory_blocks are offline. If a memory_block is not
> + * offline a warning is printed and an error is returned. dax hotremove can
> + * succeed only when every memory_block is offlined beforehand.
> + */

I'd much rather see comments inline with the code than all piled at the
top of a function like this.

One thing that would be helpful, though, is a reminder about needing the
device hotplug lock.

> +static int
> +check_memblock_offlined_cb(struct memory_block *mem, void *arg)
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

The two devices confused me for a bit here.  Seems worth a comment to
remind the reader what this device _is_ versus 'mem_dev'.

> +		unsigned long spfn = section_nr_to_pfn(mem->start_section_nr);
> +		unsigned long epfn = section_nr_to_pfn(mem->end_section_nr);
> +		phys_addr_t spa = spfn << PAGE_SHIFT;
> +		phys_addr_t epa = epfn << PAGE_SHIFT;
> +
> +		dev_warn(dev, "memory block [%pa-%pa] is not offline\n",
> +			 &spa, &epa);

I thought we had a magic resource printk %something.  Could we just
print one of the device resources here to save all the section/pfn/paddr
calculations?

Also, should we consider a slightly scarier message?  This path has a
permanent, user-visible effect (we can never try to unbind again).

> +		return -EBUSY;
> +	}
> +
> +	return 0;
> +}

Even though they're static, I'd prefer that we not create two versions
of check_memblock_offlined_cb() in the kernel.  Can we give this a
better, non-conflicting name?

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

How could that happen?  I can't think of any obvious scenarios.

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
> +	rc = walk_memory_range(start_pfn, end_pfn, dev,
> +			       check_memblock_offlined_cb);

Does lock_device_hotplug() also lock memory online/offline?  Otherwise,
isn't this offline check racy?  If not, can you please spell that out in
a comment?

Also, could you compare this a bit to the walk_memory_range() use in
__remove_memory()?  Why do we need two walks looking for offline blocks?

