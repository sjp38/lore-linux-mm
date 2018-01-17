Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 228C76B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 09:47:46 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id r74so8258372iod.15
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 06:47:46 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [69.252.207.41])
        by mx.google.com with ESMTPS id j63si4655302itb.37.2018.01.17.06.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 06:47:45 -0800 (PST)
Date: Wed, 17 Jan 2018 08:46:41 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: kmem_cache_attr (was Re: [PATCH 04/36] usercopy: Prepare for
 usercopy whitelisting)
In-Reply-To: <20180116210313.GA7791@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1801170843550.12151@nuc-kabylake>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org> <1515531365-37423-5-git-send-email-keescook@chromium.org> <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake> <20180114230719.GB32027@bombadil.infradead.org> <alpine.DEB.2.20.1801160913260.3908@nuc-kabylake>
 <20180116160525.GF30073@bombadil.infradead.org> <alpine.DEB.2.20.1801161049320.5162@nuc-kabylake> <20180116174315.GA10461@bombadil.infradead.org> <alpine.DEB.2.20.1801161205590.1771@nuc-kabylake> <alpine.DEB.2.20.1801161215500.2945@nuc-kabylake>
 <20180116210313.GA7791@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, 16 Jan 2018, Matthew Wilcox wrote:

> On Tue, Jan 16, 2018 at 12:17:01PM -0600, Christopher Lameter wrote:
> > Draft patch of how the data structs could change. kmem_cache_attr is read
> > only.
>
> Looks good.  Although I would add Kees' user feature:

Sure I tried to do this quickly so that the basic struct changes are
visible.

> And I'd start with
> +struct kmem_cache *kmem_cache_create_attr(const kmem_cache_attr *);
>
> leaving the old kmem_cache_create to kmalloc a kmem_cache_attr and
> initialise it.

Well at some point we should convert the callers by putting the
definitions into const kmem_cache_attr initializations. That way
the callbacks function pointers are safe.

> Can we also do something like this?
>
> -#define KMEM_CACHE(__struct, __flags) kmem_cache_create(#__struct,\
> -		sizeof(struct __struct), __alignof__(struct __struct),\
> -		(__flags), NULL)
> +#define KMEM_CACHE(__struct, __flags) ({				\
> +	const struct kmem_cache_attr kca ## __stringify(__struct) = {	\
> +		.name = #__struct,					\
> +		.size = sizeof(struct __struct),			\
> +		.align = __alignof__(struct __struct),			\
> +		.flags = (__flags),					\
> +	};								\
> +	kmem_cache_create_attr(&kca ## __stringify(__struct));		\
> +})
>
> That way we won't need to convert any of those users.

Yep thats what I was planning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
