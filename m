Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 719D083094
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 10:22:01 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 4so48655240oih.2
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:22:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v7si3188178ita.38.2016.08.18.07.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 07:22:00 -0700 (PDT)
Message-ID: <1471530118.2581.13.camel@redhat.com>
Subject: Re: [PATCH] usercopy: Skip multi-page bounds checking on SLOB
From: Rik van Riel <riel@redhat.com>
Date: Thu, 18 Aug 2016 10:21:58 -0400
In-Reply-To: <20160817222921.GA25148@www.outflux.net>
References: <20160817222921.GA25148@www.outflux.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xiaolong.ye@intel.com

On Wed, 2016-08-17 at 15:29 -0700, Kees Cook wrote:
> When an allocator does not mark all allocations as PageSlab, or does
> not
> mark multipage allocations with __GFP_COMP, hardened usercopy cannot
> correctly validate the allocation. SLOB lacks this, so short-circuit
> the checking for the allocators that aren't marked with
> CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR. This also updates the config
> help and corrects a typo in the usercopy comments.
> 
> Reported-by: xiaolong.ye@intel.com
> Signed-off-by: Kees Cook <keescook@chromium.org>

There may still be some subsystems that do not
go through kmalloc for multi-page allocations,
and also do not use __GFP_COMP

I do not know whether there are, but if they exist
those would still trip up the same way SLOB got
tripped up before your patch.

One big question I have for Linus is, do we want
to allow code that does a higher order allocation,
and then frees part of it in smaller orders, or
individual pages, and keeps using the remainder?

>From both a hardening and a simple stability
point of view, allowing memory to be allocated
in one size, and freed in another, seems like
it could be asking for bugs.

If we decide we do not want to allow that,
we can just do the __GFP_COMP markings
unconditionally, and show a big fat warning
when memory gets freed in a different size
than it was allocated.

Is that something we want to do?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
