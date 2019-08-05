Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14C07C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 16:53:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C20F22147A
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 16:53:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C20F22147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 626986B0005; Mon,  5 Aug 2019 12:53:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D7CF6B0006; Mon,  5 Aug 2019 12:53:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ED766B0007; Mon,  5 Aug 2019 12:53:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 167C76B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 12:53:14 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id j12so46535074pll.14
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 09:53:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DApK4ABjISnzW80o1RZHnHbfGyCGt5mCuBoyuEhzjrA=;
        b=aXlfxsWWqgwYYMvJcpY0DgkcbH8nrBrXTTc29acxAUjJn2fwZ5AlFvlXzbC7MQV5rI
         Wm3BdozeL4WFpKvTKkozUqh6Hm6/ma1XtDHM4VlNpXPx1FHgDb04x05RR+AWBMMty9Ea
         FE02cE0ldIucB3Kp65FsjKfODgJShL+CTeE4xn5Ass69eXPE2aYAfXQR3smH1TPHkT/g
         P0cTkCKKFePez8PfypQi5/02xoYUWdP2uOJiIi/XZ2Lw9Z7k/apWPArp1McGt9pw53st
         2o6xxuzS4shqEw4yxiNDN1em38jzqcEHWGvBU3/CK2Htgh/ftx0zk5IXPs8A2MXOc3G7
         2+nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rodrigo.vivi@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=rodrigo.vivi@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUTl6zOtTk3JXIlE0K64EitY98ppYiqrd8/dq26mcPziEhIUNq7
	JTsYXX6r9yyzKDGDfKO3WuWH3VDA426uYbzRQ1PpVeJJgsosmlmdE5Kp/W2pdacoVeI2wy//IxL
	xCjPyzBwKGXgHQF8l56plhKQAEW3quSXVr+GYltSgHP6pbTxHI1SMnV1MqpLy8qCT4g==
X-Received: by 2002:a17:902:934a:: with SMTP id g10mr147830899plp.18.1565023993750;
        Mon, 05 Aug 2019 09:53:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkfxRJfIZ5u3zY4dSze8/OHdCPGyKp63I2q5S/WLIhxCaZxIMdJitVn5lgCwaseyhy7I5A
X-Received: by 2002:a17:902:934a:: with SMTP id g10mr147830854plp.18.1565023993043;
        Mon, 05 Aug 2019 09:53:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565023993; cv=none;
        d=google.com; s=arc-20160816;
        b=ziCSjhnCH/ZcHicrsQK1zQEMlZBzEdTBxXlvdP862pNvaWEzbPauiWmpl0hm/1nHcl
         Llr/20nlOtozk+LMnWYMQJGchfJLiIhRLiCPePfS6Wfupl8yOORmOdaTm3YLVbTG0iw/
         vobslAv6Z4+MO0OriT0ZMwTbyojMGNKjZhBWxOemDRPkddLunmWyzg8ze0jP9YLDxJqx
         3s0sBReZXrOrQ3pPpsDYMBLQ2kquNX68FGv1oT68C2h9Hoiuz6XCpn5GjCX0+wpuumut
         7j0diiAns6nUMgbbPEH81YFU7vxVNXlbVZPlvPk2BjTNn5kAmsUoNeNb6aVtF5onfUk1
         qklg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DApK4ABjISnzW80o1RZHnHbfGyCGt5mCuBoyuEhzjrA=;
        b=DgaWXf9PJcuThKj4dCd9vceM2wt3bcK+ZNfcLsOKtIgCp/NY8mP0h7GCd3bUd0LWbm
         8rkkBhcCXC16DbB08Yg3c5afzHi/J0RQvNzFLwYBrDAwa2u9I4tYLCApPxGQX5aUpuMd
         uhkGO+JnkoGqk9lnQba1ySfziwF6kw6QRBK6tt/QHAIAED1klmltGdruVJHHMG7AsQd1
         H2kxozwAroI+zczEh+pqERnXqGL2Nxpn3YYEdJ1sKR04YDvi3ove4z0qsnFGFfODMo4r
         07Ax9BRrKgQj4vauvEZEhiDX0xHQ5cC6ZIB6N+zChnrVMP8+4GaKFxXtRs55qn4mF8Ff
         fjiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rodrigo.vivi@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=rodrigo.vivi@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id o12si12733266pjp.72.2019.08.05.09.53.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 09:53:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of rodrigo.vivi@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rodrigo.vivi@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=rodrigo.vivi@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Aug 2019 09:53:12 -0700
X-IronPort-AV: E=Sophos;i="5.64,350,1559545200"; 
   d="scan'208";a="168030649"
Received: from rdvivi-losangeles.jf.intel.com (HELO intel.com) ([10.7.196.65])
  by orsmga008-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Aug 2019 09:53:12 -0700
Date: Mon, 5 Aug 2019 09:53:46 -0700
From: Rodrigo Vivi <rodrigo.vivi@intel.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fbdev@vger.kernel.org,
	Jan Kara <jack@suse.cz>, kvm@vger.kernel.org,
	David Airlie <airlied@linux.ie>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Dave Chinner <david@fromorbit.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, sparclinux@vger.kernel.org,
	Ira Weiny <ira.weiny@intel.com>, ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org, rds-devel@oss.oracle.com,
	linux-rdma@vger.kernel.org, x86@kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>, xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org, linux-media@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, intel-gfx@lists.freedesktop.org,
	linux-block@vger.kernel.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-rpi-kernel@lists.infradead.org,
	Dan Williams <dan.j.williams@intel.com>,
	linux-arm-kernel@lists.infradead.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-xfs@vger.kernel.org, linux-crypto@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 06/34] drm/i915: convert put_page() to put_user_page*()
Message-ID: <20190805165346.GB25953@intel.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
 <20190804224915.28669-7-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190804224915.28669-7-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 04, 2019 at 03:48:47PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> This is a merge-able version of the fix, because it restricts
> itself to put_user_page() and put_user_pages(), both of which
> have not changed their APIs. Later, i915_gem_userptr_put_pages()
> can be simplified to use put_user_pages_dirty_lock().

Thanks for that.
with this version we won't have any conflict.

Ack for going through mm tree.

> 
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
> Cc: David Airlie <airlied@linux.ie>
> Cc: intel-gfx@lists.freedesktop.org
> Cc: dri-devel@lists.freedesktop.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  drivers/gpu/drm/i915/gem/i915_gem_userptr.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/gpu/drm/i915/gem/i915_gem_userptr.c b/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
> index 2caa594322bc..76dda2923cf1 100644
> --- a/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
> +++ b/drivers/gpu/drm/i915/gem/i915_gem_userptr.c
> @@ -527,7 +527,7 @@ __i915_gem_userptr_get_pages_worker(struct work_struct *_work)
>  	}
>  	mutex_unlock(&obj->mm.lock);
>  
> -	release_pages(pvec, pinned);
> +	put_user_pages(pvec, pinned);
>  	kvfree(pvec);
>  
>  	i915_gem_object_put(obj);
> @@ -640,7 +640,7 @@ static int i915_gem_userptr_get_pages(struct drm_i915_gem_object *obj)
>  		__i915_gem_userptr_set_active(obj, true);
>  
>  	if (IS_ERR(pages))
> -		release_pages(pvec, pinned);
> +		put_user_pages(pvec, pinned);
>  	kvfree(pvec);
>  
>  	return PTR_ERR_OR_ZERO(pages);
> @@ -675,7 +675,7 @@ i915_gem_userptr_put_pages(struct drm_i915_gem_object *obj,
>  			set_page_dirty_lock(page);
>  
>  		mark_page_accessed(page);
> -		put_page(page);
> +		put_user_page(page);
>  	}
>  	obj->mm.dirty = false;
>  
> -- 
> 2.22.0
> 
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel

