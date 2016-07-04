Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 978A36B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 03:26:30 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ts6so335423877pac.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 00:26:30 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id wo10si2781749pab.206.2016.07.04.00.26.28
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 00:26:29 -0700 (PDT)
Date: Mon, 4 Jul 2016 16:29:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/3] mm/page_owner: track page free call chain
Message-ID: <20160704072944.GA15729@js1304-P5Q-DELUXE>
References: <20160702161656.14071-1-sergey.senozhatsky@gmail.com>
 <20160702161656.14071-4-sergey.senozhatsky@gmail.com>
 <20160704045714.GC14840@js1304-P5Q-DELUXE>
 <20160704050730.GC898@swordfish>
 <20160704052955.GD14840@js1304-P5Q-DELUXE>
 <20160704054524.GD898@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160704054524.GD898@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 04, 2016 at 02:45:24PM +0900, Sergey Senozhatsky wrote:
> On (07/04/16 14:29), Joonsoo Kim wrote:
> > > > On Sun, Jul 03, 2016 at 01:16:56AM +0900, Sergey Senozhatsky wrote:
> > > > > Introduce PAGE_OWNER_TRACK_FREE config option to extend page owner with
> > > > > free_pages() tracking functionality. This adds to the dump_page_owner()
> > > > > output an additional backtrace, that tells us what path has freed the
> > > > > page.
> > > > 
> > > > Hmm... Do you have other ideas to use this feature? Following example is
> > > > just to detect use-after-free and we have other good tools for it
> > > > (KASAN or DEBUG_PAGEALLOC) so I'm not sure whether it's useful or not.
> > > 
> > > there is no kasan for ARM32, for example (apart from the fact that
> > > it's really hard to use kasan sometimes due to its cpu cycles and
> > > memory requirements).
> > 
> > Hmm... for debugging purpose, KASAN provides many more things so IMO it's
> > better to implement/support KASAN in ARM32 rather than expand
> > PAGE_OWNER for free.
> > 
> 
> hm, the last time I checked kasan didn't catch that extra put_page() on

Indeed. It seems that kasan only catch double-free of slab object.

> x86_64. AFAIK, kasan on ARM32 is a bit hard to do properly
> http://www.serverphorums.com/read.php?12,1206479,1281087#msg-1281087

Okay.

> I've played with kasan on arm32 (an internal custom version)... and
> extended page_owner turned out to be *incomparably* easier and faster
> to use (especially paired with stackdepot).

Okay.

> 
> > > educate me, will DEBUG_PAGEALLOC tell us what path has triggered the
> > > extra put_page()? hm... does ARM32 provide ARCH_SUPPORTS_DEBUG_PAGEALLOC?
> > 
> > Hmm... Now, I notice that PAGE_OWNER_TRACK_FREE will detect
> > double-free rather than use-after-free.
> 
> well, yes. current hits bad_page(), page_owner helps to find out who
> stole and spoiled it from under current.
> 
> CPU a							CPU b
> 
> 	alloc_page()
> 	put_page() << legitimate
> 							alloc_page()
> err:
> 	put_page() << legitimate, again.
> 	           << but is actually buggy.
> 
> 							put_page() << double free. but we need
> 								   << to report put_page() from
> 								   << CPU a.

Okay. I think that this patch make finding offending user easier
but it looks like it is a partial solution to detect double-free.
See following example.

CPU a							CPU b

	alloc_page()
	put_page() << legitimate
 							alloc_page()
err:
	put_page() << legitimate, again.
	           << but is actually buggy.

	alloc_page()

							put_page() <<
							legitimate,
							again.
	put_page() << Will report the bug and
	        page_owner have legitimate call stack.

In kasan, quarantine is used to provide some delay for real free and
it makes use-after-free detection more robust. Double-free also can be
benefit from it. Anyway, I will not object more since it looks
the simplest way to improve doublue-free detection for the page
at least for now.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
