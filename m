Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74F54C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:18:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 407782086A
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:18:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 407782086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C17A96B000A; Fri,  2 Aug 2019 04:18:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC7916B000C; Fri,  2 Aug 2019 04:18:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB67F6B000D; Fri,  2 Aug 2019 04:18:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD606B000A
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 04:18:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id w25so46424703edu.11
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 01:18:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6M63pe2XEPPGAWUPTLNv5NDRHrOKTV/b2W+ZRmFtkYc=;
        b=Q0aT1a6fE0YFk62rfTY5Hwuq3NGgWrJ8fZAhuYAuluofmuhgGUxz0snabm4Z6wGxqA
         RTSOUwqZe1/6m+BhdZSsmwRHhql1VTNY753NvVMsw0EQuI3D5ync2eVoZQL+N24AWMyN
         XJbDtjQ1xU1ONpNbpYqce1scqoGO04WAWcnyxMZfbJ+wp/d4/nKeCjb0FZWyR7I8acUx
         uuGWykHHhxNbOWMM4pkRk+dPp7841cbhPjOf9BDvmdFrdZtBhzhBI6X9id0cSvAMvJzB
         xWw0BEbs126h5wFXX+sQqf46RTlVfvkWbpSM3uUYnyMnlR7ZKjLzi+4oSJwYhhr4SCz0
         9nyg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWk3gx7WNJI19Te7y79wGNRaQP6DNiPIyJWjcZ8NS2YvXksqTxk
	l8sH9NL0AAiGxv0WQQFmZEhTkyn+xhkioKgeE5PCezafBG7MS6QzWe/ka3cKkNQLRxgqt/jQs0+
	A59EW8KcfTaEPt1S8mM3CsuwEsrtwp1CuCdZWshigJEUvDCfFLMOJQRIIr8JtoUs=
X-Received: by 2002:a17:906:6c97:: with SMTP id s23mr105102748ejr.136.1564733891935;
        Fri, 02 Aug 2019 01:18:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCTqdFrnzT2Zpc0BIPIk/8nYO/3ESFQSsb6YC0Oz9KA1gFEUGvAqlem8BNgt4nbfSEE+GN
X-Received: by 2002:a17:906:6c97:: with SMTP id s23mr105102719ejr.136.1564733891306;
        Fri, 02 Aug 2019 01:18:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564733891; cv=none;
        d=google.com; s=arc-20160816;
        b=J9zwnCjmSI5eu/PsbRcahoj9hudyxYflC+mwCkVWKN6uzbPkyJjk22bJ6vjgeh+b4K
         9lBedOjX16AxLBklG0ThuXhzkFAnjkaXSx8d168myLHoS7jl9+xnxdcUsxmhRR2l5W6Z
         +LxDDiLTbR97CSQaDHJ2AkAYLJyLOCZiAKZRRwgueJkInLYBsJNjpevM3xAPsFkOoTip
         pFHdBvUL8uKKTsVfT+w65GCv+jm22qeooBmh6TWJXIr31ccQXYjOWJETu0GiE9cVusiJ
         O0HV3WkgeejQrpliVgiQUwdRKaRLvTPnkZbmVuXne3tOsOIX0Q2x+51Byfhnm9/wo5FK
         hThQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6M63pe2XEPPGAWUPTLNv5NDRHrOKTV/b2W+ZRmFtkYc=;
        b=h2yf1ylUDZVWdObTfl2KI68GYsxfWcCLDbU/vRyLT+G4PVQ66xma80JlO4f/G1EfWD
         edV7micTki5BwbEx0jYqlb4OJUff9OSiKJ0Y+w/5++jhefjrvF2HHvZuq+xuaL08e2Gt
         MLFPHBpNxdLiADBPmGrLuhfsvBwdZSg7O/J19EWjFR4EJXQnnr9SGw8sVqZq+UXXMVzF
         Bg08ynm0jGuT1JEP3Zr+Xx7vOLvKQdMrFK+EHlBys/jaylYQPHS4bCjqIt4e5x2CQNPW
         3hq19G15AB2xTVKwFaj3xYgAmguf5Rk22l510KVOShJVFKNgBq2oySBJ84yRODJD3TtL
         FcLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rl21si21669157ejb.20.2019.08.02.01.18.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 01:18:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D3349AFF1;
	Fri,  2 Aug 2019 08:18:10 +0000 (UTC)
Date: Fri, 2 Aug 2019 10:18:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Masoud Sharbiani <msharbiani@apple.com>, hannes@cmpxchg.org,
	vdavydov.dev@gmail.com, linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Message-ID: <20190802081808.GB6461@dhcp22.suse.cz>
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
 <20190801181952.GA8425@kroah.com>
 <7EE30F16-A90B-47DC-A065-3C21881CD1CC@apple.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7EE30F16-A90B-47DC-A065-3C21881CD1CC@apple.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Hillf, your email client or workflow mangles emails. In this case you
are seem to be reusing the message id from the email you are replying to
which confuses my email client to assume your email is a duplicate.]

On Fri 02-08-19 16:08:01, Hillf Danton wrote:
[...]
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2547,8 +2547,12 @@ retry:
>  	nr_reclaimed = try_to_free_mem_cgroup_pages(mem_over_limit, nr_pages,
>  						    gfp_mask, may_swap);
>  
> -	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
> -		goto retry;
> +	if (mem_cgroup_margin(mem_over_limit) >= nr_pages) {
> +		if (nr_retries--)
> +			goto retry;
> +		/* give up charging memhog */
> +		return -ENOMEM;
> +	}

Huh, what? You are effectively saying that we should fail the charge
when the requested nr_pages would fit in. This doesn't make much sense
to me. What are you trying to achive here?
-- 
Michal Hocko
SUSE Labs

