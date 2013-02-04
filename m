Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 4 Feb 2013 15:02:09 -0800
From: Zach Brown <zab@redhat.com>
Subject: Re: [PATCH 2/2] fs/aio.c: use get_user_pages_non_movable() to pin
 ring pages when support memory hotremove
Message-ID: <20130204230209.GK14246@lenny.home.zabbo.net>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
 <1359972248-8722-3-git-send-email-linfeng@cn.fujitsu.com>
 <x49ehgw85w4.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49ehgw85w4.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

> > index 71f613c..0e9b30a 100644
> > --- a/fs/aio.c
> > +++ b/fs/aio.c
> > @@ -138,9 +138,15 @@ static int aio_setup_ring(struct kioctx *ctx)
> >  	}
> >  
> >  	dprintk("mmap address: 0x%08lx\n", info->mmap_base);
> > +#ifdef CONFIG_MEMORY_HOTREMOVE
> > +	info->nr_pages = get_user_pages_non_movable(current, ctx->mm,
> > +					info->mmap_base, nr_pages,
> > +					1, 0, info->ring_pages, NULL);
> > +#else
> >  	info->nr_pages = get_user_pages(current, ctx->mm,
> >  					info->mmap_base, nr_pages, 
> >  					1, 0, info->ring_pages, NULL);
> > +#endif
> 
> Can't you hide this in your 1/1 patch, by providing this function as
> just a static inline wrapper around get_user_pages when
> CONFIG_MEMORY_HOTREMOVE is not enabled?

Yes, please.  Having callers duplicate the call site for a single
optional boolean input is unacceptable.

But do we want another input argument as a name?  Should aio have been
using get_user_pages_fast()? (and so now _fast_non_movable?)

I wonder if it's time to offer the booleans as a _flags() variant, much
like the current internal flags for __get_user_pages().  The write and
force arguments are already booleans, we have a different fast api, and
now we're adding non-movable.  The NON_MOVABLE flag would be 0 without
MEMORY_HOTREMOVE, easy peasy.

Turning current callers' mysterious '1, 1' in to 'WRITE|FORCE' might
also be nice :).

No?

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
