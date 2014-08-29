Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6356B003B
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 01:09:23 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id o8so1881622qcw.17
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 22:09:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q64si8880272qga.126.2014.08.28.22.09.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Aug 2014 22:09:22 -0700 (PDT)
Date: Fri, 29 Aug 2014 13:09:17 +0800
From: WANG Chao <chaowang@redhat.com>
Subject: Re: [PATCH] mm, slub: do not add duplicate sysfs
Message-ID: <20140829050917.GB2831@dhcp-17-37.nay.redhat.com>
References: <1409152488-21227-1-git-send-email-chaowang@redhat.com>
 <alpine.DEB.2.11.1408271023130.17080@gentwo.org>
 <alpine.DEB.2.11.1408271030360.17080@gentwo.org>
 <20140828043211.GD3971@dhcp-17-37.nay.redhat.com>
 <alpine.DEB.2.11.1408280947270.3275@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1408280947270.3275@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "open list:SLAB ALLOCATOR" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

On 08/28/14 at 09:47am, Christoph Lameter wrote:
> On Thu, 28 Aug 2014, WANG Chao wrote:
> 
> > What about failslab_store()? SLAB_FAILSLAB is also a nomerge flag.
> 
> 
> Subject: slub: Disable tracing and failslab for merged slabs
> 
> Tracing of mergeable slabs as well as uses of failslab are
> confusing since the objects of multiple slab caches will be
> affected. Moreover this creates a situation where a mergeable
> slab will become unmergeable.
> 
> If tracing or failslab testing is desired then it may be best to
> switch merging off for starters.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2014-08-08 11:52:30.039681592 -0500
> +++ linux/mm/slub.c	2014-08-28 09:45:58.748840392 -0500
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
> @@ -4721,6 +4729,9 @@ static ssize_t failslab_show(struct kmem
>  static ssize_t failslab_store(struct kmem_cache *s, const char *buf,
>  							size_t length)
>  {
> +	if (s->refcount > 1)
> +		return -EINVAL;
> +
>  	s->flags &= ~SLAB_FAILSLAB;
>  	if (buf[0] == '1')
>  		s->flags |= SLAB_FAILSLAB;

This works for me. Thanks for the fix.

WANG Chao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
