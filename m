Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D96C16B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:48:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id i123-v6so13577548pfc.13
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:48:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w18-v6si12013041plq.104.2018.07.13.16.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 16:48:06 -0700 (PDT)
Date: Fri, 13 Jul 2018 16:48:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Instability in current -git tree
Message-Id: <20180713164804.fc2c27ccbac4c02ca2c8b984@linux-foundation.org>
In-Reply-To: <CA+55aFy9NJZeqT7h_rAgbKUZLjzfxvDPwneFQracBjVhY53aQQ@mail.gmail.com>
References: <CA+55aFyARQV302+mXNYznrOOjzW+yxbcv+=OkD43dG6G1ktoMQ@mail.gmail.com>
	<alpine.DEB.2.21.1807140031440.2644@nanos.tec.linutronix.de>
	<CA+55aFzBx1haeM2QSFvhaW2t_HVK78Y=bKvsiJmOZztwkZ-y7Q@mail.gmail.com>
	<CA+55aFzVGa57apuzDMBLgWQQRcm3BNBs1UEg-G_2o7YW1i=o2Q@mail.gmail.com>
	<CA+55aFy9NJZeqT7h_rAgbKUZLjzfxvDPwneFQracBjVhY53aQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@redhat.com>, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Miller <davem@davemloft.net>, Al Viro <viro@zeniv.linux.org.uk>, Dave Airlie <airlied@gmail.com>, Tejun Heo <tj@kernel.org>, Ted Ts'o <tytso@google.com>, Mike Snitzer <snitzer@redhat.com>, linux-mm@kvack.org, Daniel Vacek <neelx@redhat.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Mel Gorman <mgorman@techsingularity.net>

On Fri, 13 Jul 2018 16:34:49 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Fri, Jul 13, 2018 at 4:13 PM Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > It does seem to be related to low-memory situation. Maybe page-out.
> > I'm wondering if it's one of the fairly scary MM patches from this
> > merge window
> 
> Woo-hoo! Yes, I got it to happen in text-mode.
> 
>   kernel BUG at mm/page_alloc.c:2016
> 
> with the call chain being
> 
> RIP: move_pfreepages_block()
> Call Trace:
>   steal_suitable_fallback
>   get_page_from_freelist
>   __alloc_pages_nodemask
>   new_slab
>   ___slab_alloc
>   __slab_alloc
>   kmem_cache_alloc
>   __d_alloc
>   d_alloc
>   ...
> 
> (and then it goes down to sys_openat and path lookup).
> 
> I actually used the dcache stress-tester and a stupid "allocate memory
> and keep dirtying it" to get low on memory, and that d_alloc because
> of that.
> 
> And then when VM_BUG_ON() causes a do_exit(), you get a nested
> exception due to "sleeping function called from invalid context" in
> exit_)signals. And then the machine is well and truly dead and f*cked.
> 
> I hate BUG_ON() calls. I wonder how many weeks ago it was that I
> complained about people adding BUG_ON() calls last?
> 
> Anyway, looks like core VM buggery. Now, I don't know *which* one of
> the multiple tests in that VM_BUG_ON() triggered,

They all did:

	VM_BUG_ON(pfn_valid(page_to_pfn(start_page)) &&
	          pfn_valid(page_to_pfn(end_page)) &&
	          page_zone(start_page) != page_zone(end_page));

> and I have no idea
> which commit caused it, but at least non-VM people can probably
> breathe a sigh of release.,

> Andrew, I suspect it's some of yours. Adding Willy, because some of
> the scariest ones in the VM layer are from him (like thall those page
> member movement ones).
> 

Cc's added.  Pavel has been fiddling with this code lately.

The comment is interesting.

	/*
	 * page_zone is not safe to call in this context when
	 * CONFIG_HOLES_IN_ZONE is set. This bug check is probably redundant
	 * anyway as we check zone boundaries in move_freepages_block().
	 * Remove at a later date when no bug reports exist related to
	 * grouping pages by mobility
	 */

but we should work out why we're suddenly getting a range which crosses
zones before we just zap it.

(But it would be interesting to see whether removing the check "fixes" it)
