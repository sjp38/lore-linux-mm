Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40569C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:03:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 080772183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:03:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 080772183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 937656B000A; Thu, 18 Apr 2019 09:03:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E8C66B000D; Thu, 18 Apr 2019 09:03:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FF0B6B000E; Thu, 18 Apr 2019 09:03:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 347F66B000A
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:03:14 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f7so1216858edi.3
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:03:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=W/IJHbTqHqpL2OsIpUgLKcZxDTFvuYW9P+wM6vW1CHo=;
        b=LemJ1Ekii/I8d1GOAroLKnhgdgNdJ7IvTMZyczU5R3FvL6PF6j04u4VICUYKBgut3t
         amVjSiUDyDgO+gZLNhCRgqcwj09cUBgWVDFok6ZNUi/SrqbyF+We/k1CHSprxd0FsNBX
         UXCsmJo+o+HH4oxAvNiUhiURXjDmYqm8tM7sA1+Fy1/Pf98PdemyONTgwGm6kqj2a0bW
         pPA2FifhDwModnpOBFjtD4B5SoAvL2MG8bbyBsnYIkPOb0suGLrASH/O1xToZXgZoVW/
         76JNiTZ9zBBiqZ80R/ew2PO/BxkcyWfCVmzS4kV78HZeSd6cvYx+389Lt2qzrFDfC1b0
         GxWQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX1JiDFUoKBdnDDpVx8h6v2MR7JSUqlgmmQT/9YJzaQ2hmnUd9i
	7TOdm1XkUno2Hr9f++ePbUHlWRwnmpKa5l/f7N23npSIaXn5Vk1s3cq0ACA1FAS1YL52Phb0dtY
	MDiVF6Uc8sG2ZQJXvI1Q6MS4v9ho4fOVi8z8LRXv7e9Nc2uod9mOWcc6bJDSIFFU=
X-Received: by 2002:a50:b3b1:: with SMTP id s46mr60829672edd.202.1555592593790;
        Thu, 18 Apr 2019 06:03:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx57b6B7aZjm2onNXpWUF/Cm9zebhGx+IXn+sx7q4aKvQZRb8mwGwU4Fmzy6+3trrwMCh4f
X-Received: by 2002:a50:b3b1:: with SMTP id s46mr60829613edd.202.1555592592846;
        Thu, 18 Apr 2019 06:03:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555592592; cv=none;
        d=google.com; s=arc-20160816;
        b=tK3Lv885eYEYNpOLuIdOVuzRZ4f+u7ZmxZaDJR5LR7k9hCvMgg9taCAC6Cwv2XdGdH
         7LZPa8TjY+gbzxKqMemltJ/mG7a8kDLl+VdKrDITD0TaIL7wd590GZtt/JUuiIURXv8F
         vfVioFTCQe/J+52F7fxM1w1cOrn2rTk2YWWYbZl5woy2rNg7JNc9IyeIQlA2sNPGRhh0
         z40FHuJQ4G6tATFgxYfN6BLfRYCi71ab610jx/rQ/26y2kPsRQJ6P6q4OkzeTCTaCh85
         KHcYY2h4CizNFBpES50UxiXhxiu96VD0khPuq/Z52Yhv5o6YoueJFjgKv4I3VqAR0qSQ
         DE1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=W/IJHbTqHqpL2OsIpUgLKcZxDTFvuYW9P+wM6vW1CHo=;
        b=wruDsZr7rdNO5PEzaWLT9j0IABKVHdg6btEFD4EMjt1LMPJSPTvHC+iWGpxauwYw2l
         KxUz6IVzvrRVXEmiZjBsJLpoSvPTQpWdTK2mmKZ0agFtB8H7zMLoUhRrNTjCwLdCySO0
         m4csqidkQIVBRL0AjgDAYUsobhYf4D5BGkhj+UNCxHcufN7Dzlwk53wRZx6u6MwiqlS0
         H1C9MjB8yGCw9dZ73+bk0tq9aKf5K9hvW1AhWBFz13l7Yo4iD1LEDzxosqVfv89OfYCh
         m0XXogLe0fi4wXJWxUZ5vbGQQOMj/3GTis59V3yDKDW1jyy+ENch9YVWwo7uHAYtrvRo
         8fvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b89si993438edf.309.2019.04.18.06.03.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 06:03:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 25228B64C;
	Thu, 18 Apr 2019 13:03:12 +0000 (UTC)
Date: Thu, 18 Apr 2019 15:03:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Yang Shi <yang.shi@linux.alibaba.com>,
	Michal Koutny <mkoutny@suse.com>
Subject: Re: [PATCH] mm: use mm.arg_lock in get_cmdline()
Message-ID: <20190418130310.GJ6567@dhcp22.suse.cz>
References: <20190418125827.57479-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418125827.57479-1-ldufour@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal has posted the same patch few days ago http://lkml.kernel.org/r/20190417120347.15397-1-mkoutny@suse.com

On Thu 18-04-19 14:58:27, Laurent Dufour wrote:
> The commit 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end
> and env_start|end in mm_struct") introduce the spinlock arg_lock to protect
> the arg_* and env_* field of the mm_struct structure.
> 
> While reading the code, I found that this new spinlock was not used in
> get_cmdline() to protect access to these fields.
> 
> Fixing this even if there is no issue reported yet for this.
> 
> Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
> Cc: Yang Shi <yang.shi@linux.alibaba.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> ---
>  mm/util.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/util.c b/mm/util.c
> index 05a464929b3e..789760c3028b 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -758,12 +758,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
>  	if (!mm->arg_end)
>  		goto out_mm;	/* Shh! No looking before we're done */
>  
> -	down_read(&mm->mmap_sem);
> +	spin_lock(&mm->arg_lock);
>  	arg_start = mm->arg_start;
>  	arg_end = mm->arg_end;
>  	env_start = mm->env_start;
>  	env_end = mm->env_end;
> -	up_read(&mm->mmap_sem);
> +	spin_unlock(&mm->arg_lock);
>  
>  	len = arg_end - arg_start;
>  
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

