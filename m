Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f49.google.com (mail-oa0-f49.google.com [209.85.219.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF5E6B0038
	for <linux-mm@kvack.org>; Fri,  2 May 2014 16:01:56 -0400 (EDT)
Received: by mail-oa0-f49.google.com with SMTP id o6so5719771oag.36
        for <linux-mm@kvack.org>; Fri, 02 May 2014 13:01:55 -0700 (PDT)
Received: from mail-oa0-x229.google.com (mail-oa0-x229.google.com [2607:f8b0:4003:c02::229])
        by mx.google.com with ESMTPS id c10si24850537oed.109.2014.05.02.13.01.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 13:01:55 -0700 (PDT)
Received: by mail-oa0-f41.google.com with SMTP id m1so3205372oag.14
        for <linux-mm@kvack.org>; Fri, 02 May 2014 13:01:55 -0700 (PDT)
Date: Fri, 2 May 2014 15:01:52 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH 2/4] mm: zpool: implement zsmalloc shrinking
Message-ID: <20140502200152.GA18670@cerebellum.variantweb.net>
References: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
 <1397922764-1512-3-git-send-email-ddstreet@ieee.org>
 <CAL1ERfMPcfyUeACnmZ2QF5WxJUQ2PaKbtRzis8sPbQsjnvf_GQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAL1ERfMPcfyUeACnmZ2QF5WxJUQ2PaKbtRzis8sPbQsjnvf_GQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijie.yang@samsung.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Sat, Apr 26, 2014 at 04:37:31PM +0800, Weijie Yang wrote:
> On Sat, Apr 19, 2014 at 11:52 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> > Add zs_shrink() and helper functions to zsmalloc.  Update zsmalloc
> > zs_create_pool() creation function to include ops param that provides
> > an evict() function for use during shrinking.  Update helper function
> > fix_fullness_group() to always reinsert changed zspages even if the
> > fullness group did not change, so they are updated in the fullness
> > group lru.  Also update zram to use the new zsmalloc pool creation
> > function but pass NULL as the ops param, since zram does not use
> > pool shrinking.
> >
> 
> I only review the code without test, however, I think this patch is
> not acceptable.
> 
> The biggest problem is it will call zswap_writeback_entry() under lock,
> zswap_writeback_entry() may sleep, so it is a bug. see below
> 
> The 3/4 patch has a lot of #ifdef, I don't think it's a good kind of
> abstract way.
> 
> What about just disable zswap reclaim when using zsmalloc?

I agree here.  Making a generic allocator layer and zsmalloc reclaim
support should be two different efforts, since zsmalloc reclaim is
fraught with peril.

The generic layer can be done though, as long as you provide a way for
the backend to indicate that it doesn't support reclaim, which just
results in lru-inverse overflow to the swap device at the zswap layer.
Hopefully, if the user overrides the default to use zsmalloc, they
understand the implications and have sized their workload properly.

Also, the fallback logic shouldn't be in this generic layer.  It should
not be transparent to the user.  The user (in this case zswap) should
implement the fallback if they care to have it.  The generic allocator
layer makes it trivial for the user to implement.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
