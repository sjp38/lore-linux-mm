Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D75C96B026D
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 12:43:21 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 79so15561447ion.20
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 09:43:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u11si2241028iou.230.2018.01.16.09.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jan 2018 09:43:21 -0800 (PST)
Date: Tue, 16 Jan 2018 09:43:15 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: kmem_cache_attr (was Re: [PATCH 04/36] usercopy: Prepare for
 usercopy whitelisting)
Message-ID: <20180116174315.GA10461@bombadil.infradead.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
 <1515531365-37423-5-git-send-email-keescook@chromium.org>
 <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake>
 <20180114230719.GB32027@bombadil.infradead.org>
 <alpine.DEB.2.20.1801160913260.3908@nuc-kabylake>
 <20180116160525.GF30073@bombadil.infradead.org>
 <alpine.DEB.2.20.1801161049320.5162@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801161049320.5162@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, Jan 16, 2018 at 10:54:27AM -0600, Christopher Lameter wrote:
> On Tue, 16 Jan 2018, Matthew Wilcox wrote:
> 
> > I think that's a good thing!  /proc/slabinfo really starts to get grotty
> > above 16 bytes.  I'd like to chop off "_cache" from the name of every
> > single slab!  If ext4_allocation_context has to become ext4_alloc_ctx,
> > I don't think we're going to lose any valuable information.
> 
> Ok so we are going to cut off at 16 charaacters? Sounds good to me.

Excellent!

> > > struct kmem_cache_attr {
> > > 	char *name;
> > > 	size_t size;
> > > 	size_t align;
> > > 	slab_flags_t flags;
> > > 	unsigned int useroffset;
> > > 	unsinged int usersize;
> > > 	void (*ctor)(void *);
> > > 	kmem_isolate_func *isolate;
> > > 	kmem_migrate_func *migrate;
> > > 	...
> > > }
> >
> > In these slightly-more-security-conscious days, it's considered poor
> > practice to have function pointers in writable memory.  That was why
> > I wanted to make the kmem_cache_attr const.
> 
> Sure this data is never changed. It can be const.

It's changed at initialisation.  Look:

kmem_cache_create(const char *name, size_t size, size_t align,
                  slab_flags_t flags, void (*ctor)(void *))
        s = create_cache(cache_name, size, size,
                         calculate_alignment(flags, align, size),
                         flags, ctor, NULL, NULL);

The 'align' that ends up in s->align, is not the user-specified align.
It's also dependent on runtime information (cache_line_size()), so it
can't be calculated at compile time.

'flags' also gets mangled:
        flags &= CACHE_CREATE_MASK;


> I am not married to either way of specifying the sizes. unsigned int would
> be fine with me. SLUB falls back to the page allocator anyways for
> anything above 2* PAGE_SIZE and I think we can do the same for the other
> allocators as well. Zeroing or initializing such a large memory chunk is
> much more expensive than the allocation so it does not make much sense to
> have that directly supported in the slab allocators.

The only slabs larger than 4kB on my system right now are:
kvm_vcpu               0      0  19136    1    8 : tunables    8    4    0 : slabdata      0      0      0
net_namespace          1      1   6080    1    2 : tunables    8    4    0 : slabdata      1      1      0

(other than the fake slabs for kmalloc)

> Some platforms support 64K page size and I could envision a 2M page size
> at some point. So I think we cannot use 16 bits there.
> 
> If no one objects then I can use unsigned int there again.

unsigned int would be my preference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
