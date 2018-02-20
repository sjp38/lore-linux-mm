Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AB7106B002A
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 13:37:02 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u19so5297174pfl.3
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 10:37:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w25si6113385pfk.99.2018.02.20.10.37.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Feb 2018 10:37:01 -0800 (PST)
Date: Tue, 20 Feb 2018 10:36:59 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] slab: fix /proc/slabinfo alignment
Message-ID: <20180220183659.GA12573@bombadil.infradead.org>
References: <BM1PR0101MB2083C73A6E7608B630CE4C26B1CF0@BM1PR0101MB2083.INDPRD01.PROD.OUTLOOK.COM>
 <alpine.DEB.2.20.1802200855300.28634@nuc-kabylake>
 <20180220150449.GF21243@bombadil.infradead.org>
 <alpine.DEB.2.20.1802201004480.29180@nuc-kabylake>
 <20180220161139.GH21243@bombadil.infradead.org>
 <alpine.DEB.2.20.1802201022540.29313@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1802201022540.29313@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: ? ? <mordorw@hotmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Feb 20, 2018 at 10:23:41AM -0600, Christopher Lameter wrote:
> On Tue, 20 Feb 2018, Matthew Wilcox wrote:
> 
> > I don't think it's fixable; there's just too much information per slab.
> > Anyway, I preferred the solution you & I were working on to limit the
> > length of names to 16 bytes, except for the cgroup slabs.
> 
> So what do we do with the cgroup slab names? have a slabinfo per cgroup?

What I had in mind ...

struct kmem_cache_attr {
        const char name[16];
        unsigned int size;
        unsigned int align;
        unsigned int useroffset;
        unsigned int usersize;
        slab_flags_t flags;
        kmem_cache_ctor ctor;
}

struct kmem_cache {
        const struct kmem_cache_attr *a;
        const char *name;
	...
};

In kmem_cache_create_usercopy:

	s->name = a->name;

In memcg_create_kmem_cache:

	s->name = kasprintf(GFP_KERNEL, "%s(%llu:%s)", a->name,
				css->serial_nr, memcg_name_buf);

In slab_kmem_cache_release:

	if (s->name != s->a->name)
		kfree_const(s->name);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
