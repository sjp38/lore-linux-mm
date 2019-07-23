Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39915C7618E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:14:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04348218BE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:14:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04348218BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 974646B0006; Tue, 23 Jul 2019 09:14:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FC468E0003; Tue, 23 Jul 2019 09:14:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79F0D8E0002; Tue, 23 Jul 2019 09:14:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4122A6B0006
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:14:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so28224891eds.14
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:14:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2cYVhZNWCxiy6NlWCFG9LBYYQKisgo+/o33vSvTyrLs=;
        b=Fn9kxqEaI7xA/nMvpvtb5uF1VDyorVQQZdg6zVBlaF+QwJHus993RgHp+tHNiX96ig
         StUdeQxdmnEd28sc7JBxxk0/ycrxtbkylqo5n+spZl/hXaw+zStSsnPqbu7LQK8GWek4
         H8DQwohboZhlsZwvddW9fQu7tHuxQfqcyOSkF0aWl3UCRntNtaOanu50dSZNs0eeW4Hz
         lfjC2pWjMRJny+yrbC7MOVGAghcHKlSAc+E50fLRTfm/Q3hh3vtQ537MYtwFyHNipwgZ
         pe7+WqWcRrto7oBH2IcVGEN0X/65XME7oYbU8N6f8vsrVx+byVgnv57A1kaMtK3x1kMk
         Sqxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVoVUTQQIY3mgBwTgD8/c4eZ8jfZ+H/GmEU2pUR9Sh0zzld5Onu
	l2TkKsV/HjO+Se47K6oLjZjwYI96cj8eskTMJQkFaFCre4fMvb0H2hucPXcG9cLBCFuu9h9pBBX
	m2Y5LCW1Rg+1eCsIz3FjepSP2DCFXdrrW4G3NHWZz0VQObE4H70LqeZs1QNHSqAv93w==
X-Received: by 2002:a50:fa96:: with SMTP id w22mr66705934edr.45.1563887654839;
        Tue, 23 Jul 2019 06:14:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfgV6qw5udXrIOLplloyCOgMiohG/j1Z9nbqfVrIMZgvne7IJJxfvPI1ppwDj0D4My+hcv
X-Received: by 2002:a50:fa96:: with SMTP id w22mr66705882edr.45.1563887654268;
        Tue, 23 Jul 2019 06:14:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563887654; cv=none;
        d=google.com; s=arc-20160816;
        b=GkBA2iXIO6SQ5wg8jwmiq694RAUj/8VGCFpAfWe9dsc+Lo0pwz7iedXps1k6/LWVEa
         ijTKc4UYNeQaZl/TjsTuIigJ14MJku0p8WUiWwjS+Bpk4Miy+1HFqfvt7Y7Pbc87KvNK
         Sy7eNvChy9BbMA6v9Vtn6psFGpsnJ3xxOJMJ/Dz/hfVUp6mVhD+Bj5725mrj3frMmFbG
         YhvcWw+0AC4/gmrBm8vGjiOaFlyhFJB1Yg1m2a0esnRGd+Yd4LOCBLxbfXuOwFGM/qL4
         OPf2sUeNIpKXZQKSG8UfaCQYW1OUfAMyqK/FQOhcyFAEePgdT+gu3NjdSefHNiroe0cU
         6Emw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2cYVhZNWCxiy6NlWCFG9LBYYQKisgo+/o33vSvTyrLs=;
        b=Z2RF/KHj1XjdWOnjLo8vidPNTbSxCpNBP4fhsdIlbNqJEza1Z5HxeM0LNd+At1kPi9
         9xD1eMjMhXzyiEw8NZTkNj/uDR8xjNhpVe4uVue7Xyu9Lv6kWAqDjoPqzBMSoEeX/3bH
         uOBvIVvmFALGmWL+GNjiIAe9IyaN1jpjqInHOkf017/dDWmTxeQZCyty5Rt9AAevnkkU
         mPdDxpDIawZUKi04j5GQbwV0kh1gAPKuWkIvN2EJQ7RX8Y56xPfxVslxRdrUBHsNR/nQ
         v7O2p63g5cxD9F41UsZx6uHkVWPlyFxc+fHUigSZjBaMQiueqllsE6hLr3ixpOvLmSW5
         X1Aw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w23si5571466eju.93.2019.07.23.06.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 06:14:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C11D4AC47;
	Tue, 23 Jul 2019 13:14:13 +0000 (UTC)
Date: Tue, 23 Jul 2019 15:14:10 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Weitao Hou <houweitaoo@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, david@redhat.com,
	pasha.tatashin@soleen.com, dan.j.williams@intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hotplug: remove unneeded return for void function
Message-ID: <20190723131401.GA24690@linux>
References: <20190723130814.21826-1-houweitaoo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723130814.21826-1-houweitaoo@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 09:08:14PM +0800, Weitao Hou wrote:
> return is unneeded in void function
> 
> Signed-off-by: Weitao Hou <houweitaoo@gmail.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  mm/memory_hotplug.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 2a9bbddb0e55..c73f09913165 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -132,7 +132,6 @@ static void release_memory_resource(struct resource *res)
>  		return;
>  	release_resource(res);
>  	kfree(res);
> -	return;
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
> @@ -979,7 +978,6 @@ static void rollback_node_hotadd(int nid)
>  	arch_refresh_nodedata(nid, NULL);
>  	free_percpu(pgdat->per_cpu_nodestats);
>  	arch_free_nodedata(pgdat);
> -	return;
>  }
>  
>  
> -- 
> 2.18.0
> 

-- 
Oscar Salvador
SUSE L3

