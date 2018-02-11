Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E580A6B0006
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 16:18:07 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g16so1622114wmg.6
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 13:18:07 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:8b0:10b:1236::1])
        by mx.google.com with ESMTPS id k5si2800497wmg.177.2018.02.11.13.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 11 Feb 2018 13:18:06 -0800 (PST)
Date: Sun, 11 Feb 2018 13:16:46 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
Message-ID: <20180211211646.GC4680@bombadil.infradead.org>
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-4-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180211031920.3424-4-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Sun, Feb 11, 2018 at 05:19:17AM +0200, Igor Stoppa wrote:
> The struct page has a "mapping" field, which can be re-used, to store a
> pointer to the parent area. This will avoid more expensive searches.
> 
> As example, the function find_vm_area is reimplemented, to take advantage
> of the newly introduced field.

Umm.  Is it more efficient?  You're replacing an rb-tree search with a
page-table walk.  You eliminate a spinlock, which is great, but is the
page-table walk more efficient?  I suppose it'll depend on the depth of
the rb-tree, and (at least on x86), the page tables should already be
in cache.

Unrelated to this patch, I'm working on a patch to give us page_type,
and I think I'll allocate a bit to mark pages which are vmalloced.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
