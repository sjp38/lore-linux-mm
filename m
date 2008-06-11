Subject: Re: [PATCH -mm 17/25] Mlocked Pages are non-reclaimable
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080610145706.4a921cfa.akpm@linux-foundation.org>
References: <20080606202838.390050172@redhat.com>
	 <20080606202859.522708682@redhat.com>
	 <20080606180746.6c2b5288.akpm@linux-foundation.org>
	 <20080610033130.GK19404@wotan.suse.de>
	 <20080610171400.149886cf@cuia.bos.redhat.com>
	 <1213134197.6872.49.camel@lts-notebook>
	 <20080610145706.4a921cfa.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 11 Jun 2008 12:01:24 -0400
Message-Id: <1213200084.6436.31.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: riel@redhat.com, npiggin@suse.de, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-06-10 at 14:57 -0700, Andrew Morton wrote:
> On Tue, 10 Jun 2008 17:43:17 -0400
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > Couple of related items:
> > 
> > + 26-rc5-mm1 + a small fix to the double unlock_page() in
> > shrink_page_list() has been running for a couple of hours on my 32G,
> > 16cpu ia64 numa platform w/o error.  Seems to have survived the merge
> > into -mm, despite the issues Andrew has raised.
> 
> oh goody, thanks.  

I should have mentioned that it's running a fairly heavy stress load to
exercise the vm scalability changes.  Lots of IO, page cache activity,
swapping, mlocking and shmlocking various sized regions, up to 16GB on
32GB machine, migrating of mlocked/shmlocked segments between
nodes,  ...   So far today, the load has been up for ~19.5 hours with no
errors, no softlockups, no oom-kills or such.  

> Johannes's bootmem rewrite is holding up
> surprisingly well.

Well, I am seeing a lot of "potential offnode page_structs" messages for
our funky cache-line interleaved pseudo-node.  I had to limit the prints
to boot at all.  Still investigating.  Looks like slub can't allocate
its initial per node data on that node either.

> 
> gee test.kernel.org takes a long time.
> 
> > + on same platform, Mel Gorman's mminit debug code is reporting that
> > we're using 22 page flags with Noreclaim, Mlock and PAGEFLAGS_EXTENDED
> > configured.
> 
> what is "Mel Gorman's mminit debug code"?

mminit_loglevel={0|1|2}  [I use 3 :)]  shows page flag layout, zone
lists, ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
