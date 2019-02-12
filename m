Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E256C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:33:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4146E2082F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:33:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4146E2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D41C28E0012; Tue, 12 Feb 2019 03:33:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCA3C8E0007; Tue, 12 Feb 2019 03:33:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B93D18E0012; Tue, 12 Feb 2019 03:33:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA298E0007
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:33:14 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w51so1759446edw.7
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 00:33:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=byhp5NnpbB254Ys28TFfX/kJzfNTxL1zIyQbThpjGyY=;
        b=RbKwmoRN7jvVuecFCWxMQ2ZzBZ1Sz92VREAM/9Q8VQ1iRhAoVMoeYI57JWYcn5+zV/
         /KO6vjJ/2GKOcdfUCCR2M9rKRWCVEiU7/QkhGws8FhU/YAP1c7wSFV9urgnV+08wGqo2
         gqUdeUxLEe0cPX+h+f1NLylCHnFXOO5QrQoe6pqF4C5TawS+FKW1/9YMVipW61rPRJ/v
         GKJqfoL+khmOjzwVCJUtD4RfJgU9VaulotQes5U4O1veK6V6+7oFdpy/pBrskLoVwplN
         VY88KmeAkpd5X3Kki91LciYARgkiBmURfT36AgThv0MA5QAJQSnYVQam+DxOBM1Z3EU3
         0yfw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZdXZuGMy7vLkWv+JtpUMnCt7IHta4hLDZg4UFrp4j83gsKoTLr
	ZkuYXu5ecsFAZMfNBO4AzkXv49xrM/v24aYXaPrK858HTCbBNiyHbfre2YcVMAriUpwUgLIivSg
	C1TF0vbkPVxmClKMmgIlYTE97PKy5YTUQH9CSMbd4HFGKmjrZa2VY4/YLaCtvkeM=
X-Received: by 2002:aa7:c2c6:: with SMTP id m6mr2047608edp.158.1549960393843;
        Tue, 12 Feb 2019 00:33:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib+hpyD6zaHbSvPHOM2mQi0k/v1a4RaEk9cWq94xFmHK/m5mLsFNXSl0/0FI/MP5gAztYzs
X-Received: by 2002:aa7:c2c6:: with SMTP id m6mr2047550edp.158.1549960392791;
        Tue, 12 Feb 2019 00:33:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549960392; cv=none;
        d=google.com; s=arc-20160816;
        b=krs0mBfZ71a3GIObzILH8PXAHGE5fLxaU3SGjXBqzpImLaHsi8hEuv+suUIWre0h5G
         ywSdSKujPfcdwiz9QDID/mGEVQaKVIoYDS/ziG2HFV34XB4JniE/w0eK+klZWM/3k33y
         /tyoB8cMPgDDV4Y65ap+XezYpa/0iLKzPTrfjWsEfYluIfXpwpFW/NYc7TZCX3Hg5Me5
         GPM5+5zfnQjr02YXSLAoUnAfbR1XhlFDPfLVwScn6lyzPV2LrcNgl6dGT1zLGbjfQeSd
         JSbKDZJboGZEMG5KDQrzdtEjbO2YXMPMiOmTxRab6etB4C4bHfM9gEKxsd5l92Bqh0fs
         mi7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=byhp5NnpbB254Ys28TFfX/kJzfNTxL1zIyQbThpjGyY=;
        b=TCXw/lHbgrgirh6UOp32m2KAp3EMPJ+HutcsC3gxd6eWia4q8xe6Lk27vUdzo7eodM
         h6Ic7u7v7hExjR6p1ds/GLhsXJoH+sgLiANuOhMTTckQDTUfs9Utipd6FggXEj9Fiomp
         buUmSV7koqwQcCFIXZuUg2sJCa94sybk4b/fyHDeZrC6S6+g5ZgfzJVLn3qeunSnWOzP
         uI9I9o55HFLTkklxvS7PqoBMA4qs0SjN0y5yj1J0h48k0UbjuQnk6vVTQDCrBZKsD6qe
         FHnoRnmJgwFTEA745z0eUbdNNJ7gxSChdrxyO2RtDjrHOxFwSM8KHvISxwj3Ima4ksmR
         GSRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w26si4796006edb.20.2019.02.12.00.33.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 00:33:12 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EB317AF1F;
	Tue, 12 Feb 2019 08:33:11 +0000 (UTC)
Date: Tue, 12 Feb 2019 09:33:10 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, rafael@kernel.org,
	akpm@linux-foundation.org, osalvador@suse.de
Subject: Re: [PATCH v2] mm/memory-hotplug: Add sysfs hot-remove trigger
Message-ID: <20190212083310.GM15609@dhcp22.suse.cz>
References: <49ef5e6c12f5ede189419d4dcced5dc04957c34d.1549906631.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49ef5e6c12f5ede189419d4dcced5dc04957c34d.1549906631.git.robin.murphy@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 11-02-19 17:50:46, Robin Murphy wrote:
> ARCH_MEMORY_PROBE is a useful thing for testing and debugging hotplug,
> but being able to exercise the (arguably trickier) hot-remove path would
> be even more useful. Extend the feature to allow removal of offline
> sections to be triggered manually to aid development.
> 
> Since process dictates the new sysfs entry be documented, let's also
> document the existing probe entry to match - better 13-and-a-half years
> late than never, as they say...

The probe sysfs is quite dubious already TBH. Apart from testing, is
anybody using it for something real? Do we need to keep an API for
something testing only? Why isn't a customer testing module enough for
such a purpose?

In other words, why do we have to add an API that has to be maintained
for ever for a testing only purpose?

Besides that, what is the reason to use __remove_memory rather than the
exported remove_memory which does an additional locking. Also, we do
trust root to do sane things but are we sure that the current BUG-land
mines in the hotplug code are ready enough to be exported for playing?

> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
> ---
> 
> v2: Use is_memblock_offlined() helper, write up documentation
> 
>  .../ABI/testing/sysfs-devices-memory          | 25 +++++++++++
>  drivers/base/memory.c                         | 42 ++++++++++++++++++-
>  2 files changed, 66 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
> index deef3b5723cf..02a4250964e0 100644
> --- a/Documentation/ABI/testing/sysfs-devices-memory
> +++ b/Documentation/ABI/testing/sysfs-devices-memory
> @@ -91,3 +91,28 @@ Description:
>  		memory section directory.  For example, the following symbolic
>  		link is created for memory section 9 on node0.
>  		/sys/devices/system/node/node0/memory9 -> ../../memory/memory9
> +
> +What:		/sys/devices/system/memory/probe
> +Date:		October 2005
> +Contact:	Linux Memory Management list <linux-mm@kvack.org>
> +Description:
> +		The file /sys/devices/system/memory/probe is write-only, and
> +		when written will simulate a physical hot-add of a memory
> +		section at the given address. For example, assuming a section
> +		of unused memory exists at physical address 0x80000000, it can
> +		be introduced to the kernel with the following command:
> +		# echo 0x80000000 > /sys/devices/system/memory/probe
> +Users:		Memory hotplug testing and development
> +
> +What:		/sys/devices/system/memory/memoryX/remove
> +Date:		February 2019
> +Contact:	Linux Memory Management list <linux-mm@kvack.org>
> +Description:
> +		The file /sys/devices/system/memory/memoryX/remove is
> +		write-only, and when written with a boolean 'true' value will
> +		simulate a physical hot-remove of that memory section. For
> +		example, assuming a 1GB section size, the section added by the
> +		above "probe" example could be removed again with the following
> +		command:
> +		# echo 1 > /sys/devices/system/memory/memory2/remove
> +Users:		Memory hotplug testing and development
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 048cbf7d5233..1ba9d1a6ba5e 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -521,7 +521,44 @@ static ssize_t probe_store(struct device *dev, struct device_attribute *attr,
>  }
>  
>  static DEVICE_ATTR_WO(probe);
> -#endif
> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +static ssize_t remove_store(struct device *dev, struct device_attribute *attr,
> +			    const char *buf, size_t count)
> +{
> +	struct memory_block *mem = to_memory_block(dev);
> +	unsigned long start_pfn = section_nr_to_pfn(mem->start_section_nr);
> +	bool remove;
> +	int ret;
> +
> +	ret = kstrtobool(buf, &remove);
> +	if (ret)
> +		return ret;
> +	if (!remove)
> +		return count;
> +
> +	if (!is_memblock_offlined(mem))
> +		return -EBUSY;
> +
> +	ret = lock_device_hotplug_sysfs();
> +	if (ret)
> +		return ret;
> +
> +	if (device_remove_file_self(dev, attr)) {
> +		__remove_memory(pfn_to_nid(start_pfn), PFN_PHYS(start_pfn),
> +				MIN_MEMORY_BLOCK_SIZE * sections_per_block);
> +		ret = count;
> +	} else {
> +		ret = -EBUSY;
> +	}
> +
> +	unlock_device_hotplug();
> +	return ret;
> +}
> +
> +static DEVICE_ATTR_WO(remove);
> +#endif /* CONFIG_MEMORY_HOTREMOVE */
> +#endif /* CONFIG_ARCH_MEMORY_PROBE */
>  
>  #ifdef CONFIG_MEMORY_FAILURE
>  /*
> @@ -615,6 +652,9 @@ static struct attribute *memory_memblk_attrs[] = {
>  	&dev_attr_removable.attr,
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  	&dev_attr_valid_zones.attr,
> +#ifdef CONFIG_ARCH_MEMORY_PROBE
> +	&dev_attr_remove.attr,
> +#endif
>  #endif
>  	NULL
>  };
> -- 
> 2.20.1.dirty

-- 
Michal Hocko
SUSE Labs

