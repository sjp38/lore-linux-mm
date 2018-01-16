Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD216B0253
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:54:31 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w125so4198894itf.0
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 08:54:31 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id e67si2665598itc.98.2018.01.16.08.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 08:54:30 -0800 (PST)
Date: Tue, 16 Jan 2018 10:54:27 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: kmem_cache_attr (was Re: [PATCH 04/36] usercopy: Prepare for
 usercopy whitelisting)
In-Reply-To: <20180116160525.GF30073@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1801161049320.5162@nuc-kabylake>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org> <1515531365-37423-5-git-send-email-keescook@chromium.org> <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake> <20180114230719.GB32027@bombadil.infradead.org> <alpine.DEB.2.20.1801160913260.3908@nuc-kabylake>
 <20180116160525.GF30073@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, 16 Jan 2018, Matthew Wilcox wrote:

> I think that's a good thing!  /proc/slabinfo really starts to get grotty
> above 16 bytes.  I'd like to chop off "_cache" from the name of every
> single slab!  If ext4_allocation_context has to become ext4_alloc_ctx,
> I don't think we're going to lose any valuable information.

Ok so we are going to cut off at 16 charaacters? Sounds good to me.

> > struct kmem_cache_attr {
> > 	char *name;
> > 	size_t size;
> > 	size_t align;
> > 	slab_flags_t flags;
> > 	unsigned int useroffset;
> > 	unsinged int usersize;
> > 	void (*ctor)(void *);
> > 	kmem_isolate_func *isolate;
> > 	kmem_migrate_func *migrate;
> > 	...
> > }
>
> In these slightly-more-security-conscious days, it's considered poor
> practice to have function pointers in writable memory.  That was why
> I wanted to make the kmem_cache_attr const.

Sure this data is never changed. It can be const.

> Also, there's no need for 'size' and 'align' to be size_t.  Slab should
> never support allocations above 4GB in size.  I'm not even keen on seeing
> allocations above 64kB, but I see my laptop has six 512kB allocations (!),
> three 256kB allocations and seven 128kB allocations, so I must reluctantly
> concede that using an unsigned int is necessary.  If I were really into
> bitshaving, I might force all allocations to be a multiple of 32-bytes
> in size, and then we could use 16 bits to represent an allocation between
> 32 and 2MB, but I think that tips us beyond the complexity boundary.

I am not married to either way of specifying the sizes. unsigned int would
be fine with me. SLUB falls back to the page allocator anyways for
anything above 2* PAGE_SIZE and I think we can do the same for the other
allocators as well. Zeroing or initializing such a large memory chunk is
much more expensive than the allocation so it does not make much sense to
have that directly supported in the slab allocators.

Some platforms support 64K page size and I could envision a 2M page size
at some point. So I think we cannot use 16 bits there.

If no one objects then I can use unsigned int there again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
