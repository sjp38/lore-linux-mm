Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5B99C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:58:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86CA6217FA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 21:58:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86CA6217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC4B16B0005; Wed, 17 Apr 2019 17:58:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E74426B0006; Wed, 17 Apr 2019 17:58:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8A966B0007; Wed, 17 Apr 2019 17:58:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A439E6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 17:58:30 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 65so170353plf.22
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:58:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JCM5S0gkR2qqqtfgO9v0jRrej0U2QzvhxpvwqW2iiZE=;
        b=Ssv+BoxKMXi0ugi7zTgbW3v6zN2cRqinyTEtyZ8moYpMEgUm99Xwcid8wgqf4dJTby
         ZinJfQY2ScUetLNGP+Fsl/KLGfsi497sX5YIiUFOXEtSqwUeaFoFvpJVn+UfuwL6++ur
         5tU8dGd/nap8NSjKNH7jQil5KUST7gCBSRH5aFnc0Q67xyXj7t21bNP8U0u+vrDR+fPp
         LgaA+utMOBDwUJCq9NiNK8kxgBV8+bH+4L4Zglli9SxbZTTRFbNsrrdTYNNeG75OZDXh
         ZWvIDkI1Ow0MfuW4Z6mo641uuqcdpDBWQ7ETc4CRSHexD2XQXu6V5+szaz/5LgpvIAf+
         HNcw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUd58SsPzeSePQqSf9V5EwB/bUuZtn7CNn8aWjufrLzQPuF1HGm
	/egiUUHxuFJYa0f5ubJs9TGy9f1rW0FnudTuKuQIFJni6Ggr2Ihqy5yvuzHBhRMyLs8aaUT2Y6F
	IEtf70seU6aHmwFm5ihOFmtBnKOiGX/RiLEXoJONqL4dfP7pyYpplj+wsG0sJU+S03w==
X-Received: by 2002:a63:575e:: with SMTP id h30mr24165598pgm.54.1555538310339;
        Wed, 17 Apr 2019 14:58:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpqfHQoPbdMTCzU2dwuIRP4X1mu5U0zsQw1wnKRZzCNnNEYC6Q1BftbhiHmr/l4CgHVE28
X-Received: by 2002:a63:575e:: with SMTP id h30mr24165565pgm.54.1555538309617;
        Wed, 17 Apr 2019 14:58:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555538309; cv=none;
        d=google.com; s=arc-20160816;
        b=iTowEfrTTOrCBti2joO6AsE1U7n1McsULsDoCLVpr9LRbQ0T8ga9naNzkkIQRinQiP
         auYpQlUVMC2DQlPjYM6TdRZDu0UqFz6e6jbtn0oCpavMVenrWtHO/eWLcr9P6/QDdwkU
         RVvTvvRYpCP+AADEl7Npzmbc2OX8amJK39wZ3i09dsi61UmoW6vM2S98hcFUFlqdJdmX
         P+5b33uwVa1+7L1FkdG13kmZrFIZ6uZyvl5MrwczJULR6b/QHV54FCV0Ugk9jBJlfB8v
         DKd+3JqoUszOu8y5sRKBFqVIJV9f0Ppidw3QHno9eQJ1Tb8nIV5AqzOk9v0O1c7LlgK5
         od0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=JCM5S0gkR2qqqtfgO9v0jRrej0U2QzvhxpvwqW2iiZE=;
        b=vHMDygr+MuglcUl4cna7ZBlQUcgwQ+yxkFinmCJqQMEvR11CG/KDiCgJGKb9k3Nebo
         sg9CVspFoFLxk1ra+whzXcl9nz+SQshGLn0iun9tmMHfyTgllJ1Ji4GEgY4y7ijPB27E
         r4vX8Ktkga8/eK6QEAgHg42jnACqSyerT3w41LeOKSsmdMaOMf0uXvzb1eqekdWsV7hv
         lnN9/zXKsPP+so3gLS7ELJRkUPo02HiOQOas8McBW0kxCNH5jWF6t0v0QC9m/2mc2ljB
         FhIDwnQBEp9yFO2tHSXMgM1wibzyuzG0U6Mi8pE6rXWRBflKenwyabE54AowtsgBqIpk
         KiVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n15si10238pgg.308.2019.04.17.14.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 14:58:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id C52E2A95;
	Wed, 17 Apr 2019 21:58:28 +0000 (UTC)
Date: Wed, 17 Apr 2019 14:58:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com,
 Matthew Wilcox <willy@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>,
 Vlastimil Babka <vbabka@suse.cz>, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v4 1/2] mm: refactor __vunmap() to avoid duplicated call
 to find_vm_area()
Message-Id: <20190417145827.8b1c83bf22de8ba514f157e3@linux-foundation.org>
In-Reply-To: <20190417194002.12369-2-guro@fb.com>
References: <20190417194002.12369-1-guro@fb.com>
	<20190417194002.12369-2-guro@fb.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Apr 2019 12:40:01 -0700 Roman Gushchin <guroan@gmail.com> wrote:

> __vunmap() calls find_vm_area() twice without an obvious reason:
> first directly to get the area pointer, second indirectly by calling
> remove_vm_area(), which is again searching for the area.
> 
> To remove this redundancy, let's split remove_vm_area() into
> __remove_vm_area(struct vmap_area *), which performs the actual area
> removal, and remove_vm_area(const void *addr) wrapper, which can
> be used everywhere, where it has been used before.
> 
> On my test setup, I've got 5-10% speed up on vfree()'ing 1000000
> of 4-pages vmalloc blocks.
> 
> Perf report before:
>   22.64%  cat      [kernel.vmlinux]  [k] free_pcppages_bulk
>   10.30%  cat      [kernel.vmlinux]  [k] __vunmap
>    9.80%  cat      [kernel.vmlinux]  [k] find_vmap_area
>    8.11%  cat      [kernel.vmlinux]  [k] vunmap_page_range
>    4.20%  cat      [kernel.vmlinux]  [k] __slab_free
>    3.56%  cat      [kernel.vmlinux]  [k] __list_del_entry_valid
>    3.46%  cat      [kernel.vmlinux]  [k] smp_call_function_many
>    3.33%  cat      [kernel.vmlinux]  [k] kfree
>    3.32%  cat      [kernel.vmlinux]  [k] free_unref_page
> 
> Perf report after:
>   23.01%  cat      [kernel.kallsyms]  [k] free_pcppages_bulk
>    9.46%  cat      [kernel.kallsyms]  [k] __vunmap
>    9.15%  cat      [kernel.kallsyms]  [k] vunmap_page_range
>    6.17%  cat      [kernel.kallsyms]  [k] __slab_free
>    5.61%  cat      [kernel.kallsyms]  [k] kfree
>    4.86%  cat      [kernel.kallsyms]  [k] bad_range
>    4.67%  cat      [kernel.kallsyms]  [k] free_unref_page_commit
>    4.24%  cat      [kernel.kallsyms]  [k] __list_del_entry_valid
>    3.68%  cat      [kernel.kallsyms]  [k] free_unref_page
>    3.65%  cat      [kernel.kallsyms]  [k] __list_add_valid
>    3.19%  cat      [kernel.kallsyms]  [k] __purge_vmap_area_lazy
>    3.10%  cat      [kernel.kallsyms]  [k] find_vmap_area
>    3.05%  cat      [kernel.kallsyms]  [k] rcu_cblist_dequeue
> 
> ...
>
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2068,6 +2068,24 @@ struct vm_struct *find_vm_area(const void *addr)
>  	return NULL;
>  }
>  
> +static struct vm_struct *__remove_vm_area(struct vmap_area *va)
> +{
> +	struct vm_struct *vm = va->vm;
> +
> +	might_sleep();

Where might __remove_vm_area() sleep?

From a quick scan I'm only seeing vfree(), and that has the
might_sleep_if(!in_interrupt()).

So perhaps we can remove this...

> +	spin_lock(&vmap_area_lock);
> +	va->vm = NULL;
> +	va->flags &= ~VM_VM_AREA;
> +	va->flags |= VM_LAZY_FREE;
> +	spin_unlock(&vmap_area_lock);
> +
> +	kasan_free_shadow(vm);
> +	free_unmap_vmap_area(va);
> +
> +	return vm;
> +}
> +

