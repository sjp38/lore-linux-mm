Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1DD0C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 12:55:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF635206C3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 12:55:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF635206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 391E26B0007; Wed,  5 Jun 2019 08:55:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3433A6B000A; Wed,  5 Jun 2019 08:55:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20A5F6B000D; Wed,  5 Jun 2019 08:55:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C47F26B0007
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 08:55:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so5643126eda.9
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 05:55:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IHz2VGPKx3Kyl3j6GpLh66ikhQ4s1c1lZFjLDO+H8cc=;
        b=qq5uz1eHn7ZYH8A3EGTYyx4wc74zaAuGmJuh1ymTzZD9BdlY1Ba+A1B20eWpbsRH5x
         cqv/v6fXTqZWErV96WKzGFZxqPLH2VW3E+b0IJHxMJ7O8Cf3dFwNjfuNG418dw2wrk+F
         i4s53QkFFKVfAo6V/W0eP51OOjpsx1+mfgT4mGZyyvDmGCmmrHR9/Ai+zn9PlpJivNYF
         dc2yTaO7Zk8QaEOc71261lqhHzG9E7x1kzFUT3gx5GLeBFc1WraSGlXUmos/OZYMntjT
         VO6n71bjZdzD0+jEsRSbxrka9CYZf1c8z2JxLgT5YmtImssvxPpbVeOz/4AIJEJdBjIy
         fiWQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXfWDMObeH0MGO+1GS1wnIMrKkC3bW9p4tJe0soOVDegH5SIfXV
	7KvdmrizJ0zGfC8yQiRjpRJ9a+WTG89lmVhlyJgt/9PBp7VyDykjKm6zr/9sQiSjpxOGbrwyeJI
	ATKO805EmKQ41CbmVFFH5dxPsurvbrLJwr/cZ2V5SjPZZl0jY4ybRCj2sgQtaJIM=
X-Received: by 2002:a50:987a:: with SMTP id h55mr2596110edb.108.1559739322335;
        Wed, 05 Jun 2019 05:55:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAMG26d5nMfKm0ri2K3+ZS9MqmRaVPkoOeauuQJ83DYa9btX3RKQEQIXtaUe0hbZkW4cYH
X-Received: by 2002:a50:987a:: with SMTP id h55mr2596012edb.108.1559739321314;
        Wed, 05 Jun 2019 05:55:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559739321; cv=none;
        d=google.com; s=arc-20160816;
        b=YX5cM6zHmCqtRutki8FsDVxyDCoEROWU4k0ln2k3URS9wucDfrv03HBGXjOXs67BRE
         VHtEw3wCJVvcWaf4U6p7VHnhSyWbBlFqZzHMqQbpiVAfw0ZjZZMoj20cambPpRZE1hEV
         jnztWEOwCUOkQK7ImUw6ml1LgK2T9hMJrFg149rzow/S0P5u7CC+3WrJuRwkw3WwJ85B
         o4I98jGXjh98FAGH8uOw2tj7bbGyaWe0rcX9tQjy53vuvO/iaC7zmIJRhHDB9wSY1YV7
         FwP7i1R1wdSYX+bFJINu+hBel7IcFBKtlrZ4UccqimxmcUmM5qG5YoTKvo8CTUxPDU/x
         ruug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IHz2VGPKx3Kyl3j6GpLh66ikhQ4s1c1lZFjLDO+H8cc=;
        b=z9C0+/kE67ig4bMJWhE8bUIyEC3d7citXhgmG2HHEXXVTSbOtp+2GMQZMT2fvCZkPa
         aLiDUUi16amdyvdLPeOQXcpjG9wQgphnB1oX3Nu931hDC4ypS++vDjdQlRYFybwoLUh5
         ZN7EqEWgZLhUHhx9FRB53pKiOFSBH8BihfKUyo1u7axVk6F01/R+xhpxc/mzUcH6qFNa
         TTPHdgRgcJJLf7Y3uf7G4a3PKcnWu4qxp28FEBGWUyu8aKKn4b/+5y2JeJBmmP5le3fu
         VQwgoE2e8fsg/jDPZMPXyQndyUXbykPfkYJgcvaGGoj0KnHOMcyulAgfOzC8gK3JcU/B
         zbMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w23si7328002ejn.141.2019.06.05.05.55.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 05:55:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A415BAEE6;
	Wed,  5 Jun 2019 12:55:20 +0000 (UTC)
Date: Wed, 5 Jun 2019 14:55:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH for-5.2-fixes] memcg: Don't loop on css_tryget_online()
 failure
Message-ID: <20190605125520.GF15685@dhcp22.suse.cz>
References: <20190529210617.GP374014@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529210617.GP374014@devbig004.ftw2.facebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 29-05-19 14:06:17, Tejun Heo wrote:
> A PF_EXITING task may stay associated with an offline css.
> get_mem_cgroup_from_mm() may deadlock if mm->owner is in such state.
> All similar logics in memcg are falling back to root memcg on
> tryget_online failure and get_mem_cgroup_from_mm() can do the same.
>
> A similar failure existed for task_get_css() and could be triggered
> through BSD process accounting racing against memcg offlining.  See
> 18fa84a2db0e ("cgroup: Use css_tryget() instead of css_tryget_online()
> in task_get_css()") for details.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Do we need to mark this patch for stable or this is too unlikely to
happen?

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
> ---
>  mm/memcontrol.c |   24 ++++++++++--------------
>  1 file changed, 10 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e50a2db5b4ff..be1fa89db198 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -918,23 +918,19 @@ struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
>  
>  	if (mem_cgroup_disabled())
>  		return NULL;
> +	/*
> +	 * Page cache insertions can happen without an actual mm context,
> +	 * e.g. during disk probing on boot, loopback IO, acct() writes.
> +	 */
> +	if (unlikely(!mm))
> +		return root_mem_cgroup;
>  
>  	rcu_read_lock();
> -	do {
> -		/*
> -		 * Page cache insertions can happen withou an
> -		 * actual mm context, e.g. during disk probing
> -		 * on boot, loopback IO, acct() writes etc.
> -		 */
> -		if (unlikely(!mm))
> -			memcg = root_mem_cgroup;
> -		else {
> -			memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> -			if (unlikely(!memcg))
> -				memcg = root_mem_cgroup;
> -		}
> -	} while (!css_tryget_online(&memcg->css));
> +	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +	if (!css_tryget_online(&memcg->css))
> +		memcg = root_mem_cgroup;
>  	rcu_read_unlock();
> +
>  	return memcg;
>  }
>  EXPORT_SYMBOL(get_mem_cgroup_from_mm);

-- 
Michal Hocko
SUSE Labs

