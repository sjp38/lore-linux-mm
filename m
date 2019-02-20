Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DDD3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:05:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2541120880
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:05:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2541120880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC1F48E0037; Wed, 20 Feb 2019 17:05:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B719F8E0002; Wed, 20 Feb 2019 17:05:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A61388E0037; Wed, 20 Feb 2019 17:05:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47B238E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:05:14 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x47so10408407eda.8
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:05:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2DJFRfyEtFXCOTyT/90JFG4VBP6YTJFVG/ddjAQamoM=;
        b=OJs/0rr8EwAaM7IYw3VFIsDZB1bJ5NsCAfah4i+sTVOmw7ftVvAhY1ERQt3U+N4AK8
         nXTbnDGrzrTJgUxQM7tjsc2CiQCruQN+zs2vVw/IYpot06Mb72HB5ACpgQ9hBLXcwYeq
         Lg7fN/lvxTo0GiPezWHOk7alr7Z4gzgGrVnrlxeujt4c08BsZiMpyjoy1JDA+pJZMOvO
         lMlbEtnQNgZkkuAlvS3Uk2uek46mphk9XcyLkKEb8JGgcP/FGuI4dIdWX0nf5QI4kL2q
         Y5ya6hm9vHFa2YiNyyjF8Dt0teJOQDfBN1rRpT6kkBzcLE1UPBZa97xdxpvz29CgfxxU
         zQpw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZ/moEQtpUaUC67zBwYOakgS3mvuaplPwRkNY/cQZwpqjMM2dzF
	7BRdk4D0xu+KuaGKt/9kbK39gMG6w9TZuKOAiI/cUsHY0BjnD0kPVLDY4hB+mSAs/UkgTnr1caY
	XyLU1IaFd/HKXoqyZhNddwLEdmQnp6IK5G/WiCs7bvUySBQ0BvuqLk/qYloN8TQg=
X-Received: by 2002:a50:d5ce:: with SMTP id g14mr22289167edj.213.1550700313851;
        Wed, 20 Feb 2019 14:05:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ/0tw1eS9XPSAY6kZBxLlencD0R2Hqwyf7tGgu2tlO4pAINUmXKZvVGXFqOSL6jrRpmCos
X-Received: by 2002:a50:d5ce:: with SMTP id g14mr22289134edj.213.1550700313031;
        Wed, 20 Feb 2019 14:05:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550700313; cv=none;
        d=google.com; s=arc-20160816;
        b=FnNccFGJA+IcHCtfIdMxWiW3S7A7dbWnEF5xTLDjqPlexwYHeSffOHRuK4oWGQBaCW
         2v6SKiGR/Z/U6X/NXvTXnWvy4ILxzHA1qXjMYXCzIa7Udf6l/KGsVkPSBkPUmrnnSGrv
         bddjOK/sPJfB1PNRSvWBp+MnnZuDdbBF/qkt6aPYWzRlmf+EzEQvK2apL3yHZ2cNJ9Pj
         AVIvAqc7PH2AlEQBHuxPtAm7TEnR1hVNi4RUaVuPiIPgeZLOzaSLDT8VrXiHBrzP03t4
         Zd+6Bp0dWBv/pRbhM3Rw3b8gxYbxN77ndtWWFqH5ukLWQHgamjspbpUX23E1diE7nMoq
         lU8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2DJFRfyEtFXCOTyT/90JFG4VBP6YTJFVG/ddjAQamoM=;
        b=LuDFFNyG6Nawmx15S+vUk9ZfJG+wx4zwjfVBBpv+dzShEz+rGlqZywz6oV2zskOIJq
         Pv8wAEqEAQWvBhza4M7eDCVohJ3CywYgCftF0rCYtvYQkacEVVmTVXQRkTfRAkEEyCLo
         epB/GG0DpcSF5LXvoVTj0AMtrz7EqehdUpcwDPqZAiD5Nz3QLpyvNZOyAn4xqA5elBz2
         ywgwHIkyRWIftPZWbjRVCKELB4QtzO1Um47poHqmt9213NTwVwDgaCjujpCsiZksCcT1
         SbIiVCgODivLE+yO7aocNpgw3h21/VthzlDLDJrFcmo7rT31zR8vVl7Wu0fZBdd14Cqp
         zNmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d50si807941edb.246.2019.02.20.14.05.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 14:05:12 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 56E82B633;
	Wed, 20 Feb 2019 22:05:12 +0000 (UTC)
Date: Wed, 20 Feb 2019 23:05:10 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: DRI Development <dri-devel@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Roman Gushchin <guro@fb.com>, Vlastimil Babka <vbabka@suse.cz>,
	Jan Stancek <jstancek@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Huang Ying <ying.huang@intel.com>,
	Bartosz Golaszewski <brgl@bgdev.pl>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: Don't let userspace spam allocations warnings
Message-ID: <20190220220510.GE4525@dhcp22.suse.cz>
References: <20190220204058.11676-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220204058.11676-1-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 20-02-19 21:40:58, Daniel Vetter wrote:
> memdump_user usually gets fed unchecked userspace input. Blasting a
> full backtrace into dmesg every time is a bit excessive - I'm not sure
> on the kernel rule in general, but at least in drm we're trying not to
> let unpriviledge userspace spam the logs freely. Definitely not entire
> warning backtraces.

Yes, this makes sense to me. This API sounds like an example where
returning ENOMEM to the userspace right away is much better than
spamming the log for large allocation requests. Smaller allocations
simply do not fail and the OOM killer report will be printed regardless
of __GFP_NOWARN.

> It also means more filtering for our CI, because our testsuite
> exercises these corner cases and so hits these a lot.
> 
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Jan Stancek <jstancek@redhat.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Bartosz Golaszewski <brgl@bgdev.pl>
> Cc: linux-mm@kvack.org

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/util.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/util.c b/mm/util.c
> index 1ea055138043..379319b1bcfd 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -150,7 +150,7 @@ void *memdup_user(const void __user *src, size_t len)
>  {
>  	void *p;
>  
> -	p = kmalloc_track_caller(len, GFP_USER);
> +	p = kmalloc_track_caller(len, GFP_USER | __GFP_NOWARN);
>  	if (!p)
>  		return ERR_PTR(-ENOMEM);
>  
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs

