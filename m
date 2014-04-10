Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 254BA6B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 19:38:34 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kx10so4561952pab.5
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 16:38:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ic8si3026595pad.300.2014.04.10.16.38.32
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 16:38:33 -0700 (PDT)
Date: Thu, 10 Apr 2014 16:38:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v2.2] mm: get rid of __GFP_KMEMCG
Message-Id: <20140410163831.c76596b0f8d0bef39a42c63f@linux-foundation.org>
In-Reply-To: <1396537559-17453-1-git-send-email-vdavydov@parallels.com>
References: <1396419365-351-1-git-send-email-vdavydov@parallels.com>
	<1396537559-17453-1-git-send-email-vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Thu, 3 Apr 2014 19:05:59 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:

> Currently to allocate a page that should be charged to kmemcg (e.g.
> threadinfo), we pass __GFP_KMEMCG flag to the page allocator. The page
> allocated is then to be freed by free_memcg_kmem_pages. Apart from
> looking asymmetrical, this also requires intrusion to the general
> allocation path. So let's introduce separate functions that will
> alloc/free pages charged to kmemcg.
> 
> The new functions are called alloc_kmem_pages and free_kmem_pages. They
> should be used when the caller actually would like to use kmalloc, but
> has to fall back to the page allocator for the allocation is large. They
> only differ from alloc_pages and free_pages in that besides allocating
> or freeing pages they also charge them to the kmem resource counter of
> the current memory cgroup.
> 
> ...
>
> +void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
> +{
> +	void *ret;
> +	struct page *page;
> +
> +	flags |= __GFP_COMP;
> +	page = alloc_kmem_pages(flags, order);
> +	ret = page ? page_address(page) : NULL;
> +	kmemleak_alloc(ret, size, 1, flags);
> +	return ret;
> +}

While we're in there it wouldn't hurt to document this: why it exists,
what it does, etc.  And why it sets __GFP_COMP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
