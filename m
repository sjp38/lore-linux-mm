Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDA22C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:19:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE8E122CBD
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:19:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE8E122CBD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FC5C8E0002; Fri, 26 Jul 2019 04:19:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AD0A6B000D; Fri, 26 Jul 2019 04:19:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 375048E0002; Fri, 26 Jul 2019 04:19:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DACD66B000C
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:19:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c31so33674715ede.5
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:19:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2HfynCQCy6QndV0PuUJdZIFp/hm1FU8ipE+CwYytNiI=;
        b=kqEEkuu8qt9xel19k4rkhE/CNzzkQkdjJiTkgaY34YN6pSxwsH+MvBvoV7EVJAkgpG
         Cc40nBfCXLnYrJlGfu9tKijTvkiMEai0vXk4ywRtOyAkd2roCQvLgj/3sU0/PBKsHP8Z
         uG/IzXBhfCMYr+QKAkfXJeFmPe4ymayVbtfuYNQD/Lr62Ccl64AsMw+wKZ7xu47YKfzV
         tb85nbt8lBj85a5+kIfVPB9XGsJ5qQyd1js2mkwdyiEDslEXphxCceqVQ16wCYTMVzr7
         jvZ636m3RGdKBu8Vv5T7rudl/AMa8AR1I8LcEbQ248kWLYKPjA6m0uRwsEdCl6Nv5P+4
         QgiA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUtvoi0BfEQcUhc5neZzdpMQtty4OCL+rGfOHlKKfN0CjzRYrVL
	caCu7mcCa3S7+6i7cqDhSdYWcNU5mkhZDxZQhXVG27NLZmeNzQFRjuy5vONd+BeymsXxgkHp/5z
	x2PvjKhK6B7keLGoYIbTjXpSj1vRxQ3UcZnskyYl5GIg0KOWUzTKFd0ut6d5uznM=
X-Received: by 2002:a50:8be8:: with SMTP id n37mr81135030edn.216.1564129161387;
        Fri, 26 Jul 2019 01:19:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0c8IbezdkHHYfRERPkosm6yMHKs1L+WpYx8eiVmFWsAK6XyhwI632rhOzqA3z5I3Yt0fv
X-Received: by 2002:a50:8be8:: with SMTP id n37mr81134974edn.216.1564129160469;
        Fri, 26 Jul 2019 01:19:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564129160; cv=none;
        d=google.com; s=arc-20160816;
        b=BSciOwdYTZ6QVnpacT9vlAf5BqZ2w/Db9kw/7ueVo5CFSuI8dcgIxkP6qpEAZnfavM
         sEtfcgdi9L9+qFxOnH/3wr3Cm4ekd+3/p2+6UAtJpCjYaH7KnGhtvaxRg2pJFaAMRhkh
         frTj2FrhKJqS8k4aXmA4IJh/f7WBO3nhsYI2Y9IfWTZRDvvjGrtLn186Dv/mC3GFDMB4
         SDRTaCwimQdkujFghQmMR+nie36DijgGPXhJsDLWcqGAKuB/MX7D94VqjhA7FAduB4ZC
         6GdVjmHbVHBZIEzNshPJ0omVLqvjJXCSZyZByWWzPlflK48PtJmBujxJhodhAmUCM09y
         z+FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2HfynCQCy6QndV0PuUJdZIFp/hm1FU8ipE+CwYytNiI=;
        b=gnU8twf3L0IAn8xww7757YQIBs1v38HR7isDMSMGkIVDuYXCu9jOCC/Xu04pQ6GiaY
         WsUmXbGbJIEZAbn2qqR76NlswmHUYvL5iSybGpp5QdDfo7X/ZtdcGnA3+KjW9AeSfB/L
         nDWwbOLm59UFhDgqrIEyk2bMOiy3mgTzwtHWdhE+j4x4LTR6K/SoGTWk5iaSOU1UtuJB
         igyBKdL2SEf95IyIVNJu8Lf4mAJr5p2XmCn+EDlD4d8H3NIGZoFYEUvFUm/KoHXxdvoO
         IKlyf9PAGvmvJP3KnTHLUT5GUZGc8VjjlsJnHLTsZ/orww5WlSjIKzTGeWQQML9RG10U
         aNGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o13si10437067ejb.163.2019.07.26.01.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 01:19:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9641BB62C;
	Fri, 26 Jul 2019 08:19:19 +0000 (UTC)
Date: Fri, 26 Jul 2019 10:19:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH RFC] mm/memory_hotplug: Don't take the cpu_hotplug_lock
Message-ID: <20190726081919.GI6142@dhcp22.suse.cz>
References: <20190725092206.23712-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190725092206.23712-1-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-07-19 11:22:06, David Hildenbrand wrote:
> Commit 9852a7212324 ("mm: drop hotplug lock from lru_add_drain_all()")
> states that lru_add_drain_all() "Doesn't need any cpu hotplug locking
> because we do rely on per-cpu kworkers being shut down before our
> page_alloc_cpu_dead callback is executed on the offlined cpu."
> 
> And also "Calling this function with cpu hotplug locks held can actually
> lead to obscure indirect dependencies via WQ context.".
> 
> Since commit 3f906ba23689 ("mm/memory-hotplug: switch locking to a percpu
> rwsem") we do a cpus_read_lock() in mem_hotplug_begin().
> 
> I don't see how that lock is still helpful, we already hold the
> device_hotplug_lock to protect try_offline_node(), which is AFAIK one
> problematic part that can race with CPU hotplug. If it is still
> necessary, we should document why.

I have forgot all the juicy details. Maybe Thomas remembers. The
previous recursive home grown locking was just terrible. I do not see
stop_machine being used in the memory hotplug anymore.
 
I do support this kind of removal because binding CPU and MEM hotplug
locks is fragile and wrong. But this patch really needs more explanation
on why this is safe. In other words what does cpu_read_lock protects
from in mem hotplug paths.

> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  mm/memory_hotplug.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e7c3b219a305..43b8cd4b96f5 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -86,14 +86,12 @@ __setup("memhp_default_state=", setup_memhp_default_state);
>  
>  void mem_hotplug_begin(void)
>  {
> -	cpus_read_lock();
>  	percpu_down_write(&mem_hotplug_lock);
>  }
>  
>  void mem_hotplug_done(void)
>  {
>  	percpu_up_write(&mem_hotplug_lock);
> -	cpus_read_unlock();
>  }
>  
>  u64 max_mem_size = U64_MAX;
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

