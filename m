Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D6DF06B0008
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 15:14:03 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id i11so2323120pgq.10
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 12:14:03 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x16si1078948pgc.817.2018.02.14.12.14.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 12:14:02 -0800 (PST)
Date: Wed, 14 Feb 2018 12:14:00 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-ID: <20180214201400.GD20627@bombadil.infradead.org>
References: <20180214182618.14627-1-willy@infradead.org>
 <20180214182618.14627-3-willy@infradead.org>
 <alpine.DEB.2.20.1802141354530.28235@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1802141354530.28235@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Feb 14, 2018 at 01:55:59PM -0600, Christopher Lameter wrote:
> On Wed, 14 Feb 2018, Matthew Wilcox wrote:
> 
> > +#define kvzalloc_struct(p, member, n, gfp)				\
> > +	(typeof(p))kvzalloc_ab_c(n,					\
> > +		sizeof(*(p)->member) + __must_be_array((p)->member),	\
> > +		offsetof(typeof(*(p)), member), gfp)
> > +
> 
> Uppercase like the similar KMEM_CACHE related macros in
> include/linux/slab.h?>

Do you think that would look better in the users?  Compare:

@@ -1284,7 +1284,7 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
                return -EOPNOTSUPP;
        if (mem.nregions > max_mem_regions)
                return -E2BIG;
-       newmem = kvzalloc(size + mem.nregions * sizeof(*m->regions), GFP_KERNEL);
+       newmem = kvzalloc_struct(newmem, regions, mem.nregions, GFP_KERNEL);
        if (!newmem)
                return -ENOMEM;

@@ -1284,7 +1284,7 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
                return -EOPNOTSUPP;
        if (mem.nregions > max_mem_regions)
                return -E2BIG;
-       newmem = kvzalloc(size + mem.nregions * sizeof(*m->regions), GFP_KERNEL);
+       newmem = KVZALLOC_STRUCT(newmem, regions, mem.nregions, GFP_KERNEL);
        if (!newmem)
                return -ENOMEM;

Making it look like a function is more pleasing to my eye, but I'll
change it if that's the only thing keeping it from being merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
