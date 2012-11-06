Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 2A7246B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 18:48:25 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id 10so1900763ied.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2012 15:48:24 -0800 (PST)
Date: Tue, 6 Nov 2012 15:48:20 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: fix shmem_getpage_gfp VM_BUG_ON
In-Reply-To: <20121106135402.GA3543@redhat.com>
Message-ID: <alpine.LNX.2.00.1211061521230.6954@eggly.anvils>
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <20121101191052.GA5884@redhat.com> <alpine.LNX.2.00.1211011546090.19377@eggly.anvils> <20121101232030.GA25519@redhat.com> <alpine.LNX.2.00.1211011627120.19567@eggly.anvils>
 <20121102014336.GA1727@redhat.com> <alpine.LNX.2.00.1211021606580.11106@eggly.anvils> <alpine.LNX.2.00.1211051729590.963@eggly.anvils> <20121106135402.GA3543@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 6 Nov 2012, Dave Jones wrote:
> On Mon, Nov 05, 2012 at 05:32:41PM -0800, Hugh Dickins wrote:
> 
>  > -			/* We already confirmed swap, and make no allocation */
>  > -			VM_BUG_ON(error);
>  > +			/*
>  > +			 * We already confirmed swap under page lock, and make
>  > +			 * no memory allocation here, so usually no possibility
>  > +			 * of error; but free_swap_and_cache() only trylocks a
>  > +			 * page, so it is just possible that the entry has been
>  > +			 * truncated or holepunched since swap was confirmed.
>  > +			 * shmem_undo_range() will have done some of the
>  > +			 * unaccounting, now delete_from_swap_cache() will do
>  > +			 * the rest (including mem_cgroup_uncharge_swapcache).
>  > +			 * Reset swap.val? No, leave it so "failed" goes back to
>  > +			 * "repeat": reading a hole and writing should succeed.
>  > +			 */
>  > +			if (error) {
>  > +				VM_BUG_ON(error != -ENOENT);
>  > +				delete_from_swap_cache(page);
>  > +			}
>  >  		}
> 
> I ran with this overnight,

Thanks a lot...

> and still hit the (new!) VM_BUG_ON

... but that's even more surprising than your original report.

> 
> Perhaps we should print out what 'error' was too ?  I'll rebuild with that..

Thanks; though I thought the error was going to turn out too boring,
and was preparing a debug patch for you to show the expected and found
values too.  But then got very puzzled...
 
> 
> ------------[ cut here ]------------
> WARNING: at mm/shmem.c:1151 shmem_getpage_gfp+0xa5c/0xa70()
> Hardware name: 2012 Client Platform
> Pid: 21798, comm: trinity-child4 Not tainted 3.7.0-rc4+ #54

That's the very same line number as in your original report, despite
the long comment which the patch adds.  Are you sure that kernel was
built with the patch in?

I wouldn't usually question you, but I'm going mad trying to understand
how the VM_BUG_ON(error != -ENOENT) fires.  At the time I wrote that
line, and when I was preparing the debug patch, I was thinking that an
error from shmem_radix_tree_replace could also be -EEXIST, for when a
different something rather than nothing is found [*].  But that's not
the case, shmem_radix_tree_replace returns either 0 or -ENOENT.

So if error != -ENOENT, that means shmem_add_to_page_cache went the
radix_tree_insert route instead of the shmem_radix_tree_replace route;
which means that its 'expected' is NULL, so swp_to_radix_entry(swap)
is NULL; but swp_to_radix_entry() does an "| 2", so however corrupt
the radix_tree might be, I do not understand the new VM_BUG_ON firing.

Please tell me it was the wrong kernel!
Hugh

[*] But in thinking it over, I realize that if shmem_radix_tree_replace
had returned -EEXIST for the "wrong something" case, I would have been
wrong to BUG on that; because just as truncation could remove an entry,
something else could immediately after instantiate a new page there.

So although I believe my VM_BUG_ON(error != -ENOENT) is safe, it's
not saying what I had intended to say with it, and would have been
wrong to say that anyway.  It just looks stupid to me now, rather
like inserting a VM_BUG_ON(false) - but that does become interesting
when you report that you've hit it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
