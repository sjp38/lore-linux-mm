Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B446FC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:14:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F6DE208C4
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:14:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F6DE208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F41326B0006; Mon,  1 Jul 2019 04:14:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECB5C8E0003; Mon,  1 Jul 2019 04:14:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D44C78E0002; Mon,  1 Jul 2019 04:14:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f77.google.com (mail-ed1-f77.google.com [209.85.208.77])
	by kanga.kvack.org (Postfix) with ESMTP id 803AE6B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 04:14:23 -0400 (EDT)
Received: by mail-ed1-f77.google.com with SMTP id k22so16391400ede.0
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 01:14:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sjeR9vWlObipKU2f44eOK/TerwrftGbdXSes2Tb6kMQ=;
        b=tk6GICoMb2NY1zdnsBCq+7OD3VPYoRoLrJq3pWHJNqgtTt+MFTtJ1biXqoYHHlY+iE
         ts9D+wFyF0OkVYivnhZowFc3yqi4P7RsQ/GFrSWtftxWySaNzYBMwTrnAxIUHnKHY3bD
         xLbBtZcxsl++P+vONyktodi+bXb9urCzdss1qYLOasH+XDoauEXNZJiMgAJI0nF2suSF
         frqJrhw4ZWlrr5nFH2xr33z6lDjLNdeg4ulvqgaVf05quglKFMdzLiLNHZwkOcKughq9
         NQlWYklK57JzlllNETS/psYh5NuDn0uvQwDjr5ky1ZpfsK55KG6ivE5az8vZFAQ+9uBQ
         fQgA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV3/KTLsy6tMIo0MFkr2wxwHiNPinNOTO//dar1api6Q/9LkOst
	cqizKpp8XPozh2vK4ztCg8dKunkhO4wc+VcrAlBUCphOG4/o/fh0oS8zi1HACx6jubfSgl0jk/V
	yj63ktOentXfrolmgQYCvWRZ/3dB9pvSTTGKjZjUTEh0pLx+s/TRX9vjhHJW3vzM=
X-Received: by 2002:a17:906:f91:: with SMTP id q17mr21983452ejj.297.1561968863047;
        Mon, 01 Jul 2019 01:14:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCS6J4WYgKLk2K4BA2qL3CwAoz3CFQieqA9JqqSC5+a9NsWOVciLjW9pjYcnqqwkaCw6sE
X-Received: by 2002:a17:906:f91:: with SMTP id q17mr21983411ejj.297.1561968862203;
        Mon, 01 Jul 2019 01:14:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561968862; cv=none;
        d=google.com; s=arc-20160816;
        b=OKorX+EDF2l4nYs7h1E5yhz+HSoIfiOP/CMiFkzv7MRMGtarWuy7JsrnpxL8QZ6uSP
         NlL/pYGzmIN6t7sxG5Rs6GsdTRHMsr6LtWqGOUr+SSdE+LtzMptX6h5KMT8/tlX6m3hH
         6Er/M/UTDgMvqAlxo/X3pfWza3/Py7G++7UeRv6IqbZ4KVnjYAJuamlmglyBGuAySJks
         QT3lvMRAAiWrwGKEQhV3NNzoIXjJfwAM2sFVU5hy8k9sdkU/Q6wLI5yIO7c0YmMtwOay
         MY3pUf1dRrW1kERJSQzqIOmB2DWfEu2tmCFFIWlfnOUdTIUD3XtbLzJCNtf8zsHsn1LO
         +ubQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sjeR9vWlObipKU2f44eOK/TerwrftGbdXSes2Tb6kMQ=;
        b=aV+xU0oYI7NuaOrG8Gj0lma6Umzqc9dhs38z+p28TejgAmZSvX7T4Tn8Q/57g0LMOI
         WHB1Dv2z76jdaYXygdJ5HWGjk0K/HfD2ptZil2efXykQRenwXFVapSplwQyR7vjWnd26
         HOxlfnhMo6rEdYeT4uKoCAPQj9h77RntQXbT/dKJxojYoQLW05QBdLgvZA3vlYocsrxs
         NFAKp4bkDNPRSfep6LwLSG5ltG6WkttPJcycgHv0NwOyrmjP93/JMNrUt7MavT3l+Err
         bXSuICzmTwwS52Tuy6YrMzfpYR9N0P0ALgFBVcsI+GHh87JaurS8GF61YHu+rUMrDVCF
         VIYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l20si8525376edc.2.2019.07.01.01.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 01:14:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 49BC4ACFB;
	Mon,  1 Jul 2019 08:14:21 +0000 (UTC)
Date: Mon, 1 Jul 2019 10:14:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Ingo Molnar <mingo@kernel.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v3 07/11] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
Message-ID: <20190701081420.GG6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-8-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-8-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 13:11:48, David Hildenbrand wrote:
> Only memory to be added to the buddy and to be onlined/offlined by
> user space using /sys/devices/system/memory/... needs (and should have!)
> memory block devices.
> 
> Factor out creation of memory block devices. Create all devices after
> arch_add_memory() succeeded. We can later drop the want_memblock parameter,
> because it is now effectively stale.
> 
> Only after memory block devices have been added, memory can be onlined
> by user space. This implies, that memory is not visible to user space at
> all before arch_add_memory() succeeded.

I like the memblock API to go away from the low level hotplug handling.
The current implementation is just too convoluted and I remember I was
fighting with subtle expectations wired deep in call chains when
touching that code in the past (some memblocks didn't get created etc.).
Maybe those have been addressed in the meantime.

> While at it
> - use WARN_ON_ONCE instead of BUG_ON in moved unregister_memory()

This would better be a separate patch with an explanation

> - introduce find_memory_block_by_id() to search via block id
> - Use find_memory_block_by_id() in init_memory_block() to catch
>   duplicates
> 
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Andrew Banman <andrew.banman@hpe.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Other than that looks good to me.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  drivers/base/memory.c  | 82 +++++++++++++++++++++++++++---------------
>  include/linux/memory.h |  2 +-
>  mm/memory_hotplug.c    | 15 ++++----
>  3 files changed, 63 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index ac17c95a5f28..5a0370f0c506 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -39,6 +39,11 @@ static inline int base_memory_block_id(int section_nr)
>  	return section_nr / sections_per_block;
>  }
>  
> +static inline int pfn_to_block_id(unsigned long pfn)
> +{
> +	return base_memory_block_id(pfn_to_section_nr(pfn));
> +}
> +
>  static int memory_subsys_online(struct device *dev);
>  static int memory_subsys_offline(struct device *dev);
>  
> @@ -582,10 +587,9 @@ int __weak arch_get_memory_phys_device(unsigned long start_pfn)
>   * A reference for the returned object is held and the reference for the
>   * hinted object is released.
>   */
> -struct memory_block *find_memory_block_hinted(struct mem_section *section,
> -					      struct memory_block *hint)
> +static struct memory_block *find_memory_block_by_id(int block_id,
> +						    struct memory_block *hint)
>  {
> -	int block_id = base_memory_block_id(__section_nr(section));
>  	struct device *hintdev = hint ? &hint->dev : NULL;
>  	struct device *dev;
>  
> @@ -597,6 +601,14 @@ struct memory_block *find_memory_block_hinted(struct mem_section *section,
>  	return to_memory_block(dev);
>  }
>  
> +struct memory_block *find_memory_block_hinted(struct mem_section *section,
> +					      struct memory_block *hint)
> +{
> +	int block_id = base_memory_block_id(__section_nr(section));
> +
> +	return find_memory_block_by_id(block_id, hint);
> +}
> +
>  /*
>   * For now, we have a linear search to go find the appropriate
>   * memory_block corresponding to a particular phys_index. If
> @@ -658,6 +670,11 @@ static int init_memory_block(struct memory_block **memory, int block_id,
>  	unsigned long start_pfn;
>  	int ret = 0;
>  
> +	mem = find_memory_block_by_id(block_id, NULL);
> +	if (mem) {
> +		put_device(&mem->dev);
> +		return -EEXIST;
> +	}
>  	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
>  	if (!mem)
>  		return -ENOMEM;
> @@ -699,44 +716,53 @@ static int add_memory_block(int base_section_nr)
>  	return 0;
>  }
>  
> +static void unregister_memory(struct memory_block *memory)
> +{
> +	if (WARN_ON_ONCE(memory->dev.bus != &memory_subsys))
> +		return;
> +
> +	/* drop the ref. we got via find_memory_block() */
> +	put_device(&memory->dev);
> +	device_unregister(&memory->dev);
> +}
> +
>  /*
> - * need an interface for the VM to add new memory regions,
> - * but without onlining it.
> + * Create memory block devices for the given memory area. Start and size
> + * have to be aligned to memory block granularity. Memory block devices
> + * will be initialized as offline.
>   */
> -int hotplug_memory_register(int nid, struct mem_section *section)
> +int create_memory_block_devices(unsigned long start, unsigned long size)
>  {
> -	int block_id = base_memory_block_id(__section_nr(section));
> -	int ret = 0;
> +	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
> +	int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
>  	struct memory_block *mem;
> +	unsigned long block_id;
> +	int ret = 0;
>  
> -	mutex_lock(&mem_sysfs_mutex);
> +	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
> +			 !IS_ALIGNED(size, memory_block_size_bytes())))
> +		return -EINVAL;
>  
> -	mem = find_memory_block(section);
> -	if (mem) {
> -		mem->section_count++;
> -		put_device(&mem->dev);
> -	} else {
> +	mutex_lock(&mem_sysfs_mutex);
> +	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
>  		ret = init_memory_block(&mem, block_id, MEM_OFFLINE);
>  		if (ret)
> -			goto out;
> -		mem->section_count++;
> +			break;
> +		mem->section_count = sections_per_block;
> +	}
> +	if (ret) {
> +		end_block_id = block_id;
> +		for (block_id = start_block_id; block_id != end_block_id;
> +		     block_id++) {
> +			mem = find_memory_block_by_id(block_id, NULL);
> +			mem->section_count = 0;
> +			unregister_memory(mem);
> +		}
>  	}
> -
> -out:
>  	mutex_unlock(&mem_sysfs_mutex);
>  	return ret;
>  }
>  
> -static void
> -unregister_memory(struct memory_block *memory)
> -{
> -	BUG_ON(memory->dev.bus != &memory_subsys);
> -
> -	/* drop the ref. we got via find_memory_block() */
> -	put_device(&memory->dev);
> -	device_unregister(&memory->dev);
> -}
> -
>  void unregister_memory_section(struct mem_section *section)
>  {
>  	struct memory_block *mem;
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index 474c7c60c8f2..db3e8567f900 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -111,7 +111,7 @@ extern int register_memory_notifier(struct notifier_block *nb);
>  extern void unregister_memory_notifier(struct notifier_block *nb);
>  extern int register_memory_isolate_notifier(struct notifier_block *nb);
>  extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
> -int hotplug_memory_register(int nid, struct mem_section *section);
> +int create_memory_block_devices(unsigned long start, unsigned long size);
>  extern void unregister_memory_section(struct mem_section *);
>  extern int memory_dev_init(void);
>  extern int memory_notify(unsigned long val, void *v);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 4b9d2974f86c..b1fde90bbf19 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -259,13 +259,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>  		return -EEXIST;
>  
>  	ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
> -	if (ret < 0)
> -		return ret;
> -
> -	if (!want_memblock)
> -		return 0;
> -
> -	return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn));
> +	return ret < 0 ? ret : 0;
>  }
>  
>  /*
> @@ -1107,6 +1101,13 @@ int __ref add_memory_resource(int nid, struct resource *res)
>  	if (ret < 0)
>  		goto error;
>  
> +	/* create memory block devices after memory was added */
> +	ret = create_memory_block_devices(start, size);
> +	if (ret) {
> +		arch_remove_memory(nid, start, size, NULL);
> +		goto error;
> +	}
> +
>  	if (new_node) {
>  		/* If sysfs file of new node can't be created, cpu on the node
>  		 * can't be hot-added. There is no rollback way now.
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs

