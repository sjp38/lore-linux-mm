Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E986C6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 20:08:04 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id w15so12558926plp.14
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 17:08:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 71si9341109pge.254.2017.12.21.17.08.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Dec 2017 17:08:03 -0800 (PST)
Date: Thu, 21 Dec 2017 17:07:59 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] mm: Make follow_pte_pmd an inline
Message-ID: <20171222010759.GA23624@bombadil.infradead.org>
References: <20171219165823.24243-1-willy@infradead.org>
 <20171221212943.GB9087@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171221212943.GB9087@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Josh Triplett <josh@joshtriplett.org>, Matthew Wilcox <mawilcox@microsoft.com>

On Thu, Dec 21, 2017 at 02:29:43PM -0700, Ross Zwisler wrote:
> On Tue, Dec 19, 2017 at 08:58:22AM -0800, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > The one user of follow_pte_pmd (dax) emits a sparse warning because
> > it doesn't know that follow_pte_pmd conditionally returns with the
> > pte/pmd locked.  The required annotation is already there; it's just
> > in the wrong file.
> 
> Can you help me find the required annotation that is already there but in the
> wrong file?

You cut it out ... that was the entire contents of the patch!
The cond_lock annotation is correct, but sparse doesn't look across
compilation units, so it can't see the one that's in mm/memory.c when
it's compiling fs/dax.c.  That's why it needs to be in a header file.

> This does seem to quiet a lockep warning in fs/dax.c, but I think we still
> have a related one in mm/memory.c:
> 
> mm/memory.c:4204:5: warning: context imbalance in '__follow_pte_pmd' - different lock contexts for basic block
> 
> Should we deal with this one as well?

I'm not sure how to deal with that one, to be honest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
