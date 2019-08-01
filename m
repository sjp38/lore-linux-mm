Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEE9DC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 734C7206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:07:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 734C7206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AC1E8E0021; Thu,  1 Aug 2019 11:07:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 134ED8E0001; Thu,  1 Aug 2019 11:07:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC9A78E0021; Thu,  1 Aug 2019 11:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6AD88E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 11:07:31 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id v4so61432049qkj.10
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 08:07:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=gPG0sW5lY7+Ikzw+Xs+Oy8EhM+sYnH0wOC94TLnhEjE=;
        b=EmZaaoHwGEH2zuhuBvOWBzgg+ySbXCHq6XE9zib+bYL5SPP+MICVA8VLZ6xt/3hQ8k
         8T9fBlyLVrC26K0HBG+fXezkH8UQlJ/pAWWkGhJPc/spv7AFdGziLMiiNFZ7PBqNbHTC
         JeZzIhkmUmqEy0rIbK69QtmU4PJffmmzW4TmV2viM/E6mTOBr1hgfi55Oh4dLi9dHlJJ
         aksaPwM4zPw7GanvXT5bFo5iQtbf1Ey07EAYvS7NSnh2GIhiMluDSwsL3K9nqssGHQk6
         UVLo/3VIoym3r2n+BW5vKZGYFeGx7SsyTnLSRZbjkNAWWvWLwejFm+yM4hccYFB+kcoU
         SqEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWv4o3f0Uht/NPTeCaEG1pE3ys9ONnI8imUxZzVLUcCan/nG/Nc
	5CZdMzfpr7yhq9WywmZ+AaJexvHkZwmhmYymFTA3o3Xp758k0mkZGYxIn2KtaZdkomSkNhkkzYP
	mdJj1f66zkiuqzplFSFhBy5YLrPe5BIVfUSifANpmxFhbxxURM5wP6q/vWD3nSkIHrg==
X-Received: by 2002:a37:6813:: with SMTP id d19mr47754883qkc.454.1564672051579;
        Thu, 01 Aug 2019 08:07:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWMpW0tH95pik1sdOH3VO5pYHyxnEYmcBdqNCxeyrnU3Nsp0t8CwxAaC7P7SdnDoQ+y4Wv
X-Received: by 2002:a37:6813:: with SMTP id d19mr47754825qkc.454.1564672050960;
        Thu, 01 Aug 2019 08:07:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564672050; cv=none;
        d=google.com; s=arc-20160816;
        b=n0OkVprnrA8uYwGCk93fGt/peGRQ5iJIThftGBvMFoglQ9WLcYi6ZncTikhs20z9i2
         QH5ldCXslbu2vebAKyqWYelpvSEzp587G0wydfifbvMxYE+t4IEGb7YCXj1BkiUwY3MM
         uLz3ROVuwa7U1vBRiWtG6Q4Z9lludzhsmxLS/j39is9rA7ze8fOEiJXsziWLIThr0tI6
         lkmBBRWa2c3kx/O1OVAD6Y0nZSbNPH0b8TJL05ufE9hcxDJt9lcFPBsaOmUCTjrPcAUQ
         GF2k7lyRf8aO8B+gaAx14Z475IijsgxE4BCwnzNPunfIgJZiFLAGYdzmatAhEjeB0v46
         ABNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=gPG0sW5lY7+Ikzw+Xs+Oy8EhM+sYnH0wOC94TLnhEjE=;
        b=mv+wbEz3Q6mmsgltT/JR4rZNoqKJ3loQmkF/9XBMvw3WgmD2TaoFzl5aHuwO6l4He2
         0Dpqcx0gRb/imw57j3NTkJIdg4T5X+G4wIJCmaeXYLC1XRjN8lyR2IrK3CPb2t5wF15b
         5cdbOXEuYvMlvhr/U5yLS4YGSftkg7MT+lIA+Y2F6OrWwhyRYCaHAmKpn8DrdGLJ2hYM
         11iZp423+E73OXWmETmrYXxnqsmd8NO0hHsmYT1HNpz4IwURsKE+FhKj3GXe/lIvQniU
         iLVuXyabYNz2QD728ysH1wr2PYsdmO7sJbSUwabGSxAwqud+rQH2HPcxQL5d5PTDjrJZ
         BFCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f10si39443254qkm.276.2019.08.01.08.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 08:07:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0EFD7793E5;
	Thu,  1 Aug 2019 15:07:30 +0000 (UTC)
Received: from [10.36.116.115] (ovpn-116-115.ams2.redhat.com [10.36.116.115])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EA43260852;
	Thu,  1 Aug 2019 15:07:27 +0000 (UTC)
Subject: Re: [PATCH v3 5/5] mm,memory_hotplug: Allow userspace to
 enable/disable vmemmap
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, pasha.tatashin@soleen.com, mhocko@suse.com,
 anshuman.khandual@arm.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190725160207.19579-1-osalvador@suse.de>
 <20190725160207.19579-6-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <3bb12bac-77a5-c53a-247b-6241c8381d30@redhat.com>
Date: Thu, 1 Aug 2019 17:07:27 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190725160207.19579-6-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 01 Aug 2019 15:07:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.07.19 18:02, Oscar Salvador wrote:
> It seems that we have some users out there that want to expose all
> hotpluggable memory to userspace, so this implements a toggling mechanism
> for those users who want to disable it.
> 
> By default, vmemmap pages mechanism is enabled.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  drivers/base/memory.c          | 33 +++++++++++++++++++++++++++++++++
>  include/linux/memory_hotplug.h |  3 +++
>  mm/memory_hotplug.c            |  7 +++++++
>  3 files changed, 43 insertions(+)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index d30d0f6c8ad0..5ec6b80de9dd 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -578,6 +578,35 @@ static DEVICE_ATTR_WO(soft_offline_page);
>  static DEVICE_ATTR_WO(hard_offline_page);
>  #endif
>  

-ENODOCUMENTATION :)

> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> +static ssize_t vmemmap_hotplug_show(struct device *dev,
> +				    struct device_attribute *attr, char *buf)
> +{
> +	if (vmemmap_enabled)
> +		return sprintf(buf, "enabled\n");
> +	else
> +		return sprintf(buf, "disabled\n");
> +}
> +
> +static ssize_t vmemmap_hotplug_store(struct device *dev,
> +			   struct device_attribute *attr,
> +			   const char *buf, size_t count)
> +{
> +	if (!capable(CAP_SYS_ADMIN))
> +		return -EPERM;
> +
> +	if (sysfs_streq(buf, "enable"))
> +		vmemmap_enabled = true;
> +	else if (sysfs_streq(buf, "disable"))
> +		vmemmap_enabled = false;
> +	else
> +		return -EINVAL;
> +
> +	return count;
> +}
> +static DEVICE_ATTR_RW(vmemmap_hotplug);
> +#endif
> +
>  /*
>   * Note that phys_device is optional.  It is here to allow for
>   * differentiation between which *physical* devices each
> @@ -794,6 +823,10 @@ static struct attribute *memory_root_attrs[] = {
>  	&dev_attr_hard_offline_page.attr,
>  #endif
>  
> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> +	&dev_attr_vmemmap_hotplug.attr,

Don't like the name of that property, sorry.

> +#endif
> +
>  	&dev_attr_block_size_bytes.attr,
>  	&dev_attr_auto_online_blocks.attr,
>  	NULL
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index e1e8abf22a80..03d227d13301 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -134,6 +134,9 @@ extern int arch_add_memory(int nid, u64 start, u64 size,
>  			struct mhp_restrictions *restrictions);
>  extern u64 max_mem_size;
>  
> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> +extern bool vmemmap_enabled;
> +#endif
>  extern bool memhp_auto_online;
>  /* If movable_node boot option specified */
>  extern bool movable_node_enabled;
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 09d41339cd11..5ffe5375b87c 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -68,6 +68,10 @@ void put_online_mems(void)
>  
>  bool movable_node_enabled = false;
>  
> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> +bool vmemmap_enabled __read_mostly = true;
> +#endif
> +
>  #ifndef CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
>  bool memhp_auto_online;
>  #else
> @@ -1108,6 +1112,9 @@ static unsigned long mhp_check_flags(unsigned long flags)
>  	if (!flags)
>  		return 0;
>  
> +	if (!vmemmap_enabled)
> +		return 0;
> +
>  	if (flags != MHP_MEMMAP_ON_MEMORY) {
>  		WARN(1, "Wrong flags value (%lx). Ignoring flags.\n", flags);
>  		return 0;
> 

Hmmm, I wonder if that should that rather be a per-memory device driver
thingy? E.g., a toggle for ACPI which will then not pass in
MHP_MEMMAP_ON_MEMORY.

-- 

Thanks,

David / dhildenb

