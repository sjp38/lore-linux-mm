Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EF90C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:23:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EC292081C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:23:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EC292081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2AC66B026E; Tue, 28 May 2019 07:23:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDAB86B026F; Tue, 28 May 2019 07:23:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7BF76B0273; Tue, 28 May 2019 07:23:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88E2F6B026E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 07:23:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y22so32613975eds.14
        for <linux-mm@kvack.org>; Tue, 28 May 2019 04:23:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XlM7Fj50esJ0D4Qa/BhqO0c9th4LIBO7JWtPoP3QKy0=;
        b=KTri+dDKwKe5dWKQDL+75UIuXGBEDdBcjhjKyFufQ4qhyyZ9+1g5TGjCSq/lRjIdui
         z89Tq3YdYl8GEBFH8AfNGXPgnVf6Q2HVAjF1zuYwidtSUYH9HCqnY9/riTXzCrbPQqZA
         7xdMsaHI/kuACOS5ZdleC9YFB30M95v2DL/f5rcFgmVo1n9KynF6DovGgrUXTMrZcbG4
         BSJR3je7Qt/6tn6DWXra9UYIzXvfhDjrcAHccHSDo8hsKWED+tyFNUxmPdTbh6ASYxGu
         /EFN9fSXLwngVuPgy6D2Jw6PZrzRSwoSX5EsJW9U1zNczgdpO31hZ2Eep1NpcagP9tz1
         eikA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUK6rI1r11eWmdNP6MZVT/IRACHpnM4chqSfEBzNNbJB5/Wu90i
	5gfy/FnV+sHdeGL78AR1qPM9jvKu5HgISc7MLtVH+8OTW5nccBdiWhYz1QvnXwNwvTmf3TySQKI
	VciVrLkV+BcsVW05YTuXcoEcumcRv39Jlw9NNjbjYsMZ/Cp7ueLKvqNmlrh75eP4=
X-Received: by 2002:a17:906:2594:: with SMTP id m20mr41753035ejb.217.1559042589098;
        Tue, 28 May 2019 04:23:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWIiJ3BSSXlABKnN70QrpwaPR0l+FyLzf/LlzC+Xan4J9rEc49rmN/EY28NxC2+PHX5LQx
X-Received: by 2002:a17:906:2594:: with SMTP id m20mr41752971ejb.217.1559042588126;
        Tue, 28 May 2019 04:23:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559042588; cv=none;
        d=google.com; s=arc-20160816;
        b=pRxHCu8W1QKB9EhBXpNTqP9ejEeEeE2uuOoY+CF+3w+dKmxYIUYYUP0ec3e/F/H2P0
         3mqudTovQDthdV0VVyS2Ys/YUjq1B3p7A6V4bva6DL4UXsmZ7VNG0YfNP7Jn8xnICgvJ
         0YRnmFTzkYYydn9s32q+8L51t6qMtA89GyWEfN9st3Qfasw2F5aI+XjyFJAUque4maVP
         Sr1LTHXfQwc5xDanDwAliwFWfzpLo+FMEjgXuwfl4j2VwXeVux4nXU56Sw0CzT98f4+z
         pmtDW39YgdZyaTq0yBqt93+APG3bp/vt9CkNkSoY+rjMjoldiSRQprLB0/19i3fIu7Kv
         o5NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XlM7Fj50esJ0D4Qa/BhqO0c9th4LIBO7JWtPoP3QKy0=;
        b=nKcnCkxKqcewdf57FWj4SmwNgderBH6wPn7OGmYd81hDrDy8gaH7JaM1U8vk8dGbno
         RkKUDHQPmRmwerkIccYr/ZUdd9ZnjavFxJxVcFX+6vEoI3laG4ELSOxO4jju6pvDySVK
         E3DocpxQr3YSQVUTzlUUKe0cUCUrSaxwY0KmSdJU2KLKBfK+9S+PjXT0qjToYmwG5EFx
         vJczZZI6O+SPUg7tD6JI0QTE38KuHaBZcQoRThuDvVwsM0icPp+QcM11OTHtrOFGvuzP
         v/q1koPAhXw+ieoUDMbVJgTlJOKpent7mfw1UJki1NWt4jk+ix/eSqltZY3VsvYj2nZi
         73HA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m9si898210edm.178.2019.05.28.04.23.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 04:23:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1EFA0AF42;
	Tue, 28 May 2019 11:23:07 +0000 (UTC)
Date: Tue, 28 May 2019 13:23:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: jmorris@namei.org, sashal@kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-nvdimm@lists.01.org,
	akpm@linux-foundation.org, dave.hansen@linux.intel.com,
	dan.j.williams@intel.com, keith.busch@intel.com,
	vishal.l.verma@intel.com, dave.jiang@intel.com, zwisler@kernel.org,
	thomas.lendacky@amd.com, ying.huang@intel.com,
	fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com, tiwai@suse.de, jglisse@redhat.com,
	david@redhat.com
Subject: Re: [v6 2/3] mm/hotplug: make remove_memory() interface useable
Message-ID: <20190528112305.GX1658@dhcp22.suse.cz>
References: <20190517215438.6487-1-pasha.tatashin@soleen.com>
 <20190517215438.6487-3-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190517215438.6487-3-pasha.tatashin@soleen.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 17-05-19 17:54:37, Pavel Tatashin wrote:
> As of right now remove_memory() interface is inherently broken. It tries
> to remove memory but panics if some memory is not offline. The problem
> is that it is impossible to ensure that all memory blocks are offline as
> this function also takes lock_device_hotplug that is required to
> change memory state via sysfs.
> 
> So, between calling this function and offlining all memory blocks there
> is always a window when lock_device_hotplug is released, and therefore,
> there is always a chance for a panic during this window.
> 
> Make this interface to return an error if memory removal fails. This way
> it is safe to call this function without panicking machine, and also
> makes it symmetric to add_memory() which already returns an error.

I was about to object because of the acpi hotremove but looking closer
acpi_memory_remove_memory and few others already do use __remove_memory
instead of remove_memory so this is good to go. I really hate how we had
to BUG in remove_memory as well so this is definitely a good change.

> Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> Reviewed-by: David Hildenbrand <david@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memory_hotplug.h |  8 +++--
>  mm/memory_hotplug.c            | 64 +++++++++++++++++++++++-----------
>  2 files changed, 49 insertions(+), 23 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index ae892eef8b82..988fde33cd7f 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -324,7 +324,7 @@ static inline void pgdat_resize_init(struct pglist_data *pgdat) {}
>  extern bool is_mem_section_removable(unsigned long pfn, unsigned long nr_pages);
>  extern void try_offline_node(int nid);
>  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
> -extern void remove_memory(int nid, u64 start, u64 size);
> +extern int remove_memory(int nid, u64 start, u64 size);
>  extern void __remove_memory(int nid, u64 start, u64 size);
>  
>  #else
> @@ -341,7 +341,11 @@ static inline int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
>  	return -EINVAL;
>  }
>  
> -static inline void remove_memory(int nid, u64 start, u64 size) {}
> +static inline int remove_memory(int nid, u64 start, u64 size)
> +{
> +	return -EBUSY;
> +}
> +
>  static inline void __remove_memory(int nid, u64 start, u64 size) {}
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 328878b6799d..ace2cc614da4 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1735,9 +1735,10 @@ static int check_memblock_offlined_cb(struct memory_block *mem, void *arg)
>  		endpa = PFN_PHYS(section_nr_to_pfn(mem->end_section_nr + 1))-1;
>  		pr_warn("removing memory fails, because memory [%pa-%pa] is onlined\n",
>  			&beginpa, &endpa);
> -	}
>  
> -	return ret;
> +		return -EBUSY;
> +	}
> +	return 0;
>  }
>  
>  static int check_cpu_on_node(pg_data_t *pgdat)
> @@ -1820,19 +1821,9 @@ static void __release_memory_resource(resource_size_t start,
>  	}
>  }
>  
> -/**
> - * remove_memory
> - * @nid: the node ID
> - * @start: physical address of the region to remove
> - * @size: size of the region to remove
> - *
> - * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
> - * and online/offline operations before this call, as required by
> - * try_offline_node().
> - */
> -void __ref __remove_memory(int nid, u64 start, u64 size)
> +static int __ref try_remove_memory(int nid, u64 start, u64 size)
>  {
> -	int ret;
> +	int rc = 0;
>  
>  	BUG_ON(check_hotplug_memory_range(start, size));
>  
> @@ -1840,13 +1831,13 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>  
>  	/*
>  	 * All memory blocks must be offlined before removing memory.  Check
> -	 * whether all memory blocks in question are offline and trigger a BUG()
> +	 * whether all memory blocks in question are offline and return error
>  	 * if this is not the case.
>  	 */
> -	ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
> -				check_memblock_offlined_cb);
> -	if (ret)
> -		BUG();
> +	rc = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
> +			       check_memblock_offlined_cb);
> +	if (rc)
> +		goto done;
>  
>  	/* remove memmap entry */
>  	firmware_map_remove(start, start + size, "System RAM");
> @@ -1858,14 +1849,45 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>  
>  	try_offline_node(nid);
>  
> +done:
>  	mem_hotplug_done();
> +	return rc;
>  }
>  
> -void remove_memory(int nid, u64 start, u64 size)
> +/**
> + * remove_memory
> + * @nid: the node ID
> + * @start: physical address of the region to remove
> + * @size: size of the region to remove
> + *
> + * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
> + * and online/offline operations before this call, as required by
> + * try_offline_node().
> + */
> +void __remove_memory(int nid, u64 start, u64 size)
> +{
> +
> +	/*
> +	 * trigger BUG() is some memory is not offlined prior to calling this
> +	 * function
> +	 */
> +	if (try_remove_memory(nid, start, size))
> +		BUG();
> +}
> +
> +/*
> + * Remove memory if every memory block is offline, otherwise return -EBUSY is
> + * some memory is not offline
> + */
> +int remove_memory(int nid, u64 start, u64 size)
>  {
> +	int rc;
> +
>  	lock_device_hotplug();
> -	__remove_memory(nid, start, size);
> +	rc  = try_remove_memory(nid, start, size);
>  	unlock_device_hotplug();
> +
> +	return rc;
>  }
>  EXPORT_SYMBOL_GPL(remove_memory);
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
> -- 
> 2.21.0
> 

-- 
Michal Hocko
SUSE Labs

