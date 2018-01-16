Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE5986B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 10:21:34 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id b11so3986142itj.0
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 07:21:34 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id u4si2374352iti.93.2018.01.16.07.21.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 07:21:33 -0800 (PST)
Date: Tue, 16 Jan 2018 09:21:30 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: kmem_cache_attr (was Re: [PATCH 04/36] usercopy: Prepare for usercopy
 whitelisting)
In-Reply-To: <20180114230719.GB32027@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1801160913260.3908@nuc-kabylake>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org> <1515531365-37423-5-git-send-email-keescook@chromium.org> <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake> <20180114230719.GB32027@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com

On Sun, 14 Jan 2018, Matthew Wilcox wrote:

> > Hmmm... At some point we should switch kmem_cache_create to pass a struct
> > containing all the parameters. Otherwise the API will blow up with
> > additional functions.
>
> Obviously I agree with you.  I'm inclined to not let that delay Kees'
> patches; we can fix the few places that use this API later.  At this
> point, my proposal for the ultimate form would be:

Right. Thats why I said "at some point"....

>
> struct kmem_cache_attr {
> 	const char name[32];

Want to avoid the string reference mess that occurred in the past?
Is that really necessary? But it would limit the size of the name.

> 	void (*ctor)(void *);
> 	unsigned int useroffset;
> 	unsigned int user_size;
> };
>
> kmem_create_cache_attr(const struct kmem_cache_attr *attr, unsigned int size,
> 			unsigned int align, slab_flags_t flags)
>
> (my rationale is that everything in attr should be const, but size, align
> and flags all get modified by the slab code).

Thought about putting all the parameters into the kmem_cache_attr struct.

So

struct kmem_cache_attr {
	char *name;
	size_t size;
	size_t align;
	slab_flags_t flags;
	unsigned int useroffset;
	unsinged int usersize;
	void (*ctor)(void *);
	kmem_isolate_func *isolate;
	kmem_migrate_func *migrate;
	...
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
