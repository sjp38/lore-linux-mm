Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1E976B026E
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:03:24 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id d17so15800831ioc.23
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:03:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d22si2999536itb.72.2018.01.16.13.03.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jan 2018 13:03:23 -0800 (PST)
Date: Tue, 16 Jan 2018 13:03:13 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: kmem_cache_attr (was Re: [PATCH 04/36] usercopy: Prepare for
 usercopy whitelisting)
Message-ID: <20180116210313.GA7791@bombadil.infradead.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
 <1515531365-37423-5-git-send-email-keescook@chromium.org>
 <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake>
 <20180114230719.GB32027@bombadil.infradead.org>
 <alpine.DEB.2.20.1801160913260.3908@nuc-kabylake>
 <20180116160525.GF30073@bombadil.infradead.org>
 <alpine.DEB.2.20.1801161049320.5162@nuc-kabylake>
 <20180116174315.GA10461@bombadil.infradead.org>
 <alpine.DEB.2.20.1801161205590.1771@nuc-kabylake>
 <alpine.DEB.2.20.1801161215500.2945@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801161215500.2945@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, Jan 16, 2018 at 12:17:01PM -0600, Christopher Lameter wrote:
> Draft patch of how the data structs could change. kmem_cache_attr is read
> only.

Looks good.  Although I would add Kees' user feature:

struct kmem_cache_attr {
	char name[16];
	unsigned int size;
	unsigned int align;
+	unsigned int useroffset;
+	unsigned int usersize;
	slab_flags_t flags;
	kmem_cache_ctor ctor;
}

And I'd start with 
+struct kmem_cache *kmem_cache_create_attr(const kmem_cache_attr *);

leaving the old kmem_cache_create to kmalloc a kmem_cache_attr and
initialise it.

Can we also do something like this?

-#define KMEM_CACHE(__struct, __flags) kmem_cache_create(#__struct,\
-		sizeof(struct __struct), __alignof__(struct __struct),\
-		(__flags), NULL)
+#define KMEM_CACHE(__struct, __flags) ({				\
+	const struct kmem_cache_attr kca ## __stringify(__struct) = {	\
+		.name = #__struct,					\
+		.size = sizeof(struct __struct),			\
+		.align = __alignof__(struct __struct),			\
+		.flags = (__flags),					\
+	};								\
+	kmem_cache_create_attr(&kca ## __stringify(__struct));		\
+})

That way we won't need to convert any of those users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
