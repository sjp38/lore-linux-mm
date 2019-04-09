Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDD99C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 07:33:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96D2220880
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 07:33:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96D2220880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 065306B026A; Tue,  9 Apr 2019 03:33:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0147F6B026B; Tue,  9 Apr 2019 03:33:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1FB46B026C; Tue,  9 Apr 2019 03:33:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C16FF6B026A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 03:33:23 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id i124so13860472qkf.14
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 00:33:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Cc7Vg/6MC08QKkSJpzQaJSPziiPH9y1C8pe7V4WC3Dw=;
        b=nT3n1GAsru2LjQwz1N6dAP0mA560EcQ6BXQxGv48xyTnh57MXk64PiWptMhJYkScSN
         v3DL/DjuZknEepmbUpqHcWUGiyZ0pfW7B3Rxvm1HZDpIh19YBnvX5RGSrk3JKBadbdAV
         ssR59nWAXl2kDmntsTkoI5SmI1k0f2ToNbtGtTFjDpNjZm75Ev7IUY7uuxujce2v1eqH
         fiUpjGPIw9LyqoJUo/UDW35uEGzTfyTtwCvub16jsSNtiBQ6e8nn6pxIEvjo+M2ZGk8M
         yAaOQbiDuudCsVkcYc69c/tDEi+sRj5WIb0aZ0hqAMKT7CxeL0g+QDePUAmW2FRPQ5bI
         wMpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXeUw3u/ZRXn+k4snnVeiBGQrK7d7rSU/DNELEUiGnZmPUIGzJv
	alHvwWoHcx90313K1n0ShtVZDw11OIvHNcAkCWj3z3O2PecbKpKEgiofIOSCOBjB0qy84f3kpEX
	HMOlvc7B83izBbnE+mWMa8e+o0Lp5627znd6vRifV9oUAcJonuODPVYVV+vX3D+JnTg==
X-Received: by 2002:a0c:9e62:: with SMTP id z34mr27878110qve.81.1554795203445;
        Tue, 09 Apr 2019 00:33:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8BjHtzS4RJ1Vbh0kxzjKBK3CU55xaXgl2ZCTlAUCoah59i74Ep4bg9Sw0ivzrwVaouUVC
X-Received: by 2002:a0c:9e62:: with SMTP id z34mr27878050qve.81.1554795202613;
        Tue, 09 Apr 2019 00:33:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554795202; cv=none;
        d=google.com; s=arc-20160816;
        b=KJ6q8XBZ28s0EaeMBeN7fUahI7x++mArTmaHmCySEWdiyV00guLCYE1HD4h+bGMpP0
         4BnnRNAMjVpfTGf/2HoZZ3eBZBNCuA4uqQLyjto4hJzY9lgH0VnUs4ywJ7M1xAI+UASH
         VY9JItVmrmpJxpLnmqnj/O5jqHskY23gWZGcbiuRWuGwsjNWgsxnIo3DaLuk1Ym4OGjG
         hQVs3IGmmT36iGK4Xi+KUUnzx/BLotEnJPNS7bIL3hupzwmHjlhZEvH2jGFujBx2Y3gA
         YRxmd99uDHIkDroyQPjydQFIRtX2fKX+xsPKP9rG6PhLgsghRdqk6tLCjjW0gVhkvrmw
         3iyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Cc7Vg/6MC08QKkSJpzQaJSPziiPH9y1C8pe7V4WC3Dw=;
        b=pfevtbTjBKUfx56FJZcnF90GoIHQsKMUCohj8MF5QruwwYeWZ0nA2oTfuOZQqtCrt9
         66uRUxiCy4DHGeSrVZFnbs5MVc47SEfEMRGDtqrtY4ygrf69QEVpFS0FLjevOMMRMcHP
         vCstujamw/NILG5hsVEavO05pa31w8hVk5Lkej0F9yTTGq6A2Zav0l02bKh/kNuz7XRW
         lTLXvjt/QticJSwb84gpmkwYNxtdPSF36dH06Bn6ralX5daGluavbbo4nQi/84aHrYYU
         2czA+duqLUODU1UROZ+mDan94QS8EnjAU4nb9aJjPRmeMar/H+TKm+58SAqKgj2/Oqt6
         l8Lw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q3si3662933qtq.31.2019.04.09.00.33.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 00:33:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7F09C2D80F;
	Tue,  9 Apr 2019 07:33:21 +0000 (UTC)
Received: from [10.36.117.49] (ovpn-117-49.ams2.redhat.com [10.36.117.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1A4EF108BEF9;
	Tue,  9 Apr 2019 07:33:17 +0000 (UTC)
Subject: Re: [PATCH RFC 2/3] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J . Wysocki" <rafael@kernel.org>, Ingo Molnar <mingo@kernel.org>,
 Andrew Banman <andrew.banman@hpe.com>, mike.travis@hpe.com,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>,
 Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
 Pavel Tatashin <pavel.tatashin@microsoft.com>,
 Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
 Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>,
 linux-mm@kvack.org, dan.j.williams@intel.com
References: <20190408101226.20976-1-david@redhat.com>
 <20190408101226.20976-3-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <c8402806-4674-d3b2-1bdf-3fbc0971e075@redhat.com>
Date: Tue, 9 Apr 2019 09:33:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190408101226.20976-3-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 09 Apr 2019 07:33:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.04.19 12:12, David Hildenbrand wrote:
> Only memory added via add_memory() and friends will need memory
> block devices - only memory to be used via the buddy and to be onlined/
> offlined by user space in memory block granularity.
> 
> Move creation of memory block devices out of arch_add_memory(). Create all
> devices after arch_add_memory() succeeded. We can later drop the
> want_memblock parameter, because it is now effectively stale.
> 
> Only after memory block devices have been added, memory can be onlined
> by user space. This implies, that memory is not visible to user space at
> all before arch_add_memory() succeeded.
> 
> Issue 1: __add_pages() does not remove pages in case something went
> wrong. If this is the case, we would now no longer create memory block
> devices for such "partially added memory". So the memory would not be
> usable/onlinable. Bad? Or related to issue 2 (e.g. fix __add_pages()
> to remove any parts that were added in case of an error). Functions that
> fail and don't clean up are not that nice.
> 
> Issue 2: In case we can't add memory block devices, and we don't have
> HOTREMOVE, we can't remove the pages via arch_remove_pages. Maybe we should
> try to get rid of CONFIG_MEMORY_HOTREMOVE, so we can handle all failures
> in a nice way? Or at least allow arch_remove_pages() and friends, so a
> subset of CONFIG_MEMORY_HOTREMOVE.
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/memory.c  | 67 +++++++++++++++++++++++++-----------------
>  include/linux/memory.h |  2 +-
>  mm/memory_hotplug.c    | 17 +++++++----
>  3 files changed, 53 insertions(+), 33 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index d9ebb89816f7..847b33061e2e 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -701,44 +701,57 @@ static int add_memory_block(int base_section_nr)
>  	return 0;
>  }
>  
> -/*
> - * need an interface for the VM to add new memory regions,
> - * but without onlining it.
> - */
> -int hotplug_memory_register(int nid, struct mem_section *section)
> +static void unregister_memory(struct memory_block *memory)
>  {
> -	int ret = 0;
> +	BUG_ON(memory->dev.bus != &memory_subsys);
> +
> +	/* drop the ref. we got via find_memory_block() */
> +	put_device(&memory->dev);
> +	device_unregister(&memory->dev);
> +}
> +
> +int hotplug_memory_register(unsigned long start, unsigned long size)
> +{
> +	unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
> +	unsigned long start_pfn = PFN_DOWN(start);
> +	unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
> +	unsigned long pfn;
>  	struct memory_block *mem;
> +	int ret = 0;
>  
> -	mutex_lock(&mem_sysfs_mutex);
> +	BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
> +	BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));
>  
> -	mem = find_memory_block(section);
> -	if (mem) {
> -		mem->section_count++;
> -		put_device(&mem->dev);
> -	} else {
> -		ret = init_memory_block(&mem, section, MEM_OFFLINE);
> +	mutex_lock(&mem_sysfs_mutex);
> +	for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
> +		mem = find_memory_block(__pfn_to_section(pfn));
> +		if (mem) {
> +			WARN_ON_ONCE(false);
> +			put_device(&mem->dev);
> +			continue;
> +		}
> +		ret = init_memory_block(&mem, __pfn_to_section(pfn),
> +					MEM_OFFLINE);
>  		if (ret)
> -			goto out;
> -		mem->section_count++;
> +			break;
> +		mem->section_count = memory_block_size_bytes() /
> +				     MIN_MEMORY_BLOCK_SIZE;
> +	}
> +	if (ret) {
> +		end_pfn = pfn;
> +		for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
> +			mem = find_memory_block(__pfn_to_section(pfn));
> +			if (!mem)
> +				continue;
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
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -static void
> -unregister_memory(struct memory_block *memory)
> -{
> -	BUG_ON(memory->dev.bus != &memory_subsys);
> -
> -	/* drop the ref. we got in remove_memory_section() */
> -	put_device(&memory->dev);
> -	device_unregister(&memory->dev);
> -}
> -
>  static int remove_memory_section(struct mem_section *section)
>  {
>  	struct memory_block *mem;
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index a6ddefc60517..e275dc775834 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -111,7 +111,7 @@ extern int register_memory_notifier(struct notifier_block *nb);
>  extern void unregister_memory_notifier(struct notifier_block *nb);
>  extern int register_memory_isolate_notifier(struct notifier_block *nb);
>  extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
> -int hotplug_memory_register(int nid, struct mem_section *section);
> +int hotplug_memory_register(unsigned long start, unsigned long size);
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  extern int unregister_memory_section(struct mem_section *);
>  #endif
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 680dcc67f9d5..13ee0a26e034 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -260,11 +260,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>  	ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
>  	if (ret < 0)
>  		return ret;
> -
> -	if (!want_memblock)
> -		return 0;
> -
> -	return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn));
> +	return 0;
>  }
>  
>  /*
> @@ -1125,6 +1121,17 @@ int __ref add_memory_resource(int nid, struct resource *res)
>  	if (ret < 0)
>  		goto error;
>  
> +	/* create memory block devices after memory was added */
> +	ret = hotplug_memory_register(start, size);
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +	if (ret) {
> +		arch_remove_memory(nid, start, size, NULL);
> +		goto error;
> +	}
> +#else
> +	WARN_ON(ret);
> +#endif
> +
>  	if (new_node) {
>  		/* If sysfs file of new node can't be created, cpu on the node
>  		 * can't be hot-added. There is no rollback way now.
> 

FWIW, I think we should first try to make sure arch_remove_memory()
cannot fail / will not ignore errors if possible. There are still some
things in there that need more re-factoring first.

-- 

Thanks,

David / dhildenb

