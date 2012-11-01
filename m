Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 8868F6B0075
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 19:03:44 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so5317236ied.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 16:03:43 -0700 (PDT)
Date: Thu, 1 Nov 2012 16:03:40 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: shmem_getpage_gfp VM_BUG_ON triggered. [3.7rc2]
In-Reply-To: <20121101191052.GA5884@redhat.com>
Message-ID: <alpine.LNX.2.00.1211011546090.19377@eggly.anvils>
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <20121101191052.GA5884@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 1 Nov 2012, Dave Jones wrote:
> On Wed, Oct 24, 2012 at 09:36:27PM -0700, Hugh Dickins wrote:
>  > On Wed, 24 Oct 2012, Dave Jones wrote:
>  > 
>  > > Machine under significant load (4gb memory used, swap usage fluctuating)
>  > > triggered this...
>  > > 
>  > > WARNING: at mm/shmem.c:1151 shmem_getpage_gfp+0xa5c/0xa70()
>  > > 
>  > > 1148                         error = shmem_add_to_page_cache(page, mapping, index,
>  > > 1149                                                 gfp, swp_to_radix_entry(swap));
>  > > 1150                         /* We already confirmed swap, and make no allocation */
>  > > 1151                         VM_BUG_ON(error);
>  > > 1152                 }
>  > 
>  > That's very surprising.  Easy enough to handle an error there, but
>  > of course I made it a VM_BUG_ON because it violates my assumptions:
>  > I rather need to understand how this can be, and I've no idea.
> 
> I just noticed we had a user report hitting this same warning, but
> with a different trace..
> 
> : [<ffffffff8105b84f>] warn_slowpath_common+0x7f/0xc0
> : [<ffffffff8105b8aa>] warn_slowpath_null+0x1a/0x20
> : [<ffffffff81143c73>] shmem_getpage_gfp+0x7f3/0x830
> : [<ffffffff81158c9d>] ? vma_adjust+0x3ed/0x620
> : [<ffffffff81143f02>] shmem_file_aio_read+0x1f2/0x380
> : [<ffffffff8118e487>] do_sync_read+0xa7/0xe0
> : [<ffffffff8118eda9>] vfs_read+0xa9/0x180
> : [<ffffffff8118eeca>] sys_read+0x4a/0x90
> : [<ffffffff816226e9>] system_call_fastpath+0x16/0x1b

Equally explicable by Hannes's hypothesis;
but useful supporting evidence, thank you.

Except... earlier in the thread you explained how you hacked
#define VM_BUG_ON(cond) WARN_ON(cond)
to get this to come out as a warning instead of a bug,
and now it looks as if "a user" has here done the same.

Which is very much a user's right, of course; but does
make me wonder whether that user might actually be davej ;)

Never mind, whatever, it's more justification for the fix - which
I've honestly not forgotten, but somehow not got around to sending
(with a couple of others even longer outstanding).  On its way
shortly, for some unpredictable value of shortly.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
