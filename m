Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 50E8D6B025E
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:05:34 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g202so4071595ita.4
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 08:05:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a85si2325936itb.127.2018.01.16.08.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jan 2018 08:05:33 -0800 (PST)
Date: Tue, 16 Jan 2018 08:05:25 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: kmem_cache_attr (was Re: [PATCH 04/36] usercopy: Prepare for
 usercopy whitelisting)
Message-ID: <20180116160525.GF30073@bombadil.infradead.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
 <1515531365-37423-5-git-send-email-keescook@chromium.org>
 <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake>
 <20180114230719.GB32027@bombadil.infradead.org>
 <alpine.DEB.2.20.1801160913260.3908@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801160913260.3908@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, Jan 16, 2018 at 09:21:30AM -0600, Christopher Lameter wrote:
> > struct kmem_cache_attr {
> > 	const char name[32];
> 
> Want to avoid the string reference mess that occurred in the past?
> Is that really necessary? But it would limit the size of the name.

I think that's a good thing!  /proc/slabinfo really starts to get grotty
above 16 bytes.  I'd like to chop off "_cache" from the name of every
single slab!  If ext4_allocation_context has to become ext4_alloc_ctx,
I don't think we're going to lose any valuable information.

My real intent was to reduce the number of allocations; if we can make
it not necessary to kstrdup the name, I think that'd be appreciated by
our CONFIG_TINY friends.

> > (my rationale is that everything in attr should be const, but size, align
> > and flags all get modified by the slab code).
> 
> Thought about putting all the parameters into the kmem_cache_attr struct.
> 
> So
> 
> struct kmem_cache_attr {
> 	char *name;
> 	size_t size;
> 	size_t align;
> 	slab_flags_t flags;
> 	unsigned int useroffset;
> 	unsinged int usersize;
> 	void (*ctor)(void *);
> 	kmem_isolate_func *isolate;
> 	kmem_migrate_func *migrate;
> 	...
> }

In these slightly-more-security-conscious days, it's considered poor
practice to have function pointers in writable memory.  That was why
I wanted to make the kmem_cache_attr const.

Also, there's no need for 'size' and 'align' to be size_t.  Slab should
never support allocations above 4GB in size.  I'm not even keen on seeing
allocations above 64kB, but I see my laptop has six 512kB allocations (!),
three 256kB allocations and seven 128kB allocations, so I must reluctantly
concede that using an unsigned int is necessary.  If I were really into
bitshaving, I might force all allocations to be a multiple of 32-bytes
in size, and then we could use 16 bits to represent an allocation between
32 and 2MB, but I think that tips us beyond the complexity boundary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
