Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id E31E46B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:32:57 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id os4so194772852pac.5
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 02:32:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id z68si26656323pgz.5.2016.10.17.02.32.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 02:32:57 -0700 (PDT)
Date: Mon, 17 Oct 2016 02:32:55 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3] mm: vmalloc: Replace purge_lock spinlock with atomic
 refcount
Message-ID: <20161017093255.GA17523@infradead.org>
References: <20161016061057.GA26990@infradead.org>
 <1476655575-6588-1-git-send-email-joelaf@google.com>
 <CAJWu+opXocyNmL2bA43NZjx7Se42fzEg6YphiE+Bon2qhpvqSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJWu+opXocyNmL2bA43NZjx7Se42fzEg6YphiE+Bon2qhpvqSg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joelaf@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, Chris Wilson <chris@chris-wilson.co.uk>, Jisheng Zhang <jszhang@marvell.com>, John Dias <joaodias@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Oct 16, 2016 at 03:48:42PM -0700, Joel Fernandes wrote:
> Also, one more thing about the barrier dances you mentioned, this will
> also be done by the spinlock which was there before my patch. So in
> favor of my patch, it doesn't make things any worse than they were and
> actually fixes the reported issue while preserving the original code
> behavior. So I think it is a good thing to fix the issue considering
> so many people are reporting it and any clean ups of the vmalloc code
> itself can follow.

I'm not worried about having barriers, we use them all over our
synchronization primitives.  I'm worried about opencoding them
instead of having them in these well defined helpers.

So based on this discussion and the feedback from Nick I'll
propose a new patch (or rather a series to make it more understandable)
that adds a mutex, adds the lockbreak and gives sensible calling
conventions to __purge_vmap_area_lazy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
