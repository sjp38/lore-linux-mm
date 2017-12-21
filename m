Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 638CF6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 07:36:35 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id z3so11492727pln.6
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 04:36:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k193si5948397pgc.506.2017.12.21.04.36.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Dec 2017 04:36:34 -0800 (PST)
Date: Thu, 21 Dec 2017 04:36:30 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] Move kfree_call_rcu() to slab_common.c
Message-ID: <20171221123630.GB22405@bombadil.infradead.org>
References: <1513844387-2668-1-git-send-email-rao.shoaib@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1513844387-2668-1-git-send-email-rao.shoaib@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rao.shoaib@oracle.com
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org

On Thu, Dec 21, 2017 at 12:19:47AM -0800, rao.shoaib@oracle.com wrote:
> This patch moves kfree_call_rcu() and related macros out of rcu code. A new
> function __call_rcu_lazy() is created for calling __call_rcu() with the lazy
> flag.

Something you probably didn't know ... there are two RCU implementations
in the kernel; Tree and Tiny.  It looks like you've only added
__call_rcu_lazy() to Tree and you'll also need to add it to Tiny.

> Also moving macros generated following checkpatch noise. I do not know
> how to silence checkpatch as there is nothing wrong.
> 
> CHECK: Macro argument reuse 'offset' - possible side-effects?
> #91: FILE: include/linux/slab.h:348:
> +#define __kfree_rcu(head, offset) \
> +	do { \
> +		BUILD_BUG_ON(!__is_kfree_rcu_offset(offset)); \
> +		kfree_call_rcu(head, (rcu_callback_t)(unsigned long)(offset)); \
> +	} while (0)

What checkpatch is warning you about here is that somebody might call

__kfree_rcu(p, a++);

and this would expand into

	do { \
		BUILD_BUG_ON(!__is_kfree_rcu_offset(a++)); \
		kfree_call_rcu(p, (rcu_callback_t)(unsigned long)(a++)); \
	} while (0)

which would increment 'a' twice, and cause pain and suffering.

That's pretty unlikely usage of __kfree_rcu(), but I suppose it's not
impossible.  We have various hacks to get around this kind of thing;
for example I might do this as::

#define __kfree_rcu(head, offset) \
	do { \
		unsigned long __o = offset;
		BUILD_BUG_ON(!__is_kfree_rcu_offset(__o)); \
		kfree_call_rcu(head, (rcu_callback_t)(unsigned long)(__o)); \
	} while (0)

Now offset is only evaluated once per invocation of the macro.  The other
two warnings are the same problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
