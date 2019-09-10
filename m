Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5A86C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:15:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D2582067B
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:15:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="gOqTyL+z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D2582067B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1517B6B0003; Tue, 10 Sep 2019 06:15:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 105106B0006; Tue, 10 Sep 2019 06:15:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F329C6B0007; Tue, 10 Sep 2019 06:15:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0064.hostedemail.com [216.40.44.64])
	by kanga.kvack.org (Postfix) with ESMTP id CD7436B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:15:05 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8287A181AC9B6
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:15:05 +0000 (UTC)
X-FDA: 75918602970.28.rock77_497b8cb688201
X-HE-Tag: rock77_497b8cb688201
X-Filterd-Recvd-Size: 6551
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:15:04 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id f19so16472518eds.12
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 03:15:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ODon5hmEvSfDbCbUXF3A6W7tNv4GSFVh3+NVjwNel7w=;
        b=gOqTyL+zt3UB26GczT4b7POR5YXnYYuTI02Gx+uGCRVsPcQpetfEF7CwWA0N/1ZHdc
         xKgUn78IiZVbGZWCw2gpmaop3GJkSukR1+Ndu8VMNNb2mS9DPXdVNId+nTOpmtqlPtV4
         pImXC0P+R09A3sFx3wEeZQl6Exp7PV56N7LKlFsOcNdKPUK7xfzU6DVgLsLW5oL9is/x
         QZM+zOgMWB1ou50Liuxlw1xLco0OrT5K8vhH6FdHhaqvFPzQwYJisYEceHNYMsp8+hzI
         27dCt38nk/mOexTKtU62jmK+vD2RjDFFysV655uOHBmN74HYJLPJuqEgrZSA28xQoa0h
         volw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=ODon5hmEvSfDbCbUXF3A6W7tNv4GSFVh3+NVjwNel7w=;
        b=i5AI3IEa4ak+tIdHyUiaO4T+sQ2Io0MhBqQEv8YCOrkyOsYW1482gkUE2lQiWxGZhU
         VjuuMxayfzRe6/jltZssPl9JL8xN3ZlG2Su29tAMidjvaduZoT5XPaFhPm6zPwyymv3z
         4zi+hPb0CxUYMFhMZG8269mD5dJfRAjvcvex8K5Y7Wxycip1wn3thVEMYyoOjILUgp8D
         ErKjKPRQzWCJ97sRKKLOfZYYeJegjOJFTkDCNLxlxF6RtzXR6G3cxru0T3RehvCk7rsC
         ASPrZbl3lUwo85TeFznzroXmaoecdrxjavobdqOnMHCMsR5ccmNLCFnWUDDqj6Lv7Pbe
         Rdsg==
X-Gm-Message-State: APjAAAXvrvC4bBs0N8EXB5Bymlg1thkTdhzYih2qc2cydNmwqHXa9I2n
	PvEgui0GWaxbqmoh/dlCRQR5dQ==
X-Google-Smtp-Source: APXvYqzM6qhEC2SFZNeiED85iUL/MlB4L+QjKVmNhS98i6QTmoxNtz8bqI583zfzOKBhIAZYJwZlMg==
X-Received: by 2002:a50:f782:: with SMTP id h2mr28826370edn.225.1568110503296;
        Tue, 10 Sep 2019 03:15:03 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id k20sm3408749edq.17.2019.09.10.03.15.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Sep 2019 03:15:02 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id DA78310416F; Tue, 10 Sep 2019 13:15:02 +0300 (+03)
Date: Tue, 10 Sep 2019 13:15:02 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Alastair D'Silva <alastair@au1.ibm.com>
Cc: alastair@d-silva.org, Andrew Morton <akpm@linux-foundation.org>,
	David Hildenbrand <david@redhat.com>,
	Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Dan Williams <dan.j.williams@intel.com>, Qian Cai <cai@lca.pw>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Logan Gunthorpe <logang@deltatee.com>,
	Ira Weiny <ira.weiny@intel.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/2] memory_hotplug: Add a bounds check to
 check_hotplug_memory_range()
Message-ID: <20190910101502.2ioujfvopyr5krpq@box.shutemov.name>
References: <20190910025225.25904-1-alastair@au1.ibm.com>
 <20190910025225.25904-2-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190910025225.25904-2-alastair@au1.ibm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 12:52:20PM +1000, Alastair D'Silva wrote:
> From: Alastair D'Silva <alastair@d-silva.org>
> 
> On PowerPC, the address ranges allocated to OpenCAPI LPC memory
> are allocated from firmware. These address ranges may be higher
> than what older kernels permit, as we increased the maximum
> permissable address in commit 4ffe713b7587
> ("powerpc/mm: Increase the max addressable memory to 2PB"). It is
> possible that the addressable range may change again in the
> future.
> 
> In this scenario, we end up with a bogus section returned from
> __section_nr (see the discussion on the thread "mm: Trigger bug on
> if a section is not found in __section_nr").
> 
> Adding a check here means that we fail early and have an
> opportunity to handle the error gracefully, rather than rumbling
> on and potentially accessing an incorrect section.
> 
> Further discussion is also on the thread ("powerpc: Perform a bounds
> check in arch_add_memory").
> 
> Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
> ---
>  include/linux/memory_hotplug.h |  1 +
>  mm/memory_hotplug.c            | 19 ++++++++++++++++++-
>  2 files changed, 19 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index f46ea71b4ffd..bc477e98a310 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -110,6 +110,7 @@ extern void __online_page_increment_counters(struct page *page);
>  extern void __online_page_free(struct page *page);
>  
>  extern int try_online_node(int nid);
> +int check_hotplug_memory_addressable(u64 start, u64 size);
>  
>  extern int arch_add_memory(int nid, u64 start, u64 size,
>  			struct mhp_restrictions *restrictions);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c73f09913165..3c5428b014f9 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1030,6 +1030,23 @@ int try_online_node(int nid)
>  	return ret;
>  }
>  
> +#ifndef MAX_POSSIBLE_PHYSMEM_BITS
> +#ifdef MAX_PHYSMEM_BITS
> +#define MAX_POSSIBLE_PHYSMEM_BITS MAX_PHYSMEM_BITS
> +#endif
> +#endif
> +
> +int check_hotplug_memory_addressable(u64 start, u64 size)
> +{
> +#ifdef MAX_POSSIBLE_PHYSMEM_BITS

How can it be not defined? You've defined it 6 lines above.

> +	if ((start + size - 1) >> MAX_POSSIBLE_PHYSMEM_BITS)
> +		return -E2BIG;
> +#endif
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(check_hotplug_memory_addressable);
> +
>  static int check_hotplug_memory_range(u64 start, u64 size)
>  {
>  	/* memory range must be block size aligned */
> @@ -1040,7 +1057,7 @@ static int check_hotplug_memory_range(u64 start, u64 size)
>  		return -EINVAL;
>  	}
>  
> -	return 0;
> +	return check_hotplug_memory_addressable(start, size);
>  }
>  
>  static int online_memory_block(struct memory_block *mem, void *arg)
> -- 
> 2.21.0
> 

-- 
 Kirill A. Shutemov

