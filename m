Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 872EA6B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 13:55:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e199so171160178pfh.7
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 10:55:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b5si12946965pfe.489.2017.07.17.10.55.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 10:55:03 -0700 (PDT)
Date: Mon, 17 Jul 2017 10:54:59 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/1] mm/slub.c: add a naive detection of double free or
 corruption
Message-ID: <20170717175459.GC14983@bombadil.infradead.org>
References: <1500309907-9357-1-git-send-email-alex.popov@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500309907-9357-1-git-send-email-alex.popov@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Popov <alex.popov@linux.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, keescook@chromium.org

On Mon, Jul 17, 2017 at 07:45:07PM +0300, Alexander Popov wrote:
> Add an assertion similar to "fasttop" check in GNU C Library allocator:
> an object added to a singly linked freelist should not point to itself.
> That helps to detect some double free errors (e.g. CVE-2017-2636) without
> slub_debug and KASAN. Testing with hackbench doesn't show any noticeable
> performance penalty.

>  {
> +	BUG_ON(object == fp); /* naive detection of double free or corruption */
>  	*(void **)(object + s->offset) = fp;
>  }

Is BUG() the best response to this situation?  If it's a corruption, then
yes, but if we spot a double-free, then surely we should WARN() and return
without doing anything?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
