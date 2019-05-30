Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C337C072B1
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:12:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8047242F9
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:12:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8047242F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 559556B000E; Thu, 30 May 2019 02:12:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50A0E6B027F; Thu, 30 May 2019 02:12:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F9396B0281; Thu, 30 May 2019 02:12:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4D546B000E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 02:12:26 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f15so5290617ede.8
        for <linux-mm@kvack.org>; Wed, 29 May 2019 23:12:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xdJ/3URvdSp0KyZIHuSEzbOlmDTET6N7hN4IpPrd1/k=;
        b=KRIIbknu4EIs89R2OysrSAMve+dLWj9GyxfSm0Ph9ztYyeLf+OOxvSIJm0zI3s6cA2
         qXy/sXdFOc4pCzKc7ZGDnSULDbHiQEX1uIaQJgji/8bTJOcKZoqqKyxDCGgUgRzcz7/o
         nPFD84T2n6W2/FpkIwZ0YwaVS7Wqhlo5QjAm/Cu8tpb8LPt4dv7xkG/EJXeaSpk9X+VD
         aTPGIlDYmXSttN0zK+jPuiJ1QV7X0YhwAKkbM8GVAH9592GlH6SyKJNkFkxOV6HAgcbX
         GWkkqxpUjx0WlS8poG5O/u1/9r0wnIhXx8S+uUix8fSXRMxv4bZvyYBTtlwCWNjfdglV
         SDXQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWDLB4HUgNBlQQstjh70rjPM/TnUqJjHdk56+bg0OKAKQf1k0yl
	PTjTo+MArTc0k2C88rwE1A+egUiIxForU+OQMQpTcXJIXFgTRsLOcUJQ5MWCxVn4K+4llXgUsVG
	IkdQi8nlFjHILAElcxL2SV/S0YNvom9PYjnZHxAs7CfA7TWdlpDhao/DRwAJF2b0=
X-Received: by 2002:a50:d791:: with SMTP id w17mr2437927edi.223.1559196746426;
        Wed, 29 May 2019 23:12:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1agQThM5tlRroy9XO3tU/AuEWjSZ6itrkpM25CEZ9c28uaAxrI2rArCjoCJPjG60K0mlI
X-Received: by 2002:a50:d791:: with SMTP id w17mr2437881edi.223.1559196745655;
        Wed, 29 May 2019 23:12:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559196745; cv=none;
        d=google.com; s=arc-20160816;
        b=CC+AiJvBlqo2UXHwhRrWnByJI5cXiTbkuEAtGVn1rHm2wCi3HyK2MB9Odf7BJ50w3T
         Qg+eIrDBdzOm5hE2YLkW80rnnavcS5t+DmkCVXoED4YWJQL4u47hCGL+hVfvh24uZJJ4
         bU/ncMuRdoMOn4jiGa+f3f7Z2b6BNvKCRcWs0KXlaznS/hZFdgfhHq8o3j/c7n67q43d
         fquXZJhzAYerwBWoKm7OK47/61lkQxahH/tJYRnLm5jn37ZF59BaJlu8oyHGbtJ3iD6p
         xXBttHlxac9ZMcP/wZfkCA3Q5HduxWPPuV1130WEqyxAvS0T8C4wLReRh8zXXkz4lAlw
         bfnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xdJ/3URvdSp0KyZIHuSEzbOlmDTET6N7hN4IpPrd1/k=;
        b=S8YWuzUcWjgW1DcB1zSnYAM3zTEHTHIyjDmuvJmnXNySPhe/n8gee/HfLmDQaqAofq
         d6shw8/Q/fwKxKcJc7phDunOrR5aumQZ01aW31Dvq8wylHqChYUrzYIqVmqR87YQQ3Su
         /6KwnspmKC3KWq2/aFqJ5G+HR8Iq3harna3fRLfMlm7BfiMkjOufZ2q5fyCgUQ4NwK/n
         a4YRAvyIghmDsc24gzOFcj2ILWOEVE5sc8weKyHH8kJpo9OsLZ22tEXqyMcCaf1Bg8ro
         oXUwxBZqo1DN6XxK86lN7/EuGwCafjHUadIXjyKdkx2PwqG13Reoh+8ByyTkPuQC4tT6
         cr/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si1107759ejs.209.2019.05.29.23.12.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 23:12:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AF839B01C;
	Thu, 30 May 2019 06:12:24 +0000 (UTC)
Date: Thu, 30 May 2019 08:12:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Message-ID: <20190530061221.GA6703@dhcp22.suse.cz>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322160307.GA3316@chrisdown.name>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Sorry for a late reply]

On Fri 22-03-19 16:03:07, Chris Down wrote:
[...]
> With this patch, memory.low and memory.min affect reclaim pressure in a
> more understandable and composable way. For example, from a user
> standpoint, "protected" memory now remains untouchable from a reclaim
> aggression standpoint, and users can also have more confidence that
> bursty workloads will still receive some amount of guaranteed
> protection.

Maybe I am missing something so correct me if I am wrong but the new
calculation actually means that we always allow to scan even min
protected memcgs right?

Because ...

[...]

> +static inline unsigned long mem_cgroup_protection(struct mem_cgroup *memcg,
> +						  bool in_low_reclaim)
>  {
> -	if (mem_cgroup_disabled()) {
> -		*min = 0;
> -		*low = 0;
> -		return;
> -	}
> +	if (mem_cgroup_disabled())
> +		return 0;
> +
> +	if (in_low_reclaim)
> +		return READ_ONCE(memcg->memory.emin);
>  
> -	*min = READ_ONCE(memcg->memory.emin);
> -	*low = READ_ONCE(memcg->memory.elow);
> +	return max(READ_ONCE(memcg->memory.emin),
> +		   READ_ONCE(memcg->memory.elow));
>  }
[...]
> +			unsigned long cgroup_size = mem_cgroup_size(memcg);
> +
> +			/* Avoid TOCTOU with earlier protection check */
> +			cgroup_size = max(cgroup_size, protection);
> +
> +			scan = lruvec_size - lruvec_size * protection /
> +				cgroup_size;
>  
[...]
> -			scan = clamp(scan, SWAP_CLUSTER_MAX, lruvec_size);
> +			scan = max(scan, SWAP_CLUSTER_MAX);

here the zero or sub SWAP_CLUSTER_MAX scan target gets extended to
SWAP_CLUSTER_MAX. Unless I am missing something this is not correct
because min protection should be a guarantee even in in_low_reclaim
mode.

>  		} else {
>  			scan = lruvec_size;
>  		}
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

