Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8DA6B0007
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 15:21:03 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id o2so369635pls.10
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 12:21:03 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 13si497698pfk.28.2018.02.08.12.21.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Feb 2018 12:21:02 -0800 (PST)
Date: Thu, 8 Feb 2018 12:21:00 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] Warn the user when they could overflow mapcount
Message-ID: <20180208202100.GB3424@bombadil.infradead.org>
References: <20180208021112.GB14918@bombadil.infradead.org>
 <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
 <CA+DvKQLHDR0s=6r4uiHL8kw2_PnfJcwYfPxgQOmuLbc=5k39+g@mail.gmail.com>
 <20180208185648.GB9524@bombadil.infradead.org>
 <CA+DvKQLHcFc3+kW_SnD6hs53yyD5Zi+uAeSgDMm1tRzxqy-Opg@mail.gmail.com>
 <20180208194235.GA3424@bombadil.infradead.org>
 <CA+DvKQKba0iU+tydbmGkAJsxCxazORDnuoe32sy-2nggyagUxQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+DvKQKba0iU+tydbmGkAJsxCxazORDnuoe32sy-2nggyagUxQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Jann Horn <jannh@google.com>, linux-mm@kvack.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, kernel list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Feb 08, 2018 at 02:48:52PM -0500, Daniel Micay wrote:
> I guess it could saturate and then switch to tracking the count via an
> object pointer -> count mapping with a global lock? Whatever the
> solution is should probably be a generic one since it's a recurring
> issue.

I was thinking of saturating _mapcount at 2 billion (allowing _refcount
the extra space to go into the 2-3 billion range).  Once saturated,
disallow all attempts at mapping it until _mapcount has gone below 2
billion again.  We can walk the page->mapping->i_mmap tree and find
tasks with more than, say, 10 mappings each, and kill them.

Now that I think about it, though, perhaps the simplest solution is not
to worry about checking whether _mapcount has saturated, and instead when
adding a new mmap, check whether this task already has it mapped 10 times.
If so, refuse the mapping.

Now we can argue that since pid_max is smaller than 400 million that
_mapcount will never overflow, and so we don't need to check it.
Convincing argument?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
