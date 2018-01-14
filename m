Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFF9B6B0038
	for <linux-mm@kvack.org>; Sun, 14 Jan 2018 18:07:28 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id f26so10467352iob.13
        for <linux-mm@kvack.org>; Sun, 14 Jan 2018 15:07:28 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j78si6214752itj.85.2018.01.14.15.07.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 14 Jan 2018 15:07:27 -0800 (PST)
Date: Sun, 14 Jan 2018 15:07:19 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 04/36] usercopy: Prepare for usercopy whitelisting
Message-ID: <20180114230719.GB32027@bombadil.infradead.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
 <1515531365-37423-5-git-send-email-keescook@chromium.org>
 <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Jan 10, 2018 at 12:28:23PM -0600, Christopher Lameter wrote:
> On Tue, 9 Jan 2018, Kees Cook wrote:
> > +struct kmem_cache *kmem_cache_create_usercopy(const char *name,
> > +			size_t size, size_t align, slab_flags_t flags,
> > +			size_t useroffset, size_t usersize,
> > +			void (*ctor)(void *));
> 
> Hmmm... At some point we should switch kmem_cache_create to pass a struct
> containing all the parameters. Otherwise the API will blow up with
> additional functions.

Obviously I agree with you.  I'm inclined to not let that delay Kees'
patches; we can fix the few places that use this API later.  At this
point, my proposal for the ultimate form would be:

struct kmem_cache_attr {
	const char name[32];
	void (*ctor)(void *);
	unsigned int useroffset;
	unsigned int user_size; 
};

kmem_create_cache_attr(const struct kmem_cache_attr *attr, unsigned int size,
			unsigned int align, slab_flags_t flags)

(my rationale is that everything in attr should be const, but size, align
and flags all get modified by the slab code).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
