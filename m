Date: Wed, 26 Apr 2006 21:15:58 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: Lockless page cache test results
Message-ID: <20060426191557.GA9211@suse.de>
References: <20060426135310.GB5083@suse.de> <20060426095511.0cc7a3f9.akpm@osdl.org> <20060426174235.GC5002@suse.de> <20060426111054.2b4f1736.akpm@osdl.org> <Pine.LNX.4.64.0604261144290.3701@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0604261144290.3701@g5.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 26 2006, Linus Torvalds wrote:
> 
> 
> On Wed, 26 Apr 2006, Andrew Morton wrote:
> 
> > Jens Axboe <axboe@suse.de> wrote:
> > > 
> > > Once per page, it's basically exercising the generic_file_splice_read()
> > > path. Basically X number of "clients" open the same file, and fill those
> > > pages into a pipe using splice. The output end of the pipe is then
> > > spliced to /dev/null to toss it away again.
> > 
> > OK.  That doesn't sound like something which a real application is likely
> > to do ;)
> 
> True, but on the other hand, it does kind of "distill" one (small) part of 
> something that real apps _are_ likely to do.
> 
> The whole 'splice to /dev/null' part can be seen as totally irrelevant, 
> but at the same time a way to ignore all the other parts of normal page 
> cache usage (ie the other parts of page cache usage tend to be the "map it 
> into user space" or the actual "memcpy_to/from_user()" or the "TCP send" 
> part).
> 
> The question, of course, is whether the part that remains (the actual page 
> lookup) is important enough to matter, once it is part of a bigger chain 
> in a real application.
> 
> In other words, the splice() thing is just a way to isolate one part of a 
> chain that is usually much more involved, and micro-benchmark just that 
> one part.

Nick called it a find_get_page() micro benchmark, which is pretty might
spot on. So naturally it shows the absolute best side of the lockless
page cache, but that is also very interesting. The /dev/null output can
just be seen as a "infinitely" fast output method, both from a
throughput and light weight POV.

> It would be interesting to see where doing gang-lookup moves the target, 
> but on the other hand, with smaller files (and small files are still 
> common), gang lookup isn't going to help as much.

With a 16-page gang lookup in splice, the top profile for the 4-client
case (which is now at 4GiB/sec instead of 3) are:

samples  %        symbol name
30396    36.7217  __do_page_cache_readahead
25843    31.2212  find_get_pages_contig
9699     11.7174  default_idle

Even disregarding that readahead contender that could probably be made a
little more clever, we are still spending an awful lot of time in the
page lookup. I didn't mention this before, but the get_page/put_page
overhead is also a lot smaller with the lockless patches.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
