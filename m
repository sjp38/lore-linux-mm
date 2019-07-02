Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2528BC06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 19:09:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4F8821852
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 19:09:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gf9AynaR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4F8821852
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 772E76B0003; Tue,  2 Jul 2019 15:09:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F99A8E0003; Tue,  2 Jul 2019 15:09:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C0788E0001; Tue,  2 Jul 2019 15:09:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 226FF6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 15:09:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m4so4656732pgs.17
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 12:09:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=7MbyDYqaqvSFQxOK+144mOVh5/lF6H2bN9YDe1mqXsE=;
        b=hVDn4fJQNfKPhictOYZBw31HjPsg39xAjwwu3yYkq4LVWMk7WKlgtwUZUVxfU2eXAc
         mwHrncYwVK9PSYFY2wHOBaUHJUV7e5js7f50JO8+x1j+6ZQbmhHEgvYcohK4B0eDGBwK
         oEI3OLaM9Ae3Z+TOx5HYjAidTGAUElTLBa8JinryhXauo5BCYuLM5mcvjPjjsPff+svI
         6HnBWGxyd+/0+1yf8Ua1J7gtbQ1SmFUXPlqtF9KzdekpftfvOvB32TxhH/Js27jcZoPz
         ElN9kE0ISlbTZd0+eQbbUpTjNJ/ERD+Zl//bGii8Xv5Xh8FCh9MQCcaECPld/roWP8/N
         MIrA==
X-Gm-Message-State: APjAAAWzggViUW4pKyJqdYPHi0osQoO0eqcRnlnlbz+72dDxP3u23NSu
	VD/ZNcHDBFkdQyVj04Oku9ZOo0OEoEEsUqzmLHckleb9ZffFAyW+RjNHiy/+uM3lnyRwZyNmHQW
	iH8PHgeZsQf35t6vBfMvekyroIKkkKkKr7BfNWvY9pIXBfo2DpndbgT8nx1cATE5HPA==
X-Received: by 2002:a17:902:be12:: with SMTP id r18mr26753844pls.341.1562094570702;
        Tue, 02 Jul 2019 12:09:30 -0700 (PDT)
X-Received: by 2002:a17:902:be12:: with SMTP id r18mr26753775pls.341.1562094569863;
        Tue, 02 Jul 2019 12:09:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562094569; cv=none;
        d=google.com; s=arc-20160816;
        b=w1cl0cs5hceCGU2ssY5Doz/nC4cxErcfJ/cj20NoVIcMWDtpsAS9qBif4tDlum7kbE
         1W1iF/Jn7OO9AlPjYpxlIbfPqq9qst/JSCXi2z9MWBWIhjmjlYFn18rv8XVPq+hDImcQ
         yefkDA4/rj8G7gXrAbWXFPybeaGTA7no/iZXlNnjJlq0HFlgT9Jtl41ATXbvzvugqM0f
         nO4M/AmC+OnZJLe30+AePJM48mSvTbHf7WtB+QPTNFEYsHdHA06ZzUjr/xUSyNkBjRG5
         gJEG6UmaIoqx/YHeQAzmTNHMDawGrbM/k9M4TbXMDsKBKxGThJ9pgrHZO4Sa11LIzt+J
         AU2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=7MbyDYqaqvSFQxOK+144mOVh5/lF6H2bN9YDe1mqXsE=;
        b=tQ+/jPV1WzqBqgiw5lGui+l/SUYvTXCYVHCU5TkEo9ALfgBWtbhpwOlPTlXv2ibYXG
         mYNHVpK+EqEalJe0lwGszrBWRv4H/EGE1WUpyOY0lOJTNiETsfnoXo0tZbVjTVzapTtn
         mPOEhcOCVGFXs6l0AFOsjrEhuTJ9HrNQUf32jsMs4MF8Q67xeMdU+P60NO+CaRpTpeSc
         oTHxKHCny75OE+yb4mh/bLmQVWTYKTC7as+J8KRPqW0SMdY+dxU39s1KmkRuykWkyZrr
         WB6kgOiXBUDmk0PvHD1RveuMxWEhav0V6EHFzs0hVlXbw1rgR/3uWEWf8ZtQIaRuWetk
         1Glw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gf9AynaR;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m93sor4477882pje.1.2019.07.02.12.09.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 12:09:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gf9AynaR;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=7MbyDYqaqvSFQxOK+144mOVh5/lF6H2bN9YDe1mqXsE=;
        b=gf9AynaRipCPNwL4fqUj1Kgn+M7Ben9Z5cpa9swnWQpDwgucDeCPC01FXDrDkJ6uY0
         NSSCVdOhd5rccsRnUlWJ3ltnJlP3CpkB1Z4l9dmROza6n7s9SAwfvaIofJOW+IwiIL9D
         rzCy4GxgcbCFYjvq+xCwL1krM+FxBF9je/WbpobhrRQYa2zVlcD4/XurltNaGbLN9rvS
         ede+qAXNcAhTef1SGO6BUKHn/q2Nvk/NaAg2z6OGVU+ZBiu/dqAHr+Q4jibrC9xFD2D6
         NHug/qhQbzlj3lSwkRlT7jw6/nXJDtW+gVpRHI/qNjTEGJuGadXUqOSUe5XpcXv/SWGi
         fj7w==
X-Google-Smtp-Source: APXvYqx9wyjGr3gEZi8btnw1XM/Out5qiZEDMv6+jCbc/ZJawA+a4NDQhc2TqwqowTNEDVgPQ/xJhA==
X-Received: by 2002:a17:90a:338b:: with SMTP id n11mr7294382pjb.21.1562094569110;
        Tue, 02 Jul 2019 12:09:29 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id y22sm29677631pfo.39.2019.07.02.12.09.27
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 02 Jul 2019 12:09:27 -0700 (PDT)
Date: Tue, 2 Jul 2019 12:09:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Waiman Long <longman@redhat.com>
cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, 
    Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, 
    Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
    Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, 
    linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
    cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
    Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>, 
    Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
In-Reply-To: <20190702183730.14461-1-longman@redhat.com>
Message-ID: <alpine.DEB.2.21.1907021206000.67286@chino.kir.corp.google.com>
References: <20190702183730.14461-1-longman@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Jul 2019, Waiman Long wrote:

> diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
> index 29601d93a1c2..2a3d0fc4b4ac 100644
> --- a/Documentation/ABI/testing/sysfs-kernel-slab
> +++ b/Documentation/ABI/testing/sysfs-kernel-slab
> @@ -429,10 +429,12 @@ KernelVersion:	2.6.22
>  Contact:	Pekka Enberg <penberg@cs.helsinki.fi>,
>  		Christoph Lameter <cl@linux-foundation.org>
>  Description:
> -		The shrink file is written when memory should be reclaimed from
> -		a cache.  Empty partial slabs are freed and the partial list is
> -		sorted so the slabs with the fewest available objects are used
> -		first.
> +		A value of '1' is written to the shrink file when memory should
> +		be reclaimed from a cache.  Empty partial slabs are freed and
> +		the partial list is sorted so the slabs with the fewest
> +		available objects are used first.  When a value of '2' is
> +		written, all the corresponding child memory cgroup caches
> +		should be shrunk as well.  All other values are invalid.
>  

This should likely call out that '2' also does '1', that might not be 
clear enough.

>  What:		/sys/kernel/slab/cache/slab_size
>  Date:		May 2007
> diff --git a/mm/slab.h b/mm/slab.h
> index 3b22931bb557..a16b2c7ff4dd 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -174,6 +174,7 @@ int __kmem_cache_shrink(struct kmem_cache *);
>  void __kmemcg_cache_deactivate(struct kmem_cache *s);
>  void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s);
>  void slab_kmem_cache_release(struct kmem_cache *);
> +int kmem_cache_shrink_all(struct kmem_cache *s);
>  
>  struct seq_file;
>  struct file;
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 464faaa9fd81..493697ba1da5 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -981,6 +981,49 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
>  }
>  EXPORT_SYMBOL(kmem_cache_shrink);
>  
> +/**
> + * kmem_cache_shrink_all - shrink a cache and all its memcg children
> + * @s: The root cache to shrink.
> + *
> + * Return: 0 if successful, -EINVAL if not a root cache
> + */
> +int kmem_cache_shrink_all(struct kmem_cache *s)
> +{
> +	struct kmem_cache *c;
> +
> +	if (!IS_ENABLED(CONFIG_MEMCG_KMEM)) {
> +		kmem_cache_shrink(s);
> +		return 0;
> +	}
> +	if (!is_root_cache(s))
> +		return -EINVAL;
> +
> +	/*
> +	 * The caller should have a reference to the root cache and so
> +	 * we don't need to take the slab_mutex. We have to take the
> +	 * slab_mutex, however, to iterate the memcg caches.
> +	 */
> +	get_online_cpus();
> +	get_online_mems();
> +	kasan_cache_shrink(s);
> +	__kmem_cache_shrink(s);
> +
> +	mutex_lock(&slab_mutex);
> +	for_each_memcg_cache(c, s) {
> +		/*
> +		 * Don't need to shrink deactivated memcg caches.
> +		 */
> +		if (s->flags & SLAB_DEACTIVATED)
> +			continue;
> +		kasan_cache_shrink(c);
> +		__kmem_cache_shrink(c);
> +	}
> +	mutex_unlock(&slab_mutex);
> +	put_online_mems();
> +	put_online_cpus();
> +	return 0;
> +}
> +
>  bool slab_is_available(void)
>  {
>  	return slab_state >= UP;

I'm wondering how long this could take, i.e. how long we hold slab_mutex 
while we traverse each cache and shrink it.

Acked-by: David Rientjes <rientjes@google.com>

