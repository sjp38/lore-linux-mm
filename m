Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id C4D496B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 00:32:15 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id q107so247079qgd.33
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 21:32:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z8si4012727qaz.106.2014.08.27.21.32.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 21:32:15 -0700 (PDT)
Date: Thu, 28 Aug 2014 12:32:11 +0800
From: WANG Chao <chaowang@redhat.com>
Subject: Re: [PATCH] mm, slub: do not add duplicate sysfs
Message-ID: <20140828043211.GD3971@dhcp-17-37.nay.redhat.com>
References: <1409152488-21227-1-git-send-email-chaowang@redhat.com>
 <alpine.DEB.2.11.1408271023130.17080@gentwo.org>
 <alpine.DEB.2.11.1408271030360.17080@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1408271030360.17080@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "open list:SLAB ALLOCATOR" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

On 08/27/14 at 10:32am, Christoph Lameter wrote:
> Maybe something like this may be a proper fix:
> 
> Subject: slub: Disable tracing of mergeable slabs
> 
> Tracing of mergeable slabs is confusing since the objects
> of multiple slab caches will be traced. Moreover this creates
> a situation where a mergeable slab will become unmergeable.
> 
> If tracing is desired then it may be best to switch merging
> off for starters.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2014-08-08 11:52:30.039681592 -0500
> +++ linux/mm/slub.c	2014-08-27 10:30:16.508108726 -0500
> @@ -4604,6 +4604,14 @@ static ssize_t trace_show(struct kmem_ca
>  static ssize_t trace_store(struct kmem_cache *s, const char *buf,
>  							size_t length)
>  {
> +	/*
> +	 * Tracing a merged cache is going to give confusing results
> +	 * as well as cause other issues like converting a mergeable
> +	 * cache into an umergeable one.
> +	 */
> +	if (s->refcount > 1)
> +		return -EINVAL;
> +
>  	s->flags &= ~SLAB_TRACE;
>  	if (buf[0] == '1') {
>  		s->flags &= ~__CMPXCHG_DOUBLE;

What about failslab_store()? SLAB_FAILSLAB is also a nomerge flag.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
