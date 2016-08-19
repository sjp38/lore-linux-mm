Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB78F6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:31:43 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id e7so28916795lfe.0
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 03:31:43 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id en19si5747422wjb.128.2016.08.19.03.31.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 03:31:42 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i138so2863425wmf.3
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 03:31:42 -0700 (PDT)
Date: Fri, 19 Aug 2016 12:31:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] usercopy: Skip multi-page bounds checking on SLOB
Message-ID: <20160819103140.GB32632@dhcp22.suse.cz>
References: <20160817222921.GA25148@www.outflux.net>
 <1471530118.2581.13.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471530118.2581.13.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Laura Abbott <labbott@fedoraproject.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xiaolong.ye@intel.com

On Thu 18-08-16 10:21:58, Rik van Riel wrote:
> On Wed, 2016-08-17 at 15:29 -0700, Kees Cook wrote:
> > When an allocator does not mark all allocations as PageSlab, or does
> > not
> > mark multipage allocations with __GFP_COMP, hardened usercopy cannot
> > correctly validate the allocation. SLOB lacks this, so short-circuit
> > the checking for the allocators that aren't marked with
> > CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR. This also updates the config
> > help and corrects a typo in the usercopy comments.
> > 
> > Reported-by: xiaolong.ye@intel.com
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> 
> There may still be some subsystems that do not
> go through kmalloc for multi-page allocations,
> and also do not use __GFP_COMP
> 
> I do not know whether there are, but if they exist
> those would still trip up the same way SLOB got
> tripped up before your patch.
> 
> One big question I have for Linus is, do we want
> to allow code that does a higher order allocation,
> and then frees part of it in smaller orders, or
> individual pages, and keeps using the remainder?

We even have an API for that alloc_pages_exact. I do not think anybody
uses that for copying from/to userspace but this pattern is not all that
rare.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
