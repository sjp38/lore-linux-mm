Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4597C282DA
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 07:12:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC3E320857
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 07:12:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC3E320857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47F978E0003; Fri,  1 Feb 2019 02:12:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42FD38E0001; Fri,  1 Feb 2019 02:12:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 346468E0003; Fri,  1 Feb 2019 02:12:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E1F1A8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 02:12:07 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so4052668pgq.9
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 23:12:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=95zZJsAHZJnIhAwehWVn26owdKuI0eAb1OmScRhF7EY=;
        b=K5en07VM1Xyza/ygXeV4Rbe7puaN83mGjkDAlZ7PMEB+HufmLAZUvvNx9Je8Fbu0f/
         iGorUgAA2nuPWwEHHDp3e1QTYXqg9hUNmP3PNfN25aVpYXB9dOrzBnt/zS8LXpC01y08
         l6MpQ151EZ9InBa9Xif32PzDfEIMQI4fCaVRcbUtXFh/q3f4ag3nN89G3IPRKWY4+RBN
         wWrlukU/tF7h6Pv5ehmJtVhHrRuFMO1XloNCh7756ufgLFCYZrsa2UgJf/3DtAgPe6xm
         Zl4kWyOE/OqQb3EDcpTFnTQf3hAzp3I6Bvm0zOXbWzEV36gvvm/X/RK4FitKNYwB5nU/
         IhuQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukfkRKgUVTbBDbnSuR7sOTtdKwSpj7gOlugvjhn4lt6wzHrw9NAm
	TiugEGiidZLlK5jspVZmaKB9/weEw+jpYU/5FBYTAHM/54tA56cDcpoeJmvxUOtI0uXqBqzIjOM
	DWY7NoGfqoiS5MPh8Aoib1FfyTVTYPE8/A7ZjyRIMdYt0uub1QPN1yuKX4wXAVmQ=
X-Received: by 2002:aa7:8286:: with SMTP id s6mr37391872pfm.63.1549005127543;
        Thu, 31 Jan 2019 23:12:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5tHyiABf3tdU6jbrhS6CQMmYER0w6uBFomywMZwjJW+8Ev/vwyXTXznaGgll7C75K7vghg
X-Received: by 2002:aa7:8286:: with SMTP id s6mr37391853pfm.63.1549005126880;
        Thu, 31 Jan 2019 23:12:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549005126; cv=none;
        d=google.com; s=arc-20160816;
        b=fREkkyKpfu1HNaMc9GsdZKx4lt0MTkBEsGnmoFjZLn6uM5fWeqY9CIbWSRxFOQ7UZT
         mzvZa9FQxYaEptTjixRbY9yBh7zjCpPwsimw4f1HqMUHOguCCXDFSDWu17Ku+PobcYUL
         rG+kibFoWm7guLrPMb7kYwMPIQ1Aqs1KLqrhAm7fzQOCsSEpJZQULE7WegeUfJ59pnYJ
         6ZGXisVoL/0dW6rQrBc3dkegMCKGtc55qKs1tK+pQCsKyhIx6u2N44N8fSWn+II8gef6
         2Z8ns4JA60HaGuXtISUPITYJAMxI+6UJUJ5ud7OKCte0kztECPRGNNWneyTpPSPdj7OJ
         K/HA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=95zZJsAHZJnIhAwehWVn26owdKuI0eAb1OmScRhF7EY=;
        b=WNMRaI5hzM+4wjhF/yL2PyYUSdNx6ohLwqgeidWNjMIi0Iq5u+nr9jJohFiD1cczrU
         oI6tJH2vmVMS45NGF3dWdz69b68JBH5W68jHmIq9NwsdBolkuKyH3eIPNhil1X8aVhtF
         C9Ixpu/EkMR0f/7Ux8Lmpe1l8MrEth4wK9Uhk7BAnFEN2IzHTcRd8/+MSDRrSPhVAYXl
         WMMe71lIaFnohv7aW0hzmA4wMWRLHPsZKIUL82V1giUvd1XytHBfr5hZwBXsMJelDfXI
         /kySuBlTCl7MxRUWmds7u/Oeo1e+jC6r+NgssE4KXcyCqsv2t7rPGK/MTTiQGFHm/mkd
         Hcaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5si6824494pgn.243.2019.01.31.23.12.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 23:12:06 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7AA71ADA9;
	Fri,  1 Feb 2019 07:12:04 +0000 (UTC)
Date: Fri, 1 Feb 2019 08:12:03 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm, memcg: Handle cgroup_disable=memory when getting
 memcg protection
Message-ID: <20190201071203.GD11599@dhcp22.suse.cz>
References: <20190201045711.GA18302@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201045711.GA18302@chrisdown.name>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 31-01-19 23:57:11, Chris Down wrote:
> memcg is NULL if we have CONFIG_MEMCG set, but cgroup_disable=memory on
> the kernel command line.
> 
> Fixes: 8a907cdf0177ab40 ("mm, memcg: proportional memory.{low,min} reclaim")

JFYI this is not a valid sha1. It is from linux next and it will change
with the next linux-next release.

Btw. I still didn't get to look at your patch and I am unlikely to do so
today. I will be offline next week but I will try to get to it after I
get back.

> Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> ---
>  include/linux/memcontrol.h | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 290cfbfd60cd..49742489aa56 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -335,6 +335,9 @@ static inline bool mem_cgroup_disabled(void)
>  
>  static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg)
>  {
> +	if (mem_cgroup_disabled())
> +		return 0;
> +
>  	return max(READ_ONCE(memcg->memory.emin), READ_ONCE(memcg->memory.elow));
>  }
>  
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

