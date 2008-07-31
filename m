Date: Thu, 31 Jul 2008 11:54:56 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
In-Reply-To: <20080731172111.GA23644@shareable.org>
Message-ID: <alpine.LFD.1.10.0807311142510.3277@nehalem.linux-foundation.org>
References: <E1KOIYA-0002FG-Rg@pomaz-ex.szeredi.hu> <20080731001131.GA30900@shareable.org> <20080731004214.GA32207@shareable.org> <alpine.LFD.1.10.0807301746500.3277@nehalem.linux-foundation.org> <20080731061201.GA7156@shareable.org>
 <alpine.LFD.1.10.0807310925360.3277@nehalem.linux-foundation.org> <20080731172111.GA23644@shareable.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 31 Jul 2008, Jamie Lokier wrote:
> 
> But did you miss the bit where you DON'T COPY ANYTHING EVER*?  COW is
> able provide _correctness_ for the rare corner cases which you're not
> optimising for.  You don't actually copy more than 0.0% (*approx).

The thing is, just even _marking_ things COW is the expensive part. If we 
have to walk page tables - we're screwed.

> The cost of COW is TLB flushes*.  But for splice, there ARE NO TLB
> FLUSHES because such files are not mapped writable!

For splice, there are also no flags to set, no extra tracking costs, etc 
etc.

But yes, we could make splice (from a file) do something like

 - just fall back to copy if the page is already mapped (page->mapcount 
   gives us that)

 - set a bit ("splicemapped") when we splice it in, and increment 
   page->mapcount for each splice copy.

 - if a "splicemapped" page is ever mmap'ed or written to (either through 
   write or truncate), we COW it then (and actually move the page cache 
   page - it would be a "woc": a reverse cow, not a normal one).

 - do all of this with page lock held, to make sure that there are no 
   writers or new mappers happening.

So it's probably doable. 

(We could have a separate "splicecount", and actually allow non-writable 
mappings, but I suspect we cannot afford the space in teh "struct space" 
for a whole new count).

> You're missing the real point of network splice().
> 
> It's not just for speed.
> 
> It's for sharing data.  Your TCP buffers can share data, when the same
> big lump is in flight to lots of clients.  Think static file / web /
> FTP server, the kind with 80% of hits to 0.01% of the files roughly
> the same of your RAM.

Maybe. Does it really show up as a big thing?

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
